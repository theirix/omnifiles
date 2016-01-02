# encoding: utf-8

require 'sinatra/base'
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
      @storage = Storage.new Settings.db.host, Settings.db.port, Settings.db.name, logger
    end

    def self.sanitize s
      s.gsub(/[^0-9A-z.\-]/, '_')
    end
  end

end
