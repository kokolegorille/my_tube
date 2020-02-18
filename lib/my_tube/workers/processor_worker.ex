# iex> %{} |> MyTube.Workers.ProcessorWorker.new() |> Oban.insert()
# Starting work...
# {:ok,
#  %Oban.Job{
#    __meta__: #Ecto.Schema.Metadata<:loaded, "public", "oban_jobs">,
#    args: %{},
#    attempt: 0,
#    attempted_at: nil,
#    attempted_by: nil,
#    completed_at: nil,
#    discarded_at: nil,
#    errors: [],
#    id: 1,
#    inserted_at: nil,
#    max_attempts: 20,
#    priority: 0,
#    queue: "default",
#    scheduled_at: nil,
#    state: "available",
#    tags: [],
#    unique: nil,
#    worker: "MyTube.Workers.ProcessorWorker"
#  }}
# iex(5)> %Oban.Job{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "public", "oban_jobs">,
#   args: %{},
#   attempt: 1,
#   attempted_at: ~U[2020-02-15 04:58:48.779275Z],
#   attempted_by: ["iMac-de-sqrt", "default", "17dje5qu"],
#   completed_at: nil,
#   discarded_at: nil,
#   errors: [],
#   id: 1,
#   inserted_at: ~U[2020-02-15 04:58:48.768320Z],
#   max_attempts: 20,
#   priority: 0,
#   queue: "default",
#   scheduled_at: ~U[2020-02-15 04:58:48.768320Z],
#   state: "executing",
#   tags: [],
#   unique: nil,
#   worker: "MyTube.Workers.ProcessorWorker"
# }
# ...Finished work

defmodule MyTube.Workers.ProcessorWorker do
  use Oban.Worker

  def perform(_args, job) do
    IO.puts "Starting work..."

    :timer.sleep(5_000)

    IO.inspect(job)
    IO.puts "...Finished work"
  end
end
