class PagesController < ApplicationController
  def home
  end

  def create_order
    @order = Order.new
  end
  
  def about
  end

  def contact
  end
end
