"""Render original music loops and the wooden UI click into Godot WAV assets."""
import math
from array import array
from pathlib import Path
import wave

RATE = 22050
OUT = Path(__file__).resolve().parents[1] / "audio"
TAU = math.tau


def frequency(note):
    return 440 * 2 ** ((note - 69) / 12)


def note_into(samples, offset, pitch, duration, gain, instrument):
    base = frequency(pitch)
    start = round(offset * RATE)
    for index in range(round(duration * RATE)):
        time = index / RATE
        phase = TAU * base * time
        release = min(1, (duration - time) / 0.12)
        if instrument == "breath":
            envelope = min(1, time / 0.15) * release
            tone = math.sin(phase + 0.12 * math.sin(TAU * 4.8 * time)) + 0.19 * math.sin(2 * phase)
        elif instrument == "drone":
            envelope = min(1, time / 0.35) * release
            tone = math.sin(phase) + 0.25 * math.sin(2 * phase)
        else:
            envelope = min(1, time / 0.009) * math.exp(-3.6 * time) * release
            tone = math.sin(phase) + 0.35 * math.sin(2.01 * phase) + 0.17 * math.sin(3.98 * phase)
        samples[(start + index) % len(samples)] += gain * envelope * tone


def write_wav(name, samples):
    pcm = array("h", (round(max(-1, min(1, value)) * 32760) for value in samples))
    with wave.open(str(OUT / name), "wb") as file:
        file.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        file.writeframes(pcm.tobytes())


def music(name, beat, melody, bass, lead):
    samples = [0.0] * round(RATE * beat * len(melody))
    for position, pitch in enumerate(melody):
        if pitch:
            note_into(samples, position * beat, pitch, beat * (1.5 if lead == "breath" else 1.9), 0.21, lead)
            note_into(samples, (position + 0.48) * beat, pitch, beat * 1.4, 0.027, "pluck")
    for position, pitch in enumerate(bass):
        note_into(samples, position * 4 * beat, pitch, beat * 3.9, 0.075, "drone")
        note_into(samples, (position * 4 + 2.5) * beat, pitch + 12, beat * 1.5, 0.085, "pluck")
    write_wav(name, samples)


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    music("title.wav", 0.69,
          [72, 0, 74, 76, 79, 0, 76, 74, 72, 0, 69, 67, 69, 0, 72, 0,
           76, 79, 81, 0, 79, 76, 74, 0, 72, 74, 69, 0, 67, 0, 72, 0],
          [48, 43, 45, 48, 45, 48, 43, 48], "pluck")
    music("story.wav", 0.79,
          [67, 0, 69, 0, 72, 74, 0, 72, 69, 0, 67, 64, 67, 0, 0, 0,
           64, 67, 69, 0, 72, 0, 76, 74, 72, 0, 69, 0, 67, 0, 0, 0],
          [43, 45, 43, 40, 40, 45, 48, 43], "breath")
    music("farm.wav", 0.51,
          [76, 79, 81, 79, 76, 74, 72, 0, 74, 76, 79, 76, 74, 72, 69, 0,
           72, 76, 81, 84, 81, 79, 76, 0, 74, 76, 79, 74, 72, 69, 72, 0,
           79, 76, 74, 76, 72, 74, 76, 0, 69, 72, 74, 72, 69, 67, 72, 0],
          [48, 45, 43, 48, 45, 48, 43, 48, 43, 48, 45, 48], "pluck")
    click = [0.0] * round(RATE * 0.13)
    for pitch, gain in [(74, 0.29), (88, 0.14), (100, 0.068)]:
        for index in range(len(click)):
            time = index / RATE
            click[index] += gain * math.sin(TAU * frequency(pitch) * time) * math.exp(-39 * time) * min(1, time / 0.003)
    write_wav("click.wav", click)
