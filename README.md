![GitHub Release](https://img.shields.io/github/v/release/a-thousand-channels/ORTE-backend?display_name=release)
![main](https://img.shields.io/github/last-commit/a-thousand-channels/ORTE-backend/main)
![GitHub contributors](https://img.shields.io/github/contributors-anon/a-thousand-channels/ORTE-backend)
![Code Coverage w/SimpleCov](https://img.shields.io/badge/code_coverage-95%25-green) [![Linters + RSpec](https://github.com/a-thousand-channels/ORTE-backend/actions/workflows/rubyonrails-ci.yml/badge.svg)](https://github.com/a-thousand-channels/ORTE-backend/actions/workflows/rubyonrails-ci.yml) [![Maintainability](https://api.codeclimate.com/v1/badges/ab3d16e763664a942d72/maintainability)](https://codeclimate.com/github/ut/ORTE-backend/maintainability)


# ORTE-backend, a web-GIS backend

Backend application for creating and managing places/POIs (or in german "Orte"),  formatted text and assets like images, audio and video on a web-based map. Additionally relations between places can be set. Output is a public available API w/JSON or exportable as CSV/JSON/GeoJSON data. It has also some extra features like visualising relations between places and a map to go feature (see below).

Based on Ruby on Rails 7.2, Ruby 3, MariaDB, jQuery, Leaflet and Foundation 6.

Contributions to this application are appreciated (see below).

🥁 [Latest Release v0.9:](https://github.com/a-thousand-channels/ORTE-backend/releases/tag/0.9), published July 2025 

For a user manual and other informations check our [Handbook](https://github.com/a-thousand-channels/ORTE-backend/wiki/) in the wiki, a [German version](https://github.com/a-thousand-channels/ORTE-backend/wiki/Home-de-DE) is also available. 

<img src="https://raw.githubusercontent.com/a-thousand-channels/ORTE-backend/main/app/assets/images/ORTE-sample-map-desktop.jpg" style="max-width: 640px" width="640" />
<img src="https://raw.githubusercontent.com/a-thousand-channels/ORTE-backend/main/app/assets/images/ORTE-sample-map-desktop2.jpg" style="max-width: 640px" width="640" />

<img src="https://raw.githubusercontent.com/a-thousand-channels/ORTE-backend/main/app/assets/images/ORTE-sample-map-mobile.jpg" style="max-width: 360px" width="320" />
<img src="https://raw.githubusercontent.com/a-thousand-channels/ORTE-backend/main/app/assets/images/ORTE-sample-map-mobile2.jpg" style="max-width: 360px" width="320" />


## Address and geolocation lookup

This application uses [Nominatim](https://nominatim.openstreetmap.org/), a search engine for OpenStreetMap data to look up address and geolocation data. By implementing this application you should respect the [Nominatim Usage Policy](https://operations.osmfoundation.org/policies/nominatim/)!

## Map to go feature

ORTE Backend ist basically a backend which provides JSON and GeoJSON export of its layers and map. Since version 0.7 offers a "map to go" feature, where user can generate a static, Nuxt.js based website from their single layer (and its places) and place this site on their webspace. So you can get your frontend website and all defined data directly out of the application.

## Installation

Basic steps for a local installation on your machine:

### Requirements

#### Development

* Ruby 3.2+, RVM, Rubygems
* Maria DB
* ffmpeg (for the video feature)
* ImageMagick or graphicsmagick (for image features)
* Redis
* Node.js (v18++)

#### Production

Additional requirements for production

* Webserver (e.g. Apache or NGINX)
* Passenger stand-alone

#### Cron job
To schedule the maintenance cron job to remove outdated import files in the tmp folder on staging and production env, add it to the crontab file. 
This is an example how the line in the crontab file could look like to do the cleanup every Sunday at 3:30 am:

```bash
30 3 * * 0 cd /path/to/ORTE-backend && RAILS_ENV=production bundle exec rake cron_jobs:maintenance:import_files_cleanup
```

Replace /path/to/ORTE-backend with the full path to the Rails application.

### Get repository

```bash
$ git clone git@github.com:a-thousand-channels/ORTE-backend.git
```
### Prepare Rails

```bash
$ gem install bundler
$ bundle install
```

### Setup Maria DB

```bash
$ sudo mysql -u root
> CREATE USER 'orte'@'localhost' IDENTIFIED BY 'orte00';
> GRANT ALL PRIVILEGES ON *.* TO 'orte'@'localhost';
> CREATE DATABASE orte CHARACTER SET utf8 COLLATE utf8_general_ci;
> CREATE DATABASE orte_test CHARACTER SET utf8 COLLATE utf8_general_ci;
> exit;
$ bundle exec rails db:schema:load
$ bundle exec rails db:seed
```

Note: With Mariadb locally, you might not need a user root, just

```sudo mysql```


### Settings for server setup

Some settings (like email settings or database setup) you'll need for productive installation on a server are stored in the credential file.

Edit the credential file with

```bash
$ EDITOR=vim bundle exec rails credentials:edit
```

All used and needed variables are explained in the credentials.yml.default file.

To use this in different environments, with development and installations for staging or production server you can use the multi-environment credentials that came with Rails 6.1.

To create/edit a specific credential file for staging use:

```bash
$ EDITOR=vim bundle exec rails credentials:edit --environment staging
```

For details on this technique please read this good explainer about [credentials in Rails 6.1](https://blog.saeloun.com/2019/10/10/rails-6-adds-support-for-multi-environment-credentials.html)

Also edit settings.yml to define your custom server address.

### Optional: Mapbox Token for satellite imagery

As a default at ORTE, satellite imagery is used as a base layer. This imagery is available only up to level 18. If you want to have satellite imagery on a higher zoom level (19-21), where you can more clearly see details on streets, places and buildings, than you have to define an additional satellite imagery provider. ORTE has as a preset for Mapbox satellite imagery, but to use it, you need to have a Mapbox account and to generate a Mapbox API Token. (Of course this completely optional, and you switch on user level or permant on map level to a OSM base map.)

You can define your mapbox token in the credentials (token[:mapbox])

### Run application locally

```bash
$ bundle exec rails s
```

### Test application locally


```bash
$ RAILS_ENV=test bundle exec rails db:migrate
$ RAILS_ENV=test COVERAGE=true bundle exec rspec spec
```

## Credits

A project by and for [A Thousand Channels](https://a-thousand-channels.xyz)

Initial code and UI by [Ulf Treger](https://github.com/ut) with kind support by and in collaboration with:

* [Pragma Shift](https://www.pragma-shift.net/), Hamburg, for code donation,
* Treffentotal 2018, Hamburg (first use public case with a map at [map.treffentotal.de](https://map.treffentotal.de), which gets its geolocations from ORTE backend via JSON),
* Participants of mapping workshops of [city/data/explosion](https://citydataexplosion.tumblr.com/) at Kunst- und Kulturverein Spedition, Bremen 2019+
* Members of the working group "Queer narratives, mappped" 💖 for testing, bringing up ideas and feature requests for improving the user interface and the maps and thinking the tool more inclusive,
* [Sandbostel Camp Memorial](https://www.stiftung-lager-sandbostel.de/) for the public submission interface and to [Sefux](https://github.com/Sefux) for coding it.
* [Prototype Fund](https://prototypefund.de/en/) for funding the development in 2021-2022, especially the MapToGo feature, mapping of relations plus some enhanced privacy features,
* A big thanks to [birtona](https://github.com/birtona) for coding the CSV import feature and extending the public API plus improving code quality and to [MarcusRiemer](https://github.com/MarcusRiemer) for code reviews and to the [Civic Data Lab](https://civic-data.de/) for funding the development of these features.
* Thanks [dyedwiper](https://github.com/dyedwiper) for code contributions to the GeoJSON feature.
* A Thousand Channels members [Jarami110d](https://github.com/Jarami110d) and [tab-oo](https://github.com/tab-oo) for creating, editing and illustrating the [handbook, a users documentation in the wiki](https://github.com/a-thousand-channels/ORTE-backend/wiki)

There is an active fork by [Leerstandsmeldungen](https://gitlab.com/leerstandsmelder/lsm-orte) with PostgreSQL and Pundit Gem for a more sophisticated model of  authorization and roles.



## Feedback & Contributions

Feedback, bug reports and code contributions are most welcome.

Send your feedback to hello@a-thousand-channels.xyz.

Please file bug reports and feature request to our Github Repository at https://github.com/a-thousand-channels/ORTE-backend

For code contributions, please fork this repo, make a branch, commit your code & [create a pull request](https://help.github.com/en/articles/creating-a-pull-request).

All contributors shall respect the [Contributor Covenant Code of Conduct](https://github.com/a-thousand-channels/ORTE-backend/blob/main/CODE_OF_CONDUCT.md)

Please support our project by [Buy Us A Coffee](https://buymeacoffee.com/a_thousand_channels) or contact us for alternatie ways of supporting us.


## Licence

This project is licensed under a [GNU General Public Licence v3](https://github.com/a-thousand-channels/ORTE-backend/blob/master/LICENSE)
