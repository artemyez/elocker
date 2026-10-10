# frozen_string_literal: true

module RequestHelpers
  def select_user(user)
    patch current_user_path, params: { user_id: user.id }
    expect(response).to redirect_to(lockers_path)
    follow_redirect!
  end
end
