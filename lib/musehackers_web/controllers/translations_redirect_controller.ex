defmodule MusehackersWeb.TranslationsRedirectController do
  use MusehackersWeb, :controller
  @moduledoc false

  def index(conn, _params) do
    redirect(conn, external: redirect_url())
  end

  def redirect_url do
    doc_key = System.get_env("ETL_DOC_TRANSLATIONS")
    "https://docs.google.com/spreadsheets/d/#{doc_key}"
  end

end
