# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LockerPolicy do
  subject(:policy) { described_class.new(user) }

  describe '#scope' do
    subject(:scope) { policy.scope }

    let(:company) { create(:company) }
    let(:other_company) { create(:company) }

    let(:team) { create(:team, company: company) }
    let(:other_team) { create(:team, company: company) }

    let(:team_locker) { create(:locker, company: company) }
    let(:other_team_locker) { create(:locker, company: company) }
    let(:other_company_locker) { create(:locker, company: other_company) }

    before do
      team_locker
      other_team_locker
      other_company_locker
      create(:team_locker, team: team, locker: team_locker)
      create(:team_locker, team: other_team, locker: other_team_locker)
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'returns no lockers' do
        expect(scope).to be_empty
      end
    end

    context 'when user is support' do
      let(:user) { build(:user, :support) }

      it 'returns all lockers across all companies' do
        expect(scope).to match_array([team_locker, other_team_locker, other_company_locker])
      end
    end

    context 'when user is an employee' do
      context 'and user has no team' do
        let(:user) { create(:user, :employee, team: nil) }

        it 'returns no lockers' do
          expect(scope).to be_empty
        end
      end

      context 'and user belongs to a team' do
        let(:user) { create(:user, :employee, team: team) }

        it 'returns only lockers assigned to user team' do
          expect(scope).to contain_exactly(team_locker)
        end

        it 'does not return lockers of other teams in the same company' do
          expect(scope).not_to include(other_team_locker)
        end

        it 'does not return lockers from other companies' do
          expect(scope).not_to include(other_company_locker)
        end
      end
    end

    context 'when the role is unsupported' do
      let(:user) { build(:user, role: 'administrator') }

      it 'returns no lockers' do
        expect(scope).to be_empty
      end
    end

    context 'when the employee team has no assignments' do
      let(:user) { create(:user) }

      it 'returns no lockers' do
        expect(scope).to be_empty
      end
    end

    context 'when a locker is shared by teams in the same company' do
      let(:user) { create(:user, team: team) }

      before { create(:team_locker, team: team, locker: other_team_locker) }

      it 'includes the shared locker exactly once' do
        expect(scope).to contain_exactly(team_locker, other_team_locker)
      end

      it 'remains a chainable relation' do
        expect(scope.where(id: other_team_locker.id)).to contain_exactly(other_team_locker)
      end
    end

    context 'when an assignment is revoked' do
      let(:user) { create(:user, team: team) }

      before { team.team_lockers.destroy_all }

      it 'excludes the previously assigned locker' do
        expect(scope).to be_empty
      end
    end

    context 'when a cross-company assignment bypasses validation' do
      let(:user) { create(:user, team: team) }

      before { TeamLocker.insert!({ team_id: team.id, locker_id: other_company_locker.id }) }

      it 'still excludes the other company locker' do
        expect(scope).to contain_exactly(team_locker)
      end
    end
  end
end
