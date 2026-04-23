const Media = require("../models/Media")
const fs = require("fs")
const path = require("path")

/**
 * @desc    Upload music file
 * @route   POST /api/media/upload-music
 * @access  Public
 */
const uploadMusic = async (req, res) => {
    try {
        if (!req.files || !req.files['file'] || !req.files['thumbnail']) {
            return res.status(400).json({ message: "Please upload both music and thumbnail files" })
        }

        const { title } = req.body
        if (!title) {
            return res.status(400).json({ message: "Please provide a title" })
        }

        const fileUrl = req.files['file'][0].filename
        const thumbnailUrl = req.files['thumbnail'][0].filename

        const media = await Media.create({
            title,
            fileUrl,
            thumbnailUrl,
            type: "music"
        })

        // Return full URLs in response
        const host = req.get("host")
        const baseUrl = `${req.protocol}://${host}/uploads/`.replace(/([^:]\/)\/+/g, "$1") 
        res.status(201).json({
            ...media.toObject(),
            fileUrl: baseUrl + media.fileUrl,
            thumbnailUrl: baseUrl + media.thumbnailUrl
        })
    } catch (error) {
        console.error("Error in uploadMusic:", error)
        res.status(500).json({ message: "Server error during music upload" })
    }
}

/**
 * @desc    Upload video file
 * @route   POST /api/media/upload-video
 * @access  Public
 */
const uploadVideo = async (req, res) => {
    try {
        if (!req.files || !req.files['file'] || !req.files['thumbnail']) {
            return res.status(400).json({ message: "Please upload both video and thumbnail files" })
        }

        const { title } = req.body
        if (!title) {
            return res.status(400).json({ message: "Please provide a title" })
        }

        const fileUrl = req.files['file'][0].filename
        const thumbnailUrl = req.files['thumbnail'][0].filename

        const media = await Media.create({
            title,
            fileUrl,
            thumbnailUrl,
            type: "video"
        })

        // Return full URLs in response
        const host = req.get("host")
        const baseUrl = `${req.protocol}://${host}/uploads/`.replace(/([^:]\/)\/+/g, "$1") 
        res.status(201).json({
            ...media.toObject(),
            fileUrl: baseUrl + media.fileUrl,
            thumbnailUrl: baseUrl + media.thumbnailUrl
        })
    } catch (error) {
        console.error("Error in uploadVideo:", error)
        res.status(500).json({ message: "Server error during video upload" })
    }
}

/**
 * @desc    Get all music files
 * @route   GET /api/media/music-list
 * @access  Public
 */
const getMusicList = async (req, res) => {
    try {
        const music = await Media.find({ type: "music" }).sort({ createdAt: -1 })
        
        const host = req.get("host")
        const baseUrl = `${req.protocol}://${host}/uploads/`.replace(/([^:]\/)\/+/g, "$1") 
        const musicWithUrls = music.map(item => ({
            ...item.toObject(),
            fileUrl: baseUrl + item.fileUrl,
            thumbnailUrl: item.thumbnailUrl ? baseUrl + item.thumbnailUrl : null
        }))

        res.status(200).json(musicWithUrls)
    } catch (error) {
        console.error("Error in getMusicList:", error)
        res.status(500).json({ message: "Server error fetching music list" })
    }
}

/**
 * @desc    Get all video files
 * @route   GET /api/media/video-list
 * @access  Public
 */
const getVideoList = async (req, res) => {
    try {
        const videos = await Media.find({ type: "video" }).sort({ createdAt: -1 })
        
        const host = req.get("host")
        const baseUrl = `${req.protocol}://${host}/uploads/`.replace(/([^:]\/)\/+/g, "$1") 
        const videosWithUrls = videos.map(item => ({
            ...item.toObject(),
            fileUrl: baseUrl + item.fileUrl,
            thumbnailUrl: item.thumbnailUrl ? baseUrl + item.thumbnailUrl : null
        }))

        res.status(200).json(videosWithUrls)
    } catch (error) {
        console.error("Error in getVideoList:", error)
        res.status(500).json({ message: "Server error fetching video list" })
    }
}

/**
 * @desc    Delete media file
 * @route   DELETE /api/media/:id
 * @access  Public
 */
const deleteMedia = async (req, res) => {
    try {
        const media = await Media.findById(req.params.id)

        if (!media) {
            return res.status(404).json({ message: "Media not found" })
        }

        // Delete files from uploads folder
        const filesToDelete = [media.fileUrl, media.thumbnailUrl]
        
        filesToDelete.forEach(fileName => {
            if (fileName) {
                const filePath = path.join(__dirname, "..", "uploads", fileName)
                if (fs.existsSync(filePath)) {
                    try {
                        fs.unlinkSync(filePath)
                    } catch (err) {
                        console.error(`Error deleting file ${fileName}:`, err)
                    }
                } else {
                    console.warn("File to delete not found on disk:", filePath)
                }
            }
        })

        // Delete record from database
        await Media.findByIdAndDelete(req.params.id)

        res.status(200).json({ message: "Media deleted successfully" })
    } catch (error) {
        console.error("Error in deleteMedia:", error)
        res.status(500).json({ message: "Server error during media deletion" })
    }
}

module.exports = {
    uploadMusic,
    uploadVideo,
    getMusicList,
    getVideoList,
    deleteMedia
}
