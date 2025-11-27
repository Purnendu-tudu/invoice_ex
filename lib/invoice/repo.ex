defmodule Invoice.Repo do
  use Ecto.Repo,
    otp_app: :invoice,
    adapter: Ecto.Adapters.Postgres
end
