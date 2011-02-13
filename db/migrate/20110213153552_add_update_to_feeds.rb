class AddUpdateToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :updates, :boolean
  end

  def self.down
    remove_column :feeds, :updates
  end
end
