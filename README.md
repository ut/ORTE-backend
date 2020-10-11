[![Build Status](https://travis-ci.org/ut/ORTE-backend.svg?branch=main)](https://travis-ci.org/ut/ORTE-backend) ![Release](https://img.shields.io/badge/tag-v0.40-blue.svg) [![Coverage Status](https://coveralls.io/repos/github/ut/ORTE-backend/badge.svg?branch=main)](https://coveralls.io/github/ut/ORTE-backend?branch=main) [![Maintainability](https://api.codeclimate.com/v1/badges/ab3d16e763664a942d72/maintainability)](https://codeclimate.com/github/ut/ORTE-backend/maintainability)


# ORTE-backend

Simple, straightforward backend for creating and managing places/POIs (or in german "Orte") and additional informations of a web-based map. Output is a public available API w/JSON and exportable as CSV/JSON.

Based on Ruby on Rails 5, Postgres, jQuery, Leaflet and Foundation 6.

This application is work in progress. Contributions are welcome (see below).

<img src="https://raw.githubusercontent.com/ut/ORTE-backend/main/app/assets/images/ORTE-sample-map2-overview.jpg" style="max-width: 640px" width="640" />

## Address and geolocation lookup

This application uses [Nominatim](https://nominatim.openstreetmap.org/), a search engine for OpenStreetMap data to look up address and geolocation data. By implementing this application you should respect the [Nominatim Usage Policy](https://operations.osmfoundation.org/policies/nominatim/)!

## Installation

Basic steps for a local installation on your machine:

### Get repository

```bash
$ git clone git@github.com:ut/ORTE-backend.git
```
### Prepare Rails

```bash
$ gem install bundler
$ bundle install
```

### Setup MySQL/Maria DB

```bash
$ sudo mysql -u root
> CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
> GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost';
> CREATE DATABASE orte CHARACTER SET utf8 COLLATE utf8_general_ci;
> exit;
$ bundle exec rails db:schema:load
$ bundle exec rails db:seed
```

### Run


```bash
$ bundlex exec rails s
```

## Credits

Code + Design by Ulf Treger <ulf.treger@googlemail.com> with kind support from:

* Pragma Shift Projects, Hamburg (code donation)
* Treffentotal 2018, Hamburg (acceptance testing and first use public case with a map at [map.treffentotal.de](https://map.treffentotal.de), which gets its geolocations from ORTE backend via JSON)
* and from participants of recent workshops of [city/data/explosion](https://citydataexplosion.tumblr.com/) at Kunst- und Kulturverein Spedition, Bremen.



## Feedback & Contributions

Feedback, bug reports and code contributions are most welcome.

Send Feedback to ulf.treger@googlemail.com

Please file bug reports and feature request to our Github Repository at https://github.com/ut/ORTE-backend

For code contributions, please fork this repo, make a branch, commit your code & [create a pull request](https://help.github.com/en/articles/creating-a-pull-request).

All contributors shall respect the [Contributor Covenant Code of Conduct](https://github.com/ut/ORTE-backend/blob/main/CODE_OF_CONDUCT.md)


## Licence

This project is licensed under a [GNU General Public Licence v3](https://github.com/ut/ORTE-backend/blob/master/LICENSE)
