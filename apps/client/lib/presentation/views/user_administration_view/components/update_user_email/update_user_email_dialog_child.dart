part of '../../user_administration_view.dart';

class UpdateUserEmailDialogChild extends StatelessWidget {
  const UpdateUserEmailDialogChild({
    required this.isUserUpdatingSelf,
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  final bool isUserUpdatingSelf;
  final Future<void> Function() onCancel;
  final void Function(String) onConfirm;

  @override
  Widget build(BuildContext context) {
    final title = isUserUpdatingSelf ? 'Update your email' : 'Update user email';

    return ConfirmInputDialog(title: title, label: 'New email', onCancel: onCancel, onConfirm: onConfirm);
  }
}
