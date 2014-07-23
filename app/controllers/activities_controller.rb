class ActivitiesController < ApplicationController

  def available_days
    activity = Activity.find params[:activity_id]
    start_date = read_date params[:start_date], 'start_date'
    end_date = read_date params[:end_date], 'end_date'

    results = activity
      .availabilities_between(start_date..end_date)
      .map{|x| x.date}
      .uniq
      .sort
    
    render :json => results
  end

  def available_times
    activity = Activity.find params[:activity_id]
    date = read_date params[:date], 'date'

    results = activity
      .availabilities_between(date..date)
      .map{|x| x.time_of_day}
      .sort

    render :json => results
  end

  def clear
    aid = params[:activity_id]
    Activity.transaction do
      activity = Activity.find aid
      activity.update! :schedule => nil
#      activity.instances...delete_all
      # clear all instances which have no bookings
    end
    render :json => {:success => "activity #{aid} schedule cleared"}
  end

  def recurring
    aid = params[:activity_id]
    # clear all instances which have no bookings
    # set the schedule
  end

end
