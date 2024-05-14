import 'dart:convert';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:diploma/components/weather_item.dart';
import 'package:diploma/components/clothing_item.dart';
import 'package:diploma/constants.dart';
import 'package:diploma/ui/detail_page.dart';
import 'package:diploma/ui/settings_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();
  double _comfortLevel = 2;
  String _gender = '';
  static String API_KEY = 'd21d87f1e252470089e210646242703'; //Paste Your API Here

  String location = 'Astana'; //Default location
  String weatherIcon = 'heavycloud.png';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';
  bool willItRain = false;
  double chanceOfRain = 0;
  bool willItSnow = false;
  double chanceOfSnow = 0;
  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  //API Call
  String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=" +
      API_KEY +
      "&days=7&q=";

  void fetchWeatherData(String searchText) async {
    try {
      var searchResult =
      await http.get(Uri.parse(searchWeatherAPI + searchText));

      final weatherData = Map<String, dynamic>.from(
          json.decode(searchResult.body) ?? 'No data');

      var locationData = weatherData["location"];

      var currentWeather = weatherData["current"];

      setState(() {
        location = getShortLocationName(locationData["name"]);

        var parsedDate =
        DateTime.parse(locationData["localtime"].substring(0, 10));
        var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
        currentDate = newDate;

        //updateWeather
        currentWeatherStatus = currentWeather["condition"]["text"];
        weatherIcon =
            currentWeatherStatus.replaceAll(' ', '').toLowerCase() + ".png";
        temperature = currentWeather["temp_c"].toInt();
        windSpeed = currentWeather["wind_kph"].toInt();
        humidity = currentWeather["humidity"].toInt();
        cloud = currentWeather["cloud"].toInt();
        // willItRain = currentWeather["daily_will_it_rain"];
        //  chanceOfRain = currentWeather["daily_chance_of_rain"];
        //  willItSnow = currentWeather["daily_will_it_snow"];
        //  chanceOfSnow = currentWeather["daily_chance_of_snow"];//
        //Forecast data
        dailyWeatherForecast = weatherData["forecast"]["forecastday"];
        hourlyWeatherForecast = dailyWeatherForecast[0]["hour"];
        print(dailyWeatherForecast);
      });
    } catch (e) {
      //debugPrint(e);
    }
  }

  //function to return the first two names of the string location
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(" ");

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + " " + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }
  void updateComfortLevel(double newComfortLevel) {
    setState(() {
      _comfortLevel = newComfortLevel;
    });
  }

  List<ClothingItem> getOutfitRecommendation(
      int temperature,
      double comfortLevel,
      int humidity,
      int windSpeed,
      int cloud,
      String gender,
      bool willItRain,
      double chanceOfRain,
      bool willItSnow,
      double chanceOfSnow,
      ) {
    List<ClothingItem> recommendations = [];

    // Calculate the discomfort index using the Heat Index formula
    double discomfortIndex = calculateDiscomfortIndex(temperature, humidity);

    // Calculate the cloudiness factor using the cloud cover percentage
    double cloudinessFactor = calculateCloudinessFactor(cloud);

    // Calculate the comfort score using the discomfort index and cloudiness factor
    double comfortScore = calculateComfortScore(discomfortIndex, cloudinessFactor, comfortLevel);

    // Use the comfort score to recommend an outfit
    if (comfortScore > 0.9) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_t-shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/man_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_shorts',
          msg:'Shorts',
          imageUrl: 'assets/images/man_shorts.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_sandals',
          msg:'Sandals',
          imageUrl: 'assets/images/man_sandals.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_dress',
          msg:'Dress',
          imageUrl: 'assets/images/woman_dress.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_sandals',
          msg:'Sandals',
          imageUrl: 'assets/images/woman_sandals.png',
        ));
      }
    }
 else if (comfortScore > 0.8) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_t_shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/man_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_shorts',
          msg:'Shorts',
          imageUrl: 'assets/images/man_shorts.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/man_shoes.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_t-shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/woman_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_skirt',
          msg:'Skirt',
          imageUrl: 'assets/images/woman_skirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_Shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/woman_shoes.png',
        ));
      }
    } else if (comfortScore > 0.7) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_t-shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/man_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_pants',
          msg:'Pants',
          imageUrl: 'assets/images/man_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/man_shoes.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_t-shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/woman_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_pants',
          msg:'Pants',
          imageUrl: 'assets/images/woman_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/woman_shoes.png',
        ));
      }
    } else if (comfortScore > 0.6) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_shirt',
          msg:'Shirt',
          imageUrl: 'assets/images/man_shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_pants',
          msg:'Pants',
          imageUrl: 'assets/images/man_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/man_shoes.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_shirt',
          msg:'Shirt',
          imageUrl: 'assets/images/woman_shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_pants',
          msg:'Pants',
          imageUrl: 'assets/images/woman_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/woman_shoes.png',
        ));
      }
    } else if (comfortScore > 0.5) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_shirt',
          msg:'Shirt',
          imageUrl: 'assets/images/man_shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_lightjacket',
          msg:'Light Jacket',
          imageUrl: 'assets/images/man_lightjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_pants',
          msg:'Pants',
          imageUrl: 'assets/images/man_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/man_shoes.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_shirt',
          msg:'Shirt',
          imageUrl: 'assets/images/woman_shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_lightjacket',
          msg:'Light Jacket',
          imageUrl: 'assets/images/woman_lightjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_pants',
          msg:'Pants',
          imageUrl: 'assets/images/woman_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/woman_shoes.png',
        ));
      }
    } else if (comfortScore > 0.4) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_sweater',
          msg:'Sweater',
          imageUrl: 'assets/images/man_sweater.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_lightjacket',
          msg:'Light Jacket',
          imageUrl: 'assets/images/man_lightjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_pants',
          msg:'Pants',
          imageUrl: 'assets/images/man_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/man_shoes.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_sweater',
          msg:'Sweater',
          imageUrl: 'assets/images/woman_sweater.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_lightjacket',
          msg:'Light Jacket',
          imageUrl: 'assets/images/woman_lightjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_pants',
          msg:'Pants',
          imageUrl: 'assets/images/woman_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/woman_shoes.png',
        ));
      }
    } else if (comfortScore > 0.3) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_t-shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/man_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_winterjacket',
          msg:'Winter Jacket',
          imageUrl: 'assets/images/man_winterjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_pants',
          msg:'Pants',
          imageUrl: 'assets/images/man_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/man_shoes.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_t-shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/woman_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_winterjacket',
          msg:'Winter Jacket',
          imageUrl: 'assets/images/woman_winterjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_pants',
          msg:'Pants',
          imageUrl: 'assets/images/woman_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_shoes',
          msg:'Shoes',
          imageUrl: 'assets/images/woman_shoes.png',
        ));
      }
    } else if (comfortScore > 0.2) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_shirt',
          msg:'Shirt',
          imageUrl: 'assets/images/man_shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_winterjacket',
          msg:'Winter Jacket',
          imageUrl: 'assets/images/man_winterjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_pants',
          msg:'Pants',
          imageUrl: 'assets/images/man_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'Winter Boots',
          msg:'man_winterboots',
          imageUrl: 'assets/images/man_winterboots.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_shirt',
          msg:'Shirt',
          imageUrl: 'assets/images/woman_shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_winterjacket',
          msg:'Winter Jacket',
          imageUrl: 'assets/images/woman_winterjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_pants',
          msg:'Pants',
          imageUrl: 'assets/images/woman_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_winterboots',
          msg:'Winter Boots',
          imageUrl: 'assets/images/woman_winterboots.png',
        ));
      }
    } else if (comfortScore > 0.1) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_shirt',
          msg:'Shirt',
          imageUrl: 'assets/images/man_shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_winterjacket',
          msg:'Winter Jacket',
          imageUrl: 'assets/images/man_winterjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_pants',
          msg:'Pants',
          imageUrl: 'assets/images/man_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'man_underwear',
          msg:'Thermal Underwear',
          imageUrl: 'assets/images/man_underwear.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_winterboots',
          msg:'Winter Boots',
          imageUrl: 'assets/images/man_winterboots.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_shirt',
          msg:'Shirt',
          imageUrl: 'assets/images/woman_shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_winterjacket',
          msg:'Winter Jacket',
          imageUrl: 'assets/images/woman_winterjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_pants',
          msg:'Pants',
          imageUrl: 'assets/images/woman_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'woman_underwear',
          msg:'Thermal Underwear',
          imageUrl: 'assets/images/woman_underwear.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_winterboots',
          msg:'Winter Boots',
          imageUrl: 'assets/images/woman_winterboots.png',
        ));
      }
    } else {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_t-shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/man_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_sweater',
          msg:'Sweater',
          imageUrl: 'assets/images/man_sweater.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'man_winterjacket',
          msg:'Winter Jacket',
          imageUrl: 'assets/images/man_winterjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'man_pants',
          msg:'Pants',
          imageUrl: 'assets/images/man_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'man_underwear',
          msg:'Thermal Underwear',
          imageUrl: 'assets/images/man_underwear.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'man_winterboots',
          msg:'Winter Boots',
          imageUrl: 'assets/images/man_winterboots.png',
        ));
      } else {
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_t-shirt',
          msg:'T-Shirt',
          imageUrl: 'assets/images/woman_t-shirt.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_sweater',
          msg:'Sweater',
          imageUrl: 'assets/images/woman_sweater.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.top,
          name: 'woman_winterjacket',
          msg:'Winter Jacket',
          imageUrl: 'assets/images/woman_winterjacket.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.bottom,
          name: 'woman_pants',
          msg:'Pants',
          imageUrl: 'assets/images/woman_pants.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'woman_underwear',
          msg:'Thermal Underwear',
          imageUrl: 'assets/images/woman_underwear.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.footwear,
          name: 'woman_winterboots',
          msg:'Winter Boots',
          imageUrl: 'assets/images/woman_winterboots.png',
        ));
      }
    }

    // Check if it's going to rain and recommend taking an umbrella
    if (willItRain && chanceOfRain > 50) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'man_umbrella',
          msg: 'Umbrella',
          imageUrl: 'assets/images/man_umbrella.png',
        ));
      }
      else{
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'woman_umbrella',
          msg: 'Umbrella',
          imageUrl: 'assets/images/woman_umbrella.png',
        ));
      }
    }
    // Check if it's going to snow and recommend taking appropriate clothing
    if (willItSnow && chanceOfSnow > 50) {
      if (gender == 'Male') {
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'man_hat',
          msg: 'Hat',
          imageUrl: 'assets/images/man_hat.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'man_scarve',
          msg: 'Scarve',
          imageUrl: 'assets/images/man_scarve.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'man_gloves',
          msg: 'Gloves',
          imageUrl: 'assets/images/man_gloves.png',
        ));
      }
      else{
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'woman_hat',
          msg: 'Hat',
          imageUrl: 'assets/images/woman_hat.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'woman_scarve',
          msg: 'Scarve',
          imageUrl: 'assets/images/woman_scarve.png',
        ));
        recommendations.add(ClothingItem(
          type: ClothingType.accessories,
          name: 'woman_gloves',
          msg: 'Gloves',
          imageUrl: 'assets/images/woman_gloves.png',
        ));
      }
    }

    return recommendations;
  }


  double calculateDiscomfortIndex(int temperature, int humidity) {
    return 0.81 * (32 + temperature) + (0.01 * humidity * (32 + temperature - 58)) / (10 + 0.01 * humidity);
  }


  double calculateCloudinessFactor(int cloud) {
    return cloud / 100;
  }

  double calculateComfortScore(double discomfortIndex, double cloudinessFactor, double comfortLevel) {
    return (1 - discomfortIndex / 100) * (1 - cloudinessFactor) * comfortLevel;
  }


  String getOutfitRecommendationByScore(double comfortScore, String gender) {
    if (comfortScore > 0.9) {
      return gender == 'Male' ? 'Wear a t-shirt, shorts and sandals' : 'Wear a dress and sandals.';
    } else if (comfortScore > 0.8) {
      return gender == 'Male' ? 'Wear a t-shirt, shorts and shoes.' : 'Wear a t-shirt, shorts/skirt and shoes.';
    } else if (comfortScore > 0.7) {
      return gender == 'Male' ? 'Wear a t-shirt, pants and shoes.' : 'Wear a t-shirt, pants, and shoes.';
    } else if (comfortScore > 0.6) {
      return gender == 'Male' ? 'Wear a shirt, pants and shoes.' : 'Wear a shirt, pants and shoes.';
    } else if (comfortScore > 0.5) {
      return gender == 'Male' ? 'Wear a shirt, light jacket, pants and shoes.' : 'Wear a shirt, light jacket, pants and shoes.';
    } else if (comfortScore > 0.4) {
      return gender == 'Male' ? 'Wear a sweater, light jacket, pants and shoes.' : 'Wear a sweater, light jacket, pants and shoes.';
    } else if (comfortScore > 0.3) {
      return gender == 'Male' ? 'Wear a t-shirt, winter jacket, pants and shoes.' : 'Wear a t-shirt, winter jacket, pants and shoes.';
    } else if (comfortScore > 0.2) {
      return gender == 'Male' ? 'Wear a shirt, winter jacket, pants and shoes.' : 'Wear a shirt, winter jacket, pants and shoes.';
    } else if (comfortScore > 0.1) {
      return gender == 'Male' ? 'Wear a shirt, winter jacket, thermal underwear, pants and winter boots.' : 'Wear a shirt, winter jacket, thermal underwear, pants and winter boots.';
    } else {
      return gender == 'Male' ? 'Wear a t-shirt, sweater, winter jacket, thermal underwear, pants, and winter boots.' : 'Wear a t-shirt, sweater, winter jacket, thermal underwear, pants, and winter boots.';
    }
  }


// Saving the comfort level
  void saveComfortLevel(double comfortLevel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('comfortLevel', comfortLevel);
  }

// Fetching the comfort level
  void _fetchComfortLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final comfortLevel = prefs.getDouble('comfortLevel') ?? 2;
    setState(() {
      _comfortLevel = comfortLevel;
    });
  }
  void updateGender(String gender) {
    setState(() {
      _gender = gender;
    });
    saveGender(gender);
  }

  void saveGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', gender);
  }


  @override
  void initState() {
    super.initState();
    fetchWeatherData(location);
    _fetchComfortLevel();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 25, left: 1, right: 1),
        color: _constants.primaryColor.withOpacity(.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: size.height * .49,
              decoration: BoxDecoration(
                gradient: _constants.linearGradientBlue,
                boxShadow: [
                  BoxShadow(
                    color: _constants.primaryColor.withOpacity(.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        updateComfortLevel: updateComfortLevel,
                        saveComfortLevel: saveComfortLevel,
                        updateGender: updateGender,
                        saveGender: saveGender,
                        initialGender: _gender,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/settings1.png",
                          width: 40,
                          height: 40,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/pin.png",
                              width: 20,
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _cityController.clear();
                                showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) => SingleChildScrollView(
                                    controller:
                                    ModalScrollController.of(context),
                                    child: Container(
                                      height: size.height * .2,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 70,
                                            child: Divider(
                                              thickness: 3.5,
                                              color: _constants.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextField(
                                            onChanged: (searchText) {
                                              fetchWeatherData(searchText);
                                            },
                                            controller: _cityController,
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: _constants.primaryColor,
                                              ),
                                              suffixIcon: GestureDetector(
                                                onTap: () =>
                                                    _cityController.clear(),
                                                child: Icon(
                                                  Icons.close,
                                                  color: _constants.primaryColor,
                                                ),
                                              ),
                                              hintText: 'Search city e.g. London',
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: _constants.primaryColor,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/profile.png",
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 70,
                      child: Image.asset("assets/" + weatherIcon),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            temperature.toString(),
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = _constants.shader,
                            ),
                          ),
                        ),
                        Text(
                          'o',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = _constants.shader,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currentWeatherStatus,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20.0,
                      ),
                    ),
                    // Text(
                    //   getOutfitRecommendation(temperature, _comfortLevel, humidity, windSpeed, cloud, _gender, willItRain, chanceOfRain, willItSnow, chanceOfSnow),
                    //   style: TextStyle(color: Colors.white60, fontSize: 16), // централизовать
                    // ),
                    Text(
                      currentDate,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Divider(
                        color: Colors.white70,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WeatherItem(
                            value: windSpeed.toInt(),
                            unit: 'km/h',
                            imageUrl: 'assets/windspeed.png',
                          ),
                          WeatherItem(
                            value: humidity.toInt(),
                            unit: '%',
                            imageUrl: 'assets/humidity.png',
                          ),
                          WeatherItem(
                            value: cloud.toInt(),
                            unit: '%',
                            imageUrl: 'assets/cloud.png',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              height: size.height * .20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailPage(dailyForecastWeather: dailyWeatherForecast,))), //this will open forecast screen
                        child: Text(
                          'Forecasts',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: _constants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 109,
                    child: ListView.builder(
                      itemCount: hourlyWeatherForecast.length,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        String currentTime =
                        DateFormat('HH:mm:ss').format(DateTime.now());
                        String currentHour = currentTime.substring(0, 2);

                        String forecastTime = hourlyWeatherForecast[index]["time"]
                            .substring(11, 16);
                        String forecastHour = hourlyWeatherForecast[index]["time"]
                            .substring(11, 13);

                        String forecastWeatherName =
                        hourlyWeatherForecast[index]["condition"]["text"];
                        String forecastWeatherIcon = forecastWeatherName
                            .replaceAll(' ', '')
                            .toLowerCase() +
                            ".png";

                        String forecastTemperature =
                        hourlyWeatherForecast[index]["temp_c"]
                            .round()
                            .toString();
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin: const EdgeInsets.only(right: 20),
                          width: 65,
                          decoration: BoxDecoration(
                            color: currentHour == forecastHour
                                ? Colors.white
                                : _constants.primaryColor,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 5,
                                color: _constants.primaryColor.withOpacity(.2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                forecastTime,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: _constants.greyColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Image.asset(
                                'assets/' + forecastWeatherIcon,
                                width: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    forecastTemperature,
                                    style: TextStyle(
                                      color: _constants.greyColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'o',
                                    style: TextStyle(
                                      color: _constants.greyColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                      fontFeatures: const [
                                        FontFeature.enable('sups'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              height: size.height * .25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cloth recommendation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      itemCount: getOutfitRecommendation(temperature, _comfortLevel, humidity, windSpeed, cloud, _gender, willItRain, chanceOfRain, willItSnow, chanceOfSnow).length,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        ClothingItem clothingItem = getOutfitRecommendation(temperature, _comfortLevel, humidity, windSpeed, cloud, _gender, willItRain, chanceOfRain, willItSnow, chanceOfSnow)[index];
                        int currentHour = 12; // replace with the current hour
                        int forecastHour = 15; // replace with the forecast hour
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          margin: const EdgeInsets.only(right: 0),
                          width: 100,
                          decoration: BoxDecoration(
                            color: currentHour == forecastHour
                                ? Colors.white
                                : _constants.blackColor,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 5,
                                color:
                                _constants.primaryColor.withOpacity(.2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                clothingItem.msg,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _constants.greyColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Image.asset(
                                'assets/images/' +clothingItem.type.toString().toLowerCase() +'.' + clothingItem.name.toString().toLowerCase() + '.png',
                                width: 70,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}