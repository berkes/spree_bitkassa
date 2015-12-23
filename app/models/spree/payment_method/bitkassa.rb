module Spree
  class PaymentMethod::Bitkassa < PaymentMethod
    preference :bitkassa_merchant_id, :string
    preference :bitkassa_secret_api_key, :string

    ##
    # Generates a redirect_url for Bitkassa
    def redirect_url(order)
      # @INK: implement calling of Bitkassa API
      # in order to generate a payment url
      "https://www.bitkassa.nl/tx/qwerty"
    end
  end
end
