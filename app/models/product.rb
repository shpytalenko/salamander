class Product < ActiveRecord::Base
  attr_accessible :name, :description, :price, :category_id, :active, :mainphoto
  has_attached_file :mainphoto, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  belongs_to :category
end
