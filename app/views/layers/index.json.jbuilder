# frozen_string_literal: true

json.array! @layers, partial: 'layers/partials/layer', as: :layer
