import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  // Use 10.0.2.2 instead of 127.0.0.1 for Android emulator
  // final String baseUrl = "http://10.0.2.2:8000";
  final String baseUrl = "http://192.168.8.195:8000"; //ipconfig replace IPv4 Address


  Future<double> getPrediction(String vegetable, String month, double qty) async {
    final url = Uri.parse("$baseUrl/predict");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "vegetable": vegetable,
        "month": month,
        "supply_quantity": qty
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["predicted_waste"] * 1.0; // ensure double
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }
}
