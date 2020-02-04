require_relative '../src/position'
require 'minitest/autorun'

class TestPosition < MiniTest::Test

  def setup

  end

  def test_factory
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


end