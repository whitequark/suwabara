module Suwabara
  class AssetHandler

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.host == 'imgcdn.amplifr.dev'
        location = request.url.sub('//imgcdn.amplifr.dev/images',
                                   '//amplifr.dev/system/images')

        [301, {'Location' => location}, []]
      else
        @app.call(env)
      end
    end

  end
end
