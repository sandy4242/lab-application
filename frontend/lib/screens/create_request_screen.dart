import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/auth_provider.dart';
import '../services/mock_data_service.dart';
import '../widgets/file_viewer_modal.dart';
import 'package:intl/intl.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final MockDataService _dataService = MockDataService();

  String? _selectedSubjectLabId;
  DateTime? _selectedDate;
  final _reasonController = TextEditingController();

  late List<Map<String, dynamic>> _subjectLabs;
  bool _isSubmitting = false;

  // File Upload State
  PlatformFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _subjectLabs = _dataService.subjectLabs;
    if (_subjectLabs.isNotEmpty) {
      _selectedSubjectLabId = _subjectLabs[0]['id'];
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  void _previewCurrentFile() {
    if (_pickedFile == null) return;
    FileViewerModal.show(
      context,
      fileName: _pickedFile!.name,
      fileBytes: _pickedFile!.bytes,
      fileSize: _formatFileSize(_pickedFile!.size),
      requestInfo: {
        'student_name': 'My Application',
        'registration_number': 'Current Draft',
        'missed_date': _selectedDate != null ? DateFormat.yMMMd().format(_selectedDate!) : 'Scheduled Date',
        'reason': _reasonController.text.trim().isNotEmpty ? _reasonController.text.trim() : 'Medical / Academic Enclosure',
        'subject_name': _subjectLabs.firstWhere((s) => s['id'] == _selectedSubjectLabId, orElse: () => {})['subject_name'] ?? 'Re-Lab',
      },
    );
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the missed lab date.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.userId ?? 'user-student-1';
      final missedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      _dataService.createRequest(
        studentId: userId,
        subjectLabId: _selectedSubjectLabId ?? 'sub-dbms',
        missedDate: missedDateStr,
        reason: _reasonController.text.trim(),
        attachmentName: _pickedFile?.name,
        attachmentPath: _pickedFile?.name != null ? 'requests/$userId/${_pickedFile!.name}' : null,
        attachmentBytes: _pickedFile?.bytes,
        attachmentSize: _pickedFile != null ? _formatFileSize(_pickedFile!.size) : null,
        attachmentType: _pickedFile?.extension != null ? 'application/${_pickedFile!.extension}' : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Re-Lab Application Submitted Successfully! Sent to Teacher Guardian for review.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Re-Lab Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Application Guidelines',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Ensure your missed lab date is accurate.\n'
                            '• Requests require approval by Teacher Guardian, Lab Teacher, Re-Lab Teacher, and HOD.\n'
                            '• Upload valid proof (medical note/duty leave) to expedite approval.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Subject / Lab Dropdown
                  if (_subjectLabs.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSubjectLabId,
                      decoration: const InputDecoration(
                        labelText: 'Select Subject / Lab',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.science),
                      ),
                      items: _subjectLabs.map((lab) {
                        return DropdownMenuItem<String>(
                          value: lab['id'],
                          child: Text('${lab['subject_code']} - ${lab['subject_name']}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSubjectLabId = val;
                        });
                      },
                    ),
                  const SizedBox(height: 16),

                  // 2. Missed Date Picker
                  InkWell(
                    onTap: _presentDatePicker,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Missed Lab Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Tap to select missed lab date'
                            : DateFormat.yMMMd().format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null ? Colors.grey : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Reason TextField
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Missing Lab',
                      hintText: 'e.g., Medical illness with fever, participated in collegiate symposium...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please provide a clear reason';
                      }
                      if (val.trim().length < 10) {
                        return 'Please provide a detailed explanation (min 10 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. File Attachment Area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal.shade200),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.teal.shade50.withOpacity(0.3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.attach_file, color: Colors.teal),
                                SizedBox(width: 8),
                                Text(
                                  'Supporting Enclosure (Proof Document)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Recommended',
                                style: TextStyle(color: Colors.teal, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Upload medical certificate, hospital prescription, or OD duty letter to expedite approval.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 14),
                        if (_pickedFile != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.teal.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.teal.shade100),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _pickedFile!.name.toLowerCase().endsWith('.pdf')
                                          ? Icons.picture_as_pdf
                                          : _pickedFile!.name.toLowerCase().endsWith('.png') ||
                                                  _pickedFile!.name.toLowerCase().endsWith('.jpg') ||
                                                  _pickedFile!.name.toLowerCase().endsWith('.jpeg')
                                              ? Icons.image
                                              : Icons.description,
                                      color: Colors.teal,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _pickedFile!.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_formatFileSize(_pickedFile!.size)} • Ready to upload',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.teal, size: 20),
                                  tooltip: 'Preview File',
                                  onPressed: _previewCurrentFile,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                  tooltip: 'Remove',
                                  onPressed: () {
                                    setState(() {
                                      _pickedFile = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: Text(_pickedFile == null ? 'Browse / Pick File' : 'Change File'),
                              onPressed: _pickFile,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal,
                                side: const BorderSide(color: Colors.teal),
                              ),
                            ),
                            if (_pickedFile != null)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.preview, size: 18),
                                label: const Text('Preview Attachment'),
                                onPressed: _previewCurrentFile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'SUBMIT RE-LAB APPLICATION',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
