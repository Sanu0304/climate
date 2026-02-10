import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  TextEditingController locationController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "3");

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchWeather() async {
    String location = locationController.text.trim();
    String days = daysController.text.trim();

    if (location.isEmpty || days.isEmpty) {
      setState(() {
        errorMessage = "Please enter location and number of days";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=d3625be3a63d4f6e92160426251811&q=$location&days=$days&aqi=no&alerts=no');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
        });
      } else {
        setState(() {
          errorMessage = "Weather not found!";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong!";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // Title
              Text(
                "Weather Forecast",
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 20),

              /// SEARCH CARD
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10
                      )
                    ]
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Enter Location",
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Days (1-10)",
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade900,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),
                      onPressed: fetchWeather,
                      child: Text("Search", style: TextStyle(fontSize: 18)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (isLoading) CircularProgressIndicator(color: Colors.white),

              if (errorMessage != null)
                Text(errorMessage!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 16)
                ),

              if (weatherData != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: weatherData!["forecast"]["forecastday"].length,
                    itemBuilder: (context, index) {
                      final day = weatherData!["forecast"]["forecastday"][index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                        ),
                        child: ListTile(
                          leading: Image.network(
                            "https:${day["day"]["condition"]["icon"]}",
                            width: 50,
                          ),
                          title: Text(
                            day["date"],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${day["day"]["condition"]["text"]}\nMax: ${day["day"]["maxtemp_c"]}°C | Min: ${day["day"]["mintemp_c"]}°C",
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
