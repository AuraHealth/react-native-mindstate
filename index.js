// index.js
import { NativeModules, Platform } from "react-native";

const { RNMindState } = NativeModules;

const ERRORS = {
  PLATFORM: "RNMindState is only available on iOS",
  UNAVAILABLE: "State of Mind tracking is not available on this device",
  UNAUTHORIZED: "Health data access not authorized",
  INVALID_PARAMS: "Invalid parameters provided",
};

class MindState {
  constructor() {
    if (Platform.OS !== "ios") {
      console.warn(ERRORS.PLATFORM);
    }
  }

  /**
   * Check if State of Mind tracking is available on the device
   * @returns {Promise<boolean>} Promise resolving to availability status
   */
  isAvailable() {
    if (Platform.OS !== "ios") return Promise.resolve(false);
    return RNMindState.isAvailable();
  }

  /**
   * Request authorization to access HealthKit State of Mind data
   * @returns {Promise<boolean>} Promise resolving to authorization status
   */
  async requestAuthorization() {
    if (Platform.OS !== "ios") throw new Error(ERRORS.PLATFORM);

    const isAvailable = await this.isAvailable();
    if (!isAvailable) throw new Error(ERRORS.UNAVAILABLE);

    return RNMindState.requestAuthorization();
  }

  /**
   * Query State of Mind data within a date range
   * @param {Object} options Query options
   * @param {Date} options.startDate Start date for the query
   * @param {Date} options.endDate End date for the query
   * @param {string} [options.mood] Optional mood filter ('great', 'good', 'neutral', 'bad', 'terrible')
   * @param {string} [options.limit] Optional limit for number of results
   * @returns {Promise<Array>} Promise resolving to array of mind state entries
   */
  async queryMindStates(options = {}) {
    if (Platform.OS !== "ios") throw new Error(ERRORS.PLATFORM);

    if (!options.startDate || !options.endDate) {
      throw new Error(ERRORS.INVALID_PARAMS);
    }

    const isAvailable = await this.isAvailable();
    if (!isAvailable) throw new Error(ERRORS.UNAVAILABLE);

    const params = {
      startDate: options.startDate.toISOString(),
      endDate: options.endDate.toISOString(),
      mood: options.mood,
      limit: options.limit,
    };

    return RNMindState.queryMindStates(params);
  }

  /**
   * Get the latest recorded mind state
   * @returns {Promise<Object>} Promise resolving to the latest mind state entry
   */
  async getLatestMindState() {
    if (Platform.OS !== "ios") throw new Error(ERRORS.PLATFORM);

    const isAvailable = await this.isAvailable();
    if (!isAvailable) throw new Error(ERRORS.UNAVAILABLE);

    return RNMindState.getLatestMindState();
  }
}

export default new MindState();
