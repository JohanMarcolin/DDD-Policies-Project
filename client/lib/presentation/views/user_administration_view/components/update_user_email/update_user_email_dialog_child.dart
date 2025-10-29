part of '../../user_administration_view.dart';

class UpdateUserEmailDialogChild extends StatelessWidget {
  const UpdateUserEmailDialogChild({
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  final Future<void> Function() onCancel;
  final void Function(String) onConfirm;

  @override
  Widget build(BuildContext context) {
    return ConfirmInputDialog(
      title: 'Update Email',
      label: 'New Email',
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}
