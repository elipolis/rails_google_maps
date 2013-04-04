root = exports ? this
return unless google?

# Google map class
# Example:
#   gmap = new GoogleMap
#   gmap.apply()
class root.GoogleMap

  inputField: '#gmaps-input-address'

  #defines whether user can change map pin or not
  immutable = false

  _applied: false

  @defaultGmapOptions: {
    zoom: 2
    mapTypeId: google.maps.MapTypeId.ROADMAP
    center: new google.maps.LatLng(51.751724,-1.255284)
  }

  # options: object options
  # gmapOptions: google map api options
  constructor: (options = {}, gmapOptions = {}, @mapSelector = "#gmaps-canvas", @errorField = '#gmaps-error')->
    @gmapOptions = $.extend {}, GoogleMap.defaultGmapOptions, gmapOptions
    @immutable = true if options['immutable']
    if options['saveLatLang']
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

  updateMap: (geometry)->
    @map.fitBounds( geometry.viewport )
    @marker.setPosition( geometry.location )

  updateUi: (address, latLng)->
    $(@inputField).val(address)

  applied: ()->
    @_applied

  geocodeLookup: (type, value, update = false)->
    request = {}
    request[type] = value
    self = this
    @geocoder.geocode request, (results, status)->
      self.gmapErrors.cleanErrors()
      if status is google.maps.GeocoderStatus.OK
        self._succeed(results, update)
      else
        self._failed(update, type, value)

  _addListeners: ()->
    self = this
    return if @immutable
    google.maps.event.addListener @marker, 'dragend', () ->
      self.geocodeLookup 'latLng', self.marker.getPosition()
    google.maps.event.addListener @map, 'click', (event) ->
      self.marker.setPosition event.latLng
      self.geocodeLookup 'latLng', event.latLng

  _succeed: (results, update)->
    if results[0]
      this.updateUi results[0].formatted_address, results[0].geometry.location
      this.updateMap(results[0].geometry) if update
      this._saveLatLang(results[0].geometry.location.lat(), results[0].geometry.location.lng()) if @saveLangLat
    else
      @gmapErrors.wrongInputError()

  _failed: (update, type, value)->
    this._saveLatLang('', '') if @saveLangLat
    if type is 'address'
      @gmapErrors.incorrectAddress(value)
    else
      @gmapErrors.incorrectLatlng()
      this.updateUi('', value)

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



