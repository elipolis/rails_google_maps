class GoogleMapsAutocompleteInput < SimpleForm::Inputs::StringInput
  include ActionView::Helpers::TagHelper
  def input
    gmap_id = input_html_options.delete(:gmap_id)
    apply = input_html_options.delete(:apply)
    input = @builder.text_field(attribute_name, input_html_options)
    (input + content_tag('script', script_text(gmap_id, input, apply).html_safe)).html_safe
  end

  private

  def script_text(gmap_id, tag, apply = true)
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
      if(#{apply}){
        gmap.apply();
        gmapAutocomplete.apply();
      }
      if(location.length > 0){
        gmap.setMarker('address', location);
      }
    })"
  end
end
