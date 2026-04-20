const multer = require("multer")
const path = require("path")

// Absolute uploads path
const uploadPath = path.join(__dirname, "..", "uploads")

// Configure storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadPath)
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname))
    }
})

// Initialize multer
const upload = multer({
    storage: storage,
    limits: {
        fileSize: 100 * 1024 * 1024
    }
})

module.exports = upload