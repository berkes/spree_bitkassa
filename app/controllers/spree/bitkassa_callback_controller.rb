module Spree
  class BitkassaCallbackController < ApplicationController
    def create
      load_transaction
      process_transaction
      render text: "OK"
    end

    private

    def load_transaction
      @bitkassa_transaction ||= BitkassaTransaction.find_by!(
        bitkassa_payment_id: bitkassa_payment_id
      )
    end

    def process_transaction
      @bitkassa_transaction.order.next!
    end

    def bitkassa_payment_id
      transaction_params[:payment_id]
    end

    def transaction_params
      JSON.parse(Base64.urlsafe_decode64(params[:p])).with_indifferent_access
    end
  end
end
