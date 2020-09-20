# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StartController, type: :controller do
  # TODO: check as non logged in user

  before(:all) do
    User.destroy_all
    @user = FactoryBot.create(:user)
  end

  describe 'GET #index as user' do
    it 'returns success' do
      sign_in(@user)
      get :index
      expect(response).to redirect_to(maps_url)
    end
  end

  describe 'GET #info as user' do
    it 'returns success' do
      sign_in(@user)
      get :info
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #settings as user' do
    it 'returns success' do
      sign_in(@user)
      get :settings
      expect(response).to have_http_status(200)
    end
  end

  describe 'update profile as user' do
    before do
      sign_in(@user)
    end

    it 'edit response should be success' do
      get :edit_profile, params: { id: User.first.id }
      expect(response).to have_http_status(200)
    end

    it 'update response should be success' do
      put :update_profile, params: { user: { id: @user.id, email: @user.email, password: 'Test1234567890?' } }
      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to match 'Your profile was successfully updated.'
    end

    it 'incomplete update response should be not success' do
      put :update_profile, params: { user: { id: User.first.id, email: '', password: '' } }
      expect(response).to render_template('start/edit_profile')
    end
  end
end
