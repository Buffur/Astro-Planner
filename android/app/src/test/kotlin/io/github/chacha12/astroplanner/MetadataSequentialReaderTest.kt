package io.github.chacha12.astroplanner

import java.io.ByteArrayInputStream
import java.io.IOException
import org.junit.Assert.*
import org.junit.Test

class MetadataSequentialReaderTest {
    @Test fun consumesAndChargesPrefixAndCloses() {
        var closed = false
        var consumed = 0
        val input = object : ByteArrayInputStream(ByteArray(100) { it.toByte() }) {
            override fun read(b: ByteArray, off: Int, len: Int): Int {
                val n = super.read(b, off, minOf(len, 3))
                if (n > 0) consumed += n
                return n
            }
            override fun close() { closed = true; super.close() }
            override fun skip(n: Long): Long = error("must account for consumed bytes")
        }
        val result = MetadataSequentialReader.read(80, 8, 100) { input }
        assertArrayEquals(ByteArray(8) { (80 + it).toByte() }, result.bytes)
        assertEquals(88L, result.consumed)
        assertEquals(88, consumed)
        assertTrue(closed)
    }

    @Test fun cumulativeBudgetRefusesBeforeOpeningNextStream() {
        var opens = 0
        val open = { opens++; ByteArrayInputStream(ByteArray(1000000)) }
        val first = MetadataSequentialReader.read(900000, 8, 1048576, open)
        assertThrows(MetadataBudgetExceeded::class.java) {
            MetadataSequentialReader.read(900000, 8, 1048576 - first.consumed, open)
        }
        assertEquals(1, opens)
    }

    @Test fun exactBudgetAndOverflowBoundary() {
        assertEquals(10L, MetadataSequentialReader.read(8, 2, 10) {
            ByteArrayInputStream(ByteArray(10))
        }.consumed)
        assertThrows(MetadataBudgetExceeded::class.java) {
            MetadataSequentialReader.read(Long.MAX_VALUE, 8, 1048576) { error("opened") }
        }
    }

    @Test fun truncatedPrefixAndPayloadCloseStream() {
        for (length in listOf(3, 9)) {
            var closed = false
            val input = object : ByteArrayInputStream(ByteArray(length)) {
                override fun close() { closed = true; super.close() }
            }
            assertThrows(IOException::class.java) {
                MetadataSequentialReader.read(8, 4, 100) { input }
            }
            assertTrue(closed)
        }
    }
}
