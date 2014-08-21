
/*
 */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  jQuery(function() {
    var GoogleMaps, Item, ItemView, List, ListView, _initialize;
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
    Item = (function(_super) {
      __extends(Item, _super);

      function Item() {
        return Item.__super__.constructor.apply(this, arguments);
      }

      Item.prototype.defaults = {
        part1: 'Hello',
        part2: 'Backbone'
      };

      return Item;

    })(Backbone.Model);
    List = (function(_super) {
      __extends(List, _super);

      function List() {
        return List.__super__.constructor.apply(this, arguments);
      }

      List.prototype.model = Item;

      return List;

    })(Backbone.Collection);
    ItemView = (function(_super) {
      __extends(ItemView, _super);

      function ItemView() {
        this.unrender = __bind(this.unrender, this);
        this.render = __bind(this.render, this);
        return ItemView.__super__.constructor.apply(this, arguments);
      }

      ItemView.prototype.initialize = function() {
        _.bindAll(this);
        this.model.bind('change', this.render);
        return this.model.bind('remove', this.unrender);
      };

      ItemView.prototype.render = function() {
        var location, _i, _len, _ref;
        $(this.el).html("\n<div class=\"panel panel-default\">\n  <div class=\"panel-heading\">\n    <a href=\"\">" + (this.model.get('title')) + "</a>\n    <span class=\"badge pull-right\">" + (this.model.get('release_year')) + "</span>\n  </div>\n</div>\n<p><i class=\"fa fa-user\"></i> " + (this.model.get('writer')) + "<i class=\"fa fa-pencil\"></i></p>\n<p><i class=\"fa fa-smile-o\"></i> " + (this.model.get('fun_facts').join('. ')) + "</p>\n<p><i class=\"fa fa-video-camera\"></i> " + (this.model.get('production_company')) + "</p>\n<p><i class=\"fa fa-users\"></i> " + (this.model.get('actors').join(', ')) + "</p>");
        _ref = this.model.get('locations');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          location = _ref[_i];
          $(this.el).append("<p ng-click=\"dropMarker(location.latitude, location.longitude, 'bounce')\">\n  <i class=\"location fa fa-location-arrow\"></i>\n  <span class=\"swap\">\n    <a href=\"#\" longitude=" + location.longitude + " latitude=" + location.latitude + ">\n      " + location.address + "\n    </a>\n  </span>\n</p>");
        }
        $(this.el).append("<hr>");
        return this;
      };

      ItemView.prototype.unrender = function() {
        return $(this.el).remove();
      };

      ItemView.prototype.onClickLocation = function(e) {
        var latitude, longitude;
        latitude = e.target.getAttribute('latitude');
        longitude = e.target.getAttribute('longitude');
        return GoogleMaps.dropMarker(latitude, longitude, 'BOUNCE');
      };

      ItemView.prototype.remove = function() {
        return this.model.destroy();
      };

      ItemView.prototype.events = {
        'click .writer': 'onClickLocation',
        'click .swap': 'onClickLocation'
      };

      return ItemView;

    })(Backbone.View);
    ListView = (function(_super) {
      __extends(ListView, _super);

      function ListView() {
        this.appendItem = __bind(this.appendItem, this);
        return ListView.__super__.constructor.apply(this, arguments);
      }

      ListView.prototype.el = $('span#results');

      ListView.prototype.initialize = function() {
        _.bindAll(this);
        this.collection = new List;
        this.collection.bind('add', this.appendItem);
        this.counter = 0;
        return this.render();
      };

      ListView.prototype.render = function() {
        return $(this.el).append('<ul id="movies"></ul>');
      };

      ListView.prototype.createResult = function(resultData) {
        var item, location, _i, _len, _ref;
        item = new Item(resultData);
        this.collection.add(item);
        _ref = resultData.locations;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          location = _ref[_i];
          GoogleMaps.dropMarker(location.latitude.toString(), location.longitude.toString());
        }
        return item;
      };

      ListView.prototype.appendItem = function(item) {
        var item_view;
        item_view = new ItemView({
          model: item
        });
        return $('span#results').append(item_view.render().el);
      };

      return ListView;

    })(Backbone.View);
    Backbone.sync = function(method, model, success, error) {
      return success();
    };
    _initialize = function() {
      var list_view, result, resultData, _i, _len, _ref, _results;
      list_view = new ListView;
      _ref = movies.slice(0, 6);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        resultData = _ref[_i];
        _results.push(result = list_view.createResult(resultData));
      }
      return _results;
    };
    return google.maps.event.addDomListener(window, 'load', _initialize);
  });

}).call(this);
