part of '../user_administration_view.dart';

typedef EventMessageMapper<TEvent> = String Function(TEvent event);
typedef UnauthorizedMessageMapper<TReason> = String Function(TReason reason);
typedef DialogChildBuilder =
    Widget Function(
      BuildContext context, {
      required Future<void> Function(BuildContext context) closeDialog,
    });
typedef OnConfirmCallback = void Function(BuildContext context, String value);

class UserActionIcon<TActionSuccessEvent, TActionUnauthorizedReason>
    extends StatelessWidget {
  const UserActionIcon({
    super.key,
    required this.icon,
    required this.isActionAuthorized,
    required this.dialogChildBuilder,
    required this.eventMessageMapper,
    required this.unauthorizedReason,
    required this.unauthorizedMessageMapper,
  });

  final IconData icon;
  final bool isActionAuthorized;
  final DialogChildBuilder dialogChildBuilder;
  final EventMessageMapper<UserAdministrationViewEvent> eventMessageMapper;
  final TActionUnauthorizedReason? unauthorizedReason;
  final UnauthorizedMessageMapper<TActionUnauthorizedReason>
  unauthorizedMessageMapper;

  @override
  Widget build(BuildContext context) {
    return ActionIcon(
      icon: icon,
      isGreyedOut: !isActionAuthorized,
      onPressed: () {
        if (isActionAuthorized) {
          _showDialog(context);
        } else {
          _showUnauthorizedReasonSnackBar(context);
        }
      },
    );
  }

  void _showDialog(BuildContext context) {
    ActionDialogHelper.show(
      context: context,
      child: BlocProvider.value(
        value: context.read<UserAdministrationViewBloc>(),
        child:
            BlocPresentationListener<
              UserAdministrationViewBloc,
              UserAdministrationViewEvent
            >(
              listener: (_, event) async => _handleDialogEvent(context, event),
              child: dialogChildBuilder(
                context,
                closeDialog: (_) async =>
                    await ActionDialogHelper.close(context),
              ),
            ),
      ),
    );
  }

  Future<void> _handleDialogEvent(
    BuildContext context,
    UserAdministrationViewEvent event,
  ) async {
    if (event is TActionSuccessEvent) {
      await ActionDialogHelper.close(context);
    }

    final message = eventMessageMapper(event);
    if (message.isNotEmpty) {
      ActionSnackBarHelper.show(message: message);
    }
  }

  Future<void> _showUnauthorizedReasonSnackBar(BuildContext context) async {
    if (unauthorizedReason == null) return;
    final message = unauthorizedMessageMapper(
      unauthorizedReason as TActionUnauthorizedReason,
    );
    if (message.isNotEmpty) {
      ActionSnackBarHelper.show(message: message);
    }
  }
}
