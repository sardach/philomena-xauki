defmodule PhilomenaWeb.ConversationController do
  use PhilomenaWeb, :controller

  alias PhilomenaWeb.NotificationCountPlug
  alias Philomena.{Conversations, Conversations.Conversation, Conversations.Message}
  alias PhilomenaWeb.TextileRenderer
  alias Philomena.Repo
  import Ecto.Query

  plug PhilomenaWeb.FilterBannedUsersPlug when action in [:new, :create]

  plug PhilomenaWeb.LimitPlug,
       [time: 60, error: "Solo puedes iniciar una conversación por minuto"]
       when action in [:create]

  plug :load_and_authorize_resource,
    model: Conversation,
    id_field: "slug",
    only: :show,
    preload: [:to, :from]

  def index(conn, %{"with" => partner}) do
    user = conn.assigns.current_user

    Conversation
    |> where(
      [c],
      (c.from_id == ^user.id and c.to_id == ^partner and not c.from_hidden) or
        (c.to_id == ^user.id and c.from_id == ^partner and not c.to_hidden)
    )
    |> load_conversations(conn)
  end

  def index(conn, _params) do
    user = conn.assigns.current_user

    Conversation
    |> where(
      [c],
      (c.from_id == ^user.id and not c.from_hidden) or (c.to_id == ^user.id and not c.to_hidden)
    )
    |> load_conversations(conn)
  end

  defp load_conversations(queryable, conn) do
    conversations =
      queryable
      |> join(
        :inner_lateral,
        [c],
        _ in fragment("SELECT COUNT(*) FROM messages m WHERE m.conversation_id = ?", c.id)
      )
      |> order_by(desc: :last_message_at)
      |> preload([:to, :from])
      |> select([c, cnt], {c, cnt.count})
      |> Repo.paginate(conn.assigns.scrivener)

    render(conn, "index.html", title: "Conversaciones", conversations: conversations)
  end

  def show(conn, _params) do
    conversation = conn.assigns.conversation
    user = conn.assigns.current_user

    messages =
      Message
      |> where(conversation_id: ^conversation.id)
      |> order_by(asc: :created_at)
      |> preload([:from])
      |> Repo.paginate(conn.assigns.scrivener)

    rendered =
      messages.entries
      |> TextileRenderer.render_collection(conn)

    messages = %{messages | entries: Enum.zip(messages.entries, rendered)}

    changeset =
      %Message{}
      |> Conversations.change_message()

    conversation
    |> Conversations.mark_conversation_read(user)

    # Update the conversation ticker in the header
    conn = NotificationCountPlug.call(conn)

    render(conn, "show.html",
      title: "Mostrando Conversación",
      conversation: conversation,
      messages: messages,
      changeset: changeset
    )
  end

  def new(conn, params) do
    changeset =
      %Conversation{recipient: params["recipient"], messages: [%Message{}]}
      |> Conversations.change_conversation()

    render(conn, "new.html", title: "Nueva Conversación", changeset: changeset)
  end

  def create(conn, %{"conversation" => conversation_params}) do
    user = conn.assigns.current_user

    case Conversations.create_conversation(user, conversation_params) do
      {:ok, conversation} ->
        conn
        |> put_flash(:info, "Conversación iniciada sin problema.")
        |> redirect(to: Routes.conversation_path(conn, :show, conversation))

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end
end
