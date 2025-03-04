### **🔹 Store Credentials as GitHub Secrets**
- **APPLE_ID** → Your Apple Developer **email**.
- **APPLE_TEAM_ID** → Your Apple Developer **Team ID** (find it [here](https://developer.apple.com/account)).
- **APPLE_NOTARIZATION_PASSWORD** → The **app-specific password** generated above.


---

## **⚡ 2. Modify the GitHub Actions Workflow**
### **🔹 Add Notarization & Stapling Steps**
Modify your **GitHub Actions workflow** to notarize and staple the app **after code-signing**.

#### **✅ Updated Workflow**
```yaml
- name: Notarize the App
  run: |
    echo "Submitting app for notarization..."
    
    xcrun notarytool submit "build/TMBMApp.zip" \
      --apple-id "${{ secrets.APPLE_ID }}" \
      --team-id "${{ secrets.APPLE_TEAM_ID }}" \
      --password "${{ secrets.APPLE_NOTARIZATION_PASSWORD }}" \
      --wait

- name: Staple the Notarization Ticket
  run: |
    echo "Stapling notarization ticket..."
    xcrun stapler staple "build/TMBMApp.app"

- name: Verify Notarization
  run: |
    echo "Verifying notarization status..."
    spctl --assess --verbose=4 "build/TMBMApp.app"
```

---

## **🔑 3. Submit the Correct File Format**
Apple **does not accept raw `.app` files** for notarization.  
You must submit a **`.zip`, `.pkg`, or `.dmg`**.

### **🔹 Create a ZIP Archive**
Before notarizing, ensure your app is archived correctly:

```sh
/usr/bin/ditto -c -k --keepParent "build/TMBMApp.app" "build/TMBMApp.zip"
```

✅ Add this step **before notarization** in the workflow:

```yaml
- name: Prepare App for Notarization
  run: |
    echo "Creating ZIP archive for notarization..."
    /usr/bin/ditto -c -k --keepParent "build/TMBMApp.app" "build/TMBMApp.zip"
```

---

## **⏳ 4. How Long Does Notarization Take?**
- **Most apps:** **1-5 minutes**.
- **Peak times:** Up to **15 minutes**.
- **Notarization is asynchronous**, but `--wait` makes it **blocking**.

---

## **🚀 5. Final CI/CD Pipeline Steps**
1. **Build & Code-Sign the App**
2. **Create ZIP Archive**
3. **Submit for Notarization**
4. **Wait for Approval**
5. **Staple the Notarization Ticket**
6. **Verify & Package App**

---

### **❗ Important Notes**
- **You DO NOT need the `Developer ID Installer` certificate** unless you're signing a `.pkg` installer.
- Notarization **only requires** the `Developer ID Application` certificate.
- Stapling **ensures Gatekeeper works offline**.

---

## **🎯 Summary**
✅ **Use `notarytool` with an App Store Connect App-Specific Password.**  
✅ **Submit a ZIP, DMG, or PKG, not a raw `.app` file.**  
✅ **Staple the notarization ticket for offline verification.**  

This **fully automates notarization** in your CI/CD process. 🚀 Let me know if you need further adjustments!