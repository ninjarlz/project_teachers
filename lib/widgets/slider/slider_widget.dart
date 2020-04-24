import 'package:flutter/material.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/widgets/slider/slider_thumb_circle.dart';

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final int initValue;
  final int min;
  final int max;
  final fullWidth;
  final ValueChanged<int> onChanged;
  final bool dependantSlider;

  SliderWidget(
      {this.sliderHeight = 48,
      this.initValue = -1,
      this.max = 10,
      this.min = 0,
      this.fullWidth = false,
      this.onChanged,
      this.dependantSlider = false});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initValue != -1) {
      _value = (widget.initValue.toDouble()) / widget.max;
    }
  }

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;
    if (widget.initValue != -1 && widget.dependantSlider) {
      _value = (widget.initValue.toDouble()) / widget.max;
    }

    if (this.widget.fullWidth) paddingFactor = .3;

    return Container(
      width: this.widget.fullWidth
          ? double.infinity
          : (this.widget.sliderHeight) * 5.5,
      height: (this.widget.sliderHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular((this.widget.sliderHeight * .3)),
        ),
        gradient: new LinearGradient(
            colors: [
              Color(ThemeGlobalColor().secondaryColor.value),
              Color(ThemeGlobalColor().secondaryColorDark.value)
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 1.00),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(this.widget.sliderHeight * paddingFactor,
            2, this.widget.sliderHeight * paddingFactor, 2),
        child: Row(
          children: <Widget>[
            Text(
              '${this.widget.min}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: this.widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: this.widget.sliderHeight * .1,
            ),
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),
                    trackHeight: 4.0,
                    thumbShape: SliderThumbCircle(
                      thumbRadius: this.widget.sliderHeight * .4,
                      min: this.widget.min,
                      max: this.widget.max,
                    ),
                    overlayColor: Colors.white.withOpacity(.4),
                    //valueIndicatorColor: Colors.white,
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.white.withOpacity(.7),
                  ),
                  child: Slider(
                      divisions: widget.max,
                      value: _value,
                      onChanged: (value) {
                        setState(() {
                          _value = value;
                          widget.onChanged((widget.max * value).round());
                        });
                      }),
                ),
              ),
            ),
            SizedBox(
              width: this.widget.sliderHeight * .1,
            ),
            Text(
              '${this.widget.max}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: this.widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
