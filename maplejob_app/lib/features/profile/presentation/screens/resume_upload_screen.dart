import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../app/config/theme.dart';
import '../providers/profile_provider.dart';
import '../../../../app/services/analytics_service.dart';

class ResumeUploadScreen extends ConsumerStatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  ConsumerState<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends ConsumerState<ResumeUploadScreen> {
  PlatformFile? _pickedFile;
  Uint8List? _fileBytes;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // retrieves file bytes immediately (ideal for web/small files)
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null) {
          // Fallback for native platform file systems if bytes are null
          final ioFile = io.File(file.path!);
          bytes = await ioFile.readAsBytes();
        }

        if (bytes != null) {
          setState(() {
            _pickedFile = file;
            _fileBytes = bytes;
          });
        } else {
          setState(() {
            _errorMessage = 'Could not read file bytes.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _uploadResume() async {
    if (_pickedFile == null || _fileBytes == null) {
      setState(() {
        _errorMessage = 'Please select a PDF file first.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(profileNotifierProvider.notifier).uploadAndSetResume(
            _pickedFile!.name,
            _fileBytes!,
          );
      await AnalyticsService().logResumeUploaded(_pickedFile!.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume uploaded and profile updated successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileNotifierProvider).value;
    final hasExistingResume = profile?.resumeUrl?.isNotEmpty == true;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Resume Attachment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 4,
              shadowColor: const Color.fromRGBO(0, 0, 0, 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.outlineVariantColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Attach Resume',
                      style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Supported formats: PDF only (Max 5MB)',
                      style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32.0),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 20.0),
                        decoration: BoxDecoration(
                          color: AppTheme.rejectedBg,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(_errorMessage!, style: AppTheme.bodyMd.copyWith(color: AppTheme.rejectedText)),
                      ),
                    ],

                    // Current Resume Display (if any)
                    if (hasExistingResume && _pickedFile == null) ...[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.outlineVariantColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: AppTheme.rejectedText, size: 36),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile!.resumeName ?? 'Resume.pdf',
                                    style: AppTheme.bodyMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Currently Active Resume',
                                    style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],

                    // File Pick Target Box
                    InkWell(
                      onTap: _isUploading ? null : _pickFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _pickedFile != null ? AppTheme.secondaryColor : AppTheme.outlineVariantColor,
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _pickedFile != null ? Icons.file_present : Icons.cloud_upload_outlined,
                              size: 48,
                              color: _pickedFile != null ? AppTheme.secondaryColor : AppTheme.outlineColor,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              _pickedFile != null ? _pickedFile!.name : 'Click to Browse Files',
                              style: AppTheme.bodyLg.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_pickedFile != null) ...[
                              const SizedBox(height: 4.0),
                              Text(
                                '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                                style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // Actions
                    ElevatedButton(
                      onPressed: _isUploading || _pickedFile == null ? null : _uploadResume,
                      child: _isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(hasExistingResume ? 'Replace Resume File' : 'Upload Resume File'),
                    ),
                    const SizedBox(height: 12.0),
                    OutlinedButton(
                      onPressed: _isUploading ? null : () => context.pop(),
                      child: const Text('Cancel'),
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
}
