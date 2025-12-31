/*jshint unparam: true, node: true */
/*global jQuery */

function PopupImageOnlyContent(place) {
    'use strict';
    var content = '';

    if (place.imagelink2) {
        content += "<div class='leaflet-popup-content-image'><img src='" + place.imagelink2 + "' /></div>";
    } 
    if (place.edit_link || place.show_link) {
        content += "<p class='text-right'>";
        if (place.show_link) {        
            content += place.show_link;
        }
        if (place.edit_link && place.show_link) {
            content += " | ";
        }
        if (place.edit_link) {
            content += place.edit_link;
        }
        content += "</p>";
    }        
    return content;
}


function PopupFullContent(place) {
    'use strict';
    var content = '';
    if (place.images && place.images[0]) {
        jQuery.each(place.images, function (kkey, image) {
            content += "<div class='leaflet-popup-content-image' id='popup-content-image-'" + kkey + "''><img src='" + image.image_url + "' /></div>";
        });
    }
    if (place.imagelink2) {
        content += "<div class='leaflet-popup-content-image'><img src='" + place.imagelink2 + "' /></div>";
    } else if (place.imagelink) {
        content += "<img src='" + place.imagelink + "' />";
    }
    content += '<div class="leaflet-popup-content-text">';

    var layer_title = place.layer_title;
    if ( layer_title && ( layer_title.length > 30)) {
        layer_title = layer_title.substring(0, 30) + "...";
    }
    content += "<p class='label' style='background-color: "+place.layer_color+"; color: #fff; font-weight: bold; font-size: 10pt;'>" + layer_title + "</p>";
    if (place.date_with_qualifier) {
        content += "<p>" + place.date_with_qualifier;
        if (place.address) {
            content += " // " + place.address;
        }
        content += "</p>";
    } else if (place.address) {
        content += "<p class='shy'>" + place.address;
        if ( place.city) {
            content += ", " + place.city;
        }
        content += "</p>";
    }
    content += "<h4>";
    if (place.show_link) {
        content += place.show_link;
        if (place.published !== true) {
            content += " <i class='fi-lock fi-18'></i>";
        }
    }
    content += "</h4>";
    if (place.subtitle) {
        content += "<p>" + place.subtitle + "</p>";
    }
    if (place.teaser) {
        var teaser = place.teaser.replace(/<[^>]*>?/gm, ''); // remove html
        teaser = teaser.replace(/(?:\r\n|\r|\n)/g, '<br>'); // line breaks
        if (teaser.length > 400) {
            teaser = place.teaser.trim().substring(0, 400).split(" ").slice(0, -1).join(" ") + "...";
        }
        content += "<p>" + teaser + "</p>";
    }
    if (place.url) {
        content += "<p><a href='" + place.url + "'>&gt;&gt;</a></p>";
    }    
    if (place.edit_link) {
        content += "<p class='text-right'>" + place.edit_link + "</p>";
    }
    content += '</div>';
    return content;
}
