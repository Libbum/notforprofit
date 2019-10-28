(function($) {

    var	$window = $(window),
        $body = $('body'),
        $header = $('#header'),
        $banner = $('#banner');

    // Breakpoints.
    breakpoints({
        xlarge:   [ '1281px',  '1680px' ],
        large:    [ '981px',   '1280px' ],
        medium:   [ '737px',   '980px'  ],
        small:    [ '481px',   '736px'  ],
        xsmall:   [ '361px',   '480px'  ],
        xxsmall:  [ null,      '360px'  ]
    });

    // Play initial animations on page load.
    $window.on('load', function() {
        window.setTimeout(function() {
            $body.removeClass('is-preload');
        }, 100);
    });

    // Load icons
    feather.replace();

    // Load Map
    // Default to Stockholm
    var longlat = [18.07, 59.33];
    $.getJSON('https://ipapi.co/json/')
        .done(function(data){
            longlat = [data.longitude, data.latitude];
        })
        .always(function() {
            // For the moment we have to use an external service to get geotags,
            // this operation will be blocked by adblockers, so we need a fallback.
            loadMap();
    });

    function loadMap() {
        var vectorSource = new ol.source.Vector({
        //create empty vector
        });
        //create a bunch of icons and add to source vector
        places = [[18.058557, 59.332988], [18.073571, 59.322962], [18.058814, 59.316655], [11.965559, 57.704551], [11.972080, 57.685561], [11.911971, 57.652400]];
        for (var i=0;i<places.length;i++){
            var iconFeature = new ol.Feature({
                geometry: new ol.geom.Point(ol.proj.fromLonLat(places[i])),
                name: 'NFP Business ' + i,
                locations: 20,
                category: 'clothing'
            });
            vectorSource.addFeature(iconFeature);
        }
        //create the style
        var iconStyle = new ol.style.Style({
            image: new ol.style.Icon(/** @type {olx.style.IconOptions} */ ({
                anchor: [0.5, 46],
                anchorXUnits: 'fraction',
                anchorYUnits: 'pixels',
                opacity: 0.75,
                src: '/images/pin.png'
            }))
        });
        //add the feature vector to the layer vector, and apply a style to whole layer
        var vectorLayer = new ol.layer.Vector({
            source: vectorSource,
            style: iconStyle
        });

        var map = new ol.Map({
            target: 'map', layers: [
                new ol.layer.Tile({
                    source: new ol.source.OSM()
                })
                , vectorLayer],
            view: new ol.View({
                center: ol.proj.fromLonLat(longlat),
                zoom: 13
            })
        });
        var container = document.getElementById('popup');
        var content = document.getElementById('popup-content');
        var closer = document.getElementById('popup-closer');
        var popup = new ol.Overlay({
            element: container,
            autoPan: true,
            autoPanAnimation: {
                duration: 250
            }
        });
        map.addOverlay(popup);

        closer.onclick = function() {
            popup.setPosition(undefined);
            closer.blur();
            return false;
        };
        // display popup on click
        map.on('singleclick', function(evt) {
            var feature = map.forEachFeatureAtPixel(evt.pixel,
                function(feature) {
                    return feature;
                });
            if (feature) {
                var coordinates = feature.getGeometry().getCoordinates();
                popup.setPosition(coordinates);
                content.innerHTML = feature.get('name');
            }
        });

        // change mouse cursor when over marker
        map.on('pointermove', function(e) {
            if (e.dragging) {
                popup.setPosition(undefined);
                closer.blur();
                return;
            }
            map.getTargetElement().style.cursor =
                map.hasFeatureAtPixel(e.pixel) ? 'pointer' : '';
        });
    }

    // Tweaks/fixes.

    // Polyfill: Object fit.
    if (!browser.canUse('object-fit')) {

        $('.image[data-position]').each(function() {

            var $this = $(this),
                $img = $this.children('img');

            // Apply img as background.
            $this
                .css('background-image', 'url("' + $img.attr('src') + '")')
                .css('background-position', $this.data('position'))
                .css('background-size', 'cover')
                .css('background-repeat', 'no-repeat');

            // Hide img.
            $img
                .css('opacity', '0');

        });

    }

    // Scrolly.
    $('.scrolly').scrolly({
        offset: function() { return $header.height() - 5; }
    });

    // Header.
    if ($banner.length > 0
        &&	$header.hasClass('alt')) {

        $window.on('resize', function() { $window.trigger('scroll'); });

        $banner.scrollex({
            bottom:		$header.outerHeight(),
            terminate:	function() { $header.removeClass('alt'); },
            enter:		function() { $header.addClass('alt'); },
            leave:		function() { $header.removeClass('alt'); $header.addClass('reveal'); }
        });

    }

    // Banner.

    // Hack: Fix flex min-height on IE.
    if (browser.name == 'ie') {
        $window.on('resize.ie-banner-fix', function() {

            var h = $banner.height();

            if (h > $window.height())
                $banner.css('height', 'auto');
            else
                $banner.css('height', h);

        }).trigger('resize.ie-banner-fix');
    }

    // Dropdowns.
    $('#nav > ul').dropotron({
        alignment: 'right',
        hideDelay: 350,
        baseZIndex: 100000
    });

    // Menu.
    $('<a href="#navPanel" class="navPanelToggle">Menu ' + feather.icons.menu.toSvg({ class: 'menu-icon' }) + '</a>')
        .appendTo($header);

    $(	'<div id="navPanel">' +
        '<nav>' +
        $('#nav') .navList() +
        '</nav>' +
        '<a href="#navPanel" class="close">' + feather.icons.x.toSvg() +'</a>' +
        '</div>')
        .appendTo($body)
        .panel({
            delay: 500,
            hideOnClick: true,
            hideOnSwipe: true,
            resetScroll: true,
            resetForms: true,
            target: $body,
            visibleClass: 'is-navPanel-visible',
            side: 'right'
        });

})(jQuery);
