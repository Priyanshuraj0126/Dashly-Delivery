import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  bool _isButtonEnabled = false;
  bool _isResendEnabled = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Log the verification ID and phone number for debugging
    debugPrint('[OTP SCREEN] Verification screen initialized with:');
    debugPrint('[OTP SCREEN] Phone: ${widget.phoneNumber}');
    debugPrint('[OTP SCREEN] VerificationId: ${widget.verificationId}');
    debugPrint('[OTP SCREEN] isRelease: $kReleaseMode');

    // Store the verification ID and phone number again to ensure it's available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<AuthBloc>();
      if (bloc.storageService != null) {
        bloc.storageService!.saveCredentials({
          'verificationId': widget.verificationId,
          'phoneNumber': widget.phoneNumber,
        });
        debugPrint('[OTP SCREEN] Stored credentials in storage service');
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _errorController.close();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _resendOtp() {
    if (_isResendEnabled) {
      // Reset timer and button state
      setState(() {
        _isResendEnabled = false;
        _resendTimer = 30;
      });

      // Request new OTP
      context.read<AuthBloc>().add(SendOtpEvent(widget.phoneNumber));

      // Start timer again
      _startResendTimer();
    }
  }

  void _verifyOtp() {
    if (_otpController.text.length == 6) {
      debugPrint('[OTP SCREEN] Verifying OTP: ${_otpController.text}');
      debugPrint('[OTP SCREEN] With verification ID: ${widget.verificationId}');

      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              verificationId: widget.verificationId,
              otp: _otpController.text,
            ),
          );
    }
  }

  // Empty callback when button should be disabled
  void _doNothing() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('[OTP SCREEN] Auth state changed: ${state.runtimeType}');

          if (state is AuthLoadingState) {
            // Show loading
            debugPrint('[OTP SCREEN] Loading state');
          } else if (state is AuthErrorState) {
            // Show error
            debugPrint('[OTP SCREEN] Error state: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
              ),
            );

            // Animate error on OTP field
            _errorController.add(ErrorAnimationType.shake);

            // Clear the OTP field for retry
            _otpController.clear();
            setState(() {
              _isButtonEnabled = false;
            });
          } else if (state is AuthOtpSentState) {
            // Update verification ID if OTP was resent
            debugPrint('[OTP SCREEN] New OTP sent: ${state.verificationId}');

            // Store the new verification ID
            context.read<AuthBloc>().storageService?.saveCredentials({
              'verificationId': state.verificationId,
              'phoneNumber': state.phoneNumber,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('OTP sent successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AuthAuthenticatedState) {
            debugPrint('[OTP SCREEN] Authentication successful');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Verification Code',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We have sent a verification code to ${widget.phoneNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // OTP Input
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    errorAnimationController: _errorController,
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 56,
                      fieldWidth: 48,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.divider,
                      selectedColor: AppColors.primary,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    onChanged: (value) {
                      setState(() {
                        _isButtonEnabled = value.length == 6;
                      });
                    },
                    beforeTextPaste: (text) {
                      // Return true if the text contains only digits
                      return text?.contains(RegExp(r'^[0-9]+$')) ?? false;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Resend Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      _isResendEnabled
                          ? GestureDetector(
                              onTap: _resendOtp,
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : Text(
                              'Resend in $_resendTimer seconds',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Verify Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Verify',
                        onPressed: _isButtonEnabled ? _verifyOtp : _doNothing,
                        isLoading: state is AuthLoadingState,
                        width: double.infinity,
                        height: 52,
                      );
                    },
                  ),

                  // Add a troubleshooting section for release builds
                  if (kReleaseMode) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Having trouble?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you\'re having trouble with the verification process, try these steps:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Make sure you have a stable internet connection\n'
                      '2. Ensure your phone number is correct\n'
                      '3. Try closing and reopening the app\n'
                      '4. Check that you have the latest app version',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
