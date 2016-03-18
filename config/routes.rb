Spree::Core::Engine.routes.draw do
  match "/bitkassa/callback" => "bitkassa_callback#create",
        :via => :post,
        :as => :bitkassa_callback
  match "/bitkassa/returns/:id" => "bitkassa_returns#show",
        :via => :get,
        :as => :bitkassa_returns
end
