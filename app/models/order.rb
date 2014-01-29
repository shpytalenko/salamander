class Order < ActiveRecord::Base
  attr_accessible :name, :email, :description, :status, :notes, :file_attributes, :file
  has_attached_file :file
end
