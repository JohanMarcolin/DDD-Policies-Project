part of '../../user_administration_view.dart';

class DeleteUserDialogChild extends StatelessWidget {
  final Future<void> Function() onCancel;
  final VoidCallback onConfirm;

  const DeleteUserDialogChild({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Delete User',
      label: 'Are you sure you want to delete this user?',
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}
