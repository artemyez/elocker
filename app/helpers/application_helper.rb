# frozen_string_literal: true

module ApplicationHelper
  def user_context(user)
    return 'Platform support' if user.support?
    return 'No team assigned' unless user.team

    "#{user.team.company.name} · #{user.team.name}"
  end

  def user_option_label(user)
    "#{user.name} — #{user_context(user)}"
  end

  def action_time(time)
    zoned_time = time.in_time_zone
    tag.time(zoned_time.strftime('%d %b %Y, %H:%M:%S %Z'), datetime: zoned_time.iso8601)
  end

  def locker_state_badge(locker)
    colors = locker.open? ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-700'
    tag.span(locker.state.capitalize, class: "inline-flex rounded-full px-3 py-1 text-xs font-semibold #{colors}")
  end
end
