🌤 Flutter Weather App






A beautiful, real-time weather app built with Flutter using the OpenWeather API.
It shows current weather, hourly forecast, and additional info with smooth Lottie animations and dynamic backgrounds.

🔹 Features

Search for any city worldwide

Real-time weather updates (temperature, humidity, wind speed, pressure, etc.)

Hourly forecast for the next 6 hours

Lottie animations based on weather conditions (rain, sun, clouds, thunderstorm)

Dynamic background based on the time of day

Modern, clean UI design

🔹 Screenshots
Morning 🌅	Rain 🌧	Night 🌙

	
	

(Tip: Capture these using an emulator or physical device.)

🔹 Getting Started
Prerequisites

Flutter SDK installed: Flutter Installation Guide

OpenWeather API key: Get your API key

Installation

Clone this repository:

git clone https://github.com/wahid-ski/flutter_weather_app
.git
cd flutter_weather_app


Install dependencies:

flutter pub get


Create lib/secrets.dart with your API key:

const String openWeatherApiKey = "YOUR_API_KEY_HERE";


Run the app:

flutter run

🔹 Project Structure
lib/
 ├── main.dart
 ├── weather_screen.dart
 ├── hourly_forecast_item.dart
 ├── additional_info_item.dart
 └── secrets.dart (ignored by git)
assets/
 └── lottie/   # Lottie animation files
pubspec.yaml

🔹 Future Improvements

AI-powered weather predictions

8-day forecast view

Dark/light mode toggle

Custom animations for extreme weather

Geolocation-based automatic city detection

🔹 License

This project is licensed under the MIT License – see LICENSE
 for details.

🔹 Contact

Made by Albari Yasir Wahid – check my LinkedIn: [(https://www.linkedin.com/in/45379328a)]

✅ Next Steps:



