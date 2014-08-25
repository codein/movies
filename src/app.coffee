###
SF Food Truck UI, includes models and views
###
jQuery ->

  class GoogleMaps
    ###
    A container to hold all google map interactions.
    ###
    @dropMarker: (latitude, longitude, animation='DROP') ->
      ###
      Given latitude, longitude, animation='DROP', letter='Z'
      drops a marker with the appropriate animation on maps
      ###
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
    ###
    Search Result model
    a instance of this model is created for each record returned from the server.
    ###
    defaults:
      part1: 'Hello'
      part2: 'Backbone'

  class Results extends Backbone.Collection
    ###
    A Collection container to hold previously defined ResultModel
    ###
    model: ResultModel


  class ResultView extends Backbone.View
    ###
    A view corresponding to each ResultModel instance
    ###
    initialize: ->
      _.bindAll @

      @model.bind 'change', @render
      @model.bind 'remove', @unrender

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
      ###
      function fired in response to the onClick event for a location
      this animates the corresponding marker for this address.
      ###
      latitude = e.target.getAttribute('latitude')
      longitude = e.target.getAttribute('longitude')
      GoogleMaps.dropMarker(latitude, longitude, 'BOUNCE')

    remove: -> @model.destroy()

    # `ResultView`s now respond to two click actions for each `Item`.
    events:
      'click .location': 'onClickLocation'


  class ResultsView extends Backbone.View
    ###
    The contained holding all individual result views.
    ###
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
      ###
      Renders the no result section when no models have yet been retrieved.
      This section all so includes few location suggestions
      ###
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
      ###
      Given a resultData obj, creates a resultModel.
      ###
      resultModel = new ResultModel(resultData)
      for location in resultData.locations
        locationMarker = GoogleMaps.dropMarker(location.latitude.toString(), location.longitude.toString())
        @locationMarkers.push(locationMarker)

      @collection.add resultModel
      resultModel

    appendItem: (resultModel) ->
      ###
      This function is fired in-respond to a new model addtion to this collection.
      It renders the result view for this model and appends the view to the results listing.
      ###
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
    ###
    Master App controller responsible for
    1. intializing all underlying view/controllers.
    2. Fetch searchResults from server for user requests.
    3. Finally add searchResults to the resultsView.
    ###

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
      ###
      triggered when a field is selected from the field dropdown
      this sets the selected field to be the current field by which serach queries are filtered.
      ###
      fieldName = e.target.getAttribute('field')
      @_setField(fieldName)

    _setField: (fieldName) ->
      @searchField = @SEARCH_FIELDS[fieldName]
      @render()

    _setQuery: (query) =>
      @searchTextEl.val(query)

    onClickSearchSuggestions: (e) =>
      ###
      function trigger when user clicks on any of the suggested locations.
      ###
      fieldName = e.target.getAttribute('field')
      query = e.target.getAttribute('query')
      @_setField(fieldName)
      @_setQuery(query)
      @search()

    debounceSearch: =>
      ###
      Trigger for every change in search-text
      however the underlying search function is wrapper in a debounce so that it is called once in 500ms
      ###
      @_debounceSearch ?= _.debounce(@search, 500)
      @_debounceSearch()

    addSuggestions: (movies)->
      ###
      Takes the current search results to create a suggestions list to promt the test the user is trying to serach.
      ###
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
      ###
      Trigger for every user request
      Firstly, fetches searchResults from server for user requests.
      on success adds searchResults to the resultsView.
      ###
      searchText = @searchTextEl.val()
      searchText = encodeURIComponent(searchText)

      # fire the ajax request to fetch searchResults from API endpoint
      $.ajax
        url: "/movies?query=#{searchText}&field=#{@searchField.value}"
        dataType: "json"
        error: (jqXHR, textStatus, errorThrown) ->
          console.error jqXHR, textStatus, errorThrown

        success: (searchResults, textStatus, jqXHR) =>
          #on success adds searchResults to the resultsView.
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
    # initializa the app once google maps has loaded.
    searchController = new SearchController()

  google.maps.event.addDomListener(window, 'load', _initialize)