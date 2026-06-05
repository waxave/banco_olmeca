# frozen_string_literal: true

# Controller for managing user profile (edit/update)
class ProfilesController < ApplicationController
  before_action :logged_in!

  def edit
    @account = current_user
  end

  def update
    @account = current_user
    if @account.update(profile_params)
      redirect_to root_path, notice: 'Perfil actualizado correctamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:account).permit(:name, :email, :phone)
  end
end
