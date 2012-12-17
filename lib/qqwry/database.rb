
require 'qqwry/record'

module QQWry
  class Header < BinData::Record
    SIZE = 8
    endian :little
    uint32 :index_offset_start
    uint32 :index_offset_end
  end

  class Index < BinData::Record
    SIZE = 7
    endian :little
    uint32 :ip_start
    uint24 :record_offset
  end

  class Database
    def initialize(file = 'QQWrt.Dat')
      if file.respond_to?(:to_str)
        @file = File.new(file.to_str)
      else
        @file = file
        @file.seek(0)
      end
      @header = QQWry::Header.read(@file)
    end

    def each
      offset = @header.index_offset_start
      while offset <= @header.index_offset_end
        @file.seek(offset)
        index = QQWry::Index.read(@file)
        record = QQWry::Record.new(index.ip_start, @file, index.record_offset)
        yield record
        offset += QQWry::Index::SIZE
      end
    end

    def version
      # The last record saves the version info
      @file.seek(@header.index_offset_end)
      index = QQWry::Index.read(@file)
      r = QQWry::Record.new(0, @file, index.record_offset)
      r.country + r.area
    end

    def query(ip)
      if ip.respond_to?(:to_str)
        ip = ip.to_str.split('.').collect{|i| i.to_i}.pack('C4').unpack('N')[0]
      end
      raise ArgumentError, "invalid IP" unless (0...(1 << 32)).include?(ip)
      @file.seek(QQWry::Header::SIZE)
      low = 0
      # the end record is the version info
      start = @header.index_offset_start
      high = (@header.index_offset_end - start) / QQWry::Index::SIZE
      while low <= high
        middle = (low + high) / 2
        @file.seek(start + middle * QQWry::Index::SIZE)
        index = QQWry::Index.read(@file)
        if ip > index.ip_start
          low = middle + 1
        elsif ip < index.ip_start
          high = middle - 1
        else
          return QQWry::Record.new(index.ip_start, @file, index.record_offset)
        end
      end
      @file.seek(start + high * QQWry::Index::SIZE)
      index = QQWry::Index.read(@file)
      QQWry::Record.new(index.ip_start, @file, index.record_offset)
    end
  end
end
