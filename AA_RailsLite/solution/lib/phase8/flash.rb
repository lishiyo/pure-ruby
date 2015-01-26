require 'json'
require 'webrick'

module Phase8
  class HashWithIndifferentAccess
    def initialize
      @hash = {}
    end

    def [](key)
      @hash[key.to_s]
    end

    def []=(key, val)
      @hash[key.to_s] = val
    end

    def to_json
      @hash.to_json
    end
  end

  class Flash
    def initialize(req)
      cookie = req.cookies.find { |c| c.name == '_rails_lite_app_flash' }

      @flash_now = HashWithIndifferentAccess.new
      @data = HashWithIndifferentAccess.new

      if cookie
        JSON.parse(cookie.value).each do |k, v|
          @flash_now[k] = v
        end
      end
    end

    def now
      @flash_now ||= HashWithIndifferentAccess.new
    end

    def [](key)
      @data[key] || now[key]
    end

    def []=(key, val)
      @data[key] = val
    end

    def store_flash(res)
      cook = WEBrick::Cookie.new(
        "_rails_lite_app_flash",
        @data.to_json
      )
      cook.path = "/"
      res.cookies << cook
    end
  end
end
