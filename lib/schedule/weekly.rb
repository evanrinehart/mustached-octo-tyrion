module Schedule

  class Weekly

    def validate_params params
      int = /\A\d+\z/
      days = params[:days] || [] # due to deep munge
      raise Activity::BadSchedule unless days.is_a?(Array)

      times = params[:times] || [] # due to deep munge
      raise Activity::BadSchedule unless days.is_a?(Array)

      validate_int = lambda do |x|
        if x.is_a?(Integer)
          x
        elsif x =~ int
          x.to_i
        else
          raise Activity::BadSchedule
        end
      end

      validate_list_of_ints = lambda do |list, min, max|
        list.map! do |x|
          validate_int[x]
        end

        if !list.all?{|x| x >= min && x <= max}
          raise Activity::BadSchedule
        end
      end

      validate_list_of_ints[days, 0, 6]
      validate_list_of_ints[times, 0, 23]
      minutes_long = validate_int[params[:minutes_long]]
      max_bookings = validate_int[params[:max_bookings]]
      price = validate_int[params[:price]]

      OpenStruct.new(
        :strategy => 'weekly',
        :days => days,
        :times => times,
        :minutes_long => minutes_long,
        :price => price,
        :max_bookings => max_bookings
      )
    end

    def generate params, activity, date
      if params.days.include?(date.wday)
        params.times.map do |hour|
          Instance.new(
            :activity_id => activity.id,
            :date => date,
            :start_minute => hour*60,
            :minutes_long => params.minutes_long,
            :price => params.price,
            :max_bookings => params.max_bookings
          )
        end
      else
        []
      end
    end

  end
end
