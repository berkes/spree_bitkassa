require "spec_helper"

describe Spree::BitkassaTransaction do
  let(:order) { Spree::Order.new }
  let(:payment) { Spree::Payment.new(order: order) }

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
      subject.payment = payment
      expect(subject.order).to be order
    end
  end

  describe "#void" do
    it "voids the payment" do
      subject.payment = payment
      expect(payment).to receive(:void!)
      subject.void
    end
  end

  describe "#pay" do
    it "transitions order with next!" do
      subject.payment = payment
      expect(order).to receive(:next!)
      subject.pay
    end
  end
end
