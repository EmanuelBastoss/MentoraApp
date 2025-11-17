import 'package:flutter/material.dart';
import 'package:mentoraapp/services/auth/auth_service.dart';
import 'package:mentoraapp/componentes/my_button.dart';
import 'package:mentoraapp/componentes/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();

  String _tipoUsuario = 'aluno'; // 'aluno' ou 'mentor'
  final List<String> _cursos = [
    'Ciência da Computação',
    'Engenharia de Software',
    'Sistemas de Informação',
    'Engenharia de Computação',
    'Análise e Desenvolvimento de Sistemas',
    'Outro',
  ];
  String? _cursoSelecionado;

  void _showTipoUsuarioBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Selecione seu perfil",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text("Aluno"),
                subtitle: const Text("Busco ajuda com dúvidas"),
                trailing: _tipoUsuario == 'aluno'
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _tipoUsuario = 'aluno';
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Mentor"),
                subtitle: const Text("Posso ajudar outros alunos"),
                trailing: _tipoUsuario == 'mentor'
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _tipoUsuario = 'mentor';
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void register(BuildContext context) async {
    final _auth = AuthService();

    if (_nomeController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Erro"),
          content: Text("Por favor, informe seu nome"),
        ),
      );
      return;
    }

    if (_pwController.text == _confirmPwController.text) {
      if (_cursoSelecionado == null) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("Erro"),
            content: Text("Por favor, selecione um curso"),
          ),
        );
        return;
      }

      if (_periodoController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("Erro"),
            content: Text("Por favor, informe o período"),
          ),
        );
        return;
      }

      try {
        await _auth.signUpWithEmailPassword(
          _nomeController.text.trim(),
          _emailController.text,
          _pwController.text,
          _cursoSelecionado!,
          _tipoUsuario,
          int.parse(_periodoController.text),
        );
        // Não precisa de Navigator.pop, o AuthGate redireciona automaticamente
      } catch (e) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(title: Text(e.toString())),
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Erro"),
          content: Text("Senhas não coincidem"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Crie sua conta",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextField(
                      hintText: "Nome completo",
                      obscureText: false,
                      controller: _nomeController,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      hintText: "Email",
                      obscureText: false,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      hintText: "Senha",
                      obscureText: true,
                      controller: _pwController,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      hintText: "Confirme a senha",
                      obscureText: true,
                      controller: _confirmPwController,
                    ),
                    const SizedBox(height: 16),
                    // Tipo de usuário - Botão para abrir bottom sheet
                    InkWell(
                      onTap: () => _showTipoUsuarioBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _tipoUsuario == 'aluno'
                                  ? Icons.school
                                  : Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tipo de perfil",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _tipoUsuario == 'aluno'
                                        ? "Aluno"
                                        : "Mentor",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown de curso
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      child: DropdownButton<String>(
                        hint: const Text("Selecione seu curso"),
                        value: _cursoSelecionado,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _cursos.map((String curso) {
                          return DropdownMenuItem<String>(
                            value: curso,
                            child: Text(curso),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _cursoSelecionado = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      hintText: "Período (ex: 1, 2, 3...)",
                      obscureText: false,
                      controller: _periodoController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    MyButton(text: "Registrar", onTap: () => register(context)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Já tem uma conta? ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Entre",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _pwController.dispose();
    _confirmPwController.dispose();
    _cursoController.dispose();
    _periodoController.dispose();
    super.dispose();
  }
}
