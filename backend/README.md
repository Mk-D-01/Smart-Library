# Library Management System - Backend API

A complete Node.js + TypeScript backend for a library management system with Express.js and SQLite.

## Features

- ✅ Express.js server with TypeScript
- ✅ SQLite database (better-sqlite3)
- ✅ RESTful API for Books and Members
- ✅ CORS enabled for Flutter app
- ✅ Input validation middleware
- ✅ Error handling middleware
- ✅ Environment variables support
- ✅ Type-safe with TypeScript

## Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.ts          # Database configuration and initialization
│   ├── models/
│   │   └── library.model.ts     # Data models and database operations
│   ├── controllers/
│   │   └── library.controller.ts # Request handlers
│   ├── routes/
│   │   └── library.routes.ts    # API route definitions
│   ├── middleware/
│   │   └── errorHandler.ts      # Error handling middleware
│   └── server.ts                # Main server file
├── .env.example                 # Environment variables template
├── package.json                 # Dependencies and scripts
├── tsconfig.json                # TypeScript configuration
└── README.md                    # This file
```

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Or create `.env` manually with:

```
PORT=3000
NODE_ENV=development
DB_PATH=./library.db
```

### 3. Run the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Build TypeScript:**
```bash
npm run build
```

**Production mode:**
```bash
npm start
```

The server will start on `http://localhost:3000`

## API Endpoints

### Books

- `GET /api/books` - Get all books
- `GET /api/books/:id` - Get book by ID
- `POST /api/books` - Create a new book
- `PUT /api/books/:id` - Update a book
- `DELETE /api/books/:id` - Delete a book

### Members

- `GET /api/members` - Get all members
- `GET /api/members/:id` - Get member by ID
- `POST /api/members` - Create a new member
- `PUT /api/members/:id` - Update a member
- `DELETE /api/members/:id` - Delete a member

### Health Check

- `GET /` - API information
- `GET /health` - Health check endpoint

## Example API Requests

### Create a Book

```bash
POST http://localhost:3000/api/books
Content-Type: application/json

{
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "isbn": "978-0-7432-7356-5",
  "category": "Fiction",
  "published_year": 1925,
  "total_copies": 5,
  "available_copies": 5
}
```

### Create a Member

```bash
POST http://localhost:3000/api/members
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "address": "123 Main St, City, State"
}
```

## Database Schema

The database automatically creates three tables:

1. **books** - Stores book information
2. **members** - Stores member information
3. **transactions** - Stores borrow/return transactions (ready for future implementation)

## Technologies Used

- **Express.js** - Web framework
- **TypeScript** - Type-safe JavaScript
- **better-sqlite3** - SQLite database driver
- **CORS** - Cross-Origin Resource Sharing
- **dotenv** - Environment variable management
- **nodemon** - Development auto-reload

## Development

- The database file (`library.db`) will be created automatically on first run
- All TypeScript files are in the `src/` directory
- Compiled JavaScript files will be in the `dist/` directory
- Use `npm run dev` for development with auto-reload
- Use `npm run build` to compile TypeScript before production

## Notes

- The database is initialized automatically when the server starts
- Foreign keys are enabled for referential integrity
- All timestamps are automatically managed
- Input validation is handled in controllers
- Error handling middleware catches all errors
