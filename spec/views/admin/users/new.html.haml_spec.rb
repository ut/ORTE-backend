# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/new', type: :view do
  before(:each) do
    group = FactoryBot.create(:group)
    user = assign(:admin_user, User.new(
                                 email: 'you@home.com',
                                 password: '1235657',
                                 role: 'user',
                                 group: group
                               ))
  end

  it 'renders new admin_user form' do
    render

    assert_select 'form[action=?][method=?]', admin_users_path, 'post'
  end
end
