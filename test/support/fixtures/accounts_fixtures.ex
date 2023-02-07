defmodule Pento.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pento.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def valid_username, do: "valid username"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      username: valid_username()
    })
  end

  @spec user_fixture(any) :: any
  def user_fixture(attrs \\ %{}, opts \\ []) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Pento.Accounts.register_user()

    # if account is confirmed,
    if Keyword.get(opts, :confirmed, true), do: Pento.Repo.transaction(confirm_user_multi(user))
    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, Pento.Accounts.User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(
      :tokens,
      Pento.Accounts.UserToken.user_and_contexts_query(user, ["confirm"])
    )
  end
end
