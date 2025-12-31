# frozen_string_literal: true

class SubmissionConfig < ApplicationRecord
  extend Mobility

  translates :title_intro,    type: :string
  translates :subtitle_intro, type: :string
  translates :intro,          type: :text
  translates :title_outro,    type: :string
  translates :outro,          type: :text

  belongs_to :layer, optional: true

  serialize :locales, type: Array
end
