class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Cambiá tu contraseña de Rubípticos", to: user.email_address
  end
end
