package com.example.payam

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.content.Intent
import android.util.Log

class PayamHceService : HostApduService() {

    companion object {
        private const val TAG = "PayamHceService"
        
        // AID for Payam payment application (must match reader's SELECT command)
        private const val PAYAM_AID = "F0010203040506"
        
        // APDU response status words
        private val SW_OK = byteArrayOf(0x90.toByte(), 0x00.toByte())
        private val SW_NOT_FOUND = byteArrayOf(0x6A.toByte(), 0x82.toByte())
        private val SW_WRONG_LENGTH = byteArrayOf(0x67.toByte(), 0x00.toByte())
        
        // Currently active transactionId to broadcast
        @Volatile
        var activeTransactionId: String? = null
        
        // Callback when transaction is read by another device
        var onTransactionRead: (() -> Unit)? = null
        
        // Callback to send logs to Flutter
        var onLog: ((String) -> Unit)? = null
    }
    
    private fun sendLog(message: String) {
        Log.d(TAG, message)
        onLog?.invoke(message)
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "=== HCE SERVICE CREATED ===")
        Log.d(TAG, "Timestamp: ${System.currentTimeMillis()}")
        sendLog("HCE SERVICE CREATED")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "=== HCE SERVICE DESTROYED ===")
        sendLog("HCE SERVICE DESTROYED")
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        if (commandApdu == null) {
            Log.w(TAG, "Received NULL APDU command")
            sendLog("ERROR: NULL APDU received")
            return SW_NOT_FOUND
        }

        Log.d(TAG, "=== HCE: processCommandApdu called ===")
        Log.d(TAG, "Command APDU: ${commandApdu.toHexString()} (${commandApdu.size} bytes)")
        sendLog("HCE: APDU received")
        sendLog("Command: ${commandApdu.toHexString()}")

        // Parse APDU command
        val cla = commandApdu.getOrNull(0)?.toInt()?.and(0xFF) ?: 0
        val ins = commandApdu.getOrNull(1)?.toInt()?.and(0xFF) ?: 0
        val p1 = commandApdu.getOrNull(2)?.toInt()?.and(0xFF) ?: 0
        val p2 = commandApdu.getOrNull(3)?.toInt()?.and(0xFF) ?: 0

        Log.d(TAG, "APDU: CLA=$cla (0x%02X), INS=$ins (0x%02X), P1=$p1, P2=$p2".format(cla, ins))
        sendLog("CLA=0x%02X INS=0x%02X".format(cla, ins))

        when {
            // SELECT command (reader is selecting our app)
            cla == 0x00 && ins == 0xA4 -> {
                Log.d(TAG, ">>> SELECT command detected")
                sendLog(">>> SELECT command")
                return handleSelectCommand(commandApdu)
            }
            
            // READ command (reader wants transaction data)
            cla == 0x00 && ins == 0xB0 -> {
                Log.d(TAG, ">>> READ command detected")
                sendLog(">>> READ command")
                return handleReadCommand()
            }
            
            else -> {
                Log.w(TAG, ">>> Unknown command: CLA=$cla INS=$ins")
                sendLog("ERROR: Unknown command")
                return SW_NOT_FOUND
            }
        }
    }

    private fun handleSelectCommand(commandApdu: ByteArray): ByteArray {
        Log.d(TAG, "=== handleSelectCommand ===")
        sendLog("Handling SELECT")
        
        // Check if selecting Payam AID
        val lc = commandApdu.getOrNull(4)?.toInt() ?: 0
        Log.d(TAG, "Lc (AID length): $lc")
        sendLog("AID length: $lc")
        
        if (lc == PAYAM_AID.length / 2) {
            val aidData = commandApdu.drop(5).take(lc).toByteArray()
            val expectedAid = hexStringToByteArray(PAYAM_AID)
            
            Log.d(TAG, "Received AID: ${aidData.toHexString()}")
            Log.d(TAG, "Expected AID: ${expectedAid.toHexString()} (${PAYAM_AID})")
            sendLog("Received AID: ${aidData.toHexString()}")
            sendLog("Expected AID: $PAYAM_AID")
            
            if (aidData.contentEquals(expectedAid)) {
                Log.d(TAG, "=== AID MATCH! Payam app selected successfully ===")
                sendLog("SUCCESS: AID matched")
                sendLog("Payam app selected")
                return SW_OK
            } else {
                Log.w(TAG, "AID mismatch: got ${aidData.toHexString()}, expected ${expectedAid.toHexString()}")
                sendLog("ERROR: AID mismatch")
            }
        } else {
            Log.w(TAG, "Lc mismatch: got $lc, expected ${PAYAM_AID.length / 2}")
            sendLog("ERROR: AID length mismatch")
        }
        
        Log.w(TAG, "SELECT command - AID not recognized")
        sendLog("ERROR: AID not recognized")
        return SW_NOT_FOUND
    }

    private fun handleReadCommand(): ByteArray {
        Log.d(TAG, "=== handleReadCommand ===")
        sendLog("Handling READ")
        
        val txnId = activeTransactionId
        
        if (txnId.isNullOrEmpty()) {
            Log.w(TAG, "READ command but no active transaction")
            sendLog("ERROR: No transaction")
            return SW_NOT_FOUND
        }

        Log.d(TAG, "=== SENDING TRANSACTION: $txnId ===")
        sendLog("SUCCESS: Sending transaction")
        sendLog("Trans ID: $txnId")
        
        // Notify that transaction was read
        onTransactionRead?.invoke()
        
        // Return transaction as ASCII bytes + SW_OK
        val txnBytes = txnId.toByteArray(Charsets.UTF_8)
        val response = txnBytes + SW_OK
        Log.d(TAG, "Response: ${response.toHexString()} (${response.size} bytes)")
        sendLog("Response size: ${response.size} bytes")
        return response
    }

    override fun onDeactivated(reason: Int) {
        Log.d(TAG, "HCE deactivated: reason=$reason")
        sendLog("HCE deactivated: reason=$reason")
        // Reader has disconnected
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