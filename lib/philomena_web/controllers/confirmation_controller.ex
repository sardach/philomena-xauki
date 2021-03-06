defmodule PhilomenaWeb.ConfirmationController do
  use PhilomenaWeb, :controller

  alias Philomena.Users

  plug PhilomenaWeb.CaptchaPlug
  plug PhilomenaWeb.CheckCaptchaPlug when action in [:create]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Users.get_user_by_email(email) do
      Users.deliver_user_confirmation_instructions(
        user,
        &Routes.confirmation_url(conn, :show, &1)
      )
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "Si tu email esta en nuestro sistema y no ha sido confirmado, " <>
        "recibiras un email con instrucciones en breve."
    )
    |> redirect(to: "/")
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def show(conn, %{"id" => token}) do
    case Users.confirm_user(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Cuenta verificada satisfactoriamente")
        |> redirect(to: "/")

      :error ->
        conn
        |> put_flash(:error, "El enlace de confirmación expiró")
        |> redirect(to: "/")
    end
  end
end
