# encoding: utf-8

require 'sinatra'
require 'sinatra/assetpack'
require 'settingslogic'
require 'rack'

module OmniFiles

  # Common sinatra configuration
  class BaseApp < Sinatra::Application
    configure do
      disable :show_exceptions
    end

    before do
      logger.info "Fired " + self.class.to_s
      FileUtils.mkdir_p(Settings.storage_dir)
      FileUtils.mkdir_p(File.dirname(Settings.db))
      @storage = Storage.new Settings.db, logger
    end

    def self.sanitize s
      s.gsub(/[^0-9A-z.\-]/, '_')
    end
  end

end