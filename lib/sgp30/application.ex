defmodule Sgp30.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: Sgp30.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
