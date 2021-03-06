defmodule CodeStats.FrontpageChannel do
  use Phoenix.Channel

  @moduledoc """
  The frontpage channel is used to send live updates of total
  XP numbers on the front page.
  """

  alias CodeStats.{
    CacheService,
    User,
    Pulse
  }

  def join("frontpage", _params, socket) do
    # Load total language XPs from cache and use them to populate total XP and
    # list of most popular languages
    total_lang_xps = CacheService.get_total_language_xps()

    total_xp = Enum.reduce(total_lang_xps, 0, fn {_, amount}, acc -> amount + acc end)

    data = %{
      total_xp: total_xp,
      languages: Enum.map(total_lang_xps, fn {k, v} -> %{name: k, xp: v} end)
    }

    {:ok, data, socket}
  end

  @doc """
  API to send new pulse to channel.

  The given pulse must have xps preloaded, xps must have language preloaded.
  """
  def send_pulse(%User{} = user, %Pulse{xps: xps})
      when not is_nil(xps) do

    # Don't show username for private profiles
    username = case user.private_profile do
      true -> "Private user"
      false -> user.username
    end

    formatted_xps = for xp <- xps do
      %{
        xp: xp.amount,
        language: xp.language.name,
        username: username
      }
    end

    CodeStats.Endpoint.broadcast("frontpage", "new_pulse", %{xps: formatted_xps})
  end
end
