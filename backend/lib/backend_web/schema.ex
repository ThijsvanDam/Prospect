defmodule BackendWeb.Schema do
  use Absinthe.Schema

  alias BackendWeb.AccountsResolver

  object :user do
    field :id, non_null(:id)
    field :name, non_null(:string)
  end

  query do
    # this is the query entry point to our app
    @desc "Get users"
    field :all_users, non_null(list_of(non_null(:user))) do
      resolve(&AccountsResolver.all_users/3)
    end
  end
end
