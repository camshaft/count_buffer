defmodule CountBuffer.Bench do
  use Benchfella

  setup_all do
    :application.ensure_all_started(:count_buffer)
    CountBuffer.start(:bench, 128, fn(_bucket, _key, _count) ->
      :timer.sleep(100)
      if _count !== 1 do
        IO.inspect {_bucket, _key, _count}
      end
      :ok
    end)
    {:ok, :bench}
  end

  bench "count_buffer" do
    CountBuffer.increment(:bench, "bench", :crypto.rand_bytes(5))
    :ok
  end

  bench "static key" do
    CountBuffer.increment(:bench, "bench", "key")
    :ok
  end
end
