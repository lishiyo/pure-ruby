require_relative '../phase3/controller_base'
require_relative './session'

module Phase4
  class ControllerBase < Phase3::ControllerBase

    def redirect_to(url)
      super # sets status and location header
      session.store_session(@res)
    end

    def render_content(content, type)
      super # sets res.body, res.content_type
      session.store_session(@res)
    end

    # method exposing a `Session` object
    def session
      @session ||= Session.new(@req)
    end
  end
end
