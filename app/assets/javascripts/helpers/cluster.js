var markerclusterSettings = {

    // TODO: involve cluster_large, cluster_medium, cluster_small, cluster_xlarge

    create: function(marker_display_mode, data_id, cluster) {
        return {
            maxClusterRadius: 30,
            showCoverageOnHover: false,
            animate: true,
            iconCreateFunction: function(cluster) {
            if ( marker_display_mode == 'cluster' ) {
                return L.divIcon({
                html: '<div class="marker-cluster marker-cluster-small marker-cluster-layer-' + data_id + '"><div>' + cluster.getChildCount() + '</div></div>',
                className: "leaflet-data-markercluster",
                iconAnchor  : [15, 15],
                iconSize    : [30, 30],
                popupAnchor : [0, -28]
                });
            } else {
                console.log("Cluster: Zigzgag",cluster.getChildCount());     

                let cluster_viz = ( marker_display_mode === 'zigzag cluster' ? cluster_small : cluster_small_with_gradient );
                if ( cluster.getChildCount() >= 10 ) {
                cluster_viz = ( marker_display_mode === 'zigzag cluster' ? cluster_xlarge : cluster_xlarge_with_gradient );
                } else if ( cluster.getChildCount() >= 6 ) {
                cluster_viz = ( marker_display_mode === 'zigzag cluster' ? cluster_large : cluster_large_with_gradient );
                } else if ( cluster.getChildCount() >= 3 ) {
                cluster_viz = ( marker_display_mode === 'zigzag cluster' ? cluster_medium : cluster_medium_with_gradient );
                } 
                if ( layer_color && layer_color.length > 0 ) {
                cluster_viz = cluster_viz.replace(/rgba\(255, 0, 153, 0.8\)/g, layer_color); 
                }
                
                let rnd_rotate = Math.floor(Math.random()*25) * 15;
                return L.divIcon({
                html: '<div class="marker-cluster marker-cluster-small marker-cluster-layer-' + data_id + '" style="transform: rotate('+rnd_rotate+'deg);">' + cluster_viz + '</div>',
                className: "leaflet-data-markercluster",
                iconAnchor  : [15, 15],
                iconSize    : [30, 30],
                popupAnchor : [0, -28]
                });
            }
            },
            spiderLegPolylineOptions: { weight: 0, color: '#efefef', opacity: 0.5 },
            elementsPlacementStrategy: "clock",
            helpingCircles: true,
            clockHelpingCircleOptions: {
                weight: 40,
                opacity: 0,
                color: "#000000",
                fill: "#333",
                fillOpacity: 0.2
            },
            spiderfyDistanceSurplus: 28,
            spiderfyDistanceMultiplier: 1,
            spiderfiedClassName: 'spiderfied-places',
            elementsMultiplier: 1.4,
            firstCircleElements: 10,
            spiderfyShapePositions: function(count, centerPt) {
                var distanceFromCenter = 50,
                    markerDistance = 105,
                    lineLength = markerDistance * (count - 1),
                    lineStart = centerPt.y - lineLength / 4,
                    res = [],
                    i;

                res.length = count;

                for (i = count - 1; i >= 0; i--) {
                    res[i] = new Point(centerPt.x + distanceFromCenter, lineStart + markerDistance * i);
                }

                return res;
            }
        }
    }
};
