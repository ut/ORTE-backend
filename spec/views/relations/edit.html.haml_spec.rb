# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'relations/edit', type: :view do
  before(:each) do
    @map = create(:map)
    layer = create(:layer, map: @map)
    @layers = [layer]
    p1 = create(:place)
    p2 = create(:place)
    @relation = create(:relation, relation_from_id: p1.id, relation_to_id: p2.id)
  end

  it 'renders the edit relation form' do
    render

    assert_select 'form[action=?][method=?]', map_relation_path(@map, @relation), 'post'
  end
end
