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
    self = this
    @gmap.onSucceed.push (address)->
      $(self.selector).val address

  source: (self)->
    (request, response)->
      self.gmap.searchGeocodes request.term, (results)->
        response $.map results, (item) ->
          label: item.formatted_address
          value: item.formatted_address
          geocode: item

  select: (self)->
    (event, ui) ->
      self.gmap.update ui.item.geocode

  afterApply: ()->
    this._addKeyDownHandlers()

  _addKeyDownHandlers: ()->
    self = this
    $(@selector).bind 'keydown', (event)->
      if event.keyCode == 13
        self.gmap.setMarker  'address', $(self.selector).val()
        $(self.selector).autocomplete "disable"
      else
        $(self.selector).autocomplete "enable"

