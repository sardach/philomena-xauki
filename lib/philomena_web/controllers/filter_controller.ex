defmodule PhilomenaWeb.FilterController do
  use PhilomenaWeb, :controller

  alias Philomena.{Filters, Filters.Filter, Tags.Tag}
  alias Philomena.Schema.TagList
  alias Philomena.Repo
  import Ecto.Query

  plug :load_and_authorize_resource, model: Filter, except: [:index], preload: :user
  plug PhilomenaWeb.RequireUserPlug when action not in [:index, :show]

  def index(conn, _params) do
    user = conn.assigns.current_user

    my_filters =
      if user do
        Filter
        |> where(user_id: ^user.id)
        |> preload(:user)
        |> Repo.all()
      else
        []
      end

    system_filters =
      Filter
      |> where(system: true)
      |> preload(:user)
      |> Repo.all()

    render(conn, "index.html",
      title: "Filtros",
      my_filters: my_filters,
      system_filters: system_filters
    )
  end

  def show(conn, _params) do
    filter = conn.assigns.filter

    spoilered_tags =
      Tag
      |> where([t], t.id in ^filter.spoilered_tag_ids)
      |> order_by(asc: :name)
      |> Repo.all()

    hidden_tags =
      Tag
      |> where([t], t.id in ^filter.hidden_tag_ids)
      |> order_by(asc: :name)
      |> Repo.all()

    render(conn, "show.html",
      title: "Mostrando Filtro",
      filter: filter,
      spoilered_tags: spoilered_tags,
      hidden_tags: hidden_tags
    )
  end

  def new(conn, %{"based_on" => filter_id}) do
    # The last line here is a hack to get Ecto to save a new
    # model instead of trying to update the existing one.
    filter =
      Filter
      |> where(id: ^filter_id)
      |> where(
        [f],
        f.system == true or f.public == true or f.user_id == ^conn.assigns.current_user.id
      )
      |> Repo.one()
      |> Kernel.||(%Filter{})
      |> TagList.assign_tag_list(:spoilered_tag_ids, :spoilered_tag_list)
      |> TagList.assign_tag_list(:hidden_tag_ids, :hidden_tag_list)
      |> Map.put(:__meta__, %Ecto.Schema.Metadata{
        state: :built,
        source: "filters",
        schema: Filter
      })

    changeset = Filters.change_filter(filter)
    render(conn, "new.html", title: "New Filter", changeset: %{changeset | action: nil})
  end

  def new(conn, _params) do
    changeset = Filters.change_filter(%Filter{})
    render(conn, "new.html", title: "New Filter", changeset: changeset)
  end

  def create(conn, %{"filter" => filter_params}) do
    case Filters.create_filter(conn.assigns.current_user, filter_params) do
      {:ok, filter} ->
        conn
        |> put_flash(:info, "Filter created successfully.")
        |> redirect(to: Routes.filter_path(conn, :show, filter))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    filter =
      conn.assigns.filter
      |> TagList.assign_tag_list(:spoilered_tag_ids, :spoilered_tag_list)
      |> TagList.assign_tag_list(:hidden_tag_ids, :hidden_tag_list)

    changeset = Filters.change_filter(filter)

    render(conn, "edit.html", title: "Editing Filter", filter: filter, changeset: changeset)
  end

  def update(conn, %{"filter" => filter_params}) do
    filter = conn.assigns.filter

    case Filters.update_filter(filter, filter_params) do
      {:ok, filter} ->
        conn
        |> put_flash(:info, "Filter updated successfully.")
        |> redirect(to: Routes.filter_path(conn, :show, filter))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", filter: filter, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    filter = conn.assigns.filter

    case Filters.delete_filter(filter) do
      {:ok, _filter} ->
        conn
        |> put_flash(:info, "Filter deleted successfully.")
        |> redirect(to: Routes.filter_path(conn, :index))

      _error ->
        conn
        |> put_flash(:error, "Filter is still in use, not deleted.")
        |> redirect(to: Routes.filter_path(conn, :show, filter))
    end
  end
end
