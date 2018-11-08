require 'spec_helper'
require 'actions/stack_create'
require 'messages/stack_create_message'

module VCAP::CloudController
  RSpec.describe StackCreate do
    describe 'create' do
      it 'creates a stack' do
        message = VCAP::CloudController::StackCreateMessage.new(
          name: 'the-name',
          description: 'the-description',
        )
        stack = StackCreate.new.create(message)


        expect(stack.name).to eq('the-name')
        expect(stack.description).to eq('the-description')
      end

      context 'when a model validation fails' do
        it 'raises an error' do
          errors = Sequel::Model::Errors.new
          errors.add(:blork, 'is busted')
          expect(VCAP::CloudController::Stack).to receive(:create).
            and_raise(Sequel::ValidationFailed.new(errors))

          message = VCAP::CloudController::StackCreateMessage.new(name: 'foobar')
          expect {
            StackCreate.new.create(message)
          }.to raise_error(StackCreate::Error, 'blork is busted')
        end

        context 'when it is a uniqueness error' do
          let(:name) { 'the-name' }

          before do
            VCAP::CloudController::Stack.create(name: name)
          end

          it 'raises a human-friendly error' do
            message = VCAP::CloudController::StackCreateMessage.new(name: name)
            expect {
              StackCreate.new.create(message)
            }.to raise_error(StackCreate::Error, 'Name must be unique per organization')
          end
        end

        context 'when it is a db uniqueness error' do
          let(:name) { 'the-stack' }
          it 'translates database uniqueness errors into Sequel Validation Errors' do
            Stack.make(name: name)

            allow_any_instance_of(Stack).to receive(:validate).and_return true

            message = VCAP::CloudController::StackCreateMessage.new(name: name)
            expect {
              StackCreate.new.create(message)
            }.to raise_error(StackCreate::Error, 'Name must be unique per stack')
          end
        end
      end
    end
  end
end
