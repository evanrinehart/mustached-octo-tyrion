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
      x = activity.unbooked_instances
      x.delete_all
    end
    render :json => {:success => "activity #{aid} schedule cleared"}
  end

  def recurring
    aid = params[:activity_id]
    if !['weekly','prime'].include? params[:strategy]
      raise BadRequest, "bad strategy #{params[:strategy]}"
    end

    begin
      Activity.transaction do
        activity = Activity.find aid
        activity.set_schedule params
      end
    rescue Activity::BadSchedule => e
      raise BadRequest, e.message
    end

    head 200
  end

end
