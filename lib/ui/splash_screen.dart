import 'package:appwisata/ui/login_page.dart';
import 'package:flutter/material.dart';

// ignore: duplicate_import
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
	const SplashScreen({super.key});

	@override
	State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
	@override
	void initState() {
		super.initState();
		_goToLogin();
	}

	Future<void> _goToLogin() async {
		await Future.delayed(const Duration(seconds: 3));
		if (!mounted) return;
		Navigator.of(context).pushReplacement(
			MaterialPageRoute(builder: (_) => const LoginPage()),
		);
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		return Scaffold(
			backgroundColor: Colors.white,
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						const Icon(Icons.travel_explore, size: 96, color: Colors.blueAccent),
						const SizedBox(height: 16),
						Text(
							'App Wisata',
							style: theme.textTheme.headlineSmall?.copyWith(
								fontWeight: FontWeight.bold,
								color: Colors.blueGrey[800],
							),
						),
						const SizedBox(height: 12),
						const Text(
							'Temukan destinasi terbaik untuk liburanmu',
							style: TextStyle(color: Colors.black54),
						),
						const SizedBox(height: 24),
						const CircularProgressIndicator(),
					],
				),
			),
		);
	}
}
