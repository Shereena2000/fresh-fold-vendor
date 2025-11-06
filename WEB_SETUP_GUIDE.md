# Web Setup Guide for Fresh Fold Shop Keeper

## ✅ What's Already Done

1. **Firebase Web Configuration**: Added to `web/index.html` and `main.dart`
2. **Responsive Design**: All screens are now responsive for mobile, tablet, and web
3. **Image Upload for Web**: Updated to use `Image.memory` for web and `Image.file` for mobile
4. **Cloudinary Web Support**: Added web upload method using bytes

---

## 🔧 Final Step: Add Your Cloudinary Cloud Name

**File to edit:** `lib/Settings/constants/cloudinary_config.dart`

**Line 12:** Replace `'YOUR_CLOUD_NAME'` with your actual Cloudinary cloud name:

```dart
static const String _webCloudName = 'YOUR_CLOUD_NAME'; // Replace with your actual cloud name
```

### How to find your Cloud Name:

1. Go to [Cloudinary Dashboard](https://cloudinary.com/console)
2. Login to your account
3. Look for **Cloud name** on the dashboard (e.g., `dxxxxx` or `your-company-name`)
4. Copy that value and replace `'YOUR_CLOUD_NAME'` in line 12

**Example:**
```dart
static const String _webCloudName = 'dxyz123abc'; // Your actual cloud name
```

---

## 🚀 Running the App

### For Web (Chrome):
```bash
flutter run -d chrome
```

### For Mobile (Android):
```bash
flutter run
```

### For iOS:
```bash
flutter run -d iPhone
```

---

## 📱 Responsive Breakpoints

The app uses the following breakpoints:

- **Mobile**: < 600px
- **Tablet**: 600px - 900px
- **Web/Desktop**: > 900px

---

## ✨ Responsive Features

### All Screens Now Support:

1. **Sign In & Sign Up**
   - Centered card on web (500px max-width)
   - Full-screen on mobile
   - Logo and app name on web

2. **Home Dashboard**
   - 3-column grid on web
   - 2-column grid on tablet
   - Single column on mobile
   - Max-width: 1400px on web

3. **Order Management**
   - 2-column order cards on web
   - Single column on mobile/tablet
   - Scrollable tabs
   - Max-width: 1400px on web

4. **Order Details**
   - 2-column status buttons on web/tablet
   - Single column on mobile
   - Max-width: 1200px on web

5. **Price List**
   - Centered table on web (1400px max)
   - Centered "Add" button on web
   - Scrollable table

6. **Promo Management**
   - 4-column grid on web
   - 3-column grid on tablet
   - 2-column grid on mobile
   - Centered upload button on web
   - Web: opens file picker directly (no camera option)

7. **Privacy Policy**
   - Document-style card on web (900px max)
   - White background with shadow on web/tablet
   - Larger fonts on web for readability

8. **Menu Screen**
   - Centered content on web (800px max)
   - Profile card and menu items
   - Easy logout access

---

## 🌐 Web-Specific Changes

### Image Upload on Web:
- Uses `Image.memory` instead of `Image.file`
- Reads image as bytes using `XFile.readAsBytes()`
- No camera option (only gallery/file picker)
- Works with Cloudinary using bytes

### Firebase on Web:
- Configured in `web/index.html`
- Firebase options in `main.dart`
- Auth and Firestore work seamlessly

### .env File Limitation:
- `.env` file doesn't work on web
- Cloudinary credentials are hardcoded in `cloudinary_config.dart` for web
- Make sure to set your cloud name in the config file

---

## ⚠️ Important Notes

1. **Cloudinary Upload Preset**: Must be set to **"Unsigned"** mode
2. **Cloud Name**: Replace in `cloudinary_config.dart` line 12
3. **Camera**: Not available on web browsers
4. **Hot Reload**: Press `r` in terminal for hot reload, `R` for hot restart

---

## 🐛 Troubleshooting

### If you see a blank white screen:
- Check Firebase configuration in `web/index.html`
- Check browser console (F12 → Console) for errors
- Make sure Firebase web app is registered

### If image upload fails:
- Add your Cloudinary cloud name in `cloudinary_config.dart`
- Ensure upload preset "fresh-fold" exists and is **unsigned**
- Check browser console for errors

### If you see "Image.file not supported":
- Make sure you've applied all the recent changes
- Restart the app (`q` to quit, then run again)

---

## 📞 Need Help?

Check the browser console (F12 → Console tab) for detailed error messages and let me know!

