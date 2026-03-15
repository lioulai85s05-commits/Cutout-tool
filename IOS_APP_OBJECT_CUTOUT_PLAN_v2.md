# iOS Object Cutout App Plan v2

This document supersedes the earlier portrait-only plan.

The product is now positioned as a local-first object cutout app:

- upload one image
- detect multiple selectable objects
- show each instance with a different outline color
- let the user tap the object they want
- refine the selected object
- export in the chosen format

## 1. Product Repositioning

### New Product Type

- Not a portrait-only cutout app
- A general object pick-and-cut app
- Optimized for iPhone global release

### Core Promise

- fast local recognition
- simple tap-to-select interaction
- clean transparent exports
- low learning cost

### What The App Should Feel Like

- practical
- precise
- approachable
- reliable on-device utility

Not:

- a chat-style AI product
- a prompt-based tool
- a subscription-first app

## 2. AI Strategy

### 2.1 Do Not "Write A Model From Scratch"

The right move is not to train a new AI model from zero.

The right move is:

1. use Apple's built-in on-device vision stack first
2. build the app interaction around instance selection
3. leave room for a lightweight custom Core ML refinement model later

### 2.2 Recommended Local-First Stack

#### Stage A: Multi-object candidate detection

Use:

- `VNGenerateForegroundInstanceMaskRequest`

Purpose:

- detect multiple foreground instances in one image
- get separate instance regions for selectable objects
- keep app size under control because the heavy vision stack is already part of iOS

This is the best first implementation for your desired interaction:

- upload
- recognize
- choose object
- execute
- save

#### Stage B: Selected object refinement

After the user taps a target instance:

- refine only the selected object
- clean edge contamination
- optionally expand into fine boundaries such as hair, bouquet, clothing edges, glass edges, pet fur

Initial refinement path:

- local mask cleanup
- matte smoothing
- edge decontamination

Future optional refinement path:

- lightweight Core ML detail model

#### Stage C: Export rendering

Apply:

- transparent output
- white / black / custom background
- shape crop
- format conversion

## 3. App Size And Performance

## 3.1 If We Use Apple's Built-in Vision AI First

This is the most important point:

- app size stays much smaller than bundling a large third-party segmentation model

Practical implication:

- the binary is mostly your UI, assets, and app code
- the app does not need to ship a giant first-party model package in v1

My recommendation:

- v1 should rely on Apple's built-in object instance masking
- do not bundle a heavy all-object model in the first public build

### Estimated size impact

Expected outcome if we stay on built-in Vision first:

- no major model-size explosion
- app size should remain in a normal utility-app range

If later we add a custom Core ML refinement model:

- add roughly `25MB` to `60MB` for a lightweight quantized model
- more if we chase higher recall on many object types

Conclusion:

- `v1 size risk is low if we stay on Apple Vision first`
- `size risk becomes medium only when we add our own model bundle`

## 3.2 Will iPhone Run It Smoothly?

Yes, if we keep the workflow two-stage.

Recommended execution model:

1. quick multi-instance scan on the full image
2. user taps one instance
3. high-quality refinement only on that selected instance

That is much better than:

- trying to run a very heavy high-precision segmentation over every object in the whole image at once

### Performance expectation

For modern iPhones:

- first-pass detection should feel quick
- selected-object refinement should still feel acceptable

Practical target:

- newer devices: near-immediate outline discovery
- older supported devices: a short but understandable wait with visible progress

Recommended device posture:

- support `iOS 17+`
- target a good experience on `iPhone 12 and later`
- allow older supported devices, but lower internal processing resolution when needed

Conclusion:

- `yes, it can run smoothly if we use built-in Vision and a staged pipeline`
- `no, we should not start with a huge universal segmentation model baked into the app`

## 4. Interaction Logic

This is the interaction I recommend and support.

### Primary flow

1. Upload image
2. Recognize objects
3. Show each detected instance with a different colored outline
4. User taps the desired object
5. Run selected-object cutout refinement
6. Show result preview
7. Save with chosen format

### Important UX rules

- recognition overlay must appear quickly
- selection must be direct tap, not complicated list picking
- user must be able to switch to another detected object without starting over
- save step must include format choice before final export

### Fallback UX we should include

- `Rescan`
- `Try another object`
- `Basic edge cleanup`
- `High precision cleanup`

Optional later:

- `Add missed object manually`
- `Erase background by brush`

## 5. Object Labels

For v1, object naming is optional.

The app does not need to know:

- "this is a chair"
- "this is a bouquet"
- "this is a handbag"

What it really needs is:

- separate selectable instances

So v1 can show:

- color-coded outlines
- simple labels like `Object 1`, `Object 2`, `Object 3`

If class names become reliable later, we can add:

- `Person`
- `Flower`
- `Bag`
- `Pet`

But naming is not required for the core app to work well.

## 6. Monetization

You said apps with no ongoing usage cost should use buyout.

I agree with the buyout direction.

### Recommended App Store structure

- free download
- limited free recognition / preview / export experience
- one-time unlock via non-consumable purchase

Why this is better than a paid-upfront app:

- users need to test recognition quality first
- conversion is usually better when the user can try before buying
- there is still no subscription

### Commercial structure

- Free:
  - upload and detect
  - preview object selection
  - limited exports
- Full Unlock:
  - unlimited exports
  - all formats
  - high precision refinement
  - future advanced selection tools

This is still a buyout model.

## 7. Recommended Formats

### v1 export formats

- PNG
- JPG

### Later formats

- HEIF if useful
- SVG only if we later build vector tracing
- PLT should stay out of the iOS core path for now

## 8. Product Risks

### Risk 1: Not every tiny background object will be detected

Mitigation:

- design around "foreground instances" first
- support reselection and manual rescue later

### Risk 2: Too much ambition makes the app heavy

Mitigation:

- built-in Vision first
- custom model later

### Risk 3: Users may expect Photoshop-grade perfection

Mitigation:

- clear app store positioning
- show before/after honestly
- provide optional high-precision mode later

## 9. Recommended Build Order

### Phase 1

- upload image
- run multi-instance foreground mask
- show colored outlines
- allow object tap selection
- cut selected object
- export PNG/JPG

### Phase 2

- better selected-object refinement
- stronger edge cleanup
- manual object correction

### Phase 3

- optional lightweight custom Core ML enhancement model
- better recall on difficult objects
- better small-object selection

## 10. Final Recommendation

This is the plan I recommend:

- move the product from portrait cutout to object cutout
- use Apple's built-in multi-instance foreground masking first
- keep the app local-first
- keep the base app light
- use a one-time unlock, not subscription
- build the UX around `upload -> recognize -> choose -> execute -> save`

That gives us:

- manageable app size
- strong iPhone performance
- clear product differentiation
- low user learning cost
