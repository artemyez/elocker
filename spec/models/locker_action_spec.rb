# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LockerAction do
  describe 'associations' do
    it { is_expected.to belong_to(:locker) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:occurred_at) }

    it 'defines action enum with string mapping' do
      expect(subject).to define_enum_for(:action)
        .with_values(open: 'open', close: 'close')
        .backed_by_column_of_type(:string)
    end
  end

  describe 'action validation' do
    context 'with invalid values' do
      it 'is invalid when action is nil' do
        locker_action = build(:locker_action, action: nil)

        expect(locker_action).not_to be_valid
        expect(locker_action.errors[:action]).to be_present
      end

      it 'is invalid with unknown enum value' do
        locker_action = build(:locker_action, action: 'invalid')

        expect(locker_action).not_to be_valid
        expect(locker_action.errors[:action]).to include('is not included in the list')
      end
    end

    context 'with valid values' do
      it 'allows open action' do
        expect(build(:locker_action, action: 'open')).to be_valid
      end

      it 'allows close action' do
        expect(build(:locker_action, action: 'close')).to be_valid
      end
    end
  end
end
