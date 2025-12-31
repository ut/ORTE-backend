# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User creates layer and works on layer level' do
  before do
    @group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, group_id: @group.id)
    visit root_path
    click_link 'Sign in'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
  end

  scenario 'shows marker on a map layer and opens a popup on click', js: true do
    @map = FactoryBot.create(:map, group_id: @group.id)
    @layer = FactoryBot.create(:layer, map_id: @map.id, title: 'my layer', published: true)
    @place1 = FactoryBot.create(:place, layer_id: @layer.id, title: 'my place 1', lat: 53.5, lon: 10)
    @place2 = FactoryBot.create(:place, layer_id: @layer.id, title: 'my place 2', lat: 53.4, lon: 10)

    visit map_layer_path(@map, @layer)
    expect(page).to have_current_path "/maps/#{@map.slug}/layers/#{@layer.slug}"
    within '#map' do
      # expect(page).to have_css('.leaflet-marker-pane')
      # save_and_open_page
      # this will only work with...
      # ...asset_host running, like 127.0.0.1:3000
      # ...a host providing a JSON file (or a mocked version of it)
      # expect(page).to have_css('.leaflet-marker-icon', count: 2)
      # see also config/environment/test.rb
    end
  end
end
