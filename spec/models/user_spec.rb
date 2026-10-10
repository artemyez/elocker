# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it { is_expected.to belong_to(:team).optional }
    it { is_expected.to have_one(:company).through(:team) }
  end

  describe 'validations' do
    subject(:user) { build(:user) }

    it 'defines the supported roles with string mapping' do
      expect(subject).to define_enum_for(:role)
        .with_values(employee: 'employee', support: 'support')
        .backed_by_column_of_type(:string)
    end

    context 'when role is invalid' do
      it 'is invalid when role is nil' do
        user.role = nil
        expect(user).not_to be_valid
        expect(user.errors[:role]).to be_present
      end

      it 'is invalid when role is unsupported' do
        user.role = 'administrator'
        expect(user).not_to be_valid
        expect(user.errors[:role]).to be_present
      end
    end

    context 'when the user is support' do
      subject(:user) { build(:user, :support) }

      it 'is valid without a team or company' do
        expect(user).to be_valid
        expect(user.team).to be_nil
        expect(user.company).to be_nil
      end
    end
  end

  describe 'database constraints' do
    let(:user) { create(:user) }

    it 'rejects duplicate emails on database level' do
      duplicate_user = build(:user, team: user.team, email: user.email)

      expect { duplicate_user.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
