module ProtobufParser
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
end
