# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IconsController, type: :controller do
  describe "functionalities with logged in user with role 'admin'" do
    before do
      user = FactoryBot.create(:admin_user)
      sign_in user
      @iconset = FactoryBot.create(:iconset)
    end

    let(:icon) do
      FactoryBot.create(:icon, iconset_id: @iconset.id)
    end

    let(:valid_attributes) do
      FactoryBot.build(:icon, iconset_id: @iconset.id).attributes
    end

    let(:invalid_attributes) do
      FactoryBot.attributes_for(:icon, :invalid, iconset_id: @iconset.id)
    end

    let(:valid_session) { {} }

    describe 'GET #index' do
      it 'returns a success response' do
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        icon = Icon.create! valid_attributes
        get :edit, params: { id: icon.to_param, iconset_id: @iconset.id }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          FactoryBot.attributes_for(:icon, :changed, iconset_id: @iconset.id)
        end

        it 'updates the requested icon' do
          icon = Icon.create! valid_attributes
          put :update, params: { id: icon.to_param, icon: new_attributes, iconset_id: @iconset.id }, session: valid_session
          icon.reload
          expect(icon.title).to eq('OtherTitle')
        end

        it 'redirects to the iconset' do
          icon = Icon.create! valid_attributes
          put :update, params: { id: icon.to_param, icon: valid_attributes, iconset_id: @iconset.id }, session: valid_session
          expect(response).to redirect_to(iconset_url(@iconset))
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'edit' template)" do
          icon = Icon.create! invalid_attributes
          put :update, params: { id: icon.to_param, icon: invalid_attributes, iconset_id: @iconset.id }, session: valid_session
          expect(response).to have_http_status(302)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested icon' do
        icon = Icon.create! valid_attributes
        expect do
          delete :destroy, params: { id: icon.to_param, iconset_id: @iconset.id }, session: valid_session
        end.to change(Icon, :count).by(-1)
      end

      it 'redirects to the icons list' do
        icon = Icon.create! valid_attributes
        delete :destroy, params: { id: icon.to_param, iconset_id: @iconset.id }, session: valid_session
        expect(response).to redirect_to(iconset_url(@iconset))
      end
    end
  end
end
