# frozen_string_literal: true

class StartController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index info]

  def index
    redirect_to maps_path if current_user
  end

  def info; end

  def settings
    @user = current_user
  end
  def edit_profile
    @user = current_user
  end

  def update_profile
    @user = current_user
    sanitized_params = params.require(:user).permit(:email, :password, :id)
    sanitized_params.delete(:password) if sanitized_params[:password].blank?

    if current_user.update(sanitized_params)
      redirect_to root_path, notice: 'Your profile was successfully updated.'
    else
      render :edit_profile, notice: 'Your profile could not be updated.'
    end
  end
end
