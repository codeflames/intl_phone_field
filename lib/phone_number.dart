import 'countries.dart';

class NumberTooLongException implements Exception {}

class NumberTooShortException implements Exception {}

class InvalidCharactersException implements Exception {}

class CountryNotFoundException implements Exception {}

class PhoneNumber {
  String countryISOCode;
  String countryCode;
  String number;

  PhoneNumber({
    required this.countryISOCode,
    required this.countryCode,
    required this.number,
  });

  factory PhoneNumber.fromCompleteNumber({required String completeNumber}) {
    if (completeNumber.isEmpty) {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^\+?[0-9]+$');
    if (!validPhoneNumber.hasMatch(completeNumber)) {
      throw InvalidCharactersException();
    }

    try {
      Country country = getCountryByIsoCode(completeNumber);
      String number = completeNumber.startsWith('+')
          ? completeNumber.substring(1 + country.dialCode.length)
          : completeNumber.substring(country.dialCode.length);

      return PhoneNumber(
        countryISOCode: country.code,
        countryCode: country.dialCode,
        number: number,
      );
    } catch (e) {
      throw CountryNotFoundException();
    }
  }

  bool isValidNumber() {
    try {
      Country country = getCountryByIsoCode(completeNumber);

      if (number.length < country.minLength) {
        throw NumberTooShortException();
      }

      if (number.length > country.maxLength) {
        throw NumberTooLongException();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  String get completeNumber => '$countryCode$number';

  static Country getCountryByIsoCode(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      throw NumberTooShortException();
    }

    // Extract the ISO code from the phone number
    final isoCode = _extractIsoCode(phoneNumber);

    // Find the country by ISO code
    final country =
        countries.firstWhere((country) => country.code == isoCode, orElse: () => throw CountryNotFoundException());

    return country;
  }

  static String _extractIsoCode(String phoneNumber) {
    // Remove '+' and extract the first digits that represent the country code
    final digits = phoneNumber.startsWith('+') ? phoneNumber.substring(1) : phoneNumber;

    // Look for a matching country dial code
    for (var country in countries) {
      if (digits.startsWith(country.dialCode)) {
        return country.code;
      }
    }

    throw CountryNotFoundException();
  }

  @override
  String toString() {
    return 'PhoneNumber(countryISOCode: $countryISOCode, countryCode: $countryCode, number: $number)';
  }
}
