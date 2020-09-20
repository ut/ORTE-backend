# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/edit', type: :view do
  before(:each) do
    group = FactoryBot.create(:group)
    @user = assign(:admin_user, FactoryBot.create(:user, group_id: group.id))
  end

  it 'renders the edit admin_user form' do
    render
    assert_select 'form[action=?][method=?]', admin_user_path(@user), 'post' do
    end
  end
end
