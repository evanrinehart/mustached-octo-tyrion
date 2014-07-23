class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :name
      t.string :vendor
      t.string :schedule
    end

    create_table :instances do |t|
      t.integer :activity_id
      t.date :date
      t.integer :start_minute
      t.integer :minutes_long
      t.integer :max_bookings
      t.integer :price
    end

    create_table :bookings do |t|
      t.integer :instance_id
      t.integer :user_id
    end
  end
end
