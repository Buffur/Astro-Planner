package io.github.chacha12.astroplanner

import java.io.IOException
import java.io.InputStream

/** A budget refusal is distinct from a provider I/O failure. */
internal class MetadataBudgetExceeded : IOException("metadata byte budget exceeded")

internal data class MetadataRange(val bytes: ByteArray, val consumed: Long)

/** The production streaming fallback, also exercised by host JVM tests.
 * Prefix bytes are consumed explicitly and charged even when not returned.
 * No stream is opened if this traversal cannot fit the remaining file budget.
 */
internal object MetadataSequentialReader {
    fun read(offset: Long, count: Int, remaining: Long, open: () -> InputStream): MetadataRange {
        require(offset >= 0 && count >= 0 && count <= 65536)
        if (count.toLong() > remaining || offset > remaining - count) {
            throw MetadataBudgetExceeded()
        }
        return open().use { input ->
            val discard = ByteArray(8192)
            var left = offset
            while (left > 0) {
                val n = input.read(discard, 0, minOf(left, discard.size.toLong()).toInt())
                if (n <= 0) throw IOException("short or stalled prefix read")
                left -= n
            }
            val out = ByteArray(count)
            var filled = 0
            while (filled < count) {
                val n = input.read(out, filled, count - filled)
                if (n <= 0) throw IOException("short or stalled metadata read")
                filled += n
            }
            MetadataRange(out, offset + count)
        }
    }
}
