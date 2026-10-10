# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team do
  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:team_lockers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:lockers).through(:team_lockers) }
  end

  describe 'validations' do
    subject(:team) { build(:team, company: company) }

    let(:company) { create(:company) }

    it { is_expected.to validate_presence_of(:name) }

    it 'validates uniqueness of name scoped to company' do
      expect(team).to validate_uniqueness_of(:name).scoped_to(:company_id)
    end
  end

  describe 'deletion restrictions' do
    let(:team) { create(:team) }

    context 'when team has associated users' do
      before { create(:user, team: team) }

      it 'does not destroy the team and adds an error' do
        expect(team.destroy).to be_falsey
        expect(team.errors[:base]).to include('Cannot delete record because dependent users exist')
      end
    end

    context 'when team has associated team_lockers' do
      before { create(:team_locker, team: team) }

      it 'does not destroy the team and adds an error' do
        expect(team.destroy).to be_falsey
        expect(team.errors[:base]).to include('Cannot delete record because dependent team lockers exist')
      end
    end

    context 'when team has no dependencies' do
      it 'destroys the team successfully' do
        team
        expect { team.destroy }.to change(described_class, :count).by(-1)
      end
    end
  end

  describe 'database constraints' do
    let(:company) { create(:company) }
    let(:company2) { create(:company) }
    let(:team) { create(:team, name: 'Team1', company: company) }

    before { team }

    it 'rejects duplicate names within the same company at the DB level' do
      duplicate_team = build(:team, name: 'Team1', company: company)

      expect { duplicate_team.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'rejects duplicate names within a company at the model level' do
      duplicate_team = build(:team, name: 'Team1', company: company)

      expect(duplicate_team).not_to be_valid
      expect(duplicate_team.errors[:name]).to include('has already been taken')
    end

    it 'allows the same name in another company' do
      expect(build(:team, name: 'Team1', company: company2)).to be_valid
    end
  end
end
