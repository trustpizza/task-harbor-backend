require 'rails_helper'

RSpec.describe TaskWorkflow, type: :model do
  describe 'associations' do
    it { should belong_to(:task) }
    it { should belong_to(:workflow) }
  end
end
