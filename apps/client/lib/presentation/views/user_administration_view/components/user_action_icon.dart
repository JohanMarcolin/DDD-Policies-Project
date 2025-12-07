part of '../user_administration_view.dart';

class UserActionIcon {
  static Widget authorized({
    required IconData icon,
    required DialogChildBuilder dialogChildBuilder,
    required bool Function(UserAdministrationViewEvent event)? closeDialogOnEvent,
    required EventMessageMapper<UserAdministrationViewEvent> eventMessageMapper,
  }) {
    return AuthorizedUserActionIcon(
      icon: icon,
      dialogChildBuilder: dialogChildBuilder,
      closeDialogOnEvent: closeDialogOnEvent,
      eventMessageMapper: eventMessageMapper,
    );
  }

  static Widget unauthorized<TActionUnauthorizedReason>({
    required IconData icon,
    required TActionUnauthorizedReason unauthorizedReason,
    required UnauthorizedMessageMapper<TActionUnauthorizedReason> unauthorizedMessageMapper,
  }) {
    return UnauthorizedUserActionIcon<TActionUnauthorizedReason>(
      icon: icon,
      unauthorizedReason: unauthorizedReason,
      unauthorizedMessageMapper: unauthorizedMessageMapper,
    );
  }
}

class UnauthorizedUserActionIcon<TActionUnauthorizedReason> extends StatelessWidget {
  const UnauthorizedUserActionIcon({
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

typedef EventMessageMapper<TEvent> = String Function(TEvent event);
typedef UnauthorizedMessageMapper<TReason> = String Function(TReason reason);
typedef DialogChildBuilder =
    Widget Function(BuildContext context, {required Future<void> Function(BuildContext context) closeDialog});
typedef OnConfirmCallback = void Function(BuildContext context, String value);

class AuthorizedUserActionIcon<TActionUnauthorizedReason> extends StatelessWidget {
  const AuthorizedUserActionIcon({
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
