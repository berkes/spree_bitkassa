require "spec_helper"

describe Spree::BitkassaCallbackController do
  let(:transaction) { double(:transaction, payment: payment, order: order) }
  let(:payment) { double(:payment) }
  let(:order) { double(:order, next!: nil) }

  before do
    allow(Spree::BitkassaTransaction).to receive(:find_by!).
      and_return(transaction)
  end

  describe "#create" do
    describe "with payed as status" do
      let(:payment_status) { "payed" }

      it "finds the Payment to be processed" do
        expect(Spree::BitkassaTransaction).to receive(:find_by!).
          with(bitkassa_payment_id: "dhqe4cnj7f").
          and_return(transaction)
        post :create, create_params
      end

      it "completes the order for this transaction" do
        expect(order).to receive(:next!)
        post :create, create_params
      end
    end

    describe "with cancelled as status" do
      let(:payment_status) { "cancelled" }

      it "voids the payment" do
        expect(payment).to receive(:void!)
        post :create, create_params
      end
    end

    describe "with expired as status" do
      let(:payment_status) { "expired" }

      it "voids the payment" do
        expect(payment).to receive(:void!)
        post :create, create_params
      end
    end
  end

  private

  def create_params
    json_payload = {
      payment_id: "dhqe4cnj7f",
      meta_info: "A947183352",
      payment_status: payment_status,
    }.to_json

    now = Time.zone.now.to_i
    authentication = Bitkassa::Authentication.sign(json_payload, now)
    payload        = Base64.urlsafe_encode64(json_payload)

    { p: payload, a: authentication }
  end
end
