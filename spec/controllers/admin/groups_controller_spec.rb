# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::GroupsController, type: :controller do
  describe 'for guests' do
    describe 'GET #index' do
      it 'no access' do
        get :index, params: {}
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "functionalities with logged in user with role 'user'" do
    before(:all) do
      User.destroy_all
      @group = FactoryBot.create(:group)
      @user = FactoryBot.create(:user, group_id: @group.id)
    end

    before(:each) do
      sign_in(@user)
    end

    let(:group) do
      @group
    end
    let(:valid_attributes) do
      FactoryBot.build(:group).attributes
    end
    let(:invalid_attributes) do
      FactoryBot.attributes_for(:group, :invalid)
    end

    let(:valid_session) { {} }

    describe 'GET #index' do
      it 'returns a success response' do
        get :index, params: {}, session: valid_session
        expect(response).to have_http_status(200)
      end
      it 'returns a valid array' do
        @admin_groups = FactoryBot.create_list(:group, 3)
        @admin_groups.push(@group)
        get :index, params: {}, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #edit' do
      it "returns a success response (if its the user's group" do
        get :edit, params: { id: @group.to_param }, session: valid_session
        expect(response).to have_http_status(200)
      end
      it "returns a error response (if its NOT the user's group" do
        @group_not_related_to_user = FactoryBot.create(:group)
        get :edit, params: { id: @group_not_related_to_user.to_param }, session: valid_session
        expect(response).to have_http_status(302)
        expect(flash[:notice]).to match 'You can\'t edit this group.'
      end
    end
  end
  describe "functionalities with logged in user with role 'admin'" do
    before(:all) do
      User.destroy_all
      @admin_group = FactoryBot.create(:group)
      @admin_user = FactoryBot.create(:admin_user, group_id: @admin_group.id)
    end

    before(:each) do
      sign_in(@admin_user)
    end

    let(:admin_group) do
      @admin_group
    end
    let(:valid_attributes) do
      FactoryBot.build(:group).attributes
    end
    let(:invalid_attributes) do
      FactoryBot.attributes_for(:group, :invalid)
    end

    let(:valid_session) { {} }

    describe 'GET #index' do
      it 'returns a success response' do
        admin_group = Group.create! valid_attributes
        get :index, params: {}, session: valid_session
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
        get :edit, params: { id: admin_group.to_param }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Group' do
          expect do
            post :create, params: { admin_group: valid_attributes }, session: valid_session
          end.to change(Group, :count).by(1)
        end

        it 'redirects to the created group' do
          post :create, params: { admin_group: valid_attributes }, session: valid_session
          expect(response).to redirect_to(admin_groups_url)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { admin_group: invalid_attributes }, session: valid_session
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          FactoryBot.attributes_for(:group, :update)
        end

        it 'updates the requested group' do
          put :update, params: { id: @admin_group.to_param, admin_group: new_attributes }, session: valid_session
          @admin_group.reload
          expect(@admin_group.title).to eq 'MyNewString'
        end

        it 'redirects to the group' do
          put :update, params: { id: @admin_group.to_param, admin_group: valid_attributes }, session: valid_session
          expect(response).to redirect_to(admin_groups_url)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'edit' template)" do
          put :update, params: { id: @admin_group.to_param, admin_group: invalid_attributes }, session: valid_session
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'DELETE #destroy' do

      before(:each) do
        @other_group = FactoryBot.create(:group)
        @other_user = FactoryBot.create(:admin_user, group_id: @other_group.id)

      end
      xit 'cant destroy the requested group (if a user is still there)' do
        expect do
          delete :destroy, params: { id: @admin_group.to_param }, session: valid_session
        end.to change(Group, :count).by(0)
      end

      it 'destroys the requested group' do
        @other_user.destroy!
        @other_group.reload
        expect do
          delete :destroy, params: { id: @other_group.to_param }, session: valid_session
        end.to change(Group, :count).by(-1)
      end

      it 'redirects to the groups list' do
        @other_user.destroy!
        @other_group.reload
        delete :destroy, params: { id: @other_group.to_param }, session: valid_session
        expect(response).to redirect_to(admin_groups_url)
      end
    end
  end
end
