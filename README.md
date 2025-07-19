# Rezumo
**👇 See Tasty and Easy in action (GIF demo below, might take a few seconds to load):**
![rezumeGIF-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/0bd5935c-19f9-44a0-a83b-eb6a6b30544f)
## 📄 Smart CV Analyzer & Enhancer

Rezumo is a cross-platform Flutter application designed to analyze and improve résumés. It uses AI (DeepSeek Chat) to review structure and content, providing personalized suggestions tailored to the user's level: Junior, Middle, or Senior. With PDF ↔ HTML conversion technology, Rezumo allows flexible editing and visual control of your CV.

## ✨ Key Features
### 🤖 AI-Powered Analysis
Integrated with DeepSeek AI for deep content analysis

Smart improvement suggestions based on experience level (Junior / Mid / Senior)

Adaptive phrasing tailored to career goals

## 📄 PDF and HTML Workflow
Converts PDF to HTML and back

Preview, edit, and update résumé content visually

Supports images, styling, and formatting

## 📂 Functionality
Select files using a file picker

Display PDF documents inside the app

Download, open, and store files locally

Parse and visualize HTML (via flutter_html)

Render LaTeX and markdown (via flutter_markdown_latex)

## 🧱 Technical Stack
### ✅ Technologies
Framework: Flutter

PDF Tools: syncfusion_flutter_pdf, pdfx, flutter_pdfview, pdf

HTML & Markdown Rendering: flutter_html, flutter_markdown_latex

State Management: flutter_bloc

Storage & Preferences: shared_preferences, path_provider

File Handling: file_picker, open_file

Permissions: permission_handler

Networking: http

UX Enhancements: cupertino_icons, url_launcher

## 🚀 App Flow
Upload a PDF résumé using the file picker

Convert and display the résumé in HTML format

Send the content to the AI model for analysis

Receive corrections and enhancement suggestions

Preview and save the optimized résumé as PDF
## 🛠 Installation & Running
git clone https://github.com/Viktorjob/Rezumo.git
cd Rezumo
flutter pub get
flutter run
