# ProGuard rules for Carbo (car rental app)
# Enables R8 code shrinking, optimization, and obfuscation while preserving critical APIs

# =============================================================================
# 1. GENERAL R8/PROGUARD CONFIGURATION
# =============================================================================

# Optimization passes - aggressive optimization for smaller APK and better 16 KB support
-optimizationpasses 5
-allowaccessmodification

# Remove logging and debug info (security + size optimization)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep annotations
-keepattributes *Annotation*,EnclosingMethod,Signature,InnerClasses

# =============================================================================
# 2. FLUTTER & DART ENGINE
# =============================================================================

# Keep Flutter-related classes
-keep class io.flutter.** { *; }
-keep class com.google.dart.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# =============================================================================
# 3. FIREBASE MESSAGING & SERVICES
# =============================================================================

# Keep Firebase messaging handlers and services
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Keep Firebase analytics
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.measurement.** { *; }

# Keep GMS (Google Mobile Services)
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }

# =============================================================================
# 4. PUSHER PUSH NOTIFICATIONS
# =============================================================================

# Keep Pusher Beams notification handling
-keep class com.pusher.** { *; }
-keep interface com.pusher.** { *; }
-keep class com.pusher.push.** { *; }

# Keep Pusher channels (real-time communication)
-keep class com.pusher.client.** { *; }
-keep interface com.pusher.client.** { *; }

# =============================================================================
# 5. ML KIT TEXT RECOGNITION
# =============================================================================

# Keep ML Kit vision and text recognition models
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-keep class com.google.android.odml.** { *; }

# Keep TFLite interpreter (used by ML Kit internally)
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# =============================================================================
# 6. GOOGLE PLAY SERVICES
# =============================================================================

# Keep Google Play Services (required for licensing, billing, etc.)
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.maps.** { *; }

# Keep Google Play Services base classes
-keep public class com.google.android.gms.* { public *; }
-keep interface com.google.android.gms.* { *; }

# =============================================================================
# 7. CARBO APP-SPECIFIC CLASSES
# =============================================================================

# Keep Carbo app main classes and services
-keep class app.next.durratalaseel.** { *; }
-keep interface app.next.durratalaseel.** { *; }

# Keep main activity
-keep class app.next.durratalaseel.MainActivity { *; }

# =============================================================================
# 8. AWESOME NOTIFICATIONS
# =============================================================================

# Keep Awesome Notifications
-keep class me.carda.awesome_notifications.** { *; }
-keep interface me.carda.awesome_notifications.** { *; }

# Keep notification receivers and services
-keep class * extends android.app.Service { *; }
-keep class * extends android.content.BroadcastReceiver { *; }

# =============================================================================
# 9. IMAGE PROCESSING & MEDIA
# =============================================================================

# Keep image picker and related libraries
-keep class com.google.android.material.** { *; }
-keep interface com.google.android.material.** { *; }

# Keep image caching (cached_network_image, image_picker)
-keep class com.bumptech.glide.** { *; }
-keep interface com.bumptech.glide.** { *; }

# =============================================================================
# 10. JSON SERIALIZATION & DATA MODELS
# =============================================================================

# Keep model classes for JSON deserialization (needed for API responses)
-keep class **.model.** { *; }
-keep class **.models.** { *; }
-keep class **.data.model.** { *; }

# Keep enum values (used in API responses)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# =============================================================================
# 11. KOTLIN
# =============================================================================

# Keep Kotlin standard library and runtime
-keep class kotlin.** { *; }
-keep interface kotlin.** { *; }
-dontwarn kotlin.**

# Keep Kotlin coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# =============================================================================
# 12. ANDROID FRAMEWORK
# =============================================================================

# Keep Android framework classes
-keep public class android.** { public <fields>; public <methods>; }
-keep public class android.app.** { *; }
-keep public class android.content.** { *; }

# Keep view classes
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# =============================================================================
# 13. HTTP & NETWORKING
# =============================================================================

# Keep OkHttp interceptors and clients
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep Retrofit
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }
-dontwarn retrofit2.**

# =============================================================================
# 14. WARNINGS SUPPRESSION (safe to ignore)
# =============================================================================

-dontwarn android.**
-dontwarn androidx.**
-dontwarn com.google.android.**
-dontwarn com.google.common.**
-dontwarn java.lang.invoke.**
-dontwarn sun.misc.Unsafe
-dontwarn javax.lang.model.**
-dontwarn com.sun.org.apache.xerces.internal.**

# =============================================================================
# 15. 16 KB PAGE SIZE OPTIMIZATION
# =============================================================================

# Explicitly enable optimizations that support 16 KB page alignment
-optimizations code/simplification/arithmetic,field/*,method/propagation/parameter

# Reduce code size further for 16 KB compatibility
-repackageclasses 'carbo'
-allowaccessmodification
