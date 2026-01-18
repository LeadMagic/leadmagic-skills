---
title: Voice Elements for Audio/Speech Interfaces
impact: MEDIUM
impactDescription: Build voice-enabled AI applications
tags: voice, audio, speech, elements
---

## Voice Elements for Audio/Speech Interfaces

AI SDK 6 includes Voice Elements - components for building voice-enabled AI applications with speech input, transcription, and audio playback.

**Available Voice Components (Jan 2026):**

```typescript
// Install Voice Elements
// npx ai-elements@latest add speech-input transcription audio-player

import {
  Persona,          // Animated AI visual with WebGL2/Rive
  SpeechInput,      // Voice input with recording controls
  Transcription,    // Displays and syncs transcripts
  AudioPlayer,      // Audio playback with visualization
  MicSelector,      // Microphone selection dropdown
  VoiceSelector,    // Voice/model selection
} from '@/components/ui/voice'
```

**Basic Voice Chat Interface:**

```typescript
'use client'

import { useChat } from 'ai/react'
import { SpeechInput, Transcription, AudioPlayer, Persona } from '@/components/ui/voice'
import { Conversation, Message } from '@/components/ui/ai'

export function VoiceChat() {
  const { messages, append, isLoading } = useChat({
    api: '/api/voice-chat',
  })

  const handleSpeechResult = async (transcript: string) => {
    await append({
      role: 'user',
      content: transcript,
    })
  }

  return (
    <div className="flex flex-col h-screen">
      {/* AI Avatar */}
      <div className="flex justify-center p-8">
        <Persona
          speaking={isLoading}
          mood="neutral"
          size="lg"
        />
      </div>

      {/* Conversation */}
      <Conversation className="flex-1 overflow-y-auto">
        {messages.map((message) => (
          <Message key={message.id} message={message}>
            {message.role === 'assistant' && message.audio && (
              <AudioPlayer
                src={message.audio}
                showWaveform
                autoPlay
              />
            )}
          </Message>
        ))}
      </Conversation>

      {/* Voice Input */}
      <div className="p-4 border-t">
        <SpeechInput
          onResult={handleSpeechResult}
          continuous={false}
          language="en-US"
        />
      </div>
    </div>
  )
}
```

**With Transcription Display:**

```typescript
'use client'

import { useState } from 'react'
import { SpeechInput, Transcription } from '@/components/ui/voice'

export function TranscriptionDemo() {
  const [transcript, setTranscript] = useState('')
  const [isRecording, setIsRecording] = useState(false)

  return (
    <div className="space-y-4">
      <Transcription
        text={transcript}
        isLive={isRecording}
        showTimestamps
        highlightCurrent
      />

      <SpeechInput
        onInterimResult={(text) => setTranscript(text)}
        onResult={(text) => {
          setTranscript(text)
          setIsRecording(false)
        }}
        onStart={() => setIsRecording(true)}
        onEnd={() => setIsRecording(false)}
      />
    </div>
  )
}
```

**Audio Player with Visualization:**

```typescript
import { AudioPlayer } from '@/components/ui/voice'

function AudioMessage({ audioUrl, transcript }) {
  return (
    <div className="p-4 rounded-lg bg-card">
      <AudioPlayer
        src={audioUrl}
        showWaveform        // Visual waveform
        showProgress        // Progress bar
        showPlaybackSpeed   // Speed controls (0.5x, 1x, 1.5x, 2x)
        onTimeUpdate={(time) => {
          // Sync with transcript highlighting
        }}
      />

      <Transcription
        text={transcript}
        syncWithAudio
      />
    </div>
  )
}
```

**Microphone and Voice Selection:**

```typescript
import { MicSelector, VoiceSelector } from '@/components/ui/voice'

function VoiceSettings() {
  const [selectedMic, setSelectedMic] = useState<string>()
  const [selectedVoice, setSelectedVoice] = useState<string>()

  return (
    <div className="space-y-4">
      <div>
        <label>Microphone</label>
        <MicSelector
          value={selectedMic}
          onValueChange={setSelectedMic}
          showLevelMeter  // Real-time audio level
        />
      </div>

      <div>
        <label>AI Voice</label>
        <VoiceSelector
          value={selectedVoice}
          onValueChange={setSelectedVoice}
          voices={[
            { id: 'alloy', name: 'Alloy', preview: '/voices/alloy.mp3' },
            { id: 'echo', name: 'Echo', preview: '/voices/echo.mp3' },
            { id: 'nova', name: 'Nova', preview: '/voices/nova.mp3' },
          ]}
        />
      </div>
    </div>
  )
}
```

**Server Route for Voice:**

```typescript
// app/api/voice-chat/route.ts
import { openai } from '@ai-sdk/openai'
import { streamText } from 'ai'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    // Voice-specific settings
    experimental_telemetry: {
      isEnabled: true,
      recordInputs: true,
    },
  })

  return result.toDataStreamResponse()
}
```

Voice Elements require:
- Browser with Web Speech API support
- Microphone permissions
- HTTPS in production
