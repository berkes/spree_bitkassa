Spree::AppConfiguration.class_eval do
  # Bitkassa Configuration
  preference :bitkassa_merchant_id, :string, default: ""
  preference :bitkassa_secret_api_key, :string, default: ""
end
