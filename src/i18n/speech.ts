import Tts from 'react-native-tts';
import i18n from './i18n';

/**
 * Speaks a translated string using React Native TTS.
 * Automatically selects the correct voice language based on the current i18n locale.
 * @param key The i18n translation key to speak.
 * @param vars Optional interpolation variables for the translation.
 */
export const speakKey = (key: string, vars: Record<string, string> = {}) => {
  const text = i18n.t(key, vars) as string;
  const lang = i18n.language;

  // Map i18n language codes to TTS locale codes
  const langMap: Record<string, string> = {
    hi: 'hi-IN',
    kn: 'kn-IN',
    en: 'en-US',
  };

  const ttsLanguage = langMap[lang] || 'en-US';

  Tts.stop();
  Tts.setDefaultLanguage(ttsLanguage);
  Tts.speak(text);
};

/**
 * Speaks arbitrary text using React Native TTS.
 * @param text The text string to speak.
 * @param languageCode Optional language code (defaults to current i18n language).
 */
export const speakText = (text: string, languageCode?: string) => {
  const lang = languageCode || i18n.language;
  const langMap: Record<string, string> = {
    hi: 'hi-IN',
    kn: 'kn-IN',
    en: 'en-US',
  };
  const ttsLanguage = langMap[lang] || 'en-US';

  Tts.stop();
  Tts.setDefaultLanguage(ttsLanguage);
  Tts.speak(text);
};