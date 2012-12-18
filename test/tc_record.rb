
require 'test/unit'
require 'qqwry'

class TC_Record < Test::Unit::TestCase
  def teardown
    io = StringIO.new(@s)
    r = QQWry::Record.new(0x01020300, io, 3)
    assert_equal(0x01020300, r.ip_start)
    assert_equal(0x01020304, r.ip_end)
    assert_equal('1.2.3.0', r.ip_str_start)
    assert_equal('1.2.3.4', r.ip_str_end)
    if @nil_country
      assert_equal(nil, r.country)
    else
      assert_equal('country', r.country)
    end
    if @nil_area
      assert_equal(nil, r.area)
    else
      assert_equal('area', r.area)
    end
  end

  def test_simple
    @s = "pad\x04\x03\x02\x01country\x00area\x00"
  end

  def test_mode1
    @s = "pad\x04\x03\x02\x01\x01\x0b\x00\x00country\x00area\x00"
  end

  def test_mode2
    @s = "pad\x04\x03\x02\x01\x02\x10\x00\x00area\x00country\x00"
  end

  def test_mix1
    @s = "pad\x04\x03\x02\x01\x01\x0b\x00\x00\x02\x14\x00\x00area\x00country\x00"
  end

  def test_mix2
    @s = "pad\x04\x03\x02\x01\x01\x0b\x00\x00\x02\x13\x00\x00\x01\x1b\x00\x00country\x00area\x00"
  end

  def test_mix2_2
    @s = "pad\x04\x03\x02\x01\x01\x0b\x00\x00\x02\x13\x00\x00\x02\x1b\x00\x00country\x00area\x00"
  end

  def test_zero_offset
    @s = "pad\x04\x03\x02\x01\x01\x0b\x00\x00\x02\x13\x00\x00\x02\x00\x00\x00country\x00area\x00"
    @nil_area = true
  end

  def test_adv
    @s = "pad\x04\x03\x02\x01\x01\x0b\x00\x00\x02\x13\x00\x00\x02\x1c\x00\x00CZ88.NET\x00 CZ88.NET \x00"
    @nil_country = true
    @nil_area = true
  end
end

class TC_Record_Abnormal < Test::Unit::TestCase
  def test_invalid_encoding
    io = StringIO.new("\x04\x03\x02\x01\xd6\xea\x96\x00\x96\x00")
    r = QQWry::Record.new(0, io, 0)
    assert_equal("\xe6\xa0\xaa", r.country.to_s)
    assert_equal('', r.area.to_s)
  end
end
