defmodule Web.Helpers.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """

  @images_store_path Application.get_env(:api, :images_path)

  require Logger
  require Poison

  alias Ueberauth.Auth
  alias Db.Accounts

  use Tesla
  plug Tesla.Middleware.Headers, [{"Accept", "image/jpg,image/jpeg,image/png"}]
  plug Tesla.Middleware.FollowRedirects, max_redirects: 5

  def find_or_create(%Auth{provider: :github} = auth) do
    user = auth |> uid_from_auth() |> Accounts.get_user_by_github_uid()
    if user != nil do
      {:ok, user}
    else
      local_avatar_uri = auth
        |> get_avatar()
        |> upload_avatar(auth.info.nickname)
      register_result = auth
        |> user_from_github_auth(local_avatar_uri)
        |> Accounts.register_user_from_github()
      Logger.info("Register user from Github result: #{inspect(register_result)}")
      register_result
    end
  end

  defp user_from_github_auth(auth, local_avatar_uri),
    do: %{
      github_uid: uid_from_auth(auth),
      login: Map.get(auth.info, :nickname),
      email: Map.get(auth.info, :email),
      name: name_from_auth(auth),
      location: Map.get(auth.info, :location),
      avatar: local_avatar_uri
    }

  defp upload_avatar({:ok, %Tesla.Env{status: 200, body: body} = env}, login) do
    file_subpath = Path.join(login, "avatar." <> get_file_extension(env))
    dir_path = Path.join(@images_store_path, login)
    file_path = Path.join(@images_store_path, file_subpath)
    File.mkdir_p(dir_path)
    File.write!(file_path, body)
    file_subpath
  end
  defp upload_avatar({:error, _error}, _login), do: nil
  defp upload_avatar({:ok, _other}, _login), do: nil

  defp get_avatar(auth) do    
    with url <- avatar_url_from_auth(auth),
      {:ok, %Tesla.Env{} = env} <- Tesla.get(url) do
      {:ok, env}
    else
      {:error, _err} -> auth.info
        |> Map.get(:email)
        |> get_gravatar()
    end
  end

  defp get_gravatar(nil), do: {:error, nil}
  defp get_gravatar(email) do
    hash = email
      |> String.trim()
      |> String.downcase()
      |> :erlang.md5()
      |> Base.encode16(case: :lower)
    Logger.info("Getting Gravatar from: https://www.gravatar.com/avatar/#{hash}?s=150&d=identicon")
    Tesla.get("https://www.gravatar.com/avatar/#{hash}?s=150&d=identicon")
  end

  defp get_file_extension(%Tesla.Env{} = env) do
    type = Tesla.get_header(env, "content-type")
    case type do
      "image/jpg" -> "jpg"
      "image/jpeg" -> "jpg"
      "image/png" -> "png"
      _ -> "jpg"
    end
  end

  defp uid_from_auth(auth), do: Kernel.inspect(auth.uid) # turn anything to string
  defp avatar_url_from_auth(%{info: %{urls: %{avatar_url: image}}}), do: image # github-specific
  defp avatar_url_from_auth(_), do: nil # default case if nothing matches

  defp name_from_auth(auth) do
    name = Map.get(auth.info, :name)
    nickname = Map.get(auth.info, :nickname)
    if name, do: name, else: nickname
  end
end
