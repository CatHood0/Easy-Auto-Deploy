import 'package:auto_deployment/src/presentation/deployment/common/decorated_text_field.dart';
import 'package:flutter/material.dart';

class CredentialsRequestDialog extends StatefulWidget {
  final void Function(String, String) onSubmit;
  final void Function() onCancel;
  final String? subtitle;
  final bool onlyToken;
  const CredentialsRequestDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    this.subtitle,
    this.onlyToken = false,
  });

  @override
  State<CredentialsRequestDialog> createState() =>
      _CredentialsRequestDialogState();
}

class _CredentialsRequestDialogState extends State<CredentialsRequestDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final FocusNode _userNode = FocusNode();
  final FocusNode _tokenNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _tokenController.dispose();
    _userNode.dispose();
    _tokenNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget tokenField = DecoratedTextField(
      controller: _tokenController,
      obscureText: true,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'El token/contraseña es obligatorio';
        }
        return null;
      },
      labelText: 'Token/Contraseña',
      icon: Icon(Icons.lock),
      onFieldSubmitted: (_) {
        if (_formKey.currentState!.validate()) {
          widget.onSubmit(
            _usernameController.text,
            _tokenController.text,
          );
          Navigator.of(context).pop(true);
        }
      },
    );
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 340,
          height: 270,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ingrese sus credenciales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle ??
                    'Ninguna contraseña o '
                        'usuario es guardado en '
                        'el almacenamiento',
                style: TextStyle(
                  fontSize: 11.3,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!widget.onlyToken)
                Form(
                  key: _formKey,
                  child: DecoratedTextField(
                    controller: _usernameController,
                    icon: Icon(Icons.person),
                    labelText: 'Usuario',
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(
                        _tokenNode,
                      );
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'El usuario es obligatorio';
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 16),
              if (!widget.onlyToken)
                tokenField
              else
                Form(
                  key: _formKey,
                  child: tokenField,
                ),
              const SizedBox(height: 17),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color?>(
                            Colors.red,
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                        onPressed: () {
                          widget.onCancel();
                          Navigator.of(context).pop(
                            false,
                          );
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color?>(
                            Colors.blue,
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.onSubmit(
                              _usernameController.text,
                              _tokenController.text,
                            );
                            Navigator.of(context).pop(true);
                          }
                        },
                        child: const Text(
                          'Subir',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
