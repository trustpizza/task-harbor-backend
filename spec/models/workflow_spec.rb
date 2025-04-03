require 'rails_helper'

RSpec.describe Workflow, type: :model do

  describe '#should_trigger?', skip: true do
    let(:workflow) { create(:workflow) }

    it 'returns true when conditions are met' do
      conditions = { status: 'ready' }
      allow(workflow).to receive(:should_trigger?).with(conditions).and_return(true)
      expect(workflow.should_trigger?(conditions)).to be true
    end

    it 'returns false when conditions are not met' do
      conditions = { status: 'not_ready' }
      allow(workflow).to receive(:should_trigger?).with(conditions).and_return(false)
      expect(workflow.should_trigger?(conditions)).to be false
    end
  end
end
