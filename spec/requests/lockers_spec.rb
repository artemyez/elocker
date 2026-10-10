# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LockersController, type: :request do
  let(:company) { create(:company) }
  let(:team) { create(:team, company: company) }
  let(:user) { create(:user, company: company, team: team) }

  before { select_user(user) }

  describe 'GET /lockers' do
    context 'when the user is an employee' do
      let(:first_locker) { create(:team_locker, team: team).locker }
      let(:second_locker) { create(:team_locker, team: team).locker }

      let(:other_team) { create(:team, company: company) }
      let(:inaccessible_locker) { create(:team_locker, team: other_team).locker }

      before do
        first_locker
        second_locker
        inaccessible_locker
      end

      it 'assigns accessible lockers ordered by id' do
        get lockers_path

        expect(response).to have_http_status(:ok)
        expect(assigns(:lockers)).to match_array([first_locker, second_locker])
        expect(assigns(:lockers).map(&:id)).to eq([first_locker, second_locker].map(&:id).sort)
      end
    end

    context 'when the user is support' do
      let(:user) { create(:user, :support) }

      let(:first_locker) { create(:locker) }
      let(:second_locker) { create(:locker) }

      before do
        first_locker
        second_locker
      end

      it 'assigns all lockers across companies' do
        get lockers_path

        expect(response).to have_http_status(:ok)
        expect(assigns(:lockers)).to match_array([first_locker, second_locker])
      end
    end
  end

  describe 'GET /lockers/:id' do
    context 'when locker is accessible' do
      let(:locker) { create(:team_locker, team: team).locker }

      let(:first_action) { create(:locker_action, locker: locker, occurred_at: 1.hour.ago) }
      let(:second_action) { create(:locker_action, locker: locker, occurred_at: 10.minutes.ago) }

      before do
        first_action
        second_action
      end

      it 'assigns requested locker and its actions ordered by occurred_at desc' do
        get locker_path(locker)

        expect(response).to have_http_status(:ok)
        expect(assigns(:locker)).to eq(locker)
        expect(assigns(:locker_actions)).to eq([second_action, first_action])
      end
    end

    context 'when locker is inaccessible or missing' do
      let(:other_company) { create(:company) }
      let(:other_team) { create(:team, company: other_company) }
      let(:inaccessible_locker) { create(:team_locker, team: other_team).locker }

      it 'redirects to index with alert' do
        get locker_path(inaccessible_locker)

        expect(response).to redirect_to(lockers_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:alert]).to eq('Locker not found or unavailable.')
      end
    end
  end

  describe 'POST /lockers/:id/open' do
    let(:locker) { create(:team_locker, team: team).locker }

    context 'when locker is closed' do
      before { locker.update!(state: 'closed') }

      it 'opens locker and redirects with notice' do
        post open_locker_path(locker)

        expect(response).to redirect_to(locker_path(locker))
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq('Locker is now open.')
        expect(locker.reload.state).to eq('open')
      end
    end

    context 'when locker is already open' do
      before { locker.update!(state: 'open') }

      it 'does not change state and redirects with already notice' do
        post open_locker_path(locker)

        expect(response).to redirect_to(locker_path(locker))
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq('Locker is already open.')
        expect(locker.reload.state).to eq('open')
      end
    end

    context 'when state transition fails on record invalid' do
      before do
        allow_any_instance_of(Locker).to receive(:open).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'redirects with alert message' do
        post open_locker_path(locker)

        expect(response).to redirect_to(locker_path(locker))
        expect(response).to have_http_status(:see_other)
        expect(flash[:alert]).to eq('Could not change locker state.')
      end
    end

    context 'when locker is inaccessible' do
      let(:other_team) { create(:team, company: create(:company)) }
      let(:inaccessible_locker) { create(:team_locker, team: other_team).locker }

      it 'redirects to index' do
        post open_locker_path(inaccessible_locker)

        expect(response).to redirect_to(lockers_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:alert]).to eq('Locker not found or unavailable.')
      end
    end
  end

  describe 'POST /lockers/:id/close' do
    let(:locker) { create(:team_locker, team: team).locker }

    context 'when locker is open' do
      before { locker.update!(state: 'open') }

      it 'closes locker and redirects with notice' do
        post close_locker_path(locker)

        expect(response).to redirect_to(locker_path(locker))
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq('Locker is now closed.')
        expect(locker.reload.state).to eq('closed')
      end
    end

    context 'when locker is already closed' do
      before { locker.update!(state: 'closed') }

      it 'does not change state and redirects with already notice' do
        post close_locker_path(locker)

        expect(response).to redirect_to(locker_path(locker))
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq('Locker is already closed.')
        expect(locker.reload.state).to eq('closed')
      end
    end

    context 'when state transition fails on record invalid' do
      before do
        allow_any_instance_of(Locker).to receive(:close).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'redirects with alert message' do
        post close_locker_path(locker)

        expect(response).to redirect_to(locker_path(locker))
        expect(response).to have_http_status(:see_other)
        expect(flash[:alert]).to eq('Could not change locker state.')
      end
    end
  end
end
