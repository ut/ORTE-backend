# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User views a map and may create a new one ' do
  before do
    @group = FactoryBot.create(:group)
    user = FactoryBot.create(:user, group_id: @group.id)
    visit root_path
    click_link 'Sign in'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
  end

  describe ' with js', js: true do
    scenario 'shows a map view with a leaflet map container' do
      @map = FactoryBot.create(:map, group_id: @group.id)
      @layer = FactoryBot.create(:layer, map_id: @map.id, title: 'my layer')
      @place = FactoryBot.create(:place, layer_id: @layer.id, title: 'my place')
      @place2 = FactoryBot.create(:place, layer_id: @layer.id, title: 'my place')
      visit "/maps/#{@map.slug}"
      expect(page).to have_current_path "/maps/#{@map.slug}"
      within '#map' do
        expect(page).to have_css('.leaflet-tile-container')
        expect(page).to have_css('.leaflet-control-container')
      end
    end

    scenario 'shows a create form and saves a map (as a first map)' do
      expect(page).to have_current_path '/maps'
      expect(page).to have_content 'Add a map'
      click_link 'Add a map'
      expect(page).to have_current_path '/maps/new'
      fill_in 'map_title', with: 'My first map'
      # TODO: capybara does not find the button
      # save_and_open_page
      # expect(page).to have_button("Create map")
      # click_button 'Create map', disabled: true
      # expect(page).to have_content 'Map was successfully created.'
    end

    scenario 'shows a create form and saves a map (upon existing maps)' do
      expect(page).to have_current_path '/maps'
      @my_first_map = FactoryBot.create(:map, group_id: @group.id)
      visit '/maps'
      expect(page).to have_content 'Select a map...'
      click_link 'new_map_button'
      expect(page).to have_current_path '/maps/new'
      fill_in 'map_title', with: 'My second map'
      # click_button 'Create map'
      # expect(page).to have_content 'Map was successfully created.'
    end
  end
end
