count_buffer
===========

buffer a large set of counters and flush periodically.

## api

```elixir
name = :my_counters
size = 128
flush = fn(bucket, key, count) ->
  ## persist your counts here
end
CountBuffer.start(name, size, flush)

bucket = "page_views"
key = "index.html"

CountBuffer.increment(name, bucket, key)
CountBuffer.increment(name, bucket, key, 10)
```