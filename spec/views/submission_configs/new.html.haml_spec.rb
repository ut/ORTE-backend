require 'rails_helper'

RSpec.describe "submission_configs/new", type: :view do
  before(:each) do
    group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, group_id: group.id)
    sign_in user
    @map = FactoryBot.create(:map, group_id: group.id)
    @layer = FactoryBot.create(:layer, map_id: @map.id)
    assign(:submission_config, SubmissionConfig.new(
      title_intro: "MyString",
      subtitle_intro: "MyString",
      intro: "MyText",
      title_outro: "MyString",
      outro: "MyText",
      use_city_only: false,
      layer_id: @layer.id
    ))
  end

  it "renders new submission_config form" do
    render

    assert_select "form[action=?][method=?]", submission_configs_path, "post" do

      assert_select "input[name=?]", "submission_config[title_intro]"

      assert_select "input[name=?]", "submission_config[subtitle_intro]"

      assert_select "textarea[name=?]", "submission_config[intro]"

      assert_select "input[name=?]", "submission_config[title_outro]"

      assert_select "textarea[name=?]", "submission_config[outro]"

      assert_select "input[name=?]", "submission_config[use_city_only]"
    end
  end
end
