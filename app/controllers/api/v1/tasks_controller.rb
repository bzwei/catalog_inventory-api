module Api
  module V1
    class TasksController < ApplicationController
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin

      def update
        model.update(params.require(:id), params_for_update)

        if ENV['NO_KAFKA'].blank?
          CatalogInventory::Api::Messaging.client.publish_topic(
            # TODO:
            :service => "platform.catalog-inventory.task-output-stream",
            :event   => "Task.update",
            :payload => params_for_update.to_h.merge("id" => params.require(:id)),
            :headers => Insights::API::Common::Request.current_forwardable
          )
        end

        head :no_content
      end

      private

      def params_for_update
        permitted = api_doc_definition.all_attributes - api_doc_definition.read_only_attributes

        if body_params['result'].present?
          permitted.delete('result')
          permitted << {'result'=>{}}
        end

        if body_params['input'].present?
          permitted.delete('input')
          permitted << {'input'=>{}}
        end

        if body_params['output'].present?
          permitted.delete('output')
          permitted << {'output'=>{}}
        end

        permitted << 'source_id'
        body_params.permit(*permitted)
      end
    end
  end
end
