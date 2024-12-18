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
      Country country = getCountry(completeNumber);
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
      Country country = getCountry(completeNumber);

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

  static Country getCountry(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      throw NumberTooShortException();
    }

    List<Country> matchingCountries = countries.where((country) {
      String dialCode = country.dialCode;
      return phoneNumber.startsWith('+')
          ? phoneNumber.substring(1).startsWith(dialCode)
          : phoneNumber.startsWith(dialCode);
    }).toList();

    if (matchingCountries.isEmpty) {
      throw CountryNotFoundException();
    }

    // Select the most specific match (longest dial code)
    matchingCountries.sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    return matchingCountries.first;
  }

  @override
  String toString() {
    return 'PhoneNumber(countryISOCode: $countryISOCode, countryCode: $countryCode, number: $number)';
  }
}
