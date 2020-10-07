defmodule PhilomenaWeb.PasswordController do
  use PhilomenaWeb, :controller

  alias Philomena.Users

  plug PhilomenaWeb.CaptchaPlug when action in [:new, :create]
  plug PhilomenaWeb.CheckCaptchaPlug when action in [:create]
  plug PhilomenaWeb.CompromisedPasswordCheckPlug when action in [:update]
  plug :get_user_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Users.get_user_by_email(email) do
      Users.deliver_user_reset_password_instructions(
        user,
        &Routes.password_url(conn, :edit, &1)
      )
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "Si tu email esta en nuestro sistema, recibiras un mensaje con instrucciones para cambiar tu contraseña en breve"
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: Users.change_user_password(conn.assigns.user))
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def update(conn, %{"user" => user_params}) do
    case Users.reset_user_password(conn.assigns.user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Contraseña cambiada sin problema")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_user_by_reset_password_token(conn, _opts) do
    %{"id" => token} = conn.params

    if user = Users.get_user_by_reset_password_token(token) do
      conn |> assign(:user, user) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "El enlace expiró")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
