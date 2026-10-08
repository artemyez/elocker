# frozen_string_literal: true

class LockerPolicy
  def initialize(user)
    @user = user
  end

  def scope
    return Locker.none unless user
    return Locker.all if user.support?
    return Locker.none unless user.employee?

    team = user.team
    return Locker.none unless team

    team.lockers.where(company_id: team.company_id)
  end

  private

  attr_reader :user
end
