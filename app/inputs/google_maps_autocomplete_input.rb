class GoogleMapsAutocompleteInput < SimpleForm::Inputs::StringInput
  include ActionView::Helpers::TagHelper
  def input
    gmap_id = input_html_options.delete(:gmap_id)
    apply = input_html_options.key?(:apply) ? input_html_options.delete(:apply) : true
    lat_id = input_html_options.key?(:lat_id) ? input_html_options.delete(:lat_id) : nil
    lng_id = input_html_options.key?(:lng_id) ? input_html_options.delete(:lng_id) : nil
    input = @builder.text_field(attribute_name, input_html_options)
    (input + content_tag('script', script_text(gmap_id, input, apply, lat_id, lng_id).html_safe)).html_safe
  end

  private

  def script_text(gmap_id, tag, apply, lat_id, lng_id)
    "$(document).ready(function(){
      if(typeof google == 'undefined')
        return;
      var selector = '#{gmap_id}';
      if(selector.length > 0){
        selector = '#' + selector;
      }
      window.gmap = new GoogleMap({selector: selector});
      input = $('#{tag}');
      var id = input.attr('id');
      var location = input.val();
      window.gmapAutocomplete = new GmapAutocomplete('#' + id, gmap);
      if(#{apply.to_s}){
        gmap.apply();
        gmapAutocomplete.apply();
      }
      var latId = '#{lat_id.to_s}', lngId = '#{lng_id.to_s}';
      if(latId && lngId){
        gmap.setOptions({longitudeInput: lngId, latitudeInput: latId});
      }
    })"
  end
end
