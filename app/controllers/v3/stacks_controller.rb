require 'presenters/v3/stack_presenter'
require 'actions/stack_create'
require 'messages/stack_create_message'

class StacksController < ApplicationController
  def create
    unauthorized! unless permission_queryer.can_write_globally?

    message = StackCreateMessage.new(hashed_params[:body])
    stack = StackCreate.new.create(message)
    render status: :created, json: Presenters::V3::StackPresenter.new(stack)
  end
end
