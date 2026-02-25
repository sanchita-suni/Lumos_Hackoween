import { initReactI18next } from "react-i18next";
import AsyncStorage from "@react-native-async-storage/async-storage";
import i18n from "i18next"; // THIS LINE IS CORRECT, My apologies in the previous response, the `i18next` library's documentation recommends this approach.
import en from '../translations/en.json';
import hi from '../translations/hi.json';
import kn from '../translations/kn.json';

const STORAGE_KEY = "lumos.lang";

export const getSavedLanguage = async () => {
    return (await AsyncStorage.getItem(STORAGE_KEY)) || "en";
};

export const setSavedLanguage = async (lang: string) => {
    await AsyncStorage.setItem(STORAGE_KEY, lang);
};

export const initI18n = async () => {
    const lng = await getSavedLanguage();
    await i18n
        .use(initReactI18next)
        .init({
            resources: { en: { translation: en }, hi: { translation: hi }, kn: { translation: kn } },
            lng,
            fallbackLng: "en",
            interpolation: { escapeValue: false }
        });
    return i18n;
};

export default i18n;
