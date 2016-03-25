require "spec_helper"

feature "checkout" do
  let(:user) { create(:user) }
  let(:order) do
    order = OrderWalkthrough.up_to(:delivery)
    order.available_payment_methods << bitkassa
    order.save!
    order.reload
  end
  let(:bitkassa_request_url) { "https://www.bitkassa.nl/api/v1" }
  let(:bitkassa) { @bitkassa }
  let(:payment_request_response) { stored_response("payment_request_response") }

  before do
    record_api_requests
    @bitkassa = Spree::PaymentMethod::BitkassaMethod.create!(name: "Bitcoin")
    stub_user_with_order(user, order)

    stub_request(:post, bitkassa_request_url).
      with(body: /^p=[^&]+&a=.+$/).
      to_return(payment_request_response)

    visit spree.checkout_state_path(:payment)
    click_button "Save and Continue"

    # Disable redirects, or else we'll be redirected to the actual sisow page
    # which cannot be handled by RackTest but is not a good idea either.
    # We just want to know that we got the right response.
    Capybara.page.driver.options[:follow_redirects] = false

    choose "Bitcoin"
    click_button "Save and Continue"
    Capybara.page.driver.options[:follow_redirects] = true
  end

  scenario "I return on the site after the callback posted a success" do
    callback_posts(:payed)

    visit api_payload["return_url"]

    expect(page).to have_content "Your order has been processed successfully"
    expect(page).to have_content "Payment Information Bitcoin"

    expect(order.reload.state).to eq "complete"
  end

  ##
  # As a user with an order
  # When I walk through the Bitkassa Payment
  # And I return on the shop via the return url
  # But the Bitkassa API has not yet posted its result
  # Then I see an unfinished order
  # So that I know my order is still pending
  scenario "I return on the site when the callback has not yet posted" do
    visit "/bitkassa/returns/#{order.number}"
    expect(page).to have_content "Your order has been processed and the payment
      is pending. You will receive a confirmation once the payment is processed
      successfully"
    ## We can still change the payment information, hence the edit link shows.
    expect(page).to have_content "Payment Information (Edit) Bitcoin"

    expect(order.reload.state).to eq "payment"
  end

  private

  def callback_posts(status)
    json_payload = {
      payment_id: "2nwxqex8lu",
      payment_status: status.to_s,
      meta_info: "A947183352"
    }.to_json

    now = Time.zone.now.to_i
    authentication = Bitkassa::Authentication.sign(json_payload, now)
    payload        = Base64.urlsafe_encode64(json_payload)

    page.driver.post("bitkassa/callback", "p=#{payload}&a=#{authentication}")
  end
end
