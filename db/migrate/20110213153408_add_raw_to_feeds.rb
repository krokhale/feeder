class AddRawToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :raw, :binary
  end

  def self.down
    remove_column :feeds, :raw
  end
end
