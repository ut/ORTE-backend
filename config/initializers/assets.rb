# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.

Rails.application.config.assets.paths << Rails.root.join('assets/favicon')
Rails.application.config.assets.paths << Rails.root.join('vendor/assets/img')
Rails.application.config.assets.paths << Rails.root.join('vendor/assets/fonts')

# Rails.application.config.assets.paths << Rails.root.join('vendor','assets','fonts','media','files')
Rails.application.config.assets.paths << Rails.root.join('vendor','assets','fonts','worksans')
Rails.application.config.assets.paths << Rails.root.join('vendor','assets','fonts','orte')
Rails.application.config.assets.paths << Rails.root.join('node_modules')


# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# sprockets 3.x syntax:
# Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
# sprockets 4.x syntax:
Rails.application.config.assets.precompile << ["*.svg", "*.eot", "*.woff", "*.woff2", "*.ttf"]
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w( leaflet-color-markers.js )
Rails.application.config.assets.precompile += %w( application.css )
