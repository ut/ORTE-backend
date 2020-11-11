# frozen_string_literal: true

json.extract! video, :id, :title, :licence, :source, :creator, :place_id, :alt, :caption, :sorting, :preview, :created_at, :updated_at
json.url video_url(video, format: :json)
