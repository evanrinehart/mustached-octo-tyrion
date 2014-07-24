require 'prime'

module Schedule
  class PrimeDays

    def validate_params params
      OpenStruct.new(:strategy => 'prime_days')
    end

    def generate params, activity, date
      if date.day.prime?
        [Instance.new(
          :date => date,
          :start_minute => 19*60,
          :price => 17,
          :max_bookings => 2,
          :minutes_long => 31
        )]
      else
        []
      end
    end

  end
end
