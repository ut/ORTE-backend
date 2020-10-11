# frozen_string_literal: true

require 'rails_helper'


RSpec.describe Icon, type: :model do
  it 'has a valid factory' do
    expect(build(:icon)).to be_valid
  end

  xit 'icon_linktag' do
    i = Icon.new
    i.file.attach(io: File.open(Rails.root.join('public', 'apple-touch-icon.png')), filename: 'attachment.png', content_type: 'image/png')
    expect(i.icon_linktag).to eq("#{rails_blob_path(i.file)}")
  end

end
