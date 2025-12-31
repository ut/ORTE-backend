/*global jQuery */
/*global window */

jQuery(function ($) {
    "use strict";
    $('#basemaps').on('change', function () {
        console.log(this.value);
        console.log($(this).find('option:selected').data('url'));
        console.log($(this).find('option:selected').data('attribution'));
        console.log($(this).find('option:selected').data('backgroundcolor'));

        if ($('body#maps').length > 0) {
            $('#map_basemap_url').val($(this).find('option:selected').data('url'));
            $('#map_basemap_attribution').val($(this).find('option:selected').data('attribution'));
            $('#map_background_color').val($(this).find('option:selected').data('backgroundcolor'));
        } else if ($('body#layers').length > 0) {
            $('#layer_basemap_url').val($(this).find('option:selected').data('url'));
            $('#layer_basemap_attribution').val($(this).find('option:selected').data('attribution'));
            $('#layer_background_color').val($(this).find('option:selected').data('backgroundcolor'));
        }
        $('#background_color_preselector').val($(this).find('option:selected').data('backgroundcolor'));
        $('#background_color_preview').css('background', $(this).find('option:selected').data('backgroundcolor'));
    });

    // input#color fieldf
    $('#background_color_preselector').on('change', function () {
        console.log(this.value);
        $('#layer_background_color').val(this.value);
        $('#map_background_color').val(this.value);
        $('#background_color_preview').css('background', this.value);
    });

    // input#text
    $('#layer_background_color').on('change', function () {
        console.log(this.value);
        // in case the gradient def comes with a trailing semicolon
        var value = this.value.replace(/;/g, '');
        // in case someone take the css signifier
        value = value.replace(/background:\ /, '');
        $('#layer_background_color').val(value);
        $('#map_background_color').val(this.value);
        $('#background_color_preselector').val(value);
        $('#background_color_preview').css('background', value);
    });
});