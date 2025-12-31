# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'images/show', type: :view do
  before(:each) do
    @map = FactoryBot.create(:map)
    @layer = FactoryBot.create(:layer, map_id: @map.id)
    @place = FactoryBot.create(:place, layer_id: @layer.id)
    @image = FactoryBot.create(:image, place_id: @place.id)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(@image.title)
    expect(rendered).to match(@image.licence)
    expect(rendered).to match(@image.source)
    expect(rendered).to match(@image.creator)
    expect(rendered).to match(@image.alt)
    expect(rendered).to match(@image.caption)
    expect(rendered).to match(@image.sorting.to_s)
  end
end
