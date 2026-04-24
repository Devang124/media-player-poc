const express = require("express");
const router = express.Router();
const { registerUser, loginUser, getAllUsers } = require("../controllers/userController");

// @route   POST /api/users/register
router.post("/register", registerUser);

// @route   POST /api/users/login
router.post("/login", loginUser);

// @route   GET /api/users/users
router.get("/users", getAllUsers);

module.exports = router;
