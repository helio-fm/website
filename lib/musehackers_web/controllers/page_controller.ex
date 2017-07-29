defmodule MusehackersWeb.PageController do
  use MusehackersWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
