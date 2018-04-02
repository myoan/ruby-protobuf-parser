class ProtobufParser
token INTEGER WORD DQWORD VERSION
start statement
rule
  statement: version messages { result = val[0].merge(val[1]) }
  messages: message { result = val[0] }
          | message messages { result = val }
  message: 'message' WORD '{' defines '}' { result = {}; result[val[1].downcase.to_sym] = val[3] }
  defines: define { result = val[0] }
         | define defines { result = val }
  define: type WORD '=' index ';' { result = { id: val[3], type: val[0], key: val[1] } }
  version: 'syntax' '=' DQWORD ';' { result = {}; result[:version] = val[2].gsub("\"", "") }
  type: 'string'
  index: INTEGER { result = val[0].to_i }
end

---- header

require 'strscan'

---- inner

  def parse(str)
    s = StringScanner.new(str)
    @q = []
    until s.eos?
      s.scan(/\s+/)                 ? (nil) :
      s.scan(/message/)             ? (@q << [s.matched, s.matched]) :
      s.scan(/string/)              ? (@q << [s.matched, s.matched]) :
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
