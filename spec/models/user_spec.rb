require 'rails_helper'

RSpec.describe User, type: :model do
  let(:org) { create(:organization) }
  let(:user) { create(:user, organization: org, first_name: "John", last_name: "Doe", email: "test@example.com") }

  describe 'associations' do
    it { should belong_to(:organization) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should belong_to(:organization) } 
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:first_name).is_at_most(255) } # Example length constraint
    it { should validate_length_of(:last_name).is_at_most(255) } # Example length constraint
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
  end

  describe 'attributes' do
    it 'has a first_name' do
      expect(user.first_name).to eq('John')
    end

    it 'has a last_name' do
      expect(user.last_name).to eq('Doe')
    end

    it 'has an email' do
      expect(user.email).to eq('test@example.com')
    end

    it 'belongs to an organization' do
      expect(user.organization).to eq(org)
    end
  end

  describe 'full_name' do
    it 'returns the full name' do
      expect(user.full_name).to eq('John Doe')
    end
  end
end
