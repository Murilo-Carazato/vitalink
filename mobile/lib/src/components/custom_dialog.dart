import 'package:flutter/material.dart';
import 'package:vitalink/styles.dart';

Future<bool?> showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
  VoidCallback? onConfirm,
  Color confirmButtonColor = Styles.primary,
  IconData? icon,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final theme = Theme.of(context);

      return AlertDialog(
        surfaceTintColor: Colors.transparent, // Remove purple tint
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: theme.cardColor,
        icon: icon != null
            ? Icon(icon, color: confirmButtonColor, size: 48)
            : null,
        title: Text(title,
            textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 10),
        actions: <Widget>[
          // Cancel button
          if (cancelText.isNotEmpty)
            SizedBox(
              width: 130,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Styles.gray1, // Fix purple text
                  side: BorderSide(color: theme.brightness == Brightness.dark ? Styles.darkBorder : Styles.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(cancelText),
              ),
            ),
          
          // Confirm button
          SizedBox(
            width: 130,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                if (onConfirm != null) {
                  onConfirm();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(confirmText),
            ),
          ),
        ],
      );
    },
  );
} 