# frozen_string_literal: true

class Icon < ApplicationRecord
  belongs_to :iconset
  has_many :places
  has_one_attached :file


  def icon_linktag
    ApplicationController.helpers.icon_linktag(file)
  end

end
