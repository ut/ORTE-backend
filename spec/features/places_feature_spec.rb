# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User creates and updates a place ' do
  before do
    @group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, group_id: @group.id)
    visit root_path
    click_link 'Sign in'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
  end

  scenario 'provides lookup interface and proposes possible locations', js: true do
    @map = FactoryBot.create(:map, group_id: @group.id)
    @layer = FactoryBot.create(:layer, map_id: @map.id, title: 'my layer')

    visit map_layer_path(@map, @layer)
    expect(page).to have_current_path "/maps/#{@map.slug}/layers/#{@layer.slug}"
    fill_in 'addresslookup_address', with: 'Hamburg'
    within '#selection-hint' do
      expect(page).to have_content 'How to map:'
    end
    click_button 'addresslookup_button'
    within '#selection-hint' do
      expect(page).to have_content 'Searching...'
    end

    within '#selection-hint' do
      # expect(page).to have_content 'Please select one result below (or type in another address).'
    end
  end

  scenario 'shows edit form (and provide only allowed layers to select)', js: true do
    @map = FactoryBot.create(:map, group_id: @group.id)
    @layer = FactoryBot.create(:layer, map_id: @map.id, title: 'my layer')

    @other_group = FactoryBot.create(:group)
    @other_map = FactoryBot.create(:map, group_id: @other_group.id)
    @other_layer = FactoryBot.create(:layer, map_id: @other_map.id, title: 'other layer')
    @place = FactoryBot.create(:place, layer_id: @layer.id)
    visit edit_map_layer_place_path(@map, @layer, @place)
    expect(page).to have_content 'my layer'
    expect(page).not_to have_content 'other layer'
  end

  scenario 'shows edit form (and place some text into a tinymce textarea filed)', js: true do
    @map = FactoryBot.create(:map, group_id: @group.id)
    @layer = FactoryBot.create(:layer, map_id: @map.id, title: 'my layer')

    @other_group = FactoryBot.create(:group)
    @other_map = FactoryBot.create(:map, group_id: @other_group.id)
    @other_layer = FactoryBot.create(:layer, map_id: @other_map.id, title: 'other layer')
    @place = FactoryBot.create(:place, layer_id: @layer.id)
    visit edit_map_layer_place_path(@map, @layer, @place)
    expect(page).to have_css('div.tox-tinymce')
    expect(page).to have_css('iframe#place_teaser_ifr')
    page.execute_script('tinymce.get("place_teaser").setContent("updated content");')
    within_frame('place_teaser_ifr') do
      expect(page).to have_css('body#tinymce p', text: 'updated content')
    end
  end
end
