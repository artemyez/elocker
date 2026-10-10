# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LockerActionsController, type: :request do
  describe 'GET /actions' do
    let(:user) { create(:user) }

    before { select_user(user) }

    context 'when the user is an employee' do
      let(:locker) { create(:team_locker, team: user.team).locker }
      let(:other_team) { create(:team, company: user.company) }
      let(:colleague) { create(:user, team: other_team) }
      let(:support) { create(:user, :support) }
      let(:timestamp) { Time.utc(2026, 1, 5, 12) }

      let(:first_action) { create(:locker_action, locker: locker, user: user, occurred_at: timestamp - 1.hour) }
      let(:second_action) { create(:locker_action, :close, locker: locker, user: colleague, occurred_at: timestamp) }
      let(:third_action) { create(:locker_action, locker: locker, user: support, occurred_at: timestamp) }

      let(:inaccessible_locker) { create(:team_locker, team: other_team).locker }
      let(:inaccessible_action) do
        create(:locker_action, locker: inaccessible_locker, user: colleague, occurred_at: timestamp + 1.hour)
      end
      let(:support_unassigned_action) { create(:locker_action, user: support, occurred_at: timestamp + 2.hours) }

      before do
        create(:team_locker, team: other_team, locker: locker)

        first_action
        second_action
        third_action
        inaccessible_action
        support_unassigned_action
      end

      it 'assigns actions on accessible lockers only, ordered by occurred_at then id descending' do
        get locker_actions_path

        expect(response).to have_http_status(:ok)
        expect(assigns(:locker_actions)).to eq([third_action, second_action, first_action])
      end
    end

    context 'when the user is support' do
      let(:user) { create(:user, :support) }

      let(:first_locker) { create(:locker) }
      let(:second_locker) { create(:locker) }

      let(:first_action) { create(:locker_action, locker: first_locker, user: user, occurred_at: Time.utc(2026, 1, 1)) }
      let(:second_action) do
        create(:locker_action, locker: second_locker, user: user, occurred_at: Time.utc(2026, 1, 2))
      end

      before do
        first_action
        second_action
      end

      it 'assigns actions across all companies' do
        get locker_actions_path

        expect(response).to have_http_status(:ok)
        expect(assigns(:locker_actions)).to eq([second_action, first_action])
      end
    end

    context 'when accessible lockers have no history' do
      before do
        create(:team_locker, team: user.team)
      end

      it 'assigns an empty collection' do
        get locker_actions_path

        expect(response).to have_http_status(:ok)
        expect(assigns(:locker_actions)).to be_empty
      end
    end
  end
end
