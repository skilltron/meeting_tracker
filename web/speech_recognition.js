// Web Speech API integration for Flutter web
// This file provides JavaScript interop for speech recognition

class SpeechRecognitionManager {
  constructor() {
    this.recognition = null;
    this.isListening = false;
    this.onTranscript = null;
    this.onError = null;
    
    if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      this.recognition = new SpeechRecognition();
      this.recognition.continuous = true;
      this.recognition.interimResults = true;
      this.recognition.lang = 'en-US';
      
      this.recognition.onresult = (event) => {
        let transcript = '';
        for (let i = event.resultIndex; i < event.results.length; i++) {
          transcript += event.results[i][0].transcript;
        }
        if (this.onTranscript) {
          this.onTranscript(transcript);
        }
      };
      
      this.recognition.onerror = (event) => {
        if (this.onError) {
          this.onError(event.error);
        }
      };
      
      this.recognition.onend = () => {
        this.isListening = false;
      };
    }
  }
  
  start() {
    if (!this.recognition) {
      if (this.onError) {
        this.onError('Speech recognition not supported in this browser');
      }
      return false;
    }
    
    if (this.isListening) {
      return true;
    }
    
    try {
      this.recognition.start();
      this.isListening = true;
      return true;
    } catch (e) {
      if (this.onError) {
        this.onError(e.message);
      }
      return false;
    }
  }
  
  stop() {
    if (this.recognition && this.isListening) {
      this.recognition.stop();
      this.isListening = false;
    }
  }
}

// Global instance
window.speechRecognitionManager = new SpeechRecognitionManager();
