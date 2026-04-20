const express = require("express")
const cors = require("cors")
const dotenv = require("dotenv")

// Load env variables
dotenv.config()

// MongoDB connection
const connectDB = require("./config/db")

const app = express()

// Connect database
connectDB()

// Middleware
app.use(cors())
app.use(express.json())

// Test route
app.get("/", (req, res) => {
    res.send("Backend Running")
})

// Routes
const mediaRoutes = require("./routes/mediaRoutes")

app.use("/api/media", mediaRoutes)

// Serve uploads folder
app.use("/uploads", express.static("uploads"))

const PORT = process.env.PORT || 3000

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`)
})