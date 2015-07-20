module ActionController
  class LogSubscriber < ActiveSupport::LogSubscriber
    def process_action(event)
      info do
        payload   = event.payload
        additions = ActionController::Base.log_process_action(payload)

        status = payload[:status]
        if status.nil? && payload[:exception].present?
          exception_class_name = payload[:exception].first
          status = ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
        end
        message = "Completed #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} in #{event.duration.round}ms"
        message << " (#{additions.join(" | ".freeze)})" unless additions.blank?

        message = message.colorize(:color => :white, :background => :yellow) if status.to_i >= 300 && status.to_i < 500
        message = message.colorize(:color => :white, :background => :red) if status.to_i >= 500 && status.to_i < 600
        message = message.colorize(:color => :white, :background => :green) if status.to_i >= 200 && status.to_i < 300

        message
      end
    end
  end
end

ActionController::LogSubscriber.attach_to :action_controller