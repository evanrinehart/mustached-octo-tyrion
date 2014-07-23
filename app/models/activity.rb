require 'schedule/weekly'
require 'schedule/prime_days'

class Activity < ActiveRecord::Base

  has_many :instances

  def availabilities_between date_range
    set1 = generate_instances date_range
    set2 = instances.to_a
    (set1 + set2).sort_by{|x| [x.date, x.start_minute]}
  end

  def generate_instances date_range
    return [] if schedule.nil?

    params = JSON.parse schedule
    gen_class = "Schedule::#{params['generator'].camelize.constantize}"
    gen = gen_class.new

    bag = []
    date_range.each do |date|
      bag.push gen.generate(params, date)
    end
    bag.flatten
  end

end
