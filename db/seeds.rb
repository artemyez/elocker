# frozen_string_literal: true

# Rebuilds all demo data, including action history, on every run.
ActiveRecord::Base.transaction do # rubocop:disable Metrics/BlockLength
  [LockerAction, TeamLocker, User, Locker, Team, Company].each(&:delete_all)

  amazon = Company.create!(name: 'Amazon')
  dpd = Company.create!(name: 'DPD')

  lockers = {}
  {
    amazon => { 'BER-01' => 'Berlin warehouse, gate 1', 'BER-02' => 'Berlin warehouse, gate 2',
                'BER-03' => 'Berlin warehouse, gate 3', 'MUC-01' => 'Munich, Marienplatz',
                'MUC-02' => 'Munich, Hauptbahnhof', 'MUC-03' => 'Munich, Ostbahnhof (not yet assigned)' },
    dpd => { 'HAM-01' => 'Hamburg depot, entrance', 'HAM-02' => 'Hamburg, Altona',
             'CGN-01' => 'Cologne, Deutz' }
  }.each do |company, list|
    list.each do |name, location|
      lockers[name] = company.lockers.create!(name: name, identifier: name, location: location)
    end
  end

  # Morning and night shift share BER-02; only support sees unassigned MUC-03.
  teams = {
    [amazon, 'Berlin Morning Shift'] => %w[BER-01 BER-02],
    [amazon, 'Berlin Night Shift'] => %w[BER-02 BER-03],
    [amazon, 'Munich Crew'] => %w[MUC-01 MUC-02],
    [dpd, 'Hamburg Crew'] => %w[HAM-01 HAM-02],
    [dpd, 'Cologne Crew'] => %w[CGN-01]
  }.to_h do |(company, name), locker_names|
    [name, company.teams.create!(name: name, lockers: lockers.values_at(*locker_names))]
  end

  users = {
    'Anna' => 'Berlin Morning Shift', 'Ben' => 'Berlin Night Shift', 'Clara' => 'Munich Crew',
    'David' => 'Hamburg Crew', 'Eva' => 'Cologne Crew'
  }.to_h do |name, team|
    [name, User.create!(name: name, email: "#{name.downcase}@example.com", role: 'employee', team: teams.fetch(team))]
  end
  users['Sam'] = User.create!(name: 'Sam', email: 'sam@elocker.example.com', role: 'support')

  seeded_at = Time.current
  [
    ['BER-01', 'Anna', 'open', 50.hours],
    ['BER-01', 'Anna', 'close', 49.hours],
    ['BER-02', 'Ben', 'open', 30.hours],
    ['BER-02', 'Anna', 'close', 26.hours],
    ['MUC-01', 'Clara', 'open', 20.hours],
    ['HAM-01', 'David', 'open', 10.hours],
    ['HAM-01', 'Sam', 'close', 9.hours],
    ['CGN-01', 'Eva', 'open', 2.hours]
  ].each do |locker_name, user_name, action, ago|
    locker = lockers.fetch(locker_name)
    occurred_at = seeded_at - ago
    locker.locker_actions.create!(user: users.fetch(user_name), action: action, occurred_at: occurred_at,
                                  created_at: occurred_at)
    locker.update!(state: action == 'open' ? 'open' : 'closed')
  end
end

puts "Seeded #{Company.count} companies, #{Team.count} teams, #{Locker.count} lockers, " \
     "#{User.count} users, #{LockerAction.count} actions."
