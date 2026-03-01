import type { PlayerScore } from './interfaces/player-score.interface';

export interface CapacitorGameConnectPlugin {
  /**
   * * Method to sign-in a user
   */
  signIn(): Promise<{
    player_name: string;
    player_id: string;
  }>;

  /**
   * * Method to display the Leaderboards
   *
   * @param leaderboardID as string
   */
  showLeaderboard(options: { leaderboardID: string }): Promise<void>;

  /**
   * * Method to submit a score to the Google Play Services SDK
   */
  submitScore(options: {
    leaderboardID: string;
    totalScoreAmount: number;
  }): Promise<void>;

  /**
   * * Method to display the Achievements view
   */
  showAchievements(): Promise<void>;

  /**
   * * Method to unlock an achievement
   */
  unlockAchievement(options: { achievementID: string }): Promise<void>;

  /**
   * * Method to increment the progress of an achievement
   */
  incrementAchievementProgress(options: {
    achievementID: string;
    pointsToIncrement: number;
  }): Promise<void>;

  /**
   * * Method to get total player score from a leaderboard
   *
   * @param options { leaderboardID: string }
   */
  getUserTotalScore(options: { leaderboardID: string }): Promise<PlayerScore>;

  /**
   * * Method to get Game Center authentication credential
   */
  getGameCenterCredential(): Promise<{
    credential: string;
    providerId: string;
  }>;

  /**
   * * Method to get Google Play Games authentication credential
   */
  getGooglePlayCredential(options: { serverClientId: string }): Promise<{
    credential: string;
    providerId: string;
  }>;

  /**
   * * Method to save game data to a Google Play Games cloud snapshot
   * * Android only — required for Google Play Games Level Up program
   *
   * @param options.snapshotName - unique name for the save slot (default: "game-save")
   * @param options.data - JSON string of the game state to persist
   */
  saveSnapshot(options: {
    snapshotName: string;
    data: string;
  }): Promise<void>;

  /**
   * * Method to load game data from a Google Play Games cloud snapshot
   * * Android only — returns null if no snapshot exists yet (e.g. first install)
   *
   * @param options.snapshotName - name of the save slot to load
   */
  loadSnapshot(options: {
    snapshotName: string;
  }): Promise<{ data: string | null }>;
}