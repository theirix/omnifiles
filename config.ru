require 'omnifiles'

map '/f' do
  run OmniFiles::PublicApp
end

map OmniFiles::ProtectedApp.assets_prefix do
  run OmniFiles::ProtectedApp.sprockets
end

map '/' do
  run OmniFiles::ProtectedApp
end
