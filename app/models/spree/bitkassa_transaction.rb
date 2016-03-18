module Spree
  ##
  # The bitkassa transaction representing a payment-request at Bitkassa
  class BitkassaTransaction < ActiveRecord::Base
    belongs_to :payment, class_name: "Spree::Payment"

    delegate :order, to: :payment, allow_nil: true

    def pay
      order.next!
      payment.complete!
    end

    def void
      payment.void!
    end
  end
end
