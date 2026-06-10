# Flutter / general
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Flutter Gemma / MediaPipe
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# MediaPipe proto classes
-keep class com.google.mediapipe.proto.** { *; }
-dontwarn com.google.mediapipe.proto.**

# Protobuf
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# AutoValue / Memoized
-keep class com.google.auto.value.** { *; }
-dontwarn com.google.auto.value.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}