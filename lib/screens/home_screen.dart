import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 1. Adicionar o import da nova tela
import 'projects_crud_screen.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Cores do sistema EngeCore
  final Color corPrimaria = const Color.fromARGB(255, 213, 216, 28);
  final Color corSecundaria = const Color.fromARGB(255, 45, 45, 45);
  final Color corFundo = const Color.fromARGB(255, 245, 245, 250);
  final Color corTexto = Colors.black;
  final Color corCard = Colors.white;
  final Color corTextoSecundario = const Color.fromARGB(255, 120, 120, 128);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _nomeUsuario = "Engenheiro";
  int _selectedIndex = 0;

  // Chave para controlar o Scaffold e abrir o Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _carregarDadosUsuario();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _carregarDadosUsuario() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nomeUsuario =
            user.displayName ?? user.email?.split('@')[0] ?? "Engenheiro";
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao fazer logout"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: corFundo,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: corPrimaria),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Configurações"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(), // Linha de separação
            // Login / Logout
            if (FirebaseAuth.instance.currentUser != null)
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Logout", style: TextStyle(color: corTexto)),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              )
            else
              ListTile(
                leading: Icon(Icons.login, color: corPrimaria),
                title: Text("Login", style: TextStyle(color: corTexto)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          children: [
                            // Botão do menu hambúrguer
                            GestureDetector(
                              onTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: corCard,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.menu,
                                  color: corTexto,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            // Saudação
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Olá $_nomeUsuario",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: corTextoSecundario,
                                    ),
                                  ),
                                  Text(
                                    "Bom trabalho",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: corTexto,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Botão de notificação
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: corCard,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: corTexto,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Barra de pesquisa
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: corCard,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: corTextoSecundario,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Buscar projetos",
                                      style: TextStyle(
                                        color: corTextoSecundario,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: corPrimaria,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: corPrimaria.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.tune,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      // Seção Popular
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Populares",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: corTexto,
                              ),
                            ),
                            Text(
                              "Ver todos",
                              style: TextStyle(
                                fontSize: 14,
                                color: corPrimaria,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Cards populares
                      Container(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            _buildPopularCard(
                              "Residencial",
                              Icons.home,
                              Colors.orange,
                            ),
                            _buildPopularCard(
                              "Comercial",
                              Icons.business,
                              Colors.blue,
                            ),
                            _buildPopularCard(
                              "Industrial",
                              Icons.factory,
                              Colors.green,
                            ),
                            _buildPopularCard(
                              "Infraestrutura",
                              Icons.engineering,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      // Seção Recomendados
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recomendados",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: corTexto,
                              ),
                            ),
                            Text(
                              "Ver todos",
                              style: TextStyle(
                                fontSize: 14,
                                color: corPrimaria,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Cards recomendados
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildRecommendedCard(
                              "Projeto Residencial Premium",
                              "15 km de distância",
                              Icons.home_work,
                              Colors.orange,
                            ),
                            SizedBox(height: 16),
                            _buildRecommendedCard(
                              "Centro Comercial ModernPlex",
                              "8 km de distância",
                              Icons.store,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: corCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, "Home", 0, _selectedIndex == 0),
              _buildBottomNavItem(
                Icons.favorite_border,
                "Favoritos",
                1,
                _selectedIndex == 1,
              ),
              _buildBottomNavItem(
                Icons.help_outline,
                "Ajuda",
                2,
                _selectedIndex == 2,
              ),
              _buildBottomNavItem(
                Icons.person_outline,
                "Perfil",
                3,
                _selectedIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularCard(String titulo, IconData icone, Color cor) {
    // 2. Envolve o card em um GestureDetector e adiciona a lógica de navegação.
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectsCRUDScreen(projectType: titulo),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cor.withOpacity(0.2)),
              ),
              child: Icon(icone, color: cor, size: 28),
            ),
            SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: corTexto,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(
    String titulo,
    String distancia,
    IconData icone,
    Color cor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: corCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cor.withOpacity(0.8), cor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icone,
                    size: 60,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: corTexto,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  distancia,
                  style: TextStyle(fontSize: 14, color: corTextoSecundario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icone,
    String label,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          _showProfileMenu(context);
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? corPrimaria.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              color: isSelected ? corPrimaria : corTextoSecundario,
              size: 20,
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: corPrimaria,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: corCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: corTextoSecundario.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: corPrimaria.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person, color: corPrimaria),
              ),
              title: Text("Meu Perfil", style: TextStyle(color: corTexto)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout, color: Colors.red),
              ),
              title: Text("Sair", style: TextStyle(color: corTexto)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}