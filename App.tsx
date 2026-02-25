import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  StatusBar,
  Button,
  useColorScheme,
  Vibration
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { SafeAreaProvider, useSafeAreaInsets } from 'react-native-safe-area-context';
import { initI18n } from './src/i18n/i18n';

// Teammate’s component
import { ObjectDetector } from './src/components/ObjectDetector';
// AI smart switch
import { describeSmart } from './src/ai/smartSwitch';

const AppContent = () => {
  const { t, i18n } = useTranslation();
  const safeAreaInsets = useSafeAreaInsets();
  const isDarkMode = useColorScheme() === 'dark';
  const [descriptionText, setDescriptionText] = useState('Tap to get a description.');
  const [isProcessing, setIsProcessing] = useState(false);
  const [currentLanguage, setCurrentLanguage] = useState('en');

  const handleDescribePress = async () => {
    Vibration.vibrate();
    console.log('Button pressed!');
    setIsProcessing(true);

    try {
      // Fetch a real image and convert it to a valid Base64 string
      const response = await fetch('https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSX-Phw5O0_2nLYA9d6SHDEOLDhrhw1dS-6BtzxryiZ3uby5uS2');
      const blob = await response.blob();
      const reader = new FileReader();
      reader.readAsDataURL(blob);
      reader.onloadend = async () => {
        const base64data = reader.result;
        const result = await describeSmart(base64data, currentLanguage);
        setDescriptionText(result);
      };
    } catch (error) {
      console.error('Error during description:', error);
      setDescriptionText(t('ui.error_generic'));
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <SafeAreaView style={[styles.container, { paddingTop: safeAreaInsets.top }]}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />

      {/* Teammate’s camera component */}
      {/* <ObjectDetector /> */}

      {/* Description text */}
      <View style={styles.content}>
        <Text style={styles.description}>{descriptionText}</Text>
      </View>

      {/* Buttons */}
      <View style={styles.buttonContainer}>
        <TouchableOpacity
          style={styles.button}
          onPress={handleDescribePress}
          disabled={isProcessing}>
          <Text style={styles.buttonText}>
            {isProcessing ? t('ui.thinking') : t('ui.tap_to_describe')}
          </Text>
        </TouchableOpacity>

        {/* Language switching */}
        <View style={styles.languageButtons}>
          <Button title="English" onPress={() => { setCurrentLanguage('en'); i18n.changeLanguage('en'); }} />
          <Button title="Hindi" onPress={() => { setCurrentLanguage('hi'); i18n.changeLanguage('hi'); }} />
          <Button title="Kannada" onPress={() => { setCurrentLanguage('kn'); i18n.changeLanguage('kn'); }} />
        </View>
      </View>
    </SafeAreaView>
  );
};

const App = () => {
  const [isI18nInitialized, setIsI18nInitialized] = useState(false);

  useEffect(() => {
    initI18n().then(() => setIsI18nInitialized(true));
  }, []);

  if (!isI18nInitialized) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>Loading...</Text>
      </View>
    );
  }

  return (
    <SafeAreaProvider>
      <AppContent />
    </SafeAreaProvider>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000', // black background
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  description: {
    fontSize: 24,
    textAlign: 'center',
    color: 'pink',
    fontWeight: '600',
  },
  buttonContainer: {
    marginBottom: 50,
    alignItems: 'center',
  },
  button: {
    backgroundColor: 'pink',
    paddingVertical: 15,
    paddingHorizontal: 40,
    borderRadius: 30,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  languageButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 20,
    width: '100%',
  },
});

export default App;
