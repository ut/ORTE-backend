/*global $ */

function prepareBeforeLookup(url) {
    'use strict';
    $.ajaxSetup({
        headers: {
            'User-Agent': 'ORTE-Backend, in development (https://github.com/ut/ORTE-backend)',
            crossDomain: true
        }
    });
    var params = getParams();

    // url is provided via data-attr
    // alter this url if there are "remap" and "place" params
    if (params.remap) {
        // call URL + "edit"
        console.log('Lookup :: Alter URL for places > edit');
        url += '/places/' + params.place_id + "/edit";
    } else {
       // call URL + "new"
        console.log('Lookup :: Alter URL for places > new ');
        url += '/places/new';
    }
    return url;
}

function lookupNominatim(address, url) {
    'use strict';
    if ($('#addresslookup_address').hasClass('hide')) {
        showLookUpField();
    } else {
        $('#response').remove();
        $('#selection-hint').html('<p>Searching...</p>');
        var items = [];
        console.log("---------------------");
        console.log("LookupNominatim");
        console.log("Checking for params...");
        url = prepareBeforeLookup(url);
        if (address === '') {
            $('#selection-hint').html("<p><strong>No input!</strong> Please type in a complete address ('Street Number, City')</p>");
            $('#selection-hint').addClass('active');
        }
        if (address.length < 5) {
            console.log('Lookup :: Value too short!');
            $('#selection-hint').html("<p><strong>Input too short.</strong> Please type in a complete address ('Street Number, City')</p>");
            $('#selection-hint').addClass('active');
        } else {
            console.log('Lookup :: ' + address);
            /* example URL
              https://nominatim.openstreetmap.org/search?q=135+pilkington+avenue,+birmingham&format=xml&polygon=1&addressdetails=1
            */
            var nominatium_url = 'https://nominatim.openstreetmap.org/search';
            var nominatium_url_params = '&format=json&addressdetails=1';
            $.getJSON(nominatium_url + "?q=" + address +nominatium_url_params, function (data) {

                console.log(data);
                // if no result
                if (!data || data.length === 0) {
                    console.log('Lookup :: No result');
                    $('#selection-hint').html("<p>Nothing found. Please try another adress!  (Type 'Street Number, City')</p>");
                    $('#selection-hint').addClass('active');
                    return;
                }
                // if results
                console.log("items: " + items.length);
                console.log("response: " + $('#response').length);
                $.each( data, function (key, val) {
                    if (!val || (typeof val === 'undefined')) {
                        return;
                    }
                    console.log('Lookup :: "value.class" ' + val.class);

                    var regexp = /amenity|building|highway|boundary|leisure|landuse/gi;
                    var label = '';
                    if (val.class === 'building') {
                        label = 'Adresse:';
                    }
                    var href = url + '?address=' + val.display_name + '&lat=' + val.lat + '&lon=' + val.lon;

                    // OR better get address details
                    /*
                    pub Café Treibeis
                    house_number  25
                    road  Gaußstraße
                    suburb  Ottensen
                    city_district Altona
                    state Hamburg
                    postcode  22765
                    country Germany
                    country_code  de
                    */

                    if (typeof val.address !== 'undefined') {
                        var location, road, house_number, postcode;
                        location = val.address[Object.keys(val.address)[0]];
                        console.log("Lookup :: Location YEAH " + location);
                        if (typeof val.address.road !== "undefined") {
                            road = val.address.road;
                            if (typeof val.address.house_number !== 'undefined') {
                                house_number = " " + val.address.house_number;
                                address = "&address=" + road + " " + house_number;
                            } else {
                                address = "&address=" + road;
                            }
                        }
                        if (val.address.postcode) {
                            postcode = "&zip=" + val.address.postcode;
                        }
                        var city = '';
                        if (val.address && val.address.city && (val.address.city !== 'undefined')) {
                            city = val.address.city;
                        } else if (val.address.town) {
                            city = val.address.town;
                        } else if (val.address.village) {
                            city = val.address.village;
                        } else if (val.address.municipality) {
                            city = val.address.municipality;
                        } else {
                            city = val.address.state;
                        }
                        /* TODO: verify all values */
                        /* FIXME: hamburg as state */
                        href = url + '?' + location + address + postcode + "&city=" + city + '&lat=' + val.lat + '&lon=' + val.lon;
                        if (val.class.match(regexp)) {
                            console.log('Lookup :: Using entry');
                            items.push("<li id='" + key + "'><a href='" + href + "'>" + label + " " + val.display_name + "</a></li>");
                        } else {
                            $('#selection-hint').html("<p>Sorry, could not find something useful.</p>");
                            $('#selection-hint').addClass('active');
                        }
                    } else {
                        console.log('Lookup :: Empty address value');
                        $('#selection-hint').html("<p>Sorry, something went wrong.</p>");
                        $('#selection-hint').addClass('active');
                    }
                });

                $("<ul/>", {
                    id: "response",
                    html: items.join('')
                }).appendTo("#addresslookup");
                console.log("Success");
                $('#selection-hint').html("<p>Please select one result below (or type in another address).</p>");
                $('#selection-hint').addClass('active');
            }).done(function () {
                console.log('done');
                if (items.length === 0) {
                    $('#selection-hint').html("<p>Sorry, didn't found a match in the osm database.</p>");
                    $('#selection-hint').addClass('active');
                }
            }).fail(function () {
                console.log("error");
                $('#selection-hint').html("</p> :( Nothing found. Please try another input.</p>");
                $('#selection-hint').addClass('active');
            }).always(function () {
                console.log("Complete");
            });
        }
    }
}

function reverseLookupNominatim(map, latlng, lat, lon, url) {
    'use strict';
    console.log('Reverse Lookup :: Lat ' + lat + '/Lon ' + lon);
    var url = prepareBeforeLookup(url);

    if (lat === '') {
        $('#selection-hint').html("<p><strong>No input!</strong> Please try again.</p>");
        $('#selection-hint').addClass('active');
    } else {
        console.log('Reverse Lookup :: ' + lat + "/" + lon);
        //example
        // https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=-34.44076&lon=-58.70521
        var nominatium_reverse_url = 'https://nominatim.openstreetmap.org/reverse';
        var nominatium_url_params = '&format=jsonv2';

        $.getJSON(nominatium_reverse_url + "?lat=" + lat + "&lon=" + lon + nominatium_url_params, function (data) {

            // if no result
            if (!data) {
                console.log('Reverse Lookup :: No result');
                $('#selection-hint').html("<p>Nothing found. Please try another place on the map</p>");
                $('#selection-hint').addClass('active');
                return;
            }
            
            var items = []; var full_address = ''; var href = '';
            if ( data &&  data.error == 'Unable to geocode') {
                console.log('Reverse Lookup :: No result');
                href = url + '?lat=' + lat + '&lon=' + lon;
            } else { 
                // results
                // empty container
                $('#resonse').html(' ');
                console.log(data);
                console.log('Reverse Lookup :: Data '+data.display_name);
                var location = '';
                if (data.name && data.name.length > 0 && data.name != data.address.road) {
                    location = data.name;
                }
                var road = '';
                if (data.address.road) {
                    road = data.address.road || '';
                }
                var postcode = '';
                if (data.address.postcode) {
                    postcode = data.address.postcode || '';
                }
                var city = '';
                if (data.address.city) {
                    city = data.address.city;
                } else if (data.address.town) {
                    city = data.address.town;
                } else if (data.address.village) {
                    city = data.address.village;
                } else if (data.address.municipality) {
                    city = data.address.municipality;
                } else if (data.address.state) {
                    city = data.address.state
                }
                var suburb = '';
                if (data.address.suburb) {
                    suburb = " (" + (data.address.suburb  || '') + ")";
                }
                var house_number = '';
                if (data.address.house_number) {
                    house_number = ' ' + ( data.address.house_number || '');
                }
                var address = '';
                if ( road && house_number) {
                    address = road + " " + house_number + ", ";
                }
                full_address = location + ( location ? '<br />' : '' ) + address + postcode + '&nbsp;' + city + suburb;
                href = url + '?location=' + location + '&address=' + road + house_number + '&zip=' + postcode + '&city=' + city + suburb +'&lat=' + lat + '&lon=' + lon;
            }
          

            // show found place instead
            items.push("<li id='1'><a href='" + href + "'>" + full_address + "</a></li>");
            /*  $( "<ul/>", {
                "id": "response",
                html: items.join( "" ),
              }).appendTo( "#selection" );
            */
            var params = getParams(), hint;
            if (params.remap) {
                hint = 'Re-map to this place';
            } else {
                hint = 'Map this place';
            }
            L.popup().setLatLng(latlng).setContent("<p class='map_this_button text-center'><a href='" + href + "' class='button'>" + hint + "</a><br/>" + full_address + "</p>").openOn(map);
        }).done(function () {
            console.log("success");
            // $('#selection-hint').html("<p>Please select the address shown in the popup or try another input.</p>");
            // $('#selection-hint').addClass('active');
        }).fail(function () {
            console.log("error");
            $('#selection-hint').html("<p>Nothing found. Please try another input.</p>");
            $('#selection-hint').addClass('active');
        }).always(function () {
            console.log("complete");
        });
    }
}

function clearLookUpField() {
    'use strict';
    console.log('clearLookUpField');
    $('#addresslookup_address').addClass('hide');
    $('#addresslookup_address').val('');
    /* disabled
    $('#addresslookup_button i.fi-magnifying-glass').addClass('hide');
    $('#addresslookup_button i.fi-fast-forward').removeClass('hide');
    */
    $('#selection-hint').html("");
    $('#selection-hint').removeClass('active');
}
function showLookUpField() {
    'use strict';
    $('#addresslookup_address').removeClass('hide');
    /* disabled
    $('#addresslookup_button i.fi-magnifying-glass').removeClass('hide');
    $('#addresslookup_button i.fi-fast-forward').addClass('hide');
    */
    $('.leaflet-popup').hide();
    $('#selection-hint').html("");
    $('#selection-hint').removeClass('active');
}
