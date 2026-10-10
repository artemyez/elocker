# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company do
  describe 'associations' do
    it { is_expected.to have_many(:teams).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:lockers).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'deletion restrictions' do
    let(:company) { create(:company) }

    context 'when company has associated teams' do
      before { create(:team, company: company) }

      it 'does not destroy the company and adds an error' do
        expect(company.destroy).to be_falsey
        expect(company.errors[:base]).to include('Cannot delete record because dependent teams exist')
      end
    end

    context 'when company has associated lockers' do
      before { create(:locker, company: company) }

      it 'does not destroy the company and adds an error' do
        expect(company.destroy).to be_falsey
        expect(company.errors[:base]).to include('Cannot delete record because dependent lockers exist')
      end
    end

    context 'when company has no dependencies' do
      it 'destroys the company successfully' do
        company
        expect { company.destroy }.to change(described_class, :count).by(-1)
      end
    end
  end
end
