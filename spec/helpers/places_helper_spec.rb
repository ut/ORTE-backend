# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlacesHelper, type: :helper do
  describe 'default_url_options' do
    it 'it returns an array with hostname' do
      expect(helper.default_url_options).to eq({})
    end
  end

  describe 'edit_link' do
    it 'it returns a visual edit link' do
      expect(helper.edit_link(1, 2, 3)).to eq(" <a href=\"/maps/1/layers/2/places/3/edit\" class='edit_link'><i class='fi fi-pencil'></i></a>")
    end
  end

  describe 'image_link' do
    it 'it returns an polymorphic image link' do
      i = Image.new
      i.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      expect(helper.image_link(i)).to eq("http://test.host#{polymorphic_path(i.file.variant(resize: "800x800").processed)}")
    end
  end

  describe 'icon_link' do
    it 'it returns an polymorphic icon link' do
      i = Icon.new
      i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      expect(helper.icon_link(i.file)).to eq("<img src=\"http://test.host#{rails_blob_path(i.file)}\">")
    end
  end

  describe 'icon_name' do
    it 'it returns the icon name' do
      expect(helper.icon_name('Test')).to eq('Test')
    end
  end

  describe 'icon_class' do
    it 'it returns an polymorphic icon link' do
      expect(helper.icon_class('circle','Test')).to eq("icon_circle icon_test")
    end
  end

  describe 'audio_link' do
    it 'it returns an polymorphic audio link' do
      p = Place.new
      p.audio.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp3')), filename: 'attachment.mp3', content_type: 'audio/mpeg')
      expect(helper.audio_link(p.audio)).to eq("<audio autoplay=\"autoplay\" controls=\"controls\" src=\"http://test.host#{rails_blob_path(p.audio)}\"></audio>")
    end
  end
end
