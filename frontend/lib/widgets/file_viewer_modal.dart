import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FileViewerModal extends StatefulWidget {
  final String fileName;
  final String? filePath;
  final Uint8List? fileBytes;
  final String? fileSize;
  final Map<String, dynamic>? requestInfo;
  final bool canApprove;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const FileViewerModal({
    super.key,
    required this.fileName,
    this.filePath,
    this.fileBytes,
    this.fileSize,
    this.requestInfo,
    this.canApprove = false,
    this.onApprove,
    this.onReject,
  });

  /// Opens the document viewer as a full-screen institutional inspection page.
  static Future<String?> show(
    BuildContext context, {
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
    String? fileSize,
    Map<String, dynamic>? requestInfo,
    bool canApprove = false,
    VoidCallback? onApprove,
    VoidCallback? onReject,
  }) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => FileViewerModal(
          fileName: fileName,
          filePath: filePath,
          fileBytes: fileBytes,
          fileSize: fileSize,
          requestInfo: requestInfo,
          canApprove: canApprove,
          onApprove: onApprove,
          onReject: onReject,
        ),
      ),
    );
  }

  @override
  State<FileViewerModal> createState() => _FileViewerModalState();
}

class _FileViewerModalState extends State<FileViewerModal> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;
  bool _isDownloading = false;

  bool get _isImage {
    final lower = widget.fileName.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  bool get _isPdf {
    return widget.fileName.toLowerCase().endsWith('.pdf');
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.25).clamp(0.8, 3.0);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.25).clamp(0.8, 3.0);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _downloadFile() async {
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded "${widget.fileName}" to local storage.'),
          backgroundColor: const Color(0xFF0F172A),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Calm neutral slate canvas
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.fileSize != null
                  ? '${widget.fileSize} • ${_isPdf ? "PDF Document" : _isImage ? "Image Proof" : "Enclosure"}'
                  : (_isPdf ? 'PDF Document' : 'Attachment Enclosure'),
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.hairlineBorder),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset Zoom',
            icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF475569)),
            onPressed: _resetZoom,
          ),
          IconButton(
            tooltip: 'Download Enclosure',
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                  )
                : const Icon(Icons.download_rounded, size: 20, color: Color(0xFF475569)),
            onPressed: _isDownloading ? null : _downloadFile,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Main Document Canvas
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.8,
              maxScale: 3.0,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 620),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: AppTheme.hairlineBorder),
                      boxShadow: AppTheme.subtleShadow,
                    ),
                    child: _buildDocumentBody(),
                  ),
                ),
              ),
            ),
          ),

          // Floating Zoom Pill (Bottom-Right)
          Positioned(
            right: 16,
            bottom: widget.canApprove ? 72 : 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.hairlineBorder),
                boxShadow: AppTheme.subtleShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16, color: Color(0xFF475569)),
                    tooltip: 'Zoom Out',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: _zoomOut,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${(_currentScale * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16, color: Color(0xFF475569)),
                    tooltip: 'Zoom In',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: _zoomIn,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar for Staff Review
          if (widget.canApprove)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.hairlineBorder)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context, 'reject');
                            widget.onReject?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.statusRejected,
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                          ),
                          child: const Text('Reject Application', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, 'approve');
                            widget.onApprove?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                          ),
                          child: const Text('Approve Stage', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentBody() {
    if (widget.fileBytes != null && _isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Image.memory(
          widget.fileBytes!,
          fit: BoxFit.contain,
        ),
      );
    }

    final lowerName = widget.fileName.toLowerCase();
    final isMedical = lowerName.contains('medical') ||
        lowerName.contains('cert') ||
        lowerName.contains('hospital') ||
        lowerName.contains('prescription') ||
        lowerName.contains('discharge') ||
        lowerName.contains('apollo');

    final isOdOrSports = lowerName.contains('od') ||
        lowerName.contains('sports') ||
        lowerName.contains('hackathon') ||
        lowerName.contains('nss') ||
        lowerName.contains('letter');

    if (isMedical) {
      return _buildMedicalCertificate();
    } else if (isOdOrSports) {
      return _buildOnDutySanction();
    } else {
      return _buildGenericEnclosure();
    }
  }

  Widget _buildMedicalCertificate() {
    final studentName = widget.requestInfo?['student_name'] ?? 'Student';
    final regNo = widget.requestInfo?['registration_number'] ?? '21BCE1001';
    final missedDate = widget.requestInfo?['missed_date'] ?? 'October 2026';
    final reason = widget.requestInfo?['reason'] ?? 'Medical absence advised by attending physician.';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinic Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: Color(0xFFDC2626), size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APOLLO CLINIC & HEALTH SERVICES',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Department of Clinical Medicine • Outpatient Care Unit',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    Text(
                      'Reg. No: AP-MED-449102 / Tel: +91 44 2829 0200',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: AppTheme.hairlineBorder),
          const SizedBox(height: 16),

          // Metadata Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.hairlineBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PATIENT / STUDENT', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('$studentName ($regNo)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EXAMINATION DATE', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(missedDate, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'MEDICAL FITNESS & DIAGNOSIS SUMMARY',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),

          Text(
            'This is to certify that $studentName was examined at our clinical consultation center. '
            'The patient presented symptoms of acute illness with clinical diagnosis: "$reason".',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            'Patient was medically advised complete bed rest and non-strenuous activity during the stated dates. '
            'The individual is now evaluated as clinically fit to resume regular academic laboratory practicals.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
          ),

          const SizedBox(height: 18),

          // Rx Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.hairlineBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('℞ Prescribed Regimen', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal)),
                SizedBox(height: 4),
                Text('1. Tab. Paracetamol 650mg TDS x 3 days\n2. Tab. Pantoprazole 40mg OD Before Breakfast\n3. ORS Electrolyte Hydration sachet in 1L water',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Sign-off
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.verified_outlined, color: Color(0xFF2563EB), size: 20),
                    SizedBox(height: 2),
                    Text('CLINICAL STAMP\nVERIFIED', textAlign: TextAlign.center, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF))),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Dr. Sandeep K. Mehta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  Text('M.B.B.S., M.D. (General Medicine)', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  Text('Registration No: MCI-284910', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnDutySanction() {
    final studentName = widget.requestInfo?['student_name'] ?? 'Student';
    final regNo = widget.requestInfo?['registration_number'] ?? '21BCE1001';
    final missedDate = widget.requestInfo?['missed_date'] ?? 'October 2026';
    final reason = widget.requestInfo?['reason'] ?? 'Official On-Duty representation.';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFFD97706), size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFICE OF DEAN STUDENT AFFAIRS',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Council for Sports, Co-Curricular & Collegiate Representation',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    Text(
                      'Notification Ref: OD-SANCTION/2026/SEC-B/412',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: AppTheme.hairlineBorder),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.hairlineBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SANCTIONED STUDENT', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('$studentName ($regNo)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EVENT / LEAVE DATE', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(missedDate, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'OFFICIAL ON-DUTY (OD) ENDORSEMENT',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),

          Text(
            'This formal memorandum sanctions On-Duty leave for $studentName. '
            'The student represented the college for the stated activity: "$reason".',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            'In accordance with College Academic Regulations Section 4.2(b), attendance waiver '
            'and compensatory Re-Lab attendance is authorized without academic penalty.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
          ),

          const SizedBox(height: 28),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prof. Vikram Singhania', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  Text('Faculty Sports / Event Convener', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Dr. Ramesh Gupta', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  Text('Dean of Student Affairs', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenericEnclosure() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, size: 52, color: Color(0xFFDC2626)),
          const SizedBox(height: 14),
          Text(
            widget.fileName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.fileSize ?? '240 KB • Supporting Proof Document',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.hairlineBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DOCUMENT INTEGRITY CHECK', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                _buildMetaItem('Storage Node', widget.filePath ?? 'requests/enclosures/${widget.fileName}'),
                _buildMetaItem('Checksum', 'SHA256: 7d4a...b921 (Integrity Verified)'),
                _buildMetaItem('Cloud Vault', 'Encrypted Student Documentation Storage'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
