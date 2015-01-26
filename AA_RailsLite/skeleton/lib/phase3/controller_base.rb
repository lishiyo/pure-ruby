require_relative '../phase2/controller_base'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    # render :show


    def render(template_name)

      ctrl_name = self.class.name.underscore # my_controller
      file = "views/#{ctrl_name}/#{template_name}.html.erb"

      f = File.read(file)

      erb_template = ERB.new(f)
      eval_template = erb_template.result(binding)
      # binding takes MyController's instance variables
      render_content(eval_template, 'text/html')

    end
  end
end
