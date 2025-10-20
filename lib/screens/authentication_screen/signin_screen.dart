import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:pneumothoraxdashboard/helpers/session_storage_helpers.dart';
import 'package:pneumothoraxdashboard/api/authentication.dart';
import 'package:pneumothoraxdashboard/main.dart';
import 'package:pneumothoraxdashboard/services/push_notification_service.dart';
import 'package:pneumothoraxdashboard/services/token_refresh_service.dart';
import 'package:pneumothoraxdashboard/constants/responsive_breakpoints.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String deviceType = 'web';
  bool _obscureText = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setDeviceType();
  }

  void _setDeviceType() {
    if (kIsWeb) {
      deviceType = "web";
    } else if (Platform.isAndroid) {
      deviceType = "android";
    } else if (Platform.isIOS) {
      deviceType = "ios";
    }
  }

  void onSignIn() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        // Get FCM device token for authentication
        String? deviceToken = await PushNotificationService.getFCMToken();

        Map<String, dynamic> signInResult = await Authentication.signIn(
          email,
          password,
          deviceToken,
          deviceType,
        );

        bool signInSuccess = signInResult['success'] ?? false;
        Map<String, dynamic>? responseData = signInResult['data'];
        String? errorMessage = signInResult['error'];

        if (signInSuccess) {
          SessionStorageHelpers.setStorage('loginState', 'true');
          SessionStorageHelpers.setStorage(
              'accessToken', responseData?['accessToken']);

          SessionStorageHelpers.setStorage(
              'refreshToken', responseData?['refreshToken']);
          logger.d(responseData?['payload'][0]['user']['_id']);
          SessionStorageHelpers.setStorage(
              'userID', responseData?['payload'][0]['user']['_id']);
          SessionStorageHelpers.setStorage(
              'userRole', responseData?['payload'][0]['user']['userRole']);

          // Initialize token refresh service after successful login
          if (deviceToken != null) {
            TokenRefreshService().initialize(deviceToken, deviceType);
            TokenRefreshService().startTokenRefreshTimer();
          }

          // Navigator.popAndPushNamed(context, '/dashboard');
          Navigator.pushNamed(
            context,
            '/dashboard',
            arguments: {
              'userRole': '${responseData?['payload'][0]['user']['userRole']}'
            },
          );
        } else {
          // Authentication failed
          logger.d('Authentication failed: $errorMessage');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(errorMessage ?? 'Login failed. Please try again.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        logger.d('Login error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please check your connection.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      logger.d('Invalid form');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Responsive breakpoint: Use mobile layout for screens < 768px width
    // OR for actual mobile devices (Android/iOS)
    final bool isMobile = screenSize.width < ResponsiveBreakpoints.mobile ||
        (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: isMobile
            ? _buildMobileLayout(screenSize)
            : _buildWebLayout(screenSize),
      ),
    );
  }

  Widget _buildWebLayout(Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: screenSize.width * 0.5,
              height: screenSize.height,
              child: Center(
                child: Image.asset(
                  'assets/images/appLogo/appLogo_3x-nobg.png',
                  width: screenSize.width * 0.2,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(
              width: screenSize.width * 0.5,
              height: screenSize.height,
              child: Center(
                child: Container(
                  width: screenSize.width * 0.35,
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height * 0.85,
                    minHeight: 500,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF28293D).withOpacity(0.15),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: _buildFormContent(screenSize),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Size screenSize) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: screenSize.width,
          constraints: BoxConstraints(
            minHeight: screenSize.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // QIoT Logo Section
              Container(
                width: screenSize.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/appLogo/appLogo_3x-nobg.png',
                      width: screenSize.width * 0.5,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Connected Healthcare',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF004283),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Sign In Form Section
              Container(
                width: screenSize.width,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF004283).withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _buildFormContent(screenSize),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(Size screenSize) {
    // Responsive breakpoint for form content
    final bool isMobile = screenSize.width < ResponsiveBreakpoints.mobile ||
        (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isMobile ? 32 : 40),
        Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: isMobile ? 22 : 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF004283),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 8 : 12),
        if (isMobile)
          Text(
            'Enter your credentials to access the dashboard',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        SizedBox(height: isMobile ? 16 : 24),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 40,
            vertical: isMobile ? 12 : 0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email ID',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isMobile ? 16 : 20,
                    ),
                  ),
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      _isEmailValid =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email ID is required';
                    } else if (!_isEmailValid) {
                      return 'Enter valid Email ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isMobile ? screenSize.height * 0.025 : 24),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isMobile ? 16 : 20,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    setState(() {
                      _isPasswordValid = RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?]).{8,}$')
                          .hasMatch(value);
                    });
                  },
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    } else if (!_isPasswordValid) {
                      return 'Minimum 8 characters, \nMinimum 1 special character, \nMinimum 1 numerical character, \nMinimum 1 uppercase & lowercase character';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isMobile ? screenSize.height * 0.04 : 32),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          onSignIn();
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      isMobile ? 50 : 56,
                    ),
                    foregroundColor: const Color(0xFFFFFFFF),
                    backgroundColor: const Color(0xFF004283),
                    disabledBackgroundColor:
                        const Color(0xFF004283).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 40,
                      vertical: isMobile ? 16 : 18,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isMobile ? 24 : 16),
        TextButton(
          onPressed: () {
            // Handle forgot password
          },
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF004283),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),
      ],
    );
  }
}
