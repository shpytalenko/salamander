class Category < ActiveRecord::Base
  attr_accessible :name, :parent_id
  has_many :products
end
