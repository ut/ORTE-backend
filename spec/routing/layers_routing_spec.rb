# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LayersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/maps/1/layers').to route_to('layers#index', map_id: '1')
    end

    it 'routes to #import' do
      expect(get: '/maps/1/layers/1/import').to route_to('layers#import', id: '1', map_id: '1')
    end

    it 'routes to #importing' do
      expect(post: '/maps/1/layers/1/importing').to route_to('layers#importing', id: '1', map_id: '1')
    end

    it 'routes to #new' do
      expect(get: '/maps/1/layers/new').to route_to('layers#new', map_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/maps/1/layers/1').to route_to('layers#show', id: '1', map_id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/maps/1/layers/1/edit').to route_to('layers#edit', id: '1', map_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/maps/1/layers').to route_to('layers#create', map_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/maps/1/layers/1').to route_to('layers#update', id: '1', map_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/maps/1/layers/1').to route_to('layers#update', id: '1', map_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/maps/1/layers/1').to route_to('layers#destroy', id: '1', map_id: '1')
    end
  end
end
