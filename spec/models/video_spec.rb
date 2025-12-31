# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:video) { create(:video) }

  it 'has a valid factory' do
    expect(video).to be_valid
  end

  describe 'Attachment' do
    it 'is valid' do
      video.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'attachment.mp4', content_type: 'video/mp4')
      video.save!
      expect(video.file).to be_attached
    end
  end

  it 'video_url' do
    video.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'attachment.jpg', content_type: 'video/mp4')
    expect(video.video_url).to eq(Rails.application.routes.url_helpers.url_for(video.file))
  end
  it 'video_linktag' do
    video.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'attachment.jpg', content_type: 'video/mp4')
    video.filmstill.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'filmstill.jpg', content_type: 'image/jepg')
    video.save!
    expect(video.video_linktag).to eq("<video controls=\"controls\" preload=\"metadata\" poster=\"#{Rails.application.routes.url_helpers.url_for(video.filmstill)}\" src=\"#{Rails.application.routes.url_helpers.url_for(video.file)}\"></video>")
  end
end
