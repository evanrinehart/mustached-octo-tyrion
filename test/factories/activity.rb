FactoryGirl.define do

  factory :activity do
    name 'surf lesson'
    vendor 'Joe the Surf Instructor'
    schedule { JSON.generate(
      :strategy => :weekly,
      :days => [1,3,5],
      :times => [10, 12],
      :minutes_long => 45,
      :max_bookings => 2,
      :price => 100
    ) }
  end

end
