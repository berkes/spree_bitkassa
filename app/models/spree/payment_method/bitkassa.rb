module Spree
  class PaymentMethod::Bitkassa < PaymentMethod
    preference :bitkassa_merchant_id, :string
    preference :bitkassa_secret_api_key, :string

    ##
    # Define Spree::Payment::Bitkassa as the source.
    # This class will handle persistence of the extra payment details
    # such as the Bitkassa id, status and so on.
    def payment_source_class
      Spree::Payment::Bitkassa
    end

    def payment_url(order, opts = {})
    end
  end
end
