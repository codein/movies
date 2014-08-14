var sfMovieApp = angular.module('movieApp', []);

sfMovieApp.controller('MovieCtrl', function ($scope, $filter, $http) {
    $scope.movies = window.movies;
    $scope.searchText = '';
    $scope.searchTextOffline = '';
    $scope.markersArray = [];
    $scope.currentMovies = [];
    $scope.mode = 'offline';


    var searchOffline = function() {
        console.log($scope.searchText);
        movies = $filter('filter')($scope.movies, $scope.searchText);
        $scope.currentMovies = movies.slice(0,30);
        console.log($scope.currentMovies);
        $scope.clearOverlays();
        $scope.dropAllMarker($scope.currentMovies);
    }

    var searchOnline = function() {
        console.log($scope.searchText);
        var url = 'http://localhost:8888/movies/robin';
        $http({method: 'GET', url: url}).
          success(function(data, status, headers, config) {
            console.log('data');
            console.log(data);
            $scope.currentMovies = data.movies;
            $scope.clearOverlays();
            $scope.dropAllMarker($scope.currentMovies);
          })
    }

    var searchCallback = function() {
        if($scope.mode == 'offline'){
            searchOffline();
        }
        else{
            searchOnline();
        }
    }

    $scope.search = _.debounce(searchCallback, 1000);

    $scope.setSearch = function(searchText) {
        $scope.searchText = searchText;
        $scope.searchCallback();
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
