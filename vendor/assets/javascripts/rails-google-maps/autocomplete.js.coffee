class @Autocomplete
  source: ()=>
    []
  select: ()=>
  change: ()=>
  minChars: 2

  constructor: (selector)->
    @$el = $(selector)

  apply: ()->
    @$el.autocomplete
      source: @source
      select: @select
      change: @change
    this.afterApply()

  afterApply: ()->

# Auto complete attached to the GoogleMap object
# Example:
#  gmap = new GoogleMap()
#  gmap.apply()
#  autoComplete = new GmapAutocomplete('#gmaps-input-address', gmap)
#  autoComplete.apply()
class @GmapAutocomplete extends Autocomplete

  constructor: (selector, @gmap)->
    super selector
    @gmap.onSucceed.push (address)=>
      @$el.val address

  source: (request, response) =>
    @gmap.searchGeocodes request.term, (results)->
      response $.map results, (item) ->
        label: item.formatted_address
        value: item.formatted_address
        geocode: item

  select: (event, ui) =>
    @gmap.update ui.item.geocode

  afterApply: ()->
    @syncWithMap()
    @_addKeyDownHandlers()

  syncWithMap: ()->
    @gmap.setMarker('address', @$el.val()) if @$el.val()

  _addKeyDownHandlers: ()->
    @$el.bind 'keydown', (event)=>
      if event.keyCode == 13
        @gmap.setMarker  'address', @$el.val()
        @$el.autocomplete "disable"
      else
        @$el.autocomplete "enable"

