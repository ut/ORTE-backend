# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VideosHelper, type: :helper do
  let(:place) { create(:place) }

  describe 'video_url' do
    it 'it returns an polymorphic video link' do
      i = Video.new
      i.title = 'ttt'
      i.place = place
      i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'video.mp4', content_type: 'video/mp4')
      i.save!
      expect(helper.video_url(i.file)).to eq(polymorphic_url(i.file).to_s)
    end
  end
  describe 'video_linktag' do
    it 'it returns an video link tag with a filmstill' do
      i = Video.new
      i.title = 'ttt'
      i.place = place
      i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'video.mp4', content_type: 'video/mp4')
      i.filmstill.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'filmstill.jpg', content_type: 'image/jepg')
      i.save!
      expect(helper.video_linktag(i.file, i.filmstill)).to eq("<video controls=\"controls\" preload=\"metadata\" poster=\"#{polymorphic_url(i.filmstill)}\" src=\"#{polymorphic_url(i.file)}\"></video>")
    end
    it 'it returns an video link tag without a filmstill' do
      i = Video.new
      i.title = 'ttt'
      i.place = place
      i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'video.mp4', content_type: 'video/mp4')
      i.save!
      expect(helper.video_linktag(i.file, nil)).to eq("<video controls=\"controls\" preload=\"metadata\" src=\"#{polymorphic_url(i.file)}\"></video>")
    end
  end
end
