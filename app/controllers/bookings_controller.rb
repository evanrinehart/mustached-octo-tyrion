class BookingsController < ApplicationController

  def create
    activity = Activity.find params[:activity_id]

    raise BadRequest, 'bad user_id' unless params[:user_id]

    descriptor = read_instance_descriptor params[:instance_id]

    Instance.transaction do # in real life need isolation serializable here
      instance = activity.find_instance descriptor
      raise ActiveRecord::RecordNotFound if instance.nil?

      if instance.bookings.count == instance.max_bookings
        raise BadRequest, 'this activity is booked'
      else

        instance.save! if instance.id.nil? # recurring instance becomes real

        Booking.create!(
          :instance_id => instance.id,
          :user_id => params[:user_id]
        )

      end
    end
    
    head 200
  end

  def destroy
    @booking = Booking.find params[:id]
    @booking.delete
    head 200
  end

end
