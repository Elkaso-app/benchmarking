import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// Simple, clean upload zone matching the 2.png design
class SimpleUploadZone extends StatefulWidget {
  final List<PlatformFile>? selectedFiles;
  final VoidCallback onSelectFiles;
  final VoidCallback onProcess;
  final bool isProcessing;

  const SimpleUploadZone({
    super.key,
    required this.selectedFiles,
    required this.onSelectFiles,
    required this.onProcess,
    required this.isProcessing,
  });

  @override
  State<SimpleUploadZone> createState() => _SimpleUploadZoneState();
}

class _SimpleUploadZoneState extends State<SimpleUploadZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final hasFiles = widget.selectedFiles != null && widget.selectedFiles!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Upload icon
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: GestureDetector(
              onTap: widget.isProcessing ? null : widget.onSelectFiles,
              child: Column(
                children: [
                  // Circular icon container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovering 
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF818CF8),
                      boxShadow: _isHovering ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ] : [],
                    ),
                    child: const Icon(
                      Icons.file_upload_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Main heading
                  Text(
                    hasFiles ? '${widget.selectedFiles!.length} File(s) Selected' : 'Drop Your Invoices Here',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtext
                  Text(
                    hasFiles 
                        ? 'Ready to process with AI' 
                        : 'AI will automatically extract and analyze your invoice data',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action button
                  if (!hasFiles)
                    ElevatedButton.icon(
                      onPressed: widget.isProcessing ? null : widget.onSelectFiles,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Select Files or Drop Here'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  
                  if (hasFiles)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: widget.isProcessing ? null : widget.onSelectFiles,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Change Files'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            side: const BorderSide(color: Color(0xFF6366F1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: widget.isProcessing ? null : widget.onProcess,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Process Invoices'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Footer info
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Supported: PDF, JPG, JPEG, PNG',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flash_on,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Process up to 10 invoices simultaneously',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Selected files list
          if (hasFiles) ...[
            const SizedBox(height: 32),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.selectedFiles!.length,
                itemBuilder: (context, index) {
                  final file = widget.selectedFiles![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            file.name.toLowerCase().endsWith('.pdf')
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: const Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(file.size / 1024).toStringAsFixed(1)} KB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}



