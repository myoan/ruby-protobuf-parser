module ProtobufParser
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
        type: :'enum.rb',
        name: name,
        data: data.map(&:to_h)
      }
    end
  end
end

