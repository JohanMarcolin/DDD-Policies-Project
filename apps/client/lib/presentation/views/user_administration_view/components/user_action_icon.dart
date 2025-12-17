part of '../user_administration_view.dart';

/// A utility class for creating user action icons with different authorization states.
///
/// Provides methods to create icons for authorized and unauthorized user actions.
class UserActionIcon {
  /// Creates an icon for an authorized user action.
  ///
  /// - [icon]: The icon to display.
  /// - [dialogChildBuilder]: A builder for the dialog content.
  /// - [closeDialogOnEvent]: A function to determine if the dialog should close on a specific event.
  /// - [eventMessageMapper]: Maps events to messages for display.
  static Widget authorized({
    required IconData icon,
    required DialogChildBuilder dialogChildBuilder,
    required bool Function(UserAdministrationViewEvent event)? closeDialogOnEvent,
    required EventMessageMapper<UserAdministrationViewEvent> eventMessageMapper,
  }) {
    return _AuthorizedUserActionIcon(
      icon: icon,
      dialogChildBuilder: dialogChildBuilder,
      closeDialogOnEvent: closeDialogOnEvent,
      eventMessageMapper: eventMessageMapper,
    );
  }

  /// Creates an icon for an unauthorized user action.
  ///
  /// - [icon]: The icon to display.
  /// - [unauthorizedReason]: The reason the action is unauthorized.
  /// - [unauthorizedMessageMapper]: Maps the unauthorized reason to a message for display.
  static Widget unauthorized<TActionUnauthorizedReason>({
    required IconData icon,
    required TActionUnauthorizedReason unauthorizedReason,
    required UnauthorizedMessageMapper<TActionUnauthorizedReason> unauthorizedMessageMapper,
  }) {
    return _UnauthorizedUserActionIcon<TActionUnauthorizedReason>(
      icon: icon,
      unauthorizedReason: unauthorizedReason,
      unauthorizedMessageMapper: unauthorizedMessageMapper,
    );
  }
}

typedef EventMessageMapper<TEvent> = String Function(TEvent event);

typedef UnauthorizedMessageMapper<TReason> = String Function(TReason reason);

typedef DialogChildBuilder =
    Widget Function(BuildContext context, {required Future<void> Function(BuildContext context) closeDialog});

typedef OnConfirmCallback = void Function(BuildContext context, String value);

/// A widget representing an icon for an authorized user action.
class _AuthorizedUserActionIcon<TActionUnauthorizedReason> extends StatelessWidget {
  /// Creates an [_AuthorizedUserActionIcon].
  ///
  /// - [icon]: The icon to display.
  /// - [dialogChildBuilder]: A builder for the dialog content.
  /// - [closeDialogOnEvent]: A function to determine if the dialog should close on a specific event.
  /// - [eventMessageMapper]: Maps events to messages for display.
  const _AuthorizedUserActionIcon({
    super.key,
    required this.icon,
    required this.dialogChildBuilder,
    required this.closeDialogOnEvent,
    required this.eventMessageMapper,
  });

  final IconData icon;
  final DialogChildBuilder dialogChildBuilder;
  final bool Function(UserAdministrationViewEvent event)? closeDialogOnEvent;
  final EventMessageMapper<UserAdministrationViewEvent> eventMessageMapper;

  @override
  Widget build(BuildContext context) {
    return ActionIcon(icon: icon, isGreyedOut: false, onPressed: () => _showDialog(context));
  }

  void _showDialog(BuildContext context) {
    ActionDialogHelper.show(
      context: context,
      child: BlocProvider.value(
        value: context.read<UserAdministrationViewBloc>(),
        child: BlocPresentationListener<UserAdministrationViewBloc, UserAdministrationViewEvent>(
          listener: (_, event) async {
            _showAuthorizedActionSnackBar(context, event);
            if (closeDialogOnEvent?.call(event) == true) {
              await ActionDialogHelper.close(context);
            }
          },
          child: dialogChildBuilder(context, closeDialog: (_) async => await ActionDialogHelper.close(context)),
        ),
      ),
    );
  }

  Future<void> _showAuthorizedActionSnackBar(BuildContext context, UserAdministrationViewEvent event) async {
    final message = eventMessageMapper(event);
    if (message.isNotEmpty) {
      ActionSnackBarHelper.show(message: message);
    }
  }
}

/// A widget representing an icon for an unauthorized user action.
class _UnauthorizedUserActionIcon<TActionUnauthorizedReason> extends StatelessWidget {
  /// Creates an [_UnauthorizedUserActionIcon].
  ///
  /// - [icon]: The icon to display.
  /// - [unauthorizedReason]: The reason the action is unauthorized.
  /// - [unauthorizedMessageMapper]: Maps the unauthorized reason to a message for display.
  const _UnauthorizedUserActionIcon({
    super.key,
    required this.icon,
    required this.unauthorizedReason,
    required this.unauthorizedMessageMapper,
  });

  final IconData icon;
  final TActionUnauthorizedReason? unauthorizedReason;
  final UnauthorizedMessageMapper<TActionUnauthorizedReason> unauthorizedMessageMapper;

  @override
  Widget build(BuildContext context) {
    return ActionIcon(icon: icon, isGreyedOut: true, onPressed: () => _showUnauthorizedReasonSnackBar(context));
  }

  Future<void> _showUnauthorizedReasonSnackBar(BuildContext context) async {
    if (unauthorizedReason == null) return;
    final message = unauthorizedMessageMapper(unauthorizedReason as TActionUnauthorizedReason);
    if (message.isNotEmpty) {
      ActionSnackBarHelper.show(message: message);
    }
  }
}
