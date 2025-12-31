# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :place

  attr_accessor :skip_beforesave_callback

  before_save :strip_exif_data, unless: :skip_beforesave_callback

  has_one_attached :file
  delegate_missing_to :file

  validates :title, presence: true
  validate :check_file_presence
  validate :check_file_format

  scope :sorted, -> { order(sorting: :asc) }
  scope :sorted_by_place, ->(place_id) { where(place_id: place_id).order(sorting: :asc) }
  scope :preview, ->(place_id) { where(place_id: place_id, preview: true) }
  scope :without_attached_file, -> { left_joins(:file_attachment).where('active_storage_attachments.id IS NULL') }

  def image_filename
    file.filename if file&.attached?
  end

  def image_url
    ApplicationController.helpers.image_url(file)
  end

  def image_path
    ApplicationController.helpers.image_path(file)
  end

  def image_linktag
    ApplicationController.helpers.image_linktag(file, title)
  end

  def image_on_disk
    return unless file&.attached?
    return unless ActiveStorage::Blob.service.exist?(file.blob.key)

    # original size
    # full_path = ActiveStorage::Blob.service.path_for(file.key)
    # variant
    variant = file.variant(resize: '1200x1200').processed
    full_path = ActiveStorage::Blob.service.path_for(variant.key)
    return unless File.exist?(full_path)

    full_path.gsub(Rails.root.to_s, '')
  end

  def get_exif_data
    return unless file.attached?

    full_path = ActiveStorage::Blob.service.path_for(file.key)
    exif_data = MiniMagick::Image.open(full_path.to_s)
    exif_data.exif if exif_data&.exif
  end

  private

  def strip_exif_data
    return unless place.layer.exif_remove

    return unless file.attached? && file.changed? && attachment_changes['file']

    filename = file.filename.to_s
    attachment_path = "#{Dir.tmpdir}/#{file.filename}"

    attachable = if attachment_changes['file'].attachable.is_a?(Hash) && attachment_changes['file'].attachable[:io]
                   attachment_changes['file'].attachable[:io]
                 else
                   attachment_changes['file'].attachable
                 end

    tmp_new_image = File.read(attachable)

    File.open(attachment_path, 'wb') do |tmp_file|
      tmp_file.write(tmp_new_image)
      tmp_file.close
    end
    tmp_image = MiniMagick::Image.open(attachment_path)
    tmp_image.auto_orient # Before stripping
    tmp_image.strip # Strip Exif
    tmp_image.write attachment_path
    self.skip_beforesave_callback = true
    file.attach(io: File.open(attachment_path), filename: file.filename)
  end

  def check_file_presence
    errors.add(:file, 'No file present') unless file
  end

  def check_file_format
    errors.add(:file, 'File format must be JPG/PNG or GIF') if file.attached? && !file.content_type.in?(%w[image/png image/jpeg image/gif])
  end
end
