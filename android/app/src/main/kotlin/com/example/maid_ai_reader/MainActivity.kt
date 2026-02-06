package com.example.maid_ai_reader

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

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
                // Handle "Open With" intent
                intent.data?.let { uri ->
                    sharedFilePath = getPathFromUri(uri)
                }
            }
            Intent.ACTION_SEND -> {
                // Handle "Share" intent
                if (intent.type == "application/pdf") {
                    (intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))?.let { uri ->
                        sharedFilePath = getPathFromUri(uri)
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

    private fun getPathFromUri(uri: Uri): String {
        return when (uri.scheme) {
            "content" -> uri.toString() // Return content URI as string
            "file" -> uri.path ?: ""
            else -> ""
        }
    }
}
