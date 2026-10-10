# frozen_string_literal: true

class CurrentUsersController < ApplicationController
  def update
    user = User.find_by(id: params[:user_id])

    if user
      session[:current_user_id] = user.id
      redirect_to lockers_path, notice: "Switched to #{user.name}", status: :see_other
    else
      redirect_to lockers_path, alert: 'User not found', status: :see_other
    end
  end
end
