# frozen_string_literal: true

class Icon < ApplicationRecord
  belongs_to :iconset
  has_many :places
  has_one_attached :file

  validate :check_file_format

  def icon_linktag
    ApplicationController.helpers.icon_linktag(file)
  end

  private

  def check_file_format
    if file.attached? && !file.content_type.in?(%w(image/png image/jpg image/gif image/svg+xml))
      errors.add(:file, 'format must be either SVG (preferred), PNG, GIF or JPEG.')
    end
  end
end
