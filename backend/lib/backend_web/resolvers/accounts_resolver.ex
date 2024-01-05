defmodule BackendWeb.AccountsResolver do
  alias Backend.Accounts

  def all_users(_root, _args, _info) do
    {:ok, Accounts.list_users()}
  end
end
