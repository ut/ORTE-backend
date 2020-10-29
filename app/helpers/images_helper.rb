module ImagesHelper
  def image_url(file)
    if file.attached?
      polymorphic_url(file.variant(resize: "800x800").processed)
    end
  end
  def image_linktag(file,title='')
    if file.attached?
      "<img src=\"#{polymorphic_url(file.variant(resize: "800x800").processed)}\" title=\"#{(title.present? ? title : '')}\">".html_safe
    end
  end
end
