
/*
 */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  jQuery(function() {
    var GoogleMaps, ResultModel, ResultView, Results, ResultsView, SearchController, _initialize;
    GoogleMaps = (function() {
      function GoogleMaps() {}

      GoogleMaps.dropMarker = function(latitude, longitude, animation) {
        var marker, position;
        if (animation == null) {
          animation = 'DROP';
        }
        switch (animation) {
          case 'BOUNCE':
            animation = google.maps.Animation.BOUNCE;
            break;
          case 'DROP':
            animation = google.maps.Animation.DROP;
            break;
          default:
            animation = google.maps.Animation.DROP;
        }
        position = new google.maps.LatLng(latitude, longitude);
        return marker = new google.maps.Marker({
          position: position,
          map: map,
          draggable: false,
          animation: animation
        });
      };

      return GoogleMaps;

    })();
    ResultModel = (function(_super) {
      __extends(ResultModel, _super);

      function ResultModel() {
        return ResultModel.__super__.constructor.apply(this, arguments);
      }

      ResultModel.prototype.defaults = {
        part1: 'Hello',
        part2: 'Backbone'
      };

      return ResultModel;

    })(Backbone.Model);
    Results = (function(_super) {
      __extends(Results, _super);

      function Results() {
        return Results.__super__.constructor.apply(this, arguments);
      }

      Results.prototype.model = ResultModel;

      return Results;

    })(Backbone.Collection);
    ResultView = (function(_super) {
      __extends(ResultView, _super);

      function ResultView() {
        this.unrender = __bind(this.unrender, this);
        this.render = __bind(this.render, this);
        return ResultView.__super__.constructor.apply(this, arguments);
      }

      ResultView.prototype.initialize = function() {
        _.bindAll(this);
        this.model.bind('change', this.render);
        return this.model.bind('remove', this.unrender);
      };

      ResultView.prototype.render = function() {
        var location, _i, _len, _ref;
        $(this.el).html("\n<div class=\"panel panel-default\">\n  <div class=\"panel-heading\">\n    <a href=\"\">" + (this.model.get('title')) + "</a>\n    <span class=\"badge pull-right\">" + (this.model.get('release_year')) + "</span>\n  </div>\n</div>\n<p><i class=\"fa fa-user\"></i> " + (this.model.get('writer')) + "<i class=\"fa fa-pencil\"></i></p>\n<p><i class=\"fa fa-smile-o\"></i> " + (this.model.get('fun_facts').join('. ')) + "</p>\n<p><i class=\"fa fa-video-camera\"></i> " + (this.model.get('production_company')) + "</p>\n<p><i class=\"fa fa-users\"></i> " + (this.model.get('actors').join(', ')) + "</p>");
        _ref = this.model.get('locations');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          location = _ref[_i];
          $(this.el).append("<p ng-click=\"dropMarker(location.latitude, location.longitude, 'bounce')\">\n  <i class=\"fa fa-location-arrow\"></i>\n  <span class=\"location\">\n    <a href=\"#\" longitude=" + location.longitude + " latitude=" + location.latitude + ">\n      " + location.address + "\n    </a>\n  </span>\n</p>");
        }
        $(this.el).append("<hr>");
        return this;
      };

      ResultView.prototype.unrender = function() {
        return $(this.el).remove();
      };

      ResultView.prototype.onClickLocation = function(e) {
        var latitude, longitude;
        latitude = e.target.getAttribute('latitude');
        longitude = e.target.getAttribute('longitude');
        return GoogleMaps.dropMarker(latitude, longitude, 'BOUNCE');
      };

      ResultView.prototype.remove = function() {
        return this.model.destroy();
      };

      ResultView.prototype.events = {
        'click .location': 'onClickLocation'
      };

      return ResultView;

    })(Backbone.View);
    ResultsView = (function(_super) {
      __extends(ResultsView, _super);

      function ResultsView() {
        this.reset = __bind(this.reset, this);
        this.createResult = __bind(this.createResult, this);
        return ResultsView.__super__.constructor.apply(this, arguments);
      }

      ResultsView.prototype.el = $('span#results');

      ResultsView.prototype.initialize = function() {
        _.bindAll(this);
        this.collection = new Results;
        this.collection.bind('add', this.appendItem);
        this.counter = 0;
        this.render();
        return this.locationMarkers = [];
      };

      ResultsView.prototype.render = function() {
        return $(this.el).append('<ul id="movies"></ul>');
      };

      ResultsView.prototype.renderNoResult = function() {
        return $(this.el).html("<span id=\"no-result\">\n   <div class=\"panel panel-default\">\n      <div class=\"panel-heading\">\n        <a href=\"\">No Results</a>\n        <span class=\"badge pull-right\">0</span>\n      </div>\n    </div>\n    <p>Type into the search box</p>\n<span>");
      };

      ResultsView.prototype.removeNoReuslt = function() {
        return $('#no-result').remove();
      };

      ResultsView.prototype.createResult = function(resultData) {
        var location, locationMarker, resultModel, _i, _len, _ref;
        resultModel = new ResultModel(resultData);
        _ref = resultData.locations;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          location = _ref[_i];
          locationMarker = GoogleMaps.dropMarker(location.latitude.toString(), location.longitude.toString());
          this.locationMarkers.push(locationMarker);
        }
        this.collection.add(resultModel);
        return resultModel;
      };

      ResultsView.prototype.appendItem = function(resultModel) {
        var item_view;
        item_view = new ResultView({
          model: resultModel
        });
        return $('span#results').append(item_view.render().el);
      };

      ResultsView.prototype.reset = function() {

        /*
        Clears all locationMarkers and destroys all models
         */
        var locationMarker, _i, _len, _ref;
        _ref = this.locationMarkers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          locationMarker = _ref[_i];
          locationMarker.setMap(null);
        }
        this.collection.each(function(model) {
          return model.destroy();
        });
        return this.renderNoResult();
      };

      return ResultsView;

    })(Backbone.View);
    SearchController = (function(_super) {
      __extends(SearchController, _super);

      function SearchController() {
        this.search = __bind(this.search, this);
        this.debounceSearch = __bind(this.debounceSearch, this);
        return SearchController.__super__.constructor.apply(this, arguments);
      }

      SearchController.prototype.el = $('body');

      SearchController.prototype.initialize = function() {
        this.resultsView = new ResultsView;
        return this.resultsView.renderNoResult();
      };

      SearchController.prototype.debounceSearch = function() {
        if (this._debounceSearch == null) {
          this._debounceSearch = _.debounce(this.search, 1000);
        }
        return this._debounceSearch();
      };

      SearchController.prototype.addSuggestions = function(suggestions) {
        var suggestion, _i, _len, _results;
        $('#suggestions').html();
        _results = [];
        for (_i = 0, _len = suggestions.length; _i < _len; _i++) {
          suggestion = suggestions[_i];
          _results.push($('#suggestions').append("<option value=\"" + suggestion + "\">"));
        }
        return _results;
      };

      SearchController.prototype.search = function() {
        var searchText;
        searchText = $('#search-text').val();
        console.log('searchText', searchText);
        searchText = encodeURIComponent(searchText);
        return $.ajax({
          url: "/movies?query=" + searchText,
          dataType: "json",
          error: function(jqXHR, textStatus, errorThrown) {
            return console.error(jqXHR, textStatus, errorThrown);
          },
          success: (function(_this) {
            return function(data, textStatus, jqXHR) {
              var resultData, suggestions, _i, _len, _ref;
              console.log(data, textStatus, jqXHR);
              _this.resultsView.reset();
              if (data.movies.length > 0) {
                _this.resultsView.removeNoReuslt();
              }
              suggestions = [];
              _ref = data.movies.slice(0, 6);
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                resultData = _ref[_i];
                suggestions.push(resultData.title);
                _this.resultsView.createResult(resultData);
              }
              return _this.addSuggestions(suggestions);
            };
          })(this)
        });
      };

      SearchController.prototype.events = {
        'keyup :input#search-text': 'debounceSearch'
      };

      return SearchController;

    })(Backbone.View);
    Backbone.sync = function(method, model, success, error) {
      return success();
    };
    _initialize = function() {
      var searchController;
      return searchController = new SearchController();
    };
    return google.maps.event.addDomListener(window, 'load', _initialize);
  });

}).call(this);
