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
        <p><i class="fa fa-user"></i> #{@model.get 'writer'}<i class="fa fa-pencil"></i></p>
        <p><i class="fa fa-smile-o"></i> #{@model.get('fun_facts').join('. ')}</p>
        <p><i class="fa fa-video-camera"></i> #{@model.get 'production_company'}</p>
        <p><i class="fa fa-users"></i> #{@model.get('actors').join(', ')}</p>
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

    render: ->
      $(@el).append '<ul id="movies"></ul>'

    createResult: (resultData) ->
      resultModel = new ResultModel(resultData)
      @collection.add resultModel
      for location in resultData.locations
        GoogleMaps.dropMarker(location.latitude.toString(), location.longitude.toString())

      resultModel

    appendItem: (resultModel) ->
      item_view = new ResultView model: resultModel
      $('span#results').append item_view.render().el


  # We'll override
  # [`Backbone.sync`](http://documentcloud.github.com/backbone/#Sync)
  Backbone.sync = (method, model, success, error) ->

    # Perform a NOOP when we successfully change our model. In our example,
    # this will happen when we remove each Item view.
    success()



  _initialize = ->
    resultsView = new ResultsView
    for resultData in movies[0..5]
      result = resultsView.createResult(resultData)

  google.maps.event.addDomListener(window, 'load', _initialize)
