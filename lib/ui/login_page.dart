import 'package:appwisata/ui/home_page.dart';
import 'package:appwisata/ui/registrasi_page.dart';
import 'package:flutter/material.dart';
import 'package:appwisata/helpers/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiHelper = Api();
  bool _isLoading = false;
  bool _passwordVisible = false;

  final _emailTextboxController = TextEditingController();
  final _passwordTextboxController = TextEditingController();

  @override
  void dispose() {
    _emailTextboxController.dispose();
    _passwordTextboxController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _apiHelper.login(
          _emailTextboxController.text,
          _passwordTextboxController.text,
        );

        if (response['status'] == true) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        }
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal melakukan login. Silakan coba lagi.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk ke Akun Anda'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerSection(),
                const SizedBox(height: 32),
                _emailTextField(),
                const SizedBox(height: 16),
                _passwordTextField(),
                const SizedBox(height: 32),
                _buttonLogin(),
                const SizedBox(height: 32),
                _menuRegistrasi(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Column(
      children: const [
        Icon(
          Icons.person_pin_circle_rounded,
          size: 80,
          color: Colors.blueAccent,
        ),
        SizedBox(height: 16),
        Text(
          "Selamat Datang Kembali",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          "Silakan masukkan detail akun Anda untuk melanjutkan.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.blueAccent.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      decoration: _inputDecoration('Email', Icons.alternate_email),
      keyboardType: TextInputType.emailAddress,
      controller: _emailTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email harus diisi';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Masukkan email yang valid';
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      decoration: _inputDecoration('Password', Icons.lock).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
      keyboardType: TextInputType.text,
      obscureText: !_passwordVisible,
      controller: _passwordTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password harus diisi';
        }
        return null;
      },
    );
  }

  Widget _buttonLogin() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        onPressed: _isLoading ? null : _submitLogin,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Masuk",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  Widget _menuRegistrasi() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun? ", style: TextStyle(color: Colors.grey)),
        InkWell(
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegistrasiPage()),
            );
          },
        ),
      ],
    );
  }
}
