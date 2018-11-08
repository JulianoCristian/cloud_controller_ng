module VCAP::CloudController::Presenters::V3
  RSpec.describe StackPresenter do
    let(:stack) { VCAP::CloudController::Stack.make }

    describe '#to_hash' do
      let(:result) { StackPresenter.new(stack).to_hash }

      it 'presents the stack as json' do
        expect(result[:guid]).to eq(stack.guid)
        expect(result[:created_at]).to eq(stack.created_at)
        expect(result[:updated_at]).to eq(stack.updated_at)
        expect(result[:name]).to eq(stack.name)
        expect(result[:links][:self][:href]).to match(%r{/v3/stacks/#{stack.guid}$})
        expect(result[:links][:self][:href]).to eq("#{link_prefix}/v3/stacks/#{stack.guid}")
        expect(result[:links][:organization][:href]).to eq("#{link_prefix}/v3/organizations/#{stack.organization_guid}")
        expect(result[:relationships][:organization][:data][:guid]).to eq(stack.organization_guid)
        expect(result[:metadata][:labels]).to eq('release' => 'stable', 'maine.gov/potato' => 'mashed')
      end
    end

  end
end
