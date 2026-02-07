# Flutter wrapper - comprehensive rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }

# Keep all Flutter method channels
-keepclassmembers class * {
    @io.flutter.embedding.engine.dart.DartEntrypoint *;
}

# Keep Flutter platform channels
-keepclassmembers class * {
    *** callFlutterMethod(...);
}

# Play Core - these are optional, so we can safely ignore warnings
-dontwarn com.google.android.play.core.**

# Syncfusion - aggressive for size
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**
-dontwarn com.microsoft.appcenter.**

# Google ML Kit Text Recognition
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep ML Kit classes - needed for runtime
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Generative AI
-keep class com.google.ai.client.generativeai.** { *; }
-dontwarn com.google.ai.client.generativeai.**

# Keep flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# PDF libraries
-keep class com.shockwave.** { *; }
-dontwarn com.shockwave.**

# AndroidX
-dontwarn androidx.**
-keep class androidx.** { *; }

# Gson (if used)
-keepattributes Signature
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Common Android rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable,RuntimeVisibleAnnotations,RuntimeInvisibleAnnotations,RuntimeVisibleParameterAnnotations,RuntimeInvisibleParameterAnnotations,AnnotationDefault
-keep public class * extends java.lang.Exception

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep setters and getters for data classes
-keepclassmembers class * {
    void set*(***);
    *** get*();
}

# Preserve annotations
-keepattributes InnerClasses,EnclosingMethod

# Remove logging in release builds completely
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** e(...);
    public static *** w(...);
}

# Remove other verbose methods
-assumenosideeffects class java.io.PrintStream {
    public void println(...);
}

# Safe optimization (aggressive flags removed to prevent crashes)
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses

# Suppress warnings for commonly missing classes
-dontwarn android.**
-dontwarn javax.**
-dontwarn org.w3c.**
-dontwarn org.xml.**

# Keep Parcable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Size optimization: remove unused resources
-dontwarn kotlin.**
