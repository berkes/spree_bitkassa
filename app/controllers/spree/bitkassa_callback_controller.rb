module Spree
  class BitkassaCallbackController < ApplicationController
    def create
      transaction = BitkassaTransaction.find_by!(bitkassa_payment_id: bitkassa_payment_id)
      transaction.order.next!
      render text: "OK"
    end

    private

    def bitkassa_payment_id
      transaction_params[:payment_id]
    end

    def transaction_params
      JSON.parse(Base64.urlsafe_decode64(params[:p])).with_indifferent_access
    end
  end
end
