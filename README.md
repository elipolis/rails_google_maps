# Rails + Google Maps

* Gem provides small js library to simplify communication with google maps.
* jQuery Autocomplete integration.


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

And include it in your ```application.js``` file:
```//= require rails_google_maps```


## Usage

1) Apply google map to div element where map should appear:
```js
(new GoogleMap()).apply()
```
By default it will be applied to the element with id '#gmaps-canvas', but it can be customized.

2) You can store selected point (latitude and longitude) in input fields:
```js
new GoogleMap({longitudeInput: '#longitude_input', latitudeInput: '#latitude_input'})
```

3) You can set preferred location from your code:
```js
gmap = new GoogleMap()
gmap.apply()
gmap.geocodeLookup('address', 'New York')
//or
gmap.geocodeLookup('latLng', new google.maps.LatLng(51.751724,-1.255284))
```

4) We can prevent users from changing location:
```js
new GoogleMap({immutable: true})
```

5) You can integrate map with jquery-autocomplete:
```js
gmap = new GoogleMap()
autoComplete = new GmapAutocomplete('#gmaps-input-address', gmap)
autoComplete.apply()
gmap.apply()
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
