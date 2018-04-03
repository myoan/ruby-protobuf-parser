class ProtobufParser
token INTEGER WORD DQWORD
start statement
rule
  statement: version imports package_syntax messages { result = val[0].merge(val[1]).merge(val[2]).merge(val[3]) }
  messages: message
          | message messages { result = val }
  message: 'message' WORD '{' defines '}' { result = {}; result[val[1].downcase.to_sym] = val[3] }
  defines: define
         | oneof
         | define defines { result = val }
  define: type WORD '=' index ';' { result = { id: val[3], type: val[0], key: val[1] , repeated: false} }
        | 'repeated' type WORD '=' index ';' { result = { id: val[4], type: val[1], key: val[2], repeated: true } }
  version: 'syntax' '=' DQWORD ';' { result = {}; result[:version] = val[2].gsub("\"", "") }
  package_syntax: 'package' package ';' { result = {}; result[:package] = val[1] }
  package: WORD
         | WORD '.' package { result = val.join }
  oneof:  'oneof' WORD '{' defines '}' { result = {}; result[val[1].downcase.to_sym] = val[3] }
  imports: import
         | import imports { result = val }
  import: 'import' DQWORD ';' { result = {import: []}; result[:import] << val[1].gsub("\"", "") }
  type: 'bool'
      | 'bytes'
      | 'enum'
      | 'fixed32'
      | 'fixed64'
      | 'google.protobuf.Any'
      | 'int32'
      | 'int64'
      | 'package'
      | 'string'
      | 'sfixed32'
      | 'sfixed64'
      | 'sint32'
      | 'sint64'
      | 'uint32'
      | 'uint64'
  index: INTEGER { result = val[0].to_i }
end

---- header

require 'strscan'

---- inner

  def parse(str)
    s = StringScanner.new(str)
    @q = []
    until                    s.eos?
      s.scan(/\s+/)                 ? (nil) :
      s.scan(/message/)             ? (@q << [s.matched, s.matched]) :
      s.scan(/import/)              ? (@q << [s.matched, s.matched]) :
      s.scan(/repeated/)            ? (@q << [s.matched, s.matched]) :
      s.scan(/bool/)                ? (@q << [s.matched, s.matched]) :
      s.scan(/bytes/)               ? (@q << [s.matched, s.matched]) :
      s.scan(/enum/)                ? (@q << [s.matched, s.matched]) :
      s.scan(/fixed32/)             ? (@q << [s.matched, s.matched]) :
      s.scan(/fixed64/)             ? (@q << [s.matched, s.matched]) :
      s.scan(/google.protobuf.Any/) ? (@q << [s.matched, s.matched]) :
      s.scan(/int32/)               ? (@q << [s.matched, s.matched]) :
      s.scan(/int64/)               ? (@q << [s.matched, s.matched]) :
      s.scan(/oneof/)               ? (@q << [s.matched, s.matched]) :
      s.scan(/package/)             ? (@q << [s.matched, s.matched]) :
      s.scan(/string/)              ? (@q << [s.matched, s.matched]) :
      s.scan(/sfixed32/)            ? (@q << [s.matched, s.matched]) :
      s.scan(/sfixed64/)            ? (@q << [s.matched, s.matched]) :
      s.scan(/sint32/)              ? (@q << [s.matched, s.matched]) :
      s.scan(/sint64/)              ? (@q << [s.matched, s.matched]) :
      s.scan(/uint32/)              ? (@q << [s.matched, s.matched]) :
      s.scan(/uint64/)              ? (@q << [s.matched, s.matched]) :
      s.scan(/syntax/)              ? (@q << [s.matched, s.matched]) :
      s.scan(/(0|[1-9]\d*)/)        ? (@q << [:INTEGER,  s.matched]) :
      s.scan(/{}=;/)                ? (@q << [s.matched, s.matched]) :
      s.scan(/\w+/)                 ? (@q << [:WORD,     s.matched]) :
      s.scan(/"[^"]+"/)             ? (@q << [:DQWORD,   s.matched]) :
      s.scan(/./)                   ? (@q << [s.matched, s.matched]) :
                                      (raise "scanner error (#{s.matched})")
    end
    p @q
    do_parse
  end

  def next_token
    @q.shift
  end

---- footer

parser = ProtobufParser.new
if ARGV.length == 1
  src = File.open(ARGV[0]).read
  puts src
  puts "---"
  p parser.parse(src)
  puts "---"
end
