root = exports ? this
return unless google?

# Google map class
# Example:
#   gmap = new GoogleMap
#   gmap.apply()
class root.GoogleMap

  #defines whether user can change map pin or not
  immutable: false
  mapSelector: "#gmaps-canvas"
  errorField: "#gmaps-error"
  onSucceed: []
  mapless: false
  _applied: false

  @defaultGmapOptions: {
    zoom: 2
    mapTypeId: google.maps.MapTypeId.ROADMAP
    center: new google.maps.LatLng(51.751724,-1.255284)
  }

  # options: object options
  # gmapOptions: google map api options
  constructor: (options = {}, gmapOptions = {})->
    @gmapOptions = $.extend {}, GoogleMap.defaultGmapOptions, gmapOptions
    this.setOptions options

  setOptions: (options)->
    @immutable = true if options['immutable']
    @mapSelector = options['selector'] if options['selector']
    @errorField = options['errorField'] if options['errorField']
    if options['longitudeInput'] and options['latitudeInput']
      @saveLangLat = true
      @latLng = new LatLngContainer(options['latitudeInput'], options['longitudeInput'])


  apply: ()->
    if($(@mapSelector).length > 0)
      @map = new google.maps.Map $(@mapSelector)[0], @gmapOptions
      @marker = new google.maps.Marker {map: @map, draggable: true}
    else
      @mapless = true
    @geocoder = new google.maps.Geocoder()
    @gmapErrors = new GmapErrors @errorField
    @_addListeners() unless @immutable or @mapless
    @_applied = true

  applied: ()->
    @_applied

  setMarker: (type, value, focusOnMarker = true, afterCallback = ()->)->
    request = {}
    request[type] = value
    @geocoder.geocode request, (results, status)=>
      if status is google.maps.GeocoderStatus.OK and results[0]
        @_succeed results, focusOnMarker
      else
        @_failed(type, value)
      afterCallback()

  searchGeocodes: (term, callback)->
    @geocoder.geocode {'address': term }, (results, status)->
      callback(results, status)

  update: (geocode)->
    unless @mapless
      @map.fitBounds geocode.geometry.viewport
      @marker.setPosition geocode.geometry.location
    @latLng.store(geocode.geometry) if @saveLangLat

  _addListeners: ()->
    google.maps.event.addListener @marker, 'dragend', () =>
      @setMarker 'latLng', @marker.getPosition(), false
    google.maps.event.addListener @map, 'click', (event) =>
      @marker.setPosition event.latLng
      @setMarker 'latLng', event.latLng, false

  _succeed: (results, focusOnMarker)->
    @update(results[0]) if focusOnMarker
    $.map @onSucceed, (callback)->
      callback(results[0].formatted_address)
    @latLng.store(results[0].geometry) if @saveLangLat

  _failed: (type, value)->
    if type is 'address'
      @gmapErrors.incorrectAddress(value)
    else
      @gmapErrors.incorrectLatlng()

# Class for displaying Gmap Errors.
# All the errors can be customised
# There are several type of errors:
#  GmapErrors.wrongInputText
#  GmapErrors.incorrectLatLngText
#  GmapErrors.incorrectAddressText(value)  - callback, incorrect address can be used inside
class root.GmapErrors

  @incorrectLatLngText: "Woah... that's pretty remote! You're going to have to manually enter a place name."

  constructor: (@errorField)->

  incorrectAddress: (value)->
    @cleanErrors()
    @setError(GmapErrors.incorrectAddressText(value))
    @show()

  incorrectLatlng: ()->
    @cleanErrors()
    @setError(@incorrectLatLngText)
    @show()

  @incorrectAddressText: (value)->
    "Sorry! We couldn't find #{value}. Try a different search term, or click the map."

  cleanErrors: ()->
    @setError('')
    @hide()

  show: ()->
    $(@errorField).show()

  hide: ()->
    $(@errorField).hide()

  setError: (text)->
    $(@errorField).html(text)

class root.LatLngContainer
  constructor: (latitudeInput, longitudeInput)->
    @latitudeInput = $(latitudeInput)
    @longitudeInput = $(longitudeInput)

  store: (geometry)->
    @latitudeInput.val(geometry.location.lat())
    @longitudeInput.val(geometry.location.lng())

  clear: ()->
    @latitudeInput.val('')
    @longitudeInput.val('')




