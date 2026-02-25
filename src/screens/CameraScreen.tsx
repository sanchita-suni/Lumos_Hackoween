// CameraScreen.tsx
import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';
import { Camera, useCameraDevices } from 'react-native-vision-camera';

export default function CameraScreen() {
  const devices = useCameraDevices();           // get all available camera devices
  // Select the back camera from the array of devices
  const device = devices.find((d) => d.position === 'back');
  const [hasPermission, setHasPermission] = useState(false);
  const [isActive, setIsActive] = useState(true);

  // Request camera & microphone permissions
  useEffect(() => {
    (async () => {
      const camStatus = await Camera.requestCameraPermission();
      const micStatus = await Camera.requestMicrophonePermission();

      // Compare to correct enum values
      const camOK = camStatus === 'granted';
      const micOK = micStatus === 'granted';

      setHasPermission(camOK && micOK);
    })();
  }, []);

  // Guard rendering
  if (!hasPermission) {
    return (
      <View style={styles.center}>
        <Text>Waiting for camera permission...</Text>
      </View>
    );
  }

  if (!device) {
    return (
      <View style={styles.center}>
        <Text>No camera device found</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={isActive}
        onInitialized={() => console.log('Camera initialized')}
      />
      <View style={styles.buttonContainer}>
        <Button
          title="Restart Camera"
          onPress={() => {
            setIsActive(false);
            setTimeout(() => setIsActive(true), 150);
          }}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  buttonContainer: { position: 'absolute', bottom: 20, left: 20 },
});
