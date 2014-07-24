require 'schedule/weekly'
require 'schedule/prime_days'

class Activity < ActiveRecord::Base

  class BadSchedule < StandardError; end

  has_many :instances

  def enumerate_instances date_range
    set1 = generate_instances date_range
    set2 = instances.where(:date => date_range).to_a
    (set1 | set2).sort_by{|x| [x.date, x.start_minute]}
  end

  def availabilities_between date_range
    enumerate_instances(date_range).select do |inst|
      inst.bookings.count < inst.max_bookings
    end
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
      phantoms = generator.generate(params, self, date)
      phantoms.each do |phantom|
        if instances.where(:date => date, :start_minute => phantom.start_minute).empty?
          bag.push phantom
        end
      end
    end
    bag
  end

  def unbooked_instances
    Instance
      .joins('LEFT JOIN bookings ON instances.id = instance_id')
      .where(:activity_id => self.id)
      .where('bookings.id is NULL')
  end

  def set_schedule params
    strategy = "Schedule::#{params[:strategy].camelize}".constantize
    schedule = strategy.new.validate_params params # shadowing

    self.schedule = JSON.generate(JSON.parse(schedule.to_json)['table'])

    unbooked_instances.delete_all

    # as long as nothing over laps
    self.instances.each do |booked|
      date = booked.date #shadowing
      generate_instances(date..date).each do |generated|
        if generated.overlaps? booked
          raise BadSchedule, 'overlap'
        end
      end
    end

    self.save!
  end

  def find_instance descriptor
    date = descriptor.date
    enumerate_instances(date..date).select do |instance|
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
