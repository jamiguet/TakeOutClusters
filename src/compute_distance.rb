require_relative 'position'
require 'json'
require 'date'
require 'descriptive_statistics'

Time_format = "%a %Y-%m-%d %H:%M:%S"

E7div = ->(value) { value / 10.0 ** 7 }
R2val = ->(value) { value.round(2) }

file = File.open('/Users/jamiguet/data_science/data/Takeout/Location History/Location History.json')

data = JSON.parse(file.read)

data = data["locations"]

puts "Loaded #{data.size} locations"


position_factory = PositionFactory.new({
                                           :timestampMs => :time_stamp,
                                           :latitudeE7 => :latitude,
                                           :longitudeE7 => :longitude
                                       }, {
                                           :time_stamp => ->(value) { Integer(value[0..-3]) },
                                           :latitude => E7div,
                                           :longitude => E7div
                                       }, {
                                           :time_stamp => ->(value) { Time.at(value).strftime(Time_format) },
                                           :latitude => R2val,
                                           :longitude => R2val,
                                       })

points = data[0..99].map { |data| position_factory.from_hash(data) }


previous = points[0]

segments = points.drop(1).map do |current|
  diff = previous - current
  #puts "From: #{previous.pp_time_stamp} To: #{current.pp_time_stamp}  => v: #{diff.speed} Km/h  d: #{diff.distance}"
  previous = current
  diff
end

puts segments
         .select { |point| point.speed > 0.0 and point.speed < 140 }
         .map(&:speed)
         .descriptive_statistics
         .map { |key, value| "#{key} => #{value}" }

