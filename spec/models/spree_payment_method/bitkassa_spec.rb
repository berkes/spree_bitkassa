require "spec_helper"

describe Spree::PaymentMethod::Bitkassa do
  describe "#payment_source_class" do
    it { expect(subject.payment_source_class).to eq Spree::Payment::Bitkassa }
  end
end
