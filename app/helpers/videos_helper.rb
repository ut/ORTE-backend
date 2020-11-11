module VideosHelper
  def video_url(file)
    if file.attached?
      polymorphic_url(file)
    end
  end
  def video_linktag(file,filmstill,title='')
    if file.attached?
      if filmstill.attached?
        video_tag("#{polymorphic_url(file)}", controls: true, preload: 'metadata', poster: "#{polymorphic_url(filmstill)}", poster_skip_pipeline: true)
      else
        video_tag("#{polymorphic_url(file)}", controls: true, preload: 'metadata')
      end
    end
  end
end
