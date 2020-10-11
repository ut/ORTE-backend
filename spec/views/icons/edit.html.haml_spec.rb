# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'icons/edit', type: :view do
  before(:each) do
    @iconset = FactoryBot.create(:iconset)
    @icon = FactoryBot.create(:icon, iconset_id: @iconset.id)
  end

  it 'renders the edit icon form' do
    render

    assert_select 'form[action=?][method=?]', iconset_icon_path(@iconset, @icon), 'post' do
      assert_select 'input[name=?]', 'icon[title]'

    end
  end
end
