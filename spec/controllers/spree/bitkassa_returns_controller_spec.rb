require "spec_helper"

describe Spree::BitkassaReturnsController do
  it "redirects with a flash message to order path" do
    get :show, id: "R1234"
    expect(response).to redirect_to "/orders/R1234"
    expect(flash.notice).to eq("Your order has been processed successfully")
  end
end
