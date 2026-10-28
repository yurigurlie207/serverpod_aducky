/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_aducky_client/src/protocol/ai_schedule_response.dart'
    as _i9bq4xv2;
import 'package:serverpod_aducky_client/src/protocol/calendar_event.dart'
    as _i9n0perj;
import 'package:serverpod_aducky_client/src/protocol/greetings/greeting.dart'
    as _inw1nql6;
import 'package:serverpod_aducky_client/src/protocol/location_details.dart'
    as _i0k6jrsp;
import 'package:serverpod_aducky_client/src/protocol/place_suggestion.dart'
    as _irll6ro1;
import 'package:serverpod_aducky_client/src/protocol/shared_event.dart'
    as _i7kts2jy;
import 'package:serverpod_aducky_client/src/protocol/travel_result.dart'
    as _itz10shf;
import 'package:serverpod_aducky_client/src/protocol/user_location_profile.dart'
    as _idzwj8zy;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointAi extends _isc.EndpointRef {
  EndpointAi(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'ai';

  /// Process natural language instructions using Claude (Anthropic API)
  /// to edit, shift, add, or reschedule events for the day.
  _ida.Future<_i9bq4xv2.AiScheduleResponse> editScheduleWithClaude({
    required String prompt,
    required List<_i9n0perj.CalendarEvent> currentEvents,
  }) => caller.callServerEndpoint<_i9bq4xv2.AiScheduleResponse>(
    'ai',
    'editScheduleWithClaude',
    {
      'prompt': prompt,
      'currentEvents': currentEvents,
    },
  );
}

/// {@category Endpoint}
class EndpointCalendar extends _isc.EndpointRef {
  EndpointCalendar(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'calendar';

  _ida.Future<List<_i9n0perj.CalendarEvent>> getUpcomingEvents({
    DateTime? start,
    DateTime? end,
  }) => caller.callServerEndpoint<List<_i9n0perj.CalendarEvent>>(
    'calendar',
    'getUpcomingEvents',
    {
      'start': start,
      'end': end,
    },
  );

  _ida.Future<bool> updateEvent(_i9n0perj.CalendarEvent event) =>
      caller.callServerEndpoint<bool>(
        'calendar',
        'updateEvent',
        {'event': event},
      );

  _ida.Future<bool> deleteEvent(_i9n0perj.CalendarEvent event) =>
      caller.callServerEndpoint<bool>(
        'calendar',
        'deleteEvent',
        {'event': event},
      );
}

/// {@category Endpoint}
class EndpointContact extends _isc.EndpointRef {
  EndpointContact(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'contact';

  _ida.Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String message,
    required String honeypot,
    required int humanAnswer,
    required int expectedAnswer,
    required int durationSeconds,
  }) => caller.callServerEndpoint<bool>(
    'contact',
    'sendContactMessage',
    {
      'name': name,
      'email': email,
      'message': message,
      'honeypot': honeypot,
      'humanAnswer': humanAnswer,
      'expectedAnswer': expectedAnswer,
      'durationSeconds': durationSeconds,
    },
  );
}

/// {@category Endpoint}
class EndpointGoogleIdp extends _iaic.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'login',
    {
      'idToken': idToken,
      'accessToken': accessToken,
    },
  );

  /// Validates a Google authorization code from the web OAuth2 PKCE flow and
  /// either logs in the associated user or creates a new account.
  ///
  /// This is the web counterpart of [login], which accepts an ID token directly
  /// (used on native platforms via the `google_sign_in` package).
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> loginWithCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'loginWithCode',
    {
      'code': code,
      'codeVerifier': codeVerifier,
      'redirectUri': redirectUri,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointNotification extends _isc.EndpointRef {
  EndpointNotification(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'notification';

  /// Returns true if Twilio credentials are configured in passwords.yaml or env.
  _ida.Future<bool> isTwilioConfigured() => caller.callServerEndpoint<bool>(
    'notification',
    'isTwilioConfigured',
    {},
  );

  /// Sends an SMS notification message via Twilio REST API.
  _ida.Future<bool> sendSms({
    required String toPhoneNumber,
    required String message,
  }) => caller.callServerEndpoint<bool>(
    'notification',
    'sendSms',
    {
      'toPhoneNumber': toPhoneNumber,
      'message': message,
    },
  );

  /// Sends countdown departure alert SMS (at 30m, 20m, or 10m before departure).
  _ida.Future<bool> sendDepartureAlert({
    required String toPhoneNumber,
    required String eventTitle,
    required int minutesBeforeDeparture,
    required DateTime leaveByTime,
    required DateTime eventStartTime,
  }) => caller.callServerEndpoint<bool>(
    'notification',
    'sendDepartureAlert',
    {
      'toPhoneNumber': toPhoneNumber,
      'eventTitle': eventTitle,
      'minutesBeforeDeparture': minutesBeforeDeparture,
      'leaveByTime': leaveByTime,
      'eventStartTime': eventStartTime,
    },
  );

  /// Sends a test SMS verification message.
  _ida.Future<bool> sendTestSms({required String toPhoneNumber}) =>
      caller.callServerEndpoint<bool>(
        'notification',
        'sendTestSms',
        {'toPhoneNumber': toPhoneNumber},
      );
}

/// {@category Endpoint}
class EndpointPlaces extends _isc.EndpointRef {
  EndpointPlaces(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'places';

  _ida.Future<List<_irll6ro1.PlaceSuggestion>> getSuggestions(String query) =>
      caller.callServerEndpoint<List<_irll6ro1.PlaceSuggestion>>(
        'places',
        'getSuggestions',
        {'query': query},
      );

  _ida.Future<_i0k6jrsp.LocationDetails?> getPlaceDetails(String placeId) =>
      caller.callServerEndpoint<_i0k6jrsp.LocationDetails?>(
        'places',
        'getPlaceDetails',
        {'placeId': placeId},
      );
}

/// {@category Endpoint}
class EndpointProfile extends _isc.EndpointRef {
  EndpointProfile(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'profile';

  _ida.Future<_idzwj8zy.UserLocationProfile?> getProfile() =>
      caller.callServerEndpoint<_idzwj8zy.UserLocationProfile?>(
        'profile',
        'getProfile',
        {},
      );

  _ida.Future<_idzwj8zy.UserLocationProfile> saveProfile({
    required String homeAddress,
    required double homeLat,
    required double homeLng,
    int? meetingBufferMinutes,
  }) => caller.callServerEndpoint<_idzwj8zy.UserLocationProfile>(
    'profile',
    'saveProfile',
    {
      'homeAddress': homeAddress,
      'homeLat': homeLat,
      'homeLng': homeLng,
      'meetingBufferMinutes': meetingBufferMinutes,
    },
  );
}

/// {@category Endpoint}
class EndpointShare extends _isc.EndpointRef {
  EndpointShare(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'share';

  /// Creates a shareable live countdown link for an event.
  /// Works for both authenticated users and guests.
  _ida.Future<_i7kts2jy.SharedEvent> createShareLink({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? startLocation,
    String? transportMode,
    int? travelMinutes,
    int? bufferMinutes,
    String? personName,
  }) => caller.callServerEndpoint<_i7kts2jy.SharedEvent>(
    'share',
    'createShareLink',
    {
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'startLocation': startLocation,
      'transportMode': transportMode,
      'travelMinutes': travelMinutes,
      'bufferMinutes': bufferMinutes,
      'personName': personName,
    },
  );

  /// Fetches a shared event by its unique share token.
  /// Open to everyone without authentication.
  _ida.Future<_i7kts2jy.SharedEvent?> getSharedEvent(String token) =>
      caller.callServerEndpoint<_i7kts2jy.SharedEvent?>(
        'share',
        'getSharedEvent',
        {'token': token},
      );

  /// Sends the share link to a recipient either via SMS phone number or email.
  _ida.Future<bool> sendShareLink({
    required String token,
    String? phoneNumber,
    String? email,
    required String shareUrl,
  }) => caller.callServerEndpoint<bool>(
    'share',
    'sendShareLink',
    {
      'token': token,
      'phoneNumber': phoneNumber,
      'email': email,
      'shareUrl': shareUrl,
    },
  );
}

/// {@category Endpoint}
class EndpointTravel extends _isc.EndpointRef {
  EndpointTravel(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'travel';

  _ida.Future<_itz10shf.TravelResult> getTravelTime({
    required String origin,
    required String destination,
    required String mode,
  }) => caller.callServerEndpoint<_itz10shf.TravelResult>(
    'travel',
    'getTravelTime',
    {
      'origin': origin,
      'destination': destination,
      'mode': mode,
    },
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_inw1nql6.Greeting> hello(String name) =>
      caller.callServerEndpoint<_inw1nql6.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    ai = EndpointAi(this);
    calendar = EndpointCalendar(this);
    contact = EndpointContact(this);
    googleIdp = EndpointGoogleIdp(this);
    notification = EndpointNotification(this);
    places = EndpointPlaces(this);
    profile = EndpointProfile(this);
    share = EndpointShare(this);
    travel = EndpointTravel(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAi ai;

  late final EndpointCalendar calendar;

  late final EndpointContact contact;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointNotification notification;

  late final EndpointPlaces places;

  late final EndpointProfile profile;

  late final EndpointShare share;

  late final EndpointTravel travel;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'ai': ai,
    'calendar': calendar,
    'contact': contact,
    'googleIdp': googleIdp,
    'notification': notification,
    'places': places,
    'profile': profile,
    'share': share,
    'travel': travel,
    'greeting': greeting,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
