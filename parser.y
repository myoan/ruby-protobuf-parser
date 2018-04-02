class ProtobufParser
token KEY INTEGER STRING INT32 MSG_NAME
start messages
rule
  messages: message { result = val[0] }
          | message messages { result = val }
  message: 'message' MSG_NAME '{' defines '}' { result = {}; result[val[1].downcase.to_sym] = val[3] }
  defines: define { result = val[0] }
         | define defines { result = val }
  define: type KEY '=' index ';' { result = { id: val[3], type: val[0], key: val[1] } }
  type: STRING
      | INT32
  index: INTEGER { result = val[0].to_i }
end

---- inner

  def parse(str)
    @q = []
    @q << ["message", "message"]
    @q << [:MSG_NAME, "Sample"]
    @q << ["{", "{"]
    @q << [:STRING, "string"]
    @q << [:KEY, "hoge"]
    @q << ["=", "="]
    @q << [:INTEGER, "1"]
    @q << [";", ";"]
    @q << [:STRING, "string"]
    @q << [:KEY, "fuga"]
    @q << ["=", "="]
    @q << [:INTEGER, "2"]
    @q << [";", ";"]
    @q << ["}", "}"]
    @q << [false, "$"]
    # p @q
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
  puts "end"
end
