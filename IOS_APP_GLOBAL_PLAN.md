# iOS Global App Plan

## 1. Product Direction

- Product type: portrait cutout app for global App Store release
- Core promise: fast, accurate portrait background removal with clean edges, simple editing, and export-ready results
- Positioning: a professional photo utility, not a chat-style AI product
- Platform strategy:
  - iPhone first
  - iPad compatible
  - offline-first for the main cutout flow

## 2. Recommended AI Strategy

### 2.1 Core Principle

- Use local visual AI first
- Keep cloud AI optional and delayed
- Build the app around privacy, low latency, and predictable cost

### 2.2 Recommended Architecture

Layer 1: Local person segmentation
- Use Apple Vision person segmentation as the default baseline
- Purpose:
  - stable offline experience
  - fast first result
  - lower review and privacy risk

Layer 2: Advanced segmentation engine
- Reserve a replaceable engine interface for higher-quality models later
- Candidate directions:
  - Core ML portrait segmentation model
  - custom hair-detail / veil-detail / clothing-detail segmentation model
- Purpose:
  - improve hair, veil, bouquet, hand, and low-light scenes

Layer 3: Edge refinement and rendering
- matte cleanup
- edge decontamination
- transparent export
- circle / square crop rendering

### 2.3 What Not To Do First

- Do not make cloud AI the default path in v1
- Do not use activation-code licensing on iOS
- Do not put niche formats like PLT into the first public release path

## 3. Business Model

### 3.1 Recommended Monetization

- Free download
- limited free exports or basic free quality
- Pro unlock through StoreKit 2

### 3.2 Suggested Commercial Structure

- Free
  - preview
  - limited exports
  - basic resolution
- Pro Monthly
  - unlimited exports
  - high-resolution export
  - advanced cutout mode
- Pro Yearly
  - best value
- Lifetime
  - optional, only if price strategy supports it

### 3.3 Why Not Activation Codes

- App Store flow is built around Apple purchase systems
- activation code workflows increase friction
- global users expect subscriptions or one-time purchase, not manual codes

## 4. Information Architecture

Recommended top-level structure:

1. Home
2. Editor
3. Export
4. Settings

### 4.1 Home

Purpose:
- start new cutout fast
- show recent items
- explain value with minimal friction

Modules:
- hero area
- select photo button
- recent projects
- sample demos
- Pro entry point

### 4.2 Editor

Purpose:
- preview result
- adjust output quickly

Modules:
- large preview canvas
- before / after switch
- mode bar
- shape selector
- color selector
- background selector
- clarity slider
- advanced AI mode entry

### 4.3 Export

Purpose:
- save, share, and choose output

Modules:
- export format
- resolution
- transparent / black / white / custom background
- save to Photos
- share sheet

### 4.4 Settings

Purpose:
- account-free app controls
- language and policy

Modules:
- subscription status
- restore purchase
- language
- privacy
- help
- contact support

## 5. Interaction Logic

### 5.1 Primary User Flow

1. Open app
2. Tap "Select Photo"
3. Pick image
4. App starts AI cutout immediately
5. Show progress state
6. Enter editor with result
7. Adjust shape / color / clarity / background
8. Tap export
9. Save or share

### 5.2 First-Run Experience

Goal:
- user sees a good result within three taps

Recommended first-run flow:
- one lightweight onboarding page or no onboarding
- ask for photo access only when needed
- run AI immediately after image selection

### 5.3 Progress Experience

Show clear stage-based progress:
- loading image
- detecting subject
- segmenting portrait
- refining hair and clothing edges
- rendering result
- preparing export

Rules:
- progress bar must be visually prominent
- progress text must be short and localized
- avoid fake waiting animations when no work is happening

### 5.4 Error Handling

Handle these cases explicitly:
- no face or subject detected
- low-light image quality too poor
- processing timeout
- export failure
- photo permission denied

Fallback:
- offer retry
- offer "Basic Mode"
- offer "Advanced AI Mode"

## 6. Screen Plan

### Screen A: Home

Key actions:
- Select Photo
- Open Recent
- Upgrade to Pro

### Screen B: Processing

Key content:
- progress bar
- stage label
- original thumbnail

### Screen C: Editor

Key content:
- result preview
- compare toggle
- segmented controls
- bottom tool tray

### Screen D: Export

Key content:
- format
- quality
- output size
- save / share buttons

### Screen E: Pro

Key content:
- feature comparison
- pricing cards
- restore purchase

### Screen F: Settings

Key content:
- language
- privacy
- support
- version

## 7. UI Direction

### 7.1 Visual Tone

- modern
- precise
- premium
- photography-tool feel

Avoid:
- neon AI style
- chatbot feel
- overly playful gradients
- generic purple AI branding

### 7.2 Recommended Design Language

- bright interface first
- dark mode supported later or in parallel
- strong canvas focus
- restrained color palette
- warm neutral surfaces
- one strong accent color for primary action

### 7.3 Typography

- clean, modern, readable
- avoid over-styled decorative type
- prioritize localization-safe typography

### 7.4 Layout

- large preview area
- bottom action zones reachable by thumb
- minimize deep settings during editing

### 7.5 Motion

- subtle reveal animation after AI completes
- slider feedback should feel direct
- avoid decorative motion that slows the app

## 8. Icon Direction

### 8.1 Recommended Icon Concept

Concept:
- portrait silhouette plus cutout edge
- layered image plate / transparency cue
- precise tool feeling rather than magic effect

Visual elements to explore:
- face contour
- circular crop ring
- separated foreground plate
- clean edge highlight

### 8.2 Avoid

- wand plus sparkles
- generic robot face
- over-detailed photorealistic icon
- cheap template AI look

### 8.3 Icon Goal

- readable at small size
- globally understandable
- clearly about portrait editing

## 9. Localization Strategy

### 9.1 Languages For Early Release

- English
- Simplified Chinese
- Traditional Chinese
- Japanese
- Korean
- Spanish

### 9.2 Technical Rules

- use String Catalog from day one
- no text embedded in images
- avoid layout assumptions tied to one language
- keep labels concise

### 9.3 Product Writing Rules

- short verbs
- simple nouns
- no culture-specific slang
- no overloaded AI wording

## 10. Technical Architecture

Recommended project modules:

- App
- Features/Home
- Features/Editor
- Features/Export
- Features/Settings
- Core/Segmentation
- Core/Imaging
- Core/Localization
- Core/Billing
- Core/Storage
- DesignSystem

Recommended app stack:
- SwiftUI for interface
- Vision for baseline segmentation
- Core Image / Metal / vImage for rendering pipeline where needed
- StoreKit 2 for subscriptions
- PhotosUI for image picking
- String Catalog for localization

## 11. Release Phases

### Phase 1: Foundation

- clean project naming
- app architecture
- design system base
- localization setup
- StoreKit skeleton

### Phase 2: MVP

- Home
- photo picker
- local portrait segmentation
- progress view
- basic Editor
- PNG export

### Phase 3: Commercial Release Candidate

- Pro paywall
- restore purchases
- multi-language UI
- export improvements
- settings
- analytics-safe local event model

### Phase 4: Quality Upgrade

- advanced AI mode
- hair / veil / bouquet refinement
- performance tuning
- iPad polish
- App Store asset package

## 12. Decisions To Confirm Together

Before building the full app, we should align on:

1. Free vs Pro feature split
2. Whether PLT is in v1 or postponed
3. Icon direction: precise tool vs friendly consumer
4. UI direction: bright premium vs darker pro-editing style
5. Whether "Advanced AI Mode" is visible in v1 or hidden until later

## 13. My Recommendation

Best path:

1. Build iOS as a clean offline-first portrait cutout editor
2. Use Apple local vision segmentation first
3. Keep a replaceable high-precision AI engine interface
4. Ship global-language-ready UI from the beginning
5. Use StoreKit 2 instead of activation codes
6. Finalize interaction logic and visual language before large code implementation
