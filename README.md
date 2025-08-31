# 🎤 Ruler Voice Bridge

Give your AI coding assistants a voice! Ruler Voice Bridge is a lightweight Text-to-Speech (TTS) server that integrates with [Ruler](https://github.com/sst/ruler) to provide voice output capabilities for Claude, Cursor, Windsurf, and other AI coding tools.

## ✨ Features

- **Universal Voice Output** - Works with any AI tool configured through Ruler
- **Multiple Voice Models** - 6 different voices with varying quality/speed tradeoffs
- **Simple CLI** - Just type `say "Hello world"` from anywhere
- **REST API** - FastAPI server with `/speak` and `/play` endpoints
- **Cross-Platform** - Works on Linux, macOS, and WSL
- **Lightweight** - Minimal dependencies, runs on CPU
- **Configurable** - Environment variables or JSON config
- **Auto-detection** - Finds the best audio backend automatically

## 🚀 Quick Start

### One-Line Install

```bash
git clone https://github.com/yourusername/ruler-voice-bridge.git && \
cd ruler-voice-bridge && \
./install.sh
```

This will:
1. Install Python dependencies
2. Download the default voice model (Amy)
3. Set up the `say` command
4. Create a config file

### Start the Server

```bash
# Using the virtual environment
./venv/bin/python server.py

# Or if you activated the venv
source venv/bin/activate
python server.py
```

### Test It Out

```bash
# From anywhere on your system
say "Hello from Ruler Voice Bridge"

# Try different voices
say "This is Danny speaking" danny
say "Kathleen here with an update" kathleen
say "Ryan's deep voice" ryan
```

## 📦 Installation Details

### Prerequisites

- Python 3.8+
- Audio player (PulseAudio, ALSA, Sox, or FFmpeg)
- 500MB free space for voice models

### Manual Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/ruler-voice-bridge.git
cd ruler-voice-bridge

# 2. Create virtual environment
python3 -m venv venv
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Download voice models
./install.sh download-voice amy    # Default female voice
./install.sh download-voice danny  # Male voice

# 5. Start the server
python server.py
```

### Install as System Service (Linux)

```bash
# Generate systemd service file
./install.sh systemd

# Install and start
sudo cp ruler-voice.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ruler-voice
sudo systemctl start ruler-voice
```

## 🎭 Available Voices

| Voice | Quality | Speed | Description |
|-------|---------|-------|-------------|
| **amy** | Medium | Fast | Natural female voice (default) |
| **danny** | Low | Very Fast | Clear male voice |
| **kathleen** | Low | Very Fast | Professional female voice |
| **ryan** | Medium | Fast | Deep male voice |
| **lessac** | Medium | Fast | Alternative accent |
| **libritts** | High | Slower | Highest quality |

Download voices as needed:
```bash
./install.sh download-voice danny
./install.sh download-all  # Get all voices
```

## 🔧 Configuration

### Environment Variables

```bash
export RULER_VOICE_SERVER="http://localhost:9003"  # Server URL
export RULER_VOICE_DEFAULT="amy"                   # Default voice
export RULER_VOICE_PORT="9003"                     # Server port
export RULER_VOICE_HOST="0.0.0.0"                  # Server host
export RULER_VOICE_CONFIG="./config.json"          # Config file path
```

### Configuration File

Copy and edit `config.example.json`:

```json
{
  "port": 9003,
  "default_voice": "amy",
  "audio_backend": "auto",
  "silence_padding": 0.2
}
```

## 🤖 Ruler Integration

Add this to your `.ruler/AGENTS.md` or tool-specific config:

```markdown
## Voice Output Capability

You have access to voice output through the `say` command:
- Usage: `say "message" [voice]`
- Voices: amy (default), danny, kathleen, ryan, lessac, libritts
- Server: http://localhost:9003

Examples:
- `say "Build complete"`
- `say "Error detected" ryan`
- `say "System ready" kathleen`

Use voice for:
- Critical alerts
- Long-running task completion
- Important notifications
- Error announcements
```

## 📡 API Documentation

### REST Endpoints

```bash
# Get server status
curl http://localhost:9003/

# List available voices
curl http://localhost:9003/voices

# Generate and download audio
curl "http://localhost:9003/speak?text=Hello&voice=amy" -o speech.wav

# Generate and play locally (on server)
curl "http://localhost:9003/play?text=Hello&voice=danny"
```

### Python Client Example

```python
import requests

# Play text on server
response = requests.get("http://localhost:9003/play", params={
    "text": "Task completed successfully",
    "voice": "amy"
})

# Download audio file
response = requests.get("http://localhost:9003/speak", params={
    "text": "Hello world",
    "voice": "danny"
})
with open("output.wav", "wb") as f:
    f.write(response.content)
```

## 🛠️ Troubleshooting

### No Audio Output
```bash
# Check audio system
pactl info  # PulseAudio
aplay -l    # ALSA

# Test audio directly
speaker-test -t wav -c 2

# Check server logs
curl http://localhost:9003/  # Should show status
```

### Voice Model Not Found
```bash
# Download specific voice
./install.sh download-voice amy

# Check voice directory
ls ~/.piper/voices/

# Use config to set custom path
export RULER_VOICE_DIR="/path/to/voices"
```

### Server Won't Start
```bash
# Check Python version
python3 --version  # Need 3.8+

# Reinstall dependencies
rm -rf venv
./install.sh deps

# Check port availability
lsof -i :9003
```

## 🏗️ Development

### Project Structure
```
ruler-voice-bridge/
├── server.py           # FastAPI TTS server
├── bin/
│   └── say            # CLI interface
├── requirements.txt    # Python dependencies
├── install.sh         # Installation script
├── config.example.json # Configuration template
├── docs/
│   └── CLAUDE_SNIPPET.md # For .ruler configs
└── voices/            # Voice models (after download)
```

### Running Tests
```bash
# Test installation
./install.sh test

# Test voice output
say "Test message" amy
say "Another test" danny

# Test API
curl http://localhost:9003/voices
```

## 📄 License

MIT License - See LICENSE file

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## 🙏 Acknowledgments

- [Piper TTS](https://github.com/rhasspy/piper) - The TTS engine
- [Ruler](https://github.com/sst/ruler) - AI tool configuration manager
- Voice models from the Piper project

## 📮 Support

- Issues: [GitHub Issues](https://github.com/yourusername/ruler-voice-bridge/issues)
- Discussions: [GitHub Discussions](https://github.com/yourusername/ruler-voice-bridge/discussions)

---

Made with 🎤 for AI coding assistants everywhere