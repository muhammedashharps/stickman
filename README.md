<div align="center">

# 🎯 Stickman Productivity

### *Where Focus Meets Art*

**An AI-powered productivity timer with animated companions that bring your focus sessions to life**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Gemini AI](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google&logoColor=white)](https://deepmind.google/technologies/gemini/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

**[Features](#-features) • [How It Works](#-how-it-works) • [AI Magic](#-ai-magic) • [Installation](#-installation) • [Documentation](#-documentation)**

</div>

---

## 🌟 The Problem We Solve

Traditional timers are **boring**. You stare at numbers counting down. There's no emotional connection, no visual reward for your effort.

**Stickman Productivity transforms this experience.** 

Watch a tiny stickman build a bridge as you work. See a plant grow with each passing minute. Or describe ANY scene you can imagine—and watch our **Gemini AI** bring it to life, synchronized perfectly with your timer.

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎬 6 Preset Animations
Hand-crafted, physics-based stickman companions:
- 🌱 **Plant Growth** — Nurture a garden
- ⛰️ **Mountain Climb** — Conquer the summit  
- 💡 **Bulb Ladder** — Light up ideas
- 🌉 **Bridge Builder** — Connect worlds
- 🧗 **Cliff Climb** — Scale new heights
- 💧 **Water Tank** — Fill with patience

</td>
<td width="50%">

### 🤖 AI Animation Creator
Powered by **Google Gemini**:
- Describe any scene in natural language
- AI generates animated vector graphics
- Iterate and refine through conversation
- Save unlimited custom animations

</td>
</tr>
<tr>
<td>

### ⏱️ Smart Timer
- Wheel-style duration picker
- 1-180 minute range
- **Background persistence** — continues when minimized
- Completion sounds

</td>
<td>

### 📊 Rich Statistics  
- Daily/Weekly/Monthly/Yearly views
- Interactive calendar heatmap
- Session history with details
- Streak tracking

</td>
</tr>
</table>

---

## 🔄 How It Works

```mermaid
graph TD
    A[User Opens App] --> B{Choose Animation}
    B -->|Preset| C[Select from 6 Companions]
    B -->|Custom| D[AI Animation Wizard]
    
    D --> E[Describe Scene]
    E --> F[Gemini AI Generates JSON]
    F --> G[Preview Animation]
    G -->|Refine| H[Provide Feedback]
    H --> F
    G -->|Save| I[Animation Library]
    
    C --> J[Start Timer]
    I --> J
    
    J --> K[Timer Running]
    K --> L[Progress Syncs]
    L --> M{Complete?}
    M -->|No| K
    M -->|Yes| N[Celebration + Sound]
    N --> O[Stats Updated]
```

---

## 🧠 AI Magic

### The Gemini Integration Flow

```mermaid
sequenceDiagram
    participant U as User
    participant W as UI Wizard
    participant P as Provider
    participant G as Gemini AI
    participant R as Renderer

    U->>W: Describes scene "Stickman painting"
    W->>P: Collects action, environment, style
    P->>G: Sends structured prompt
    
    Note over G: AI generates JSON with geometric primitives
    
    G-->>P: Returns animation config
    P-->>R: Parses elements & animations
    R-->>U: Renders on Canvas
    
    U->>P: "Make brush red"
    P->>G: Refinement prompt + JSON
    G-->>P: Updated JSON
    R-->>U: New Animation
```

### What Makes It Special

| Traditional Apps | Stickman Productivity |
|-----------------|----------------------|
| Static timers | **Living animations** |
| Fixed visuals | **Infinite AI-generated scenes** |
| No progression | **Timer-synced visual progress** |
| Boring numbers | **Story-driven focus sessions** |

---

## 🛠️ Installation

```bash
# Clone
git clone https://github.com/yourusername/stickman_productivity.git
cd stickman_productivity

# Install dependencies
flutter pub get

# Run
flutter run
```

### Configure Gemini AI
1. Get API key from [Google AI Studio](https://aistudio.google.com/)
2. Open app → ⚙️ Settings
3. Enter API key & select model

---

## 📁 Project Structure

```mermaid
graph LR
    subgraph UI [Screens]
        HS[home_screen.dart]
        TS[timer_screen.dart]
        CS[create_animation_screen.dart]
        SS[stats_screen.dart]
    end
    
    subgraph Logic [Providers]
        TP[timer_provider.dart]
        AP[animation_creator_provider.dart]
        SP[statistics_provider.dart]
    end
    
    subgraph Services [Services]
        GS[gemini_service.dart]
        AS[audio_service.dart]
    end
    
    subgraph Widgets [Widgets]
        AW[animation_widgets.dart]
        AIW[ai_animation_widget.dart]
    end
    
    UI --> Logic
    Logic --> Services
    Logic --> Widgets
    Services -.->|Gemini API| GS
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [**GEMINI_INTEGRATION.md**](./GEMINI_INTEGRATION.md) | Full AI workflow, prompts, JSON schema |
| [**ANIMATION_SYSTEM.md**](./ANIMATION_SYSTEM.md) | Rendering pipeline, timer sync, element types |

---

## 🏆 Hackathon Submission

> **Built for the Gemini AI Hackathon**

### Innovation Highlights

1. **Text → Animated Graphics**: Gemini generates structured JSON, not just text/images
2. **Timer-Synced Animations**: The `progress` animation type creates live session feedback
3. **Iterative Refinement**: Users improve animations conversationally
4. **Infinite Creativity**: Any scene imaginable becomes a focus companion

---

<div align="center">

### Made with ❤️ and Gemini AI

**[⬆ Back to Top](#-stickman-productivity)**

</div>
