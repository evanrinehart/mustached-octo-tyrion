require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  setup do
    @activity = FactoryGirl.create :activity
    @start_date = Date.new(2014, 4, 1)
    @end_date = Date.new(2014, 4, 5)
    (@start_date..@end_date+5).each do |date|
      next if date.mjd.even?

      FactoryGirl.create(
        :instance,
        :activity_id => @activity.id,
        :date => date,
        :start_minute => 15*60
      )

      FactoryGirl.create(
        :instance,
        :activity_id => @activity.id,
        :date => date,
        :start_minute => 18*60
      )
    end
  end

  test "availability between two dates" do

    get :available_days,
      :activity_id => @activity.id,
      :start_date => @start_date.to_s,
      :end_date => @end_date.to_s

    assert_response 200

    results = JSON.parse response.body

    assert results.count > 0 # probably
    assert results.none?{|x| Date.parse(x) > @end_date }, "it didn't filter correctly"

    assert results.count == results.uniq.count
  end

  test "bad calls" do
    get :available_days, :activity_id => @activity.id
    assert_response 400
    get :available_days,
      :activity_id => @activity.id,
      :start_date => "1999-47-92",
      :end_date => "2014-09-12"
    assert_response 400
    get :available_days,
      :activity_id => @activity.id,
      :start_date => "",
      :end_date => "2014-09-12"
    assert_response 400

    get :available_times, :activity_id => @activity.id
    assert_response 400
    get :available_times, :activity_id => @activity.id, :date => ""
    assert_response 400
  end

  test "available times on a particular day" do

    available_day = @activity.instances.first.date

    get :available_times,
      :activity_id => @activity.id,
      :date => available_day.to_s

    assert_response 200

    results = JSON.parse response.body

    assert results.count == results.uniq.count

  end

  test "clear the schedule" do
    post :clear, :activity_id => @activity.id
    assert_response 200
    @activity.reload
    assert @activity.schedule.nil?
    assert @activity.unbooked_instances.count == 0
  end

  test "install or reinstall a recurring schedule" do
    post :recurring,
      :activity_id => @activity.id,
      :strategy => 'weekly',
      :days => [1,4],
      :times => [9],
      :price => 40,
      :minutes_long => 90,
      :max_bookings => 3

    assert_response 200

    @activity.reload

    monday = Date.new(2014, 7, 7)
    availables = @activity.availabilities_on(monday)

    assert availables.count == 1, "there should only be one thing on monday"
    assert availables.first.start_minute == 9*60
    assert availables.first.max_bookings == 3
  end

  test "bad schedule" do
    post :recurring,
      :activity_id => @activity.id,
      :strategy => 'weekly',
      :days => [1,4],
      :times => [9],
      :price => "",
      :minutes_long => 90,
      :max_bookings => 3

    assert_response 400
  end

end
