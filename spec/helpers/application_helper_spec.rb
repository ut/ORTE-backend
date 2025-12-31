# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'admin?' do
    it 'returns true if current_user and is admin' do
      user = FactoryBot.create(:admin_user, email: 'user99@example.com')
      sign_in user
      expect(helper.admin?).to be true
    end
  end

  describe 'basemaps' do
    it 'returns structured basemap infos' do
      expect(helper.basemaps).not_to eq(nil)
      expect(helper.basemaps['osm']['id']).to eq('osm')
    end
  end

  describe 'smart data displays' do
    it 'returns nothing' do
      startdate = nil
      enddate = nil
      expect(helper.smart_date_display(startdate, enddate)).to eq(nil)
    end
    it 'returns %d.%m.%Y, %H:%M (if enddate is exact the same)' do
      startdate = '2015-03-16 15:13:04'.to_time
      enddate = '2015-03-16 15:13:04'.to_time
      expect(helper.smart_date_display(startdate, enddate)).to eq('16.03.2015, 15:13')
    end
    it 'returns %d.%m.%Y, %H:%M (if enddate is older)' do
      startdate = '2015-03-16 15:13:04'.to_time
      enddate = '2015-03-16 14:13:04'.to_time
      expect(helper.smart_date_display(startdate, enddate)).to eq('16.03.2015, 15:13')
    end
    it 'returns %Y' do
      startdate = '2015-01-01 00:00:00'.to_time
      enddate = nil
      expect(helper.smart_date_display(startdate, enddate)).to eq('2015')
    end
    it 'returns %d.%m.%Y' do
      startdate = '2015-03-16 00:00:00'.to_time
      enddate = nil
      expect(helper.smart_date_display(startdate, enddate)).to eq('16.03.2015')
    end
    it 'returns %d.%m.%Y, %H:%M' do
      startdate = '2015-03-16 20:00:00'.to_time
      enddate = nil
      expect(helper.smart_date_display(startdate, enddate)).to eq('16.03.2015, 20:00')
    end
    it 'returns %d.%m.%Y, %H:%M ‒ %H:%M' do
      startdate = '2015-03-16 15:13:04'.to_time
      enddate = '2015-03-16 20:13:04'.to_time
      expect(helper.smart_date_display(startdate, enddate)).to eq('16.03.2015, 15:13 ‒ 20:13')
    end
    it 'returns %d.%m.%Y, %H:%M ‒ %d.%m.%Y, %H:%M ' do
      startdate = '2015-03-16 15:13:04'.to_time
      enddate = '2015-03-17 15:13:04'.to_time
      expect(helper.smart_date_display(startdate, enddate)).to eq('16.03.2015, 15:13 ‒ 17.03.2015, 15:13')
    end
    it 'returns %d.%m.%Y ‒ %d.%m.%Y ' do
      startdate = '2015-03-16 00:00:00'.to_time
      enddate = '2015-03-17 00:00:00'.to_time
      expect(helper.smart_date_display(startdate, enddate)).to eq('16.03.2015 ‒ 17.03.2015')
    end
    it 'returns %Y ‒ %Y ' do
      startdate = '2015-01-01 00:00:00'.to_time
      enddate = '2017-01-01 00:00:00'.to_time
      expect(helper.smart_date_display(startdate, enddate)).to eq('2015 ‒ 2017')
    end
  end

  describe 'smart data with qualifier displays' do
    it 'returns nothing' do
      startdate = nil
      enddate = nil
      expect(helper.smart_date_display_with_qualifier(startdate, enddate)).to eq(nil)
    end
    it 'returns %d.%m.%Y, %H:%M (if enddate is exact the same)' do
      startdate = '2015-03-16 15:13:04'.to_time
      enddate = '2015-03-16 15:13:04'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate)).to eq('16.3.2015, 15:13')
    end
    it 'returns %d.%m.%Y, %H:%M (if enddate is older)' do
      startdate = '2015-03-16 15:13:04'.to_time
      enddate = '2015-03-16 14:13:04'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate)).to eq('16.3.2015, 15:13')
    end
    it 'returns %Y with qualifier' do
      startdate = '2015-01-01 00:00:00'.to_time
      enddate = nil
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'circa', '')).to eq('ca. 2015')
    end
    it 'returns %d.%m.%Y' do
      startdate = '2015-03-16 00:00:00'.to_time
      enddate = nil
      expect(helper.smart_date_display_with_qualifier(startdate, enddate)).to eq('16.3.2015')
    end
    it 'returns %d.%m.%Y, %H:%M' do
      startdate = '2015-03-16 20:00:00'.to_time
      enddate = nil
      expect(helper.smart_date_display_with_qualifier(startdate, enddate)).to eq('16.3.2015, 20:00')
    end
    it 'returns %d.%m.%Y, %H:%M ‒ %H:%M' do
      startdate = '2015-03-16 15:13:04'.to_time
      enddate = '2015-03-16 20:13:04'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate)).to eq('16.3.2015, 15:13 ‒ 20:13')
    end
    it 'returns %d.%m.%Y, %H:%M ‒ %d.%m.%Y, %H:%M ' do
      startdate = '2015-03-16 15:13:04'.to_time
      enddate = '2015-03-17 15:13:04'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate)).to eq('16.3.2015, 15:13 ‒ 17.3.2015, 15:13')
    end
    it 'returns %d.%m.%Y ‒ %d.%m.%Y ' do
      startdate = '2015-03-16 00:00:00'.to_time
      enddate = '2015-03-17 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate)).to eq('16.3.2015 ‒ 17.3.2015')
    end
    it 'returns ca. %Y ‒ %Y with qualifier' do
      startdate = '2015-01-01 00:00:00'.to_time
      enddate = '2017-01-01 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'circa', 'circa')).to eq('ca. 2015 ‒ 2017')
    end
    it 'returns ca. %Y ‒ %Y with qualifier/2' do
      startdate = '2015-01-01 00:00:00'.to_time
      enddate = '2016-01-01 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'circa', 'circa')).to eq('ca. 2015 ‒ 2016')
    end
    it 'returns ca. %Y with qualifier' do
      startdate = '2015-01-01 00:00:00'.to_time
      enddate = '2015-12-31 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'circa', 'circa')).to eq('ca. 2015')
    end
    it 'returns ca. %Y with qualifier/2' do
      startdate = '2015-01-01 00:00:00'.to_time
      enddate = '2015-01-01 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'circa', 'circa')).to eq('ca. 2015')
    end
    it 'returns ca. %Ys with qualifier' do
      startdate = '2010-01-01 00:00:00'.to_time
      enddate = '2020-01-01 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'circa', 'circa')).to eq('ca. 2010s')
    end
    it 'returns ca. %Ys ‒ %Ys with qualifier' do
      startdate = '2000-01-01 00:00:00'.to_time
      enddate = '2020-01-01 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'circa', 'circa')).to eq('ca. 2000s ‒ 2020s')
    end
    it 'returns %m.d.y ‒ ca. %Ys with exact startdate qualifier and circa enddate qualifier' do
      startdate = '2000-08-15 00:00:00'.to_time
      enddate = '2008-01-01 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'exact', 'circa')).to eq('15.8.2000 ‒ ca. 2008')
    end
    it 'returns ca. %Ys ‒ %m.d.y with circa startdate qualifier and exat enddate qualifier' do
      startdate = '2000-08-15 00:00:00'.to_time
      enddate = '2008-01-01 00:00:00'.to_time
      expect(helper.smart_date_display_with_qualifier(startdate, enddate, 'circa', 'exact')).to eq('ca. 2000 ‒ 1.1.2008')
    end
  end
end
