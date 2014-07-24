class Instance < ActiveRecord::Base

  belongs_to :activity
  has_many :bookings

  def overlaps? other_instance
    a = self
    b = other_instance

    minutes_in_day = 24*60
    scale = minutes_in_day

    aL, aR = a.coords
    bL, bR = b.coords

    (aR > bL) && (aL < bR)
  end

  def coords
    minutes_in_day = 24*60
    scale = minutes_in_day
    min = self.date.mjd*scale + self.start_minute
    max = min + self.minutes_long
    [min, max]
  end

  def time_of_day
    hours = start_minute / 60
    minutes = start_minute % 60
    "%02d:%02d:00" % [hours, minutes]
  end

  def eql? other_instance
    date == other_instance.date &&
    start_minute == other_instance.start_minute &&
    minutes_long == other_instance.minutes_long
  end

  def descriptor_string
    "#{date}_#{time_of_day}"
  end

end
