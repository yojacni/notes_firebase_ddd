import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dartz/dartz.dart';
import 'package:notes_firebase_ddd/domain/core/value_objects.dart';

import '../core/failures.dart';
import '../core/value_validators.dart' as validators;

@immutable
class EmailAddress extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  const EmailAddress._(this.value);

  factory EmailAddress(String input) {
    return EmailAddress._(validators.validateEmailAddress(input));
  }
}

@immutable
class Password extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  const Password._(this.value);

  factory Password(String input) {
    return Password._(validators.validatePassword(input));
  }
}
