module Spree
  class BitkassaReturnsController < ApplicationController
    def show
      flash.notice = Spree.t(:order_processed_successfully)
      # We intentionally don't load the order from the database.
      # Loading requires us to do expensive authorization checks, to see if a
      # user may actually see the order. If we don't, we leak information about
      # order numbers being available. Hence we leave it to the OrdersController
      # completely and only make a dumb redirect here.
      redirect_to order_path(id: params[:id])
    end
  end
end
