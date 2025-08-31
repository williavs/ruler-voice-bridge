#!/bin/bash
# Ruler Voice Bridge - Installation Script
# Installs dependencies and downloads voice models

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
VOICE_DIR="${HOME}/.piper/voices"
PIPER_RELEASE="https://github.com/rhasspy/piper/releases/download/2023.11.14-2"

# Voice model URLs
declare -A VOICE_URLS=(
    ["amy"]="${PIPER_RELEASE}/en_US-amy-medium.onnx"
    ["amy-config"]="${PIPER_RELEASE}/en_US-amy-medium.onnx.json"
    ["danny"]="${PIPER_RELEASE}/en_US-danny-low.onnx"
    ["danny-config"]="${PIPER_RELEASE}/en_US-danny-low.onnx.json"
    ["kathleen"]="${PIPER_RELEASE}/en_US-kathleen-low.onnx"
    ["kathleen-config"]="${PIPER_RELEASE}/en_US-kathleen-low.onnx.json"
    ["ryan"]="${PIPER_RELEASE}/en_US-ryan-medium.onnx"
    ["ryan-config"]="${PIPER_RELEASE}/en_US-ryan-medium.onnx.json"
    ["lessac"]="${PIPER_RELEASE}/en_US-lessac-medium.onnx"
    ["lessac-config"]="${PIPER_RELEASE}/en_US-lessac-medium.onnx.json"
    ["libritts"]="${PIPER_RELEASE}/en_US-libritts_r-medium.onnx"
    ["libritts-config"]="${PIPER_RELEASE}/en_US-libritts_r-medium.onnx.json"
)

print_header() {
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}    Ruler Voice Bridge - Installation${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

check_python() {
    echo "Checking Python installation..."
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_success "Python $PYTHON_VERSION found"
        
        # Check if version is 3.8+
        MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
        MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
        
        if [ "$MAJOR" -lt 3 ] || ([ "$MAJOR" -eq 3 ] && [ "$MINOR" -lt 8 ]); then
            print_error "Python 3.8+ required (found $PYTHON_VERSION)"
            exit 1
        fi
    else
        print_error "Python 3 not found. Please install Python 3.8+"
        exit 1
    fi
}

check_audio() {
    echo "Checking audio playback tools..."
    
    local found=false
    for tool in paplay aplay sox ffplay afplay; do
        if command -v $tool &> /dev/null; then
            print_success "Found audio player: $tool"
            found=true
            break
        fi
    done
    
    if [ "$found" = false ]; then
        print_warning "No audio player found. Install one of:"
        echo "  - PulseAudio: sudo apt install pulseaudio-utils"
        echo "  - ALSA: sudo apt install alsa-utils"
        echo "  - Sox: sudo apt install sox"
        echo "  - FFmpeg: sudo apt install ffmpeg"
    fi
}

install_python_deps() {
    echo "Installing Python dependencies..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        print_warning "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip --quiet
    
    # Install requirements
    pip install -r requirements.txt
    
    print_success "Python dependencies installed"
}

download_voice() {
    local voice=$1
    
    if [ -z "$voice" ]; then
        print_error "Please specify a voice to download"
        echo "Available voices: amy, danny, kathleen, ryan, lessac, libritts"
        return 1
    fi
    
    # Create voice directory if it doesn't exist
    mkdir -p "$VOICE_DIR"
    
    # Map voice names to files
    local model_file=""
    case "$voice" in
        "amy")
            model_file="en_US-amy-medium.onnx"
            ;;
        "danny")
            model_file="en_US-danny-low.onnx"
            ;;
        "kathleen")
            model_file="en_US-kathleen-low.onnx"
            ;;
        "ryan")
            model_file="en_US-ryan-medium.onnx"
            ;;
        "lessac")
            model_file="en_US-lessac-medium.onnx"
            ;;
        "libritts")
            model_file="en_US-libritts_r-medium.onnx"
            ;;
        *)
            print_error "Unknown voice: $voice"
            echo "Available voices: amy, danny, kathleen, ryan, lessac, libritts"
            return 1
            ;;
    esac
    
    # Check if already downloaded
    if [ -f "$VOICE_DIR/$model_file" ]; then
        print_success "Voice '$voice' already downloaded"
        return 0
    fi
    
    echo "Downloading $voice voice model..."
    
    # Download model file
    if wget -q --show-progress -O "$VOICE_DIR/$model_file" "${VOICE_URLS[$voice]}"; then
        print_success "Downloaded $model_file"
    else
        print_error "Failed to download $model_file"
        return 1
    fi
    
    # Download config file
    if wget -q -O "$VOICE_DIR/${model_file}.json" "${VOICE_URLS[$voice-config]}"; then
        print_success "Downloaded config for $voice"
    else
        print_warning "Config file download failed (may not be needed)"
    fi
    
    print_success "Voice '$voice' installed successfully"
}

install_ruler_integration() {
    echo "Setting up Ruler integration..."
    
    # Create symlink to say command in /usr/local/bin if we have permissions
    if [ -w "/usr/local/bin" ]; then
        ln -sf "$PWD/bin/say" /usr/local/bin/say
        print_success "Installed 'say' command globally"
    else
        print_warning "Cannot install globally. Add this to your PATH:"
        echo "  export PATH=\"$PWD/bin:\$PATH\""
    fi
    
    # Copy config example if no config exists
    if [ ! -f "config.json" ]; then
        cp config.example.json config.json
        print_success "Created config.json from example"
    fi
}

setup_systemd() {
    echo "Creating systemd service file..."
    
    cat > ruler-voice.service <<EOF
[Unit]
Description=Ruler Voice Bridge - TTS Server for AI Coding Assistants
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD
Environment="PATH=$PWD/venv/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=$PWD/venv/bin/python $PWD/server.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    print_success "Created ruler-voice.service"
    echo
    echo "To install as a system service:"
    echo "  sudo cp ruler-voice.service /etc/systemd/system/"
    echo "  sudo systemctl daemon-reload"
    echo "  sudo systemctl enable ruler-voice"
    echo "  sudo systemctl start ruler-voice"
}

show_usage() {
    echo "Usage: $0 [command] [options]"
    echo
    echo "Commands:"
    echo "  install              - Full installation (deps + default voice)"
    echo "  deps                 - Install Python dependencies only"
    echo "  download-voice NAME  - Download a specific voice model"
    echo "  download-all         - Download all voice models"
    echo "  systemd              - Create systemd service file"
    echo "  test                 - Test the installation"
    echo
    echo "Available voices:"
    echo "  amy      - Natural female voice (medium quality) [DEFAULT]"
    echo "  danny    - Clear male voice (low quality, fast)"
    echo "  kathleen - Professional female voice (low quality, fast)"
    echo "  ryan     - Deep male voice (medium quality)"
    echo "  lessac   - Alternative voice (medium quality)"
    echo "  libritts - High quality voice (slower)"
}

test_installation() {
    echo "Testing Ruler Voice Bridge installation..."
    
    # Check if venv exists
    if [ ! -d "venv" ]; then
        print_error "Virtual environment not found. Run: $0 install"
        exit 1
    fi
    
    # Activate venv
    source venv/bin/activate
    
    # Test Python imports
    echo "Testing Python dependencies..."
    python3 -c "import fastapi, uvicorn, piper" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "Python dependencies OK"
    else
        print_error "Missing Python dependencies. Run: $0 deps"
        exit 1
    fi
    
    # Check for at least one voice
    if [ -d "$VOICE_DIR" ] && [ "$(ls -A $VOICE_DIR/*.onnx 2>/dev/null | wc -l)" -gt 0 ]; then
        print_success "Voice models found"
    else
        print_warning "No voice models found. Run: $0 download-voice amy"
    fi
    
    # Test say command
    if [ -x "bin/say" ]; then
        print_success "CLI tool is executable"
    else
        print_error "CLI tool not executable"
        chmod +x bin/say
    fi
    
    print_success "Installation test complete"
}

# Main script
print_header

case "${1:-install}" in
    "install")
        check_python
        check_audio
        install_python_deps
        download_voice amy
        install_ruler_integration
        echo
        print_success "Installation complete!"
        echo
        echo "Next steps:"
        echo "1. Start the server: ./venv/bin/python server.py"
        echo "2. Test with: say 'Hello world'"
        echo "3. Download more voices: $0 download-voice danny"
        ;;
    
    "deps")
        check_python
        install_python_deps
        ;;
    
    "download-voice")
        download_voice "$2"
        ;;
    
    "download-all")
        for voice in amy danny kathleen ryan lessac libritts; do
            download_voice "$voice"
        done
        ;;
    
    "systemd")
        setup_systemd
        ;;
    
    "test")
        test_installation
        ;;
    
    *)
        show_usage
        ;;
esac