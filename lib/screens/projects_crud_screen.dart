import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';


const String IMGBB_API_KEY = 'c511d3bf4a60dff45fc07c210a6cb7ed'; 

class ProjectsCRUDScreen extends StatefulWidget {
  final String projectType;

  const ProjectsCRUDScreen({Key? key, required this.projectType}) : super(key: key);

  @override
  _ProjectsCRUDScreenState createState() => _ProjectsCRUDScreenState();
}

class _ProjectsCRUDScreenState extends State<ProjectsCRUDScreen> {
  final Color corPrimaria = const Color.fromARGB(255, 213, 216, 28);
  final Color corCard = Colors.white;
  final Color corTexto = Colors.black;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();
  
  DocumentSnapshot? _editingProject;
  
  XFile? _selectedXFile; 
  String? _currentImageUrl; 
  
  Uint8List? _webImageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _selectedXFile = pickedFile;
        _webImageBytes = null;
      });

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
      }
    }
  }

  Future<String?> _uploadImageToImgBB() async {
    if (_selectedXFile == null) return _currentImageUrl;

    final url = Uri.https('api.imgbb.com', '/1/upload', {
      'key': IMGBB_API_KEY,
    });

    try {
      final bytes = await _selectedXFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final request = http.MultipartRequest('POST', url);
      request.fields['image'] = base64Image;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['url'];
        } else {
          _showSnackBar('Falha no upload do ImgBB: ${data['error']['message']}', Colors.red.shade700);
          return null;
        }
      } else {
        _showSnackBar('Erro de servidor ImgBB: ${response.statusCode}', Colors.red.shade700);
        return null;
      }
    } catch (e) {
      _showSnackBar('Erro ao conectar com ImgBB: $e', Colors.red.shade700);
      return null;
    }
  }


  Stream<QuerySnapshot> _getProjectsStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.empty();
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('projects')
        .where('type', isEqualTo: widget.projectType)
        .snapshots();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("Usuário não autenticado.", Colors.red.shade700);
      return;
    }

    final String buttonText = _editingProject == null ? "criado" : "atualizado";
    String? finalImageUrl = _currentImageUrl;
    bool isNewImageSelected = _selectedXFile != null;

    if (isNewImageSelected) {
      _showSnackBar("Fazendo upload da imagem...", corPrimaria.withOpacity(0.5));
      finalImageUrl = await _uploadImageToImgBB();
      
      if (finalImageUrl == null) {
        return; 
      }
    }
    
    Map<String, dynamic> projectData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'address': _addressController.text.trim(),
      'budget': double.tryParse(_budgetController.text.replaceAll(',', '.').trim()) ?? 0.0,
      'type': widget.projectType,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': finalImageUrl, 
    };

    try {
      if (_editingProject == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('projects')
            .add(projectData);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('projects')
            .doc(_editingProject!.id)
            .update(projectData);
      }

      _showSnackBar("Projeto $buttonText com sucesso!", corPrimaria);
      _resetForm();
    } on FirebaseException catch (e) {
      _showSnackBar("Erro no Firebase: ${e.message}", Colors.red.shade700);
    } catch (e) {
      _showSnackBar("Ocorreu um erro: $e", Colors.red.shade700);
    }
  }

  void _loadProjectForEditing(DocumentSnapshot project) {
    setState(() {
      _editingProject = project;
      _nameController.text = project['name'] ?? '';
      _descriptionController.text = project['description'] ?? '';
      _addressController.text = project['address'] ?? '';
      _budgetController.text = (project['budget'] as num? ?? 0.0).toStringAsFixed(2);
      
      _currentImageUrl = project['imageUrl'];
      _selectedXFile = null;
      _webImageBytes = null;
    });
  }
  
  Future<void> _deleteProject(String projectId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (_editingProject != null && _editingProject!.id == projectId) {
        _resetForm();
      }
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('projects')
          .doc(projectId)
          .delete();
          
      _showSnackBar("Projeto excluído com sucesso!", Colors.red);
    } on FirebaseException catch (e) {
      _showSnackBar("Erro ao excluir projeto: ${e.message}", Colors.red.shade700);
    }
  }

  Future<void> _confirmDelete(DocumentSnapshot project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o projeto "${project['name'] ?? 'sem nome'}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      await _deleteProject(project.id);
    }
  }

  void _resetForm() {
    setState(() {
      _editingProject = null;
      _nameController.clear();
      _descriptionController.clear();
      _addressController.clear();
      _budgetController.clear();
      _selectedXFile = null;
      _currentImageUrl = null;
      _webImageBytes = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(color: corTexto),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: corPrimaria),
          prefixIcon: Icon(icon, color: corPrimaria),
          filled: true,
          fillColor: corCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: corPrimaria, width: 2),
          ),
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) return 'Campo obrigatório';
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    Widget imageSource;

    if (_selectedXFile != null) {
      if (!kIsWeb && _selectedXFile!.path.isNotEmpty) {
        imageSource = Image.file(File(_selectedXFile!.path), fit: BoxFit.cover);
      } 
      else if (kIsWeb && _webImageBytes != null) {
        imageSource = Image.memory(_webImageBytes!, fit: BoxFit.cover);
      } 
      else {
        imageSource = Icon(Icons.check_circle, color: Colors.green, size: 40);
      }
    } 
    else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      imageSource = Image.network(
        _currentImageUrl!, 
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      );
    } 
    else {
      imageSource = Icon(Icons.camera_alt, color: corPrimaria, size: 40);
    }
    
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: corCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: corPrimaria.withOpacity(0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageSource is Icon ? Center(child: imageSource) : imageSource as Widget,
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: corPrimaria.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedXFile != null ? 'Trocar Imagem' : (_currentImageUrl != null ? 'Mudar Imagem' : 'Adicionar Imagem'),
                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectImage(String? imageUrl) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: corCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: corPrimaria.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
              )
            : Icon(Icons.home_work_outlined, size: 24, color: corTexto.withOpacity(0.7)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 250),
      appBar: AppBar(
        title: Text('Projetos ${widget.projectType}'),
        backgroundColor: corPrimaria,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editingProject == null ? "Novo Projeto" : "Editar Projeto",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: corTexto,
              ),
            ),
            SizedBox(height: 20),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
            
                  _buildImagePicker(),
                  SizedBox(height: 16),

                  _buildTextField(_nameController, "Nome do Projeto", Icons.text_fields),
                  
                  _buildTextField(_descriptionController, "Descrição", Icons.notes,
                      keyboardType: TextInputType.multiline),
                  
                  _buildTextField(_addressController, "Endereço", Icons.location_on_outlined),
                  
                  _buildTextField(
                    _budgetController,
                    "Orçamento Estimado (R\$)",
                    Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo obrigatório';
                      if (double.tryParse(value.replaceAll(',', '.').trim()) == null) {
                        return 'Digite um valor numérico válido';
                      }
                      return null;
                    },
                  ),

                  ElevatedButton.icon(
                    onPressed: _saveProject,
                    icon: Icon(
                      _editingProject == null ? Icons.save : Icons.update,
                      color: Colors.black,
                    ),
                    label: Text(
                      _editingProject == null ? "Salvar Projeto" : "Atualizar Projeto",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corPrimaria,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  if (_editingProject != null)
                    TextButton(
                      onPressed: _resetForm,
                      child: Text("Cancelar Edição", style: TextStyle(color: corTexto)),
                    ),
                ],
              ),
            ),

            Divider(height: 40, thickness: 2),

            Text(
              "Lista de Projetos",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: corTexto,
              ),
            ),
            SizedBox(height: 10),
            
            StreamBuilder<QuerySnapshot>(
              stream: _getProjectsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: corPrimaria));
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erro ao carregar projetos: ${snapshot.error}", style: TextStyle(color: Colors.red)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "Nenhum projeto encontrado. Adicione um novo no formulário acima.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: corTexto.withOpacity(0.7)),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot project = snapshot.data!.docs[index];
                    String name = project['name'] ?? 'Projeto sem nome';
                    String budget = (project['budget'] as num? ?? 0.0).toStringAsFixed(2);
                    String? imageUrl = project['imageUrl'];
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      color: project.id == _editingProject?.id ? corPrimaria.withOpacity(0.3) : corCard, 
                      child: ListTile(
                        leading: _buildProjectImage(imageUrl),
                        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('R\$ $budget \nEndereço: ${project['address'] ?? ''}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _loadProjectForEditing(project),
                              tooltip: 'Carregar para Edição',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(project),
                              tooltip: 'Excluir Projeto',
                            ),
                          ],
                        ),
                        onTap: () => _loadProjectForEditing(project),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}