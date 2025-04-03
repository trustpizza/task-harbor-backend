require 'rails_helper'

RSpec.describe Workflow, type: :model do
  describe 'associations' do
    it { should belong_to(:project) }
    it { should have_many(:task_workflows).dependent(:destroy) }
    it { should have_many(:tasks).through(:task_workflows) }
  end

  describe '#should_trigger?' do
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
