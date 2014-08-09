var sfMovieApp = angular.module('movieApp', []);

sfMovieApp.controller('MovieCtrl', function ($scope, $filter) {
    $scope.movies = window.movies;
    $scope.searchText = ''
    $scope.markersArray = []

    $scope.search = function() {
        movies = $filter('filter')($scope.movies, $scope.searchText)
        if(movies.length<30){
            $scope.clearOverlays()
            $scope.dropAllMarker(movies);
        }
    }

    $scope.setSearch = function(searchText) {
        $scope.searchText = searchText;
        $scope.search();
    }

    $scope.showAll = function() {
        $scope.searchText = '';
        $scope.clearOverlays();
        $scope.dropAllMarker(movies);
    }


    $scope.clearOverlays = function() {
      for (var i = 0; i < $scope.markersArray.length; i++ ) {
        $scope.markersArray[i].setMap(null);
      }
      $scope.markersArray.length = 0;
    }

    $scope.dropMarker = function(latitude, longitude, animation) {
        if(typeof(animation)==='undefined') animation = google.maps.Animation.DROP;
        if(animation==='bounce'){
            animation = google.maps.Animation.BOUNCE;
        }
        position = new google.maps.LatLng(latitude, longitude);
        marker = new google.maps.Marker({
          position:position,
          map: map,
          draggable: false,
          animation: animation,
        });
        $scope.markersArray.push(marker);
    }


    $scope.dropAllMarker = function(movies) {
        movies = $filter('filter')(movies, $scope.searchText)
        for (i = 0; i < movies.length; i++) {
            movie = movies[i];
            for (l = 0; l < movie.locations.length; l++) {
                address = movie.locations[l];
                _dropMarker = angular.bind(self, $scope.dropMarker, address.latitude, address.longitude);
                setTimeout(_dropMarker, i * 200);

            }
        }
    }

});
