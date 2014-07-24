class ActivityTest < ActiveSupport::TestCase
  
  test 'something' do
    activity = FactoryGirl.create :activity, :schedule => nil
    instance1 = FactoryGirl.create :instance, :activity_id => activity.id
    instance2 = FactoryGirl.create :instance, :activity_id => activity.id
    FactoryGirl.create :booking, :instance_id => instance1.id

    assert instance1.bookings.count == 1

    assert activity.unbooked_instances.count == 1
    assert( activity.unbooked_instances.all? do |inst|
      inst.bookings.count == 0
    end)
  end

end
