require 'haversine'


class Position

  def -(object)
    Segment.new(self, object)
  end

  def initialize(data, mapping = {}, transform = {}, formatter = {})

    data.keys.each do |field|

      if mapping.key?(field.to_sym)
        field = mapping[field.to_sym]
      else
        field = field.to_sym
      end

      define_singleton_method("#{field.to_s}=") do |val|
        instance_variable_set("@#{field.to_s}", val)
      end

      define_singleton_method("#{field.to_s}") do
        instance_variable_get("@#{field.to_s}")
      end

      formatter_fn = ->(val) { val }
      if formatter.key?(field)
        formatter_fn = formatter[field]
      end

      define_singleton_method("pp_#{field.to_s}") do
        formatter_fn.call(instance_variable_get("@#{field.to_s}"))
      end

    end

    define_singleton_method("to_s") do
      result = "Position: "
      mapping.values.each do |field|
        result << "#{field.to_s}:  #{self.send('pp_' + field.to_s)}, "
      end
      result[0..-1]
    end

    populate(data, mapping, transform)
  end

  def populate (data, mapping, transform)

    data.each do |src, value|

      dest = src.to_sym
      if mapping.key?(src.to_sym)
        dest = mapping[src.to_sym]
      end

      if transform.key?(dest.to_sym)
        value = transform[dest.to_sym].call(value)
      end
      self.public_send("#{dest}=", value)
    end

  end
end

class PositionFactory

  def initialize(mapping, transform, formatter)
    @mapping = mapping
    @transform = transform
    @formatter = formatter
  end

  def from_hash(data)
    Position.new(data, @mapping, @transform, @formatter)
  end

end

# TODO Adapt segment so that it distance speed and time_lapse methods can be injected
class Segment

  def initialize(previous, current)
    raise "Previous after current" unless previous.time_stamp <= current.time_stamp
    @previous = previous
    @current = current
  end

  def distance
    Haversine.distance(@previous.latitude, @previous.longitude, @current.latitude, @current.longitude).to_km
  end

  def speed
    delta_t = time_lapse
    raise "Negative time" unless delta_t >= 0
    distance / delta_t
  end

  def time_lapse
    (@current.time_stamp - @previous.time_stamp) / 60.0 ** 2
  end

  def to_s
    "Segment [#{@previous.pp_time_stamp}] => [#{@current.pp_time_stamp}]  #{distance.round(2)} Km, [#{speed.round(2)}] km/h"
  end

end