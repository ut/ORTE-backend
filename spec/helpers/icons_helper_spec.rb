# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IconsHelper, type: :helper do
  let(:iconset) { create(:iconset) }

  describe 'icon_url' do
    it 'it returns an polymorphic image link' do
      i = Icon.new
      i.iconset = iconset
      i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      i.save!
      expect(helper.icon_url(i.file)).to eq("http://test.host#{rails_blob_path(i.file)}")
    end
  end
  describe 'icon_linktag' do
    it 'it returns an image link tag' do
      i = Icon.new
      i.iconset = iconset
      i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      i.save!
      expect(helper.icon_linktag(i.file)).to eq("<img src=\"http://test.host#{rails_blob_path(i.file)}\">")
    end
  end
end
