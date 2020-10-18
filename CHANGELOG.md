# Changelog
All notable changes to this project (since Version 0.3) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.41] - 2020-10-11

### Added
- [Feature/MVC] Define a set of icons and connect it to a map, dispay it as map markers
- [Feature] Search for title/teaser/text of all places of one map
- [Images] Better display of metadata and infos
- [Images] Click on image shows large version in a modal
- [UI] Admin view: Combine access to settings, user, groups into one view
- [UI] Adding HTML titles + OG metadata for most views
- [UI] Some smaller improvements and adjustments
- [App] Improve RSpecs + feature tests

### Changed
- Finally removed old way of attaching images directly to places

## [0.40] - 2020-08-20

### Added
- [Place] Improve audio upload a bit
- [App] Adding CODE_OF_CONDUCT
- [App] Switching from masst to main branch

## [0.38] - 2020-07-26

### Added
- [Map] Adding leaflet control module (for user location on map)
- [MVC] Extend Layer and Map with a fulltext column
- [UI]  Sorting images of a place w/XHR
- [Place] Adding basic audio upload and play feature

### Changed
- [UI] Icons, switch from font to inline svg, set favicon

## [0.37] - 2020-05-01

### Added
- [UI] Custom icons for maps, layers, places w/SVG font
- [MVC] Image MVC, now more than one image can be attached to a place

### Changed
- [UI] Better handling of inplace layer change for places
- [UI] Some minor UI improvements

## [0.36] - 2020-04-10

### Changed
- [UI] Adjust some CSS positions, labels, styles
- [Fix] Fix error by resolving a city name
- [Fix] Some minor bugs

## [0.35] - 2020-03-28
### Added
- [UI/Map] Implementing markercluster + style it according to the SVG marker style
- [UI] List map titles A-Z
- [UI/Map] Introduce custom map extend, making it possible to switch from automatic bounds to manuelly set bounds
- [Feature] Export layer as CSV
- [Info] Public accesible help/infotext, adding contact email
- [Info] Basic installation description added

## [0.34] - 2020-01-26
### Added
- [UI] Popup: Nicer image display
- [UI] Improve views for smallscreens, make things like the forms more compact

## [0.33] - 2020-01-05
### Added
- Colored svg markers
- Rich text editor TinyMCE
- WorkSans as main typeface
- Better flow between address lookup and point'n'click on the map to set a new point
. Recenter/zoom map to extend of a places (getbounds())

### Fixed
- Fixed map overall marker display
- Fixed places edit: Only related layer are shown.
- Fixed minor UI things

## [0.32] - 2019-08-14
### Added
- Offer color alternatives for svg markers and selection via UI
- Introduce alternative layer display (places as text, places as images)

### Changed
- Minor UI improvements

## [0.31] - 2019-07-25
### Added
- Colored svg markers
- ColorGenerator Gem


## [0.3] - 2019-07-21
### Added
- More flexible timeformats and image uploads via active storage
