require "spec_helper"

describe Spree::BitkassaReturnsController do
  let(:order)  { double(:order, number: "R1234", complete?: true) }

  before do
    allow(Spree::Order).to receive(:find_by_number!).and_return(order)
  end

  describe "order is complete" do
    before do
      allow(order).to receive(:complete?).and_return(true)
    end

    it "redirects with a success flash message to order path" do
      get :show, id: "R1234"
      expect(response).to redirect_to "/orders/R1234"
      expect(flash.notice).to eq("Your order has been processed successfully")
    end
  end

  describe "order is not complete" do
    before do
      allow(order).to receive(:complete?).and_return(false)
    end

    it "redirects with a pending success flash message to order path" do
      get :show, id: "R1234"
      expect(response).to redirect_to "/orders/R1234"
      expect(flash.notice).to include("payment is pending")
    end
  end


  it "finds the Order by its number raising not found exception" do
    expect(Spree::Order).to receive(:find_by_number!).
      with("R1234").
      and_return(order)
    get :show, id: "R1234"
  end
end
