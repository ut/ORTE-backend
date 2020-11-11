# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Video, type: :model do
  it 'has a valid factory' do
    expect(build(:video)).to be_valid
  end

  describe 'Attachment' do
    it 'is valid' do
      subject.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'attachment.mp4', content_type: 'video/mp4')
      expect(subject.file).to be_attached
    end
  end
end
