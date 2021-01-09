# frozen_string_literal: true

module ApplicationHelper
  def after_sign_in_path_for(resource)
    maps_path
  end

  def admin?
    current_user&.admin?
  end

  def smart_date_display(startdate, enddate)
    if !startdate
      return
    end
    if !enddate
      if startdate.strftime("%H:%M") == '00:00'
        if startdate.strftime("%d.%m") == '01.01'
          "#{startdate.strftime("%Y")}"
        else
          "#{startdate.strftime("%d.%m.%y")}"
        end
      else
        "#{startdate.strftime("%d.%m.%y, %H:%M")}"
      end
    elsif startdate > enddate
      "#{startdate.strftime("%d.%m.%y, %H:%M")}"
    elsif startdate == enddate
      if startdate.strftime("%H:%M") == '00:00'
        "#{startdate.strftime("%d.%m.%y")}"
      else
        "#{startdate.strftime("%d.%m.%y, %H:%M")}"
      end
    elsif startdate.to_date == enddate.to_date
      "#{startdate.strftime("%d.%m.%y, %H:%M")} ‒ #{enddate.strftime("%H:%M")}"
    else
      if startdate.strftime("%H:%M") == '00:00'
        if startdate.strftime("%d.%m") == '01.01' && enddate.strftime("%d.%m") == '01.01'
          "#{startdate.strftime("%Y")} ‒ #{enddate.strftime("%Y")}"
        else
          "#{startdate.strftime("%d.%m.%y")} ‒ #{enddate.strftime("%d.%m.%y")}"
        end
      else
        "#{startdate.strftime("%d.%m.%y, %H:%M")} ‒ #{enddate.strftime("%d.%m.%y, %H:%M")}"
      end
    end
  end
end
