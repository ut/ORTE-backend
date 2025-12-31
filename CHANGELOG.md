# Changelog
All notable changes to this project (since Version 0.3) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres (more or less) to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.8] - 2024-06-19

With our latest version come a set of improvements and features, that has been developed step by step in the last half year. As in earlier versions, features ideas come in existance usually by request by the contributors of the A Thousand Channels Platform (and if  enough time resources are available by our side for concepting, coding, designing, testing).

With this version we introduce the option of a time-based visualisation. We designed some nice  marker cluster symbols and we added an simple import function for KML and CSV to get a bunch of places with geodata into one map layer. Plus we added a batch importer of georeferenced images. Let's see the details:

### Zigzag Cluster

Clustered markers are a nice feature to keep track of a crowded map when you have multiple entries in the same area. Since some time, we were not happy with the default symbolism of the plugin we used (leaflet.markercluster). We were also not really happy with the circular symbol with a generic color we used instead. 

Now we have created flowery icons with a smooth zigzag outline in four different styles depending on how many points are clustered. You can choose to use these shapes with either a solid color or a nice gradient.

Of course you can disable this option (this is then called "single" mode). Since some events or places exists on the very same coordiniates, we enabled a simplified cluster function just for these places in single mode.

### Time Slider

For the research project "Lacune", we built a time slider to filter the displayed places or events by the year of their existence. Since entries would usually disappear completely after completion or end (at least in our memory and/or in written documents, pictures or videos), we decided that "past" entries remain on the time slider some time after the end date and are displayed as an echo or a shadow (just like past places remain for some time in out memories).

Since we very often have places where we don't know exactly when they start or end, we needed an approach to work with this uncertainty so that these places can also appear in the timeline without falsely referring to precise points in time. That is why we introced fuzzy dates.

### Fuzzy Dates

One focus of the maps created with our tool is the mapping of informal, temporary places. Time is also a factor in describing from when to when a place exists. Often this data is fuzzy, even vague, sometimes unknown. That's why we decided to add qualifiers for dates (start and end date of a place) so that fuzzy dates are declared as such.

It makes a difference whether I say that this place was founded exactly on "February 15, 2005" (by a huge opening party), or sometime "in the mid-2000s". With these qualifiers, it is now possible to distinguish between exact or estimated/fuzzy dates and allows to map places, where not all dates are very precise.

This also allows entries with uncertain dates to be included in the Timeslider! Otherwise, such entries could become invisible if no data is defined due to the fuzziness.


### Imports (KML, CSV, Images)

We have implemented import routines for geodata in KML (Keyhole Markup Language) and CSV (Comma-seperated Values) format. This is useful if you have geodata from another platform and if you want to get those into the database in one single step.

Also a batch import of images with geodata is now possible. You can take a bunch of geocoded photos (e.g. made by your phone with this feature enabled) and import it as an "image layer". The photos will then be displayed on the map on its embedded geolocations. Beware: This might be a privacy issue, depending of which kind of images you upload. Sometimes you don't want to have the exact location of photos you upload. So think carefully which photos in which context you want to place on the map. Consider also the privacy enhancing features of our tool: The removal of geodata of uploaded images, so that also no one, who has direct access to the uploaded files could read out this sensible data!

### Etc

In a very basic implementation we started to embed WMS layer as basemap for maps. More to come.

## [0.72] - 2022-11-28

This release comes with an update to Ruby on Rails 6.1 and some minor fixes.

## [0.71] - 2022-10-03

This release contains some nice improvements and customization for the display of tile layers, map center and the markers on the map.

It's now possible, to set the background (tile layer) per map and per layer. There a some pre-set tile layers, like OSM, satellite or plain background. It is also possible to define a custom tile layer by providing a valid tile layer URL.

The selection per map will be rendered to the backend and will be part of the JSON export. A user working in the backend has now the option to switch temporarily to one of the default or the custom tile layer (if one is set).

Some minor improvements to the map has been made, like the option to set a custom map center and the user option to select between different marker display options (point, text label, image label and relations between points, if defined)

Each place can have one or more annotations (e.g. quotes), every annotation has a n:1 relation wie a person. With this release, the people model is


### Added + Changed

- [UI] Set backend map to mapcenter if defined
- [UI] Add custom tile layers to layer control
- [UI] Inherit basemap/background color setting form parent maps
- [UI] Store and load selected baselayer via localstorage
- [UI] Improve use of the mapcenter subsiding if no parent mapcenter is defined
- [UI] Improve text/label display on map: rotation, margin
- [UI] Improve form UI of maps and layers
- [UI] Show zoom level in header. Toggle text layers on zoomend event
- [Model] People: Connect people to maps (refs #209)

### Fixes

- [Fix] Fix to avoid exception if image blob is gone
- [Fix] Quick fix if layer images are gone
- [Fix] Fix zoom level default overrides lower map extent zoom levels (refs #245)

### Etc

- Improved code coverage (CC now at 94%)
- Added some feature tests
- Fixed some minor bugs
- JS linting (work in progress, about 70% finished)


## [0.7] - 2022-03-03

With this release a map-to-go feature is introduced. With this, a user can preview and auto-generate a Nuxt/Vue-based Client from a map layer they created in the Orte Backend. The client can then be downloaded as a ZIP archive and published on a webspace.

### Added

- Map To Go: UI/Design #165
- Map To Go: Frontend interface #173
- Map To Go: Build library #170
- Map To Go: Metadata for client rendering #153
- Map To Go: Rake task #171
- Adding Preview link #203
- Allow basemap selection per dropdown #167

Plus some minor fixes and improvements

## [0.6] - 2022-01-18

### Added

- Friendly ID for maps and layers #44
- Photo gallery view #123
- A place should be annotated by quotes or comments #124
- Places: Make lat/lon coordinates editable #145
- Make popups visible on mouseover #133
- Cluster group: Design for a mix of places and annotations #134
- Creating new place: Show selected location in the background #139
- Cluster group at map level: Merge all entries of one place and cluster them #141
- Connect places of a layer #135 + Adding/editing relations (between places) (#144)
- Relations: Implement cubic beziers curves to layer maps, via Leaflet.curve (#144)
-  Adding relations + metdata to public json for layers and maps
- Make a place cloneable (with all associations) #146
- Set a map center and zoom level per layer (#159)
- Add carousel/orbit to place show view (#123)

### Fixes

- On some occasions the wrong map extent is shown #131
- Fix sorting of images (#87)

### Etc

- Improved code coverage
- Github Actions with linting by Rubocop, checks by Brakemen and testing with Rspec

## [0.51] - 2021-05-08

Rails 5.2.6 + Ruby 2.7

### Added
- [Feature] Public submission interface (by @Sefux)
- [Feature] Internationalisation for the public interfaces w/Mobility (by @Sefux)

### Changed
- [Improvement] More flexible geo to address resolution, allows city only results


## [0.5] - 2021-03-05

### Added
- [Feature] Simple search within a map
- [UI] Custom iconset per map
- [UI] Tagging per place, tagcloud
- [Feature] Videoupload w/Active Storage + simple html5 player
- [App] Deployment setup w/Capistrano
- plus several smaller improvements and fixes

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
