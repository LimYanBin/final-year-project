import 'package:aig/API/weather_services.dart';

// class AIEngine {
//   Future<Map<String, List<String>>> recommendOperations(double lat, double lon) async {
//     WeatherService weather = WeatherService();

//     List<Weather> weatherDataList = await weather.fetchWeather(lat, lon);
//     List<String> irrigationTimes = [];
//     List<String> fertilizerTimes = [];
//     List<String> pesticideTimes = [];

//     // Get today's date
//     DateTime today = DateTime.now();

//     // Algorithms
//     for (var weatherData in weatherDataList) {
//       // Check if the date is today
//       if (weatherData.dateTime.year == today.year &&
//           weatherData.dateTime.month == today.month &&
//           weatherData.dateTime.day == today.day) {
        
//         // Restrict to time slots between 8 am and 8 pm
//         if (weatherData.dateTime.hour >= 8 && weatherData.dateTime.hour < 20) {
//           String timeSlot =
//               '${weatherData.dateTime.hour}:00 to ${weatherData.dateTime.hour + 3}:00';

//           // Irrigation recommendation
//           if (weatherData.main.toLowerCase() != 'rain') {
//             irrigationTimes.add(timeSlot);
//           }

//           // Fertilizer and Pesticide recommendation
//           if ((weatherData.main.toLowerCase() == 'clear' || weatherData.main.toLowerCase() == 'clouds') &&
//               weatherData.temperature > 20 &&
//               weatherData.humidity < 70) {
//             fertilizerTimes.add(timeSlot);
//             pesticideTimes.add(timeSlot);
//           }
//         }
//       }
//     }

//     return {
//       'Irrigation': irrigationTimes,
//       'Fertilizer': fertilizerTimes,
//       'Pesticide': pesticideTimes,
//     };
//   }
// }

// Testing Purpose !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

class AIEngine {
  Future<Map<String, List<String>>> recommendOperations(
      double lat, double lon) async {
    WeatherService weather = WeatherService();

    List<Weather> weatherDataList = await weather.fetchWeather(lat, lon);
    List<String> irrigationTimes = [];
    List<String> fertilizerTimes = [];
    List<String> pesticideTimes = [];

    //Algorithms
    for (var weatherData in weatherDataList) {
      if (weatherData.dateTime.hour >= 8 && weatherData.dateTime.hour < 20) {
        String timeSlot =
            '${weatherData.dateTime.hour}:00 to ${weatherData.dateTime.hour + 3}:00';

        // Irrigation recommendation
        if (weatherData.main.toLowerCase() != 'rain') {
          irrigationTimes.add(timeSlot);
        }

        // Fertilizer and Pesticide recommendation
        if ((weatherData.main.toLowerCase() == 'clear' || weatherData.main.toLowerCase() == 'clouds') &&
            weatherData.temperature > 20 &&
            weatherData.humidity < 70) {
          fertilizerTimes.add(timeSlot);
          pesticideTimes.add(timeSlot);
        }
      }
    }

    return {
      'Irrigation': irrigationTimes,
      'Fertilizer': fertilizerTimes,
      'Pesticide': pesticideTimes,
    };
  }
}
