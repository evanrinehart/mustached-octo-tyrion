class InstancesController < ApplicationController

  def create
    # create a new single instance (if possible) of an activity

    Activity.transaction do # in real life you need :isolation => :serializable for this
      activity = Activity.find params[:activity_id]

      date = read_date params[:date], 'date'
      raise BadRequest, 'bad time' unless params[:time].is_a?(String)
      time = params[:time].match /\A(\d\d):(\d\d):00\z/
      raise BadRequest, 'bad time' if time.nil?
      hour = time[1].to_i
      minute = time[2].to_i

      price = read_int params[:price], 'price'
      max_bookings = read_int params[:max_bookings], 'max_bookings'
      minutes_long = read_int params[:minutes_long], 'minutes_long'

      instance = Instance.new(
        :activity_id => activity.id,
        :date => date,
        :start_minute => hour*60+minute,
        :price => price,
        :max_bookings => max_bookings,
        :minutes_long => minutes_long
      )

      if activity.has_overlapping_instance? instance
        raise BadRequest, 'overlapping instance'
      end

      instance.save!
    end

    head 200
  end

  def destroy
    # remove an instance of an activity
    # if the instance is recurring, disable the entire schedule

    descriptor = read_instance_descriptor params[:id]

    activity = Activity.find params[:activity_id]
    instance = activity.find_instance descriptor
    if instance
      if instance.bookings.count > 0
        raise BadRequest, "don't try to cancel a booked activity instance"
      else
        if instance.id.nil? # it's an unbooked recurring availability
          activity.update! :schedule => nil
        else
          instance.delete
        end 
      end
    else
      raise NotFound
    end

    head 200
  end

end
