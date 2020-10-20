# frozen_string_literal: true

require 'rails_helper'


RSpec.describe Icon, type: :model do
  it 'has a valid factory' do
    expect(build(:icon)).to be_valid
  end

  xit 'icon_linktag' do
    subject.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.png', content_type: 'image/jpeg')
    expect(subject.icon_linktag).to eq(Rails.application.routes.url_helpers.url_for(subject.file))
  end

  describe 'Image attachment' do

    let(:iconset) { FactoryBot.create(:iconset) }

    it 'is attached' do
      subject.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'test.jpg', content_type: 'image/jpeg')
      expect(subject.file).to be_attached
    end
    it 'is invalid ' do
      subject.iconset = iconset
      subject.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.txt')), filename: 'test.txt', content_type: '')
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include("File format must be either SVG (preferred), PNG, GIF or JPEG.")
    end
  end
end
