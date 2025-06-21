defmodule Buddy.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Buddy.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox, as: EctoSandbox

  using do
    quote do
      alias Buddy.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Buddy.DataCase
      import Buddy.Factory
    end
  end

  setup tags do
    Buddy.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = EctoSandbox.start_owner!(Buddy.Repo, shared: not tags[:async])
    on_exit(fn -> EctoSandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @spec valid_params(list({atom(), atom()})) :: map()
  def valid_params(fields_with_types) do
    valid_value_by_type = %{
      "id" => fn -> 1 end,
      "integer" => fn -> :rand.uniform(100) end,
      "string" => fn -> "test" end,
      "boolean" => fn -> true end,
      "float" => fn -> :rand.uniform() end,
      "date" => fn -> ~D[2024-01-01] end,
      "datetime" => fn -> ~U[2024-01-01 00:00:00Z] end,
      "iso_month" => fn -> "2024-01" end,
      "account_type" => fn -> "checking" end
    }

    for {field, type} <- fields_with_types, into: %{} do
      type = Atom.to_string(type)
      {field, valid_value_by_type[type].()}
    end
  end
end
