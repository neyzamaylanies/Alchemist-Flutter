// lib/screens/student/student_detail_page.dart
import 'package:flutter/material.dart';
import '../../models/ui/student.dart';
import '../../repositories/student_repository.dart';
import '../../utils/remote_helper.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_button.dart';

class StudentDetailPage extends StatefulWidget {
  final Student? student;
  const StudentDetailPage({super.key, required this.student});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  late ThemeData _theme;
  bool _isLoading = false;

  final _idController = TextEditingController();
  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _programController = TextEditingController();
  final _phoneController = TextEditingController();

  final StudentRepository _repository = StudentRepository(RemoteHelper.getDio());

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _idController.text = widget.student!.id;
      _nimController.text = widget.student!.nim;
      _nameController.text = widget.student!.name;
      _programController.text = widget.student!.studyProgram;
      _phoneController.text = widget.student!.phone ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.navyDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.student == null ? "Tambah Mahasiswa" : "Edit Mahasiswa",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.student == null) ...[
                Text("ID", style: _theme.textTheme.labelMedium),
                TextField(controller: _idController, decoration: const InputDecoration(hintText: "Contoh: STU001")),
                const SizedBox(height: 16),
              ],
              Text("NIM", style: _theme.textTheme.labelMedium),
              TextField(controller: _nimController, decoration: const InputDecoration(hintText: "Masukkan NIM")),
              const SizedBox(height: 16),
              Text("Nama", style: _theme.textTheme.labelMedium),
              TextField(controller: _nameController, decoration: const InputDecoration(hintText: "Nama lengkap")),
              const SizedBox(height: 16),
              Text("Program Studi", style: _theme.textTheme.labelMedium),
              TextField(controller: _programController, decoration: const InputDecoration(hintText: "Contoh: Teknik Informatika")),
              const SizedBox(height: 16),
              Text("Nomor HP (opsional)", style: _theme.textTheme.labelMedium),
              TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: "08xxxxxxxxxx")),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: LoadingButton(isLoading: _isLoading, onPressed: _onSaveClick, text: widget.student == null ? "Tambah" : "Simpan")),
              ]),
              if (widget.student != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: LoadingButton(isLoading: _isLoading, onPressed: _onDeleteClick, text: "Hapus", buttonColor: _theme.colorScheme.error)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onSaveClick() async {
    if (_nimController.text.isEmpty || _nameController.text.isEmpty || _programController.text.isEmpty) {
      _showMessage("NIM, nama, dan program studi wajib diisi!");
      return;
    }
    setState(() => _isLoading = true);
    var data = {
      "id": _idController.text,
      "nim": _nimController.text,
      "name": _nameController.text,
      "studyProgram": _programController.text,
      "phone": _phoneController.text.isNotEmpty ? _phoneController.text : null,
    };
    if (widget.student == null) {
      var result = await _repository.createStudent(data);
      setState(() => _isLoading = false);
      if (result.isSuccess && result.data != null) {
        if (!mounted) return;
        Navigator.pop(context, StudentCreatedResult(student: Student.fromRemote(result.data!)));
      } else {
        _showMessage(result.message);
      }
    } else {
      var result = await _repository.updateStudent(widget.student!.id, data);
      setState(() => _isLoading = false);
      if (result.isSuccess && result.data != null) {
        if (!mounted) return;
        Navigator.pop(context, StudentUpdatedResult(student: Student.fromRemote(result.data!)));
      } else {
        _showMessage(result.message);
      }
    }
  }

  void _onDeleteClick() async {
    setState(() => _isLoading = true);
    var result = await _repository.deleteStudent(widget.student!.id);
    setState(() => _isLoading = false);
    if (result.isSuccess) {
      if (!mounted) return;
      Navigator.pop(context, StudentDeletedResult(student: widget.student!));
    } else {
      _showMessage(result.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class StudentCreatedResult {
  final Student student;
  StudentCreatedResult({required this.student});
}

class StudentUpdatedResult {
  final Student student;
  StudentUpdatedResult({required this.student});
}

class StudentDeletedResult {
  final Student student;
  StudentDeletedResult({required this.student});
}