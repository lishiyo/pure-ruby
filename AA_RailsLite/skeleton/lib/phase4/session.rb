require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      cookie = req.cookies.find {|c| c.name == '_rails_lite_app'}

      if cookie.nil?
        @session = {}
      else
        @session = JSON.parse(cookie.value)
        # deserialized from JSON to hash: { pho: "soup" }
      end
    end

    def [](key) # session['pho'] = 'soup'
      @session[key]
    end

    def []=(key, val) # session['machine'] = 'mocha'
      @session[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      cookie = WEBrick::Cookie.new('_rails_lite_app', @session.to_json)
      res.cookies << cookie
    end
  end
end
