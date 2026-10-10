# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locker do
  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:team_lockers).dependent(:destroy) }
    it { is_expected.to have_many(:teams).through(:team_lockers) }
    it { is_expected.to have_many(:locker_actions).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject(:locker) { build(:locker, company: company) }

    let(:company) { create(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:location) }

    it 'validates uniqueness of name scoped to company' do
      expect(locker).to validate_uniqueness_of(:name).scoped_to(:company_id)
    end

    it 'validates uniqueness of identifier scoped to company' do
      expect(locker).to validate_uniqueness_of(:identifier).scoped_to(:company_id)
    end

    it 'defaults to closed state' do
      expect(described_class.new).to be_closed
    end

    it 'defines state enum with string mapping' do
      expect(subject).to define_enum_for(:state)
        .with_values(open: 'open', closed: 'closed')
        .backed_by_column_of_type(:string)
    end

    context 'when state is invalid' do
      it 'is invalid when state is nil' do
        locker.state = nil
        expect(locker).not_to be_valid
        expect(locker.errors[:state]).to be_present
      end

      it 'is invalid when state is unknown' do
        locker.state = 'unknown'
        expect(locker).not_to be_valid
        expect(locker.errors[:state]).to be_present
      end
    end
  end

  describe 'state transitions' do
    let(:company) { create(:company) }
    let(:user) { create(:user, company: company, team: create(:team, company: company)) }

    describe '#open' do
      context 'when locker is closed' do
        let(:locker) { create(:locker, state: 'closed', company: company) }

        it 'changes state to open and records the action with timestamp' do
          travel_to Time.utc(2026, 2, 1, 12) do
            expect { locker.open(user) }
              .to change(locker, :state).from('closed').to('open')
              .and change(LockerAction, :count).by(1)

            action = locker.locker_actions.last
            expect(action.action).to eq('open')
            expect(action.user).to eq(user)
            expect(action.occurred_at).to eq(Time.current)
          end
        end

        it 'returns true' do
          expect(locker.open(user)).to be true
        end

        context 'when action creation fails' do
          it 'rolls back the state update and action' do
            expect { locker.open(nil) }.to raise_error(ActiveRecord::RecordInvalid)
            expect(locker.reload.state).to eq('closed')
            expect(LockerAction.count).to be_zero
          end
        end
      end

      context 'when locker is already open' do
        let(:locker) { create(:locker, state: 'open', company: company) }

        it 'does not change state or create action and returns false' do
          expect { locker.open(user) }.not_to change(locker, :state)
          expect { locker.open(user) }.not_to change(LockerAction, :count)
          expect(locker.open(user)).to be false
        end
      end
    end

    describe '#close' do
      context 'when locker is open' do
        let(:locker) { create(:locker, state: 'open', company: company) }

        it 'changes state to closed and records the action with timestamp' do
          travel_to Time.utc(2026, 2, 1, 12) do
            expect { locker.close(user) }
              .to change(locker, :state).from('open').to('closed')
              .and change(LockerAction, :count).by(1)

            action = locker.locker_actions.last
            expect(action.action).to eq('close')
            expect(action.user).to eq(user)
            expect(action.occurred_at).to eq(Time.current)
          end
        end

        it 'returns true' do
          expect(locker.close(user)).to be true
        end

        context 'when action creation fails' do
          it 'rolls back the state update and action' do
            expect { locker.close(nil) }.to raise_error(ActiveRecord::RecordInvalid)
            expect(locker.reload.state).to eq('open')
            expect(LockerAction.count).to be_zero
          end
        end
      end

      context 'when locker is already closed' do
        let(:locker) { create(:locker, state: 'closed', company: company) }

        it 'does not change state or create action and returns false' do
          expect { locker.close(user) }.not_to change(locker, :state)
          expect { locker.close(user) }.not_to change(LockerAction, :count)
          expect(locker.close(user)).to be false
        end
      end
    end
  end

  describe 'database constraints' do
    let(:locker) { create(:locker) }

    it 'rejects duplicate names within the same company' do
      duplicate = build(:locker, company: locker.company, name: locker.name)
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'rejects duplicate identifiers within the same company' do
      duplicate = build(:locker, company: locker.company, identifier: locker.identifier)
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows matching names and identifiers in another company' do
      other_company = create(:company)
      duplicate = build(:locker, company: other_company, name: locker.name, identifier: locker.identifier)

      expect(duplicate.save(validate: false)).to be true
    end
  end
end
