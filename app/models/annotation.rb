class Annotation < ApplicationRecord
  belongs_to :place
  belongs_to :person, optional: true

  acts_as_taggable_on :tags

  validates :text, presence: true

  scope :published, -> { where(published: true) }
end
