# 🎵 Media Player POC (Music & Video Streaming App)

## 📌 Project Overview

This project is a **Media Player Proof of Concept (POC)** that supports:

* Uploading Music and Videos
* Uploading Thumbnail Images
* Streaming Music and Video
* Searching Media
* Managing Media (Delete, View)
* User Module (Basic Login/Register)
* Modern SwiftUI Mobile UI
* Node.js Backend with MongoDB

The goal of this project is to demonstrate a **full-stack media streaming workflow** using modern technologies.

---

# 🧰 Tech Stack Used

## 📱 Frontend (iOS)

| Technology        | Purpose                  |
| ----------------- | ------------------------ |
| SwiftUI           | UI development           |
| AVPlayer          | Audio & Video Playback   |
| AsyncImage        | Thumbnail Loading        |
| MVVM Architecture | Separation of UI & Logic |
| URLSession        | API Calls                |
| PhotosPicker      | Thumbnail Selection      |
| FileImporter      | Media File Selection     |

---

## 🌐 Backend

| Technology | Purpose                   |
| ---------- | ------------------------- |
| Node.js    | Backend runtime           |
| Express.js | API Framework             |
| MongoDB    | Database                  |
| Mongoose   | MongoDB Object Modeling   |
| Multer     | File Upload Handling      |
| CORS       | API Access Control        |
| Dotenv     | Environment Configuration |

---

## 🗄 Database

Database: **MongoDB**

Collections Used:

```text
Users
Media
```

Media stores:

```json
{
  "title": "Sample Video",
  "fileUrl": "video.mp4",
  "thumbnailUrl": "thumb.jpg",
  "type": "video"
}
```

---

# 🏗 Architecture

This project follows:

```text
Frontend (SwiftUI)
        ↓
REST API (Express.js)
        ↓
MongoDB Database
        ↓
Uploads Folder (Media Storage)
```

Architecture Style:

```text
MVVM (Frontend)
MVC (Backend)
```

---

# 📂 Project Structure

```text
media-player-poc/

backend/
│
├── config/
│   └── db.js
│
├── controllers/
│   ├── mediaController.js
│   └── userController.js
│
├── middleware/
│   └── upload.js
│
├── models/
│   ├── Media.js
│   └── User.js
│
├── routes/
│   ├── mediaRoutes.js
│   └── userRoutes.js
│
├── uploads/
│
├── server.js
│
ios-app/
│
└── MediaPlayerApp/
    ├── Models/
    ├── Services/
    ├── ViewModels/
    ├── Views/
```

---

# 🚀 Features Implemented

## 🎵 Media Features

* Upload Music
* Upload Videos
* Upload Thumbnail Images
* Play Music
* Play Video
* Delete Media
* Search Media
* Display Thumbnails
* Media Detail View

---

## 👤 User Features

* Register User
* Login User
* View Profile
* Logout User

(Simple authentication used for POC)

---

## 🔍 Search Features

* Search by Media Title
* Real-time Search
* Filter Results
* Display Matching Media

---

## 🎬 Media Player Features

* Video Streaming
* Audio Playback
* Play / Pause Controls
* Seek Forward / Backward
* Thumbnail Display
* Streaming Optimization

---

# 🔌 Backend APIs

## Media APIs

| Method | Endpoint                | Description    |
| ------ | ----------------------- | -------------- |
| POST   | /api/media/upload-music | Upload Music   |
| POST   | /api/media/upload-video | Upload Video   |
| GET    | /api/media/music-list   | Get Music List |
| GET    | /api/media/video-list   | Get Video List |
| GET    | /api/media/search       | Search Media   |
| DELETE | /api/media/:id          | Delete Media   |

---

## User APIs

| Method | Endpoint            | Description   |
| ------ | ------------------- | ------------- |
| POST   | /api/users/register | Register User |
| POST   | /api/users/login    | Login User    |
| GET    | /api/users/users    | Get All Users |

---

# 📥 Setup Instructions

## Backend Setup

```bash
git clone https://github.com/your-username/media-player-poc.git

cd media-player-poc/backend

npm install
```

Create `.env` file:

```text
PORT=3000
MONGO_URI=mongodb://localhost:27017/mediaDB
```

Run server:

```bash
npm start
```

---

## Frontend Setup (iOS)

Open:

```text
ios-app/MediaPlayerApp.xcodeproj
```

Run on:

```text
iPhone Simulator
```

Ensure backend is running before launching app.

---

# 🤖 AI Usage (Antigravity)

This project utilized **AI-assisted development** using Antigravity.

AI was used for:

* Generating API structures
* Creating SwiftUI UI layouts
* Debugging issues
* Optimizing media playback
* Implementing search functionality
* Enhancing UI design patterns

Manual coding was used for:

* Integration logic
* Debugging runtime issues
* Performance tuning
* UI customization

---

# 📸 Screenshots

| Home Screen | Upload Screen | Player Screen |
|-------------|----------------|----------------|
| <img width="250" height="550" alt="Simulator Screenshot - iPhone 17 Pro - 2026-04-24 at 16 34 33" src="https://github.com/user-attachments/assets/506d78f4-f75d-4935-b514-ad8cbf359868" />
 | <img width="250" height="550" alt="Simulator Screenshot - iPhone 17 Pro - 2026-04-24 at 16 34 27" src="https://github.com/user-attachments/assets/bca1fbd0-5713-4a2c-82bc-895e8b4846bc" />
 | <img width="250" height="550" alt="Simulator Screenshot - iPhone 17 Pro - 2026-04-24 at 16 38 05" src="https://github.com/user-attachments/assets/d0373776-354d-4ba7-9c5a-289d7d03385f" />
 |
---

# ⚡ Performance Optimizations

Implemented:

* Lazy loading media
* Thumbnail-first rendering
* Video compression optimization
* Debounced search requests
* Async API calls

---

# 👨‍💻 Contributors

* Devang Parmar
* Vishnu Mavawala

---

# 📄 License

This project is created for **educational and demonstration purposes**.
