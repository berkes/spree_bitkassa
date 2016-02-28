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
  end

  scenario "I select 'Bitcoin' it creates a transaction at Bitkassa and redirects me there" do
    choose "Bitcoin"
    click_button "Save and Continue"

    expect(WebMock).to have_requested(:post, bitkassa_request_url).
      with(body: /^p=[^&]+&a=.+$/)

    response = page.driver.response
    expect(response.status).to be 302
    expect(response.headers["Location"]).to match(%r(https://www\.bitkassa\.nl/tx/.*))
  end

  scenario "Paying with Bitkassa does not finalize the order: no mail sent" do
    expect do
      choose "Bitcoin"
      click_button "Save and Continue"
    end.not_to change(ActionMailer::Base.deliveries, :length)
  end
end
