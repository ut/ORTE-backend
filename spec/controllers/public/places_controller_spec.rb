# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Public::PlacesController, type: :controller do
  render_views

  describe 'functionalities for everybody' do
    before do
      @group = FactoryBot.create(:group)
      user = FactoryBot.create(:admin_user, group_id: @group.id)
      @map = FactoryBot.create(:map, group_id: @group.id)
      @layer = FactoryBot.create(:layer, map_id: @map.id)
    end

    let(:place) do
      FactoryBot.create(:place, layer_id: @layer.id)
    end

    let(:valid_attributes) do
      FactoryBot.build(:place, layer_id: @layer.id, published: true).attributes
    end

    let(:invalid_attributes) do
      FactoryBot.build(:place, layer_id: @layer.id, published: false).attributes
    end

    let(:valid_session) { {} }

    describe 'GET #show w/JSON format' do
      it 'returns a success response for a published layer' do
        place = Place.create! valid_attributes
        get :show, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
      end

      it 'returns json for a published layer' do
        place = Place.create! valid_attributes
        get :show, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      xit 'returns json with a valid scheme' do
        place = FactoryBot.create(:place, layer_id: @layer.id, published: true)
        get :show, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to match_response_schema('layer', 'json')
      end

      it 'returns an 403 + error response for unpublished resources' do
        place = Place.create! invalid_attributes
        get :show, params: { id: place.to_param, layer_id: @layer.id, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(403)
        expect(JSON.parse(response.body)['error']).to match(/Place not accessible/)
      end
    end
  end
end
