#!/usr/bin/env python3
"""Generates android/app/src/main/res/raw/sound_celebrate.wav.

A quiet, soft chime: five mellow bell-bar notes rising over a C major chord,
with a short room reverb. Pure standard library; run from the repo root:

    python3 tool/gen_celebrate_sound.py
"""
import math
import random
import struct
import wave

SR = 44100
LENGTH = 2.4  # seconds
OUT = "android/app/src/main/res/raw/sound_celebrate.wav"

# (start seconds, frequency Hz, loudness)
NOTES = [
    (0.00, 523.25, 0.80),  # C5
    (0.13, 659.25, 0.75),  # E5
    (0.26, 783.99, 0.75),  # G5
    (0.41, 1046.50, 0.70),  # C6
    (0.62, 1318.51, 0.45),  # E6
]
# (frequency ratio, level, decay time constant in seconds): a struck metal bar.
PARTIALS = [(1.0, 1.0, 0.50), (2.76, 0.22, 0.14), (5.40, 0.07, 0.05)]


def render_dry():
    n = int(SR * LENGTH)
    out = [0.0] * n
    rng = random.Random(7)
    for start, freq, level in NOTES:
        first = int(start * SR)
        for detune, share in ((1.0, 0.7), (1.0018, 0.3)):  # slight shimmer
            for ratio, amp, tau in PARTIALS:
                f = freq * ratio * detune
                # Higher notes ring shorter, like real bars.
                tau_n = tau * (523.25 / freq) ** 0.35
                w = 2 * math.pi * f / SR
                gain = level * amp * share
                for i in range(first, n):
                    t = (i - first) / SR
                    attack = min(1.0, t / 0.004)
                    attack = 0.5 - 0.5 * math.cos(math.pi * attack)
                    out[i] += gain * attack * math.exp(-t / tau_n) * math.sin(w * (i - first))
        # Soft mallet tick.
        for i in range(first, min(n, first + int(0.006 * SR))):
            t = (i - first) / (0.006 * SR)
            out[i] += 0.05 * level * (1 - t) * rng.uniform(-1, 1)
    return out


def comb(x, delay_s, feedback, damp):
    d = int(delay_s * SR)
    buf = [0.0] * d
    y = [0.0] * len(x)
    low = 0.0
    k = 0
    for i, s in enumerate(x):
        o = buf[k]
        low = o * (1 - damp) + low * damp  # darker tail
        buf[k] = s + low * feedback
        y[i] = o
        k = (k + 1) % d
    return y


def allpass(x, delay_s, g):
    d = int(delay_s * SR)
    buf = [0.0] * d
    y = [0.0] * len(x)
    k = 0
    for i, s in enumerate(x):
        b = buf[k]
        o = -g * s + b
        buf[k] = s + g * o
        y[i] = o
        k = (k + 1) % d
    return y


def main():
    dry = render_dry()
    wet = [0.0] * len(dry)
    for delay, fb in ((0.0297, 0.80), (0.0371, 0.78), (0.0411, 0.77), (0.0437, 0.75)):
        for i, s in enumerate(comb(dry, delay, fb, 0.35)):
            wet[i] += s * 0.25
    wet = allpass(allpass(wet, 0.005, 0.7), 0.0017, 0.7)
    mix = [d + 0.30 * w for d, w in zip(dry, wet)]

    # Gentle low-pass to take the edge off, then fade the tail out.
    low = 0.0
    a = math.exp(-2 * math.pi * 6500 / SR)
    for i, s in enumerate(mix):
        low = (1 - a) * s + a * low
        mix[i] = low
    fade = int(0.5 * SR)
    for i in range(fade):
        mix[len(mix) - 1 - i] *= 0.5 - 0.5 * math.cos(math.pi * i / fade)

    peak = max(abs(s) for s in mix)
    scale = 0.42 / peak  # about -7.5 dBFS: clearly quieter than full scale
    with wave.open(OUT, "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SR)
        f.writeframes(b"".join(struct.pack("<h", int(s * scale * 32767)) for s in mix))


if __name__ == "__main__":
    main()
