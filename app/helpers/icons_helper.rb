# frozen_string_literal: true

module IconsHelper
  def icon_url(file)
    if file.attached?
      polymorphic_url(file)
    end
  end
  def icon_linktag(file)
    if file.attached?
      "<img src=\"#{polymorphic_url(file)}\">".html_safe
    end
  end
end
