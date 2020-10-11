# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'iconsets/edit', type: :view do
  before(:each) do
    @iconset = assign(:iconset, Iconset.create!(
                                  title: 'MyString',
                                  text: 'MyText'
                                ))
  end

  it 'renders the edit iconset form' do
    render

    assert_select 'form[action=?][method=?]', iconset_path(@iconset), 'post' do
      assert_select 'input[name=?]', 'iconset[title]'

      assert_select 'textarea[name=?]', 'iconset[text]'

    end
  end
end
