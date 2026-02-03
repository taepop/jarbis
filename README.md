# J.A.R.V.I.S Alarm - Iron Man Style Morning Briefing

A futuristic alarm app inspired by Tony Stark's AI assistant. Wake up to your favorite music while getting an AI-powered briefing on weather and world news.

![JARVIS Style](https://img.shields.io/badge/Style-Iron%20Man-red)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![Cost](https://img.shields.io/badge/Cost-FREE-brightgreen)

## ✨ Features

- 🎵 **Custom Alarm Sound** - Use your own MP3 files (like "Back in Black")
- 🌤️ **Weather Briefing** - Current conditions and forecast for your location
- 📰 **AI News Summary** - World news summarized by Gemini AI
- 🗣️ **Voice Briefing** - JARVIS-style spoken updates
- 🎨 **Futuristic UI** - Iron Man HUD-inspired design with glowing effects
- 💰 **100% FREE** - No subscriptions or payments required

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

1. **Clone/Download the project**

2. **Get dependencies**
   ```bash
   cd tony_stank
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 Setting Up Gemini API (FREE)

The AI news briefing feature uses Google's Gemini API, which has a **generous free tier**.

### Step 1: Get Your API Key

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy the generated key

### Step 2: Add Key to the App

1. Open the app
2. Go to **Settings** (gear icon)
3. Paste your API key in the "Gemini API Key" field
4. Tap **"Save Key"**

### Free Tier Limits

| Feature | Limit |
|---------|-------|
| Requests per day | 1,500 |
| Requests per minute | 15 |
| Tokens per minute | 1,000,000 |

This is more than enough for personal alarm use!

### No API Key?

The app still works without an API key! News headlines will be displayed without AI summarization.

## 🎵 Setting Up Your Alarm Sound

1. Open the app
2. Tap **+** to create an alarm
3. Tap **"Select your MP3 file"**
4. Choose your audio file (e.g., your "Back in Black" MP3)

**Tip:** You can also set a default sound in Settings that applies to all new alarms.

## 📱 Permissions Required

The app needs these permissions to function:

| Permission | Purpose |
|------------|---------|
| Notifications | Show alarm alerts |
| Exact Alarms | Trigger alarms precisely |
| Location | Get local weather |
| Storage | Access your music files |
| Internet | Fetch weather & news |

## 🎨 UI Features

- **Cyan & Orange Glow** - Iron Man's signature colors
- **HUD-Style Elements** - Rotating rings and scan lines
- **Animated Backgrounds** - Subtle grid patterns
- **Pulsing Effects** - Dynamic visual feedback
- **JARVIS Typography** - Futuristic Orbitron font

## 📋 Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| Alarm Scheduling | android_alarm_manager_plus |
| Notifications | flutter_local_notifications |
| Audio | just_audio |
| TTS | flutter_tts |
| Weather API | Open-Meteo (FREE) |
| News Sources | BBC, NYT, NPR (RSS) |
| AI Summary | Google Gemini 2.0 Flash |

## 🆓 Free Services Used

All services have free tiers with no payment required:

- **Open-Meteo** - Unlimited free weather API
- **RSS Feeds** - Free news from major outlets
- **Gemini API** - 1,500 free requests/day
- **Native TTS** - Built into Android

## ⚠️ Important Notes

### Battery Optimization

Some Android phones (Xiaomi, Huawei, Samsung) aggressively kill background apps. To ensure alarms work:

1. Go to **Settings > Apps > J.A.R.V.I.S Alarm**
2. Tap **Battery**
3. Select **"Don't optimize"** or **"Unrestricted"**

See [Don't Kill My App](https://dontkillmyapp.com) for device-specific instructions.

### Music Copyright

This app lets you use your own audio files. Ensure you legally own any music you use.

## 🔧 Troubleshooting

### Alarm not ringing?
- Check battery optimization settings
- Ensure notification permission is granted
- Verify exact alarm permission on Android 14+

### No weather data?
- Enable location permission
- Check internet connection
- Location services must be enabled

### News briefing not working?
- Add your Gemini API key in Settings
- Check internet connection
- API key may have hit daily limit (resets at midnight PT)

## 📄 License

This project is for personal use. Feel free to modify and enhance!

---

*"Sometimes you gotta run before you can walk."* - Tony Stark
