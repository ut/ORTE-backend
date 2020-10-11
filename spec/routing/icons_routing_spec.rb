# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IconsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/iconsets/1/icons').not_to be_routable
    end

    it 'routes to #show' do
      expect(get: '/iconsets/1/icons/1').not_to be_routable
    end

    it 'routes to #new' do
      expect(get: '/iconsets/1/icons/new').not_to be_routable
    end


    it 'routes to #edit' do
      expect(get: '/iconsets/1/icons/1/edit').to route_to('icons#edit', id: '1', iconset_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/iconsets/1/icons').not_to be_routable
    end

    it 'routes to #update via PUT' do
      expect(put: '/iconsets/1/icons/1').to route_to('icons#update', id: '1', iconset_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/iconsets/1/icons/1').to route_to('icons#update', id: '1', iconset_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/iconsets/1/icons/1').to route_to('icons#destroy', id: '1', iconset_id: '1')
    end
  end
end
