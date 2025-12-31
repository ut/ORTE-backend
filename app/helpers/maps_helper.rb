# frozen_string_literal: true

module MapsHelper
  def popup_display_mode_for_select
    popup_display_modes = %w[click click+mouseover]
    popup_display_modes.each_with_object({}) { |e, m| m[e.capitalize] = e }
  end

  def marker_display_mode_for_select
    # array with three values
    marker_display_modes = ['cluster', 'zigzag cluster', 'zigzag cluster, w/gradient', 'single']
    marker_display_modes.each_with_object({}) { |e, m| m[e.capitalize] = e }
  end
end
