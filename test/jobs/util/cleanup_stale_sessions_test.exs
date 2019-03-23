defmodule Jobs.Util.CleanupStaleSessionsTest do
  use Jobs.DataCase

  alias Db.Accounts
  alias Db.Accounts.Session
  alias Api.Auth.Token
  alias Jobs.Util.CleanupStaleSessions

  @user_attrs %{
    login: "test",
    email: "peter.rudenko@gmail.com",
    name: "name",
    password: "some password"
  }

  describe "cleanup stale sessions" do
    test "cleanup sessions job removes all sessions with token expired" do
      {:ok, user} = Accounts.create_user(@user_attrs)

      {:ok, token1, _claims} = Token.encode_and_sign(user, %{}, ttl: {0, :second})
      {:ok, token2, _claims} = Token.encode_and_sign(user, %{}, ttl: {1, :minute})
      :timer.sleep(1000) # to make sure first token expires

      # insert some sessions and make sure it is removed after the check:
      Accounts.create_or_update_session(%{
        user_id: user.id,
        device_id: "device 1",
        platform_id: "platform 1",
        token: token1})

      Accounts.create_or_update_session(%{
        user_id: user.id,
        device_id: "device 2",
        platform_id: "platform 2",
        token: token2})

      num_deleted = CleanupStaleSessions.cleanup_sessions()
      assert 1 = num_deleted

      sessions = Session |> Repo.all
      assert Enum.count(sessions) == 1
      session = List.first(sessions)
      assert session.user_id == user.id
      assert session.device_id == "device 2"
      assert session.platform_id == "platform 2"
      assert session.token == token2
    end
  end
end
