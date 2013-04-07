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
    @map = new google.maps.Map $(@mapSelector)[0], @gmapOptions
    @geocoder = new google.maps.Geocoder()
    @marker = new google.maps.Marker {map: @map, draggable: true}
    @gmapErrors = new GmapErrors @errorField
    this._addListeners()
    @_applied = true

  applied: ()->
    @_applied

  setMarker: (type, value, update = true)->
    request = {}
    request[type] = value
    self = this
    @geocoder.geocode request, (results, status)->
      self.gmapErrors.cleanErrors()
      if status is google.maps.GeocoderStatus.OK
        self._succeed(results, update)
      else
        self._failed(update, type, value)

  searchGeocodes: (term, callback)->
    @geocoder.geocode {'address': term }, (results, status)->
      callback(results, status)


  update: (geocode)->
    @map.fitBounds geocode.geometry.viewport
    @marker.setPosition geocode.geometry.location

  _addListeners: ()->
    self = this
    return if @immutable
    google.maps.event.addListener @marker, 'dragend', () ->
      self.setMarker 'latLng', self.marker.getPosition(), false
    google.maps.event.addListener @map, 'click', (event) ->
      self.marker.setPosition event.latLng
      self.setMarker 'latLng', event.latLng, false

  _succeed: (results, update)->
    if results[0]
      this.update(results[0]) if update
      $.map @onSucceed, (callback)->
        callback(results[0].formatted_address)
      this._saveLatLang(results[0].geometry.location.lat(), results[0].geometry.location.lng()) if @saveLangLat
    else
      @gmapErrors.wrongInputError()

  _failed: (update, type, value)->
    this._saveLatLang('', '') if @saveLangLat
    if type is 'address'
      @gmapErrors.incorrectAddress(value)
    else
      @gmapErrors.incorrectLatlng()

  _saveLatLang: (lat, long)->
    $(@latitudeInput).val(lat)
    $(@longitudeInput).val(long)

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
    this.setError(@wrongInputText)
    this.show()

  cleanErrors: ()->
    this.setError('')
    this.hide()

  show: ()->
    $(@errorField).show()

  hide: ()->
    $(@errorField).hide()

  setError: (text)->
    $(@errorField).html(text)



