Spree::Core::Engine.routes.draw do
  match "/bitkassa/callback" => "bitkassa_callback#create",
        :via => :post,
        :as => :bitkassa_callback
end
