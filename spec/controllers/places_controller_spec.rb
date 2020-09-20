# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlacesController, type: :controller do
  # needed for json builder test, since json builder files are handled as views
  render_views

  describe "functionalities with logged in user with role 'admin'" do
    before do
      group = FactoryBot.create(:group)
      user = FactoryBot.create(:admin_user, group_id: group.id)
      sign_in user
      @map = FactoryBot.create(:map, group_id: group.id)
      @layer = FactoryBot.create(:layer, map_id: @map.id)
    end

    let(:place) do
      FactoryBot.create(:place, layer_id: @layer.id)
    end

    let(:valid_attributes) do
      FactoryBot.build(:place, layer_id: @layer.id).attributes
    end

    let(:invalid_attributes) do
      FactoryBot.attributes_for(:place, :invalid, layer_id: @layer.id)
    end

    let(:valid_session) { {} }

    describe 'GET #index' do
      it 'returns a success response' do
        place = Place.create! valid_attributes
        get :index, params: { layer_id: @layer.id, map_id: @map.id }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        place = Place.create! valid_attributes
        get :show, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #show as json' do
      it 'returns a success reponse' do
        place = Place.create! valid_attributes
        get :show, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id }, session: valid_session, format: 'json'
        expect(response).to have_http_status(200)
      end

      it 'returns a placemark w/title' do
        place = Place.create! valid_attributes
        get :show, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id }, session: valid_session, format: 'json'
        json = JSON.parse(response.body)
        expect(json['title']).to eq place.title
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new, params: { layer_id: @layer.id, map_id: @map.id }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        place = Place.create! valid_attributes
        get :edit, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id }, session: valid_session
        expect(response).to have_http_status(200)
      end

      it 'returns a success response (with new coords to reposition)' do
        place = Place.create! valid_attributes
        get :edit, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id, lat: 10, lng: 10 }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Place' do
          expect do
            post :create, params: { place: valid_attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          end.to change(Place, :count).by(1)
        end

        it 'redirects to the related map' do
          post :create, params: { place: valid_attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          expect(response).to redirect_to(map_layer_url(@map, @layer))
        end

        # ActiveStorage::Attachment, :count still not working
        xit 'attaches an uploaded audio' do
          valid_attributes_with_audio = FactoryBot.build(:place, :with_audio, layer_id: @layer.id).attributes
          expect do
            post :create, params: { place: valid_attributes_with_audio, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          end.to change(ActiveStorage::Attachment, :count).by(1)
        end

        it 'saves startdate date without time (as seperate date and time strings) correctly' do
          startdate = '2010-04-29 00:00:00.000000000 +0000'
          startdate_date = '2010-04-29'
          startdate_time = ''
          attributes = FactoryBot.attributes_for(:place, :date_and_time, layer_id: @layer.id, startdate_date: startdate_date, startdate_time: startdate_time)
          post :create, params: { place: attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          expect(Place.last.startdate).to eq(startdate)
        end

        it 'saves startdate date and time (as seperate date and time strings) correctly' do
          startdate = '2010-04-29 20:30:00.000000000 +0000'
          startdate_date = '2010-04-29'
          startdate_time = '20:30'
          # ups, FactoryBot.build did not handle the attr_accessor values startdate_date...
          attributes = FactoryBot.attributes_for(:place, :date_and_time, layer_id: @layer.id, startdate_date: startdate_date, startdate_time: startdate_time)
          post :create, params: { place: attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          expect(Place.last.startdate).to eq(startdate)
        end

        it 'saves startdate and enddate date and time (as seperate date and time strings) correctly' do
          startdate = '2010-04-29 18:30:00.000000000 +0000'
          enddate = '2010-04-29 20:30:00.000000000 +0000'
          startdate_date = '2010-04-29'
          enddate_date = '2010-04-29'
          startdate_time = '18:30'
          enddate_time = '20:30'
          attributes = FactoryBot.attributes_for(:place, :date_and_time, layer_id: @layer.id, startdate_date: startdate_date, startdate_time: startdate_time, enddate_date: enddate_date, enddate_time: enddate_time)
          post :create, params: { place: attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          expect(Place.last.startdate).to eq(startdate)
          expect(Place.last.enddate).to eq(enddate)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { place: invalid_attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          FactoryBot.build(:place, :changed, layer_id: @layer.id).attributes
        end
        let(:new_attributes_with_published) do
          FactoryBot.build(:place, :changed_and_published, layer_id: @layer.id).attributes
        end

        it 'updates the requested place' do
          place = Place.create! valid_attributes
          put :update, params: { id: place.to_param, place: new_attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          place.reload
          expect(place.title).to eq('OtherTitle')
        end

        it "updates the requested place (with published 'on')" do
          place = Place.create! valid_attributes
          put :update, params: { id: place.to_param, place: new_attributes_with_published, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          place.reload
          expect(place.title).to eq('OtherTitle')
          expect(place.published).to eq(true)
        end

        it 'redirects to the place' do
          place = Place.create! valid_attributes
          put :update, params: { id: place.to_param, place: valid_attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          expect(response).to redirect_to(map_layer_url(@map, @layer))
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'edit' template)" do
          place = Place.create! valid_attributes
          put :update, params: { id: place.to_param, place: invalid_attributes, layer_id: @layer.id, map_id: @map.id }, session: valid_session
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested place' do
        place = Place.create! valid_attributes
        expect do
          delete :destroy, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id }, session: valid_session
        end.to change(Place, :count).by(-1)
      end

      it 'redirects to the places list' do
        place = Place.create! valid_attributes
        delete :destroy, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id }, session: valid_session
        expect(response).to redirect_to(map_layer_places_url(@map, @layer))
      end
    end


    describe 'POST #sort' do
      it 'sort images of a place (via XHR)' do
        place = Place.create! valid_attributes

        image1 = FactoryBot.create(:image, place: place, sorting: 1)
        image2 = FactoryBot.create(:image, place: place, sorting: 2)
        image3 = FactoryBot.create(:image, place: place, sorting: 3)
        @image_ids = [image3.id, image2.id, image1.id]
        post :sort, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id, images: @image_ids }, session: valid_session
        image1.reload
        image3.reload
        expect(image1.sorting).to eq(3)
        expect(image3.sorting).to eq(1)
      end
    end
  end
end
