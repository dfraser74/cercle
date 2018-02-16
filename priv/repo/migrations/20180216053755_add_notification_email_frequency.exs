defmodule CercleApi.Repo.Migrations.AddNotificationEmailFrequency do
  use Ecto.Migration

  def change do
	  alter table(:users) do
	    add :notification_email_frequency, :integer, default: 1
	  end
    create index("users", [:notification_email_frequency])
  end
end
