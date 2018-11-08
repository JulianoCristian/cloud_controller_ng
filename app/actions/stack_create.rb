module VCAP::CloudController
  class StackCreate
    def create(message)
      stack = nil
      Stack.db.transaction do
        stack = VCAP::CloudController::Stack.create(
          name: message.name,
          description: message.description
        )
      end

      stack
    end
  end
end
