import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  // Cores do sistema EngeCore
  final Color corPrimaria = const Color.fromARGB(255, 213, 216, 28);
  final Color corSecundaria = const Color.fromARGB(255, 45, 45, 45);
  final Color corFundo = const Color.fromARGB(255, 18, 18, 18);
  final Color corTexto = Colors.white;
  final Color corCard = const Color.fromARGB(255, 28, 28, 30);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> _fazerCadastro() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Criação do usuário no Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passController.text.trim(),
            );

        // Atualiza o displayName (nome do usuário)
        await userCredential.user!.updateDisplayName(
          _nameController.text.trim(),
        );

        // Sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registro realizado com sucesso!"),
            backgroundColor: corPrimaria,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Redireciona para a tela de login
        Navigator.pop(context);

      } on FirebaseAuthException catch (e) {
        String mensagemErro = "Ocorreu um erro";
        if (e.code == 'email-already-in-use') {
          mensagemErro = "O e-mail já está em uso";
        } else if (e.code == 'weak-password') {
          mensagemErro = "Senha muito fraca";
        } else if (e.code == 'invalid-email') {
          mensagemErro = "E-mail inválido";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagemErro),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: corCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: corTexto,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Criar Conta",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: corTexto,
                          ),
                        ),
                      ),
                      SizedBox(width: 44),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 20),
                          
                          // Logo
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: corPrimaria,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: corPrimaria.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.engineering,
                                size: 40,
                                color: corFundo,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 32),
                          
                          Text(
                            "Junte-se ao EngeCore",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: corTexto,
                            ),
                          ),
                          
                          SizedBox(height: 8),
                          
                          Text(
                            "Gerencie seus projetos de construção",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: corTexto.withOpacity(0.7),
                            ),
                          ),
                          
                          SizedBox(height: 40),
                          
                          // Nome
                          Container(
                            decoration: BoxDecoration(
                              color: corCard,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              style: TextStyle(color: corTexto, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: "Nome Completo",
                                labelStyle: TextStyle(color: corPrimaria),
                                prefixIcon: Icon(Icons.person_outline, color: corPrimaria),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: corPrimaria, width: 2),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? "Digite o nome" : null,
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // E-mail
                          Container(
                            decoration: BoxDecoration(
                              color: corCard,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              style: TextStyle(color: corTexto, fontSize: 16),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "E-mail",
                                labelStyle: TextStyle(color: corPrimaria),
                                prefixIcon: Icon(Icons.email_outlined, color: corPrimaria),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: corPrimaria, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Digite o e-mail";
                                }
                                if (!value.contains("@")) {
                                  return "Digite um e-mail válido";
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Senha
                          Container(
                            decoration: BoxDecoration(
                              color: corCard,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passController,
                              obscureText: true,
                              style: TextStyle(color: corTexto, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: "Senha",
                                labelStyle: TextStyle(color: corPrimaria),
                                prefixIcon: Icon(Icons.lock_outline, color: corPrimaria),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: corPrimaria, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Digite a senha";
                                if (!_validatePassword(value)) {
                                  return "Senha deve ter no mínimo 8 caracteres,\n1 maiúscula, 1 minúscula, 1 número e 1 especial.";
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          SizedBox(height: 32),
                          
                          // Botão Cadastrar
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [corPrimaria, corPrimaria.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: corPrimaria.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(28),
                              child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: corFundo,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Criar Conta",
                                    style: TextStyle(
                                      color: corFundo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                              onPressed: _isLoading ? null : _fazerCadastro,
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Link para login
                          Center(
                            child: GestureDetector(
                              child: RichText(
                                text: TextSpan(
                                  text: "Já tem conta? ",
                                  style: TextStyle(
                                    color: corTexto.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Faça login",
                                      style: TextStyle(
                                        color: corPrimaria,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}