# frozen_string_literal: true

class LockerActionsController < ApplicationController
  before_action :require_current_user

  def index
    @locker_actions = LockerAction.where(locker_id: accessible_lockers.select(:id))
                                  .includes(:user, locker: :company)
                                  .order(occurred_at: :desc, id: :desc)
  end
end
