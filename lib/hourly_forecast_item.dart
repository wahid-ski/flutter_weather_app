import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final String lottiePath;
  final String temperature;

  const HourlyForecastItem({super.key, 
  required this.time,
   required this.lottiePath, 
   required this.temperature}
   );

  @override
  Widget build(BuildContext context) {
    return Card(
                  elevation: 6,
                  child: Container(
                    width: 115,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Text(time,style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(height: 10),
                        Lottie.asset(
                          lottiePath,
                          width: 70,
                          height: 70,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(height: 5),
                        Text(temperature,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ],
                    ),
                  )
                 );
  }
}