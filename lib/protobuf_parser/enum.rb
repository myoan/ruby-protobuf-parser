module ProtobufParser
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
      puts "create enum.rb as #{name}"
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
end
