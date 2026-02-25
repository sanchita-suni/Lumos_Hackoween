import NetInfo from '@react-native-community/netinfo';
import { Vibration } from 'react-native';

// NOTE: You will need to create these files/functions later.
// For now, these imports are placeholders.
import { fetchOnlineDescription } from './onlineDescriber';
import { getOfflineDetections } from './offlineDetector';

/**
 * A simple function to pluralize words.
 * @param word The word to pluralize.
 * @param count The count of the word.
 * @returns The word, correctly pluralized if the count is not 1.
 */
const pluralize = (word: string, count: number): string => {
  if (count !== 1) {
    // A very simple pluralization rule. We will improve this later if needed.
    return `${word}s`;
  }
  return word;
};

/**
 * Takes a list of detected objects and synthesizes a simple sentence.
 * @param detections An array of strings, e.g., ['car', 'person', 'car'].
 * @returns A synthesized sentence, e.g., "I see two cars and one person."
 */
export const synthesizeOfflineDescription = (detections: string[]): string => {
  // Use a Map to store the counts of each detected object.
  const counts = new Map<string, number>();

  // Iterate through the detections and tally the counts.
  for (const detection of detections) {
    counts.set(detection, (counts.get(detection) || 0) + 1);
  }

  // Build the sentence from the tallied counts.
  let sentence = 'I see ';
  const phrases: string[] = [];

  // Iterate through the Map entries and create a phrase for each object.
  for (const [object, count] of counts.entries()) {
    const word = pluralize(object, count);
    phrases.push(`${count} ${word}`);
  }

  // Join the phrases with "and" for the final sentence.
  if (phrases.length > 1) {
    const lastPhrase = phrases.pop();
    sentence += phrases.join(', ') + ' and ' + lastPhrase;
  } else {
    sentence += phrases[0] || 'nothing'; // Handle the case where no objects are detected.
  }

  return sentence;
};

/**
 * The master function that intelligently switches between online and offline AI modules.
 * @param image The image to be processed.
 * @param language The target language for the description.
 */
export const describeSmart = async (image: any, language: string): Promise<string> => {
  // 1. Acknowledge the user's tap with a quick haptic pulse.
  Vibration.vibrate();

  // 2. Check the device's current internet connection status.
  const state = await NetInfo.fetch();
  const isConnected = state.isConnected;

  // 3. Use a conditional statement to decide which AI to use.
  if (isConnected) {
    // If online, use Tan's premium Gemini-based module.
    console.log("Online: Calling Tan's fetchOnlineDescription...");
    return fetchOnlineDescription(image, language);
  } else {
    // If offline, get the detections and synthesize a sentence.
    console.log("Offline: Calling San's getOfflineDetections...");
    const detections = getOfflineDetections();
    return synthesizeOfflineDescription(detections);
  }
};
