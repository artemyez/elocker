# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrentUsersController, type: :request do
  describe 'PATCH /current_user' do
    context 'when user exists' do
      let(:user) { create(:user) }

      it 'updates current_user_id in session and redirects to lockers' do
        patch current_user_path, params: { user_id: user.id }

        expect(response).to redirect_to(lockers_path)
        expect(session[:current_user_id]).to eq(user.id)
        expect(flash[:notice]).to eq("Switched to #{user.name}")
      end
    end

    context 'when user does not exist' do
      it 'does not update session and redirects with alert' do
        patch current_user_path, params: { user_id: 999_999 }

        expect(response).to redirect_to(lockers_path)
        expect(session[:current_user_id]).to be_nil
        expect(flash[:alert]).to eq('User not found')
      end
    end
  end
end
