// src/components/ObjectDetector.tsx

import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Linking } from 'react-native';
import {
  Camera,
  useCameraDevice,
  useFrameProcessor,
} from 'react-native-vision-camera';
import { useTensorflowModel, Tflite } from 'react-native-fast-tflite';
import { runOnJS } from 'react-native-reanimated';
import { setLatestDetections } from '../ai/offlineDetector';

// Define the structure of a single detection result from the model
interface DetectionResult {
  confidence: number;
  label: string;
}

export const ObjectDetector = () => {
  const device = useCameraDevice('back');
  const [hasPermission, setHasPermission] = useState(false);

  // 1. Load the TFLite model from the assets folder
  const { model, state } = useTensorflowModel(
    require('../../assets/ssd_mobilenet_v2.tflite'),
  );

  // State to hold the detected object labels
  const [detectedLabels, setDetectedLabels] = useState<string[]>([]);

  // 2. Request Camera Permissions
  useEffect(() => {
    const checkPermissions = async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
    };
    checkPermissions();
  }, []);

  // 3. Create the Frame Processor
  // This function runs for every frame the camera captures.
  // --- Create the Frame Processor ---
  const frameProcessor = useFrameProcessor(
    (frame) => {
      'worklet'; // This annotation is important!
      if (!model.value) {
        return; // Model is not ready yet
      }

      // Run object detection on the current frame
      const results: DetectionResult[] = Tflite.detectObject(frame, model.value, {
        // Temporarily lower the threshold to see all results
        scoreThreshold: 0.1,
      });

      const processResultsOnJsThread = (detectedObjects: DetectionResult[]) => {
        // This will print the raw data to your Metro terminal!
        console.log('AI Results:', detectedObjects);

        // We only want to display labels with high confidence
        const highConfidenceLabels = detectedObjects
          .filter(result => result.confidence > 0.5)
          .map(result => result.label);

        setLatestDetections(highConfidenceLabels);
        setDetectedLabels(highConfidenceLabels);
      };

      // Update the component's state on the main UI thread
      runOnJS(processResultsOnJsThread)(results);
      
      // The extra ');' that caused the error was here. It has been removed.
    },
    [model], // The dependency array
  );

  // Render a message while waiting for permissions or if no device is found
  if (!device) {
    return <Text style={styles.infoText}>No camera device found.</Text>;
  }

  if (!hasPermission) {
    return (
      <View style={styles.container}>
        <Text style={styles.infoText}>
          Camera permission is required to use this feature.
        </Text>
        <Text style={styles.linkText} onPress={() => Linking.openSettings()}>
          Open Settings
        </Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        // Attach the frame processor to the camera
        frameProcessor={frameProcessor}
      />
      <View style={styles.labelContainer}>
        <Text style={styles.labelText}>
          {/* Display a loading message or the detected labels */}
          {state === 'loading' && 'Loading model...'}
          {state === 'ready' &&
            (detectedLabels.length > 0
              ? detectedLabels.join(', ')
              : 'Detecting...')}
          {state === 'error' && 'Failed to load model.'}
        </Text>
      </View>
    </View>
  );
};

// --- Styles ---
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'black',
  },
  infoText: {
    color: 'white',
    fontSize: 18,
    textAlign: 'center',
    margin: 20,
  },
  linkText: {
    color: '#007AFF', // A standard blue link color
    fontSize: 16,
    textAlign: 'center',
  },
  labelContainer: {
    position: 'absolute',
    bottom: 40,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 15,
    paddingVertical: 10,
    borderRadius: 8,
  },
  labelText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
});