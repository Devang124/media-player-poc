const express = require("express")
const router = express.Router()
const { uploadMusic, uploadVideo, getMusicList, getVideoList, deleteMedia } = require("../controllers/mediaController")
const upload = require("../middleware/upload")

// Existing test route
router.get("/", (req, res) => {
    res.json({
        message: "Media routes working"
    })
})

// @route   GET /api/media/music-list
router.get("/music-list", getMusicList)

// @route   GET /api/media/video-list
router.get("/video-list", getVideoList)

// @route   POST /api/media/upload-music
router.post("/upload-music", upload.fields([
    { name: "file", maxCount: 1 },
    { name: "thumbnail", maxCount: 1 }
]), uploadMusic)

// @route   POST /api/media/upload-video
router.post("/upload-video", upload.fields([
    { name: "file", maxCount: 1 },
    { name: "thumbnail", maxCount: 1 }
]), uploadVideo)

// @route   DELETE /api/media/:id
router.delete("/:id", deleteMedia)

module.exports = router