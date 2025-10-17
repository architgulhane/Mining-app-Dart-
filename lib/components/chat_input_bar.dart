import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onVoiceInput;
  final VoidCallback? onCsvUpload;
  final bool isLoading;
  final bool hasCsvContext;
  
  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.onVoiceInput,
    this.onCsvUpload,
    this.isLoading = false,
    this.hasCsvContext = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // CSV Upload button
            if (widget.onCsvUpload != null)
              Tooltip(
                message: widget.hasCsvContext ? 'CSV loaded (Type "clear csv" to clear)' : 'Upload CSV for context-based queries',
                child: IconButton(
                  onPressed: widget.isLoading ? null : widget.onCsvUpload,
                  icon: Icon(
                    Icons.upload_file,
                    color: widget.hasCsvContext ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            if (widget.onCsvUpload != null) SizedBox(width: isMobile ? 4 : 8),
            // Voice input button
            if (widget.onVoiceInput != null)
              VoiceInputButton(
                onPressed: widget.isLoading ? null : widget.onVoiceInput,
              ),
            if (widget.onVoiceInput != null) SizedBox(width: isMobile ? 8 : 12),
            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isLoading,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Ask a question...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF9CA3AF),
                      fontSize: isMobile ? 15 : 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 10 : 12,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            // Send button
            SendButton(
              onPressed: _hasText && !widget.isLoading ? _sendMessage : null,
              isLoading: widget.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceInputButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const VoiceInputButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.mic_outlined),
      color: onPressed != null ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF3F4F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  
  const SendButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.send, size: 20),
      color: Colors.white,
      style: IconButton.styleFrom(
        backgroundColor: onPressed != null
            ? const Color(0xFF4F46E5)
            : const Color(0xFF9CA3AF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
