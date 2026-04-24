const express = require("express")
const cors = require("cors")
const dotenv = require("dotenv")
const path = require("path")

// Load env variables
dotenv.config()

// MongoDB connection
const connectDB = require("./config/db")

const app = express()

// Middleware
app.use(cors()) // Re-enabled CORS
app.use(express.json())

// Request logger (clean version)
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`)
    next()
})

// Test route
app.get("/", (req, res) => {
    res.send("Backend Running")
})

// Routes
const mediaRoutes = require("./routes/mediaRoutes")
const userRoutes = require("./routes/userRoutes")

app.use("/api/media", mediaRoutes)
app.use("/api/users", userRoutes)

// Serve uploads folder
app.use("/uploads", express.static(path.join(__dirname, "uploads")))

const PORT = process.env.PORT || 3000

// Initialize Server after DB connection
const startServer = async () => {
    try {
        console.log("Connecting to Database...")
        await connectDB()
        
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`)
        })
    } catch (error) {
        console.error("Failed to start server:", error.message)
        process.exit(1)
    }
}

startServer()