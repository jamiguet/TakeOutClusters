Identity = ->(val) { val }

class Position

  def -(object)
    Segment.new(object, self, @distance, @time_lapse)
  end

  def initialize(data, mapping, transform, formatter, distance, time_lapse)

    @distance = distance
    @time_lapse = time_lapse

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

  def populate(data, mapping, transform)

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

  def initialize(mapping = {}, transform = {}, formatter = {}, distance = Identity, time_lapse = Identity)
    @mapping = mapping
    @transform = transform
    @formatter = formatter
    @distance = distance
    @time_lapse = time_lapse
  end

  def from_hash(data)
    Position.new(data, @mapping, @transform, @formatter, @distance, @time_lapse)
  end

end

class Segment

  def initialize(previous, current, distance, time_lapse)
    raise "Previous after current" unless previous.time_stamp <= current.time_stamp
    @previous = previous
    @current = current
    @distance = distance
    @time_lapse = time_lapse
  end

  def distance
    @distance.call(@previous, @current)
  end

  def speed
    delta_t = time_lapse
    raise "Negative time" unless delta_t >= 0
    distance / delta_t
  end

  def time_lapse
    @time_lapse.call(@previous, @current)
  end

  def to_s
    "Segment [#{@previous.pp_time_stamp}] => [#{@current.pp_time_stamp}]  #{distance.round(2)} Km, [#{speed.round(2)}] km/h"
  end

end

class Cluster

  def initialize(inclusion_predicate, centroid)
    @inclusion_predicate = inclusion_predicate
    @centroid = centroid
    @contents = []
    @centroid_value = {}
  end

  def present!(point)
    if @contents.empty? or @inclusion_predicate.call(point, @centroid_value)
      @contents << point
      @centroid_value = @centroid.call(@contents)
      true
    else
      false
    end
  end

  def centroid
    @centroid_value
  end

  def <<(point)
    @contents << point
  end

  def to_s
    centroid_disp = @centroid.call(@contents).map { |key, value| "#{key} => #{value}" }
    "Cluster size: #{@contents.size}, centroid #{centroid_disp} "
  end

  def size
    @contents.size
  end

end