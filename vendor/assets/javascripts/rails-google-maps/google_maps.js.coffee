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
      @longitudeInput = options['longitudeInput']
      @latitudeInput = options['latitudeInput']


  apply: ()->
    if($(@mapSelector).length > 0)
      @map = new google.maps.Map $(@mapSelector)[0], @gmapOptions
      @marker = new google.maps.Marker {map: @map, draggable: true}
    else
      @mapless = true
    @geocoder = new google.maps.Geocoder()
    @gmapErrors = new GmapErrors @errorField
    @_addListeners()
    @_applied = true

  applied: ()->
    @_applied

  setMarker: (type, value, update = true, afterCallback = ()->)->
    request = {}
    request[type] = value
    @geocoder.geocode request, (results, status)=>
      @gmapErrors.cleanErrors()
      if status is google.maps.GeocoderStatus.OK
        @_succeed(results, update)
      else
        @_failed(update, type, value)
      afterCallback()

  searchGeocodes: (term, callback)->
    @geocoder.geocode {'address': term }, (results, status)->
      callback(results, status)


  update: (geocode)->
    unless @mapless
      @map.fitBounds geocode.geometry.viewport
      @marker.setPosition geocode.geometry.location
    this.saveLatLang(geocode.geometry) if @saveLangLat

  _addListeners: ()->
    return if @immutable
    unless @mapless
      google.maps.event.addListener @marker, 'dragend', () =>
        @setMarker 'latLng', @marker.getPosition(), false
      google.maps.event.addListener @map, 'click', (event) =>
        @marker.setPosition event.latLng
        @setMarker 'latLng', event.latLng, false

  _succeed: (results, update)->
    if results[0]
      this.update(results[0]) if update
      $.map @onSucceed, (callback)->
        callback(results[0].formatted_address)
      this.saveLatLang(results[0].geometry) if @saveLangLat
    else
      @gmapErrors.wrongInputError()

  _failed: (update, type, value)->
    this.clearLatLng() if @saveLangLat
    if type is 'address'
      @gmapErrors.incorrectAddress(value)
    else
      @gmapErrors.incorrectLatlng()

  saveLatLang: (geometry)->
    $(@latitudeInput).val(geometry.location.lat())
    $(@longitudeInput).val(geometry.location.lng())

  clearLatLng: ()->
    $(@latitudeInput).val('')
    $(@longitudeInput).val('')

# Class for displaying Gmap Errors.
# All the errors can be customised
# There are several type of errors:
#  GmapErrors.wrongInputText
#  GmapErrors.incorrectLatLngText
#  GmapErrors.incorrectAddressText(value)  - callback, incorrect address can be used inside
class root.GmapErrors

  @wrongInputText: "Sorry, something went wrong. Try again!"
  @incorrectLatLngText: "Woah... that's pretty remote! You're going to have to manually enter a place name."

  constructor: (@errorField)->

  incorrectAddress: (value)->
    this.setError(GmapErrors.incorrectAddressText(value))
    this.show()

  incorrectLatlng: ()->
    this.setError(@incorrectLatLngText)
    this.show()

  @incorrectAddressText: (value)->
    "Sorry! We couldn't find #{value}. Try a different search term, or click the map."

  wrongInputError: ()->
    @setError(@wrongInputText)
    @show()

  cleanErrors: ()->
    @setError('')
    @hide()

  show: ()->
    $(@errorField).show()

  hide: ()->
    $(@errorField).hide()

  setError: (text)->
    $(@errorField).html(text)



