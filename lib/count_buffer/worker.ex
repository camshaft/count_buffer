defmodule CountBuffer.Worker do
  require Logger

  def init(flush) do
    :erlang.send_after(30_000, self(), :stats)
    loop(flush)
  end

  def loop(flush) do
    receive do
      :stats ->
        {_, size} = :erlang.process_info(self(), :message_queue_len)
        if size > 0 do
          :io.format("at=count_buffer measure#count_buffer.worker_queue=~p~n", [size])
        end
        :erlang.send_after(30_000, self(), :stats)
        __MODULE__.loop(flush)
      {bucket, key, count} ->
        count = gather(bucket, key, count)
        try do
          flush.(bucket, key, count)
        rescue
          _ ->
            Logger.error("error while saving count", [bucket: bucket,
                                                      key: key,
                                                      count: count])
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
