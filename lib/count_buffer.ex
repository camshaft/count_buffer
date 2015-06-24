defmodule CountBuffer do
  def start(name, size, flush, num_workers \\ 3) do
    PoolRing.start(name, size, fn(_, _) ->
      {:ok, spawn_link(__MODULE__, :init, [flush, num_workers])}
    end)
  end

  def increment(name, bucket, key, count \\ 1) do
    case PoolRing.get(name, [bucket, key]) do
      {:ok, pid} ->
        send(pid, {bucket, key, count})
        {:ok, count}
      error ->
        error
    end
  end

  def init(flush, num_workers \\ 3) do
    :erlang.process_flag(:trap_exit, true)
    workers = :lists.seq(1, num_workers)
    |> Enum.map(fn(_) ->
      spawn_link(CountBuffer.Worker, :init, [flush])
    end)
    loop(workers, nil)
  end

  def loop(workers, timer) do
    receive do
      :flush ->
        flush(workers)
        __MODULE__.loop(workers, nil)
      {bucket, key, count} when is_integer(count) or is_float(count) ->
        k = {bucket, key}
        val = Process.get(k, 0)
        Process.put(k, val + count)

        timer = if timer do
          timer
        else
          :erlang.send_after(500, self(), :flush)
        end

        __MODULE__.loop(workers, timer)
      _other ->
        __MODULE__.loop(workers, timer)
    end
  end

  defp flush(workers) do
    :erlang.erase()
    |> Enum.each(fn({{bucket, key} = k, count}) ->
      hash(workers, k)
      |> send({bucket, key, count})
    end)
  end

  defp hash(workers, key) do
    i = rem(:erlang.phash2(key), length(workers))
    :lists.nth(i + 1, workers)
  end
end
