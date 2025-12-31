# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Image, type: :model do
  include Rails.application.routes.url_helpers

  it 'has a valid factory' do
    expect(build(:image)).to be_valid
  end

  it 'has an image type' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    l.exif_remove = true
    p = FactoryBot.create(:place, layer: l)
    i = create(:image, place: p)
    expect(i.itype).to eq('image')
  end

  describe 'Attachment' do
    it 'is valid' do
      subject.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      expect(subject.file).to be_attached
      expect(subject).to have_one_attached(:file)
    end
  end

  describe 'Image links and tags' do
    before do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      p = FactoryBot.create(:place, layer: l)
      @i = FactoryBot.build(:image, place: p)
      @i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      @i.save!
      @i.reload
    end
    it 'image_filename' do
      expect(@i.image_filename).to eq(@i.file.filename)
    end
    it 'image_url' do
      expect(@i.image_url).to eq("http://127.0.0.1:3000#{Rails.application.routes.url_helpers.url_for(polymorphic_path(@i.file.variant(resize: '800x800')))}")
    end
    it 'image_path' do
      expect(@i.image_path).to eq(Rails.application.routes.url_helpers.url_for(polymorphic_path(@i.file.variant(resize: '800x800').processed)))
    end
    it 'image_linktag' do
      expect(@i.image_linktag).to eq("<img src=\"http://127.0.0.1:3000#{Rails.application.routes.url_helpers.url_for(polymorphic_path(@i.file.variant(resize: '800x800').processed))}\" title=\"#{@i.title}\">")
    end
    it 'image_on_disk' do
      variant = @i.file.variant(resize: '1200x1200').processed
      full_path = ActiveStorage::Blob.service.path_for(variant.key)
      expect(@i.image_on_disk).to eq(full_path.gsub(Rails.root.to_s, ''))
    end
  end

  describe 'EXIF' do
    before do
      m = FactoryBot.create(:map)
      l1 = FactoryBot.create(:layer, map: m, exif_remove: false)
      l2 = FactoryBot.create(:layer, map: m, exif_remove: true)
      @p1 = FactoryBot.create(:place, layer: l1)
      @p2 = FactoryBot.create(:place, layer: l2)
    end
    xit 'should retain EXIF data' do
      i = FactoryBot.build(:image, place: @p1)
      i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test-with-exif-data.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      i.save!
      i.reload
      expect(i.get_exif_data['GPSLatitude']).to match(/10\/1,\s*0\/1,\s*0\/1/)
    end
    xit 'should remove EXIF data' do
      i = FactoryBot.build(:image, place: @p2)
      i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test-with-exif-data.jpg')), filename: 'attachment.jpg', content_type: 'image/jpeg')
      i.save!
      i.reload
      expect(i.get_exif_data).to eq({})
    end
  end

  describe 'checks and validations' do
    before do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      @p = FactoryBot.create(:place, layer: l)
    end
    it 'should check if title is present' do
      image = build(:image, place: @p)
      expect(image).to be_valid
      expect(image.errors).to be_empty
    end
    it 'should be invalid if no title is present' do
      image = build(:image, :notitle, place: @p)
      expect(image).not_to be_valid
      expect(image.errors[:title]).to eq(['Image description can not be blank'])
    end
    xit 'should be invalid if no file is present' do
      image = build(:image, :nofile, place: @p)
      expect(image).not_to be_valid
      expect(image.errors[:file]).to eq(['no file present'])
    end
    it 'should check_file_format' do
      image = build(:image, place: @p)
      uploaded = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'files', 'test.txt'), 'txt/plain')
      image.file.attach(uploaded)
      expect(image).not_to be_valid
      expect(image.errors[:file]).to eq(['File format must be JPG/PNG or GIF'])
    end
  end
end
