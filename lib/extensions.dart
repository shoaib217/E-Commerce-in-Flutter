extension StringValueCheck on String {
  bool isNotNullOrEmpty() {
    return this != "" && this != "null";
  }
}


extension CurrencyConversion on double {
  /// Converts a double value from USD to INR.
  double toRupees() {
    const double usdToInrRate = 83.3; // Example rate
    return this * usdToInrRate;
  }
}