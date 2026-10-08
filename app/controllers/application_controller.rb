class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protect_from_forgery with: :exception

  helper_method :current_user, :available_users

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:current_user_id]) || User.order(:id).first
    session[:current_user_id] = @current_user&.id
    @current_user
  end

  def available_users
    @available_users ||= User.includes(team: :company).order(:name, :id)
  end

  def require_current_user
    return if current_user

    render plain: "No users are available. Create the demo users to continue.", status: :service_unavailable
  end

  def accessible_lockers
    LockerPolicy.new(current_user).scope
  end
end
