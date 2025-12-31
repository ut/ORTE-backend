# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'videos/show', type: :view do
  before(:each) do
    @map = FactoryBot.create(:map)
    @layer = FactoryBot.create(:layer, map_id: @map.id)
    @place = FactoryBot.create(:place, layer_id: @layer.id)
    @video = FactoryBot.create(:video, place_id: @place.id)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(@video.title)
    expect(rendered).to match(@video.licence)
    expect(rendered).to match(@video.source)
    expect(rendered).to match(@video.creator)
    expect(rendered).to match(@video.alt)
    expect(rendered).to match(@video.caption)
    expect(rendered).to match(@video.sorting.to_s)
  end
end
