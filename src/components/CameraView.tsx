import React, {forwardRef, useEffect, useState} from 'react';
import {StyleSheet, Text, View} from 'react-native';
import {Camera, useCameraDevice} from 'react-native-vision-camera';

// We use forwardRef to pass the cameraRef from App.tsx to the Camera component
export const CameraView = forwardRef<Camera>((props, ref) => {
  const [hasPermission, setHasPermission] = useState(false);
  const device = useCameraDevice('back');

  useEffect(() => {
    // Function to request camera permission
    const getPermission = async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
    };
    getPermission();
  }, []);

  // If the camera device is not available, show a message
  if (device == null) {
    return (
      <View style={styles.container}>
        <Text>Camera not available</Text>
      </View>
    );
  }

  // If permission is not granted yet, show a message
  if (!hasPermission) {
    return (
      <View style={styles.container}>
        <Text>No camera permission</Text>
      </View>
    );
  }

  // If we have a device and permission, render the Camera view
  return (
    <Camera
      ref={ref}
      style={StyleSheet.absoluteFill}
      device={device}
      isActive={true}
      photo={true} // Enable photo capture
    />
  );
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});