# iOS App Visual Direction v1

## Purpose

This document defines the recommended icon direction, visual language, color strategy, typography behavior, and UI style rules for the iOS app.

The goal is to lock a clear design direction before building production screens.

## Visual Positioning

The app should feel like:

- precise
- premium
- modern
- photography-tool oriented

The app should not feel like:

- a chatbot
- a generic AI demo
- a flashy neon utility
- a templated purple startup product

## Recommended Direction

### Direction Name

`Bright Precision`

### Why This Direction

- works globally
- looks trustworthy in App Store screenshots
- fits portrait editing
- supports multiple languages well
- keeps the photo as the hero

## Shell vs Canvas Strategy

Use two visual layers:

- app shell: light and premium
- editor canvas: dark and neutral

Why:

- bright shell improves readability and trust
- dark canvas makes cutout edges easier to judge

## Color System

Recommended base palette:

- Background Warm: `#F6F2EB`
- Surface Warm: `#FFF9F2`
- Ink Primary: `#171412`
- Ink Secondary: `#5B5149`
- Border Soft: `#D9CEC2`
- Canvas Dark: `#0C0C0D`
- Accent Primary: `#FF7A59`
- Accent Deep: `#E45A3D`
- Success Soft: `#2E8B57`

Usage rules:

- accent only for main actions
- avoid too many saturated colors
- preview tools should not compete with the image

## Typography Direction

Use a clean modern sans with strong readability.

Rules:

- short titles
- compact labels
- avoid decorative headlines
- prioritize localization resilience

Hierarchy:

- Hero Title
- Section Title
- Tool Label
- Helper Text
- Fine Meta

## Layout Direction

### General Layout

- large top preview area
- bottom floating tool tray
- generous corner radii
- soft surface elevation

### Spacing

- spacious outer margins
- compact control groups
- clear visual separation between image and tools

## Component Style Rules

### Primary Button

- filled accent gradient or solid accent
- rounded pill or rounded rectangle
- strong contrast text

### Secondary Button

- soft neutral surface
- subtle border

### Segmented Controls

- high legibility
- active state should be obvious
- labels must stay readable in all locales

### Slider

- thick enough for thumb interaction
- show current level text
- avoid tiny precision-only controls

### Cards

- soft warm surfaces
- subtle shadow
- not glassmorphism-heavy

## Editor UI Style

### Preview

- black or near-black canvas
- subject centered
- generous breathing room
- pinch zoom supported

### Bottom Tool Area

Recommended sections:

- Shape
- Color
- Background
- Clarity
- Advanced

Interaction rules:

- one panel open at a time
- changes should feel immediate
- animated transitions should be short and purposeful

## Progress UI Style

Progress must be visually prominent.

Recommended treatment:

- large numeric percentage
- bright accent progress fill
- short stage label
- compact helper text

Avoid:

- tiny spinner-only progress
- vague "AI working..." copy

## Icon Direction

## Recommended Icon Concept

### Concept Name

`Cutout Plate`

### Core Idea

A portrait silhouette partially separated from a background plate, with a precise clean edge highlight.

### Visual Ingredients

- head-and-shoulder silhouette
- cut edge or lifted layer
- circular framing cue
- subtle contrast between foreground and plate

### Why This Works

- immediately communicates portrait editing
- scales well at small icon sizes
- feels like a tool, not a toy

## Alternative Concepts

### Option B: Precision Ring

- face silhouette inside a circular crop ring
- more minimal
- cleaner but less distinctive

### Option C: Split Portrait

- one side solid portrait
- one side transparent checker cue or plate separation
- more explicitly about cutout, but easier to overcomplicate

## Avoid In Icon

- magic wand
- sparkles everywhere
- robot faces
- camera lens clichés
- photoreal skin or hair detail
- too many tiny details

## App Store Screenshot Direction

Screenshots should show:

1. quick photo selection
2. AI cutout in progress
3. clean editing interface
4. export options
5. Pro quality positioning

Tone:

- clean
- premium
- confidence-building
- benefit-first

## Motion Direction

Recommended:

- smooth result reveal after processing
- subtle panel slide-up
- clean state transitions

Avoid:

- bouncing controls
- over-animated gradients
- decorative motion that slows editing

## Accessibility Rules

- controls must meet contrast targets
- previews must remain readable with large text enabled
- avoid color-only state indicators
- controls must stay reachable one-handed

## Multi-Language Visual Rules

- never rely on tight fixed-width labels
- allow buttons to grow for longer text
- avoid text inside illustrations
- titles should wrap gracefully when needed

## Locked Recommendations

- choose `Bright Precision` as the visual direction
- choose `Cutout Plate` as the primary icon concept
- use a bright premium shell with a dark preview canvas
- use one strong coral accent instead of purple AI styling
- keep the interface tool-like and globally legible
