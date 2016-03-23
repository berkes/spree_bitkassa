module Spree
  class BitkassaReturnsController < ApplicationController
    def show
      load_order
      redirect_to_order
    end

    private

    def load_order
      @order ||= Spree::Order.find_by_number!(params[:id])
    end

    def redirect_to_order
      redirect_to(order_path(id: @order.number), notice: message)
    end

    def message
      if @order.complete?
        Spree.t(:order_processed_successfully)
      else
        Spree.t(:order_processed_pending)
      end
    end
  end
end
