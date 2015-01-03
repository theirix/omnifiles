require 'omnifiles'
run Rack::URLMap.new({
 "/f" => OmniFiles::PublicApp,
 "/" => OmniFiles::ProtectedApp
})
