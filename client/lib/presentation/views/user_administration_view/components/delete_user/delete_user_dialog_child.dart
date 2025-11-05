part of '../../user_administration_view.dart';

class DeleteUserDialogChild extends StatelessWidget {
  final bool isUserDeletingSelf;
  final Future<void> Function() onCancel;
  final VoidCallback onConfirm;

  const DeleteUserDialogChild({
    super.key,
    required this.isUserDeletingSelf,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final title = isUserDeletingSelf
        ? 'Delete Your Account'
        : 'Delete User Account';
    final label = isUserDeletingSelf
        ? 'Are you sure you want to delete your own account?'
        : 'Are you sure you want to delete this user?';
    return ConfirmDialog(
      title: title,
      label: label,
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}
