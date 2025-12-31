# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Public::TagsController, type: :controller do
  render_views

  describe 'functionalities with anonymous access' do
    before do
      @map = FactoryBot.create(:map, published: true)
      @layer = FactoryBot.create(:layer, map_id: @map.id, published: true)
      # create some additional places with tags belonging to another map and unpublished place and layers whose tags
      # should not be returned and whose taggings should not be included in the taggings count
      another_map = FactoryBot.create(:map, published: true)
      another_layer = FactoryBot.create(:layer, map_id: another_map.id, published: true)
      unpublished_layer = FactoryBot.create(:layer, map_id: @map.id, published: false)
      FactoryBot.create(:place, layer_id: another_layer.id, published: true, tag_list: %w[ddd])
      FactoryBot.create(:place, layer_id: unpublished_layer.id, published: true, tag_list: %w[ddd])
      FactoryBot.create(:place, layer_id: another_layer.id, published: true, tag_list: %w[xyz])
      FactoryBot.create(:place, layer_id: @layer.id, published: false, tag_list: %w[ddd xyz])
    end
    let(:valid_session) { {} }

    describe 'GET #index' do
      context 'when map is not available' do
        it 'returns a 403 if map is not available' do
          get :index, params: { map_id: 'notexisting', format: 'json' }, session: valid_session
          expect(response).to have_http_status(403)
        end
      end

      context 'when map is available' do
        it 'returns a success response and a list of all available tags, ordered by name' do
          FactoryBot.create(:tag, name: 'aaa') # not used tag should not be returned
          FactoryBot.create(:place, layer_id: @layer.id, published: true, tag_list: %w[ddd])
          FactoryBot.create(:place, layer_id: @layer.id, published: true, tag_list: %w[bbb ddd])

          get :index, params: { map_id: @map.id, format: 'json' }, session: valid_session

          expect(response).to have_http_status(200)
          json = response.parsed_body
          expect(json.length).to eq 2
          expect(json[0]['name']).to eq 'bbb'
          expect(json[0]['taggings_count']).to eq 1
          expect(json[1]['name']).to eq 'ddd'
          expect(json[1]['taggings_count']).to eq 2
        end
      end

      context 'with layer_id param' do
        context 'when layer_id is not available' do
          it 'returns a 403 if layer is not available' do
            get :index, params: { map_id: @map.id, layer_id: 'notexisting', format: 'json' }, session: valid_session
            expect(response).to have_http_status(403)
          end
        end

        context 'when requested layer belongs to another map' do
          it 'returns a 403 if layer is not available' do
            map2 = FactoryBot.create(:map, published: true)
            layer2 = FactoryBot.create(:layer, map_id: map2.id)
            get :index, params: { map_id: @map.id, layer_id: layer2.id, format: 'json' }, session: valid_session
            expect(response).to have_http_status(403)
          end
        end

        context 'when layer_id is available' do
          it 'returns a success response and a list of all available tags, ordered by name' do
            layer2 = FactoryBot.create(:layer, map_id: @map.id)
            FactoryBot.create(:tag, name: 'aaa') # not used tag should not be returned
            FactoryBot.create(:place, layer_id: @layer.id, published: true, tag_list: %w[ddd])
            FactoryBot.create(:place, layer_id: layer2.id, published: true, tag_list: %w[bbb ddd])

            get :index, params: { map_id: @map.id, layer_id: @layer.id, format: 'json' }, session: valid_session

            expect(response).to have_http_status(200)
            json = response.parsed_body
            expect(json[0]['name']).to eq 'ddd'
            expect(json[0]['taggings_count']).to eq 1
            expect(json.length).to eq 1
          end
        end
      end
    end
  end
end
