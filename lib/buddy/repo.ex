defmodule Buddy.Repo do
  use Ecto.Repo,
    otp_app: :buddy,
    adapter: Ecto.Adapters.Postgres
end
