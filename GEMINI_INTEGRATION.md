<div align="center">

# 🤖 Gemini AI Integration

### *The Brain Behind the Magic*

**How we transform natural language into living, breathing animations**

</div>

---

## 🎯 Overview

Stickman Productivity uses **Google Gemini AI** to convert plain English descriptions into fully animated vector graphics. This isn't image generation—it's **structured data generation** that powers real-time animations synchronized with your focus timer.

```mermaid
graph LR
    A["🗣️ Natural Language"] --> B["🤖 Gemini AI"]
    B --> C["📄 Structured JSON"]
    C --> D["🎨 Canvas Renderer"]
    D --> E["✨ Animated Scene"]
```

---

## 🏗️ Architecture

```mermaid
graph TB
    subgraph User [User Interface]
        W1[Step 1: Action]
        W2[Step 2: Environment]
        W3[Step 3: Progress]
        W4[Step 4: Style]
    end
    
    subgraph Provider [Animation Creator Provider]
        ST[State Management]
        VC[Validation & Coordination]
    end
    
    subgraph Gemini [Gemini Service]
        PM[Prompt Builder]
        API[API Call]
        JP[JSON Parser]
        EH[Error Handler]
    end
    
    subgraph Renderer [Animation System]
        CFG[AIAnimationConfig]
        WDG[AIAnimationWidget]
        CVS[CustomPainter Canvas]
    end
    
    W1 --> W2 --> W3 --> W4
    W4 --> ST
    ST --> PM
    PM --> API
    API --> JP
    JP --> CFG
    CFG --> WDG
    WDG --> CVS
    
    API -.->|Error| EH
    EH -.->|Retry| ST
```

---

## 📝 The Wizard Flow

### Step-by-Step User Journey

```mermaid
graph TD
    subgraph Describe [1. Describe]
        A1[Enter Action] --> A2[Choose Environment]
        A2 --> A3[Define Progress]
        A3 --> A4[Select Style]
    end
    
    subgraph Generate [2. Generate]
        B1[AI Processes Request] --> B2[JSON Generated]
        B2 --> B3[Animation Renders]
    end
    
    subgraph Refine [3. Refine]
        C1[Preview Animation] --> C2{Looks Good?}
        C2 -->|No| C3[Request Changes]
        C3 --> B1
        C2 -->|Yes| C4[Final Save]
    end
    
    A4 --> B1
```

| Step | Question | Example Input |
|------|----------|---------------|
| **1. Action** | *What's happening?* | "A stickman painting on a canvas" |
| **2. Environment** | *Where is it?* | "Art studio with easel" |
| **3. Progress** | *How does it change?* | "Painting gets more complete as timer runs" |
| **4. Style** | *Visual aesthetic?* | "Minimalist, warm colors, playful" |

---

## 🎯 The Prompts

### Generation Prompt

This is the exact prompt sent to Gemini when creating a new animation:

```
You are a Vector Graphics Generator. Create a JSON description of a scene 
using geometric primitives (circles, lines, rects).

USER REQUEST:
Action: "{action}"
Environment: "{environment}"
Progress/Interaction: "{progress}"
Style: "{style}"

INSTRUCTIONS:
1. Deconstruct the scene into simple shapes (lines for stickfigures, 
   circles for heads/suns, rects for buildings/ground).
2. Coordinates are normalized (0.0 to 1.0). Top-left is (0,0). 
   Bottom-right is (1,1).
3. Ground level is usually around Y=0.8.
4. ANIMATION: Use the "animations" array to make things move.
   - "type": "sine" (for waving/breathing)
   - "type": "linear" (for moving across screen)
   - "type": "progress" (CRITICAL: Use this for long-term changes 
     aligned with the timer)
   - "property": Which value to animate (e.g., "y1", "cx", "rotation", "h")
   - "magnitude": Amount to change. Use NEGATIVE for shrinking.

JSON STRUCTURE (Return ONLY this):
{
  "backgroundColor": "#1E1E1E",
  "elements": [
    {
      "id": "item_1",
      "type": "circle",
      "color": "#FFFFFF",
      "strokeWidth": 2.0,
      "filled": false,
      "properties": {
        "cx": 0.5, "cy": 0.5, "r": 0.1
      },
      "animations": [
        {
          "property": "cx",
          "type": "sine",
          "speed": 1.0,
          "magnitude": 0.1
        }
      ]
    }
  ]
}

Create a COMPLEX and DETAILED scene. Use 10-20 elements if needed.
```

### Refinement Prompt

When users want to modify an existing animation:

```
You are a Vector Graphics Generator. Modify the existing JSON scene 
based on the user's instructions.

CURRENT JSON:
{current animation JSON}

USER INSTRUCTIONS:
"{user's refinement request}"

TASKS:
1. Parse the Current JSON.
2. Apply the requested changes.
3. Keep the rest intact unless asked to change it.
4. If adding new elements, use standard primitives with 
   normalized coordinates (0.0-1.0).

RETURN FORMAT:
Return ONLY the updated JSON structure.
```

---

## 📊 JSON Schema

```mermaid
classDiagram
    class AIAnimationConfig {
        +String backgroundColor
        +List elements
    }
    
    class AnimationElement {
        +String id
        +String type
        +String color
        +List animations
    }
    
    class ElementAnimation {
        +String property
        +String type
        +double speed
        +double magnitude
    }
    
    AIAnimationConfig "1" --> "*" AnimationElement
    AnimationElement "1" --> "*" ElementAnimation
```

### Animation Types

| Type | Behavior | Use Case |
|------|----------|----------|
| `sine` | Smooth oscillation | Breathing, waving, bobbing |
| `linear` | Constant movement | Walking, scrolling |
| `progress` | **Synced to timer 0→1** | Growing, building, filling |
| `pulse` | Rhythmic scaling | Heartbeat, emphasis |

---

## 🔄 Refinement Loop

```mermaid
graph TD
    A[Animation Generated] --> B[Preview]
    B --> C{Looks Good?}
    C -->|No| D[Refine]
    D --> E[User: 'Make the sun yellow']
    E --> F[Gemini: Updates JSON]
    F --> B
    C -->|Yes| G[Save to Library]
```

### Example Refinements

| User Says | Gemini Does |
|-----------|-------------|
| *"Make the sun yellow"* | Updates sun element's `color` to `#FFD700` |
| *"Add clouds"* | Inserts new circle elements with offset positions |
| *"Make him walk faster"* | Increases `speed` on leg animation objects |
| *"Remove the tree"* | Deletes tree-related elements from array |

---

## ⚠️ Error Handling

```mermaid
graph TD
    API[API Call] --> R{Response}
    R -->|Success| PARSE[Parse JSON]
    R -->|Error| CLASSIFY{Classify Error}
    
    CLASSIFY -->|429| RATE[Rate Limit: Wait]
    CLASSIFY -->|503| BUSY[Model Busy: Retry]
    CLASSIFY -->|401| KEY[Invalid Key: Check Settings]
    CLASSIFY -->|Network| NET[No Internet]
    CLASSIFY -->|Safety| SAFE[Content Blocked]
    
    RATE --> MSG[Show User Message]
    BUSY --> MSG
    KEY --> MSG
    NET --> MSG
    SAFE --> MSG
    
    PARSE --> RENDER[Render Animation]
```

---

## ⚙️ Model Configuration

### Supported Models

| Model | Speed | Quality | Best For |
|-------|-------|---------|----------|
| `gemini-2.0-flash` | ⚡⚡⚡ | ★★★★ | Default choice |
| `gemini-2.0-flash-lite` | ⚡⚡⚡⚡ | ★★★ | Quick iterations |
| `gemini-1.5-pro` | ⚡⚡ | ★★★★★ | Complex scenes |
| `gemini-1.5-flash` | ⚡⚡⚡ | ★★★★ | Balanced |

### Setup

1. Get API key → [Google AI Studio](https://aistudio.google.com/)
2. App Settings → Enter key
3. Select model from dropdown

---

## 🏆 Why This Is Innovative

```mermaid
graph TD
    Root((Gemini Integration)) --> A[Structured Output]
    Root --> B[Animation Sync]
    Root --> C[Iterative Design]
    Root --> D[Infinite Creativity]
    
    A --> A1[Valid JSON]
    A --> A2[Parseable Data]
    
    B --> B1[Progress Type]
    B --> B2[Timer Aware]
    
    C --> C1[Conversational]
    C --> C2[Build on Previous]
    
    D --> D1[Natural Language]
    D --> D2[Any Scene]
```

---

<div align="center">

**[← Back to README](./README.md) • [Animation System →](./ANIMATION_SYSTEM.md)**

</div>
