class BookingsController < ApplicationController

  def create
    # to arbitrarily cause 404, would make more sense with access controls
    Activity.find params[:activity_id]

    raise BadRequest, 'bad user_id' unless params[:user_id]

    Instance.transaction do # in real life need isolation serializable here
      instance = Instance.includes(:bookings).find params[:instance_id]
      if instance.bookings.count == instance.max_bookings
        raise BadRequest, 'this activity is booked'
      else
        Booking.create!(
          :instance_id => instance.id,
          :user_id => params[:user_id]
        )
      end
    end
    
    head 200
  end

  def destroy
    # mostly useless (without access controls) but will trigger a 404 if bad
    Activity.find params[:activity_id]
    Instance.find params[:instance_id]

    @booking = Booking.find params[:id]
    @booking.delete
    head 200
  end

end
