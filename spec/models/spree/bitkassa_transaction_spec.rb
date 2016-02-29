require "spec_helper"

describe Spree::BitkassaTransaction do
  it "has a payment" do
    subject.build_payment
    expect(subject.payment).to be_a Spree::Payment
  end

  describe "#order" do
    it "is nil when there is no payment" do
      subject.payment = nil
      expect(subject.order).to be_nil
    end

    it "is the order from the payment" do
      order = double(:order)
      allow(subject).to receive(:payment).
        and_return(double(:payment, order: order))
      expect(subject.order).to be order
    end
  end
end
