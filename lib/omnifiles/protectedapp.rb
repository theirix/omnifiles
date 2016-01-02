# encoding: utf-8

require 'sinatra/base'
require 'sinatra/flash'
require 'filemagic'
require 'uri'
require 'tempfile'
require 'settingslogic'
require 'haml'
require 'tilt/haml'
require 'rack'

module OmniFiles

  # Protected app for POST request
  class ProtectedApp < BaseApp

    use Rack::Auth::Digest::MD5, "OmniFiles Realm", Settings.auth_opaque do |_|
      Settings.auth_password
    end

    enable :sessions
    set :session_secret, Settings.session_secret

    register Sinatra::Flash

    # POST a file
    post '/store/' do
      store_file
    end

    post '/store' do
      store_file
    end

    def make_visible_filename filename
        filename ? URI.unescape(filename) : "<i>Not provided</i>"
    end

    def format_time_str time
      if time
        time.localtime.to_s
      else
        '<i>Not yet</i>'
      end
    end

    def make_haml_data_from_doc doc
      {
        shortened: doc['shortened'],
        url: url('/f/' + doc['shortened']),
        original_filename: make_visible_filename(doc['original_filename']),
        mime: doc['mime'],
        access_time: format_time_str(doc['accessed']['time']),
        created_time: format_time_str(doc['created']['time']),
        access_count: doc['accessed']['count']
      }
    end

    # GET stat of file
    get '/stat/:name' do |name|
      logger.info "Route GET stat #{name}"

      halt 500, "Wrong URL" if name != BaseApp.sanitize(name)

      data = @storage.get_file name
      halt 404, "File not found" unless data

      @hdata = make_haml_data_from_doc data
      logger.info @hdata.inspect

      haml :stat
    end

    # POST to delete file
    # cannot remap methods
    post '/stat/:name/delete' do |name|
      logger.info "Route POST to delete file #{name}"

      target_path = File.join(Settings.storage_dir, name)

      if @storage.delete_file(name)
        if File.file?(target_path)
          FileUtils.rm target_path
          flash[:notice] = "Successfully deleted file #{name}"
        else
          flash[:error] = "Cannot delete file #{name} from disk"
        end
      else
        flash[:error] = "Cannot delete file #{name} from mongo"
      end

      redirect to('/stat')
    end

    # GET index
    get '/stat' do
        logger.info "Route GET index"

        @hdata = []
        @storage.enumerate_docs do |doc|
            @hdata << make_haml_data_from_doc(doc)
        end

        haml :index
    end

    # POST handler with form/body handling
    def store_file
      logger.info "Route POST store"
      begin
        req = Rack::Request.new(env)
        if !req.POST || req.POST == {}
          logger.info "Saving POST body to temp file"

          original_filename = nil

          # Make a temp file with body content
          temp_file = Tempfile.new("omnifiles-post-")
          File.open(temp_file.path, 'wb') do |ftemp|
            IO.copy_stream(req.body, ftemp)
          end
        else
          logger.info "Using POST form"

          # Use a Rack provided file with content
          post_file = req.POST['file']
          original_filename = URI.escape(File.basename(post_file[:filename]))

          temp_file = post_file[:tempfile]
        end

        store_with_file temp_file.path, original_filename

      ensure
        if temp_file
          temp_file.close
          temp_file.unlink
        end
      end
    end

    # Save temporary file to storage
    def store_with_file path, original_filename
      # Take a sample of file
      sample = Digest::MD5.hexdigest(IO.binread(path, 0x100))

      # Determine file mime and desired url
      mime = FileMagic.mime.file path

      # Short URL is composed from escaped filename from form, mime type and leading file bytes
      shortened = @storage.shorten_file sample, original_filename, mime

      # Save file to storage
      target_path = File.join(Settings.storage_dir, shortened)
      raise "Not so unique id #{shortened}" if File.exists? target_path
      FileUtils.cp path, target_path

      # Put record to storage
      @storage.put_file shortened, original_filename, mime
      short_url = url('/f/'+shortened)

      logger.info "Stored file #{target_path} to shortened #{shortened}, magic '#{mime}'"

      short_url
    end

  end

end
