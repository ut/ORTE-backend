module ImagesHelper
  def image_url(file)
    if file.attached?
      polymorphic_url(file)
    end
  end
  def image_linktag(file,title='')
    if file.attached?
      "<img src=\"#{polymorphic_path(file)}\" title=\"#{(title.present? ? title : '')}\">".html_safe
    end
  end
end
