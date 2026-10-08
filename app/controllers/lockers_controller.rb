class LockersController < ApplicationController
  before_action :require_current_user
  before_action :set_locker, only: [ :show, :open, :close ]

  def index
    @lockers = accessible_lockers.includes(:company).order(:id)
  end

  def show
    @locker_actions = @locker.locker_actions
                             .includes(user: :team)
                             .order(occurred_at: :desc, id: :desc)
  end

  def open
    process_action(@locker.open(current_user))
  end

  def close
    process_action(@locker.close(current_user))
  end

  private

  def set_locker
    @locker = accessible_lockers.find(params[:id])
  end

  def process_action(changed)
    notice = changed ? "Locker is now #{@locker.state}." : "Locker is already #{@locker.state}."
    redirect_to locker_path(@locker), notice: notice, status: :see_other
  rescue ActiveRecord::RecordInvalid
    redirect_to locker_path(@locker), alert: "Could not change locker state.", status: :see_other
  end
end
