import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/proof_of_delivery.dart';

class ProofCaptureScreen extends StatefulWidget {
  const ProofCaptureScreen({
    super.key,
    required this.assignmentId,
    required this.onProofCaptured,
  });

  final String assignmentId;
  final ValueChanged<ProofOfDelivery> onProofCaptured;

  @override
  State<ProofCaptureScreen> createState() => _ProofCaptureScreenState();
}

class _ProofCaptureScreenState extends State<ProofCaptureScreen> {
  final GlobalKey _signatureKey = GlobalKey();
  final List<Offset?> _points = [];
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture proof of delivery')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client confirmation signature',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 160,
                child: RepaintBoundary(
                  key: _signatureKey,
                  child: GestureDetector(
                    onPanStart: (details) => setState(() => _points.add(details.localPosition)),
                    onPanUpdate: (details) => setState(() => _points.add(details.localPosition)),
                    onPanEnd: (_) => setState(() => _points.add(null)),
                    child: CustomPaint(
                      painter: _SignaturePainter(points: _points),
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _points.clear()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear'),
                ),
                const Spacer(),
                Text(_hasSignature ? 'Signature captured' : 'Awaiting signature'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Optional delivery photo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Add photo'),
                  onPressed: _handlePickPhoto,
                ),
                const SizedBox(width: 12),
                if (_photo != null) Expanded(child: Text(_photo!.name, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes for support (optional)',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit proof'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePickPhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _photo = photo);
    }
  }

  Future<void> _submit() async {
    if (!_hasSignature) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture the client signature before submitting.')),
      );
      return;
    }
    setState(() => _submitting = true);
    final signatureBytes = await _exportSignature();
    final encodedSignature = base64Encode(signatureBytes);
    final proof = ProofOfDelivery(
      capturedAt: DateTime.now(),
      signatureImage: encodedSignature.isEmpty ? null : encodedSignature,
      photoPath: _photo?.path,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
    widget.onProofCaptured(proof);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  bool get _hasSignature => _points.any((point) => point != null);

  Future<Uint8List> _exportSignature() async {
    final boundary = _signatureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final image = await boundary!.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({required this.points});

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current != null && next != null) {
        canvas.drawLine(current, next, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
