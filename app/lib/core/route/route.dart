import 'package:ovo_meet/view/components/bottom-nav-bar/presistent_bottom_navbar.dart';
import 'package:ovo_meet/view/components/preview_image.dart';
import 'package:ovo_meet/view/screens/Profile/profile_screen.dart';
import 'package:ovo_meet/view/screens/about/about_screen.dart';
import 'package:ovo_meet/view/screens/account/change-password/change_password_screen.dart';
import 'package:ovo_meet/view/screens/audio_call/audio_call_screen.dart';
import 'package:ovo_meet/view/screens/auth/add_profile_details/add_profile_details.dart';
import 'package:ovo_meet/view/screens/auth/email_verification_page/email_verification_screen.dart';
import 'package:ovo_meet/view/screens/auth/enter_email/enter_email_screen.dart';
import 'package:ovo_meet/view/screens/auth/enter_email/enter_registration_email.dart';
import 'package:ovo_meet/view/screens/auth/enter_phone_number/enter_phone_number_screen.dart';
import 'package:ovo_meet/view/screens/auth/enter_phone_number/signup_with_phone_screen.dart';
import 'package:ovo_meet/view/screens/auth/ideal_match/ideal_match_screen.dart';
import 'package:ovo_meet/view/screens/auth/login/login_screen.dart';
import 'package:ovo_meet/view/screens/auth/profile_complete/profile_complete_screen.dart';
import 'package:ovo_meet/view/screens/auth/registration/registration_screen.dart';
import 'package:ovo_meet/view/screens/auth/select_gender/select_gender_screen.dart';
import 'package:ovo_meet/view/screens/auth/select_interest/select_interest_screen.dart';
import 'package:ovo_meet/view/screens/auth/sms_verification_page/sms_verification_screen.dart';
import 'package:ovo_meet/view/screens/auth/verification_code/verification_code_screen.dart';
import 'package:ovo_meet/view/screens/chat/chat_screen.dart';
import 'package:ovo_meet/view/screens/components_preview/components_preview_screen.dart';
import 'package:ovo_meet/view/screens/edit_profile/edit_profile_screen.dart';
import 'package:ovo_meet/view/screens/homescreen/home_screen.dart';
import 'package:ovo_meet/view/screens/language/language_screen.dart';
import 'package:ovo_meet/view/screens/message_list/messages_list_screen.dart';
import 'package:ovo_meet/view/screens/events/my_events_screen.dart';
import 'package:ovo_meet/view/screens/notification/notification_screen.dart';
import 'package:ovo_meet/view/screens/onboard/onboar_screen.dart';
import 'package:ovo_meet/view/screens/partner_profile/partner_profile_screen.dart';
import 'package:ovo_meet/view/screens/privacy_policy/privacy_policy_screen.dart';
import 'package:ovo_meet/view/screens/search_connection/search_connection_screen.dart';
import 'package:ovo_meet/view/screens/splash/splash_screen.dart';
import 'package:ovo_meet/view/screens/terms_and_conditions/terms_and_conditions.dart';
import 'package:get/get.dart';
import '../../view/screens/auth/two_factor/two_factor_setup_screen/two_factor_setup_screen.dart';
import '../../view/screens/auth/two_factor/two_factor_verification_screen/two_factor_verification_screen.dart';
import '../../view/screens/events/widget/create_event_form.dart';
import '../../view/screens/events/widget/edit_event_form.dart';
import '../../view/screens/events/event_details_screen.dart';

class RouteHelper {
  //use screen in screen name and route name
  static const String componentPreviewScreen = "/component_preview_screen";
  static const String splashScreen = "/splash_screen";
  static const String onboardScreen = "/onboard_screen";
  static const String loginScreen = "/login_screen";
  static const String changePasswordScreen = "/change_password_screen";
  static const String registrationScreen = "/registration_screen";
  static const String bottomNavBar = "/bottom_nav_bar";
  static const String profileCompleteScreen = "/profile_complete_screen";
  static const String emailVerificationScreen = "/verify_email_screen";
  static const String smsVerificationScreen = "/verify_sms_screen";
  static const String twoFactorScreen = "/two-factor-screen";
  static const String notificationScreen = "/notification_screen";
  static const String profileScreen = "/profile_screen";
  static const String editProfileScreen = "/edit_profile_screen";
  static const String privacyScreen = "/privacy-screen";
  static const String languageScreen = "/languages_screen";
  static const String twoFactorSetupScreen = "/two-factor-setup-screen";
  static const String previewImageScreen = "/preview-image-screen";
  static const String notification = "/notifications-screen";
  static const String enterPhNumberScreen = "/enter-phone-numeber-screen";
  static const String verificationCodeScreen = "/verification-code-screen";
  static const String addProfileDetailsScreen = "/add-profile-details-screen";
  static const String selectGenderScreen = "/select-gender-screen";
  static const String selectIntersetScreen = "/select-interest-screen";
  static const String idealMatchScreen = "/ideal-match-screen";
  static const String homeScreen = "/home-screen";
  static const String searchConnectionScreen = "/search-connection-screen";
  static const String partnersProfileScreen = "/partner-profile-screen";
  static const String myEventsScreen = "/my-events-screen";
  static const String messageListScreen = "/message-list-screen";
  static const String chatScreen = "/chat-screen";
  static const String audioCallScreen = "/audio-call-screen";
  static const String termsAndConditionsScreen = "/terms-and-conditions-screen";
  static const String aboutScreen = "/about-screen";
  static const String enterEmailScreen = "/enter-email-screen";
  static const String registrationwithEmailScreen = "/register-email-screen";
  static const String registrationwithPhoneScreen = "/register-phone-screen";
  static const String createEventForm = "/create-event-form";
  static const String editEventForm = "/edit-event-form";
  static const String eventDetailsScreen = "/event-details-screen";

  List<GetPage> routes = [
    GetPage(
        name: componentPreviewScreen,
        page: () => const ComponentPreviewScreen()),
    GetPage(name: onboardScreen, page: () => const OnboardScreen()),
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(
        name: changePasswordScreen, page: () => const ChangePasswordScreen()),
    GetPage(name: registrationScreen, page: () => const RegistrationScreen()),
    GetPage(
        name: profileCompleteScreen, page: () => const ProfileCompleteScreen()),
    GetPage(name: bottomNavBar, page: () => const BottomNavbarScreen()),
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
    GetPage(
        name: registrationwithEmailScreen,
        page: () => const EnterRegistrationEmailScreen()),
    GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
    GetPage(
        name: emailVerificationScreen,
        page: () => const EmailVerificationScreen()),
    GetPage(
        name: smsVerificationScreen, page: () => const SmsVerificationScreen()),
    GetPage(
        name: twoFactorScreen, page: () => const TwoFactorVerificationScreen()),
    GetPage(name: privacyScreen, page: () => const PrivacyPolicyScreen()),
    GetPage(
        name: twoFactorSetupScreen, page: () => const TwoFactorSetupScreen()),
    GetPage(name: languageScreen, page: () => const LanguageScreen()),
    GetPage(
        name: previewImageScreen, page: () => PreviewImage(url: Get.arguments)),
    GetPage(name: notificationScreen, page: () => const NotificationScreen()),
    GetPage(
        name: enterPhNumberScreen, page: () => const EnterPhoneNumberScreen()),
    GetPage(
        name: registrationwithPhoneScreen,
        page: () => const EnterPhoneNumberRegistrationScreen()),
    GetPage(
        name: verificationCodeScreen,
        page: () => const VerificationCodeScreen()),
    GetPage(
        name: addProfileDetailsScreen,
        page: () => const AddProfileDetailsScreen()),
    GetPage(name: selectGenderScreen, page: () => const SelectGenderScreen()),
    GetPage(
        name: selectIntersetScreen, page: () => const SelectInterstScreen()),
    GetPage(name: idealMatchScreen, page: () => const IdealMatchScreen()),
    GetPage(name: homeScreen, page: () => const HomeScreen()),
    GetPage(
        name: searchConnectionScreen,
        page: () => const SearchConnectionScreen()),
    GetPage(
        name: partnersProfileScreen, page: () => const PartnersProfileScreen()),
    GetPage(name: myEventsScreen, page: () => const MyEventsScreen()),
    GetPage(name: messageListScreen, page: () => const MessageListScreen()),
    GetPage(name: chatScreen, page: () => const ChatScreen()),
    GetPage(name: audioCallScreen, page: () => const AudioCallScreen()),
    GetPage(
        name: termsAndConditionsScreen, page: () => const TermsAndConditions()),
    GetPage(name: aboutScreen, page: () => const AboutScreen()),
    GetPage(name: enterEmailScreen, page: () => const EnterEmailScreen()),
    GetPage(name: createEventForm, page: () => const CreateEventForm()),
    GetPage(
        name: editEventForm,
        page: () => EditEventForm(eventData: Get.arguments ?? {})),
    GetPage(name: eventDetailsScreen, page: () => const EventDetailsScreen()),
  ];
}
