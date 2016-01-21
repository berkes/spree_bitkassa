module Spree
  CheckoutController.class_eval do
    ## Monkeypatch Spree::CheckoutController#update
    def update_with_bitkassa
      if pay_with_bitkassa?
        if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
          payment_method.initiate(@order)
          redirect_to payment_method.payment_url
        else
          render :edit
        end
      else
        update_without_bitkassa
      end
    end
    alias_method_chain :update, :bitkassa

    private

    def pay_with_bitkassa?
      return false unless params[:state] == "payment"
      return false unless payment_method.is_a? Spree::PaymentMethod::BitkassaMethod
      return true
    end

    def payment_method
      if payment_method_id
        @payment_method ||= Spree::PaymentMethod.find(payment_method_id)
      end
    end

    def payment_method_id
      return @payment_method_id if @payment_method_id
      payment_attrs = params.fetch(:order, {}).fetch(:payments_attributes, [])
      @payment_method_id = payment_attrs.first[:payment_method_id] if payment_attrs.any?
    end
  end
end

