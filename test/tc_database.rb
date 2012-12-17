
require 'test/unit'
require 'qqwry'

class TC_DataBase < Test::Unit::TestCase
  # one record
  def test_one_record
    s = "\x12\x00\x00\x00\x12\x00\x00\x00" + # header
        "\xff\xff\xff\xffc1\x00a1\x00" + # record
        "\x00\x00\x00\x00\x08\x00\x00" # index
    db = QQWry::Database.new(StringIO.new(s))
    assert_equal('c1a1', db.version)
    records = []
    db.each{|r| records << r}
    assert_equal(1, records.length)
    assert_equal('c1', records[0].country)
    assert_equal('a1', records[0].area)
    ['0.0.0.0', 0x01020304, '255.255.255.255'].each do |ip|
      r = db.query(ip)
      assert_equal('c1', r.country)
      assert_equal('a1', r.area)
    end
    assert_raise(ArgumentError){db.query(-1)}
    assert_raise(ArgumentError){db.query(1 << 32)}
  end

  # two records
  def test_two_record
    s = "\x1c\x00\x00\x00\x23\x00\x00\x00" + # header
        "\xff\xff\x00\x00c1\x00a1\x00" + # record 1
        "\xff\xff\xff\xffc2\x00a2\x00" + # record 2
        "\x00\x00\x00\x00\x08\x00\x00" + # index 1
        "\x00\x00\x01\x00\x12\x00\x00" # index 2
    db = QQWry::Database.new(StringIO.new(s))
    assert_equal('c2a2', db.version)
    records = []
    db.each{|r| records << r}
    assert_equal(2, records.length)
    r = [{:c => 'c1', :a => 'a1'}, {:c => 'c2', :a => 'a2'}]
    (0...2).each do |i|
      assert_equal(r[i][:c], records[i].country)
      assert_equal(r[i][:a], records[i].area)
    end
    s = {'0.0.0.0' => r[0], '0.0.254.254' => r[0], '0.0.255.255' => r[0],
         '0.1.0.0' => r[1], '0.1.2.3' => r[1], '255.255.255.255' => r[1]}
    s.each do |ip, r|
      rec = db.query(ip)
      assert_equal(r[:c], rec.country)
      assert_equal(r[:a], rec.area)
    end
  end

  # three records
  def test_three_record
    s = "\x26\x00\x00\x00\x34\x00\x00\x00" + # header
        "\xff\xff\x00\x00c1\x00a1\x00" + # record 1
        "\xff\xff\xff\x00c2\x00a2\x00" + # record 2
        "\xff\xff\xff\xffc3\x00a3\x00" + # record 3
        "\x00\x00\x00\x00\x08\x00\x00" + # index 1
        "\x00\x00\x01\x00\x12\x00\x00" + # index 2
        "\x00\x00\x00\x01\x1c\x00\x00" # index 3
    db = QQWry::Database.new(StringIO.new(s))
    assert_equal('c3a3', db.version)
    records = []
    db.each{|r| records << r}
    assert_equal(3, records.length)
    r = [{:c => 'c1', :a => 'a1'}, {:c => 'c2', :a => 'a2'},
         {:c => 'c3', :a => 'a3'}]
    (0...3).each do |i|
      assert_equal(r[i][:c], records[i].country)
      assert_equal(r[i][:a], records[i].area)
    end
    s = {'0.0.0.0' => r[0], '0.0.254.254' => r[0], '0.0.255.255' => r[0],
         '0.1.0.0' => r[1], '0.1.8.254' => r[1], '0.255.255.255' => r[1],
         '1.0.0.0' => r[2], '1.2.3.4' => r[2], '255.255.255.255' => r[2]}
    s.each do |ip, r|
      rec = db.query(ip)
      assert_equal(r[:c], rec.country)
      assert_equal(r[:a], rec.area)
    end
  end
end
