import 'package:flutter/material.dart';
import 'package:weather_app/domains/weather_model/weather_data_model.dart';
import 'package:weather_app/pages/main_page/widgets/model_hour_weather_widget.dart';

class HoursWeatherWidget extends StatelessWidget {
  final WeatherData weather;

  const HoursWeatherWidget({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: checkDayEnd(),
        itemBuilder: (context, index) {
          return ModelWeatherHourWidget(weather: weather, index: index);
        });
  }

  int checkDayEnd() {
    for (int i = 0; i < 8; i++) {
      if (getOnlyHour(weather.list![i].dtTxt.toString()) == "00:00:00") {
        return i + 1;
      }
    }
    return 8;
  }

  String getOnlyHour(String str) {
    return str.split(' ')[1];
  }
}
