defmodule Musehackers.VersionControl do
  @moduledoc """
  The VersionControl context.
  """

  import Ecto.Query, warn: false
  alias Musehackers.Repo

  alias Musehackers.VersionControl.Project
  alias Musehackers.VersionControl.Revision

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  def get_project_heads(id) do
    query = from r in Revision,
          left_join: child in Revision, on: r.id == child.parent_id,
          where: r.project_id == ^id and is_nil(child.parent_id),
          select: struct(r, [:id, :message, :hash, :project_id, :parent_id])
    {:ok, Repo.all(query)}
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    Project.changeset(project, %{})
  end

  alias Musehackers.VersionControl.Revision

  @doc """
  Returns the list of revisions.

  ## Examples

      iex> list_revisions()
      [%Revision{}, ...]

  """
  def list_revisions do
    Repo.all(Revision)
  end

  @doc """
  Gets a single revision.

  Raises `Ecto.NoResultsError` if the Revision does not exist.

  ## Examples

      iex> get_revision!(123)
      %Revision{}

      iex> get_revision!(456)
      ** (Ecto.NoResultsError)

  """
  def get_revision!(id), do: Repo.get!(Revision, id)

  def get_revision_summary(id) do
    query = from r in Revision,
      where: r.id == ^id,
      select: struct(r, [:id, :parent_id, :message, :hash])
    case Repo.one(query) do
      nil -> {:error, :revision_not_found}
      revision -> {:ok, revision}
    end
  end

  def get_revision_data(id) do
    query = from r in Revision,
      where: r.id == ^id,
      select: struct(r, [:id, :hash, :data])
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
