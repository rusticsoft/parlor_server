defmodule Parlor.Factory do
  @moduledoc false

  @spec room_code() :: String.t()
  def room_code do
    # for _ <- 1..4, into: "", do: <<Enum.random(?A..?Z)>>

    4
    |> Faker.Lorem.characters()
    |> to_string()
    |> String.downcase()
  end

  @spec handle() :: String.t()
  def handle do
    Faker.Superhero.name()
  end
end
