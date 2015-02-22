# encoding: utf-8

require 'sinatra'
require 'filemagic'
require 'uri'
require 'settingslogic'
require 'rack'

module OmniFiles

  # Public app for GET request
  class PublicApp < BaseApp

    # GET a file
    get '/:name' do |name|
      logger.info "GET by name #{name}"

      halt 500, "Wrong URL" if name != BaseApp.sanitize(name)

      data = @storage.get_file_and_bump name
      logger.info "Data #{data}"
      halt 404, "File not found" unless data

      path = File.join(Settings.storage_dir, name)
      filename = data['original_filename']
      halt 404, "File not found" unless File.exists?(path)

      mime = data['mime']
      mime = 'application/octet-stream' unless mime && mime != ''

      logger.info "File '#{path}' was named '#{filename}'"

      if filename && !filename.empty?
        headers 'X-Original-Filename' => filename
      end
      send_file path, :type => mime
    end

  end

end
