class ProtobufParser::Parser
token INTEGER WORD DQWORD
start top_stmt
rule
  top_stmt: version statements               { }
  version: 'syntax' '=' DQWORD ';'           { @statement.version = val[2].gsub("\"", "") }
  statements: statement
            | statements statement           { }
  statement: import
           | package_syntax
           | message                         { @statement.append(:message, val[0]) }
  import: 'import' DQWORD ';'                { @statement.append(:import, ProtobufParser::Import.new(val[1].gsub("\"", ""))) }
  package_syntax: 'package' package ';'      { @statement.append(:package, val[1]) }
  package: WORD
         | package '.' WORD                  { result = val.join }
  message: 'message' WORD '{' defines '}'    { result = ProtobufParser::Message.new(val[1], val[3]) }
  defines:
         | define
         | defines define                    { result = val.flatten }
  define: oneof                              { result = val[0] }
        | enum                               { result = val[0] }
        | message                            { result = val[0] }
        | type WORD '=' index ';'            { result = ProtobufParser::Message::Field.new(val[0], val[1], val[3], false) }
        | 'repeated' type WORD '=' index ';' { result = ProtobufParser::Message::Field.new(val[1], val[2], val[4], true) }
  oneof: 'oneof' WORD '{' defines '}'        { result = ProtobufParser::Oneof.new(val[1], val[3]) }
  enum: 'enum' WORD '{' enum_defines '}'     { result = ProtobufParser::Enum.new(val[1], val[3].flatten) }
  enum_defines:
              | enum_defined
              | enum_defines enum_defined    { result = val }
  enum_defined: WORD '=' index ';'           { result = ProtobufParser::Enum::Field.new(val[0], val[2], false) }
              | 'reserved' list ';'          { result = val[1..-2].flatten }
  list: element
      | list ',' element                     { result = ([val[0]] + [val[2]]).flatten }
  element: INTEGER                           { result = ProtobufParser::Enum::Field.new("", val[0].to_i, true) }
         | DQWORD                            { result = ProtobufParser::Enum::Field.new(val[0].gsub("\"", ""), 0, true) }
         | INTEGER 'to' INTEGER              { result = ProtobufParser::Enum::RangeField.new(val[0].to_i, val[2].to_i) }
         | INTEGER 'to' 'max'                { result = ProtobufParser::Enum::RangeField.new(val[0].to_i, nil, true, true) }
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
require_relative 'lib/protobuf_parser'

---- inner

  def parse(str)
    @yydebug = false
    s = StringScanner.new(str)
    @q = []
    @statement = ProtobufParser::Statement.new
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
      s.scan(/max/)                 ? (@q << [s.matched, s.matched]) :
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
    @statement
  end

  def next_token
    @q.shift
  end

---- footer

parser = ProtobufParser::Parser.new
if ARGV.length == 1
  src = File.open(ARGV[0]).read
  pp parser.parse(src).to_h
end
