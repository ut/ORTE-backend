# frozen_string_literal: true

class Iconset < ApplicationRecord
  has_many :icons, :dependent => :destroy
  accepts_nested_attributes_for :icons, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true
  has_many :maps
  has_one_attached :file

  validates :title, presence: true

end
