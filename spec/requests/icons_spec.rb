# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Icons', type: :request do
  describe 'GET /iconsets/1/icons/1/edit' do
    it 'gets redirected to login' do
      get edit_iconset_icon_path(1,1)
      expect(response).to have_http_status(302)
    end
  end
end
