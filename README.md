# 🎓 LMS App - Learning Management System
Name:Florence Ankomah
ID:224CS02001273

A premium, feature-rich Learning Management System built with **Flutter** and **Firebase**. This app provides a seamless learning experience, allowing users to browse courses, watch video lessons, test their knowledge with quizzes, and earn certificates.

---

## ✨ Key Features

### 🔐 Secure Authentication
- **User Accounts**: Sign up and log in securely using Firebase Authentication.
- **Session Persistence**: Stay logged in across app restarts.
- **Profile Management**: Update your personal information and track your learning progress.

### 📚 Comprehensive Course Catalog
- **Browse & Search**: Explore a wide range of courses across various categories like Programming, Design, Business, Marketing, and Health.
- **Rich Course Details**: View in-depth descriptions, instructor information, and student reviews.

### 📺 Interactive Learning Experience
- **Video Integration**: Watch course content directly within the app via the integrated YouTube player.
- **Course Enrollment**: Enroll in courses to track your progress and unlock quizzes.

### 🧠 Knowledge Assessment & Certification
- **Quizzes**: Challenge yourself with course-specific quizzes after completing the video content.
- **Dynamic Certificates**: Automatically receive a personalized certificate of completion upon successfully passing a quiz (70% or higher).
- **Learning History**: Keep a record of all your completed courses and earned certificates.

### 💬 Community & Feedback
- **Student Reviews**: Read honest feedback from other learners before enrolling.
- **Rate & Review**: Share your own experience by leaving ratings and comments on completed courses.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (3.x)
- **Backend**: [Firebase](https://firebase.google.com/)
  - **Firestore**: Real-time NoSQL database for courses, users, and progress.
  - **Authentication**: Secure email/password login.
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Video Player**: [youtube_player_iframe](https://pub.dev/packages/youtube_player_iframe)
- **Icons**: Custom generated via `flutter_launcher_icons`.

---

## 🚀 How It Works

1.  **Onboarding**: Start by creating an account or logging in.
2.  **Explore**: Use the Home screen to browse through the latest courses or filter by category.
3.  **Learn**: Select a course to view its details. Once enrolled, you can start watching the video lessons.
4.  **Test**: After finishing the video content, take the quiz to test your understanding.
5.  **Achieve**: If you pass the quiz, your certificate is instantly generated with your name and the completion date. You can view it anytime from the Course Detail or Learning History screens.
6.  **Engage**: Share your thoughts by leaving a review for the course to help other students!

---

## 🛠️ Getting Started

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 📁 Project Structure

- `lib/models`: Data models for Courses, Quizzes, Users, and Reviews.
- `lib/screens`: All UI screens (Home, Course Detail, Certificate, Profile, etc.).
- `lib/providers`: State management logic for Auth and Course data.
- `lib/services`: API service for Firestore interactions.
- `lib/widgets`: Reusable UI components.

---

*Built with ❤️ by the LMS App Team.*
