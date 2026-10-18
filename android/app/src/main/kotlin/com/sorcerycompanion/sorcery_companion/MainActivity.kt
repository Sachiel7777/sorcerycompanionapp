package com.sorcerycompanion.sorcery_companion

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.os.Handler
import android.os.Looper
import com.googlecode.tesseract.android.TessBaseAPI
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val worker = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sorcery_companion/ocr")
            .setMethodCallHandler { call, result ->
                val path = call.argument<String>("path")
                if (call.method != "recognize" || path == null) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                worker.execute {
                    try {
                        val lines = recognize(path)
                        mainHandler.post { result.success(lines) }
                    } catch (e: Exception) {
                        mainHandler.post { result.error("ocr_failed", e.message, null) }
                    }
                }
            }
    }

    /** Reads the text lines of the photo at [path] with Tesseract, entirely on the phone. */
    private fun recognize(path: String): List<Map<String, Any>> {
        val dataDir = File(filesDir, "tesseract")
        copyModel(File(dataDir, "tessdata/eng.traineddata"))

        val bitmap = upright(BitmapFactory.decodeFile(path) ?: throw IllegalStateException("Cannot read the photo"), path)
        val tess = TessBaseAPI()
        try {
            if (!tess.init(dataDir.absolutePath, "eng")) throw IllegalStateException("Cannot load the OCR model")
            // A card is a few separate pieces of text (title, type line, rules), not a page.
            tess.setPageSegMode(TessBaseAPI.PageSegMode.PSM_SPARSE_TEXT)
            tess.setImage(bitmap)
            tess.getUTF8Text() // runs the recognition
            val iterator = tess.getResultIterator() ?: return emptyList()
            val lines = mutableListOf<Map<String, Any>>()
            try {
                iterator.begin()
                do {
                    val text = iterator.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE)?.trim()
                    if (!text.isNullOrEmpty()) {
                        val box = iterator.getBoundingRect(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE)
                        lines.add(mapOf("text" to text, "height" to minOf(box.width(), box.height()).toDouble()))
                    }
                } while (iterator.next(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE))
            } finally {
                iterator.delete()
            }
            return lines
        } finally {
            tess.recycle()
        }
    }

    /** Tesseract reads its model from a real file, so the one in the APK is copied out once. */
    private fun copyModel(target: File) {
        if (target.exists()) return
        target.parentFile?.mkdirs()
        val partial = File(target.parentFile, target.name + ".part")
        assets.open("tessdata/eng.traineddata").use { input -> partial.outputStream().use { input.copyTo(it) } }
        if (!partial.renameTo(target)) throw IllegalStateException("Cannot save the OCR model")
    }

    /** Camera photos are often stored sideways with an EXIF tag; Tesseract ignores it, so turn the pixels. */
    private fun upright(bitmap: Bitmap, path: String): Bitmap {
        val degrees = when (ExifInterface(path).getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)) {
            ExifInterface.ORIENTATION_ROTATE_90 -> 90f
            ExifInterface.ORIENTATION_ROTATE_180 -> 180f
            ExifInterface.ORIENTATION_ROTATE_270 -> 270f
            else -> return bitmap
        }
        val matrix = Matrix().apply { postRotate(degrees) }
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }
}
