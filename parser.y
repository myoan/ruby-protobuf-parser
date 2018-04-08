class ProtobufParser
token INTEGER WORD DQWORD
start top_stmt
rule
  top_stmt: version statements { result = val }
  version: 'syntax' '=' DQWORD ';' { result = { :version => val[2].gsub("\"", "") } }
  statements: statement
            | statements statement { result = val[0].merge(val[1]) }
  statement: import
           | package_syntax
           | message { result = { message: val[0] } }
  import: 'import' DQWORD ';' { result = {import: []}; result[:import] << val[1].gsub("\"", "") }
  package_syntax: 'package' package ';' { result = {}; result[:package] = val[1] }
  package: WORD
         | package '.' WORD { result = val.join }
  message: 'message' WORD '{' defines '}' { result = { name: val[1], value: val[3] } }
  defines:
         | define
         | defines define { result = val.flatten }
  define: oneof { result = { oneof: val[0] } }
        | enum { result = { enum: val[0] } }
        | message { result = { message: val[0] } }
        | type WORD '=' index ';' { result = { id: val[3], type: val[0], key: val[1] , repeated: false} }
        | 'repeated' type WORD '=' index ';' { result = { id: val[4], type: val[1], key: val[2], repeated: true } }
  oneof: 'oneof' WORD '{' defines '}' { result = { name: val[1], value: val[3] } }
  enum: 'enum' WORD '{' enum_defines '}' { result = { name: val[1], value: val[3].flatten } }
  enum_defines:
              | enum_defined
              | enum_defines enum_defined { result = val }
  enum_defined: WORD '=' index ';' { result = { id: val[2], key: val[0] } }
              | 'reserved' list ';' { result = { reserved: val[1..-2].flatten } }
  list: element
      | list ',' element { result = ([val[0]] + [val[2]]).flatten }
  element: INTEGER              { result = { from: val[0].to_i, to: val[0].to_i } }
         | DQWORD               { result = { from: val[0], to: val[0] } }
         | INTEGER 'to' INTEGER { result = { from: val[0].to_i, to: val[2].to_i } }
         | INTEGER 'to' WORD    { result = { from: val[0].to_i, to: val[2] } }
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
      | WORD
  index: INTEGER { result = val[0].to_i }
end

---- header

require 'strscan'
require 'json'

---- inner

  def parse(str)
    @yydebug = false
    # @yydebug = true
    s = StringScanner.new(str)
    @q = []
    until                    s.eos?
      s.scan(/\s+/)                 ? (nil) :
      s.scan(/message/)             ? (@q << [s.matched, s.matched]) :
      s.scan(/import/)              ? (@q << [s.matched, s.matched]) :
      s.scan(/repeated/)            ? (@q << [s.matched, s.matched]) :
      s.scan(/reserved/)            ? (@q << [s.matched, s.matched]) :
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
      s.scan(/to/)                  ? (@q << [s.matched, s.matched]) :
      s.scan(/(0|[1-9]\d*)/)        ? (@q << [:INTEGER,  s.matched]) :
      s.scan(/{}=;/)                ? (@q << [s.matched, s.matched]) :
      s.scan(/\w+/)                 ? (@q << [:WORD,     s.matched]) :
      s.scan(/"[^"]+"/)             ? (@q << [:DQWORD,   s.matched]) :
      s.scan(/./)                   ? (@q << [s.matched, s.matched]) :
                                      (raise "scanner error (#{s.matched})")
    end
    do_parse
  end

  def next_token
    @q.shift
  end

---- footer

parser = ProtobufParser.new
if ARGV.length == 1
  src = File.open(ARGV[0]).read
  puts parser.parse(src).to_json
end
