# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
require 'json'

# Minimal data to have a admin user

Group.find_or_create_by( title: 'Admins' )

User.find_or_create_by( email: 'admin@domain.org' ) do |user|
	user.password = '123456789'
  user.role = 'admin'
  user.group = Group.find_by( title: 'Admins' )
  puts 'Created a first group and a user'
end



module DatabaseSeeding
  class MapSeeder
    def self.seed_map_structure(json_file_path )
      json_data = File.read(Rails.root.join('db', 'seeds', json_file_path))
      map_data = JSON.parse(json_data)
      
      ActiveRecord::Base.transaction do
        # Create or update the map
        map = create_or_update_map(map_data['map'])
        
        # Process layers
        process_layers(map, map_data['map']['layer'])
      rescue StandardError => e
        puts "Error seeding data: #{e.message}"
        puts e.backtrace
        raise ActiveRecord::Rollback
      end
    end
  
    
    def self.create_or_update_map(map_data)
      map_attributes = map_data.except('layer')

      # prepare the map attributes
      map_attributes.delete_if { |_, v| v.nil? }
      group = Group.find_by( title: 'Admins' )
      map_attributes['group_id'] = group.id
      map_attributes.delete('owner')
     
      if existing_map = Map.find_by(title: map_attributes['title'])
        existing_map.tap { |map| map.update!(map_attributes) }
      else
        Map.create!(map_attributes)
      end.tap { |map| puts "Processed Map: #{map_attributes['title']}" }
    end
    
    def self.process_layers(map, layers)
      return unless layers.is_a?(Array)
      
      layers.each do |layer_data|
        layer = create_or_update_layer(map, layer_data)
        process_places(layer, layer_data['places'])
      end
    end
    
    def self.create_or_update_layer(map, layer_data)
      layer_attributes = layer_data.except('places').except('places_with_relations')
      layer_attributes['map_id'] = map.id
      layer_attributes.delete_if { |_, v| v.nil? }
      
      if existing_layer = Layer.find_by(id: layer_attributes['id'])
        existing_layer.tap { |layer| layer.update!(layer_attributes) }
      else
        Layer.create!(layer_attributes)
      end.tap { |layer| puts "-- Processed Layer: #{layer_attributes['title']}" }
    end
    
    def self.process_places(layer, places)
      return unless places.is_a?(Array)
      
      places.each do |place_data|
        create_or_update_place(layer, place_data)
      end
    end
    
    def self.create_or_update_place(layer, place_data)
      place_attributes = place_data.clone
      place_attributes['layer_id'] = layer.id
      
      # Filter attributes to only include those that exist in the Place model
      valid_attributes = place_attributes.slice(*Place.column_names)
      
      if existing_place = Place.find_by(id: valid_attributes['id'])
        existing_place.tap { |place| place.update!(valid_attributes) }
      else
        Place.create!(valid_attributes)
      end.tap { |place| puts "---- Processed Place: #{place.title}" }
    end
  end
end # module DatabaseSeeding  

# Seed the database with a sample dataset of public parks in Hamburg West
DatabaseSeeding::MapSeeder.seed_map_structure('public-parks-and-greens-in-hamburg-west.json')
