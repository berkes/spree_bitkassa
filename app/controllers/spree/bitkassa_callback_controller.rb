module Spree
  class BitkassaCallbackController < ApplicationController
    before_action :authenticate

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
      case payment_status
      when :payed
        complete_order
      when :cancelled, :expired
        void_payment
      end
    end

    def bitkassa_payment_id
      transaction_params[:payment_id]
    end

    def authenticate
      unless Bitkassa::Authentication.valid?(params[:a], json_params)
        head :forbidden
      end
    end

    def json_params
      Base64.urlsafe_decode64(params[:p])
    end

    def transaction_params
      JSON.parse(json_params).with_indifferent_access
    end

    def complete_order
      @bitkassa_transaction.order.next!
    end

    def void_payment
      @bitkassa_transaction.payment.void!
    end

    def payment_status
      transaction_params[:payment_status].to_sym
    end
  end
end
