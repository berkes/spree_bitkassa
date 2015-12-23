module Spree
  CheckoutController.class_eval do
    around_action :pay_with_bitkassa

    private

    def pay_with_bitkassa
      if pay_with_bitkassa?
        ## @INK: attempt to extract the payment from the just-now updated
        # @order. We've added a payment, but should determine
        # which is the payment we're dealing with here, from all the possible
        # payments in @order.payments. See Order.update_from_params()
        redirect_to "https://www.bitkassa.nl/tx/qwerty"
        #redirect_to payment.payment_url
      else
        yield
      end
    end

    def pay_with_bitkassa?
      return false unless params[:state] == "payment"
      return false unless payment_method.is_a? Spree::PaymentMethod::Bitkassa
      return true
    end

    def payment_method
      Spree::PaymentMethod.find(payment_method_id) unless payment_method_id.nil?
    end

    def payment_method_id
      return @payment_method_id if @payment_method_id
      payment_attrs = params.fetch(:order, {}).fetch(:payments_attributes, [])
      @payment_method_id = payment_attrs.first[:payment_method_id] if payment_attrs.any?
    end
  end
end

