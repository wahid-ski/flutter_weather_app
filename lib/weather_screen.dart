import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/additional_info_item.dart'
    show AdditionalInformation;
import 'package:weather_app/hourly_forecast_item.dart' show HourlyForecastItem;
import 'package:weather_app/secrets.dart';

/// The WeatherScreen class is a StatefulWidget in Dart used to display weather information.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  late String backgroundAnimation;
  Timer? _timer;

  final TextEditingController _controller = TextEditingController();
  String _cityName = "Dhaka,BD";
  List<Map<String, dynamic>> _citySuggestions = [];
  bool _isLoadingSuggestions = false;

  Future<void> fetchCitySuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _citySuggestions = []);
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    final encoded = Uri.encodeComponent(input);
    final uri = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$encoded&limit=5&appid=$openWeatherAPIKey',
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      // Decode JSON response (list of city suggestions)
      final data = jsonDecode(res.body) as List<dynamic>;
      // Convert each item to Map<String, dynamic> and update the UI
      setState(() {
        _citySuggestions = data.map((e) => e as Map<String, dynamic>).toList();
      });
    } else {
      setState(() => _citySuggestions = []);
    }

    setState(() => _isLoadingSuggestions = false);
  }

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      // Encode the city name to make it safe for use in the URL (handles spaces and special characters).
      final encoded = Uri.encodeComponent(cityName);

      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$encoded&appid=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || data['cod'].toString() != '200') {
        throw Exception(data['message'] ?? 'City not found');
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather(_cityName);
    _updateBackground();
  }

  void _updateBackground() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      backgroundAnimation = 'assets/lottie/Solar.json'; // Morning
    } else if (hour >= 12 && hour < 18) {
      backgroundAnimation = 'assets/lottie/night.json'; // Afternoon
    } else if (hour >= 18 && hour < 21) {
      backgroundAnimation = 'assets/lottie/Solar.json'; // Evening
    } else {
      backgroundAnimation = 'assets/lottie/night.json'; // Night
    }

    // ---- Calculate time until the next hour ----
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    final durationUntilNextHour = nextHour.difference(now);

    _timer?.cancel();
    _timer = Timer(durationUntilNextHour, _updateBackground);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // CHANGE 1: Removed the Column and suggestions from AppBar
        // Now AppBar only contains the TextField
        title: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Enter city name',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // call geocoding API while typing
            fetchCitySuggestions(value);
          },
          onSubmitted: (value) {
            final q = value.trim();
            if (q.isNotEmpty) {
              setState(() {
                _cityName = q;
                weather = getCurrentWeather(_cityName);
                _citySuggestions = []; // Clear suggestions when submitted
              });
              FocusScope.of(context).unfocus();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final q = _controller.text.trim();
              if (q.isNotEmpty) {
                setState(() {
                  _cityName = q;
                  weather = getCurrentWeather(_cityName);
                  _citySuggestions = []; // Clear suggestions when searched
                });
                FocusScope.of(context).unfocus();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                weather = getCurrentWeather(_cityName);
              });
            },
          ),
        ],
      ),

      // CHANGE 2: Wrapped body in Stack to handle suggestions overlay
      body: Stack(
        children: [
          // Main weather content (your original FutureBuilder)
          FutureBuilder(
            future: weather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Failed to load weather data"),
                      ElevatedButton(
                        onPressed: () {
                          setState(
                            () => weather = getCurrentWeather(_cityName),
                          );
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data!;

              final currentWeather = data['list'][0];

              final currentHumidity = currentWeather['main']['humidity'];
              final currentTemp = (currentWeather['main']['temp'] - 273.15);
              final currentFeelsLike =
                  (currentWeather['main']['feels_like'] - 273.15);
              final currentSky = currentWeather['weather'][0]['main'];
              final currentWindSpeed = currentWeather['wind']['speed'];
              final currentPressure = currentWeather['main']['pressure'];

              return Stack(
                children: [
                  SizedBox.expand(
                    child: Lottie.asset(
                      backgroundAnimation,
                      fit: BoxFit.cover,
                      repeat: true,
                    ),
                  ),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Main card
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 20,
                                    sigmaY: 20,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(13.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${data['city']['name']},${data['city']['country']}',
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '${currentTemp.toStringAsFixed(0)}°C',
                                                style: const TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        if (currentSky == 'Rain' ||
                                            currentSky == 'Drizzle') ...[
                                          Lottie.asset(
                                            'assets/lottie/Rainy.json',
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill,
                                          ),
                                        ] else if (currentSky == 'Clouds' ||
                                            currentSky == 'Atmosphere') ...[
                                          Lottie.asset(
                                            'assets/lottie/Weather-windy.json',
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill,
                                          ),
                                        ] else if (currentSky == 'Clear') ...[
                                          Lottie.asset(
                                            'assets/lottie/Weather-sunny.json',
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill,
                                          ),
                                        ] else if (currentSky ==
                                            'Thunderstorm') ...[
                                          Lottie.asset(
                                            'assets/lottie/Weather-thunder.json',
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill,
                                          ),
                                        ],

                                        Text(
                                          '$currentSky',
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: const Text(
                              'Hourly Forecast',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          SizedBox(
                            height: 175,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: 6,
                              itemExtent: 120,
                              itemBuilder: (context, index) {
                                final forecast = data['list'][index + 1];
                                final temp = forecast['main']['temp'] - 273.15;
                                final time = DateTime.parse(forecast['dt_txt']);
                                final formattedTime = DateFormat.jm().format(
                                  time,
                                );
                                final weatherMain =
                                    forecast['weather'][0]['main'];
                                String lottiePath;

                                switch (weatherMain) {
                                  case 'Clear':
                                    lottiePath =
                                        'assets/lottie/Weather-sunny.json';
                                    break;
                                  case 'Thunderstorm':
                                    lottiePath =
                                        'assets/lottie/Weather-thunder.json';
                                    break;
                                  case 'Rain':
                                    lottiePath = 'assets/lottie/Rainy.json';
                                    break;
                                  case 'Drizzle':
                                    lottiePath = 'assets/lottie/Rainy.json';
                                    break;
                                  case 'Clouds':
                                    lottiePath =
                                        'assets/lottie/Weather-windy.json';
                                    break;
                                  case 'Atmosphere':
                                    lottiePath =
                                        'assets/lottie/Weather-windy.json';
                                    break;
                                  default:
                                    lottiePath =
                                        'assets/lottie/Weather-sunny.json';
                                }

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 7,
                                  ),
                                  child: HourlyForecastItem(
                                    time: formattedTime,
                                    lottiePath: lottiePath,
                                    temperature: '${temp.toStringAsFixed(0)}°C',
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: const Text(
                              'Additional Information',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),

                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AdditionalInformation(
                                  lottiePath: 'assets/lottie/droplet.json',
                                  label: 'Humidity',
                                  value: '${currentHumidity.toString()}%',
                                ),
                                AdditionalInformation(
                                  lottiePath:
                                      'assets/lottie/Forest In Wind Animated Icon.json',
                                  label: 'Wind Speed',
                                  value: '${currentWindSpeed.toString()} m/s',
                                ),
                                AdditionalInformation(
                                  lottiePath: 'assets/lottie/Thermometer.json',
                                  label: 'Feels Like',
                                  value:
                                      '${currentFeelsLike.toStringAsFixed(1)}°C',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            child: Column(
                              children: [
                                Center(
                                  child: AdditionalInformation(
                                    lottiePath:
                                        'assets/lottie/Clock Lottie Animation.json',
                                    label: 'Pressure',
                                    value: '${currentPressure.toString()} hPa',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // CHANGE 3: Background overlay to close suggestions when tapping outside
          // This goes BEHIND the suggestions
          if (_citySuggestions.isNotEmpty)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _citySuggestions = [];
                  });
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  color: const Color.fromARGB(
                    255,
                    0,
                    0,
                    0,
                  ).withValues(), // Slight tint to show overlay
                ),
              ),
            ),

          // CHANGE 4: Suggestions dropdown positioned as overlay
          // This appears ABOVE the background overlay, making it clickable
          if (_citySuggestions.isNotEmpty || _isLoadingSuggestions)
            Positioned(
              top: 0, // Position at the very top of the body (below AppBar)
              left: 0,
              right: 0,
              child: Material(
                elevation: 8.0, // Shadow for dropdown effect
                shadowColor: const Color.fromARGB(255, 0, 0, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: 250, // Limit maximum height
                  ),
                  child: _isLoadingSuggestions
                      ? Container(
                          height: 60,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : ListView.builder(
                          shrinkWrap: true, // Only take needed space
                          physics: BouncingScrollPhysics(),
                          itemCount: _citySuggestions.length,
                          itemBuilder: (context, index) {
                            final city = _citySuggestions[index];

                            /// The above code is written in Dart and it is using the `InkWell` widget.
                            /// The `InkWell` widget is typically used in Flutter to create a rectangular
                            /// area that responds to touch. It provides a visual feedback when touched,
                            /// such as a ripple effect. The `InkWell` widget is commonly used to make
                            /// interactive elements in a Flutter application, like buttons or clickable
                            /// areas.
                            return InkWell(
                              // Better tap response than ListTile
                              onTap: () {
                                print(
                                  'Tapped on: ${city['name']}, ${city['country']}',
                                ); // Debug
                                setState(() {
                                  _cityName =
                                      '${city['name']}, ${city['country']}';
                                  weather = getCurrentWeather(_cityName);
                                  _citySuggestions = []; // Clear suggestions
                                  _controller.text = _cityName;
                                });
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${city['name']}, ${city['country']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: const Color.fromARGB(
                                                221,
                                                255,
                                                255,
                                                255,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (city['state'] != null)
                                            Text(
                                              city['state'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
