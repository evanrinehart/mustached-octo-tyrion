require 'test_helper'

class InstancesControllerTest < ActionController::TestCase

  setup do
    @activity = FactoryGirl.create :activity
    @date = Date.new(2013, 4, 1)
    @hour = 15
    @minute = 45
    @instance = FactoryGirl.create(
      :instance,
      :activity_id => @activity.id,
      :date => @date,
      :start_minute => @hour*60+@minute
    )
  end

  test 'delete instance' do
    delete :destroy,
      :activity_id => @activity.id,
      :id => "#{@date}_#{'%02d:%02d:00' % [@hour,@minute]}"

    assert_response 200

    refute Instance.exists?(@instance.id)
    assert @activity.schedule # should not be affected
  end

  test 'delete recurring instance' do
    monday = Date.new(2014, 7, 7)
    delete :destroy,
      :activity_id => @activity.id,
      :id => "#{monday}_10:00:00"

    assert_response 200

    @activity.reload
    assert Instance.exists?(@instance.id) # should not be affected
    assert @activity.schedule.nil?
  end

  test 'create an instance' do
    monday = Date.new(2014, 7, 7)
    params = {
      :activity_id => @activity.id,
      :date => monday,
      :start_minute => 15*60+30,
      :minutes_long => 90,
      :price => 20,
      :max_bookings => 3
    }

    assert !Instance.exists?(params)
    post :create, 
      :activity_id => @activity.id,
      :date => monday,
      :time => '15:30:00',
      :minutes_long => 90,
      :price => 20,
      :max_bookings => 3

    assert_response 200

    assert Instance.exists?(params)
  end

  test 'create an overlapping instance' do
    monday = Date.new(2014, 7, 7)
    post :create,
      :activity_id => @activity.id,
      :date => monday,
      :time => '09:30:00',
      :minutes_long => 90,
      :price => 20,
      :max_bookings => 3

    assert_response 400
  end

end
