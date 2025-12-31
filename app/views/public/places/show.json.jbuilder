# frozen_string_literal: true

json.place do
  next unless @place.published

  json.call(@place, :id, :uid, :title, :subtitle, :teaser, :text, :sources, :link, :imagelink, :imagelink2, :audiolink, :published, :date, :date_with_qualifier, :startdate, :enddate, :startdate_qualifier, :enddate_qualifier, :location, :address, :zip, :city, :text, :country, :featured, :layer_id, :layer_title, :color, :icon_link, :icon_class, :icon_name)
end
