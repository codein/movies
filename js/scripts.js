
// $(document).ready(function(){/* google maps -----------------------------------------------------*/
// google.maps.event.addDomListener(window, 'load', initialize);

// function initialize() {

//   /* position Amsterdam */
//   var latlng = new google.maps.LatLng(52.3731, 4.8922);

//   var mapOptions = {
//     center: latlng,
//     scrollWheel: false,
//     zoom: 13
//   };

//   var marker = new google.maps.Marker({
//     position: latlng,
//     url: '/',
//     animation: google.maps.Animation.DROP
//   });

//   var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
//   marker.setMap(map);

// };
// /* end google maps -----------------------------------------------------*/
// });

var sanFrancisco = new google.maps.LatLng(37.758895, -122.41472420000002);



var markers = [];

var map;
var iterator = 0;

var neighborhoods = [
  new google.maps.LatLng(37.758895, -122.41472420000002),
]

function initialize() {
  var mapOptions = {
    zoom: 12,
    center: sanFrancisco
  };

  map = new google.maps.Map(document.getElementById('map-canvas'),
          mapOptions);
}

// function drop() {
//   iterator = 0;
//   for (var i = 0; i < window.data.length; i++) {
//     setTimeout(function() {
//       addMarker();
//     }, i * 200);
//   }
// }

function addMarker() {
  record = window.data[iterator];
  position = new google.maps.LatLng(record.latitude, record.longitude);
  markers.push(new google.maps.Marker({
    position:position,
    map: map,
    draggable: false,
    animation: google.maps.Animation.DROP
  }));
  iterator++;
}

google.maps.event.addDomListener(window, 'load', initialize);

function addMovies() {
  for (var i = 0; i < window.data.length; i++) {
    appendMovie(window.data[i])
  }
}

function appendMovie(movie) {
  $( ".movie-list" ).append( "<p>Test</p>" );
}