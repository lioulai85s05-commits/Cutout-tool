# iOS UI Options v2

The app is now a general object pick-and-cut product.

So the UI must optimize for:

- fast image upload
- fast recognition feedback
- visible multi-object selection
- clean export path

This document gives three UI directions to choose from.

## 1. Free Reference Sources

### Apple Human Interface Guidelines

Why used:

- this keeps the app native and globally legible

References:

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)

### Page Flows

Why used:

- useful for studying real product flows and common screen structure

Reference:

- [Page Flows](https://pageflows.com/)

### Pttrns

Why used:

- useful for fast pattern comparison across mobile layouts

Reference:

- [Pttrns](https://www.pttrns.com/)

### Untitled UI

Why used:

- useful as a reference for modern surface treatment, hierarchy, spacing, and control polish

Reference:

- [Untitled UI Free Icons](https://www.untitledui.com/free-icons)

## 2. Shared UX Structure

All three options keep the same logic:

1. Upload
2. Recognize
3. Choose object
4. Execute cutout
5. Save

Main screens:

- Home
- Recognition Overlay
- Selected Object Preview
- Export
- Settings / Unlock

## 3. Option A: Studio Light

### Positioning

- safest global direction
- looks polished and App Store friendly
- easiest to localize

### Visual idea

- warm light shell
- dark recognition canvas
- coral accent
- soft cards

### Home

- large upload button
- recent items in horizontal cards
- short explanation chips

### Recognition screen

- full image preview
- colored outlines over objects
- bottom sheet saying "Tap an object to continue"

### Preview screen

- large dark canvas
- selected object centered
- bottom toolbar for background, shape, format

### Export screen

- card list for format
- one primary save action

### Why choose it

- broadest appeal
- best for first launch
- easy to market globally

## 4. Option B: Precision Dark

### Positioning

- more professional
- more "editing tool" than "consumer utility"

### Visual idea

- dark shell
- thin bright outlines
- restrained coral or cyan signal color
- less card-heavy, more panel-based

### Home

- darker gallery surface
- stronger focus on recent work

### Recognition screen

- object outlines are the hero
- image dominates almost the whole screen

### Preview screen

- feels closer to a mini pro editor
- controls sit in a tighter bottom dock

### Export screen

- denser and more tool-like

### Why choose it

- strongest "professional" feel
- best if you want the product to feel more serious than cute

### Tradeoff

- slightly riskier for casual users
- screenshots can feel heavier if not handled carefully

## 5. Option C: Gallery Utility

### Positioning

- more approachable
- more consumer-friendly
- optimized for quick sharing and repeated use

### Visual idea

- brighter overall shell
- stronger color system
- bigger cards
- more obvious guidance text

### Home

- example gallery is more visible
- stronger onboarding cues

### Recognition screen

- each detected object can show a numbered chip
- easier for beginners to understand

### Preview screen

- bigger labels
- chunkier controls

### Export screen

- larger format buttons
- more emphasis on save-to-photos

### Why choose it

- lowest learning curve
- best for broad casual audience

### Tradeoff

- can feel less premium if overdone

## 6. Recommendation

My recommendation is:

- `Option A: Studio Light`

Why:

- strongest balance of premium feel, clarity, and App Store friendliness
- easiest to combine with the icon direction I prefer
- keeps the selected object visually central without making the whole app dark-first

Second choice:

- `Option B: Precision Dark`

If we want a more pro editing identity later, this is the fallback direction worth evolving into.

## 7. What I Would Lock Right Now

If you want the fastest route to a coherent product:

- Icon: `Option A: Signal Plate`
- UI: `Option A: Studio Light`

That gives us the cleanest unified visual system for the next implementation stage.
