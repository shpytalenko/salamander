class AddAttachmentMainphotoToProducts < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.attachment :mainphoto
    end
  end

  def self.down
    drop_attached_file :products, :mainphoto
  end
end
