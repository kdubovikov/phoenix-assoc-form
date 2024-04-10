defmodule ScrumMaster.Repo do
  use Ecto.Repo,
    otp_app: :scrum_master,
    adapter: Ecto.Adapters.SQLite3
end
