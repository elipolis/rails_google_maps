root = exports ? this

class root.Autocomplete
  source: ()->
    []
  select: ()->
    ()->
  change: ()->
    ()->
  minChars: 2

  constructor: (@selector)->
    @$el = $(@selector)

  apply: ()->
    self = this
    $(@selector).autocomplete
      source: self.source(self)
      select: self.select(self)
      change: self.change(self)
    this.afterApply()

  afterApply: ()->

# Auto complete attached to the GoogleMap object
# Example:
#  gmap = new GoogleMap()
#  gmap.apply()
#  autoComplete = new GmapAutocomplete('#gmaps-input-address', gmap)
#  autoComplete.apply()
class root.GmapAutocomplete extends Autocomplete

  constructor: (@selector, @gmap)->

  source: (self)->
    (request, response)->
      self.gmap.geocoder.geocode {'address': request.term }, (results, status)->
        response $.map results, (item) ->
            label: item.formatted_address
            value: item.formatted_address
            geocode: item

  select: (self)->
    (event, ui) ->
      self.gmap.updateUi  ui.item.value, ui.item.geocode.geometry.location
      self.gmap.updateMap ui.item.geocode.geometry

  afterApply: ()->
    this._addKeyDownHandlers()

  _addKeyDownHandlers: ()->
    self = this
    $(@selector).bind 'keydown', (event)->
      if event.keyCode == 13
        self.gmap.geocodeLookup  'address', $(self.selector).val(), true
        $(self.selector).autocomplete "disable"
      else
        $(self.selector).autocomplete "enable"

