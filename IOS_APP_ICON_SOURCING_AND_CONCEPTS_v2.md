# iOS Icon Sourcing And Concepts v2

This document defines how we should source inspiration for the app icon without shipping a generic stock icon.

Rule:

- do not ship a raw third-party icon
- do not just recolor a stock icon
- use free reference libraries to extract shape language
- redraw a new app mark for our own product

## 1. Free Reference Sources Chosen

### A. Lucide

Why selected:

- clean stroke logic
- lightweight and scalable
- good for structure and silhouette reference

Reference:

- [Lucide](https://lucide.dev/)

Notes:

- site states the icon set is released under the ISC License

### B. Untitled UI Free Icons

Why selected:

- strong modern product feel
- neutral, premium UI icon language
- especially useful for app-shell and export controls

Reference:

- [Untitled UI Free Icons](https://www.untitledui.com/free-icons)

Notes:

- site states the assets can be used in personal and commercial projects

### C. SVG Repo

Why selected:

- useful for exploring broad cut/crop/object/shape metaphors
- good for quickly surveying motif directions

Reference:

- [SVG Repo Licensing](https://www.svgrepo.com/page/licensing/)

Notes:

- we still need to verify the license on each specific source asset before any direct reuse
- for the app icon, we should use SVG Repo as inspiration only, not as a final shipped logo source

## 2. Icon Strategy

The app is now a general object cutout tool, not a portrait-only tool.

So the icon should communicate:

- object selection
- precise edge extraction
- one item separated from the background

It should not communicate:

- only faces
- magic wands
- generic AI sparkles

## 3. Custom Concept Directions

I created three custom concept directions. These are original compositions informed by the source libraries above.

### Option A: Signal Plate

File:

- [icon_option_a_signal_plate.svg](/Volumes/GAME/打印机图片/iOS%20app/人像抠图器/Design/IconConcepts/icon_option_a_signal_plate.svg)

Idea:

- an object plate lifted from a dark background
- active selection ring and cut edge
- strongest balance between clarity and uniqueness

Influence sources:

- Lucide line clarity
- Untitled UI neutral geometry

Best for:

- broad consumer appeal
- easy recognition in the App Store grid

### Option B: Object Ring

File:

- [icon_option_b_object_ring.svg](/Volumes/GAME/打印机图片/iOS%20app/人像抠图器/Design/IconConcepts/icon_option_b_object_ring.svg)

Idea:

- scanning ring around a selected object
- feels precise and tool-like
- more minimal and premium

Influence sources:

- Lucide layout discipline
- Apple-style clean object emphasis

Best for:

- professional utility positioning
- cleaner visual identity

### Option C: Split Stage

File:

- [icon_option_c_split_stage.svg](/Volumes/GAME/打印机图片/iOS%20app/人像抠图器/Design/IconConcepts/icon_option_c_split_stage.svg)

Idea:

- the selected object breaks out of a plate
- strongest "before vs after" storytelling
- visually distinctive but slightly busier

Influence sources:

- SVG Repo metaphor survey
- Untitled UI interface geometry

Best for:

- obvious feature communication
- more expressive branding

## 4. Recommendation

My recommended direction is:

- `Option A: Signal Plate`

Reason:

- easiest to understand
- strongest at small icon sizes
- already feels like a real iOS utility icon
- can evolve into a premium final asset without redesigning the whole mark

## 5. Redraw Rules Before Final Shipping

Whichever option we choose:

- redraw as a fresh vector from scratch
- rebalance geometry for 1024x1024 app icon usage
- simplify tiny details
- test at 60px and 29px sizes
- avoid raw icon-library shapes surviving unchanged

## 6. Next Step

Choose one:

- A for safest commercial direction
- B for cleaner premium direction
- C for most feature-explicit direction
