class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.datetime :date
      t.string :text
      t.string :url
      t.integer :feed_id

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end