# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Adding and removing tags ' do
  before do
    @group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, group_id: @group.id)
    visit root_path
    click_link 'Sign in'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
  end

  scenario 'allows users to add a tag', js: true do
    @map = FactoryBot.create(:map, group_id: @group.id)
    @layer = FactoryBot.create(:layer, map_id: @map.id, title: 'my layer')
    tag1 = FactoryBot.create(:tag, name: 'alpha')
    tag2 = FactoryBot.create(:tag, name: 'beta')
    @place = FactoryBot.create(:place, layer_id: @layer.id, tag_list: [tag1,tag2])
    visit edit_map_layer_place_path(@map, @layer, @place)
    option1 = find('#place_tag_list').find(:xpath, 'option[1]')
    expect(option1).to have_content 'alpha'
    option1.select_option
    click_button 'Update Place'
    # TODO: check if "alpha" has been saved
    # @place.reload!
  end
end
