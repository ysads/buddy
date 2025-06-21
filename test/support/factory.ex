defmodule Buddy.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Buddy.Repo

  alias Buddy.Account.Domain, as: Account
  alias Buddy.Category.Domain, as: Category
  alias Buddy.Provision.Domain, as: Provision
  alias Buddy.Transaction.Domain, as: Transaction

  def account_factory do
    %Account{
      name: sequence(:name, &"Account #{&1}"),
      currency: "USD",
      balance: 10_000,
      type: sequence(:type, Account.account_types())
    }
  end

  def category_factory do
    %Category{
      name: sequence(:name, &"Category #{&1}")
    }
  end

  def provision_factory do
    %Provision{
      month: "2024-03",
      amount: 10_000,
      category: build(:category)
    }
  end

  def transaction_factory do
    %Transaction{
      amount: 10_000,
      description: sequence(:description, &"Transaction #{&1}"),
      date: ~D[2024-03-21],
      account: build(:account),
      provision: build(:provision)
    }
  end
end
