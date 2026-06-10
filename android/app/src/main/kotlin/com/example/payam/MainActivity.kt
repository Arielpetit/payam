package com.example.payam

import android.app.PendingIntent
import android.content.ComponentName
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.NdefMessage
import android.nfc.Tag
import android.nfc.cardemulation.CardEmulation
import android.nfc.tech.IsoDep
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.nio.charset.StandardCharsets
import android.content.Context
import android.os.Handler
import android.os.Looper

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.example.payam/nfc"
    private var methodChannel: MethodChannel? = null
    private var pendingTransactionId: String? = null
    private var nfcAdapter: NfcAdapter? = null
    private var isReaderModeActive = false
    private var isHceModeActive = false

    // AID for Payam (must match HceService)
    private val PAYAM_AID = "F0010203040506"

    companion object {
        private const val TAG = "MainActivity"
    }

    private fun sendLogToFlutter(message: String) {
        Handler(Looper.getMainLooper()).post {
            methodChannel?.invokeMethod("onLog", message)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
        
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startCardEmulation" -> {
                    val txnId = call.argument<String>("transactionId")
                    if (txnId != null) {
                        startCardEmulation(txnId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARG", "transactionId required", null)
                    }
                }
                "stopCardEmulation" -> {
                    stopCardEmulation()
                    result.success(true)
                }
                "startReaderMode" -> {
                    startReaderMode()
                    result.success(true)
                }
                "stopReaderMode" -> {
                    stopReaderMode()
                    result.success(true)
                }
                "isNfcAvailable" -> {
                    val available = nfcAdapter != null && nfcAdapter!!.isEnabled
                    result.success(available)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // If app was launched via NFC before Flutter was ready, send it now
        pendingTransactionId?.let { txnId ->
            methodChannel?.invokeMethod("onNfcIntent", txnId)
            pendingTransactionId = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        handleNfcIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleNfcIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        // Re-enable reader mode if it was active before pause
        if (isReaderModeActive) {
            enableReaderMode()
        }
    }

    override fun onPause() {
        super.onPause()
        // Don't disable reader mode onResume/onPause - 
        // the Flutter side will manage this explicitly
    }

    override fun onDestroy() {
        super.onDestroy()
        stopCardEmulation()
        stopReaderMode()
    }

    // ─── Traditional NFC Intent Handling (for external tags) ─────────────────

    private fun handleNfcIntent(intent: Intent?) {
        if (intent == null) return
        if (intent.action != NfcAdapter.ACTION_NDEF_DISCOVERED &&
            intent.action != NfcAdapter.ACTION_TECH_DISCOVERED &&
            intent.action != NfcAdapter.ACTION_TAG_DISCOVERED
        ) return

        val rawMessages = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
            ?: return
        val ndefMessages = rawMessages.map { it as NdefMessage }
        val payload = ndefMessages
            .flatMap { it.records.toList() }
            .firstOrNull()
            ?.payload
            ?: return

        val txnId = try {
            val json = JSONObject(String(payload))
            json.optString("transactionId").takeIf { it.isNotEmpty() }
        } catch (_: Exception) {
            null
        } ?: return

        // Forward to Flutter
        if (methodChannel != null) {
            methodChannel?.invokeMethod("onNfcIntent", txnId)
        } else {
            pendingTransactionId = txnId
        }
    }

    // ─── Card Emulation Mode (Sender) ──────────────────────────────

    private fun startCardEmulation(transactionId: String) {
        Log.d(TAG, "=== START CARD EMULATION ===")

        sendLogToFlutter("=== CARD EMULATION STARTED ===")
        sendLogToFlutter("Transaction: $transactionId")

        if (nfcAdapter == null) {
            sendLogToFlutter("ERROR: NFC adapter not available")
            return
        }

        if (nfcAdapter?.isEnabled == false) {
            sendLogToFlutter("ERROR: NFC is disabled")
            return
        }

        sendLogToFlutter("NFC adapter OK")

        PayamHceService.activeTransactionId = transactionId
        isHceModeActive = true
        sendLogToFlutter("activeTransactionId set: $transactionId")

        try {
            val cardEmulation = CardEmulation.getInstance(nfcAdapter!!)
            val componentName = ComponentName(this, PayamHceService::class.java)
            val isDefault = cardEmulation.isDefaultServiceForCategory(componentName, CardEmulation.CATEGORY_PAYMENT)
            sendLogToFlutter("Is default payment service: $isDefault")
            if (cardEmulation.categoryAllowsForegroundPreference(CardEmulation.CATEGORY_PAYMENT)) {
                cardEmulation.setPreferredService(this, componentName)
                sendLogToFlutter("Preferred service set OK")
            } else {
                sendLogToFlutter("WARNING: foreground preference not allowed")
            }
        } catch (e: Exception) {
            sendLogToFlutter("ERROR setting preferred service: ${e.message}")
        }

        PayamHceService.onLog = { message -> sendLogToFlutter(message) }

        PayamHceService.onTransactionRead = {
            sendLogToFlutter("SUCCESS: Transaction read by receiver")
            Handler(Looper.getMainLooper()).post {
                methodChannel?.invokeMethod("onCardRead", null)
            }
        }

        sendLogToFlutter("HCE ready - waiting for reader tap...")
    }

    private fun stopCardEmulation() {
        Log.d(TAG, "Stopping card emulation")
        PayamHceService.activeTransactionId = null
        PayamHceService.onTransactionRead = null
        isHceModeActive = false
        // Release preferred service
        try {
            val cardEmulation = CardEmulation.getInstance(nfcAdapter!!)
            cardEmulation.unsetPreferredService(this)
            sendLogToFlutter("Preferred service released")
        } catch (_: Exception) {}
    }

    // ─── Reader Mode (Receiver) ───────────────────────────────────

    private fun startReaderMode() {
        Log.d(TAG, "Starting reader mode")
        sendLogToFlutter("READER MODE STARTED")
        
        if (nfcAdapter == null) {
            Log.w(TAG, "NFC not available")
            sendLogToFlutter("ERROR: NFC adapter not available")
            return
        }
        isReaderModeActive = true
        enableReaderMode()
    }

    private fun enableReaderMode() {
        Log.d(TAG, "=== ENABLE READER MODE ===")
        Log.d(TAG, "Timestamp: ${System.currentTimeMillis()}")
        
        sendLogToFlutter("Enabling reader mode...")
        
        if (nfcAdapter == null) {
            Log.e(TAG, "ERROR: NFC adapter is null!")
            sendLogToFlutter("ERROR: NFC adapter is null")
            return
        }
        
        if (nfcAdapter?.isEnabled == false) {
            Log.e(TAG, "ERROR: NFC is not enabled!")
            sendLogToFlutter("ERROR: NFC is disabled")
            return
        }
        
        Log.d(TAG, "NFC adapter available: ${nfcAdapter?.isEnabled}")
        sendLogToFlutter("NFC adapter ready")
        
        val flags = NfcAdapter.FLAG_READER_NFC_A or
                    NfcAdapter.FLAG_READER_NFC_B or
                    NfcAdapter.FLAG_READER_NFC_F or
                    NfcAdapter.FLAG_READER_NFC_V or
                    NfcAdapter.FLAG_READER_NO_PLATFORM_SOUNDS
        
        Log.d(TAG, "Reader flags: $flags")
        Log.d(TAG, "Activity: $localClassName")
        Log.d(TAG, "Calling enableReaderMode...")
        
        sendLogToFlutter("Reader mode enabled")
        sendLogToFlutter("Waiting for NFC tags...")
        
        nfcAdapter?.enableReaderMode(
            this,
            { tag ->
                Log.d(TAG, "=== NFC TAG CALLBACK FIRED ===")
                Log.d(TAG, "Tag discovered in reader mode at ${System.currentTimeMillis()}")
                sendLogToFlutter("TAG DETECTED")
                handleTagInReaderMode(tag)
            },
            flags,
            null
        )
        
        Log.d(TAG, "Reader mode enabled - waiting for NFC tags...")
        Log.d(TAG, "Make sure sender phone is in HCE mode")
    }

    private fun stopReaderMode() {
        Log.d(TAG, "Stopping reader mode")
        isReaderModeActive = false
        nfcAdapter?.disableReaderMode(this)
    }

    private fun handleTagInReaderMode(tag: Tag) {
        Log.d(TAG, "=== READER MODE: Tag discovered ===")
        Log.d(TAG, "Tag ID: ${tag.id?.joinToString("") { "%02X".format(it) } ?: "null"}")
        Log.d(TAG, "Tag tech list: ${tag.techList?.joinToString() ?: "null"}")
        
        sendLogToFlutter("TAG ID: ${tag.id?.joinToString("") { "%02X".format(it) } ?: "null"}")
        sendLogToFlutter("Tech: ${tag.techList?.joinToString() ?: "none"}")
        
        try {
            val isoDep = IsoDep.get(tag)
            if (isoDep != null) {
                Log.d(TAG, "ISO-DEP technology available")
                sendLogToFlutter("ISO-DEP found - HCE detected")
                isoDep.connect()
                Log.d(TAG, "=== Connected to ISO-DEP tag (HCE device) ===")
                sendLogToFlutter("Connected to HCE device")
                
                try {
                    // SELECT Payam AID
                    val selectCommand = buildSelectApdu(PAYAM_AID)
                    Log.d(TAG, "Sending SELECT command: ${selectCommand.toHexString()}")
                    sendLogToFlutter("SELECT AID: ${selectCommand.toHexString()}")
                    val selectResponse = isoDep.transceive(selectCommand)
                    Log.d(TAG, "SELECT response: ${selectResponse.toHexString()} (${selectResponse.size} bytes)")
                    sendLogToFlutter("SELECT response: ${selectResponse.toHexString()}")
                    
                    // Check if selection was successful (SW = 9000)
                    if (selectResponse.size >= 2 && 
                        selectResponse[selectResponse.size - 2] == 0x90.toByte() &&
                        selectResponse[selectResponse.size - 1] == 0x00.toByte()) {
                        
                        Log.d(TAG, "=== Payam app selected successfully ===")
                        sendLogToFlutter("SUCCESS: Payam app selected")
                        
                        // READ command (get transaction data)
                        val readCommand = byteArrayOf(0x00.toByte(), 0xB0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x00.toByte())
                        Log.d(TAG, "Sending READ command: ${readCommand.toHexString()}")
                        sendLogToFlutter("READ command: ${readCommand.toHexString()}")
                        val readResponse = isoDep.transceive(readCommand)
                        Log.d(TAG, "READ response: ${readResponse.toHexString()} (${readResponse.size} bytes)")
                        sendLogToFlutter("READ response: ${readResponse.toHexString()}")
                        
                        // Extract transaction ID (everything except last 2 bytes which is SW)
                        if (readResponse.size > 2) {
                            val txnBytes = readResponse.dropLast(2).toByteArray()
                            val txnId = String(txnBytes, StandardCharsets.UTF_8)
                            Log.d(TAG, "=== TRANSACTION RECEIVED: $txnId ===")
                            sendLogToFlutter("SUCCESS: Transaction received")
                            sendLogToFlutter("Trans ID: $txnId")
                            
                            // Send to Flutter
                            Handler(Looper.getMainLooper()).post {
                                methodChannel?.invokeMethod("onTransactionReceived", txnId)
                            }
                        } else {
                            Log.w(TAG, "READ response too short: ${readResponse.size} bytes")
                            sendLogToFlutter("ERROR: Response too short")
                        }
                    } else {
                        Log.w(TAG, "SELECT failed - wrong status word: ${selectResponse.toHexString()}")
                        Log.w(TAG, "Expected SW: 9000, Got: ${"%02X%02X".format(selectResponse[selectResponse.size-2], selectResponse[selectResponse.size-1])}")
                        sendLogToFlutter("ERROR: SELECT failed")
                        sendLogToFlutter("Status: ${"%02X%02X".format(selectResponse[selectResponse.size-2], selectResponse[selectResponse.size-1])}")
                    }
                } finally {
                    isoDep.close()
                    Log.d(TAG, "ISO-DEP connection closed")
                    sendLogToFlutter("Connection closed")
                }
            } else {
                Log.w(TAG, "ISO-DEP not available on this tag")
                Log.d(TAG, "Available technologies: ${tag.techList?.joinToString() ?: "none"}")
                sendLogToFlutter("ERROR: ISO-DEP not available")
                sendLogToFlutter("This is not an HCE device")
            }
        } catch (e: Exception) {
            Log.e(TAG, "=== ERROR in reader mode ===")
            Log.e(TAG, "Exception: ${e.javaClass.simpleName}: ${e.message}")
            Log.e(TAG, "Stack trace:", e)
            sendLogToFlutter("ERROR: ${e.javaClass.simpleName}")
            sendLogToFlutter("Message: ${e.message}")
        }
    }

    private fun buildSelectApdu(aid: String): ByteArray {
        val aidBytes = hexStringToByteArray(aid)
        return byteArrayOf(
            0x00.toByte(),  // CLA
            0xA4.toByte(),  // INS: SELECT
            0x04.toByte(),  // P1: Select by name
            0x00.toByte(),  // P2
            aidBytes.size.toByte(),  // Lc
            *aidBytes,  // AID data
            0x00.toByte()   // Le
        )
    }

    private fun hexStringToByteArray(hex: String): ByteArray {
        return hex.chunked(2)
            .map { it.toInt(16).toByte() }
            .toByteArray()
    }

    private fun ByteArray.toHexString(): String {
        return this.joinToString("") { "%02X".format(it) }
    }
}