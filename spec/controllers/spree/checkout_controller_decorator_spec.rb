require "spec_helper"

describe Spree::CheckoutController do
  let(:user) { Spree::User.new }
  let(:order) { OrderWalkthrough.up_to(:payment) }
  let(:payment_method) { Spree::PaymentMethod::BitkassaMethod.new }
  let(:payment) { Spree::Payment.new }
  let(:payment_response) { Bitkassa::PaymentResponse.new(success: true) }

  let(:params) do
    {
      state: "payment",
      order: { payments_attributes: [payment_method_id: 42] }
    }
  end

  before do
    allow(subject).to receive(:current_spree_user).and_return(user)
    allow(subject).to receive(:current_order).and_return(order)
    allow(Spree::PaymentMethod).to receive(:find).
      and_return(Spree::PaymentMethod::Check.new)
    allow(Spree::PaymentMethod).to receive(:find).
      with("42").
      and_return(payment_method)

    allow(order).to receive(:valid?).and_return(true)
    allow(order).to receive(:deliver_order_confirmation_email).and_return(true)

    allow(payment_method).to receive(:initiate).
      and_return(payment_response)
    allow(payment_method).to receive(:payment_url).
      and_return("https://example.com/tx/qwerty")
  end

  describe "#pay_with_bitkassa" do
    describe "state is not payment" do
      it "calls original" do
        expect(subject).to receive(:update).and_call_original

        params = {
          state: "address",
          order: { payments_attributes: [payment_method_id: 42] }
        }
        put :update, params
      end
    end

    describe "payment method is not a Spree::PaymentMethod::Bitkassa" do
      it "calls original" do
        expect(subject).to receive(:update).and_call_original

        params = {
          state: "payment",
          order: { payments_attributes: [payment_method_id: 12] }
        }
        put :update, params
      end
    end

    it "finds payment method" do
      expect(Spree::PaymentMethod).to receive(:find).with("42")
      put :update, params
    end

    it "initatiates payment" do
      expect(payment_method).to receive(:initiate).with(order)
      put :update, params
    end

    it "raises RecordNotFound if payment was not found in order" do
      allow(order).to receive(:payments).and_return(Spree::Payment.none)
      expect do
        put :update, params
      end.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "adds transaction details to the payment" do
      allow(payment_response).to receive(:payment_id).and_return("qwerty")
      allow(payment_response).to receive(:address).and_return("1EJiC4omTWvLmRQbU9jm4LYsQvUV4M9uYK")
      allow(payment_response).to receive(:amount).and_return(1337)
      allow(payment_response).to receive(:expire).and_return(1455260000)
      expect(Spree::BitkassaTransaction).to receive(:create).
        with(spree_payment_id: 1,
             bitkassa_payment_id: "qwerty",
             address: "1EJiC4omTWvLmRQbU9jm4LYsQvUV4M9uYK",
             amount: 1337,
             expire: 1455260000).
        and_return(double(:transaction, save: true))
      put :update, params
    end

    context "with a success response" do
      it "redirects to payment_url from payment_method" do
        put :update, params
        expect(response).to redirect_to("https://example.com/tx/qwerty")
      end
    end

    context "with an failed response" do
      before do
        allow(payment_response).to receive(:success).and_return(false)
        allow(payment_response).to receive(:error).and_return("wut?")
      end

      it "generates an exception" do
        expect do
          put :update, params
        end.to raise_exception("wut?")
      end
    end
  end
end
