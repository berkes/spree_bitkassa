module Spree
  class PaymentMethod::BitkassaMethod < PaymentMethod
    preference :bitkassa_merchant_id, :string
    preference :bitkassa_secret_api_key, :string

    def initialize(attributes = {})
      configure
      super
    end

    ##
    # Initiates a payment with the API.
    def initiate(order)
      attributes = {
        currency: "EUR",
        amount: order.payment_total.to_i,
        description: "#{Spree::Store.current.name} - Order: #{order.number}",
        return_url: "http://example.com/return",
        update_url: "http://example.com/update",
        meta_info: order.number
      }

      bitkassa = Bitkassa::PaymentRequest.new(attributes) #=> PaymentRequest
      @response = bitkassa.perform
    end

    ##
    # Generates a redirect_url for Bitkassa
    def payment_url
      unless @response
        fail PaymentNotInitiated,
          "This payment was not initiated, or initalizing gave no response"
      end

      @response.payment_url
    end

    private

    def configure
      Bitkassa.config.secret_api_key = Spree::Config.preferred_bitkassa_secret_api_key
      Bitkassa.config.merchant_id = Spree::Config.preferred_bitkassa_merchant_id
    end

    class PaymentNotInitiated < StandardError
    end
  end
end
