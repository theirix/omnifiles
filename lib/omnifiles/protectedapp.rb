# encoding: utf-8

require 'sinatra'
require 'filemagic'
require 'uri'
require 'tempfile'
require 'settingslogic'
require 'haml'
require 'rack'

module OmniFiles

  # Protected app for POST request
  class ProtectedApp < BaseApp

    use Rack::Auth::Digest::MD5, "OmniFiles Realm", Settings.auth_opaque do |_|
      Settings.auth_password
    end

    # POST a file
    post '/store/' do
      store_file
    end

    post '/store' do
      store_file
    end

    def format_time_str time
      if time
        time.localtime.to_s
      else
        '<i>Not yet</i>'
      end
    end

    get '/stat/:name' do |name|
      logger.info "Route GET stat #{name}"

      halt 500, "Wrong URL" if name != BaseApp.sanitize(name)

      data = @storage.get_file name
      halt 404, "File not found" unless data

      @url = url('/f/'+name)
      if data['original_filename']
        @original_filename = URI.unescape data['original_filename']
      else
        @original_filename = "<i>Not provided</i>"
      end
      @access_count = data['accessed']['count']
      @access_time = format_time_str data['accessed']['time']
      @created_time = format_time_str data['created']['time']
      @mime = data['mime']
      @shortened = name

      haml :stat
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
