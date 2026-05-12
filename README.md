# Flutter Express MySQL

A full-stack application built with **Flutter** (frontend) and **Node.js Express** (backend), powered by MySQL database. This project demonstrates a complete e-commerce system with user management, product catalog, and order processing.

## Project Overview

This is a multi-platform mobile application with a REST API backend:

- **Frontend**: Flutter - Runs on iOS, Android, Web, Windows, macOS, and Linux
- **Backend**: Node.js Express - RESTful API server
- **Database**: MySQL - Stores users, products, and orders data

## Project Structure

```
flutter_express/
├── frontend/               # Flutter application
│   ├── lib/               # Dart source code
│   │   └── main.dart      # Entry point
│   ├── android/           # Android-specific configuration
│   ├── ios/              # iOS-specific configuration
│   ├── web/              # Web version
│   ├── windows/          # Windows version
│   ├── macos/            # macOS version
│   ├── linux/            # Linux version
│   ├── pubspec.yaml      # Flutter dependencies
│   └── test/             # Unit and widget tests
│
├── backend/               # Express server
│   ├── server.js         # Server entry point
│   ├── db.js             # Database configuration
│   ├── package.json      # Node dependencies
│   ├── src/
│   │   └── module/       # API modules
│   │       ├── validation.js    # Input validation
│   │       ├── users/           # User endpoints
│   │       ├── products/        # Product endpoints
│   │       └── orders/          # Order endpoints
│   └── README.md
│
└── README.md             # This file
```

## Getting Started

### Prerequisites

- **Flutter SDK** (v3.11.5 or higher)
- **Node.js** (v14 or higher)
- **MySQL Server** (v5.7 or higher)
- **npm** or **yarn** package manager

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure MySQL connection in `db.js`

4. Create the database and tables (see [Database Schema](#-database-schema) below)

5. Start the development server:
   ```bash
   npm start
   ```
   The server will run with nodemon for automatic reload on file changes.

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Update the API base URL in your Flutter code to match the backend server

4. Run the app:
   ```bash
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   
   # For Web
   flutter run -d web
   
   # For Windows
   flutter run -d windows
   ```

## Database Schema

Run these SQL queries in your MySQL database to create the required tables:

```sql
-- Users table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  position VARCHAR(100),
  salary VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  price DECIMAL(10,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Order details table
CREATE TABLE order_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

## Dependencies

### Backend
- **express** - Web framework
- **mysql2** - MySQL database driver
- **cors** - Enable cross-origin requests
- **joi** - Input validation
- **body-parser** - Request body parsing
- **nodemon** - Development server with auto-reload
- **ip** - IP utility

### Frontend
- **Flutter SDK 3.11.5+** - UI framework
- See `frontend/pubspec.yaml` for complete list

##  API Endpoints

The backend provides REST API endpoints for:

- **Users**: CRUD operations for user management
- **Products**: Product listing and management
- **Orders**: Order creation and tracking
- **Order Details**: Order item management

Refer to `backend/src/module/` for specific endpoint implementations.

## Development

### Backend Development
- Modify files in `backend/src/module/`
- Server automatically reloads with nodemon
- Use Postman or similar tools to test API endpoints

### Frontend Development
- Edit Dart files in `frontend/lib/`
- Use `flutter run` for hot reload during development
- Test on multiple platforms using platform-specific commands

## Notes

- The application includes input validation using Joi
- Database connections are configured in `backend/db.js`
- API responses follow standard REST conventions
- CORS is enabled for cross-origin requests

## License

Add your license here if applicable.

## Author

Your name/organization here
