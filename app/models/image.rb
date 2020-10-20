# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :place

  has_one_attached :file
  delegate_missing_to :file

  validates :title, presence: true
  validate :check_file_presence
  validate :check_file_format


  scope :sorted, -> { order(sorted: :asc) }
  scope :sorted_by_place, ->(place_id) { where('place_id': place_id).order(sorted: :asc) }
  scope :preview, ->(place_id) { where('place_id': place_id, 'preview': true) }

  def image_url
    ApplicationController.helpers.image_url(file)
  end
  def image_linktag
    ApplicationController.helpers.image_linktag(file,title)
  end

  private

  def check_file_presence
    if !file
      errors.add(:file, 'no file present')
    end
  end

  def check_file_format
    if file.attached? && !file.content_type.in?(%w(image/png image/jpeg image/gif))
      errors.add(:file, 'format must be JPG/PNG or GIF')
    end
  end

end
