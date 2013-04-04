class GoogleMapsAutocompleteInput < SimpleForm::Inputs::StringInput
  include ActionView::Helpers::TagHelper
  def input
    gmap_id = input_html_options.delete(:gmap_id)
    input = @builder.text_field(attribute_name, input_html_options)
    (input + content_tag('script', script_text(gmap_id, input).html_safe)).html_safe
  end

  private

  def script_text(gmap_id, tag)
    "$(document).ready(function(){
      window.gmap = new GoogleMap({selector: '##{gmap_id}'});
      input = $('#{tag}');
      var id = input.attr('id');
      var location = input.val();
      window.googleAutocomplete = new GmapAutocomplete('#' + id, gmap);
      gmap.apply();
      googleAutocomplete.apply();
      if(location.length > 0){
        gmap.setMarker('address', location);
      }
    })"
  end
end
