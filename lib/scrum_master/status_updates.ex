defmodule ScrumMaster.StatusUpdates do
  @moduledoc """
  The StatusUpdates context.
  """

  import Ecto.Query, warn: false
  alias ScrumMaster.Repo

  alias ScrumMaster.StatusUpdates.StatusUpdate

  @doc """
  Returns the list of status_updates.

  ## Examples

      iex> list_status_updates()
      [%StatusUpdate{}, ...]

  """
  def list_status_updates do
    Repo.all(StatusUpdate)
  end

  @doc """
  Gets a single status_update.

  Raises `Ecto.NoResultsError` if the Status update does not exist.

  ## Examples

      iex> get_status_update!(123)
      %StatusUpdate{}

      iex> get_status_update!(456)
      ** (Ecto.NoResultsError)

  """
  def get_status_update!(id), do: Repo.get!(StatusUpdate, id)

  @doc """
  Creates a status_update.

  ## Examples

      iex> create_status_update(%{field: value})
      {:ok, %StatusUpdate{}}

      iex> create_status_update(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_status_update(attrs \\ %{}) do
    %StatusUpdate{}
    |> StatusUpdate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a status_update.

  ## Examples

      iex> update_status_update(status_update, %{field: new_value})
      {:ok, %StatusUpdate{}}

      iex> update_status_update(status_update, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_status_update(%StatusUpdate{} = status_update, attrs) do
    status_update
    |> StatusUpdate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a status_update.

  ## Examples

      iex> delete_status_update(status_update)
      {:ok, %StatusUpdate{}}

      iex> delete_status_update(status_update)
      {:error, %Ecto.Changeset{}}

  """
  def delete_status_update(%StatusUpdate{} = status_update) do
    Repo.delete(status_update)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking status_update changes.

  ## Examples

      iex> change_status_update(status_update)
      %Ecto.Changeset{data: %StatusUpdate{}}

  """
  def change_status_update(%StatusUpdate{} = status_update, attrs \\ %{}) do
    StatusUpdate.changeset(status_update, attrs)
  end
end
