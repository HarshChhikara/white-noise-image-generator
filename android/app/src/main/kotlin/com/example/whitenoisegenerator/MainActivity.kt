package com.example.whitenoisegenerator

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "custom.download.channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "saveImage") {
                    try {
                        val bytes = call.argument<ByteArray>("bytes")
                        val filename = call.argument<String>("filename")

                        val resolver = applicationContext.contentResolver
                        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI

                        val values = ContentValues().apply {
                            put(MediaStore.Downloads.DISPLAY_NAME, filename)
                            put(MediaStore.Downloads.MIME_TYPE, "image/png")
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                put(MediaStore.Downloads.RELATIVE_PATH, "Download/")
                                put(MediaStore.Downloads.IS_PENDING, 1)
                            }
                        }

                        val uri = resolver.insert(collection, values)
                        val stream = resolver.openOutputStream(uri!!)
                        stream!!.write(bytes)
                        stream.close()

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            values.clear()
                            values.put(MediaStore.Downloads.IS_PENDING, 0)
                            resolver.update(uri, values, null, null)
                        }

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
