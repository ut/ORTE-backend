# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'submission_configs/index', type: :view do
  before(:each) do
    group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, group_id: group.id)
    sign_in user
    @map = FactoryBot.create(:map, group_id: group.id)
    @layer = FactoryBot.create(:layer, map_id: @map.id)

    assign(:submission_configs, [
             SubmissionConfig.create!(
               title_intro: 'Title Intro',
               subtitle_intro: 'Subtitle Intro',
               intro: 'MyIntro',
               title_outro: 'Title Outro',
               outro: 'MyText',
               use_city_only: false,
               layer_id: @layer.id
             ),
             SubmissionConfig.create!(
               title_intro: 'Title Intro',
               subtitle_intro: 'Subtitle Intro',
               intro: 'MyIntro',
               title_outro: 'Title Outro',
               outro: 'MyText',
               use_city_only: false,
               layer_id: @layer.id
             )
           ])
  end

  it 'renders a list of submission_configs' do
    render

    assert_select 'tr>td', text: 'Title Intro', count: 2
    assert_select 'tr>td', text: 'Subtitle Intro', count: 2
    assert_select 'tr>td', text: 'MyIntro', count: 2
    assert_select 'tr>td', text: 'Title Outro', count: 2
    assert_select 'tr>td', text: 'MyText', count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
  end
end
