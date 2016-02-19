require "spec_helper"

describe Spree::BitkassaCallbackController do
  let(:transaction) { double(:transaction) }
  let(:order) { double(:order, next!: nil) }

  before do
    allow(Spree::BitkassaTransaction).to receive(:find_by!).
      and_return(transaction)
    allow(transaction).to receive(:order).and_return(order)
  end

  describe "#create" do
    describe "with success as status" do
      let(:payment_status) { "success" }
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
  end

  private

  def create_params
    json_payload = {
      payment_id: "dhqe4cnj7f",
      payment_status: payment_status,
      meta_info: "A947183352"
    }.to_json

    now = Time.zone.now.to_i
    authentication = Bitkassa::Authentication.sign(json_payload, now)
    payload        = Base64.urlsafe_encode64(json_payload)

    { p: payload, a: authentication }
  end
end
