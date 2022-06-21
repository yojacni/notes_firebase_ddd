import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:notes_firebase_ddd/domain/auth/i_auth_facade.dart';
import 'package:notes_firebase_ddd/domain/auth/value_objects.dart';

import '../../../domain/auth/auth_failure.dart';
part 'sign_in_form_bloc.freezed.dart';

part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';

class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;

  SignInFormBloc(this._authFacade) : super(SignInFormState.initial()) {
    on<SignInFormEvent>(_onSignInFormEvent);
  }

  void _onSignInFormEvent(
      SignInFormEvent event, Emitter<SignInFormState> emit) {
    event.map(
      emailChanged: (e) async {
        emit(state.copyWith(
            emailAddress: EmailAddress(e.emailStr),
            authFailureOrSuccessOption: none()));
      },
      passwordChanged: (e) async {
        emit(state.copyWith(
            password: Password(e.passwordStr),
            authFailureOrSuccessOption: none()));
      },
      registerWithEmailAndPasswordPressed: (e) async {
        await _performActionOnAuthFacadeWithEmailAndPassword(
            emit: emit,
            forwardedCall: _authFacade.registerWithEmailAndPassword);
      },
      signInWithEmailAndPasswordPressed: (e) async {
        await _performActionOnAuthFacadeWithEmailAndPassword(
            emit: emit, forwardedCall: _authFacade.signInWithEmailAndPassword);
      },
      signInWithGooglePressed: (e) async {
        emit(state.copyWith(
            isSubmitting: true, authFailureOrSuccessOption: none()));
        final failureOrSuccess = await _authFacade.signInWithGoogle();
        emit(state.copyWith(
          isSubmitting: false,
          authFailureOrSuccessOption: some(failureOrSuccess),
        ));
      },
    );
  }

  Future<void> _performActionOnAuthFacadeWithEmailAndPassword(
      {required Emitter<SignInFormState> emit,
      required Future<Either<AuthFailure, Unit>> Function(
              {required EmailAddress emailAddress, required Password password})
          forwardedCall}) async {
    final isEmailValid = state.emailAddress.isValid();
    final isPasswordValid = state.password.isValid();
    Either<AuthFailure, Unit>? failureOrSuccess;

    if (isEmailValid && isPasswordValid) {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(),
      ));

      failureOrSuccess = await forwardedCall(
        emailAddress: state.emailAddress,
        password: state.password,
      );
    }

    emit(state.copyWith(
      isSubmitting: false,
      showErrorMessages: true,
      authFailureOrSuccessOption: optionOf(failureOrSuccess),
    ));
  }
}
