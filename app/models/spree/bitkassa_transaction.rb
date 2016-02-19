module Spree
  ##
  # The bitkassa transaction representing a payment-request at Bitkassa
  class BitkassaTransaction < ActiveRecord::Base
    belongs_to :payment, class_name: "Spree::Payment"

    delegate :order, to: :payment, allow_nil: true
  end
end
