import 'package:versatech_investment_companion/core/errors/app_exception.dart';

Map<String, dynamic> asJsonMap(Object? value, String context) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  throw InvalidMarketDataException('Expected a JSON object for $context.');
}

List<dynamic> asJsonList(Object? value) {
  if (value is List) {
    return value;
  }
  if (value is Map &&
      (value.containsKey('Error Message') || value.containsKey('error'))) {
    throw const UnknownRemoteException();
  }
  throw InvalidMarketDataException('Expected a JSON array.');
}

String requireText(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  throw InvalidMarketDataException('Missing or invalid field: $field.');
}

String requireFirstText(Map<String, dynamic> json, List<String> fields) {
  for (final field in fields) {
    final value = json[field];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  throw InvalidMarketDataException(
      'Missing or invalid field: ${fields.first}.');
}

String? optionalText(Map<String, dynamic> json, String field) {
  if (!json.containsKey(field) || json[field] == null) {
    return null;
  }
  final value = json[field];
  if (value is! String) {
    throw InvalidMarketDataException('Invalid field: $field.');
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

double? _tryDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

double requireDouble(
  Object? value,
  String field, {
  bool allowNegative = false,
}) {
  final parsed = _tryDouble(value);
  if (parsed == null || parsed.isNaN || parsed.isInfinite) {
    throw InvalidMarketDataException('Missing or invalid field: $field.');
  }
  if (!allowNegative && parsed < 0) {
    throw InvalidMarketDataException('Invalid field: $field.');
  }
  return parsed;
}

double requireFirstDouble(
  Map<String, dynamic> json,
  List<String> fields, {
  bool allowNegative = false,
}) {
  for (final field in fields) {
    if (!json.containsKey(field) || json[field] == null) {
      continue;
    }
    return requireDouble(json[field], field, allowNegative: allowNegative);
  }
  throw InvalidMarketDataException(
      'Missing or invalid field: ${fields.first}.');
}

double? optionalDouble(
  Map<String, dynamic> json,
  String field, {
  bool allowNegative = false,
}) {
  if (!json.containsKey(field) || json[field] == null) {
    return null;
  }
  return requireDouble(json[field], field, allowNegative: allowNegative);
}

int requireWholeNumber(Object? value, String field) {
  if (value is int) {
    if (value < 0) {
      throw InvalidMarketDataException('Invalid field: $field.');
    }
    return value;
  }
  if (value is double) {
    if (value.isNaN ||
        value.isInfinite ||
        value < 0 ||
        value != value.roundToDouble()) {
      throw InvalidMarketDataException('Invalid field: $field.');
    }
    return value.toInt();
  }
  if (value is String) {
    final trimmed = value.trim();
    final asInt = int.tryParse(trimmed);
    if (asInt != null) {
      if (asInt < 0) {
        throw InvalidMarketDataException('Invalid field: $field.');
      }
      return asInt;
    }
    final asDouble = double.tryParse(trimmed);
    if (asDouble != null &&
        !asDouble.isNaN &&
        !asDouble.isInfinite &&
        asDouble >= 0 &&
        asDouble == asDouble.roundToDouble()) {
      return asDouble.toInt();
    }
  }
  throw InvalidMarketDataException('Missing or invalid field: $field.');
}

DateTime requireCalendarDate(Object? value, String field) {
  if (value is! String) {
    throw InvalidMarketDataException('Invalid date for $field.');
  }
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value.trim());
  if (match == null) {
    throw InvalidMarketDataException('Invalid date for $field.');
  }
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    throw InvalidMarketDataException('Invalid date for $field.');
  }
  return date;
}

DateTime requireQuoteTimestamp(Map<String, dynamic> json) {
  if (json.containsKey('timestamp') && json['timestamp'] != null) {
    final seconds = requireWholeNumber(json['timestamp'], 'timestamp');
    if (seconds <= 0) {
      throw InvalidMarketDataException('Invalid field: timestamp.');
    }
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }
  if (json.containsKey('date') && json['date'] != null) {
    return requireCalendarDate(json['date'], 'date');
  }
  throw InvalidMarketDataException('Missing field: timestamp.');
}
