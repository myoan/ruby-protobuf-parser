module ProtobufParser
  class Oneof
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
