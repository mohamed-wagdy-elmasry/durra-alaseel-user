# Google Maps Setup Guide

To enable the map functionality in the booking screen, you need to configure Google Maps API keys.

## Step 1: Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Geocoding API**
   - **Places API**
4. Go to **Credentials** → **Create Credentials** → **API Key**
5. Copy your API key

## Step 2: Restrict Your API Key (Recommended)

1. Click on your API key in the credentials page
2. Under **Application restrictions**:
   - For Android: Select "Android apps" and add your package name and SHA-1 fingerprint
   - For iOS: Select "iOS apps" and add your bundle identifier
3. Under **API restrictions**:
   - Select "Restrict key"
   - Choose: Maps SDK for Android, Maps SDK for iOS, Geocoding API, Places API
4. Save changes

## Step 3: Configure Android

File: `android/app/src/main/AndroidManifest.xml`

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

## Step 4: Configure iOS

File: `ios/Runner/AppDelegate.swift`

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:

```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

## Step 5: Get SHA-1 Fingerprint (Android)

Run this command in your project root:

```bash
# For Debug Key
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For Release Key (if you have one)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your_alias_name
```

Copy the SHA-1 fingerprint and add it to your Google Cloud Console under Android app restrictions.

## Step 6: Test the Map

1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild and run your app
4. Navigate to the booking screen
5. Try selecting a pickup location on the map

## Troubleshooting

### Map shows blank/gray screen:
- Verify API key is correct
- Ensure all required APIs are enabled
- Check API key restrictions match your app configuration
- Verify SHA-1 fingerprint is added for Android

### "Authorization failure" error:
- API key restrictions might be too strict
- Try temporarily removing restrictions to test
- Ensure package name/bundle ID matches exactly

### Location not working:
- Check that location permissions are granted
- Verify GPS is enabled on the device
- Test on a real device (emulators may have GPS issues)

## Important Notes

- **Never commit your API key to version control**
- Consider using environment variables or secrets management
- Monitor your API usage in Google Cloud Console
- Enable billing (free tier is usually sufficient for development)
- Different API keys for development and production are recommended

## Cost Information

Google Maps Platform offers a **$200 monthly credit** which is usually enough for development and small-scale production apps. Check current pricing at: https://developers.google.com/maps/billing-and-pricing/pricing

## Security Best Practices

1. Use API key restrictions (Application + API)
2. Use separate keys for Android and iOS
3. Monitor usage regularly
4. Set up usage quotas and alerts
5. Rotate keys periodically
