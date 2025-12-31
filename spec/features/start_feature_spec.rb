# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Visitors view startpage and ' do
  scenario 'will use the specific js driver', js: true do
    visit root_path
    expect(page).to have_content('Javascript enabled')
  end
end

RSpec.feature 'Login' do
  scenario 'shows login form', js: true do
    visit root_path
    click_link 'Sign in'
    expect(page).to have_current_path '/users/sign_in'
    expect(page).to have_content 'Sign in'
  end

  scenario 'shows error if login with wrong credentials' do
    visit root_path
    click_link 'Sign in'
    fill_in 'user_email', with: 'nobody@nowhere.com'
    fill_in 'user_password', with: 'abcdefghijklmn'
    click_button 'Log in'
    expect(page).to have_content 'Invalid Email or password'
  end

  scenario 'shows success message if login with credentials worked' do
    group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, group_id: group.id)
    visit root_path
    click_link 'Sign in'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
    expect(page).to have_current_path '/maps'
    expect(page).to have_content I18n.t('devise.sessions.signed_in')
  end
end

RSpec.feature 'Logout' do
  scenario 'shows success message if logout was succesful', js: true do
    group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, group_id: group.id)
    visit root_path
    click_link 'Sign in'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
    expect(page).to have_current_path '/maps'
    find(:css, '#logout').click
    expect(page).to have_content I18n.t('devise.sessions.signed_out')
  end
end
