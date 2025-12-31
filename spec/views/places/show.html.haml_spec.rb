# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'places/show', type: :view do
  before(:each) do
    @map = FactoryBot.create(:map)
    @layer = FactoryBot.create(:layer, map_id: @map.id)
    @place = FactoryBot.create(:place, layer_id: @layer.id, published: false)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(@place.title)
    expect(rendered).to match(@place.teaser)
    expect(rendered).to match(@place.text)
    expect(rendered).to match(@place.location)
    expect(rendered).to match(@place.address)
    expect(rendered).to match(@place.zip)
    expect(rendered).to match(@place.city)
    expect(rendered).to match("<i class='fi-lock fi-18'></i>")
    expect(rendered).to match(//)
  end
end
