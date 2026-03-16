# Task Management System

A full-stack, cross-platform Task Management application featuring user authentication, advanced task tracking, and dynamic state management.

This project is separated into a **Node.js/TypeScript Backend** and a **Flutter Mobile/Web Frontend**.

---

## 🏗 System Architecture & Technologies

### Backend (`/backend`)
The backend provides a robust REST API for managing users and tasks.
- **Node.js & Express v5**: Scalable backend web framework.
- **TypeScript**: Strictly typed JavaScript development.
- **Prisma ORM**: Modern database access toolkit and migration manager.
- **SQLite**: Lightweight database utilized for self-contained, easy local setup.
- **Zod**: Declarative schema validation for all incoming API payload processing.
- **JSON Web Tokens (JWT)**: Secure user authentication using a dual-token (Access + Refresh) rotation mechanism with BCrypt password hashing.

### Frontend (`/mobile`)
The frontend is built using a Clean Architecture paradigm (Models -> Services -> Repositories -> Providers -> UI).
- **Flutter & Dart 3**: Cross-platform development spanning Android, iOS, and Web.
- **Provider**: Streamlined widget state management for Authentication flows and Task Dashboards.
- **Dio**: Powerful HTTP networking client equipped with custom interceptors to automatically refresh expiring JWT access tokens behind the scenes.
- **Flutter Secure Storage**: Encrypted local caching of authentication tokens.

---

## 🚀 How to Run the Project Locally

### Prerequisites
Before starting, ensure you have the following installed on your machine:
- [Node.js](https://nodejs.org/) (v18 or newer recommended)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- A connected Android Emulator, iOS Simulator, or Google Chrome / Microsoft Edge for web testing.

### 1. Starting the Backend API
Open a terminal and navigate to the `backend` directory:
```bash
cd d:\TaskManagement\backend
```

**Install dependencies:**
```bash
npm install
```

**Set up the Environment & Database:**
1. Create a `.env` file directly inside the `backend` folder containing your configurations:
   ```env
   PORT=3000
   ACCESS_TOKEN_SECRET=your_super_secret_access_key
   REFRESH_TOKEN_SECRET=your_super_secret_refresh_key
   ```
2. Run Prisma initialization and Migrations to recreate your local SQLite database structure:
   ```bash
   npx prisma generate
   npm run prisma:migrate
   ```

**Run the Server:**
Use the development script to start the backend with nodemon hot-reloading:
```bash
npm run dev
```
*The server will start running on `http://localhost:3000`.*

---

### 2. Starting the Flutter Mobile/Web App
Open a *new* terminal window and navigate to the `mobile` directory:
```bash
cd d:\TaskManagement\mobile
```

**Install dependencies:**
```bash
flutter pub get
```

**Run the Application:**
To see the list of active devices (Emulators, Browsers, etc.), run:
```bash
flutter devices
```

To run the application on a specific device (like Chrome, Edge, or an Android emulator), use the device ID from the command above. For example:
```bash
# Run on web (Edge/Chrome)
flutter run -d edge

# Run on Android Emulator (assuming one is running)
flutter run
```

---

## ⚙️ Core Application Features

### 🔐 Authentication Flow
- **Registration**: Users can create an account providing an Name, Email, and strong Password (securely hashed via bcrypt).
- **Login**: Verifies credentials and issues a short-lived Access Token and long-lived Refresh Token.
- **Auto-Logout/Refresh**: The Flutter app intercepts `401 Unauthorized` API responses. It automatically uses the Refresh Token to securely fetch a new Access Token behind the scenes without interrupting the user. If the refresh token expires, the user is safely logged out.

### 📋 Task Management
- **Dashboard**: A list view of all created tasks showing titles, partial descriptions, formatted due dates, and dynamically colored Priority/Status badges.
- **Sorting & Filtering**: Quickly filter tasks into functional categories like "To Do", "In Progress", or "Done" via the top-right toolbar.
- **Quick Toggle Checkboxes**: Tap the circular checkbox on any task card to instantly mark it as "Done".
- **Creation & Editing Forms**: Fully interactive UI forms allowing the adjustment of Task Titles, detailed Descriptions, Priorities (`LOW`, `MEDIUM`, `HIGH`), and Statuses (`TODO`, `IN_PROGRESS`, `DONE`).
- **Deletions**: Clean sweep outdated or mistake tasks with a single confirmation prompt.
