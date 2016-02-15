module Spree
  CheckoutController.class_eval do
    ## Monkeypatch Spree::CheckoutController#update
    def update_with_bitkassa
      if pay_with_bitkassa?
        if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
          response = payment_method.initiate(@order)
          raise BitkassaRequestException, response.error unless response.success
          ## This sucks. Find a better way to read a payment
          payment = @order.payments.to_a.find_all do |payment|
            payment.payment_method_id == payment_method_id.to_i &&
              payment.amount == payment_amount
          end.first
          raise ActiveRecord::RecordNotFound if payment.nil?

          Spree::BitkassaTransaction.create(
            spree_payment_id: payment.id,
            payment_id: response.payment_id,
            address: response.address,
            amount: response.amount,
            expire: response.expire
          )

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

    def payment_amount
      return @payment_amount if @payment_amount
      payment_attrs = params.fetch(:order, {}).fetch(:payments_attributes, [])
      @payment_amount = payment_attrs.first[:amount] if payment_attrs.any?
    end

    ## General exception to handle bitkassa errors in the app.
    # For now, we do nothing, but we might want to force the payment and order
    # status into a certain state if this occurs
    class BitkassaRequestException < Exception; end
  end
end
