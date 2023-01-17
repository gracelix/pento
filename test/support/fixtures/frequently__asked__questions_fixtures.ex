defmodule Pento.Frequently_Asked_QuestionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pento.Frequently_Asked_Questions` context.
  """

  @doc """
  Generate a faq.
  """
  def faq_fixture(attrs \\ %{}) do
    {:ok, faq} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        question: "some question",
        vote_count: 42
      })
      |> Pento.Frequently_Asked_Questions.create_faq()

    faq
  end
end
