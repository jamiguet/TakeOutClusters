require_relative '../src/position_tools'
require 'minitest/autorun'

class TestPosition < MiniTest::Test

  def setup

  end

  def test_factory_for_dynamic_point
    expected_time = Time.now.to_i.to_s

    expected_pos = 345.7899999
    wrong_time = expected_time.clone
    wrong_time << "123"
    data = {:timestamp => wrong_time, :posX => expected_pos}
    position_factory = PositionFactory.new({
                                               :timestamp => :time_stamp,
                                               :posX => :x
                                           }, {
                                               :time_stamp => ->(value) { Integer(value[0..-4]) }
                                           }, {
                                               :time_stamp => ->(value) { Time.at(value).strftime(Time_format) }
                                           })


    tested = position_factory.from_hash(data)

    assert_equal(expected_time, tested.time_stamp.to_s)
    assert_equal(expected_pos, tested.x)

  end

  def test_factory_for_dynamic_segment

    position_factory = PositionFactory.new({
                                               :timestamp => :time_stamp,
                                               :posX => :x
                                           },
                                           {},
                                           {},
                                           ->(previous, current) { current.x - previous.x },
                                           ->(previous, current) { current.time_stamp - previous.time_stamp }
    )

    data_1 = {:timestamp => 250, :posX => 100.0}
    data_2 = {:timestamp => 350, :posX => 110.0}

    point_1 = position_factory.from_hash(data_1)
    point_2 = position_factory.from_hash(data_2)

    segment = point_2 - point_1

    assert_equal(10, segment.distance)
    assert_equal(100, segment.time_lapse)
    assert_equal(0.1, segment.speed)

  end


end
