# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Place, type: :model do
  it 'has a valid factory' do
    expect(build(:place)).to be_valid
  end

  describe 'Audio attachment' do
    it 'is attached' do
      subject.audio.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.mp3')), filename: 'test.mp3', content_type: 'audio/mpeg')
      expect(subject.audio).to be_attached
    end
    it 'is invalid ' do
      subject.audio.attach(io: File.open(Rails.root.join('spec', 'support', 'files', 'test.m4a')), filename: 'test.mp3', content_type: 'audio/mpeg')
      # expect(subject.audio).not_to be_attached
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include("Audio format must be MP3.")
    end
  end

  describe 'Dates' do
    it 'returns date' do
      p = FactoryBot.create(:place, startdate: '2018-01-01', enddate: '2018-01-02')
      expect(p.date).to eq('01.01.18 ‒ 02.01.18')
    end

    it 'returns full startdate' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '20:30', enddate: '')
      expect(p.date).to eq('01.01.18, 20:30')
    end

    it 'returns full startdate without time' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '', enddate: '')
      expect(p.date).to eq('2018')
    end

    it 'returns full date range with time' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '12:00', enddate_date: '2018-01-01', enddate_time: '18:00')
      expect(p.date).to eq('01.01.18, 12:00 ‒ 18:00')
    end

    it 'returns full date range without time' do
      p = FactoryBot.create(:place, startdate_date: '2018-01-01', startdate_time: '', enddate_date: '2018-10-15')
      expect(p.date).to eq('01.01.18 ‒ 15.10.18')
    end

    it 'returns year range' do
      p = FactoryBot.create(:place, startdate_date: '2015-01-01', startdate_time: '', enddate_date: '2018-01-01')
      expect(p.date).to eq('2015 ‒ 2018')
    end
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
    p = FactoryBot.create(:place, layer: l)
    expect(p.imagelink2).to eq(p.imagelink)
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


  describe 'CSV' do
    it 'is valid  ' do
      m = FactoryBot.create(:map)
      l = FactoryBot.create(:layer, map: m)
      p1 = FactoryBot.create(:place, layer: l, address: 'An address1', location: 'A location', zip: '12345', city: 'City')
      p2 = FactoryBot.create(:place, layer: l, address: 'An address2', location: 'A location', zip: '12345', city: 'City')
      places = Place.all
      csv_header = 'id,title,teaser,text,startdate,enddate,lat,lon,location,address,zip,city,country'
      csv_line1 = 'An address1,12345,City,Country'
      csv_line2 = 'An address2,12345,City,Country'
      expect(places.to_csv).to include(csv_header)
      expect(places.to_csv).to include(csv_line1)
      expect(places.to_csv).to include(csv_line2)
    end
  end
end
