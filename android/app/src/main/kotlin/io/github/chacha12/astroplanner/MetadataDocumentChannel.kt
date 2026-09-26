package io.github.chacha12.astroplanner

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.provider.OpenableColumns
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.nio.ByteBuffer
import java.util.concurrent.Executors

/**
 * Opens a capture file for metadata reading without copying it (ADR-017 §6,
 * S2.4). `pick` starts the system document picker (ACTION_OPEN_DOCUMENT) and
 * returns the document's URI, name and size; `read` returns one byte range,
 * read in place through the provider's file descriptor. Nothing is written to
 * the app's cache, and no persistable permission is taken: the grant ends with
 * the activity. The byte budget itself is enforced on the Dart side.
 */
class MetadataDocumentChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    companion object {
        const val NAME = "io.github.chacha12.astroplanner/metadata_document"
        private const val PICK_REQUEST = 0x4D44 // "MD"
    }

    private val channel = MethodChannel(messenger, NAME)
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pendingPick: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pick" -> pick(result)
            "read" -> read(call, result)
            else -> result.notImplemented()
        }
    }

    private fun pick(result: MethodChannel.Result) {
        if (pendingPick != null) {
            result.error("busy", "A document picker is already open", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
            .addCategory(Intent.CATEGORY_OPENABLE)
            .setType("*/*")
        pendingPick = result
        try {
            activity.startActivityForResult(intent, PICK_REQUEST)
        } catch (e: Exception) {
            pendingPick = null
            result.error("unavailable", e.toString(), null)
        }
    }

    /** Returns true when [requestCode] was this channel's pick. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_REQUEST) return false
        val result = pendingPick ?: return true
        pendingPick = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null) // cancelled
            return true
        }
        io.execute {
            try {
                val (name, size) = describe(uri)
                main.post {
                    result.success(
                        mapOf("uri" to uri.toString(), "name" to name, "size" to size),
                    )
                }
            } catch (e: Exception) {
                main.post { result.error(errorCode(e), e.toString(), null) }
            }
        }
        return true
    }

    /** The document's display name and size in bytes (null when unknown). */
    private fun describe(uri: Uri): Pair<String?, Long?> {
        var name: String? = null
        var size: Long? = null
        activity.contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                val n = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (n >= 0 && !cursor.isNull(n)) name = cursor.getString(n)
                val s = cursor.getColumnIndex(OpenableColumns.SIZE)
                if (s >= 0 && !cursor.isNull(s)) size = cursor.getLong(s)
            }
        }
        if (size == null || size!! < 0) {
            size = activity.contentResolver.openFileDescriptor(uri, "r")?.use { pfd ->
                pfd.statSize.takeIf { it >= 0 }
            }
        }
        return name to size
    }

    private fun read(call: MethodCall, result: MethodChannel.Result) {
        val uri = Uri.parse(call.argument<String>("uri"))
        val offset = call.argument<Number>("offset")!!.toLong()
        val count = call.argument<Number>("count")!!.toInt()
        val sequentialLimit = call.argument<Number>("sequentialLimit")!!.toLong()
        io.execute {
            try {
                val bytes = readRange(uri, offset, count, sequentialLimit)
                main.post { result.success(bytes) }
            } catch (e: Exception) {
                main.post { result.error(errorCode(e), e.toString(), null) }
            }
        }
    }

    /**
     * [count] bytes at [offset]. A regular file is read in place with a
     * positioned read. A descriptor that cannot seek (a pipe or a streaming
     * provider) is read from the start, and only while the range ends within
     * [sequentialLimit] bytes (the Dart side's byte budget).
     */
    private fun readRange(uri: Uri, offset: Long, count: Int, sequentialLimit: Long): ByteArray {
        val resolver = activity.contentResolver
        val pfd = resolver.openFileDescriptor(uri, "r")
            ?: throw IOException("the provider returned no file descriptor")
        if (pfd.statSize >= 0) {
            ParcelFileDescriptor.AutoCloseInputStream(pfd).use { stream ->
                val channel = stream.channel
                val buffer = ByteBuffer.allocate(count)
                var position = offset
                while (buffer.hasRemaining()) {
                    val n = channel.read(buffer, position)
                    if (n < 0) throw IOException("short read at $position")
                    position += n
                }
                return buffer.array()
            }
        }
        pfd.close()
        if (offset + count > sequentialLimit) {
            throw IOException("not seekable: range ends past $sequentialLimit bytes")
        }
        val input = resolver.openInputStream(uri)
            ?: throw IOException("the provider returned no stream")
        input.use {
            var skipped = 0L
            while (skipped < offset) {
                val n = it.skip(offset - skipped)
                if (n > 0) {
                    skipped += n
                } else if (it.read() >= 0) {
                    skipped += 1
                } else {
                    throw IOException("short read at $skipped")
                }
            }
            val out = ByteArray(count)
            var filled = 0
            while (filled < count) {
                val n = it.read(out, filled, count - filled)
                if (n < 0) throw IOException("short read at ${offset + filled}")
                filled += n
            }
            return out
        }
    }

    private fun errorCode(e: Exception): String =
        if (e is SecurityException) "revoked" else "io"

    fun dispose() {
        channel.setMethodCallHandler(null)
        pendingPick?.error("disposed", "The activity went away", null)
        pendingPick = null
        io.shutdown()
    }
}
