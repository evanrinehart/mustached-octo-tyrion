FactoryGirl.define do

  factory :instance do
    date '2014-06-04'
    start_minute 5*60
    minutes_long 60
    max_bookings 2
    price 100
  end

end
