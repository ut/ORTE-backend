# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layer, type: :model do
  include Rails.application.routes.url_helpers

  it 'has a valid factory' do
    expect(build(:layer)).to be_valid
  end

  describe 'Layer data' do
    it 'has some image metadata' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      expect(l.image_alt).to be_present
      expect(l.image_creator).to be_present
    end
  end

  describe 'Layer image' do
    describe 'Attachment' do
      it 'is valid' do
        subject.image.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
        expect(subject.image).to be_attached
      end
    end

    it 'image_filename' do
      subject.image.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      expect(subject.image_filename).to eq(subject.image.filename)
    end
    it 'image_link' do
      m = FactoryBot.create(:map)
      l = FactoryBot.build(:layer, map: m)
      l.image.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      l.save!
      expect(l.image_link).to eq("http://127.0.0.1:3000#{Rails.application.routes.url_helpers.url_for(polymorphic_path(l.image.variant(resize: '800x800').processed))}")
    end
  end

  describe 'Layer background image' do
    describe 'Attachment' do
      it 'is valid' do
        subject.backgroundimage.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
        expect(subject.backgroundimage).to be_attached
        expect(subject).to have_one_attached(:backgroundimage)
      end
    end

    it 'backgroundimage_filename' do
      subject.backgroundimage.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      expect(subject.backgroundimage_filename).to eq(subject.backgroundimage.filename)
    end
    it 'backgroundimage_link' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      l.backgroundimage.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      expect(l.backgroundimage_link).to eq("http://127.0.0.1:3000#{Rails.application.routes.url_helpers.url_for(polymorphic_path(l.backgroundimage.variant(resize: '800x800').processed))}")
    end
  end

  describe 'Layer favicon image' do
    describe 'Attachment' do
      it 'is valid' do
        subject.favicon.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
        expect(subject.favicon).to be_attached
      end
    end

    it 'favicon_filename' do
      subject.favicon.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      expect(subject.favicon_filename).to eq(subject.favicon.filename)
    end
    it 'favicon_link' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      l.favicon.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      expect(l.favicon_link).to eq("http://127.0.0.1:3000#{Rails.application.routes.url_helpers.url_for(polymorphic_path(l.favicon.variant(resize: '800x800').processed))}")
    end
  end

  describe 'EXIF' do
    xit 'should retain EXIF data' do
      m = FactoryBot.create(:map)
      l = FactoryBot.build(:layer, map: m)
      l.exif_remove = false
      l.image.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test-with-exif-data.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      l.save!
      l.reload
      expect(l.get_exif_data['GPSLatitude']).to match(/10\/1,\s*0\/1,\s*0\/1/)
    end

    it 'should remove EXIF data' do
      m = FactoryBot.create(:map)
      l = FactoryBot.build(:layer, map: m)
      l.exif_remove = true
      l.image.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test-with-exif-data.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      l.save!
      l.reload
      expect(l.get_exif_data).to eq({})
    end
  end

  describe 'ZIP' do
    it 'should create a ZIP archive' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m, published: true)
      p1 = FactoryBot.create(:place, layer: l)
      p2 = FactoryBot.create(:place, layer: l)
      zip_file = "orte-map-#{l.map.title.parameterize}-layer-#{l.title.parameterize}-#{I18n.l Date.today}.zip"
      expect(l.to_zip(zip_file)).to eq("public/#{zip_file}")
    end
  end
end
