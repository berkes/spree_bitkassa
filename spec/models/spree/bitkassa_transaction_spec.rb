require "spec_helper"

describe Spree::BitkassaTransaction do
  it "has a payment" do
    subject.build_payment
    expect(subject.payment).to be_a Spree::Payment
  end
end
