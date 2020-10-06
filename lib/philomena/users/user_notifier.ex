defmodule Philomena.Users.UserNotifier do
  alias Bamboo.Email
  alias Philomena.Mailer

  defp deliver(to, subject, body) do
    email =
      Email.new_email(
        to: to,
        from: mailer_address(),
        subject: subject,
        text_body: body
      )
      |> Mailer.deliver_later()

    {:ok, email}
  end

  defp mailer_address do
    Application.get_env(:philomena, :mailer_address)
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirma tu cuenta de Xauki", """

    ==============================

    ¡Hola! #{user.name},

    Puedes confirmar tu cuenta entrando al siguiente enlace:

    #{url}

    ==============================
    """)
  end

  @doc """
  Cambio de contraseña Xauki
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Instrucciones para resetear contraseña de Xauki", """

    ==============================

    ¡Hola! #{user.name},

    Puedes cambiar tu contraseña entrando al siguiente enlace:

    #{url}

    Si no solicitaste este cambio, ignora este correo.

    ==============================
    """)
  end

  @doc """
  Cambio de Coreeo Xauk
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Email update instructions for your account", """

    ==============================

    ¡Hola! #{user.name},

    Puedes cambiar tu correo entrando al siguiente enlace:

    #{url}

    Si no solicitaste este cambio, ignora este mensaje.

    ==============================
    """)
  end

  @doc """
  Insturcciones para desbloquear tu cuenta Xauki
  """
  def deliver_unlock_instructions(user, url) do
    deliver(user.email, "Unlock instructions for your account", """

    ==============================

    ¡Hola! #{user.name},

    Tu cuenta se bloqueo automaticamente debido a muchos intentos fallidos de entrada.

    Para desbloquearla, entra al siguiente enlace:

    #{url}

    ==============================
    """)
  end
end
