require_relative '../phase6/router'
require_relative './url_helpers'

module Phase9
  class Route < Phase6::Route
    def initialize(pattern, http_method, controller_class, action_name)
      super
      add_url_helpers
    end

    private

    def add_url_helpers
      case action_name
      when :edit
        name = "edit_#{ class_name_singular }"
        add_url_method(name, "/#{ class_name_plural }/:id/edit")
      when :new
        name = "new_#{ class_name_singular }"
        add_url_method(name, "/#{ class_name_plural }/new")
      when :show, :destroy, :update
        name = "#{ class_name_singular }"
        add_url_method(name, "/#{ class_name_plural }/:id")
      when :index, :create
        name = "#{ class_name_plural }"
        add_url_method(name, "/#{ name }")
      end
    end

    def class_name
      controller_class.to_s.underscore.gsub('_controller', '')
    end

    def class_name_plural
      class_name.pluralize
    end

    def class_name_singular
      class_name.singularize
    end

    def add_url_method(name, path)
      url_name = "#{ name }_url"
      puts "#{ url_name } #=> #{ path }"

      URLHelpers.send(:define_method, url_name) do |*args|
        id = args.first.to_s
        if path.include?(':id') && !id.nil?
          path.gsub!(':id', id)
        end
        path
      end
    end
  end

  class Router < Phase6::Router
    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(
        pattern,
        method,
        controller_class,
        action_name
      )
    end
  end
end
