defmodule Api.V1.SessionControllerTest do
  use Api.ConnCase

  alias Db.Accounts
  alias Db.Accounts.Session
  alias Api.Auth.Token

  @refresh_token_payload %{
    device_id: "some device",
    platform_id: "ios"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/helio.fm.v1+json")}
  end

  describe "re-issuing a token" do
    setup [:create_session]

    test "refreshes token given a valid token and a new token becomes valid to refresh again", %{conn: conn, token: token} do
      conn = get authenticated(conn, token), api_user_current_session_path(conn, :is_authenticated)
      assert json_response(conn, 200)

      :timer.sleep(1000) # to make sure new tokens will have different expiry

      conn = post authenticated(conn, token), api_user_current_session_path(conn, :refresh_token),
        session: @refresh_token_payload

      assert %{"token" => new_token_1} = json_response(conn, 200)
      assert token != new_token_1

      # authorizes the protected resource request with a refreshed token
      conn = get authenticated(conn, new_token_1), api_user_current_session_path(conn, :is_authenticated)
      assert json_response(conn, 200)

      :timer.sleep(1000) # to make sure new tokens will have different expiry

      # and is able to use new token to prolong the sliding session again
      conn = post authenticated(conn, new_token_1), api_user_current_session_path(conn, :refresh_token),
        session: @refresh_token_payload

      assert %{"token" => new_token_2} = json_response(conn, 200)
      assert new_token_1 != new_token_2

      conn = get authenticated(conn, new_token_2), api_user_current_session_path(conn, :is_authenticated)
      assert json_response(conn, 200)

      # fails to re-generate token twice based on the old tokens
      conn = post authenticated(conn, token), api_user_current_session_path(conn, :refresh_token),
        session: @refresh_token_payload

      assert response(conn, 401)

      conn = post authenticated(conn, new_token_1), api_user_current_session_path(conn, :refresh_token),
        session: @refresh_token_payload

      assert response(conn, 401)
    end

    test "fails to re-generate token given valid token but different device id", %{conn: conn, token: token} do
      conn = get authenticated(conn, token), api_user_current_session_path(conn, :is_authenticated)
      assert json_response(conn, 200)

      conn = post authenticated(conn, token), api_user_current_session_path(conn, :refresh_token),
        session: %{@refresh_token_payload | device_id: "other"}

      assert response(conn, 401)
    end

    test "fails to re-generate token given an unauthenticated request", %{conn: conn} do
      conn = post conn, api_user_current_session_path(conn, :refresh_token), session: @refresh_token_payload
      assert response(conn, 401)
    end
  end

  @user_attrs %{
    login: "helio.fm",
    email: "email@helio.fm",
    name: "john",
    github_uid: "12345"
  }

  defp create_session(_) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, token, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :hour}, permissions: %{})
    {:ok, token} = Session.update_token_for_device(user.id,
      @refresh_token_payload.device_id, @refresh_token_payload.platform_id, token)
    {:ok, token: token}
  end

  defp authenticated(conn, jwt) do
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
