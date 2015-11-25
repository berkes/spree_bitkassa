module Spree
  class PaymentMethod::Bitkassa < PaymentMethod
    preference :bitkassa_merchant_id, :string
    preference :bitkassa_secret_api_key, :string
  end
end
