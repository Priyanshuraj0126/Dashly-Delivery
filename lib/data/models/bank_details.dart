/// Model class representing bank account details
class BankDetails {
  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String ifscCode;
  final String? branchName;
  final String? upiId;

  const BankDetails({
    required this.accountHolderName,
    required this.accountNumber,
    required this.bankName,
    required this.ifscCode,
    this.branchName,
    this.upiId,
  });

  /// Create a BankDetails from a map
  factory BankDetails.fromMap(Map<String, dynamic> map) {
    return BankDetails(
      accountHolderName: map['account_holder_name'] as String? ?? '',
      accountNumber: map['account_number'] as String? ?? '',
      bankName: map['bank_name'] as String? ?? '',
      ifscCode: map['ifsc_code'] as String? ?? '',
      branchName: map['branch_name'] as String?,
      upiId: map['upi_id'] as String?,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'ifsc_code': ifscCode,
      'branch_name': branchName,
      'upi_id': upiId,
    };
  }

  /// Create a copy with updated fields
  BankDetails copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? bankName,
    String? ifscCode,
    String? branchName,
    String? upiId,
  }) {
    return BankDetails(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      upiId: upiId ?? this.upiId,
    );
  }
}
