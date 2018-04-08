```sh
$ racc -v -g -O parse.log -o proto.rb parser.y
$ ruby proto.rb src.proto | jq .
```
