# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'videos/index', type: :view do
  before(:each) do
    @map = FactoryBot.create(:map)
    @layer = FactoryBot.create(:layer, map_id: @map.id)
    @place1 = FactoryBot.create(:place, layer_id: @layer.id)
    @place2 = FactoryBot.create(:place, layer_id: @layer.id)
    assign(:videos, [
             Video.create!(
               title: 'Title1',
               licence: 'Licence',
               source: 'Source',
               creator: 'Creator',
               place: @place1,
               alt: 'Alt',
               caption: 'Caption',
               sorting: 2,
               preview: false
             ),
             Video.create!(
               title: 'Title2',
               licence: 'Licence',
               source: 'Source',
               creator: 'Creator',
               place: @place2,
               alt: 'Alt',
               caption: 'Caption',
               sorting: 2,
               preview: false
             )
           ])
  end

  it 'renders a list of videos' do
    render
    expect(rendered).to match(/Title1/)
    expect(rendered).to match(/Title2/)
  end
end
