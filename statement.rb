require 'pp'

module Protobuf
  class Statement
    attr_accessor :version

    def initialize
      @import_list  = []
      @message_list = []
      @package_list = []
      @version      = ""
    end

    def list(type)
      case type
      when :import
        @import_list
      when :message
        @message_list
      when :package
        @package_list
      else
        []
      end
    end

    def append(type, val)
      list(type) << val
    end

    def to_h
      {
        import: @import_list.map(&:to_h),
        message: @message_list.map(&:to_h),
        package: @package_list
      }
    end
  end

  class Import
    attr_accessor :path

    def initialize(path)
      @path = path
      puts "create import as #{path}"
      puts "---"
      pp path
      puts "---"
      puts ""
    end

    def to_h
      {
        path: path
      }
    end
  end

  class Enum
    class RangeField
      attr_accessor :from_value, :to_value

      def initialize(from_value, to_value, is_max = false, is_reserved = false)
        @from_value  = from_value
        @to_value    = to_value
        @is_max      = is_max
        @is_reserved = is_reserved
      end

      def to_h
        {
          from:        @from_value,
          to:          @to_value,
          is_max:      @is_max,
          is_reserved: @is_reserved
        }
      end
    end

    class Field
      attr_accessor :key, :value

      def initialize(key, value, is_reserved = false)
        @key         = key
        @value       = value
        @is_reserved = is_reserved
      end

      def to_h
        {
          key:         @key,
          value:       @value,
          is_reserved: @is_reserved
        }
      end
    end

    attr_accessor :name, :data

    def initialize(name, data)
      puts "create enum as #{name}"
      puts "---"
      pp data
      puts "---"
      puts ""
      @name = name
      @data = data
    end

    def to_h
      {
        type: :message,
        name: name,
        data: data.map(&:to_h)
      }
    end
  end

  class Message
    class Field
      def initialize(type, key, index, is_repeated = false)
        @type        = type
        @key         = key
        @index       = index
        @is_repeated = is_repeated
      end

      def to_h
        {
          type:        @type,
          key:         @key,
          index:       @index,
          is_repeated: @is_repeated
        }
      end
    end

    attr_accessor :name, :data

    def initialize(name, data)
      puts "create message as #{name}"
      puts "---"
      pp data
      puts "---"
      puts ""
      @name = name
      @data = data
    end

    def to_h
      {
        type: :enum,
        name: name,
        data: data.map(&:to_h)
      }
    end
  end

  class OneOf
    attr_accessor :name, :data

    def initialize(name, data)
      puts "create one_of as #{name}"
      puts "---"
      pp data
      puts "---"
      puts ""
      @name = name
      @data = data
    end

    def to_h
      data.map(&:to_h)
    end
  end
end