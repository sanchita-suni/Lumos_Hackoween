/**
 * offlineDetector.ts
 *
 * Shared state bridge between ObjectDetector (camera frame processor) and
 * smartSwitch (AI router). ObjectDetector writes detections here on every
 * processed frame; smartSwitch reads from here when the device is offline.
 */

// Module-level cache — updated by ObjectDetector continuously.
let latestDetections: string[] = [];

/**
 * Called by ObjectDetector to store the latest high-confidence object labels.
 * @param labels Array of detected object label strings.
 */
export const setLatestDetections = (labels: string[]): void => {
  latestDetections = labels;
};

/**
 * Returns the most recently detected object labels.
 * Called by smartSwitch when the device has no internet connection.
 */
export const getOfflineDetections = (): string[] => {
  return latestDetections;
};
