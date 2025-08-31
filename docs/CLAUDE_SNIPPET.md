# Ruler Voice Bridge - Configuration Snippet

Add this section to your `.ruler/AGENTS.md` file to enable voice output for all AI coding assistants:

```markdown
## 🎤 Voice Output System

You have access to voice output capabilities via the Ruler Voice Bridge:

### Quick Usage
```bash
say "System ready"                  # Default voice (amy)
say "Build failed" ryan             # Specific voice
say "Deployment complete" kathleen  # Professional voice
```

### Available Voices
- **amy** - Natural female voice (default)
- **danny** - Clear male voice
- **kathleen** - Professional female voice
- **ryan** - Deep male voice
- **lessac** - Alternative accent
- **libritts** - High quality (slower)

### When to Use Voice
- ✅ Critical errors or failures
- ✅ Long task completions (builds, deployments)
- ✅ Security alerts
- ✅ User-requested notifications
- ❌ Routine status updates
- ❌ Debug information
- ❌ Verbose logging

### Examples
```bash
# Build/deployment notifications
say "Build completed successfully"
say "Deployment failed! Check logs!" ryan

# Long-running tasks
say "Database migration complete"
say "All tests passed" danny

# Alerts
say "CRITICAL: Disk space low!" ryan
say "Security scan detected vulnerabilities" kathleen

# Fun responses
say "Hello boss, how can I help?" amy
say "Roger that, initiating sequence" danny
```

### API Access
If the `say` command is unavailable, use the REST API:
```bash
curl "http://localhost:9003/play?text=Hello%20world&voice=amy"
```

### Environment Variables
- `RULER_VOICE_SERVER` - TTS server URL (default: http://localhost:9003)
- `RULER_VOICE_DEFAULT` - Default voice (default: amy)

**Note**: Server must be running: `cd ~/ruler-voice-bridge && ./venv/bin/python server.py`
```

## Alternative Minimal Version

If you want a more compact version, use this instead:

```markdown
## Voice Output
Use `say "message" [voice]` for audio output. Voices: amy (default), danny, kathleen, ryan.
Examples: `say "Build complete"` or `say "Error!" ryan`
Use for: critical alerts, task completion, errors. Server: localhost:9003
```