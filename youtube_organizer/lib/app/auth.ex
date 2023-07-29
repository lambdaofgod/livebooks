defmodule YTOrg.AuthWrapper do
  defstruct [:token]

  def new(path, sym \\ :auth) do
    credentials = File.read!(Path.expand(path)) |> Poison.decode!()

    source = {:refresh_token, credentials, []}
    _ = Goth.start_link(name: sym, source: source)
    t = Goth.fetch!(sym).token
    %YTOrg.AuthWrapper{token: t}
  end
end
