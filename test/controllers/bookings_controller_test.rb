require 'test_helper'

class BookingsControllerTest < ActionController::TestCase

  setup do
    @activity = FactoryGirl.create :activity
    @instance = FactoryGirl.create(
      :instance,
      :activity_id => @activity.id,
      :max_bookings => 2
    )
  end

  test "create booking" do

    before = @instance.bookings.count

    post :create,
      :activity_id => @activity.id,
      :instance_id => @instance.descriptor_string,
      :user_id => 'u348957'

    assert_response 200

    @instance.reload

    after = @instance.bookings.count

    assert after == before + 1
  end

  test "create too many bookings" do
    [200,200,400,400,400].each do |code|
      post :create,
        :activity_id => @activity.id,
        :instance_id => @instance.descriptor_string,
        :user_id => 'u348957'
      assert_response code
    end
  end

  test "cancel booking" do
    booking = FactoryGirl.create :booking, :instance_id => @instance.id
    delete :destroy,
      :activity_id => @activity.id,
      :instance_id => @instance.descriptor_string,
      :id => booking.id

    assert_response 200

    assert !Booking.exists?(booking.id)
  end

end
