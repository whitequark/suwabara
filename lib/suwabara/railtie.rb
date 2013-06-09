module Suwabara
  class Railtie < Rails::Railtie
    initializer 'suwabara.insert_middleware' do |app|
      app.config.middleware.use 'Suwabara::AssetHandler'
    end
  end
end
