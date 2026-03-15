# App Store Connect Submission Checklist

## Required URLs

- Landing page:
  `https://lioulai85s05-commits.github.io/Cutout-tool/`
- Support URL:
  `https://lioulai85s05-commits.github.io/Cutout-tool/support.html`
- Privacy Policy URL:
  `https://lioulai85s05-commits.github.io/Cutout-tool/privacy.html`

## App Information

- Bundle ID used by the current build:
  `com.snake.PortraitCutout`
- SKU:
  `cutout-magic-ios-001`
- App name:
  localized in `APP_STORE_CONNECT_METADATA_LOCALIZED.md`
- Subtitle:
  localized in `APP_STORE_CONNECT_METADATA_LOCALIZED.md`
- Copyright:
  `2026 Yahaha Tech, Rodan`
- Primary category:
  `Photo & Video`
- Secondary category:
  `Productivity`
- Content Rights:
  `Yes, the app only uses developer-owned assets and user-selected photos.`
- License Agreement:
  `Use Apple Standard EULA`

## Pricing

- App price:
  `Free`
- Monetization:
  `Non-Consumable In-App Purchase`
- IAP base price:
  `US $3.99`

## In-App Purchase Setup

- Product type:
  `Non-Consumable`
- Product ID currently used in code:
  `com.snake.PortraitCutout.lifetime`
- Important:
  create this product in App Store Connect before testing unlock,
  otherwise the app will show the fallback price text but StoreKit will not load a real product
- Localized display names and descriptions:
  see `APP_STORE_CONNECT_METADATA_LOCALIZED.md`

## Review Notes

Use this for App Review:

`Cutout Magic uses on-device image processing to detect foreground objects and lets users preview edits before export. The free tier supports image import, object recognition, and preview. Saving to Photos, sharing, high-resolution export, and premium extraction tools are unlocked through a one-time non-consumable purchase. No account creation is required.`

## Age Rating Recommendation

- Recommended age rating:
  `4+`
- Suggested questionnaire direction:
  `No violence, no gambling, no sexual content, no unrestricted web access, no user-generated content, no advertising, no medical content.`

## Export Compliance Recommendation

- Recommended answer:
  `Uses only encryption provided within the Apple operating system.`
- Apple reference:
  `No additional export compliance documentation is required when encryption is limited to that within the Apple operating system.`

## App Review Contact

- Contact name: `Rodan`
- Contact email: `luodan91918@gamil.com`
- Contact phone: `YOUR_REVIEW_PHONE`

## App Privacy Recommendation

Recommended answer based on the current codebase:

- If you do not add analytics, ad SDKs, crash reporters, or your own backend before release:
  `No, this app does not collect data from this app.`

Detailed reference:

- `APP_STORE_CONNECT_PRIVACY_ANSWERS.md`

Recheck this before submission if you later add:

- analytics
- crash reporting
- advertising SDKs
- cloud processing
- user accounts
- support chat or feedback forms

## Screenshots

- Required:
  upload localized screenshots for iPhone display sizes required by App Store Connect
- Suggested caption direction:
  use short lines focused on
  - select photo
  - detect objects
  - tap to choose
  - adjust frame
  - unlock export

## Unlock Flow Check Before Submission

Make sure all of the following are true:

1. The uploaded build bundle id is still `com.snake.PortraitCutout`.
2. The IAP in App Store Connect uses product id `com.snake.PortraitCutout.lifetime`.
3. The IAP price is set to `US $3.99` base territory pricing.
4. The IAP is attached to the app and available for review.
5. Support URL and Privacy Policy URL are reachable after GitHub Pages is published.
