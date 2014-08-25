Movies
=========
A service that shows on a map where movies have been filmed in San Francisco. The user should be able to filter the view using autocompletion search.
A version hosted at http://146.148.41.202:8888/static/index.html


### Overview

* Features
* Codebase overview
* Setup
    * Data loading.
    * Starting server.
    * Running unitest.
* Development
* Improvements

### Features
* A the landing page the user two option to filter movies
    1. The user could directly start searching, by selecting a field and typing the query.
    2. The user can choose to click on one of the suggested queries. (for ex. "Release year: 2014")
In both the scenarios, the app will behave as follows
Firstly, drop markers for the locations the movie where picturized.
Finally will render records for each movie matching the user query in the left search result listings section.

* Clicking on the address on the record in the listing section, will animate it's coresponding marker.

### Codebase overview

#### Front-end
* App code in `src\app.coffee` and `index.html`
* Implemented using backbone and twitter bootstrap, theme courtesy goes to www.bootply.com
* The <datalist> tag is used to provide an "autocomplete" feature on <input> elements.

#### API Server
* The back end server is implemented as a tornado API server.
* Firstly, the server is used to server the static assets for the app at /static/*
* Secondly, /movies end point searching movies for a given user query from elasticserach

#### Data-Enginnering
* First part is performed using `data/data_engineering.py`
* Firstly, .csv data fetched from data.sfgov.org had to supported with geo-location data.
* Secondly, records where grouped into movie objects with these common attributes ('title','release year','production_company','distributor','director','writer')
* Next these records are written into a .py file.
* Finally the records is pushed into elasticserach using `data\load_elasticsearch.py`

### Setup
* the setup involves primarily going through ./setup.sh
    * Data loading.
    ```
    # load data into elastic serach
    cd data
    python load_elasticsearch.py
    ```
    * Starting server.
    ```
    ./run_server.sh
    ```

    * Running unitest.
    ```
    ./test_runnner.sh
    ```

### Development
Grunt is used to compiling `src\app.coffee` into `js/index.js`
```
grunt watch
```
on saving a .coffee file grunt compiles coffescript into javascript.

### Improvements
* Implement paging for serach results.
* Ansible scripts for automation around setup
* User should be able filter by multiple fields
* Auto completion is implemented currently using HTML5 <datalist>, these are not optimally implemeted across all browsers. Firefox has the best implementation chrome is a bit bad. We might wanna use typeahead.js or jQueryUI autocompletion plugin to have a consisting behaviour.
* use grunt to minify the compiled js.
* use redis to cache results
* use nginx to load balance




