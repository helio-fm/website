defmodule Db.VersionControl do
  @moduledoc """
  The VersionControl context.
  """

  import Ecto.Query, warn: false
  alias Db.Repo

  alias Db.VersionControl.Project
  alias Db.VersionControl.Revision
  alias Ecto.Multi

  @doc """
  Returns the list of projects for a given user id.
  """
  def get_projects_for_user(user_id) do
    query = from p in Project,
      where: p.author_id == ^user_id,
      select: p
    {:ok, Repo.all(query)}
  end

  @doc """
  Gets a single project for a given user.
  """
  def get_project(id, user_id) do
    query = from p in Project,
      where: p.id == ^id and p.author_id == ^user_id,
      select: p
    case Repo.one(query) do
      nil -> {:error, :project_not_found}
      project -> {:ok, project}
    end
  end

  @doc """
  Gets all revisions summary for a given project.
  """
  def get_revisions_summary(%Project{} = project) do
    query = from r in Revision,
      where: r.project_id == ^project.id,
      select: struct(r, [:id, :message, :timestamp, :parent_id])
    {:ok, Repo.all(query)}
  end

  @doc """
  Creates a project.

  ## Examples

      iex> update_project(%{field: value})
      {:ok, %Project{}}

      iex> update_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(attrs \\ %{}) do
    project = %Project{}
    cs = Project.changeset(project, attrs)
    title = Map.get(cs.changes, :title)
    slug = Map.get(cs.changes, :alias)
    head = Map.get(cs.changes, :head)
    on_conflict = [set: [title: title, alias: slug, head: head]]
    Repo.insert(cs, on_conflict: on_conflict, conflict_target: [:id])
  end

  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a project with all linked revisions.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    project_revisions = from r in Revision,
      where: r.project_id == ^project.id
    Multi.new
      |> Multi.delete_all(:revisions, project_revisions)
      |> Multi.delete(:project, project)
      |> Repo.transaction()
  end

  alias Db.VersionControl.Revision

  @doc """
  Gets a single revision which belongs to the project of a given user.
  """
  def get_revision(id, user_id) do
    query = from r in Revision,
      left_join: p in Project, on: p.id == r.project_id,
      where: r.id == ^id and p.author_id == ^user_id,
      select: r
    case Repo.one(query) do
      nil -> {:error, :revision_not_found}
      revision -> {:ok, revision}
    end
  end

  @doc """
  Creates a revision.

  ## Examples

      iex> create_revision(%{field: value})
      {:ok, %Revision{}}

      iex> create_revision(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_revision(attrs \\ %{}) do
    %Revision{}
    |> Revision.changeset(attrs)
    |> Repo.insert()
  end

  # defp transaction(f) do
  #   Repo.transaction fn ->
  #     Repo.query!("set transaction isolation level repeatable read;")
  #     f.()
  #   end
  # end

  @doc """
  Deletes a Revision.

  ## Examples

      iex> delete_revision(revision)
      {:ok, %Revision{}}

      iex> delete_revision(revision)
      {:error, %Ecto.Changeset{}}

  """
  def delete_revision(%Revision{} = revision) do
    Repo.delete(revision)
  end
end
