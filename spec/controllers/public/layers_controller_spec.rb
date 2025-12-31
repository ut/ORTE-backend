# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Public::LayersController, type: :controller do
  render_views

  describe 'functionalities for everybody' do
    before do
      @group = FactoryBot.create(:group)
      user = FactoryBot.create(:admin_user, group_id: @group.id)
      @map = FactoryBot.create(:map, group_id: @group.id)
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

      it 'returns sorted results a published layer, sorted by ID' do
        layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
        place1 = FactoryBot.create(:place, layer: layer, published: true, title: 'C')
        place2 = FactoryBot.create(:place, layer: layer, published: true, title: 'A')
        place3 = FactoryBot.create(:place, layer: layer, published: true, title: 'B')
        place4_notpublished = FactoryBot.create(:place, layer: layer, published: false)

        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session

        expect(assigns(:layer)).to eq(layer)
        expect(assigns(:places)).to eq([place1, place2, place3])
      end

      it 'returns sorted results a published layer, sorted by title' do
        layer = FactoryBot.create(:layer, :sorted_by_title, map_id: @map.id, published: true)
        place1 = FactoryBot.create(:place, layer: layer, published: true, title: 'C')
        place2 = FactoryBot.create(:place, layer: layer, published: true, title: 'A')
        place3 = FactoryBot.create(:place, layer: layer, published: true, title: 'B')
        place4_notpublished = FactoryBot.create(:place, layer: layer, published: false)

        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session

        expect(assigns(:layer)).to eq(layer)
        expect(assigns(:places)).to eq([place2, place3, place1])
      end

      it 'returns sorted results a published layer, sorted by startdate' do
        layer = FactoryBot.create(:layer, :sorted_by_startdate, map_id: @map.id, published: true)
        place1 = FactoryBot.create(:place, layer: layer, published: true, startdate_date: Time.now - 2.day)
        place2 = FactoryBot.create(:place, layer: layer, published: true, startdate_date: Time.now - 4.day)
        place3 = FactoryBot.create(:place, layer: layer, published: true, startdate_date: Time.now - 3.day)
        place4_notpublished = FactoryBot.create(:place, layer: layer, published: false)

        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session

        expect(assigns(:layer)).to eq(layer)
        expect(assigns(:places)).to eq([place2, place3, place1])
      end

      context 'when filtering by tags' do
        let(:map) { create(:map) }
        let!(:layer) { create(:layer, map_id: map.id, published: true) }
        let!(:place1) { create(:place, layer: layer, published: true, tag_list: %w[aaa bbb ccc]) }
        let!(:place2) { create(:place, layer: layer, published: true, tag_list: %w[ddd eee]) }
        let!(:place3) { create(:place, layer: layer, published: true, tag_list: %w[bbb fff]) }
        let!(:place4) { create(:place, layer: layer, published: true, tag_list: %w[fff aaa bbb]) }

        it 'returns only accordingly tagged places with any tag when filtered by tag' do
          get :show, params: { id: layer.to_param, map_id: map.id, filter_by_tags: 'bbb,fff', format: 'json' }, session: valid_session
          expect(response).to have_http_status(200)
          expect(assigns(:places)).to eq([place1, place3, place4])
          expect(assigns(:places)).not_to include(place2)
        end

        it 'returns only accordingly tagged places with all tags when filtered by tag with match all param' do
          get :show, params: { id: layer.to_param, map_id: map.id, filter_by_tags: 'bbb,fff', match_all: true, format: 'json' }, session: valid_session
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(assigns(:places)).to eq([place3, place4])
          expect(assigns(:places)).not_to include(place1)
          expect(assigns(:places)).not_to include(place2)
          expect(json['layer']['places'][0]['tags']).to eq %w[bbb fff]
          expect(json['layer']['places'][1]['tags']).to eq %w[aaa bbb fff]
        end
      end

      it 'can handle images with and without sorting values' do
        layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        FactoryBot.create(:image, place: place, sorting: nil)
        FactoryBot.create(:image, place: place, sorting: 1)
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'returns json for a published layer' do
        layer = Layer.create! valid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'returns json with a valid scheme' do
        layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session
        expect(response).to match_response_schema('layer', 'json')
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
        expect(response.content_type).to eq('application/geo+json; charset=utf-8')
      end

      it 'returns geojson with a valid scheme' do
        layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'geojson' }, session: valid_session
        expect(response).to match_response_schema('layer', 'geojson')
      end

      it 'returns an 403 + error response for unpublished resources' do
        layer = Layer.create! invalid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'geojson' }, session: valid_session
        expect(response).to have_http_status(403)
        expect(JSON.parse(response.body)['error']).to match(/Layer not accessible/)
      end

      context 'when filtering by tags' do
        let(:map) { create(:map) }
        let!(:layer) { create(:layer, map_id: map.id, published: true) }
        let!(:place1) { create(:place, layer: layer, published: true, tag_list: %w[aaa bbb ccc]) }
        let!(:place2) { create(:place, layer: layer, published: true, tag_list: %w[ddd eee]) }
        let!(:place3) { create(:place, layer: layer, published: true, tag_list: %w[bbb fff]) }
        let!(:place4) { create(:place, layer: layer, published: true, tag_list: %w[fff aaa bbb]) }

        it 'returns geojson with  only accordingly tagged places with any tag when filtered by tag' do
          get :show, params: { id: layer.to_param, map_id: map.id, filter_by_tags: 'bbb,fff', format: 'geojson' }, session: valid_session
          expect(response).to have_http_status(200)
          expect(assigns(:places)).to eq([place1, place3, place4])
          expect(assigns(:places)).not_to include(place2)
        end

        it 'returns only accordingly tagged places with all tags when filtered by tag with match all param' do
          get :show, params: { id: layer.to_param, map_id: map.id, filter_by_tags: 'bbb,fff', match_all: true, format: 'geojson' }, session: valid_session
          expect(response).to have_http_status(200)
          expect(assigns(:places)).to eq([place3, place4])
          expect(assigns(:places)).not_to include(place1)
          expect(assigns(:places)).not_to include(place2)
        end
      end
    end

    describe 'GET #show w/ZIP format' do
      it 'returns a success response for a published layer' do
        layer = Layer.create! valid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'zip' }, session: valid_session
        expect(response).to have_http_status(200)
      end
    end

    describe 'filtering by tags' do
      before do
        @layer = Layer.create! valid_attributes
        @place1 = FactoryBot.create(:place, layer: @layer, published: true, tag_list: %w[aaa bbb ccc])
        @place2 = FactoryBot.create(:place, layer: @layer, published: true, tag_list: %w[ddd eee])
        @place3 = FactoryBot.create(:place, layer: @layer, published: true, tag_list: %w[fff])
      end

      it 'returns geojson with only accordingly tagged places when filtered by tag' do
        get :show, params: { id: @layer.to_param, map_id: @map.id, filter_by_tags: 'bbb,eee', format: 'geojson' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(assigns(:places)).to eq([@place1, @place2])
        expect(assigns(:places)).not_to include(@place3)
      end

      it 'returns zip file with only accordingly tagged places when filtered by tag' do
        get :show, params: { id: @layer.to_param, map_id: @map.id, filter_by_tags: 'eee', format: 'zip' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(assigns(:places)).to eq([@place2])
        expect(assigns(:places)).not_to include(@place1)
        expect(assigns(:places)).not_to include(@place3)
      end
    end

    describe 'GET #show w/ZIP format' do
      it 'returns a success response for a published layer' do
        layer = Layer.create! valid_attributes
        get :show, params: { id: layer.to_param, map_id: @map.id, format: 'zip' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/zip')
      end
    end

    describe 'preventing n+1 queries for GET #show w/JSON and w/GeoJSON format' do
      before do
        @map = FactoryBot.create(:map, published: true)
        @layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
        # Create 6 places with relations between them
        3.times do
          place1 = FactoryBot.create(:place, :with_audio, layer_id: @layer.id, tag_list: %w[aaa bbb ccc], published: true)
          place2 = FactoryBot.create(:place, layer_id: @layer.id, tag_list: %w[bbb ccc ddd], published: true)
          FactoryBot.create(:relation, relation_from: place1, relation_to: place2)
        end
      end

      def trigger_show_json
        get :show, params: { id: @layer.to_param, map_id: @map.id, format: 'json' }, session: valid_session
      end

      def trigger_show_geomap
        get :show, params: { id: @layer.to_param, map_id: @map.id, format: 'geojson' }, session: valid_session
      end

      def trigger_show_json_tags
        get :show, params: { id: @layer.to_param, map_id: @map.id, filter_by_tags: 'bbb,fff', format: 'json' }, session: valid_session
      end

      def trigger_show_geomap_tags
        get :show, params: { id: @layer.to_param, map_id: @map.id, filter_by_tags: 'bbb,fff', format: 'geojson' }, session: valid_session
      end

      it 'makes the same number of queries, no matter how many records are delivered' do
        # Measure queries before adding additional records
        x_json = count_queries { trigger_show_json }
        x_geo = count_queries { trigger_show_geomap }

        # Create 3 additional places with relations between them
        3.times do
          place1 = FactoryBot.create(:place, :with_audio, layer_id: @layer.id, tag_list: %w[aaa bbb ccc], published: true)
          place2 = FactoryBot.create(:place, layer_id: @layer.id, tag_list: %w[ccc ddd], published: true)
          FactoryBot.create(:relation, relation_from: place1, relation_to: place2)
        end

        # Measure queries after adding records
        y_json = count_queries { trigger_show_json }
        y_geo = count_queries { trigger_show_geomap }

        # Ensure query count remains the same
        expect(x_json).to eq(y_json)
        expect(x_geo).to eq(y_geo)
      end

      context 'when filtered by tag' do
        it 'makes the same number of queries, no matter how many records are delivered' do
          # Measure queries before adding additional records
          x_json_tags = count_queries { trigger_show_json_tags }
          x_geo_tags = count_queries { trigger_show_geomap_tags }

          # Create 3 additional places with relations between them
          3.times do
            place1 = FactoryBot.create(:place, :with_audio, layer_id: @layer.id, tag_list: %w[aaa bbb ccc], published: true)
            place2 = FactoryBot.create(:place, layer_id: @layer.id, tag_list: %w[ccc ddd], published: true)
            FactoryBot.create(:relation, relation_from: place1, relation_to: place2)
          end

          # Measure queries after adding records
          y_json_tags = count_queries { trigger_show_json_tags }
          y_geo_tags = count_queries { trigger_show_geomap_tags }

          # Ensure query count remains the same
          expect(x_json_tags).to eq(y_json_tags)
          expect(x_geo_tags).to eq(y_geo_tags)
        end
      end
    end
  end
end
