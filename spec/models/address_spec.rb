require 'rails_helper'

require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:organization) { create(:organization) }
  let(:address) { create(:address, addressable: organization) }

  describe "associations" do
    it { should belong_to(:addressable) }
  end

  describe "validations" do
    it { should validate_presence_of(:address_line_1) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip) }
    it { should validate_presence_of(:country) }
  end

  describe "#full_address" do
    it "returns the full address as a single string" do
      address = build(:address, 
                      address_line_1: "1600 Amphitheatre Parkway", 
                      address_line_2: "Suite 100", 
                      city: "Mountain View", 
                      state: "CA", 
                      zip: "94043", 
                      country: "USA")
      
      expect(address.full_address).to eq("1600 Amphitheatre Parkway, Suite 100, Mountain View, CA, 94043, USA")
    end
  end

  describe "geocoding" do
    it "geocodes an address before saving" do
      address = build(:address, 
      address_line_1: "1600 Amphitheatre Parkway", 
      address_line_2: "Suite 100", 
      city: "Mountain View", 
      state: "CA", 
      zip: "94043", 
      country: "USA")

      address.run_callbacks(:validation) # Trigger geocode manually
      expect(address.latitude).to_not be_nil
      expect(address.longitude).to_not be_nil
    end
  end
end
