# frozen_string_literal: true

# Rebuilds all demo data, including action history, on every run.
return if Rails.env.test?

ActiveRecord::Base.transaction do # rubocop:disable Metrics/BlockLength
  [LockerAction, TeamLocker, User, Locker, Team, Company].each(&:delete_all)

  # 1. Companies & Lockers
  companies_data = {
    'Amazon' => {
      'BER-01' => 'Berlin warehouse, gate 1',
      'BER-02' => 'Berlin warehouse, gate 2'
    },
    'DPD' => {
      'HAM-01' => 'Hamburg depot, entrance'
    }
  }

  companies = {}
  lockers = {}

  companies_data.each do |company_name, locker_list|
    company = Company.create!(name: company_name)
    companies[company_name] = company

    locker_list.each do |identifier, location|
      lockers[identifier] = company.lockers.create!(
        name: identifier,
        identifier: identifier,
        location: location
      )
    end
  end

  amazon = companies.fetch('Amazon')
  dpd = companies.fetch('DPD')

  # 2. Teams & Assignments
  teams_data = {
    [amazon, 'Amazon Team A'] => %w[BER-01],
    [amazon, 'Amazon Team B'] => %w[BER-02],
    [dpd, 'DPD Shared Crew'] => %w[HAM-01]
  }

  teams = {}
  teams_data.each do |(company, team_name), locker_identifiers|
    assigned_lockers = locker_identifiers.map { |id| lockers.fetch(id) }
    teams[team_name] = company.teams.create!(name: team_name, lockers: assigned_lockers)
  end

  # 3. Users
  users = {}
  [
    ['Anna', 'anna@example.com', 'Amazon Team A'],
    ['Ben', 'ben@example.com', 'Amazon Team B'],
    ['Clara', 'clara@example.com', 'DPD Shared Crew'],
    ['David', 'david@example.com', 'DPD Shared Crew']
  ].each do |name, email, team_name|
    users[name] = User.create!(
      name: name,
      email: email,
      role: 'employee',
      team: teams.fetch(team_name)
    )
  end

  # Support role
  users['Sam'] = User.create!(name: 'Sam', email: 'sam@elocker.example.com', role: 'support')

  # 4. Action History & Initial States
  seeded_at = Time.current
  [
    ['BER-01', 'Anna', 'open', 10.hours],
    ['BER-01', 'Anna', 'close', 9.hours],
    ['HAM-01', 'Clara', 'open', 5.hours],
    ['HAM-01', 'David', 'close', 4.hours]
  ].each do |locker_name, user_name, action, ago|
    locker = lockers.fetch(locker_name)
    occurred_at = seeded_at - ago

    locker.locker_actions.create!(
      user: users.fetch(user_name),
      action: action,
      occurred_at: occurred_at,
      created_at: occurred_at
    )
    locker.update!(state: action == 'open' ? 'open' : 'closed')
  end
end

puts "Seeded #{Company.count} companies, #{Team.count} teams, #{Locker.count} lockers, " \
     "#{User.count} users, #{LockerAction.count} actions."
