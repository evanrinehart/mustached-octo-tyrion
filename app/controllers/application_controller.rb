class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # replace this with appropriate API security like pre-shared key in a cookie
  # or in a custom header
  #protect_from_forgery with: :exception

  class BadRequest < StandardError; end

  rescue_from BadRequest do |e|
    render :text => "400 #{e.message}\n", :status => 400
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render :text => "404 #{e.message}", :status => 404
  end

  def read_int text, name
    raise BadRequest, "bad #{name}" unless text =~ /\A\d+\z/
    text.to_i
  end

  def read_date text, name
    raise BadRequest, "bad #{name}" unless text =~ /\A\d\d\d\d-\d\d-\d\d\z/
    begin
      Date.parse text
    rescue ArgumentError
      raise BadRequest, "bad #{name}"
    end
  end

  def read_instance_descriptor text
    raise BadRequest, 'bad instance' if text.blank?
    bits = text.match /\A(\d\d\d\d-\d\d-\d\d)_(\d\d):(\d\d):00\z/
    raise BadRequest, 'bad instance' unless bits
    hours = bits[2].to_i
    minutes = bits[3].to_i
    date = read_date bits[1], 'date'
    raise BadRequest, 'bad time' unless hours >= 0 && hours <= 23
    raise BadRequest, 'bad time' unless minutes >= 0 && minutes <= 59

    OpenStruct.new(:date => date, :start_minute => hours*60 + minutes)
  end
  
end
