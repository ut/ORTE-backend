# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Image, type: :model do
  it 'has a valid factory' do
    expect(build(:image)).to be_valid
  end

  describe 'Attachment' do
    it 'is valid  ' do
      subject.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.png', content_type: 'image/png')
      expect(subject.file).to be_attached
    end
  end
end
