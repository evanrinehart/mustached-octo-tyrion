require 'schedule/weekly'
require 'schedule/prime_days'

class Activity < ActiveRecord::Base

  class BadSchedule < StandardError; end

  has_many :instances

  def availabilities_between date_range
    set1 = generate_instances date_range
    set2 = instances.where(:date => date_range).to_a
    (set1 | set2).sort_by{|x| [x.date, x.start_minute]}
  end

  def availabilities_on date
    availabilities_between(date .. date)
  end

  def generate_instances date_range
    return [] if schedule.nil?

    params = OpenStruct.new JSON.parse(schedule)
    strategy = "Schedule::#{params.strategy.camelize}".constantize

    generator = strategy.new 

    bag = []
    date_range.each do |date|
      bag.push generator.generate(params, self, date)
    end
    bag.flatten
  end

  def unbooked_instances
    instances.includes(:bookings)
  end

  def set_schedule params
    strategy = "Schedule::#{params[:strategy].camelize}".constantize
    schedule = strategy.new.validate_params params # shadowing

    self.schedule = JSON.generate(JSON.parse(schedule.to_json)['table'])

    unbooked_instances.delete_all

    # as long as nothing over laps
    self.instances.each do |booked|
      date = instance.date #shadowing
      generate_instances(date..date).each do |generated|
        if generated.overlaps booked
          raise BadSchedule, 'overlap'
        end
      end
    end

    self.save!
  end

  def find_instance descriptor
    availabilities_on(descriptor.date).select do |instance|
      instance.start_minute == descriptor.start_minute
    end.first
  end

  def has_overlapping_instance? new_inst
    start_date = new_inst.date
    end_date = new_inst.date + 1 + new_inst.minutes_long/(60*24)
    availabilities_between(start_date .. end_date).any? do |inst|
      inst.overlaps? new_inst
    end
  end

end
