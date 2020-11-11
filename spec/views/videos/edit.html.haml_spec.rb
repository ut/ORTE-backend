# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'videos/edit', type: :view do
  before(:each) do
    @map = FactoryBot.create(:map)
    @layer = FactoryBot.create(:layer, map_id: @map.id)
    @place = FactoryBot.create(:place, layer_id: @layer.id)
    @video = FactoryBot.create(:video, place_id: @place.id)
  end

  it 'renders the edit video form' do
    render

    assert_select 'form[action=?][method=?]', map_layer_place_video_path(@map, @layer, @place, @video), 'post' do
      assert_select 'input[name=?]', 'video[title]'

      assert_select 'input[name=?]', 'video[licence]'

      assert_select 'textarea[name=?]', 'video[source]'

      assert_select 'input[name=?]', 'video[creator]'

      assert_select 'input[name=?]', 'video[alt]'

      assert_select 'input[name=?]', 'video[caption]'

      assert_select 'input[name=?]', 'video[sorting]'

      assert_select 'input[name=?]', 'video[preview]'
    end
  end
end
