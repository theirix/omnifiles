# encoding: utf-8

require 'sinatra'
require 'filemagic'
require 'uri'
require 'settingslogic'
require 'haml'
require 'rack'

module OmniFiles

  # Protected app for POST request
  class ProtectedApp < BaseApp

    register Sinatra::AssetPack
    assets do
      css :application, [
        '/css/app.css'
      ]
    end


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

    get '/stat/:name' do |name|
      logger.info "Route GET stat #{name}"

      halt 500, "Wrong URL" if name != BaseApp.sanitize(name)

      data = @storage.get_file name
      halt 404, "File not found" unless data

      @url = url('/f/'+name)
      @original_filename = URI.unescape data['original_filename']
      @access_count = data['accessed']
      @mime = data['mime']
      @shortened = name

      haml :stat
    end

    def store_file
      logger.info "Route POST store"
      begin
        req = Rack::Request.new(env)
        post_file = req.POST['file']
        original_filename = URI.escape(File.basename(post_file[:filename]))

        temp_file = post_file[:tempfile]

        # Determine file mime and desired url
        mime = FileMagic.mime.file temp_file.path

        # Short URL is composed from escaped filename from form, mime type and leading file bytes
        shortened = @storage.shorten_file temp_file.path, original_filename, mime

        # Save file to storage
        target_path = File.join(Settings.storage_dir, shortened)
        raise "Not so unique id #{shortened}" if File.exists? target_path
        FileUtils.cp temp_file.path, target_path

        # Put record to storage
        @storage.put_file shortened, original_filename, mime
        short_url = url('/f/'+shortened)

        logger.info "Stored file #{target_path} to shortened #{shortened}, magic '#{mime}'"

        short_url
      ensure
        if temp_file
          temp_file.close
          temp_file.unlink
        end
      end
    end

  end

end