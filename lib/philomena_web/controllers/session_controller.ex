defmodule PhilomenaWeb.SessionController do
  use PhilomenaWeb, :controller

  alias Philomena.Users
  alias PhilomenaWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    user =
      Users.get_user_by_email_and_password(
        email,
        password,
        &Routes.unlock_url(conn, :show, &1)
      )

    cond do
      not is_nil(user) and is_nil(user.confirmed_at) ->
        render(
          conn,
          "new.html",
          error_message: "Debes confirmar tu cuenta antes de Iniciar Sesión."
        )

      not is_nil(user) ->
        conn
        |> put_flash(:info, "Inicio de Sesión satisfactorio.")
        |> UserAuth.log_in_user(user, user_params)

      true ->
        render(
          conn,
          "new.html",
          error_message:
            "Contraseña o email erroneos. También podría estar bloqueada tu cuenta"
        )
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Adios. ¡No tardes en volver!")
    |> UserAuth.log_out_user()
  end
end
