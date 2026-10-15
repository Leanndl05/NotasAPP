import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;

  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    widget.authController.clearError();
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isRegisterMode) {
      await widget.authController.register(email, password);
    } else {
      await widget.authController.login(email, password);
    }
  }

  void _demoLogin() async {
    widget.authController.clearError();
    await widget.authController.signInAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.authController,
          builder: (context, _) {
            final isLoading = widget.authController.isLoading;
            final errorMessage = widget.authController.errorMessage;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon & App Name
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.sticky_note_2_rounded,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Notas App',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tus notas y listas sincronizadas en la nube',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card with Form
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Tab Switcher: Iniciar Sesión / Registrarse
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF20232B)
                                        : const Color(0xFFF0F1F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (_isRegisterMode) {
                                              setState(() {
                                                _isRegisterMode = false;
                                              });
                                              widget.authController.clearError();
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: !_isRegisterMode
                                                  ? theme.colorScheme.surface
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: !_isRegisterMode
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.05),
                                                        blurRadius: 4,
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              'Iniciar Sesión',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: !_isRegisterMode
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (!_isRegisterMode) {
                                              setState(() {
                                                _isRegisterMode = true;
                                              });
                                              widget.authController.clearError();
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: _isRegisterMode
                                                  ? theme.colorScheme.surface
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: _isRegisterMode
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.05),
                                                        blurRadius: 4,
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              'Registrarse',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: _isRegisterMode
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Error Banner
                                if (errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.red.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline,
                                            color: Colors.red, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            errorMessage,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Email Input
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    labelText: 'Correo Electrónico',
                                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    final val = value?.trim() ?? '';
                                    if (val.isEmpty) {
                                      return 'Por favor ingresa tu correo';
                                    }
                                    if (!val.contains('@') || !val.contains('.')) {
                                      return 'Ingresa un correo electrónico válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password Input
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'La contraseña debe tener al menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),

                                // Confirm Password (only on Register)
                                if (_isRegisterMode) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar Contraseña',
                                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                ],

                                const SizedBox(height: 24),

                                // Submit Button
                                FilledButton(
                                  onPressed: isLoading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isRegisterMode
                                              ? 'Crear Cuenta'
                                              : 'Iniciar Sesión',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Fast Guest / Offline Mode Option
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _demoLogin,
                        icon: const Icon(Icons.person_outline_rounded, size: 20),
                        label: const Text('Acceso rápido sin registro (Modo Demo)'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
