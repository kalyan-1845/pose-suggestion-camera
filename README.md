# 📸 Pose AI Camera — Intelligent Mobile Framing

[![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?style=flat-square&logo=flutter)](https://flutter.dev/)
[![MLKit](https://img.shields.io/badge/Google--ML--Kit-Pose--Detection-4285F4?style=flat-square&logo=google)](https://developers.google.com/ml-kit)
[![Android](https://img.shields.io/badge/Android-Native--Performance-3DDC84?style=flat-square&logo=android)](https://www.android.com/)

A premium, high-performance mobile application engineered to assist photographers and content creators by suggesting perfect camera framings and body postures in real-time, leveraging on-device ML pose estimation models.

```mermaid
graph TD
    Cam[Camera Stream] -->|Asynchronous YUV Frames| Controller[Camera Controller]
    Controller -->|On-Device Image Streaming| MLKit[Google ML Kit Pose Engine]
    MLKit -->|Body Pose Coordinates| Calc[Vector Angular Solver]
    Calc -->|Angle & Skeleton Matching| Suggest[Framing & Suggester Layer]
    Suggest -->|Overlay UI Render| Screen[Interactive Mobile Overlay]
```

## ⚡ Core Features
- **On-Device Computer Vision**: Leveraging Google ML Kit Pose Detection for real-time skeleton tracking at 30+ FPS.
- **Asymmetric Vector Angle Solver**: Translates coordinate maps into exact physical posture angular discrepancies.
- **Real-Time Interactive Skeleton Overlay**: Smooth rendering of dynamic joint lines on high-resolution camera canvases.

## 🛠 Architecture
- **Language Core**: Dart 3.x
- **UI Platform**: Flutter Framework
- **Hardware Integration**: Camera plugins with custom background frame isolator streams.
- **Inference Layer**: Google ML Kit Pose ML Engine.

## 🚀 Installation & Setup
1. Ensure Flutter is installed and configured on your system PATH.
2. Initialize dependencies:
   ```bash
   flutter pub get
   ```
3. Compile and execute on connected mobile device:
   ```bash
   flutter run --release
   ```

## 📜 License
MIT License. Created by Kalyan Reddy.
