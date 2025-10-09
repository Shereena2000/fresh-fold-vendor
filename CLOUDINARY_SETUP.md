# Cloudinary Setup Instructions

## 🔑 Your Cloudinary Credentials

✅ **API Key**: `692484724374318` (Already configured)  
✅ **API Secret**: `hIZ6N5OjvIFXks9wWAAcveYA8v8` (Already configured)  
⚠️ **Cloud Name**: You need to add this!

---

## 🚀 Quick Setup Guide

### Step 1: Find Your Cloud Name

1. Go to [Cloudinary Dashboard](https://cloudinary.com/console)
2. Log in to your account
3. On the dashboard, you'll see something like:
   ```
   Cloud name: dxxxxx or your-company-name
   ```
4. Copy that cloud name

### Step 2: Add Cloud Name to .env File

**IMPORTANT:** You must create/update the `.env` file in the project root.

Create file: `/Users/shereenamj/Flutter/Earning_Fish/fresh_fold_shop_keeper/.env`

Add this content:
```env
CLOUDINARY_CLOUD_NAME=your-cloud-name-here
CLOUDINARY_API_KEY=692484724374318
CLOUDINARY_API_SECRET=hIZ6N5OjvIFXks9wWAAcveYA8v8
CLOUDINARY_UPLOAD_PRESET=fresh-fold
```

Replace `your-cloud-name-here` with your actual cloud name from Step 1.

### Step 3: Configure Upload Preset (Already Named 'fresh-fold')

1. In Cloudinary Dashboard, go to **Settings** → **Upload**
2. Scroll to **Upload presets** section
3. Click **Add upload preset**
4. Configure:
   - **Preset name**: `fresh-fold` (exactly as shown)
   - **Signing Mode**: **Unsigned** (important!)
   - **Folder**: `fresh_fold/promos`
   - **Allowed formats**: jpg, png, webp
   - **Max file size**: 5 MB (recommended)
5. Click **Save**

### Step 4: Test Upload

1. Run the app
2. Go to **Menu** → **Manage Promos**
3. Click **Upload Promo Image**
4. Select an image
5. Check Cloudinary dashboard to verify upload

---

## 📁 Firebase Structure

Promo images are stored in Firebase at:

```
promos/{promoId}
  ├─ promoId: "timestamp"
  ├─ imageUrl: "https://res.cloudinary.com/..."
  ├─ publicId: "fresh_fold/promos/xyz123"
  ├─ uploadedBy: "vendorUid"
  ├─ createdAt: timestamp
  └─ updatedAt: timestamp
```

---

## 🎨 Features Implemented

✅ Upload promo images from gallery or camera  
✅ Store images in Cloudinary (preset: fresh-fold)  
✅ Save image URLs in Firebase (collection: promos)  
✅ Grid view of all promos  
✅ Delete promos with confirmation  
✅ Real-time updates  
✅ Image preview before upload  
✅ Loading states  

---

## 📱 Client App Integration

The client app can fetch promos using:

```dart
FirebaseFirestore.instance
  .collection('promos')
  .orderBy('createdAt', descending: true)
  .get();
```

Each promo contains:
- `imageUrl` - Direct link to Cloudinary image
- `createdAt` - Upload timestamp
- Can filter by date, show as carousel, etc.

---

## ⚠️ Important Notes

1. **Unsigned preset** allows uploads without authentication
2. **Folder organization**: All promos go to `fresh_fold/promos`
3. **Image quality**: Compressed to 80% for faster loading
4. **Max dimensions**: 1920x1080 for optimal performance
5. **Deletion**: Currently removes from Firebase only (Cloudinary files persist)

---

## 🔐 Security Recommendations

For production:
1. Consider using **signed uploads** for better security
2. Implement **rate limiting** to prevent abuse
3. Add **file size validation** before upload
4. Use **Cloud Functions** for Cloudinary deletions
5. Add **upload quota** per vendor

---

## 📞 Support

If you encounter issues:
1. Verify cloud name is correct
2. Ensure upload preset 'fresh-fold' exists
3. Check preset is set to **Unsigned** mode
4. Verify Firebase permissions allow writes to 'promos' collection

