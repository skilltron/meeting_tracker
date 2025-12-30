import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obs_provider.dart';
import '../providers/transcription_provider.dart';
import 'obs_setup_dialog.dart';

/// Grandmother-simple OBS recording widget
/// Big buttons, clear status, easy to use
class OBSRecordingWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const OBSRecordingWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<OBSProvider>(
      builder: (context, obsProvider, child) {
        final isConnected = obsProvider.isConnected;
        final isRecording = obsProvider.isRecording;
        final error = obsProvider.error;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.15),
                accentColor.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'RECORDING',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Status indicator
              _buildStatusIndicator(isConnected, isRecording, error, textColor, accentColor),
              
              // Transcription status (if transcription provider is available)
              Builder(
                builder: (context) {
                  TranscriptionProvider? transcriptionProvider;
                  try {
                    transcriptionProvider = Provider.of<TranscriptionProvider>(context, listen: true);
                  } catch (e) {
                    return const SizedBox.shrink();
                  }
                  
                  final isTranscribing = transcriptionProvider.isTranscribing;
                  final actionItemsDetected = transcriptionProvider.actionItemsDetected;
                  
                  if (!isTranscribing) return const SizedBox.shrink();
                  
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LISTENING FOR ACTION ITEMS',
                              style: TextStyle(
                                fontSize: 11,
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            if (actionItemsDetected > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$actionItemsDetected',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Big buttons
              if (!isConnected)
                _buildConnectOrSetupButton(context, obsProvider, textColor, accentColor)
              else
                _buildRecordingButtons(context, obsProvider, isRecording, textColor, accentColor),
              
              // Error message
              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatusIndicator(
    bool isConnected,
    bool isRecording,
    String? error,
    Color textColor,
    Color accentColor,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (error != null) {
      statusColor = Colors.red;
      statusText = 'ERROR';
      statusIcon = Icons.error_outline;
    } else if (!isConnected) {
      statusColor = Colors.grey;
      statusText = 'NOT CONNECTED';
      statusIcon = Icons.link_off;
    } else if (isRecording) {
      statusColor = Colors.red;
      statusText = 'RECORDING';
      statusIcon = Icons.fiber_manual_record;
    } else {
      statusColor = Colors.green;
      statusText = 'READY';
      statusIcon = Icons.check_circle;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          statusIcon,
          color: statusColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: statusColor,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildConnectOrSetupButton(
    BuildContext context,
    OBSProvider obsProvider,
    Color textColor,
    Color accentColor,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () async {
              // Try to connect first
              final connected = await obsProvider.connect();
              if (!connected) {
                // If connection fails, show setup dialog
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => const OBSSetupDialog(),
                  );
                }
              } else {
                // Auto-configure on successful connection
                await obsProvider.autoConfigure();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              'CONNECT TO OBS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const OBSSetupDialog(),
            );
          },
          child: Text(
            'NEED TO SET UP OBS?',
            style: TextStyle(
              fontSize: 12,
              color: accentColor.withOpacity(0.8),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecordingButtons(
    BuildContext context,
    OBSProvider obsProvider,
    bool isRecording,
    Color textColor,
    Color accentColor,
  ) {
    return Row(
      children: [
        // Start/Stop button (big)
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 70,
            child: ElevatedButton(
              onPressed: () async {
                await obsProvider.toggleRecording();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRecording ? Icons.stop : Icons.play_arrow,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isRecording ? 'STOP' : 'START',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
