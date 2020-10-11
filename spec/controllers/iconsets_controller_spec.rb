# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IconsetsController, type: :controller do
  describe "functionalities with logged in user with role 'admin'" do
    before do
      user = FactoryBot.create(:admin_user)
      sign_in user
    end

    let(:iconset) do
      FactoryBot.create(:iconset)
    end

    let(:valid_attributes) do
      FactoryBot.build(:iconset).attributes
    end

    let(:invalid_attributes) do
      FactoryBot.attributes_for(:iconset, :invalid)
    end

    let(:valid_session) { {} }

    describe 'GET #index' do
      it 'returns a success response' do
        iconset = Iconset.create! valid_attributes
        get :index, params: {}, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        iconset = Iconset.create! valid_attributes
        get :show, params: { id: iconset.to_param }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new, params: {}, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        iconset = Iconset.create! valid_attributes
        get :edit, params: { id: iconset.to_param }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Iconset' do
          expect do
            post :create, params: { iconset: valid_attributes }, session: valid_session
          end.to change(Iconset, :count).by(1)
        end

        it 'redirects to the created iconset' do
          post :create, params: { iconset: valid_attributes }, session: valid_session
          expect(response).to redirect_to(Iconset.last)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { iconset: invalid_attributes }, session: valid_session
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          FactoryBot.attributes_for(:iconset, :changed)
        end

        it 'updates the requested iconset' do
          iconset = Iconset.create! valid_attributes
          put :update, params: { id: iconset.to_param, iconset: new_attributes }, session: valid_session
          iconset.reload
          expect(iconset.title).to eq('OtherTitle')
        end

        it 'redirects to the iconset' do
          iconset = Iconset.create! valid_attributes
          put :update, params: { id: iconset.to_param, iconset: valid_attributes }, session: valid_session
          expect(response).to redirect_to(iconset)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'edit' template)" do
          iconset = Iconset.create! valid_attributes
          put :update, params: { id: iconset.to_param, iconset: invalid_attributes }, session: valid_session
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested iconset' do
        iconset = Iconset.create! valid_attributes
        expect do
          delete :destroy, params: { id: iconset.to_param }, session: valid_session
        end.to change(Iconset, :count).by(-1)
      end

      it 'redirects to the iconsets list' do
        iconset = Iconset.create! valid_attributes
        delete :destroy, params: { id: iconset.to_param }, session: valid_session
        expect(response).to redirect_to(iconsets_url)
      end
    end
  end
end
