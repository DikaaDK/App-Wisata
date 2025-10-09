import 'package:http/http.dart' as http;

Future<void> testApi() async {
  final url = Uri.parse('http://localhost:8080/login'); // ganti URL sesuai API-mu
  final response = await http.get(url);

  if (response.statusCode == 200) {
    print('✅ Success: ${response.body}');
  } else {
    print('❌ Failed: ${response.statusCode}');
  }
}
