import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/nfc_method_channel.dart';

class NfcDebugScreen extends StatefulWidget {
  const NfcDebugScreen({Key? key}) : super(key: key);

  @override
  State<NfcDebugScreen> createState() => _NfcDebugScreenState();
}

class _NfcDebugScreenState extends State<NfcDebugScreen> {
  final List<String> logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _nfcAvailable = false;

  @override
  void initState() {
    super.initState();
    // Load all logs that happened before this screen was opened
    logs.addAll(nfcMethodChannel.logBuffer);
    _listenToLogs();
    _addLog('Debug screen initialized');
    _checkNfcStatus();
  }

  void _listenToLogs() {
    nfcMethodChannel.onLog = (message) {
      // Only add if not already in buffer (buffer already has it)
      _addRaw('[${ DateTime.now().toString().substring(11, 23)}] $message');
    };
  }

  void _checkNfcStatus() async {
    try {
      final available = await nfcMethodChannel.isNfcAvailable();
      setState(() {
        _nfcAvailable = available;
      });
      _addLog('NFC available: ${available ? "Yes" : "No"}');
    } catch (e) {
      _addLog('ERROR checking NFC: $e');
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 23);
    _addRaw('[$timestamp] $message');
  }

  void _addRaw(String entry) {
    setState(() {
      logs.add(entry);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearLogs() {
    setState(() {
      logs.clear();
    });
    nfcMethodChannel.logBuffer.clear();
    _addLog('Logs cleared');
  }

  void _copyLogs() {
    final text = logs.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Debug Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogs,
            tooltip: 'Copy logs',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NFC Status:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.nfc, color: _nfcAvailable ? Colors.teal : Colors.red),
                    SizedBox(width: 8),
                    Text('NFC Available: ${_nfcAvailable ? "Yes" : "No"}'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: logs.isEmpty
                  ? Center(
                      child: Text(
                        'No logs yet...\nBring phones together to start',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final isError = log.contains('ERROR') ||
                            log.contains('FAIL') ||
                            log.contains('Exception');
                        final isSuccess = log.contains('SUCCESS') ||
                            log.contains('Transaction received') ||
                            log.contains('Transaction sent');
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: isError
                                  ? Colors.red
                                  : isSuccess
                                      ? Colors.green
                                      : Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal,
            child: Text(
              'Bring both phones NFC-to-NFC to see logs',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    nfcMethodChannel.onLog = null;
    super.dispose();
  }
}