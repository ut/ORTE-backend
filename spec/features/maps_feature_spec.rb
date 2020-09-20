# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User may create a map ' do
  before do
    @group = FactoryBot.create(:group)
    user = FactoryBot.create(:user, group_id: @group.id)
    visit root_path
    click_link 'Sign in'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
  end

  scenario 'shows a create form and saves a map (on a first map)', js: false do
    expect(page).to have_current_path '/maps'
    expect(page).to have_content 'Add a map'
    click_link 'Add a map'
    expect(page).to have_current_path '/maps/new'
    fill_in 'map_title', with: "My first map"
    # TODO: capybara does not find the button
    # save_and_open_page
    # expect(page).to have_button("Create map")
    # click_button 'Create map', disabled: true
    # expect(page).to have_content 'Map was successfully created.'

  end

  scenario 'shows a create form and saves a map (on any further maps)', js: true do
    expect(page).to have_current_path '/maps'
    @my_first_map = FactoryBot.create(:map, group_id: @group.id)
    visit '/maps'
    expect(page).to have_content 'Select a map...'
    click_link 'new_map_button'
    expect(page).to have_current_path '/maps/new'
    fill_in 'map_title', with: "My second map"
    # click_button 'Create map'
    # expect(page).to have_content 'Map was successfully created.'
  end
end
