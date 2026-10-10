# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamLocker do
  describe 'associations' do
    it { is_expected.to belong_to(:team) }
    it { is_expected.to belong_to(:locker) }
  end

  describe 'validations' do
    subject(:team_locker) { build(:team_locker, team: team, locker: locker) }

    let(:company) { create(:company) }
    let(:team) { create(:team, company: company) }
    let(:locker) { create(:locker, company: company) }

    it 'validates uniqueness of locker scoped to team' do
      create(:team_locker, team: team, locker: locker)
      expect(team_locker).not_to be_valid
      expect(team_locker.errors[:locker]).to include('has already been taken')
    end

    describe '#same_company' do
      context 'when team and locker belong to the same company' do
        it 'is valid' do
          expect(team_locker).to be_valid
        end
      end

      context 'when team and locker belong to different companies' do
        let(:other_company) { create(:company) }
        let(:locker) { create(:locker, company: other_company) }

        it 'is invalid and adds a multi-tenant error' do
          expect(team_locker).not_to be_valid
          expect(team_locker.errors[:locker]).to include('must belong to the same company as the team')
        end
      end
    end
  end

  describe 'database constraints' do
    let(:team_locker) { create(:team_locker) }

    it 'rejects duplicate assignments' do
      duplicate_assignment = build(:team_locker, team: team_locker.team, locker: team_locker.locker)

      expect { duplicate_assignment.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'shared access' do
    let(:assignment) { create(:team_locker) }

    it 'allows another team in the same company to share the locker' do
      other_team = create(:team, company: assignment.team.company)
      expect(create(:team_locker, team: other_team, locker: assignment.locker)).to be_persisted
    end
  end
end
