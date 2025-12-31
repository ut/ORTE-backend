# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Place, type: :model do
  it 'has a valid factory' do
    expect(build(:place)).to be_valid
  end

  it 'has a valid factory (with sensitive on)' do
    expect(build(:place, sensitive: true)).to be_valid
  end

  describe 'Audio attachment' do
    it '(mp3) is attached' do
      subject.audio.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp3')), filename: 'test.mp3', content_type: 'audio/mpeg')
      expect(subject.audio).to be_attached
    end
    it '(m4a) is attached' do
      subject.audio.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.m4a')), filename: 'test.m4a', content_type: 'audio/x-m4a')
      expect(subject.audio).to be_attached
    end
    it '(mp4) is not attached' do
      subject.audio.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'test.mp4', content_type: 'video/mpeg')
      expect(subject).not_to be_valid
    end
    it 'is invalid' do
      subject.audio.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp4')), filename: 'test.ogg', content_type: 'audio/mpeg')
      expect(subject).not_to be_valid
      # expect(subject.errors.full_messages).to include('Format must be MP3 or M4')
    end
  end

  describe 'Fulldates w/before_save handling' do
    it 'updates full date' do
      p = FactoryBot.create(:place, startdate: '2018-01-01', enddate: '2018-01-02')
      p.startdate_date = '2018-01-01'
      p.enddate_date = '2018-12-31'
      p.save!
      p.reload
      expect(p.startdate).to eq('2018-01-01 00:00:00.000')
      expect(p.enddate).to eq('2018-12-31 00:00:00.000')
    end

    it 'removes full date with nil' do
      p = FactoryBot.create(:place, startdate: '2018-01-01', enddate: '2018-01-02')
      p.startdate_date = '2018-01-01'
      p.enddate_date = nil
      p.save!
      p.reload
      expect(p.startdate).to eq('2018-01-01 00:00:00.000')
      expect(p.enddate).to eq(nil)
    end

    it 'removes full date with blank' do
      p = FactoryBot.create(:place, startdate: '2018-01-01', enddate: '2018-01-02')
      p.startdate_date = ''
      p.enddate_date = '2018-01-02'
      p.save!
      p.reload
      expect(p.startdate).to eq(nil)
      expect(p.enddate).to eq('2018-01-02 00:00:00.000')
    end
  end

  describe 'Dates for UI' do
    it 'returns date range' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', enddate_date: '2018-01-02')
      expect(p.date).to eq('01.01.2018 ‒ 02.01.2018')
    end

    it 'returns full startdate' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '20:30', enddate: '')
      expect(p.date).to eq('01.01.2018, 20:30')
    end

    it 'returns year (with only startdate given)' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '', enddate: '')
      expect(p.date).to eq('2018')
    end
    it 'returns year' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '', enddate: '2018-12-31')
      expect(p.date).to eq('2018')
    end
    it 'returns full date range with time' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '12:00', enddate_date: '2018-01-01', enddate_time: '18:00')
      expect(p.date).to eq('01.01.2018, 12:00 ‒ 18:00')
    end

    it 'returns full date range without time' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '', enddate_date: '2018-10-15')
      expect(p.date).to eq('01.01.2018 ‒ 15.10.2018')
    end

    it 'returns year range' do
      p = FactoryBot.create(:place, startdate_date: '2015-01-01', startdate_time: '', enddate_date: '2018-01-01')
      expect(p.date).to eq('2015 ‒ 2018')
    end
  end

  it 'layer_color' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    p = FactoryBot.create(:place, layer: l)
    expect(p.layer_color).to eq(l.color)
  end

  it 'title_and_location' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    p = FactoryBot.create(:place, layer: l)
    expect(p.title_and_location).to eq("#{p.title} (#{p.location})")
  end

  it 'title_and_location (while no location is defined)' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    p = FactoryBot.create(:place, layer: l, location: nil)
    expect(p.title_and_location).to eq(p.title)
  end

  it 'show_link' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    p = FactoryBot.create(:place, layer: l)
    expect(p.show_link).to eq(" <a href=\"/maps/#{m.id}/layers/#{l.id}/places/#{p.id}\">#{p.title}</a>")
  end

  it 'edit_link' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    p = FactoryBot.create(:place, layer: l)
    expect(p.edit_link).to eq(" <a href=\"/maps/#{m.id}/layers/#{l.id}/places/#{p.id}/edit\" class='edit_link'><i class='fi fi-pencil'></i></a>")
  end

  it 'imagelink2' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    p1 = FactoryBot.create(:place, layer: l)
    expect(p1.imagelink2).not_to eq(p1.imagelink)
    p2 = FactoryBot.create(:place, layer: l)
    i = build(:image, :preview, place: p2)
    i.file.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.jpg')), filename: 'attachment.jpg', content_type: 'image/jepg')
    i.save!
    expect(p2.imagelink2).not_to eq(p2.imagelink)
  end

  it 'audiolink' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    p = FactoryBot.create(:place, layer: l)
    p.audio.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp3')), filename: 'test.mp3', content_type: 'audio/mpeg')
    expect(p.audiolink).to eq("<audio controls=\"controls\" src=\"#{Rails.application.routes.url_helpers.url_for(p.audio)}\"></audio>")
  end

  it 'random_loc' do
    m = FactoryBot.create(:map)
    l = FactoryBot.create(:layer, map: m)
    p = FactoryBot.create(:place, layer: l)
    allow(SecureRandom).to receive(:random_number).with(anything).and_return(2)
    expect(p.random_loc(long: 10, lat: 50, radius_meters: 200)).to eq([10.002541264263025, 50.0])
  end

  describe 'Scope, (implicit) sorted by id ' do
    it 'is valid  ' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      event_1_in_the_middle = FactoryBot.create(:place, layer: l, startdate_date: '2016-01-01 00:00:00')
      event_2_earlier = FactoryBot.create(:place, layer: l, startdate_date: '2011-01-01 00:00:00')
      event_3_latest = FactoryBot.create(:place, layer: l, startdate_date: '2021-01-01 00:00:00')

      places = l.places
      expect(places).to eq([event_1_in_the_middle, event_2_earlier, event_3_latest])
    end
  end

  describe 'Scope, sorted by startdate ' do
    it 'is valid  ' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      event_1_in_the_middle = FactoryBot.create(:place, layer: l, startdate_date: '2016-01-01 00:00:00')
      event_2_earlier = FactoryBot.create(:place, layer: l, startdate_date: '2011-01-01 00:00:00')
      event_3_latest = FactoryBot.create(:place, layer: l, startdate_date: '2021-01-01 00:00:00')

      places = l.places.sorted_by_startdate
      expect(places).not_to eq([event_1_in_the_middle, event_2_earlier, event_3_latest])
      expect(places).to eq([event_2_earlier, event_1_in_the_middle, event_3_latest])
    end
  end

  describe 'Scope, all published ' do
    it 'is valid  ' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      event_1_published = FactoryBot.create(:place, layer: l, published: true)
      event_2_published = FactoryBot.create(:place, layer: l, published: true)
      event_3_unpublished = FactoryBot.create(:place, layer: l, published: false)

      places = l.places.published
      expect(places).not_to eq([event_1_published, event_2_published, event_3_unpublished])
      expect(places).to eq([event_1_published, event_2_published])
    end
  end

  describe 'Address' do
    it 'full_address w/location but no address' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      p = FactoryBot.create(:place, layer: l, address: '', location: 'A location')
      expect(p.full_address).to eq('A location')
    end

    it 'full_address w/address but no location(name)' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      p = FactoryBot.create(:place, layer: l, address: 'An address', location: '')
      expect(p.full_address).to eq('An address')
    end

    it 'full_address_with_city' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      p = FactoryBot.create(:place, layer: l, address: 'An address', location: 'A location', zip: '12345', city: 'City')
      expect(p.full_address_with_city).to eq('A location An address, 12345 City')
    end
  end

  describe 'Tags' do
    it 'returns list of tags' do
      tag_list = %w[aaa bbb ccc]
      p = FactoryBot.create(:place, tag_list: tag_list)
      expect(p.tag_list).to eq(tag_list)
    end
  end

  describe 'Relations' do
    describe 'Relation associations' do
      subject { build(:place) }
      it { is_expected.to have_many(:relations_tos) }
      it { is_expected.to have_many(:relations_froms) }
    end

    it 'has valid relations' do
      p1 = create(:place, title: 'Yellow')
      p2 = create(:place, title: 'Green')
      r = create(:relation, relation_from_id: p1.id, relation_to_id: p2.id)
      expect(p1.relations_froms.first.relation_from.title).to eq('Yellow')
      expect(p1.relations_froms.first.relation_to.title).to eq('Green')
      expect(p2.relations_tos.first.relation_from.title).to eq('Yellow')
      expect(p2.relations_tos.first.relation_to.title).to eq('Green')
    end
  end

  describe 'CSV' do
    it 'is valid  ' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      p1 = FactoryBot.create(:place, layer: l, address: 'An address1', location: 'A location', zip: '12345', city: 'City', country: 'Country')
      p2 = FactoryBot.create(:place, layer: l, address: 'An address2', location: 'A location', zip: '12345', city: 'City', country: 'Country')
      a1 = FactoryBot.create(:annotation, place: p1, title: 'Annotation 1')
      a2 = FactoryBot.create(:annotation, place: p2, title: 'Annotation 2')

      other_map = FactoryBot.create(:map)
      other_layer = FactoryBot.create(:layer, map: other_map)
      p3 = FactoryBot.create(:place, layer: other_layer, address: 'An address3', location: 'A location', zip: '12345', city: 'City', country: 'Country')
      a3 = FactoryBot.create(:annotation, place: p3, title: 'Annotation 3')
      places = l.places
      csv_header = 'id,title,teaser,text,annotations,startdate,enddate,lat,lon,location,address,zip,city,country'
      csv_line1 = 'An address1,12345,City,Country'
      csv_line2 = 'An address2,12345,City,Country'
      csv_line3 = 'An address3,12345,City,Country'
      expect(places.to_csv).to include(csv_header)
      expect(places.to_csv).to include(csv_line1)
      expect(places.to_csv).to include(csv_line2)
      expect(places.to_csv).to include(a1.title)
      expect(places.to_csv).to include(a2.title)
      expect(places.to_csv).not_to include(csv_line3)
      expect(places.to_csv).not_to include(a3.title)
    end
  end
end
