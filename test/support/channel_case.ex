defmodule ParlorWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by channel tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest
      import ParlorWeb.ChannelCase

      # The default endpoint for testing
      @endpoint ParlorWeb.Endpoint
    end
  end
end
