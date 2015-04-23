require 'psych'
require 'settingslogic'

module OmniFiles

  class Settings < Settingslogic
    settings_file = (ENV['OMNIFILES_SETTINGS'] or '')
    raise "Please specify a settings file in env OMNIFILES_SETTINGS" unless File.file?(settings_file)
    source settings_file
    namespace ENV['RACK_ENV'] || 'development'
    load!
  end
end
