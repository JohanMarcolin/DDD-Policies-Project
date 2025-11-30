part of '../../user_administration_view.dart';

class UpdateUserPasswordDialogChild extends StatelessWidget {
  const UpdateUserPasswordDialogChild({
    required this.isUserUpdatingSelf,
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  final bool isUserUpdatingSelf;
  final Future<void> Function() onCancel;
  final void Function(String value) onConfirm;

  @override
  Widget build(BuildContext context) {
    final title = isUserUpdatingSelf ? 'Update your password' : 'Update user password';

    return ConfirmInputDialog(
      title: title,
      label: 'New password',
      isTextObscured: true,
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}
