import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

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
          if (state is AuthLoadingState) {
            // Show loading
          } else if (state is AuthErrorState) {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );

            // Animate error on OTP field
            _errorController.add(ErrorAnimationType.shake);
          } else if (state is AuthOtpSentState) {
            // Update verification ID if OTP was resent
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP sent successfully'),
                backgroundColor: AppColors.success,
              ),
            );
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
