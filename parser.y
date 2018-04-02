class ProtobufParser
token KEY INTEGER EQUAL EOL STRING INT32
start statements
rule
  statements: statement { result = val[0] }
            | statement statements { result = val }
  statement: type KEY EQUAL index EOL { result = { id: val[3], type: val[0], key: val[1] } }
  type: STRING
      | INT32
  index: INTEGER { result = val[0].to_i }
end

---- inner

  def parse(str)
    @q = []
    @q << [:STRING, "string"]
    @q << [:KEY, "hoge"]
    @q << [:EQUAL, "="]
    @q << [:INTEGER, "1"]
    @q << [:EOL, ";"]
    @q << [:STRING, "string"]
    @q << [:KEY, "fuga"]
    @q << [:EQUAL, "="]
    @q << [:INTEGER, "2"]
    @q << [:EOL, ";"]
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
