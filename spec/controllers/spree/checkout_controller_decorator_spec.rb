require "spec_helper"

describe Spree::CheckoutController do
  let(:user) { Spree::User.new }
  let(:order) { OrderWalkthrough.up_to(:payment) }
  let(:payment_method) { Spree::PaymentMethod::Bitkassa.new }
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

    it "redirects" do
      put :update, params
      expect(response).to redirect_to("https://www.bitkassa.nl/tx/qwerty")
    end

    it "finds payment method" do
      expect(Spree::PaymentMethod).to receive(:find).with("42")
      put :update, params
    end

  end
end
