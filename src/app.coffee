###
###
jQuery ->

  class GoogleMaps

    @dropMarker: (latitude, longitude, animation='DROP') ->
      switch animation
        when 'BOUNCE'
          animation = google.maps.Animation.BOUNCE

        when 'DROP'
          animation = google.maps.Animation.DROP

        else
          animation = google.maps.Animation.DROP

      position = new google.maps.LatLng(latitude, longitude)
      marker = new google.maps.Marker
        position: position
        map: map
        draggable: false
        animation: animation


  class ResultModel extends Backbone.Model

    defaults:
      part1: 'Hello'
      part2: 'Backbone'

  class Results extends Backbone.Collection

    model: ResultModel


  class ResultView extends Backbone.View

    # tagName: 'div'

    # `initialize()`
    # binds [`change`](http://documentcloud.github.com/backbone/#Model-change)
    # and [`remove`](http://documentcloud.github.com/backbone/#Collection-remove)
    # to `@render` and `@unrender`, respectively.
    initialize: ->
      _.bindAll @

      @model.bind 'change', @render
      @model.bind 'remove', @unrender

    # `render()` now includes two extra `span`s for swapping and deleting
    # an item.
    render: =>
      $(@el).html """

        <div class="panel panel-default">
          <div class="panel-heading">
            <a href="">#{@model.get 'title'}</a>
            <span class="badge pull-right">#{@model.get 'release_year'}</span>
          </div>
        </div>
        <p><i class="fa fa-user"></i> #{@model.get 'writer'} <i class="fa fa-pencil"></i></p>
        <p><i class="fa fa-user"></i> #{@model.get 'director'} <i class="fa fa-scissors"></i></p>
        <p><i class="fa fa-users"></i> #{@model.get('actors').join(', ')}</p>
        <p><i class="fa fa-smile-o"></i> #{@model.get('fun_facts').join('. ')}</p>
        <p><i class="fa fa-video-camera"></i> #{@model.get 'production_company'}</p>
        <p><i class="fa fa-file-video-o"></i> #{@model.get 'distributor'}</p>
      """

      for location in @model.get('locations')
        $(@el).append """
            <p ng-click="dropMarker(location.latitude, location.longitude, 'bounce')">
              <i class="fa fa-location-arrow"></i>
              <span class="location">
                <a href="#" longitude=#{location.longitude} latitude=#{location.latitude}>
                  #{location.address}
                </a>
              </span>
            </p>
        """

      $(@el).append """
        <hr>
      """
      @

    # `unrender()` removes the calling list item from the DOM. This uses
    # [jQuery's `remove()` method](http://api.jquery.com/remove/).
    unrender: =>
      $(@el).remove()

    onClickLocation: (e) ->
      latitude = e.target.getAttribute('latitude')
      longitude = e.target.getAttribute('longitude')
      GoogleMaps.dropMarker(latitude, longitude, 'BOUNCE')


    # `remove()` calls the model's
    # [`destroy()`](http://documentcloud.github.com/backbone/#Model-destroy)
    # method, removing the model from its collection. `destroy()` would
    # normally delete the record from its persistent storage, but we'll
    # override this in `Backbone.sync` below.
    remove: -> @model.destroy()

    # `ResultView`s now respond to two click actions for each `Item`.
    events:
      'click .location': 'onClickLocation'


  # We no longer need to modify the `ResultsView` because `swap` and `delete` are
  # called on each `Item`.
  class ResultsView extends Backbone.View

    el: $ 'span#results'

    initialize: ->
      _.bindAll @

      @collection = new Results
      @collection.bind 'add', @appendItem

      @counter = 0
      @render()
      @locationMarkers = []

    render: ->
      $(@el).append '<ul id="movies"></ul>'

    renderNoResult: ->
      $(@el).html """
      <span id="no-result">
         <div class="panel panel-default">
            <div class="panel-heading">
              <a href="">No Results</a>
              <span class="badge pull-right">0</span>
            </div>
          </div>
          <p><i class="fa fa-keyboard-o"></i> Type into the search box</p>
          <p><i class="fa fa-chevron-down fa-3"></i>   or   <i class="fa fa-chevron-up fa-3"></i></p>
          <p><i class="fa fa-hand-o-up"></i> Click one from below</p>
          <ul id="search-suggestions">
            <li><a field="ACTOR" query="Robin Williams"href="#">Actors: Robin Williams</a></li>
            <li><a field="ADDRESS" query="Alcatraz Island" href="#">Address: Alcatraz Island</a></li>
            <li><a field="DIRECTOR" query="George Lucas" href="#">Director: George Lucas</a></li>
            <li><a field="DISTRIBUTOR" query="Warner Bro" href="#">Distributor: Warner Bro</a></li>
            <li><a field="FUN_FACTS" query="church" href="#">Fun Facts: church</a></li>
            <li><a field="PRODUCTION_COMPANY" query="Warner Bro" href="#">Production Company: Warner Bro</a></li>
            <li><a field="RELEASE_YEAR" query="2014" href="#">Release year: 2014</a></li>
            <li><a field="TITLE" query="Commandments" href="#">Title: Commandments</a></li>
            <li><a field="WRITE" query="Chaplin" href="#">Writer: Chaplin</a></li>
          </ul>
      <span>
      """

    removeNoReuslt: ->
      $('#no-result').remove()

    createResult: (resultData) =>
      resultModel = new ResultModel(resultData)
      for location in resultData.locations
        locationMarker = GoogleMaps.dropMarker(location.latitude.toString(), location.longitude.toString())
        @locationMarkers.push(locationMarker)

      @collection.add resultModel
      resultModel

    appendItem: (resultModel) ->
      item_view = new ResultView model: resultModel
      $('span#results').append item_view.render().el

    reset: =>
      ###
      Clears all locationMarkers and destroys all models1
      ###
      for locationMarker in @locationMarkers
        locationMarker.setMap(null)

      @collection.each((model) -> model.destroy())
      @renderNoResult()


  class SearchController extends Backbone.View
    el: $ 'body'
    searchFieldEl: $('#search-field')
    searchFieldOptionsEl: $('#search-field-options')
    searchTextEl: $('#search-text')

    SEARCH_FIELDS:
      DIRECTOR:
        label: 'Director'
        value: 'director'

      RELEASE_YEAR:
        label: 'Release year'
        value: 'release_year'

      TITLE:
        label: 'Title'
        value: 'title'

      ADDRESS:
        label: 'Address'
        value: 'addresses'

      ACTOR:
        label: 'Actors'
        value: 'actors'

      WRITE:
        label: 'Writer'
        value: 'writer'

      PRODUCTION_COMPANY:
        label: 'Production Company'
        value: 'production_company'

      DISTRIBUTOR:
        label: 'Distributor'
        value: 'distributor'

      FUN_FACTS:
        label: 'Fun Facts'
        value: 'fun_facts'


    initialize: ->
      @resultsView = new ResultsView
      @resultsView.renderNoResult()
      @searchField = @SEARCH_FIELDS.TITLE
      @render()

    render: =>
      @searchFieldEl.html """
       #{@searchField.label} <span class="glyphicon glyphicon-chevron-down"></span>
      """

    onClickSearchField: (e) =>
      fieldName = e.target.getAttribute('field')
      @_setField(fieldName)

    _setField: (fieldName) ->
      @searchField = @SEARCH_FIELDS[fieldName]
      @render()

    _setQuery: (query) =>
      @searchTextEl.val(query)

    onClickSearchSuggestions: (e) =>
      fieldName = e.target.getAttribute('field')
      query = e.target.getAttribute('query')
      @_setField(fieldName)
      @_setQuery(query)
      @search()

    debounceSearch: =>
      @_debounceSearch ?= _.debounce(@search, 500)
      @_debounceSearch()

    addSuggestions: (movies)->
      $('#suggestions').html('')
      suggestions = []
      for movie in movies
        suggestions = if @searchField.value in ['actors', 'addresses']
          suggestions.concat(movie[@searchField.value])
        else if @searchField.value is 'fun_facts'
          _suggestions = (suggestion[0..50] for suggestion in movie[@searchField.value])
          suggestions.concat(_suggestions)
        else
          suggestions.concat([movie[@searchField.value]])

      for suggestion in _.uniq(suggestions)
        $('#suggestions').append "<option value=\"#{suggestion}\">"

    search: =>
      searchText = @searchTextEl.val()
      console.log 'searchText', searchText
      searchText = encodeURIComponent(searchText)
      $.ajax
        url: "/movies?query=#{searchText}&field=#{@searchField.value}"
        dataType: "json"
        error: (jqXHR, textStatus, errorThrown) ->
          console.error jqXHR, textStatus, errorThrown

        success: (searchResults, textStatus, jqXHR) =>
          console.log searchResults, textStatus, jqXHR
          @resultsView.reset()
          @resultsView.removeNoReuslt() if searchResults.movies.length > 0
          @addSuggestions(searchResults.movies)
          for resultData in searchResults.movies[0..10]
            @resultsView.createResult(resultData)


    events:
      'keyup :input#search-text': 'debounceSearch'
      'click #search-field-options': 'onClickSearchField'
      'click #search-suggestions': 'onClickSearchSuggestions'

  # We'll override
  # [`Backbone.sync`](http://documentcloud.github.com/backbone/#Sync)
  Backbone.sync = (method, model, success, error) ->

    # Perform a NOOP when we successfully change our model. In our example,
    # this will happen when we remove each Item view.
    success()

  _initialize = ->
    searchController = new SearchController()

  google.maps.event.addDomListener(window, 'load', _initialize)