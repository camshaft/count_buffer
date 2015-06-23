defmodule CountBuffer.Worker do
  def init(flush) do
    loop(flush)
  end

  def loop(flush) do
    receive do
      {bucket, key, count} ->
        count = gather(bucket, key, count)
        try do
          flush.(bucket, key, count)
        rescue
          _ ->
            send(self(), {bucket, key, count})
        end
        __MODULE__.loop(flush)
    end
  end

  defp gather(bucket, key, count) do
    receive do
      {^bucket, ^key, additional} ->
        gather(bucket, key, count + additional)
    after
      0 ->
        count
    end
  end
end
