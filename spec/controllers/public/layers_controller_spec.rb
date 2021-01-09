# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Public::LayersController, type: :controller do
  render_views

  describe "functionalities with logged in user with role 'admin'" do
    before do
      @group = FactoryBot.create(:group)
      user = FactoryBot.create(:admin_user, group_id: @group.id)
      @map = FactoryBot.create(:map, group_id: @group.id)
    end

    let(:map) do
      FactoryBot.create(:layer, map_id: @map.id)
    end

    let(:valid_attributes) do
      FactoryBot.build(:layer, map_id: @map.id, published: true).attributes
    end

    let(:invalid_attributes) do
      FactoryBot.build(:layer, map_id: @map.id, published: false).attributes
    end

    let(:valid_session) { {} }


    describe 'GET #show w/JSON format' do
      it 'returns a success response for a published layer' do
        layer = Layer.create! valid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
      end

      it 'returns geojson for a published layer' do
        layer = Layer.create! valid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/json')
      end

      it 'returns geojson with a valid scheme' do
        layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session
        # puts response.body
        expect(response).to match_response_schema('layer','json')
      end

      it 'returns an 403 + error response for unpublished resources' do
        layer = Layer.create! invalid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(403)
        expect(JSON.parse(response.body)['error']).to match(/Layer not accessible/)
      end
    end

    describe 'GET #show w/GeoJSON format' do
      it 'returns a success response for a published layer' do
        layer = Layer.create! valid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'geojson' }, session: valid_session
        expect(response).to have_http_status(200)
      end

      it 'returns geojson for a published layer' do
        layer = Layer.create! valid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'geojson' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/geo+json')
      end

      it 'returns geojson with a valid scheme' do
        layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'geojson' }, session: valid_session
        # puts response.body
        expect(response).to match_response_schema('layer','geojson')
      end

      it 'returns an 403 + error response for unpublished resources' do
        layer = Layer.create! invalid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'geojson' }, session: valid_session
        expect(response).to have_http_status(403)
        expect(JSON.parse(response.body)['error']).to match(/Layer not accessible/)
      end
    end
  end
end
