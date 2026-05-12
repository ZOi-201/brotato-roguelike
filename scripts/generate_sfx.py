"""Generate 8-bit style sound effects as WAV files using square waves, noise, and arpeggios."""
import struct
import math
import random
import os

SFX_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")
SAMPLE_RATE = 22050  # Classic 8-bit sample rate

def wav_header(num_samples):
    data_size = num_samples * 2  # 16-bit mono
    return struct.pack('<4sI4s4sIHHIIHH4sI',
        b'RIFF', 36 + data_size, b'WAVE', b'fmt ', 16,
        1, 1, SAMPLE_RATE, SAMPLE_RATE * 2, 2, 16,
        b'data', data_size)

def square_wave(freq, duration, volume=0.3):
    """Generate a square wave at given frequency."""
    samples = int(SAMPLE_RATE * duration)
    data = []
    period = SAMPLE_RATE / freq
    for i in range(samples):
        val = volume if (i % period) < (period / 2) else -volume
        data.append(struct.pack('<h', int(val * 32767)))
    return b''.join(data)

def noise(duration, volume=0.15):
    """White noise burst."""
    samples = int(SAMPLE_RATE * duration)
    data = []
    for _ in range(samples):
        val = random.uniform(-volume, volume)
        data.append(struct.pack('<h', int(val * 32767)))
    return b''.join(data)

def fade(data, fade_out=True):
    """Apply fade in/out to PCM data."""
    count = len(data) // 2
    result = bytearray()
    for i in range(count):
        sample = struct.unpack('<h', data[i*2:i*2+2])[0]
        t = i / count
        factor = (1 - t) if fade_out else t
        if not fade_out and t < 0.1:
            factor = t / 0.1
        sample = int(sample * factor)
        result.extend(struct.pack('<h', max(-32767, min(32767, sample))))
    return bytes(result)

def tone_sweep(start_freq, end_freq, duration, volume=0.3):
    """Frequency sweep from start to end."""
    samples = int(SAMPLE_RATE * duration)
    data = []
    for i in range(samples):
        t = i / samples
        freq = start_freq + (end_freq - start_freq) * t
        period = SAMPLE_RATE / max(1, freq)
        val = volume if (i % period) < (period / 2) else -volume
        # Simple envelope
        env = min(t * 4, 1.0) * max(1 - t * 1.5, 0.1)
        data.append(struct.pack('<h', int(val * env * 32767)))
    return b''.join(data)

def arpeggio(notes, note_duration, volume=0.25):
    """Play a sequence of notes."""
    note_freqs = {
        'C4': 262, 'D4': 294, 'E4': 330, 'F4': 349, 'G4': 392,
        'A4': 440, 'B4': 494, 'C5': 523, 'D5': 587, 'E5': 659,
        'F5': 698, 'G5': 784, 'A5': 880, 'C3': 131, 'E3': 165, 'G3': 196,
    }
    data = bytearray()
    for note in notes:
        freq = note_freqs.get(note, 440)
        wave = square_wave(freq, note_duration, volume)
        data.extend(wave)
    return bytes(data)

def save_wav(filename, audio_data):
    path = os.path.join(SFX_DIR, filename)
    with open(path, 'wb') as f:
        f.write(wav_header(len(audio_data) // 2))
        f.write(audio_data)
    print(f"  Created: {filename}")

print("Generating 8-bit SFX...\n")

# 1. Shoot - quick descending laser
save_wav("shoot.wav", tone_sweep(1200, 400, 0.08, 0.25))

# 2. Enemy hit - short noise + low thud
data = noise(0.04, 0.2)
data = bytearray(data) + bytearray(tone_sweep(200, 60, 0.06, 0.2))
save_wav("hit.wav", bytes(data))

# 3. Player hit - deeper, longer
save_wav("player_hit.wav", tone_sweep(300, 60, 0.15, 0.3))

# 4. Kill - descending tones
save_wav("kill.wav", arpeggio(['G4', 'E4', 'C4'], 0.06, 0.2))

# 5. Pickup XP - quick high blip
save_wav("pickup_xp.wav", arpeggio(['E5', 'A5'], 0.04, 0.15))

# 6. Pickup coin - two-tone ding
save_wav("pickup_coin.wav", arpeggio(['C5', 'E5'], 0.05, 0.2))

# 7. Level up - ascending arpeggio
save_wav("level_up.wav", arpeggio(['C4', 'E4', 'G4', 'C5', 'E5'], 0.08, 0.22))

# 8. Wave start - alert tone
save_wav("wave_start.wav", arpeggio(['C4', 'G4', 'C5'], 0.1, 0.25))

# 9. Game over / defeat
save_wav("game_over.wav", arpeggio(['E4', 'C4', 'A3', 'G3'], 0.15, 0.25))

# 10. Victory jingle
save_wav("victory.wav", arpeggio(['C4', 'E4', 'G4', 'C5', 'E5', 'G5', 'C5', 'G5', 'C5'], 0.08, 0.22))

print("\nDone!")
