class AddAttachmentFileToOrders < ActiveRecord::Migration
  def self.up
    change_table :orders do |t|
      t.attachment :file
    end
  end

  def self.down
    drop_attached_file :orders, :file
  end
end
