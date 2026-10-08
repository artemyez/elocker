# frozen_string_literal: true

class LockersController < ApplicationController
  before_action :require_current_user
  before_action :set_locker, only: %i[show open close]

  def index
    @lockers = accessible_lockers.includes(:company).order(:id)
  end

  def show
    @locker_actions = @locker.locker_actions
                             .includes(user: :team)
                             .order(occurred_at: :desc, id: :desc)
  end

  def open
    respond_to_operation { @locker.open(current_user) }
  end

  def close
    respond_to_operation { @locker.close(current_user) }
  end

  private

  def set_locker
    @locker = accessible_lockers.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to lockers_path, alert: 'Locker not found or unavailable.', status: :see_other
  end

  def respond_to_operation
    changed = yield
    notice = changed ? "Locker is now #{@locker.state}." : "Locker is already #{@locker.state}."
    redirect_to locker_path(@locker), notice: notice, status: :see_other
  rescue ActiveRecord::RecordInvalid
    redirect_to locker_path(@locker), alert: 'Could not change locker state.', status: :see_other
  end
end
