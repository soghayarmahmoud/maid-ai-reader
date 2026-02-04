import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';

/// Advanced PDF Editor Service
/// Handles all PDF editing operations
class PdfEditorService {
  /// Insert image into PDF
  Future<bool> insertImage({
    required String pdfPath,
    required String imagePath,
    required int pageNumber,
    required double x,
    required double y,
    double? width,
    double? height,
  }) async {
    try {
      // Load existing PDF
      final File pdfFile = File(pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      // Get page
      final PdfPage page = document.pages[pageNumber];

      // Load image
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final PdfBitmap image = PdfBitmap(imageBytes);

      // Draw image on page
      page.graphics.drawImage(
        image,
        Rect.fromLTWH(x, y, width ?? image.width.toDouble(), height ?? image.height.toDouble()),
      );

      // Save
      final List<int> bytes = await document.save();
      document.dispose();
      
      await File(pdfPath).writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error inserting image: $e');
      return false;
    }
  }

  /// Rotate PDF page
  Future<bool> rotatePage({
    required String pdfPath,
    required int pageNumber,
    required PdfPageRotateAngle angle,
  }) async {
    try {
      final File pdfFile = File(pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      document.pages[pageNumber].rotation = angle;

      final List<int> bytes = await document.save();
      document.dispose();
      
      await File(pdfPath).writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error rotating page: $e');
      return false;
    }
  }

  /// Delete PDF page
  Future<bool> deletePage({
    required String pdfPath,
    required int pageNumber,
  }) async {
    try {
      final File pdfFile = File(pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      document.pages.removeAt(pageNumber);

      final List<int> bytes = await document.save();
      document.dispose();
      
      await File(pdfPath).writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error deleting page: $e');
      return false;
    }
  }

  /// Reorder PDF pages
  Future<bool> reorderPages({
    required String pdfPath,
    required List<int> newOrder,
  }) async {
    try {
      final File pdfFile = File(pdfPath);
      final PdfDocument sourceDoc = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final PdfDocument newDoc = PdfDocument();

      // Add pages in new order
      for (int pageIndex in newOrder) {
        newDoc.pages.add().graphics.drawPdfTemplate(
          sourceDoc.pages[pageIndex].createTemplate(),
          const Offset(0, 0),
        );
      }

      final List<int> bytes = await newDoc.save();
      sourceDoc.dispose();
      newDoc.dispose();
      
      await File(pdfPath).writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error reordering pages: $e');
      return false;
    }
  }

  /// Merge multiple PDFs
  Future<String?> mergePdfs({
    required List<String> pdfPaths,
    required String outputPath,
  }) async {
    try {
      final PdfDocument mergedDocument = PdfDocument();

      for (String path in pdfPaths) {
        final File pdfFile = File(path);
        final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
        
        // Import all pages by copying them
        for (int i = 0; i < document.pages.count; i++) {
          mergedDocument.pages.add().graphics.drawPdfTemplate(
            document.pages[i].createTemplate(),
            const Offset(0, 0),
          );
        }
        document.dispose();
      }

      final List<int> bytes = await mergedDocument.save();
      mergedDocument.dispose();
      
      await File(outputPath).writeAsBytes(bytes);
      return outputPath;
    } catch (e) {
      print('Error merging PDFs: $e');
      return null;
    }
  }

  /// Split PDF into multiple files
  Future<List<String>> splitPdf({
    required String pdfPath,
    required String outputDir,
    required List<int> splitPoints, // Page numbers where to split
  }) async {
    try {
      final List<String> outputFiles = [];
      final File pdfFile = File(pdfPath);
      final PdfDocument sourceDoc = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      int startPage = 0;
      for (int i = 0; i < splitPoints.length; i++) {
        final PdfDocument splitDoc = PdfDocument();
        final int endPage = splitPoints[i];

        // Copy pages to new document
        for (int pageIndex = startPage; pageIndex <= endPage && pageIndex < sourceDoc.pages.count; pageIndex++) {
          splitDoc.pages.add().graphics.drawPdfTemplate(
            sourceDoc.pages[pageIndex].createTemplate(),
            const Offset(0, 0),
          );
        }

        // Save
        final String outputPath = '$outputDir/split_${i + 1}.pdf';
        final List<int> bytes = await splitDoc.save();
        await File(outputPath).writeAsBytes(bytes);
        outputFiles.add(outputPath);
        
        splitDoc.dispose();
        startPage = endPage + 1;
      }

      sourceDoc.dispose();
      return outputFiles;
    } catch (e) {
      print('Error splitting PDF: $e');
      return [];
    }
  }

  /// Add watermark to PDF
  Future<bool> addWatermark({
    required String pdfPath,
    required String watermarkText,
    double opacity = 0.3,
    double fontSize = 48,
    PdfColor? color,
  }) async {
    try {
      final File pdfFile = File(pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, fontSize);
      final watermarkColor = color ?? PdfColor(128, 128, 128);

      // Add watermark to all pages
      for (int i = 0; i < document.pages.count; i++) {
        final PdfPage page = document.pages[i];
        final Size pageSize = page.size;

        // Draw watermark diagonally
        final PdfGraphics graphics = page.graphics;
        final PdfGraphicsState state = graphics.save();
        
        graphics.setTransparency(opacity);
        graphics.translateTransform(pageSize.width / 2, pageSize.height / 2);
        graphics.rotateTransform(-45);
        
        graphics.drawString(
          watermarkText,
          font,
          brush: PdfSolidBrush(watermarkColor),
          bounds: Rect.fromLTWH(-200, -20, 400, 40),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
        );
        
        graphics.restore(state);
      }

      final List<int> bytes = await document.save();
      document.dispose();
      
      await File(pdfPath).writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error adding watermark: $e');
      return false;
    }
  }

  /// Fill PDF form field
  Future<bool> fillFormField({
    required String pdfPath,
    required String fieldName,
    required String value,
  }) async {
    try {
      final File pdfFile = File(pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      // Get form
      final PdfForm form = document.form;
      
      // Find and fill field
      for (int i = 0; i < form.fields.count; i++) {
        final PdfField field = form.fields[i];
        if (field.name == fieldName) {
          if (field is PdfTextBoxField) {
            field.text = value;
          } else if (field is PdfCheckBoxField) {
            field.isChecked = value.toLowerCase() == 'true';
          }
          break;
        }
      }

      final List<int> bytes = await document.save();
      document.dispose();
      
      await File(pdfPath).writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error filling form: $e');
      return false;
    }
  }

  /// Add signature to PDF
  Future<bool> addSignature({
    required String pdfPath,
    required String signatureImagePath,
    required int pageNumber,
    required Rect bounds,
  }) async {
    try {
      final File pdfFile = File(pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      // Load signature image
      final File signatureFile = File(signatureImagePath);
      final Uint8List signatureBytes = await signatureFile.readAsBytes();
      final PdfBitmap signatureImage = PdfBitmap(signatureBytes);

      // Draw signature on specified page
      final PdfPage page = document.pages[pageNumber];
      page.graphics.drawImage(signatureImage, bounds);

      final List<int> bytes = await document.save();
      document.dispose();
      
      await File(pdfPath).writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error adding signature: $e');
      return false;
    }
  }

  /// Crop PDF page
  Future<bool> cropPage({
    required String pdfPath,
    required int pageNumber,
    required Rect cropBox,
  }) async {
    try {
      final File pdfFile = File(pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      // Create new page with cropped size
      final PdfPage originalPage = document.pages[pageNumber];
      final PdfDocument croppedDoc = PdfDocument();
      final PdfPage newPage = croppedDoc.pages.add();      
      // Draw cropped portion
      newPage.graphics.drawPdfTemplate(
        originalPage.createTemplate(),
        Offset(-cropBox.left, -cropBox.top),
      );

      // Replace original page
      document.pages.removeAt(pageNumber);
      document.pages.insert(pageNumber, newPage as Size?);

      final List<int> bytes = await document.save();
      document.dispose();
      croppedDoc.dispose();
      
      await File(pdfPath).writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error cropping page: $e');
      return false;
    }
  }

  /// Export edited PDF
  Future<String?> exportPdf({
    required String sourcePath,
    required String destinationPath,
    bool flatten = false, // Flatten forms and annotations
  }) async {
    try {
      final File pdfFile = File(sourcePath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      if (flatten) {
        // Flatten form fields and annotations
        document.form.setDefaultAppearance(false);
        document.form.flattenAllFields();
      }

      final List<int> bytes = await document.save();
      document.dispose();
      
      await File(destinationPath).writeAsBytes(bytes);
      return destinationPath;
    } catch (e) {
      print('Error exporting PDF: $e');
      return null;
    }
  }

  /// Get PDF info
  Future<PdfInfo?> getPdfInfo(String pdfPath) async {
    try {
      final File pdfFile = File(pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());

      final info = PdfInfo(
        pageCount: document.pages.count,
        hasForm: document.form.fields.count > 0,
        fileSize: await pdfFile.length(),
        title: document.documentInformation.title,
        author: document.documentInformation.author,
      );

      document.dispose();
      return info;
    } catch (e) {
      print('Error getting PDF info: $e');
      return null;
    }
  }
}

class PdfInfo {
  final int pageCount;
  final bool hasForm;
  final int fileSize;
  final String title;
  final String author;

  PdfInfo({
    required this.pageCount,
    required this.hasForm,
    required this.fileSize,
    required this.title,
    required this.author,
  });
}
