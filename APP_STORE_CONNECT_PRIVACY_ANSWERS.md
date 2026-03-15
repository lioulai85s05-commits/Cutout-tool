# App Store Connect Privacy Answers

Prepared for `Cutout Magic / 抠图神器`  
Copyright: `2026 Yahaha Tech, Rodan`

## Current Codebase Recommendation

Based on the current project state:

- processing is local on device
- there is no custom backend
- there is no analytics SDK
- there is no ad SDK
- there is no account system
- there is no in-app messaging or feedback SDK

Recommended App Privacy answer in App Store Connect:

- `No, we do not collect data from this app`

Use this answer only if the release build stays aligned with the current codebase.

## When This Answer Would Become Wrong

Recheck the App Privacy form before submission if you later add any of the following:

- analytics
- crash reporting services
- advertising SDKs
- cloud image processing
- user accounts
- web forms or in-app support chat
- device fingerprinting

## Practical Submission Notes

- Photo Library permission does not automatically mean you collect data.
- StoreKit purchase flow does not mean you collect full payment information yourself.
- Apple handles billing and restoration.
- User-selected photos stay on device unless the user explicitly saves or shares results.

## Suggested Internal Note

If App Review asks why the app requests Photos access:

`The app requests photo access only when the user selects an image to process or chooses to save an exported result to Photos. Selected images are processed locally on device.`
