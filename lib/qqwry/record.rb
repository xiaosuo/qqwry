
require 'rubygems'
require 'bundler/setup'
require 'bindata'
require 'iconv' unless RUBY_VERSION.respond_to?(:encode)

module QQWry
  class Record
    attr_reader :ip_start, :ip_end, :country, :area

    def initialize(ip_start, file, offset)
      @ip_start = ip_start
      file.seek(offset)
      @ip_end = BinData::Uint32le.read(file).to_i
      case BinData::Uint8.read(file).to_i
      when 0x1
        offset = BinData::Uint24le.read(file).to_i
        file.seek(offset)
        case BinData::Uint8.read(file).to_i
        when 0x2
          file.seek(BinData::Uint24le.read(file).to_i)
          @country = BinData::Stringz.read(file).to_s
          file.seek(offset + 4)
        else
          file.seek(-1, IO::SEEK_CUR)
          @country = BinData::Stringz.read(file).to_s
        end
        parse_area(file)
      when 0x2
        offset = BinData::Uint24le.read(file).to_i
        parse_area(file)
        file.seek(offset)
        @country = BinData::Stringz.read(file).to_s
      else
        file.seek(-1, IO::SEEK_CUR)
        @country = BinData::Stringz.read(file).to_s
        parse_area(file)
      end
      if @country
        @country = conv(@country)
        @country = nil if @country=~ /\s*CZ88\.NET\s*/
      end
    end

    def ip_str_start
      ip_str(@ip_start)
    end

    def ip_str_end
      ip_str(@ip_end)
    end

    private

    def ip_str(ip)
      [ip].pack('N').unpack('C4').join('.')
    end

    def conv(str)
      begin
        if str.respond_to?(:encode)
          str.force_encoding('GBK').encode('UTF-8')
        else
          Iconv::conv('UTF-8', 'GBK', str)
        end
      rescue
        str = str[0, str.length - 1]
        retry
      end
    end

    def parse_area(file)
      case BinData::Uint8.read(file).to_i
      when 0x1, 0x2
        offset = BinData::Uint24le.read(file).to_i
        if offset > 0
          file.seek(offset)
          @area = BinData::Stringz.read(file).to_s
        end
      else
        file.seek(-1, IO::SEEK_CUR)
        @area = BinData::Stringz.read(file).to_s
      end
      if @area
        @area = conv(@area)
        # CZ88.NET is an advertisement
        @area = nil if @area =~ /\s*CZ88\.NET\s*/
      end
    end
  end
end
