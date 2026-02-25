import Config from 'react-native-config';

// --- Configuration ---
// The API key is loaded from the .env file via react-native-config.
// Create a .env file in the project root with: GEMINI_API_KEY=your_key_here
const API_KEY = Config.GEMINI_API_KEY || '';

// Use a supported Gemini model
const MODEL_NAME = 'gemini-2.0-flash';

const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}`;

/**
 * Fetches a description for an image from the Gemini Vision API.
 * @param base64Image The image encoded as a base64 string.
 * @param languageCode The language for the description (e.g., 'en', 'kn', 'hi').
 * @returns A promise that resolves to the generated description string.
 */
export async function fetchOnlineDescription(
  base64Image: string,
  languageCode: string,
): Promise<string> {
  if (!API_KEY) {
    console.warn('GEMINI_API_KEY is not set. Check your .env file.');
    return 'Error: API key not configured.';
  }

  // Clean the Base64 string (strip "data:*;base64," if present)
  const cleanedBase64 = base64Image.includes(',')
    ? base64Image.split(',')[1]
    : base64Image;

  // Map short codes to full names for better prompting results
  const languageMap: Record<string, string> = {
    en: 'English',
    hi: 'Hindi',
    kn: 'Kannada',
  };
  const language = languageMap[languageCode] || 'English';

  // The prompt we send to Gemini
  const prompt = `You are a visual assistant for a visually impaired person. Describe this image in one detailed, helpful sentence in ${language}. Mention key objects, people, and their relative positions.`;

  // Request body
  const requestBody = {
    contents: [
      {
        parts: [
          { text: prompt },
          {
            inline_data: {
              mime_type: 'image/jpeg',
              data: cleanedBase64,
            },
          },
        ],
      },
    ],
  };

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`API request failed: ${response.status} ${errorText}`);
    }

    const data = await response.json();

    // Safely extract description
    const description =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ??
      'No description generated.';

    return description;
  } catch (error: any) {
    console.error('Error fetching online description:', error);
    return `Error: ${error.message}`;
  }
}
