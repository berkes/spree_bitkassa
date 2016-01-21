require "spec_helper"

feature "Administer" do
  context "as an admin" do
    stub_authorization!

    context "when adding a payment method" do
      before(:each) do
        visit spree.new_admin_payment_method_path
      end

      scenario "I want to provide the Sisow API-credentials" do
        select "Bitkassa", from: "gtwy-type"
        fill_in "Name", with: "BitKassa"
        click_button "Create"

        expect(page).to have_content "Payment Method has been successfully created!"

        expect(page).to have_field("Merchant ID")
        expect(page).to have_field("Secret API key")
        # We can safely assume that Spree Backend tests for preferences cover
        # the actual saving and setting of these settings
      end
    end
  end
end
