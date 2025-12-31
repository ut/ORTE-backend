# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Public::MapsController, type: :controller do
  render_views

  describe 'functionalities with anonymous access' do
    before do
      @group = FactoryBot.create(:group)
      user = FactoryBot.create(:admin_user, group_id: @group.id)
    end

    let(:map) do
      FactoryBot.create(:map, group_id: @group.id)
    end

    let(:valid_attributes) do
      FactoryBot.build(:map, group_id: @group.id, published: true).attributes
    end

    let(:invalid_attributes) do
      FactoryBot.build(:map, group_id: @group.id, published: false).attributes
    end

    let(:valid_session) { {} }

    describe 'GET #index' do
      it 'returns a 403' do
        map = Map.create! valid_attributes
        get :index, params: { format: 'json' }, session: valid_session
        expect(response).to have_http_status(403)
      end
    end

    describe 'GET #show' do
      it 'returns a success response for a published map' do
        map = Map.create! valid_attributes
        get :show, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
      end

      it 'returns json for a published map' do
        map = Map.create! valid_attributes
        get :show, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'returns json with a valid scheme' do
        map = Map.create! valid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :show, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to match_response_schema('map', 'json')
      end

      it 'returns an 403 + error response for unpublished resources' do
        map = Map.create! invalid_attributes
        get :show, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(403)
        expect(JSON.parse(response.body)['error']).to match(/Map not accessible/)
      end

      it 'returns all places when not filtered by tag' do
        map = Map.create! valid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        FactoryBot.create(:place, layer: layer, published: true, tag_list: %w[aaa bbb ccc])
        FactoryBot.create(:place, layer: layer, published: true, tag_list: %w[ddd eee])
        FactoryBot.create(:place, layer: layer, published: true, tag_list: %w[fff])

        get :show, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['map']['layer'][0]['places'].length).to eq 3
      end

      context 'when filtering by tags' do
        let!(:map) { create(:map, valid_attributes) }
        let!(:layer) { create(:layer, map_id: map.id, published: true) }
        let!(:place1) { create(:place, layer: layer, published: true, tag_list: %w[aaa bbb ccc]) }
        let!(:place2) { create(:place, layer: layer, published: true, tag_list: %w[ddd eee]) }
        let!(:place3) { create(:place, layer: layer, published: true, tag_list: %w[bbb fff]) }
        let!(:place4) { create(:place, layer: layer, published: true, tag_list: %w[fff aaa bbb]) }

        it 'returns only accordingly tagged places with any tag when filtered by tag' do
          get :show, params: { id: map.friendly_id, filter_by_tags: 'bbb,fff', format: 'json' }, session: valid_session
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['map']['layer'][0]['places'].length).to eq 3
          expect(json['map']['layer'][0]['places'][0]['title']).to eq place1.title
          expect(json['map']['layer'][0]['places'][1]['title']).to eq place3.title
          expect(json['map']['layer'][0]['places'][2]['title']).to eq place4.title
          expect(json['map']['layer'][0]['places'][0]['tags']).to eq %w[aaa bbb ccc]
          expect(json['map']['layer'][0]['places'][1]['tags']).to eq %w[bbb fff]
          expect(json['map']['layer'][0]['places'][2]['tags']).to eq %w[aaa bbb fff]
        end

        it 'returns only accordingly tagged places with all tags when filtered by tag with match all param' do
          get :show, params: { id: map.friendly_id, filter_by_tags: 'bbb,fff', match_all: true, format: 'json' }, session: valid_session
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['map']['layer'][0]['places'].length).to eq 2
          expect(json['map']['layer'][0]['places'][0]['title']).to eq place3.title
          expect(json['map']['layer'][0]['places'][1]['title']).to eq place4.title
          expect(json['map']['layer'][0]['places'][0]['tags']).to eq %w[bbb fff]
          expect(json['map']['layer'][0]['places'][1]['tags']).to eq %w[aaa bbb fff]
        end
      end

      it 'can handle images with and without sorting values' do
        map = Map.create! valid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        FactoryBot.create(:image, place: place, sorting: nil)
        FactoryBot.create(:image, place: place, sorting: 1)
        get :show, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    describe 'GET #allplaces' do
      it 'returns a success response for a published map' do
        map = Map.create! valid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :allplaces, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
      end

      it 'returns json for a published map' do
        map = Map.create! valid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :allplaces, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'returns json with a valid scheme' do
        map = Map.create! valid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :allplaces, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to match_response_schema('map_allplaces', 'json')
      end

      it 'returns only accordingly tagged places when filtered by tag' do
        map = Map.create! valid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        place1 = FactoryBot.create(:place, layer: layer, published: true, tag_list: %w[aaa bbb ccc])
        place2 = FactoryBot.create(:place, layer: layer, published: true, tag_list: %w[ddd eee])
        place3 = FactoryBot.create(:place, layer: layer, published: true, tag_list: %w[fff])

        get :allplaces, params: { id: map.friendly_id, filter_by_tags: 'bbb,fff', format: 'json' }, session: valid_session
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['map']['places'].length).to eq 2
        expect(json['map']['places'][0]['title']).to eq place1.title
        expect(json['map']['places'][1]['title']).to eq place3.title
        expect(json['map']['places'][0]['tags']).to eq %w[aaa bbb ccc]
        expect(json['map']['places'][1]['tags']).to eq %w[fff]
      end
      context 'when filtering by tags' do
        let!(:map) { create(:map, valid_attributes) }
        let!(:layer) { create(:layer, map_id: map.id, published: true) }
        let!(:place1) { create(:place, layer: layer, published: true, tag_list: %w[aaa bbb ccc]) }
        let!(:place2) { create(:place, layer: layer, published: true, tag_list: %w[ddd eee]) }
        let!(:place3) { create(:place, layer: layer, published: true, tag_list: %w[bbb fff]) }
        let!(:place4) { create(:place, layer: layer, published: true, tag_list: %w[fff aaa bbb]) }

        it 'returns only accordingly tagged places with any tag when filtered by tag' do
          get :allplaces, params: { id: map.friendly_id, filter_by_tags: 'bbb,fff', format: 'json' }, session: valid_session
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['map']['places'].length).to eq 3
          expect(json['map']['places'][0]['title']).to eq place1.title
          expect(json['map']['places'][1]['title']).to eq place3.title
          expect(json['map']['places'][2]['title']).to eq place4.title
          expect(json['map']['places'][0]['tags']).to eq %w[aaa bbb ccc]
          expect(json['map']['places'][1]['tags']).to eq %w[bbb fff]
          expect(json['map']['places'][2]['tags']).to eq %w[aaa bbb fff]
        end

        it 'returns only accordingly tagged places with all tags when filtered by tag with match all param' do
          get :allplaces, params: { id: map.friendly_id, filter_by_tags: 'bbb,fff', match_all: true, format: 'json' }, session: valid_session
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['map']['places'].length).to eq 2
          expect(json['map']['places'][0]['title']).to eq place3.title
          expect(json['map']['places'][1]['title']).to eq place4.title
          expect(json['map']['places'][0]['tags']).to eq %w[bbb fff]
          expect(json['map']['places'][1]['tags']).to eq %w[aaa bbb fff]
        end
      end

      it 'returns an 403 + error response for unpublished resources' do
        map = Map.create! invalid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        get :allplaces, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response).to have_http_status(403)
        expect(JSON.parse(response.body)['error']).to match(/Map not accessible/)
      end

      it 'can handle images with and without sorting values' do
        map = Map.create! valid_attributes
        layer = FactoryBot.create(:layer, map_id: map.id, published: true)
        place = FactoryBot.create(:place, layer_id: layer.id, published: true)
        FactoryBot.create(:image, place: place, sorting: nil)
        FactoryBot.create(:image, place: place, sorting: 1)
        get :allplaces, params: { id: map.friendly_id, format: 'json' }, session: valid_session
        expect(response.status).to eq 200
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    describe 'preventing n+1 queries for GET #show GET #allplaces format' do
      before do
        @map = FactoryBot.create(:map, published: true)
        @layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
        # Create 6 places with relations between them
        3.times do
          place1 = FactoryBot.create(:place, :with_audio, layer_id: @layer.id, tag_list: %w[aaa bbb], published: true)
          place2 = FactoryBot.create(:place, layer_id: @layer.id, tag_list: %w[ccc], published: true)
          FactoryBot.create(:relation, relation_from: place1, relation_to: place2)
        end
      end

      def trigger_show
        get :show, params: { id: @map.id, format: 'json' }, session: valid_session
      end

      def trigger_tag_filter
        get :show, params: { id: @map.id, filter_by_tags: 'bbb,fff', format: 'json' }, session: valid_session
      end

      def trigger_allplaces
        get :allplaces, params: { id: @map.id, format: 'json' }, session: valid_session
      end

      it 'makes the same number of queries, no matter how many records are delivered' do
        # Measure queries before adding additional records
        x_show = count_queries { trigger_show }
        x_all = count_queries { trigger_allplaces }

        # Create 3 additional layers and 18 additional places with relations between them
        3.times do
          layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
          3.times do
            place1 = FactoryBot.create(:place, :with_audio, layer_id: layer.id, tag_list: %w[aaa bbb], published: true)
            place2 = FactoryBot.create(:place, layer_id: layer.id, tag_list: %w[ccc], published: true)
            FactoryBot.create(:relation, relation_from: place1, relation_to: place2)
          end
        end

        # Measure queries after adding records
        y_show = count_queries { trigger_show }
        y_all = count_queries { trigger_allplaces }

        # Ensure query count remains the same
        expect(x_show).to eq(y_show)
        expect(x_all).to eq(y_all)
      end

      context 'when filtered by tag' do
        it 'makes the same number of queries, no matter how many records are delivered' do
          # Measure queries before adding additional records
          x_tags = count_queries { trigger_tag_filter }

          # Create 3 additional layers and 18 additional places with relations between them
          3.times do
            layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
            3.times do
              place1 = FactoryBot.create(:place, :with_audio, layer_id: layer.id, tag_list: %w[aaa bbb], published: true)
              place2 = FactoryBot.create(:place, layer_id: layer.id, tag_list: %w[ccc], published: true)
              FactoryBot.create(:relation, relation_from: place1, relation_to: place2)
            end
          end

          # Measure queries after adding records
          y_tags = count_queries { trigger_tag_filter }

          # Ensure query count remains the same
          expect(x_tags).to eq(y_tags)
        end
      end
    end
  end
end
