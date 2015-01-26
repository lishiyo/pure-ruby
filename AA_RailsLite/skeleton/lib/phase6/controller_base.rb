require_relative '../phase5/controller_base'

module Phase6
  class ControllerBase < Phase5::ControllerBase
    # use this with the router to call action_name (:index, :show, :create...)
    def invoke_action(name)
      # router.draw do
      #   get Regexp.new("^/cats$"), Cats2Controller, :index
      #   get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
      # end
      # router.get(Regexp.new("^/users$"), Phase6::ControllerBase, :index)

      # http_method = @req.request_method
      # pattern = @req.path
      # controller_class = self # CatsCtrl
      # action_name = name
      #
      # # get(pattern, controller_class, action_name)
      # router.send(http_method )

      #
      # route = Route.new(pattern, http_method, controller_class, action_name)
      # router = Router.new
      #
      # router.match(@req)
      self.send(name)

      unless already_built_response?
        template_name = name # :show, :index..
        render(template_name)
      end
      nil
    end
  end
end
