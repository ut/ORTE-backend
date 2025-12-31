# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'places/index', type: :view do
  before(:each) do
    @map = FactoryBot.create(:map)
    @layer = FactoryBot.create(:layer, map_id: @map.id)
    @other_layer = FactoryBot.create(:layer, map_id: @map.id)
    place1 = FactoryBot.create(:place, layer_id: @layer.id, title: 'Title1')
    place2 = FactoryBot.create(:place, layer_id: @layer.id, title: 'Title2')
    @places = Kaminari.paginate_array([place1, place2]).page(1)
  end

  it 'renders a list of places' do
    render
    expect(rendered).to match(/Title1/)
    expect(rendered).to match(/Title2/)
  end
end
