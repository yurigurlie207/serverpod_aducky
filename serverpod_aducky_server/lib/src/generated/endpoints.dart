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
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_aducky_server/src/generated/calendar_event.dart'
    as _iv795s94;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/ai_endpoint.dart' as _igsjf4zh;
import '../endpoints/calendar_endpoint.dart' as _inx4l1vp;
import '../endpoints/contact_endpoint.dart' as _iioqm6zp;
import '../endpoints/google_idp_endpoint.dart' as _iiimk4ot;
import '../endpoints/notification_endpoint.dart' as _ihb11yhk;
import '../endpoints/places_endpoint.dart' as _id40adi8;
import '../endpoints/profile_endpoint.dart' as _i2cx2pww;
import '../endpoints/share_endpoint.dart' as _ir7ph2j5;
import '../endpoints/travel_endpoint.dart' as _ivmv8akq;
import '../greetings/greeting_endpoint.dart' as _il624ik7;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'ai': _igsjf4zh.AiEndpoint()
        ..initialize(
          server,
          'ai',
          null,
        ),
      'calendar': _inx4l1vp.CalendarEndpoint()
        ..initialize(
          server,
          'calendar',
          null,
        ),
      'contact': _iioqm6zp.ContactEndpoint()
        ..initialize(
          server,
          'contact',
          null,
        ),
      'googleIdp': _iiimk4ot.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'notification': _ihb11yhk.NotificationEndpoint()
        ..initialize(
          server,
          'notification',
          null,
        ),
      'places': _id40adi8.PlacesEndpoint()
        ..initialize(
          server,
          'places',
          null,
        ),
      'profile': _i2cx2pww.ProfileEndpoint()
        ..initialize(
          server,
          'profile',
          null,
        ),
      'share': _ir7ph2j5.ShareEndpoint()
        ..initialize(
          server,
          'share',
          null,
        ),
      'travel': _ivmv8akq.TravelEndpoint()
        ..initialize(
          server,
          'travel',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['ai'] = _is.EndpointConnector(
      name: 'ai',
      endpoint: endpoints['ai']!,
      methodConnectors: {
        'editScheduleWithClaude': _is.MethodConnector(
          name: 'editScheduleWithClaude',
          params: {
            'prompt': _is.ParameterDescription(
              name: 'prompt',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'currentEvents': _is.ParameterDescription(
              name: 'currentEvents',
              type: _is.getType<List<_iv795s94.CalendarEvent>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ai'] as _igsjf4zh.AiEndpoint)
                  .editScheduleWithClaude(
                    session,
                    prompt: params['prompt'],
                    currentEvents: params['currentEvents'],
                  ),
        ),
      },
    );
    connectors['calendar'] = _is.EndpointConnector(
      name: 'calendar',
      endpoint: endpoints['calendar']!,
      methodConnectors: {
        'getUpcomingEvents': _is.MethodConnector(
          name: 'getUpcomingEvents',
          params: {
            'start': _is.ParameterDescription(
              name: 'start',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'end': _is.ParameterDescription(
              name: 'end',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .getUpcomingEvents(
                    session,
                    start: params['start'],
                    end: params['end'],
                  ),
        ),
        'updateEvent': _is.MethodConnector(
          name: 'updateEvent',
          params: {
            'event': _is.ParameterDescription(
              name: 'event',
              type: _is.getType<_iv795s94.CalendarEvent>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .updateEvent(
                    session,
                    params['event'],
                  ),
        ),
        'deleteEvent': _is.MethodConnector(
          name: 'deleteEvent',
          params: {
            'event': _is.ParameterDescription(
              name: 'event',
              type: _is.getType<_iv795s94.CalendarEvent>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .deleteEvent(
                    session,
                    params['event'],
                  ),
        ),
      },
    );
    connectors['contact'] = _is.EndpointConnector(
      name: 'contact',
      endpoint: endpoints['contact']!,
      methodConnectors: {
        'sendContactMessage': _is.MethodConnector(
          name: 'sendContactMessage',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'message': _is.ParameterDescription(
              name: 'message',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'honeypot': _is.ParameterDescription(
              name: 'honeypot',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'humanAnswer': _is.ParameterDescription(
              name: 'humanAnswer',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'expectedAnswer': _is.ParameterDescription(
              name: 'expectedAnswer',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'durationSeconds': _is.ParameterDescription(
              name: 'durationSeconds',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['contact'] as _iioqm6zp.ContactEndpoint)
                  .sendContactMessage(
                    session,
                    name: params['name'],
                    email: params['email'],
                    message: params['message'],
                    honeypot: params['honeypot'],
                    humanAnswer: params['humanAnswer'],
                    expectedAnswer: params['expectedAnswer'],
                    durationSeconds: params['durationSeconds'],
                  ),
        ),
      },
    );
    connectors['googleIdp'] = _is.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'idToken': _is.ParameterDescription(
              name: 'idToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'accessToken': _is.ParameterDescription(
              name: 'accessToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['googleIdp'] as _iiimk4ot.GoogleIdpEndpoint).login(
                    session,
                    idToken: params['idToken'],
                    accessToken: params['accessToken'],
                  ),
        ),
        'loginWithCode': _is.MethodConnector(
          name: 'loginWithCode',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'codeVerifier': _is.ParameterDescription(
              name: 'codeVerifier',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'redirectUri': _is.ParameterDescription(
              name: 'redirectUri',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _iiimk4ot.GoogleIdpEndpoint)
                  .loginWithCode(
                    session,
                    code: params['code'],
                    codeVerifier: params['codeVerifier'],
                    redirectUri: params['redirectUri'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _iiimk4ot.GoogleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['notification'] = _is.EndpointConnector(
      name: 'notification',
      endpoint: endpoints['notification']!,
      methodConnectors: {
        'isTwilioConfigured': _is.MethodConnector(
          name: 'isTwilioConfigured',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['notification'] as _ihb11yhk.NotificationEndpoint)
                      .isTwilioConfigured(session),
        ),
        'sendSms': _is.MethodConnector(
          name: 'sendSms',
          params: {
            'toPhoneNumber': _is.ParameterDescription(
              name: 'toPhoneNumber',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'message': _is.ParameterDescription(
              name: 'message',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['notification'] as _ihb11yhk.NotificationEndpoint)
                      .sendSms(
                        session,
                        toPhoneNumber: params['toPhoneNumber'],
                        message: params['message'],
                      ),
        ),
        'sendDepartureAlert': _is.MethodConnector(
          name: 'sendDepartureAlert',
          params: {
            'toPhoneNumber': _is.ParameterDescription(
              name: 'toPhoneNumber',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'eventTitle': _is.ParameterDescription(
              name: 'eventTitle',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'minutesBeforeDeparture': _is.ParameterDescription(
              name: 'minutesBeforeDeparture',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'leaveByTime': _is.ParameterDescription(
              name: 'leaveByTime',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'eventStartTime': _is.ParameterDescription(
              name: 'eventStartTime',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['notification'] as _ihb11yhk.NotificationEndpoint)
                      .sendDepartureAlert(
                        session,
                        toPhoneNumber: params['toPhoneNumber'],
                        eventTitle: params['eventTitle'],
                        minutesBeforeDeparture:
                            params['minutesBeforeDeparture'],
                        leaveByTime: params['leaveByTime'],
                        eventStartTime: params['eventStartTime'],
                      ),
        ),
        'sendTestSms': _is.MethodConnector(
          name: 'sendTestSms',
          params: {
            'toPhoneNumber': _is.ParameterDescription(
              name: 'toPhoneNumber',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['notification'] as _ihb11yhk.NotificationEndpoint)
                      .sendTestSms(
                        session,
                        toPhoneNumber: params['toPhoneNumber'],
                      ),
        ),
      },
    );
    connectors['places'] = _is.EndpointConnector(
      name: 'places',
      endpoint: endpoints['places']!,
      methodConnectors: {
        'getSuggestions': _is.MethodConnector(
          name: 'getSuggestions',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['places'] as _id40adi8.PlacesEndpoint)
                  .getSuggestions(
                    session,
                    params['query'],
                  ),
        ),
        'getPlaceDetails': _is.MethodConnector(
          name: 'getPlaceDetails',
          params: {
            'placeId': _is.ParameterDescription(
              name: 'placeId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['places'] as _id40adi8.PlacesEndpoint)
                  .getPlaceDetails(
                    session,
                    params['placeId'],
                  ),
        ),
      },
    );
    connectors['profile'] = _is.EndpointConnector(
      name: 'profile',
      endpoint: endpoints['profile']!,
      methodConnectors: {
        'getProfile': _is.MethodConnector(
          name: 'getProfile',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i2cx2pww.ProfileEndpoint)
                  .getProfile(session),
        ),
        'saveProfile': _is.MethodConnector(
          name: 'saveProfile',
          params: {
            'homeAddress': _is.ParameterDescription(
              name: 'homeAddress',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'homeLat': _is.ParameterDescription(
              name: 'homeLat',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'homeLng': _is.ParameterDescription(
              name: 'homeLng',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'meetingBufferMinutes': _is.ParameterDescription(
              name: 'meetingBufferMinutes',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i2cx2pww.ProfileEndpoint)
                  .saveProfile(
                    session,
                    homeAddress: params['homeAddress'],
                    homeLat: params['homeLat'],
                    homeLng: params['homeLng'],
                    meetingBufferMinutes: params['meetingBufferMinutes'],
                  ),
        ),
      },
    );
    connectors['share'] = _is.EndpointConnector(
      name: 'share',
      endpoint: endpoints['share']!,
      methodConnectors: {
        'createShareLink': _is.MethodConnector(
          name: 'createShareLink',
          params: {
            'title': _is.ParameterDescription(
              name: 'title',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'startTime': _is.ParameterDescription(
              name: 'startTime',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'endTime': _is.ParameterDescription(
              name: 'endTime',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'location': _is.ParameterDescription(
              name: 'location',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'startLocation': _is.ParameterDescription(
              name: 'startLocation',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'transportMode': _is.ParameterDescription(
              name: 'transportMode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'travelMinutes': _is.ParameterDescription(
              name: 'travelMinutes',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'bufferMinutes': _is.ParameterDescription(
              name: 'bufferMinutes',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'personName': _is.ParameterDescription(
              name: 'personName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['share'] as _ir7ph2j5.ShareEndpoint)
                  .createShareLink(
                    session,
                    title: params['title'],
                    startTime: params['startTime'],
                    endTime: params['endTime'],
                    location: params['location'],
                    startLocation: params['startLocation'],
                    transportMode: params['transportMode'],
                    travelMinutes: params['travelMinutes'],
                    bufferMinutes: params['bufferMinutes'],
                    personName: params['personName'],
                  ),
        ),
        'getSharedEvent': _is.MethodConnector(
          name: 'getSharedEvent',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['share'] as _ir7ph2j5.ShareEndpoint)
                  .getSharedEvent(
                    session,
                    params['token'],
                  ),
        ),
        'sendShareLink': _is.MethodConnector(
          name: 'sendShareLink',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'phoneNumber': _is.ParameterDescription(
              name: 'phoneNumber',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'shareUrl': _is.ParameterDescription(
              name: 'shareUrl',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['share'] as _ir7ph2j5.ShareEndpoint).sendShareLink(
                    session,
                    token: params['token'],
                    phoneNumber: params['phoneNumber'],
                    email: params['email'],
                    shareUrl: params['shareUrl'],
                  ),
        ),
      },
    );
    connectors['travel'] = _is.EndpointConnector(
      name: 'travel',
      endpoint: endpoints['travel']!,
      methodConnectors: {
        'getTravelTime': _is.MethodConnector(
          name: 'getTravelTime',
          params: {
            'origin': _is.ParameterDescription(
              name: 'origin',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'destination': _is.ParameterDescription(
              name: 'destination',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'mode': _is.ParameterDescription(
              name: 'mode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['travel'] as _ivmv8akq.TravelEndpoint)
                  .getTravelTime(
                    session,
                    origin: params['origin'],
                    destination: params['destination'],
                    mode: params['mode'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
