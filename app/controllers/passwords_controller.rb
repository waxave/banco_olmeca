# frozen_string_literal: true

# Controller for managing user password changes (edit/update)
class PasswordsController < ApplicationController
  before_action :logged_in!

  def edit
    @account = current_user
  end

  def update
    @account = current_user
    if @account.update(password_params)
      redirect_to root_path, notice: 'Contraseña actualizada correctamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:account).permit(:password, :password_confirmation)
  end
end
