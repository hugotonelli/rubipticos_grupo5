require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "por defecto es editor de puntajes y está activo" do
    user = User.new
    assert user.editor_puntajes?
    assert user.activo?
  end

  test "rechaza un rol inexistente" do
    user = users(:one)
    user.rol = "superusuario"
    assert_not user.valid?
  end
end
