import 'package:flutter/material.dart';

class DonationSuccessDialog extends StatelessWidget {
  const DonationSuccessDialog({super.key, required int doadorid});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Seu livro foi doado com sucesso!"),
          const SizedBox(height: 16),
          Image.asset("assets/Ok.png", height: 64),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Voltar"),
          )
        ],
      ),
    );
  }
}
