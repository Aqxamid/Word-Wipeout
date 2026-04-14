# Word Wipeout

An offline-first word puzzle game for Android. It features various game modes, built-in stats tracking, and experimental AI integration for word definitions.

## Game Modes

*   **Classic**: The standard experience. Build your win streak as words get longer and more challenging.
*   **Rage Bait**: A high-stakes mode with adaptive difficulty. You start with 3 hearts—if you lose them, your streak resets. Use the flag icon to forfeit a round and save a heart if you're stuck.
*   **Custom**: Build your own game. You can choose word lengths, set the number of attempts, or play with your own custom word lists.

## Key Features

*   **AI Insights (Beta)**: Get definitions and fun facts for words after every match. Support for both Google Gemini (online) and local GGUF models (completely offline).
*   **Fast Typing Audio**: A custom audio engine designed for fast typists. Sounds overlap naturally without cutting out, even when typing at high speeds.
*   **Precise Feedback**: Audio cues are index-tracked, meaning you only hear the "correct" sound when you actually find a new letter.
*   **Auto-Save**: Games are saved locally as you play. If you close the app or lose power, you can pick up exactly where you left off.
*   **Pure Offline Experience**: The core game requires no internet. All stats, history, and even local AI processing happen entirely on your device.

## Tech Stack

*   **Framework**: Flutter 3 / Provider
*   **Database**: Isar (Local NoSQL)
*   **AI**: llama_flutter_android (Local GGUF) / Gemini API
*   **Audio**: audioplayers (Customized for low-latency)

---
Made by Aquamid
