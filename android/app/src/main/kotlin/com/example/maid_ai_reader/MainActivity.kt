package com.example.maid_ai_reader

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.maid/file_intent"
    private var sharedFilePath: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        when (intent?.action) {
            Intent.ACTION_VIEW -> {
                intent.data?.let { uri ->
                    sharedFilePath = resolveUri(uri)
                }
            }
            Intent.ACTION_SEND -> {
                if (intent.type == "application/pdf") {
                    (intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))?.let { uri ->
                        sharedFilePath = resolveUri(uri)
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedFile" -> {
                    result.success(sharedFilePath)
                    sharedFilePath = null // Clear after sending
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Resolves a URI to a file path that Flutter can read.
     * For content:// URIs, copies the file to app cache directory.
     * For file:// URIs, returns the path directly.
     */
    private fun resolveUri(uri: Uri): String {
        return when (uri.scheme) {
            "content" -> {
                try {
                    // Copy content URI to a temporary file in cache
                    val inputStream = contentResolver.openInputStream(uri)
                    if (inputStream != null) {
                        // Try to get a meaningful filename
                        val fileName = getFileNameFromUri(uri) ?: "shared_${System.currentTimeMillis()}.pdf"
                        val cacheDir = File(cacheDir, "shared_pdfs")
                        cacheDir.mkdirs()
                        val outputFile = File(cacheDir, fileName)
                        
                        FileOutputStream(outputFile).use { output ->
                            inputStream.copyTo(output)
                        }
                        inputStream.close()
                        
                        outputFile.absolutePath
                    } else {
                        ""
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    ""
                }
            }
            "file" -> uri.path ?: ""
            else -> ""
        }
    }

    /**
     * Attempts to extract a filename from a content URI.
     */
    private fun getFileNameFromUri(uri: Uri): String? {
        var name: String? = null
        val cursor = contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val nameIndex = it.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0) {
                    name = it.getString(nameIndex)
                }
            }
        }
        return name
    }
}
