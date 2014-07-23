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

  def read_date text, name
    raise BadRequest, "bad #{name}" unless text =~ /\A\d\d\d\d-\d\d-\d\d\z/
    begin
      Date.parse text
    rescue ArgumentError
      raise BadRequest, "bad #{name}"
    end
  end
  
end
