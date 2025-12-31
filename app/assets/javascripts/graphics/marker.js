/*
call me like this:

var params = {
  color: "red",
  opacity: 1,
  stroke: "black",
  stroke_width: 1,
  stroke_opacity: 1,
  defs_with_gradient: ""
};

var icon = LargeMarkerIcon.create(params);

*/
var LargeMarkerIcon = {

    CustomLargeIcon: L.Icon.extend({
        options: {
            iconSize:     [30, 30],
            iconAnchor:   [15, 15],
            popupAnchor:  [0, -15]
        }
    }),
    iconSVG: function(params) {
        // console.log("PARAMS",params);
        var svg = `<svg height="${params.marker_size}" width="${params.marker_size}" xmlns="http://www.w3.org/2000/svg">${params.defs_with_gradient}<circle class="cls-1" cx="${params.marker_size/2}" cy="${params.marker_size/2}" r="${params.marker_size/2}" fill="${params.color}" fill-opacity="${params.opacity}" stroke="${params.stroke}" stroke-width="${params.stroke_width}" stroke-opacity="${params.stroke_opacity}" shape-rendering="geometricPrecision"></circle></svg>`;
        return encodeURI("data:image/svg+xml," + svg).replace(new RegExp('#', 'g'),'%23');
    },
    create: function(params) {
        var defaultParams = {marker_size: 30, color: "black", opacity: 0.7, stroke: "transparent", stroke_width: 0, stroke_opacity: 0, defs_with_gradient: ""};
        params = Object.assign({}, defaultParams, params);        
        // console.log("PARAMS",params);
        return new this.CustomLargeIcon({iconUrl: this.iconSVG(params)});
    }

};