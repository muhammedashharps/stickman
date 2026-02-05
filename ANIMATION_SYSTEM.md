<div align="center">

# 🎨 Animation System

### *The Engine That Brings Focus to Life*

**From code to canvas: how we render timer-synchronized animations**

</div>

---

## 🌐 Overview

The animation system supports two types of visual companions:

| Type | Source | Customization |
|------|--------|---------------|
| **Preset** | Hand-coded CustomPainter widgets | 6 fixed animations |
| **AI-Generated** | Gemini JSON → dynamic renderer | Unlimited possibilities |

Both share a critical feature: **progress synchronization** with the focus timer.

---

## 🔄 The Render Loop

```mermaid
flowchart LR
    subgraph Timer["⏱️ Timer Provider"]
        TP[TimerProvider]
        PROG[progress: 0.0 → 1.0]
    end
    
    subgraph Animation["🎨 Animation Widget"]
        AW[AnimationController]
        CP[CustomPainter]
        CVS[Canvas]
    end
    
    TP --> |remainingTime / totalDuration| PROG
    PROG --> |Rebuild trigger| AW
    AW --> |animValue + progress| CP
    CP --> |Draw calls| CVS
    CVS --> |60 FPS| DISPLAY[📱 Display]
```

---

## 🎬 Preset Animations

### Widget Hierarchy

```mermaid
classDiagram
    class StatefulWidget {
        +createState()
    }
    
    class AnimationWidgetState {
        +AnimationController _controller
        +progress: double
        +isRunning: bool
        +build() Widget
    }
    
    class CustomPainter {
        +paint(Canvas, Size)
        +shouldRepaint() bool
    }
    
    StatefulWidget <|-- PlantGrowthWidget
    StatefulWidget <|-- MountainClimbWidget
    StatefulWidget <|-- BulbLadderWidget
    StatefulWidget <|-- BridgeBuilderWidget
    StatefulWidget <|-- CliffClimbWidget
    StatefulWidget <|-- WaterTankWidget
    
    PlantGrowthWidget --> AnimationWidgetState
    AnimationWidgetState --> CustomPainter
```

### The Six Companions

```mermaid
timeline
    title Animation Progress Timeline
    
    0% : 🌱 Seed planted
       : ⛰️ At base
       : 💡 All dark
       : 🌉 Empty gap
       : 🧗 Ground level
       : 💧 Tank empty
    
    25% : 🌱 Sprout appears
        : ⛰️ Quarter climb
        : 💡 1 bulb lit
        : 🌉 2 planks
        : 🧗 First ledge
        : 💧 25% filled
    
    50% : 🌱 Small plant
        : ⛰️ Halfway up
        : 💡 3 bulbs lit
        : 🌉 5 planks
        : 🧗 Mid cliff
        : 💧 50% filled
    
    75% : 🌱 Tall plant
        : ⛰️ Near summit
        : 💡 4 bulbs lit
        : 🌉 8 planks
        : 🧗 Almost top
        : 💧 75% filled
    
    100% : 🌱 Flower blooms!
         : ⛰️ Victory flag!
         : 💡 All lit!
         : 🌉 Bridge complete!
         : 🧗 Summit reached!
         : 💧 Tank full!
```

---

## 🤖 AI-Generated Animations

### Data Flow

```mermaid
flowchart TD
    JSON["📄 Gemini JSON Response"] --> PARSE["Parse via fromJson()"]
    
    PARSE --> CONFIG["AIAnimationConfig"]
    
    CONFIG --> ELEMENTS["List of Elements"]
    
    ELEMENTS --> |Circle| C["CircleElement<br/>cx, cy, r"]
    ELEMENTS --> |Line| L["LineElement<br/>x1, y1, x2, y2"]
    ELEMENTS --> |Rect| R["RectElement<br/>x, y, w, h"]
    
    C --> ANIM["Animation Processing"]
    L --> ANIM
    R --> ANIM
    
    ANIM --> CANVAS["Canvas.draw*()"]
    CANVAS --> DISPLAY["📱 60 FPS Output"]
    
    style JSON fill:#e8f5e9
    style CONFIG fill:#e3f2fd
    style CANVAS fill:#fff3e0
```

### Element Types

| Type | Properties | Draw Method |
|------|------------|-------------|
| **Circle** | `cx`, `cy`, `r` | `canvas.drawCircle()` |
| **Line** | `x1`, `y1`, `x2`, `y2` | `canvas.drawLine()` |
| **Rect** | `x`, `y`, `w`, `h` | `canvas.drawRect()` |

### Coordinate System

```mermaid
graph TB
    subgraph Canvas["📐 Normalized Coordinates"]
        TL["(0,0)<br/>Top-Left"]
        TR["(1,0)<br/>Top-Right"]
        BL["(0,1)<br/>Bottom-Left"]
        BR["(1,1)<br/>Bottom-Right"]
        GND["Ground ≈ y: 0.8"]
    end
    
    TL --- TR
    TL --- BL
    TR --- BR
    BL --- BR
```

All coordinates are **normalized (0.0 to 1.0)** for device independence.

---

## 🎭 Animation Types

```mermaid
flowchart LR
    subgraph Types["Animation Types"]
        SINE["🌊 sine"]
        LINEAR["➡️ linear"]
        PROGRESS["📈 progress"]
        PULSE["💓 pulse"]
    end
    
    SINE --> |"sin(t) × magnitude"| OSC["Oscillation<br/>Waving, breathing"]
    LINEAR --> |"t × magnitude"| MOVE["Movement<br/>Walking, scrolling"]
    PROGRESS --> |"timerProgress × magnitude"| SYNC["Timer Sync<br/>Growing, building"]
    PULSE --> |"(sin(t)+1)/2 × magnitude"| SCALE["Scaling<br/>Heartbeat, emphasis"]
```

### The Magic of `progress` Type

This is what makes animations **session-aware**:

```mermaid
sequenceDiagram
    participant T as ⏱️ Timer
    participant P as 📊 Progress
    participant A as 🎨 Animation
    participant E as 📐 Element
    
    T->>P: remaining = 15:00 / 25:00
    P->>A: progress = 0.4 (40% done)
    A->>E: Apply progress animations
    
    Note over E: Stem height = 0 + (0.4 × 0.3)<br/>= 0.12 (12% of canvas)
    
    E->>A: Updated properties
    A->>T: Visual feedback rendered
```

---

## 🖌️ Rendering Pipeline

### Step-by-Step Canvas Drawing

```mermaid
flowchart TD
    START[paint() called] --> BG["Draw Background<br/>canvas.drawRect(bgColor)"]
    
    BG --> LOOP["For each element in config.elements"]
    
    LOOP --> CALC["Calculate animated values"]
    
    CALC --> TYPE{Element Type?}
    
    TYPE --> |Circle| CIRC["drawCircle(<br/>  Offset(cx, cy),<br/>  radius,<br/>  paint<br/>)"]
    
    TYPE --> |Line| LINE["drawLine(<br/>  Offset(x1, y1),<br/>  Offset(x2, y2),<br/>  paint<br/>)"]
    
    TYPE --> |Rect| RECT["drawRect(<br/>  Rect.fromLTWH(x, y, w, h),<br/>  paint<br/>)"]
    
    CIRC --> NEXT[Next element]
    LINE --> NEXT
    RECT --> NEXT
    
    NEXT --> |More elements| LOOP
    NEXT --> |Done| END[Frame complete]
```

### Animation Value Calculation

```dart
double _animate(element, property, baseValue) {
  for (anim in element.animations) {
    if (anim.property == property) {
      switch (anim.type) {
        case 'sine':
          return base + sin(animValue × 2π × speed) × magnitude;
        case 'linear':
          return base + (animValue × speed % 1) × magnitude;
        case 'progress':
          return base + timerProgress × magnitude;  // 🎯 KEY!
        case 'pulse':
          return base + ((sin(animValue × 2π × speed) + 1) / 2) × magnitude;
      }
    }
  }
  return baseValue;
}
```

---

## ⏱️ Timer Synchronization

```mermaid
stateDiagram-v2
    [*] --> Idle: App opened
    
    Idle --> Running: Start pressed
    Running --> Running: Every 500ms tick
    
    state Running {
        [*] --> Calculate
        Calculate --> Notify
        Notify --> Rebuild
        Rebuild --> Paint
        Paint --> [*]
        
        note right of Calculate
            elapsed = now - startTime
            remaining = pausedRemaining - elapsed
            progress = 1 - (remaining / total)
        end note
    }
    
    Running --> Paused: Pause pressed
    Paused --> Running: Resume pressed
    Running --> Complete: remaining ≤ 0
    
    Complete --> [*]: Celebration + Sound
```

### Background Persistence

The timer uses **DateTime-based calculation**, not tick counting:

```mermaid
flowchart LR
    subgraph Before["❌ Old Approach"]
        TICK["Timer.periodic(1s)"]
        COUNT["remaining--"]
        PROBLEM["Stops in background!"]
    end
    
    subgraph After["✅ Current Approach"]
        START["Store startTime"]
        CALC["remaining = pausedRemaining - (now - startTime)"]
        WORKS["Works even after hours in background"]
    end
```

---

## 📁 File Reference

| File | Responsibility |
|------|----------------|
| `animation_widgets.dart` | 5 preset animations (Mountain, Bulb, Bridge, Cliff, Water) |
| `plant_growth_widget.dart` | Plant growth animation (most complex) |
| `ai_animation_widget.dart` | AI animation renderer with CustomPainter |
| `ai_animation_config.dart` | JSON parsing and data models |
| `timer_provider.dart` | Progress calculation and background handling |

---

## 🎯 Key Insights

```mermaid
mindmap
  root((Animation<br/>System))
    Dual Sources
      Preset widgets
      AI-generated JSON
    Unified Interface
      progress prop
      isRunning prop
      Same parent widget
    Timer Sync
      progress type
      Real-time mapping
      Background safe
    Canvas Rendering
      60 FPS
      CustomPainter
      Device independent
```

---

<div align="center">

**[← Gemini Integration](./GEMINI_INTEGRATION.md) • [Back to README →](./README.md)**

</div>
