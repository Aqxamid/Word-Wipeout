# Word Wipeout

A premium, offline-capable vocabulary puzzle game for Android with dynamic multi-tiered game modes and localized AI dictionary generation.

## Features

### 🧩 Dynamic Gameplay Modes
- **Classic Play**: Endless vocabulary testing. Streaks build over time allowing for increasing difficulty calculations and extended words.
- **Rage Bait**: Elite-tier difficulty with adaptive word pools aggressively scaling to your streak. You are granted 3 Hearts per run. A pristine modal-driven white flag UI allows tactical surrenders at the cost of one life instead of wiping your sequence.
- **Custom Mode**: Total granular configurability — inject your own specific word pools, letter lengths, and attempts limits.

### 🤖 Dual-Engine AI Integration(Beta - might not work properly yet)
- **Hybrid System**:
    - **Local GGUF (Mobile Native AI)**: Pure, offline-first computation natively running directly on your processor via `llama_flutter_android`. Ingests standard `.gguf` architecture dynamically while safely copying the internal cache layer transparently.
    - **Cloud Gateway (Gemini API)**: Lightweight external cloud bindings utilizing Gemini Flash for rapid-fire dictionary ingestion.
- **Contextual Insights**: At the end of every round, the localized AI parses definition components and contextual fun facts using strict anti-hallucination prompt pipelines.

### 🎧 Zero-Latency Audio Triggers
- **Continuous Overlapping Overlay Engine**: An ephemeral garbage-collection scheme allows you to physically type at blistering speeds with overlapping auditory ticks, completely eliminating sound engine cut-out.
- **Adaptive Discovery Framework**: The underlying core tracking logic has been upgraded to scan precise positional indices, ensuring `correct.mp3` solely fires perfectly on *newly unlocked* green alignments rather than spamming arbitrarily. 

### ⚡ Performance & Caching
- **Absolute Preservation**: Active sessions forcefully cache into the physical drive via Isar tracking arrays — if the OS wipes the app during a game, everything correctly reinstantiates exactly as you left it.
- **Fluid Visual Polish**: Rapid shake animations correctly synchronize over failed entries and dynamic cascading unveil logic handles the row drops organically.

## Tech Stack

Flutter 3 · Provider · Isar 3 · llama_flutter_android · file_picker
