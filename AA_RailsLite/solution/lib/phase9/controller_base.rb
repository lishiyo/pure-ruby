require_relative '../phase8/controller_base'
require_relative './router'
require_relative './url_helpers'

module Phase9
  class ControllerBase < Phase8::ControllerBase
    include URLHelpers
  end
end
