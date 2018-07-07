module ProtobufParser
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
end