# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MapsController, type: :controller do
  # needed for json builder test, since json builder files are handled as views
  render_views

  describe "functionalities with logged in user with role 'admin'" do
    before do
      @group = FactoryBot.create(:group)
      user = FactoryBot.create(:admin_user, group_id: @group.id)
      sign_in user
    end

    let(:map) do
      FactoryBot.create(:map, group_id: @group.id)
    end

    let(:valid_attributes) do
      FactoryBot.build(:map, group_id: @group.id).attributes
    end

    let(:invalid_attributes) do
      FactoryBot.attributes_for(:map, :invalid, group_id: @group.id)
    end

    let(:valid_session) { {} }

    describe 'GET #index' do
      it 'returns a success response' do
        map = Map.create! valid_attributes
        get :index, params: {}, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        map = Map.create! valid_attributes
        get :show, params: { id: map.friendly_id }, session: valid_session
        expect(response).to have_http_status(200)
      end
      it 'returns a redirect to an friendly_id' do
        map = Map.create! valid_attributes
        get :show, params: { id: map.id }, session: valid_session
        expect(response).to have_http_status(301)
      end
      it 'returns a no success response (for a non-accesible map)' do
        another_group = FactoryBot.create(:group)
        map = FactoryBot.create(:map, group_id: another_group.id)
        get :show, params: { id: map.friendly_id }, session: valid_session
        expect(response).to have_http_status(302)
        expect(flash[:notice]).to match 'Sorry, this map could not be found.'
      end
      it 'returns a no success response (for a non-existing map)' do
        another_group = FactoryBot.create(:group)
        map = FactoryBot.create(:map, group_id: another_group.id)
        get :show, params: { id: 'UNKNOWN' }, session: valid_session
        expect(response).to have_http_status(302)
        expect(flash[:notice]).to match 'Sorry, this map could not be found.'
      end
    end

    describe 'GET #show as json' do
      it 'returns a success reponse' do
        map = Map.create! valid_attributes
        get :show, params: { id: map.friendly_id }, session: valid_session, format: 'json'
        expect(response).to have_http_status(200)
      end

      it 'a map w/title for a published map' do
        map = FactoryBot.create(:map, group_id: @group.id, published: true)
        get :show, params: { id: map.friendly_id }, session: valid_session, format: 'json'
        json = JSON.parse(response.body)
        expect(json['title']).to eq map.title
      end

      it 'a map w/2 layers for a published map' do
        map = FactoryBot.create(:map, group_id: @group.id, published: true)
        layer1 = FactoryBot.create(:layer, map: map, published: true)
        FactoryBot.create(:place, layer: layer1, published: true)
        layer2 = FactoryBot.create(:layer, map: map, published: false)
        FactoryBot.create(:place, layer: layer2, published: true)

        get :show, params: { id: map.friendly_id }, session: valid_session, format: 'json'
        json = JSON.parse(response.body)
        expect(json['layers'][0]['title']).to eq layer1.title
        expect(json['layers'][1]['title']).to eq layer2.title
      end

      it 'a map w/2 layers for a published map and search param' do
        map = FactoryBot.create(:map, group_id: @group.id, published: true)
        layer1 = FactoryBot.create(:layer, map: map)
        place1 = FactoryBot.create(:place, layer: layer1)
        layer2 = FactoryBot.create(:layer, map: map)
        place2 = FactoryBot.create(:place, layer: layer2)
        get :show, params: { id: map.friendly_id, search: place1.title }, session: valid_session, format: 'json'
        expect(response.body).to include(place1.title)
        expect(response.body).not_to include(place2.title)
      end

      it 'a map w/2 layers for a published map and filter param' do
        map = FactoryBot.create(:map, group_id: @group.id, published: true)
        layer1 = FactoryBot.create(:layer, map: map)
        place1 = FactoryBot.create(:place, :with_tags, layer: layer1)
        layer2 = FactoryBot.create(:layer, map: map)
        place2 = FactoryBot.create(:place, layer: layer2)
        get :show, params: { id: map.friendly_id, filter: place1.tags[0].to_s }, session: valid_session, format: 'json'
        expect(response.body).to include(place1.title)
        expect(response.body).not_to include(place2.title)
      end

      it 'a map w/places_by_year for timeslider of a published map' do
        map = FactoryBot.create(:map, group_id: @group.id, published: true, enable_time_slider: true)
        layer1 = FactoryBot.create(:layer, map: map)
        FactoryBot.create(:place, :date_and_time, layer: layer1)
        layer2 = FactoryBot.create(:layer, map: map)
        FactoryBot.create(:place, :date_and_time, layer: layer2)
        get :show, params: { id: map.friendly_id }, session: valid_session, format: 'json'
        json = JSON.parse(response.body)
        expect(json['places_by_year']).to be_present
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
        map = Map.create! valid_attributes
        get :edit, params: { id: map.friendly_id }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Map' do
          expect do
            post :create, params: { map: valid_attributes }, session: valid_session
          end.to change(Map, :count).by(1)
        end

        it 'redirects to the created map' do
          post :create, params: { map: valid_attributes }, session: valid_session
          expect(response).to redirect_to(Map.last)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { map: invalid_attributes }, session: valid_session
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          FactoryBot.attributes_for(:map, :update)
        end

        it 'updates the requested map' do
          map = Map.create! valid_attributes
          put :update, params: { id: map.friendly_id, map: new_attributes }, session: valid_session
          map.reload
          expect(map.title).to eq 'MyNewString'
        end

        it 'redirects to the map' do
          map = Map.create! valid_attributes
          put :update, params: { id: map.friendly_id, map: valid_attributes }, session: valid_session
          expect(response).to redirect_to(map)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'edit' template)" do
          map = Map.create! valid_attributes
          put :update, params: { id: map.friendly_id, map: invalid_attributes }, session: valid_session
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'GET #import' do
      it 'returns a success response and renders the import form' do
        get :import, params: { id: map.friendly_id }, session: valid_session
        expect(response).to have_http_status(200)
        expect(response).to render_template(:import)
      end
    end

    describe 'POST #import_preview' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places.csv', 'text/csv') }

      context 'with valid CSV' do
        it 'renders the import preview' do
          post :import_preview, params: { id: map.friendly_id, import: { file: file } }, session: valid_session
          expect(response).to be_redirect
        end
      end

      context 'with invalid CSV' do
        let(:invalid_file) { Rack::Test::UploadedFile.new('spec/support/files/malformed.csv', 'text/csv') }

        it 'shows an error message' do
          post :import_preview, params: { id: map.friendly_id, import: { file: invalid_file } }, session: valid_session

          expect(flash[:error]).to eq('Maybe the file has a different column separator? Or it does not contain CSV? (Malformed CSV: Illegal quoting in line 2.)')
          expect(response).to render_template(:import)
        end
      end
    end

    describe 'POST #importing' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places.csv', 'text/csv') }
      let(:invalid_file) { Rack::Test::UploadedFile.new('spec/support/files/places_invalid_lat.csv', 'text/csv') }
      let(:layer) { create(:layer, map: map) }
      let(:import_mapping) { create(:import_mapping) }

      context 'without data stored in cache' do
        it 'redirects to map_layer_path and flashes error message' do
          post :importing, params: { id: map.friendly_id, file: file, import_mapping_id: import_mapping.id }, session: valid_session
          expect(response).to redirect_to(import_map_path(map))
          expect(flash[:notice]).to eq('No data provided to import!')
        end
      end

      context 'with data stored in cache' do
        context 'with valid CSV' do
          before do
            importing_rows = [Place.new(title: 'Place 1', lat: 53.95, lon: 9.34, layer: layer), Place.new(title: 'Place 2', lat: 53.85, lon: 9.27, layer: layer)]
            allow(ImportContextHelper).to receive(:read_importing_rows).and_return(importing_rows)
          end

          it 'imports the CSV and redirects to map_layer_path' do
            post :importing, params: { id: map.friendly_id, file: file, import_mapping_id: import_mapping.id }, session: valid_session

            expect(response).to redirect_to(map_path(map))
            expect(flash[:notice]).to match("CSV import to #{map.title} completed successfully!")
          end

          it 'creates new place records from the CSV' do
            expect do
              post :importing, params: { id: map.friendly_id, file: file, import_mapping_id: import_mapping.id }, session: valid_session
            end.to change(Place, :count).by(2)

            expect(Place.pluck(:title)).to contain_exactly('Place 1', 'Place 2')
          end
        end

        context 'with invalid CSV' do
          it 'does not import the CSV and shows an error message' do
            post :importing, params: { id: map.friendly_id, file: invalid_file, import_mapping_id: import_mapping.id }, session: valid_session

            expect(response).to redirect_to(import_map_path(map))
            expect(flash[:notice]).to include('No data provided')
          end

          it 'does not create book records from the invalid CSV' do
            expect do
              post :importing, params: { id: map.friendly_id, file: invalid_file, import_mapping_id: import_mapping.id }, session: valid_session
            end.not_to change(Place, :count)
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested map' do
        map = Map.create! valid_attributes
        expect do
          delete :destroy, params: { id: map.friendly_id }, session: valid_session
        end.to change(Map, :count).by(-1)
      end

      it 'redirects to the maps list' do
        map = Map.create! valid_attributes
        delete :destroy, params: { id: map.friendly_id }, session: valid_session
        expect(response).to redirect_to(maps_url)
      end
    end
  end
end
