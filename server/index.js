require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const axios = require("axios");

const app = express();
app.use(cors());
app.use(bodyParser.json({ limit: "10mb" }));

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const PORT = process.env.PORT || 3000;

if (!GEMINI_API_KEY) {
    console.error("ERROR: GEMINI_API_KEY is not set in the .env file.");
    process.exit(1);
}

app.post("/describe", async (req, res) => {
    const { imageBase64 } = req.body;
    if (!imageBase64) return res.status(400).json({ error: "Missing imageBase64" });

    try {
        const response = await axios.post(
            `https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`,
            {
                contents: [
                    {
                        parts: [
                            { inline_data: { mime_type: "image/jpeg", data: imageBase64 } },
                            { text: "You are a visual assistant for a blind person. Describe what the camera sees in a short, clear sentence. Mention key objects or people and their relative positions." }
                        ]
                    }
                ]
            }
        );
        const desc = response.data?.candidates?.[0]?.content?.parts?.[0]?.text || "No objects detected.";
        res.json({ description: desc });
    } catch (err) {
        console.error(err.response?.data || err.message);
        res.status(500).json({ error: "Gemini API failed" });
    }
});

app.listen(PORT, '0.0.0.0', () => console.log(`Lumos server running on http://0.0.0.0:${PORT}`));
