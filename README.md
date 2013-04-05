# Rails + Google Maps

* Gem provides small js library to simplify communication with google maps.
* jQuery Autocomplete integration.

Something was taken from https://github.com/rjshade/gmaps-autocomplete

## Installation

Add this line to your application's Gemfile:

    gem 'rails_google_maps'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_google_maps

To use this gem you need to require google map script on the top of your layout(before including application.js).
Haml example:
```ruby
- unless Rails.env == 'test' # we don't like to load gmaps while testing
    %script{:src => "http://maps.googleapis.com/maps/api/js?sensor=false", :type => "text/javascript"}
```

And include it in your ```application.js``` file after jquery:
```
//= require rails-google-maps/google_maps
```


## Usage
####SimpleForm usage:
Google maps autocomplete.
in ```application.js```:
```
//= require rails-google-maps/autocomplete
```
in template:
```erb
/*NOTE: gmap-canvas - default value and can be ommited*/
<%= f.input :address, as: :google_maps_autocomplete, input_html: { gmap_id: 'gmap_canvas' } %> 
...
<div id="gmap_canvas"></div>
```
Additionally on edit address point will be marked on the map.
####Javascript usage:
1) Apply google map to div element where map should appear:
```js
(new GoogleMap()).apply()
```
By default it will be applied to the element with id '#gmaps-canvas', but it can be customized:
```js
(new GoogleMap({selector: '#gmaps'})).apply()
```

2) Store selected point (latitude and longitude) in input fields:
```js
new GoogleMap({longitudeInput: '#longitude_input', latitudeInput: '#latitude_input'})
```

3) Set preferred location from your code:
```js
gmap = new GoogleMap()
gmap.apply()
gmap.geocodeLookup('address', 'New York')
//or
gmap.geocodeLookup('latLng', new google.maps.LatLng(51.751724,-1.255284))
```

4) Prevent users from changing location:
```js
new GoogleMap({immutable: true})
```

5) Integrate map with jquery-autocomplete:
in 'application.js':
```
//= require rails-google-maps/autocomplete
```
in client code:
```js
gmap = new GoogleMap()
autoComplete = new GmapAutocomplete('#gmaps-input-address', gmap)
autoComplete.apply()
gmap.apply()
```
6) Add errors (these - are defaults):
```js
(new GoogleMap({errorField: "#gmaps-error"})).apply() // default errorField is "#gmaps-error"
GmapErrors.wrongInputText = "Sorry, something went wrong. Try again!"
GmapErrors.incorrectLatLngText = "Woah... that's pretty remote! You're going to have to manually enter a place name."
GmapErrors.incorrectAddressText = function(value){"Sorry! We couldn't find " + value + ". Try a different search term, or click the map."}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
