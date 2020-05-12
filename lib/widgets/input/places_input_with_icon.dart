import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:project_teachers/services/places/google_places.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/constants/constants.dart';
import 'package:project_teachers/utils/helpers/uuid.dart';
import 'base_input_with_icon.dart';

class PlacesInputWithIconWidget extends StatefulWidget {
  final TextEditingController ctrl;
  final IconData icon;
  final String hint;
  final String error;
  final String language;
  final List<String> placesTypes;
  final Function(String placeId) onPlacePicked;

  PlacesInputWithIconWidget(
      {@required this.ctrl,
      @required this.hint,
      @required this.icon,
      this.error,
      @required this.language,
      @required this.placesTypes,
      this.onPlacePicked});

  @override
  State<StatefulWidget> createState() => PlacesInputWithIconWidgetState();
}

class PlacesInputWithIconWidgetState
    extends BaseInputWithIconWidgetState<PlacesInputWithIconWidget> {
  GooglePlaces _googlePlaces;
  bool _pickerError = false;

  @override
  void initState() {
    super.initState();
    _googlePlaces = GooglePlaces.instance;
  }

  Future<void> onTap() async {
    Prediction prediction = await PlacesAutocomplete.show(
        context: context,
        apiKey: Constants.API_KEY,
        mode: Mode.overlay,
        language: widget.language,
        types: ["establishment"],
        hint: Translations.of(context).text("global_search"),
        components: [
          Component(Component.country, "nl"),
          Component(Component.country, "pl")
        ],
        sessionToken: Uuid().generateV4());
    if (prediction != null) {
      PlacesDetailsResponse detail =
          await _googlePlaces.Places.getDetailsByPlaceId(prediction.placeId);
      if (detail.isOkay) {
        _pickerError = true;
        widget.ctrl.text = detail.result.name;
        if (widget.placesTypes != null) {
          for (String type in detail.result.types) {
            if (widget.placesTypes.contains(type)) {
              _pickerError = false;
              if (widget.onPlacePicked != null) {
                widget.onPlacePicked(detail.result.id);
              }
              break;
            }
          }
        }
      }
    } else {
      if (widget.onPlacePicked != null) {
        widget.onPlacePicked(null);
      }
    }
  }

  String validate(String value) {
    if (value.isEmpty || _pickerError) {
      if (widget.error == null) {
        return Translations.of(context).text("error_unknown");
      }
      return widget.error;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
            controller: widget.ctrl,
            maxLines: 1,
            autofocus: false,
            decoration: setDecoration(
                widget.hint, (widget.icon != null) ? Icon(widget.icon) : null),
            validator: validate,
            onTap: onTap,
            readOnly: true));
  }
}
