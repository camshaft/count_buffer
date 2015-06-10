defmodule CountBuffer do
  def start(name, size, flush) do
    PoolRing.start(name, size, fn(_, _) ->
      GenServer.start_link(__MODULE__, [flush], [])
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

  def init([flush]) do
    :erlang.send_after(500, self(), :flush)
    :erlang.process_flag(:trap_exit, true)
    {:ok, {flush, %{}}}
  end

  def handle_call(_, _, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end

  def handle_info(:flush, {flush, counts}) do
    parent = self()
    spawn(fn ->
      Enum.each(counts, fn({{bucket, key}, count}) ->
        try do
          flush.(bucket, key, count)
        rescue
          _ ->
            send(parent, {bucket, key, count})
        end
      end)
    end)
    :erlang.send_after(500, self(), :flush)
    {:noreply, {flush, %{}}}
  end
  def handle_info({bucket, key, count}, {flush, counts}) when is_integer(count) do
    val = :maps.get({bucket, key}, counts, 0)
    counts = :maps.put({bucket, key}, val + count, counts)
    {:noreply, {flush, counts}}
  end
  def handle_info(_info, state) do
    {:noreply, state}
  end
end
