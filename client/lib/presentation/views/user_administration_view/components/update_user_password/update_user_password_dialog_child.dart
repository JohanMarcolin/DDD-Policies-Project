part of '../../user_administration_view.dart';

class UpdateUserPasswordDialogChild extends StatelessWidget {
  const UpdateUserPasswordDialogChild({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  final Future<void> Function() onCancel;
  final void Function(String value) onConfirm;

  @override
  Widget build(BuildContext context) {
    return ConfirmInputDialog(
      title: 'Update Password',
      label: 'New Password',
      isTextObscured: true,
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}
