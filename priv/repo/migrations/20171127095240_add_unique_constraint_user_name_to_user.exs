defmodule CercleApi.Repo.Migrations.AddUniqueConstraintUserNameToUser do
  use Ecto.Migration
  alias CercleApi.{Repo, User}
  import Ecto.Query, only: [from: 2]

  def up do
    if Mix.env != :test, do: prepare_users
    alter table("users") do
      modify :user_name, :string, null: false
    end
    create unique_index("users", [:user_name])
  end

  def down do
    drop unique_index("users", [:user_name])
    alter table("users") do
      modify :user_name, :string, null: true
    end
  end

  defp prepare_users do
  end

  defp update_user_name(user) do
    User.update_user_name(user)
    |> Repo.update!
  end
end
