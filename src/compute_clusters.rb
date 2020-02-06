require_relative 'position_tools'
require 'json'
require 'date'
require 'descriptive_statistics'
require 'optparse'
require 'haversine'

Time_format = "%a %Y-%m-%d %H:%M:%S"

E7div = ->(value) { value / 10.0 ** 7 }
R2val = ->(value) { value.round(2) }

Options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: compute_clusters.rb [options]"

  opts.on("-fFILE", "--data-file=FILE", "json file to process") do |file_name|
    Options[:data_file_name] = file_name
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!


file = File.open(Options[:data_file_name])

data = JSON.parse(file.read)

data = data["locations"]

puts "Loaded #{data.size} locations"


position_factory = PositionFactory.new({
                                           :timestampMs => :time_stamp,
                                           :latitudeE7 => :latitude,
                                           :longitudeE7 => :longitude,
                                           :accuracy => :accuracy
                                       }, {
                                           :time_stamp => ->(value) { Integer(value[0..-3]) },
                                           :latitude => E7div,
                                           :longitude => E7div
                                       }, {
                                           :time_stamp => ->(value) { Time.at(value).strftime(Time_format) },
                                           :latitude => R2val,
                                           :longitude => R2val,
                                       },
                                       ->(previous, current) {
                                         Haversine.distance(previous.latitude, previous.longitude,
                                                            current.latitude, current.longitude).to_km },
                                       ->(previous, current) {
                                         (current.time_stamp - previous.time_stamp) / 60.0 ** 2 })


points = data.map { |data| position_factory.from_hash(data) }


previous = points[0]

segments = points.drop(1).map do |current|
  diff = current - previous
  #puts "From: #{previous.pp_time_stamp} To: #{current.pp_time_stamp}  => v: #{diff.speed} Km/h  d: #{diff.distance}"
  previous = current
  diff
end

puts segments
         .select { |point| point.speed > 0.0 and point.speed < 140 }
         .map(&:speed)
         .descriptive_statistics
         .map { |key, value| "#{key} => #{value}" }


# computing clusters in a very clumsy and inefficient way
#
point_adapter = PositionFactory.new

include = ->(point, centroid) {
  centroid_point = point_adapter.from_hash(centroid)
  (point - centroid_point ).distance < (centroid_point.accuracy / 1000.0)
}

centroid = ->(contents) {
  result = contents.reduce({:latitude => 0, :longitude => 0, :time_stamp => 0, :accuracy => 100000000}) do |sum, point|
    sum[:latitude] = sum[:latitude] + point.latitude
    sum[:longitude] = sum[:longitude] + point.longitude
    sum[:time_stamp] = point.time_stamp
    sum[:accuracy] = [point.accuracy, sum[:accuracy]].min
    sum
  end
  result[:latitude] /= contents.size
  result[:longitude] /= contents.size
  result
}

cluster = Cluster.new(include, centroid)

clusters = []

clusters << cluster

points.each do |point|
  clusters.each do |cluster|
    unless cluster.present!(point)
      new_cluster = Cluster.new(include, centroid)
      raise "Something seriously wrong" unless new_cluster.present!(point)
      clusters << new_cluster
      break
    end
  end
end

puts "Total points #{points.size}"
puts "Total clusters #{clusters.size}"
puts "Meaningful clusters: "
clusters
    .select { |cluster| cluster.size > 1 }
    .each { |cluster| puts cluster }
