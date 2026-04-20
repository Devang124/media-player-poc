const mongoose = require("mongoose")

const mediaSchema = new mongoose.Schema({

    title: {
        type: String,
        required: true
    },

    fileUrl: {
        type: String,
        required: true
    },

    type: {
        type: String,
        enum: ["music", "video"],
        required: true
    },

    createdAt: {
        type: Date,
        default: Date.now
    }

})

module.exports = mongoose.model("Media", mediaSchema)