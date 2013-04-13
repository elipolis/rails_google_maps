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
    $(@selector).autocomplete
      source: @source()
      select: @select()
      change: @change()
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
    @gmap.onSucceed.push (address)=>
      $(_this.selector).val address

  source: ()->
    (request, response) =>
      _this.gmap.searchGeocodes request.term, (results)->
        response $.map results, (item) ->
          label: item.formatted_address
          value: item.formatted_address
          geocode: item

  select: ()->
    (event, ui) =>
      _this.gmap.update ui.item.geocode

  afterApply: ()->
    @syncWithMap()
    @_addKeyDownHandlers()

  syncWithMap: ()->
    @gmap.setMarker('address', $(@selector).val()) if $(@selector).val()

  _addKeyDownHandlers: ()->
    $(@selector).bind 'keydown', (event)=>
      if event.keyCode == 13
        _this.gmap.setMarker  'address', $(_this.selector).val()
        $(_this.selector).autocomplete "disable"
      else
        $(_this.selector).autocomplete "enable"

