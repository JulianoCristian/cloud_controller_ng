require 'messages/base_message'
require 'messages/validators/metadata_validator'

module VCAP::CloudController
  class StackCreateMessage < BaseMessage
    register_allowed_keys [:name, :description]
  end
end
