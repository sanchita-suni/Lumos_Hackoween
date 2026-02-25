import React from "react";
import { View, Button, Text } from "react-native";
import { useTranslation } from "react-i18next";
import i18n, { setSavedLanguage } from "./i18n";

export const LanguageSelector = () => {
  const { t } = useTranslation();
  const change = async (lang: "en" | "hi" | "kn") => {
    await i18n.changeLanguage(lang);
    await setSavedLanguage(lang);
  };
  return (
    <View>
      <Text>{t("ui.language")}</Text>
      <Button title="English" onPress={() => change("en")} />
      <Button title="हिंदी" onPress={() => change("hi")} />
      <Button title="ಕನ್ನಡ" onPress={() => change("kn")} />
    </View>
  );
};
