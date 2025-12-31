# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportMappingsController, type: :controller do
  # needed for json builder test, since json builder files are handled as views:
  render_views

  before do
    group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, group_id: group.id)
    sign_in user
    @map = FactoryBot.create(:map, group_id: group.id)
    @layer = FactoryBot.create(:layer, map_id: @map.id)
  end

  let(:import_mapping) { FactoryBot.create(:import_mapping) }

  let(:valid_session) { {} }

  describe 'GET #new' do
    it 'assigns variables from params and builds an ImportMapping' do
      get :new, params: { col_sep: ',', file_name: 'file.csv', headers: %w[title teaser latX lonX], missing_fields: %w[lat lon], layer_id: @layer.id }, session: valid_session

      expect(response).to have_http_status(200)
      expect(assigns(:import_mapping)).to be_a(ImportMapping)
      expect(assigns(:import_mapping)).not_to be_valid
      expect(assigns(:import_mapping).errors.first.type).to include('is missing required properties: lat, lon')
      expect(assigns(:headers)).to eq(%w[title teaser latX lonX])
      expect(assigns(:missing_fields)).to eq(%w[lat lon])
      expect(assigns(:place_columns)).to include('title')
      expect(assigns(:place_columns)).to include('tag_list')
      expect(assigns(:layer)).to eq(@layer)
      expect(assigns(:map)).to eq(@map)
      expect(assigns(:existing_mappings)).to be_empty
      expect(response).to render_template(:new)
    end

    it 'returns an array of matching import mappings' do
      not_matching_mapping = FactoryBot.create(:import_mapping)
      matching_mapping = FactoryBot.create(:import_mapping, mapping: [{ csv_column_name: 'description', model_property: 'description' },
                                                                      { csv_column_name: 'title', model_property: 'title', key: true },
                                                                      { csv_column_name: 'lon', model_property: 'lon' },
                                                                      { csv_column_name: 'lat', model_property: 'lat' }])

      get :new, params: { headers: %w[title lat lon description], layer_id: @layer.id }, session: valid_session

      expect(assigns(:existing_mappings).size).to eq(1)
      expect(assigns(:existing_mappings).first.name).to include(matching_mapping.name)
      expect(assigns(:existing_mappings).map(&:name)).not_to include(not_matching_mapping.name)
    end
  end

  describe 'POST #create' do
    it 'creates a new ImportMapping and redirects to the show page' do
      post :create, params: { import_mapping: { name: 'Test Mapping', mapping: '[{ "csv_column_name": "title", "model_property": "title" }, { "csv_column_name": "latX", "model_property": "lat" }, { "csv_column_name": "lonX", "model_property": "lon" }]' }, headers: '["title", "teaser", "latX", "lonX"]', layer_id: @layer.id }, session: valid_session

      expect(assigns(:import_mapping)).to be_a(ImportMapping)
      expect(assigns(:import_mapping)).to be_valid
      expect(response).to redirect_to(import_mapping_path(assigns(:import_mapping), layer_id: @layer.id, map_id: @map.id))
    end

    it 'renders the new template with errors if the mapping is invalid' do
      post :create, params: { import_mapping: { name: 'Test Mapping', mapping: '[{ "csv_column_name": "title", "model_property": "title" }]' }, headers: '["title", "teaser", "latX", "latY"]', layer_id: @layer.id }, session: valid_session

      expect(response).to render_template(:new)
      expect(assigns(:import_mapping)).not_to be_valid
    end

    context 'when an import mapping with the same name already exists' do
      let!(:existing_mapping) { FactoryBot.create(:import_mapping, name: 'Existing Mapping') }

      it 'updates the existing mapping if update_existing is checked' do
        post :create, params: { import_mapping: { name: 'Existing Mapping', mapping: '[{ "csv_column_name": "id", "model_property": "uid", "key": false },{ "csv_column_name": "title", "model_property": "title" }, { "csv_column_name": "lat", "model_property": "lat" }, { "csv_column_name": "lon", "model_property": "lon" }]', update_existing: '1' }, headers: '["title", "teaser", "latX", "lonX"]', layer_id: @layer.id }, session: valid_session

        expect(response).to redirect_to(import_mapping_path(existing_mapping.reload, layer_id: @layer.id, map_id: @map.id))
        expect(existing_mapping.mapping.first['model_property']).to eq('uid')
      end

      it 'renders the new template with an error if update_existing is not checked' do
        post :create, params: { import_mapping: { name: 'Existing Mapping', mapping: '[{ "csv_column_name": "id", "model_property": "uid", "key": false },{ "csv_column_name": "title", "model_property": "title" }, { "csv_column_name": "lat", "model_property": "lat" }, { "csv_column_name": "lon", "model_property": "lon" }]' }, headers: '["title", "teaser", "latX", "lonX"]', layer_id: @layer.id }, session: valid_session

        expect(response).to render_template(:new)
        expect(assigns(:import_mapping)).not_to be_valid
        expect(flash[:alert]).to eq('An import mapping with this name already exists. Please tick the "update" box if you would like to update it.')
      end
    end
  end

  describe 'GET #show' do
    it 'assigns variables from params and renders the show template' do
      get :show, params: { id: import_mapping.id, layer_id: @layer.id }, session: valid_session
      expect(response).to have_http_status(200)
      expect(assigns(:import_mapping)).to eq(import_mapping)
      expect(assigns(:maps)).to include(@map)
      expect(assigns(:layers)).to include(@layer)
      expect(assigns(:layer)).to eq(@layer)
      expect(assigns(:map)).to eq(@map)
      expect(response).to render_template(:show)
    end
  end

  describe 'POST #apply_mapping' do
    include_context 'with cache'
    let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places.csv', 'text/csv') }

    before do
      ImportContextHelper.write_tempfile_path(file)
    end

    context 'with only valid entries from previously uploaded file' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places.csv', 'text/csv') }

      it 'applies the mapping and redirects to the import preview page' do
        post :apply_mapping, params: { id: import_mapping.id, layer_id: @layer.id, file_name: 'places.csv', col_sep: ',', quote_char: '"', import: { overwrite: '1' } }, session: valid_session

        expect(response).to redirect_to(import_preview_import_mapping_path(assigns(:import_mapping), file_name: 'places.csv', layer_id: @layer.id, map_id: @map.id, overwrite: '1'))
        expect(assigns(:errored_rows)).to be_empty
        expect(assigns(:duplicate_rows)).to be_empty
        expect(assigns(:invalid_duplicate_rows)).to be_empty
        expect(assigns(:ambiguous_rows)).to be_empty
        expect(assigns(:importing_duplicate_rows)).to be_empty
        expect(assigns(:valid_rows)).not_to be_empty
        expect(assigns(:valid_rows).first.title).to eq('Place 1')
        expect(assigns(:valid_rows).first.errors).to be_empty
      end
    end

    context 'with duplicate and invalid entries from previously uploaded file' do
      before do
        Place.destroy_all
      end

      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places_with_valid_invalid_and_duplicate_rows.csv', 'text/csv') }
      let!(:place1) { create(:place, title: 'Place 1', layer: @layer) }
      let!(:place2) { create(:place, title: 'title2', id: 2, layer: @layer) }

      it 'applies the mapping and redirects to the import preview page' do
        post :apply_mapping, params: { id: import_mapping.id, layer_id: @layer.id, file_name: 'places_with_valid_invalid_and_duplicate_rows.csv', col_sep: ',', quote_char: '"', import: { overwrite: '1' } }, session: valid_session

        expect(response).to be_redirect
        expect(assigns(:errored_rows)).not_to be_empty
        expect(assigns(:errored_rows).first[:messages]).to eq([["Lon can't be blank", 'Lon should be a valid longitude value', 'Lon is not a number']])
        expect(assigns(:duplicate_rows)).not_to be_empty
        expect(assigns(:duplicate_rows).first[:duplicate_id]).to eq(place1.id)
        expect(assigns(:invalid_duplicate_rows)).not_to be_empty
        expect(assigns(:invalid_duplicate_rows).first[:messages]).to eq([['Lat should be a valid latitude value', "Lon can't be blank", 'Lon should be a valid longitude value', 'Lat is not a number', 'Lon is not a number', 'Id has already been taken']])
        expect(assigns(:ambiguous_rows)).to be_empty
        expect(assigns(:importing_duplicate_rows)).not_to be_empty
        expect(assigns(:importing_duplicate_rows).first.title).to eq('Place 1')
        expect(assigns(:valid_rows)).not_to be_empty
        expect(assigns(:valid_rows).first.title).to eq('Place 2')
      end
    end

    context 'when file is newly uploaded and matches the mapping' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places_with_html.csv', 'text/csv') }

      it 'applies the mapping and redirects to import_preview' do
        post :apply_mapping, params: { id: import_mapping.id, layer_id: @layer.id, file_name: nil, col_sep: ',', quote_char: '"', import: { overwrite: '1', file: file } }, session: valid_session

        expect(response).to redirect_to(import_preview_import_mapping_path(assigns(:import_mapping), file_name: 'places_with_html.csv', layer_id: @layer.id, map_id: @map.id, overwrite: '1'))
        expect(assigns(:valid_rows).first.title).to eq('Place 1 HTML')
      end
    end

    context 'when file newly uploaded and does not match the mapping' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places_invalid_header_valid_rows.csv', 'text/csv') }

      it 'redirects to the new mapping page with an error message' do
        post :apply_mapping, params: { id: import_mapping.id, layer_id: @layer.id, file_name: nil, col_sep: ',', quote_char: '"', import: { overwrite: '1', file: file } }, session: valid_session

        expect(response).to redirect_to(new_import_mapping_path(col_sep: ',', file_name: 'places_invalid_header_valid_rows.csv', headers: %w[id titleX latX lonX], layer_id: @layer.id, missing_fields: %w[title lat lon], quote_char: '"'))
        expect(flash[:error]).to eq('CSV is not matching mapping. Please select or create another mapping.')
      end
    end

    context 'when file is malformed csv' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/malformed.csv', 'text/csv') }

      it 'redirects to the import mapping page with an error message' do
        post :apply_mapping, params: { id: import_mapping.id, layer_id: @layer.id, file_name: nil, col_sep: ',', quote_char: '"', import: { overwrite: '1', file: file } }, session: valid_session

        expect(response).to redirect_to(import_mapping_path(import_mapping, layer_id: @layer.id, map_id: @map.id))
        expect(flash[:error]).to eq('Maybe the file has a different column separator? Or it does not contain CSV? (Malformed CSV: Illegal quoting in line 2.)')
      end
    end

    context 'when no layer_id is provided and the mapping does not contain layer_id' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places_with_layer_id.csv', 'text/csv') }

      it 'redirects to the import mapping page with an error message' do
        post :apply_mapping, params: { id: import_mapping.id, layer_id: nil, map_id: @map.id, file_name: 'places_with_layer_id.csv', col_sep: ',', quote_char: '"', import: { overwrite: '1', file: file } }, session: valid_session

        expect(response).to redirect_to(import_mapping_path(import_mapping, file_name: 'places_with_layer_id.csv', col_sep: ',', quote_char: '"', map_id: @map.id))
        expect(flash[:error]).to eq('Please select a layer.')
      end
    end

    context 'when the mapping does contain layer_id' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places_with_layer_id.csv', 'text/csv') }
      let(:import_mapping) { create(:import_mapping, :with_layer_id) }
      Layer.destroy_all
      let!(:layer) { create(:layer, map_id: @map.id, slug: 'first_layer', id: 1) }

      context 'without fallback layer_id' do
        it 'redirects to the import preview page with the layer_id from csv file assigned' do
          post :apply_mapping, params: { id: import_mapping.id, layer_id: nil, map_id: @map.id, file_name: 'places_with_layer_id.csv', col_sep: ',', quote_char: '"', import: { overwrite: '1', file: file } }, session: valid_session

          expect(response).to redirect_to(import_preview_import_mapping_path(assigns(:import_mapping), file_name: 'places_with_layer_id.csv', map_id: @map.id, overwrite: '1'))
          expect(assigns(:valid_rows).count).to eq(2)
          expect(assigns(:valid_rows).first.title).to eq('Place for first layer by id')
          expect(assigns(:valid_rows).last.title).to eq('Place for first layer by slug')
          expect(assigns(:valid_rows).first.layer_id).to eq(1)
          expect(assigns(:errored_rows).count).to eq(6)
          expect(assigns(:errored_rows).first[:messages]).to eq([['Layer must exist']])
        end
      end

      context 'whith fallback layer_id' do
        let(:fallback_layer) { FactoryBot.create(:layer, map_id: @map.id) }

        it 'redirects to the import preview page with the layer_id from csv file assigned' do
          post :apply_mapping, params: { id: import_mapping.id, layer_id: fallback_layer.id, map_id: @map.id, file_name: 'places_with_layer_id.csv', col_sep: ',', quote_char: '"', import: { overwrite: '1', file: file } }, session: valid_session

          expect(response).to redirect_to(import_preview_import_mapping_path(assigns(:import_mapping), file_name: 'places_with_layer_id.csv', layer_id: fallback_layer.id, map_id: @map.id, overwrite: '1'))
          expect(assigns(:valid_rows).count).to eq(8)
          expect(assigns(:valid_rows).first.title).to eq('Place for first layer by id')
          expect(assigns(:valid_rows).first.layer_id).to eq(1)
          expect(assigns(:valid_rows).last.layer_id).to eq(fallback_layer.id)
        end
      end
    end
  end

  describe 'GET #import_preview' do
    include_context 'with cache'
    let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places.csv', 'text/csv') }

    before do
      ImportContextHelper.write_tempfile_path(file)
    end

    context 'with only valid entries' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places.csv', 'text/csv') }

      before do
        valid_rows = [
          Place.new(title: 'Place 1', teaser: 'Ein etwas versteckt gelegenes und daher wohl eher ...', lat: '53.55', lon: '9.94', layer_id: 1),
          Place.new(title: 'Place 2', teaser: 'Zusätzlich wurden zum Zweck der Feuerholzgewinnung...', lat: '53.55', lon: '9.95', layer_id: 1)
        ]
        ImportContextHelper.write_importing_rows('places.csv', valid_rows)
        ImportContextHelper.write_importing_duplicate_rows('places.csv', [])
      end

      it 'assigns variables from params and renders the import preview template' do
        get :import_preview, params: { id: import_mapping.id, file_name: 'places.csv', layer_id: @layer.id, map_id: @map.id }, session: valid_session

        expect(response).to have_http_status(200)
        expect(assigns(:valid_rows)).not_to be_empty
        expect(assigns(:valid_rows).first.title).to eq('Place 1')
        expect(assigns(:duplicate_rows)).to be_nil
        expect(assigns(:invalid_duplicate_rows)).to be_nil
        expect(assigns(:ambiguous_rows)).to be_nil
        expect(assigns(:importing_duplicate_rows)).to be_empty
        expect(assigns(:errored_rows)).to be_nil
        expect(assigns(:overwrite)).to eq(false)
        expect(response).to render_template(:import_preview)
      end
    end

    context 'with duplicate and invalid entries' do
      let(:file) { Rack::Test::UploadedFile.new('spec/support/files/places_with_valid_invalid_and_duplicate_rows.csv', 'text/csv') }

      before do
        valid_rows = [
          Place.new(title: 'Place 1', teaser: 'Ein etwas versteckt gelegenes und daher wohl eher ...', lat: '53.55', lon: '9.94', layer_id: 1)
        ]
        importing_duplicate_rows = [
          Place.new(title: 'Place 2', teaser: 'Zusätzlich wurden zum Zweck der Feuerholzgewinnung...', lat: '53.55', lon: '9.95', layer_id: 1)
        ]

        errored_rows = [{ data: '3,"",row without title,text2,annotations2,2025-01-02,2025-01-03,1.2,9,', messages: [["Title can't be blank"]] }]
        ambiguous_rows = [{ data: '347,Place 1,Ein besonderer Ort', duplicate_count: '2' }]
        duplicate_rows = [{ data: '1,title1,row with valid data,text1,annotations1,2025-01-01,2025-01-02,1.2,9,Main Street,,', duplicate_id: '3348' }]

        ImportContextHelper.write_importing_rows('places_with_valid_invalid_and_duplicate_rows.csv', valid_rows)
        ImportContextHelper.write_importing_duplicate_rows('places_with_valid_invalid_and_duplicate_rows.csv', importing_duplicate_rows)
        ImportContextHelper.write_not_importing_rows('places_with_valid_invalid_and_duplicate_rows.csv', { errored_rows: errored_rows, ambiguous_rows: ambiguous_rows, duplicate_rows: duplicate_rows })
      end

      it 'assigns variables from rails cache and params and renders the import preview template' do
        get :import_preview, params: { id: import_mapping.id, file_name: 'places_with_valid_invalid_and_duplicate_rows.csv', layer_id: @layer.id, map_id: @map.id }, session: valid_session

        expect(response).to have_http_status(200)
        expect(assigns(:valid_rows)).not_to be_empty
        expect(assigns(:valid_rows).first.title).to eq('Place 1')
        expect(assigns(:duplicate_rows)).not_to be_empty
        expect(assigns(:duplicate_rows).first[:duplicate_id]).to eq('3348')
        expect(assigns(:invalid_duplicate_rows)).to be_nil
        expect(assigns(:ambiguous_rows)).not_to be_empty
        expect(assigns(:ambiguous_rows).first[:duplicate_count]).to eq('2')
        expect(assigns(:importing_duplicate_rows)).not_to be_empty
        expect(assigns(:importing_duplicate_rows).first.title).to eq('Place 2')
        expect(assigns(:errored_rows)).not_to be_empty
        expect(assigns(:errored_rows).first[:messages]).to eq([["Title can't be blank"]])
        expect(assigns(:overwrite)).to eq(false)
        expect(response).to render_template(:import_preview)
      end
    end
  end
end
