module Api
  module V1x0
    class ServiceInventoriesController < ApplicationController
      include Mixins::IndexMixin
      include Mixins::ShowMixin
    end
  end
end
