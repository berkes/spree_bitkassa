require "spec_helper"

describe Spree::BitkassaCallbackController do
  let(:transaction) { double(:transaction, void: false, pay: false) }

  before do
    allow(Spree::BitkassaTransaction).to receive(:find_by!).
      and_return(transaction)
  end

  describe "#create" do
    let(:payment_status) { "anything" }

    it "finds the Payment to be processed" do
      expect(Spree::BitkassaTransaction).to receive(:find_by!).
        with(bitkassa_payment_id: "dhqe4cnj7f").
        and_return(transaction)
      post :create, create_params
    end

    describe "with payed as status" do
      let(:payment_status) { "payed" }

      it "pays the transaction" do
        expect(transaction).to receive(:pay)
        post :create, create_params
      end
    end

    describe "with cancelled as status" do
      let(:payment_status) { "cancelled" }

      it "voids the transaction" do
        expect(transaction).to receive(:void)
        post :create, create_params
      end
    end

    describe "with expired as status" do
      let(:payment_status) { "expired" }

      it "voids the payment" do
        expect(transaction).to receive(:void)
        post :create, create_params
      end
    end

    describe "with invalid signed request" do
      it "returns a 400" do
        # API signs with a different api_key
        Bitkassa.config.secret_api_key = "GUESSED"
        params = create_params
        Bitkassa.config.secret_api_key = "SECRET"

        post :create, params
        expect(response.status).to be 403
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
