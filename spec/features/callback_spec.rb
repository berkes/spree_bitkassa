require "spec_helper"

feature "checkout" do
  let(:bitkassa_request_url) { "https://www.bitkassa.nl/api/v1" }
  let(:bitkassa) { @bitkassa }
  let(:payment_request_response) { stored_response("payment_request_response") }
  let(:user) { create(:user) }
  let(:order) do
    order = OrderWalkthrough.up_to(:delivery)
    order.available_payment_methods << bitkassa
    order.save!
    order.reload
  end

  before do
    @bitkassa = Spree::PaymentMethod::BitkassaMethod.create!(name: "Bitcoin")
    stub_user_with_order(user, order)

    stub_request(:post, bitkassa_request_url).
      with(body: /^p=[^&]+&a=.+$/).
      to_return(payment_request_response)

    visit spree.checkout_state_path(:payment)
    click_button "Save and Continue"

    Capybara.page.driver.options[:follow_redirects] = false
    @now = Time.zone.now
    choose "Bitcoin"
    click_button "Save and Continue"
    # We now have a pending payment.
  end

  after do
    Capybara.page.driver.options[:follow_redirects] = true
  end

  scenario "API posts a succss callback spree sends order confirmation mail" do
    json_payload = {
      payment_id: "2nwxqex8lu",
      payment_status: "payed",
      meta_info: "A947183352"
    }.to_json

    now = Time.zone.now.to_i
    authentication = Bitkassa::Authentication.sign(json_payload, now)
    payload        = Base64.urlsafe_encode64(json_payload)

    expect do
      page.driver.post("bitkassa/callback", "p=#{payload}&a=#{authentication}")
    end.to change(ActionMailer::Base.deliveries, :length).by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to match /Order Confirmation/
  end

  scenario "API posts a failure callback spree sends no mail" do
    json_payload = {
      payment_id: "2nwxqex8lu",
      payment_status: "cancelled", # Same for "expired"
      meta_info: "A947183352"
    }.to_json

    now = Time.zone.now.to_i
    authentication = Bitkassa::Authentication.sign(json_payload, now)
    payload        = Base64.urlsafe_encode64(json_payload)

    expect do
      page.driver.post("bitkassa/callback", "p=#{payload}&a=#{authentication}")
    end.to change(ActionMailer::Base.deliveries, :length).by(0)
  end
end
