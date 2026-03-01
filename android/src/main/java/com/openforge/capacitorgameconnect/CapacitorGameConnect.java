package com.openforge.capacitorgameconnect;

import android.content.Intent;
import android.util.Log;

import androidx.activity.result.ActivityResultLauncher;
import androidx.appcompat.app.AppCompatActivity;

import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;
import com.google.android.gms.games.GamesSignInClient;
import com.google.android.gms.games.PlayGames;
import com.google.android.gms.games.leaderboard.LeaderboardVariant;
import com.google.android.gms.games.AuthenticationResult;

import com.google.android.gms.games.SnapshotsClient;
import com.google.android.gms.games.snapshot.Snapshot;
import com.google.android.gms.games.snapshot.SnapshotMetadataChange;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;

public class CapacitorGameConnect {

    private AppCompatActivity activity;
    private static final String TAG = "CapacitorGameConnect";

    public CapacitorGameConnect(AppCompatActivity activity) {
        this.activity = activity;
    }

    /**
     * * Method to sign-in a user to Google Play Services
     *
     * @param call as PluginCall
     * @param resultCallback as SignInCallback
     */
    public void signIn(PluginCall call, final SignInCallback resultCallback) {
        Log.i(TAG, "SignIn method called");
        GamesSignInClient gamesSignInClient = PlayGames.getGamesSignInClient(this.activity);

        gamesSignInClient
            .isAuthenticated()
            .addOnCompleteListener(
                isAuthenticatedTask -> {
                    boolean isAuthenticated = (isAuthenticatedTask.isSuccessful() && isAuthenticatedTask.getResult().isAuthenticated());

                    if (isAuthenticated) {
                        Log.i(TAG, "User is already authenticated");
                        resultCallback.success();
                    } else {
                        gamesSignInClient
                                .signIn()
                                .addOnSuccessListener(signInResponse -> {
                                    if (signInResponse.isAuthenticated()) {
                                        Log.i(TAG, "Sign-in completed successful");
                                        resultCallback.success();
                                    } else {
                                        Log.i(TAG, "Sign-in failed or cancelled");
                                        resultCallback.error("Sign-in failed or cancelled");
                                    }
                                })
                                .addOnFailureListener(e -> {
                                    Log.i(TAG, "Sign-in failed with exception", e);
                                    resultCallback.error(e.getMessage());
                                });
                    }
                }
            )
            .addOnFailureListener(e -> resultCallback.error(e.getMessage()));
    }

    /**
     * * Method to fetch the logged in Player
     *
     * @param resultCallback as PlayerResultCallback
     */
    public void fetchUserInformation(final PlayerResultCallback resultCallback) {
        PlayGames
            .getPlayersClient(this.activity)
            .getCurrentPlayer()
            .addOnSuccessListener(
                player -> {
                    resultCallback.success(player);
                }
            )
            .addOnFailureListener(e -> resultCallback.error(e.getMessage()));
    }

    /**
     * * Method to display the Leaderboards view from Google Play Services SDK
     *
     * @param call as PluginCall
     * @param startActivityIntent as ActivityResultLauncher<Intent>
     */
    public void showLeaderboard(PluginCall call, ActivityResultLauncher<Intent> startActivityIntent) {
        Log.i(TAG, "showLeaderboard has been called");
        var leaderboardID = call.getString("leaderboardID");
        PlayGames
            .getLeaderboardsClient(this.activity)
            .getLeaderboardIntent(leaderboardID)
            .addOnSuccessListener(intent -> startActivityIntent.launch(intent))
            .addOnFailureListener(e -> Log.e(TAG, "Failed to get leaderboard intent", e));
    }

    /**
     * * Method to submit a score to the Google Play Services SDK
     *
     * @param call as PluginCall
     */
    public void submitScore(PluginCall call) {
        Log.i(TAG, "submitScore has been called");
        var leaderboardID = call.getString("leaderboardID");
        var totalScoreAmount = call.getInt("totalScoreAmount");
        PlayGames.getLeaderboardsClient(this.activity).submitScore(leaderboardID, totalScoreAmount);
    }

    /**
     * * Method to display the Achievements view from Google Play SDK
     *
     * @param startActivityIntent as ActivityResultLauncher<Intent>
     */
    public void showAchievements(ActivityResultLauncher<Intent> startActivityIntent) {
        Log.i(TAG, "showAchievements has been called");
        PlayGames
            .getAchievementsClient(this.activity)
            .getAchievementsIntent()
            .addOnSuccessListener(intent -> startActivityIntent.launch(intent))
            .addOnFailureListener(e -> Log.e(TAG, "Failed to get achievements intent", e));
    }

    /**
     * * Method to unlock an achievement
     */
    public void unlockAchievement(PluginCall call) {
        Log.i(TAG, "unlockAchievement has been called");
        var achievementID = call.getString("achievementID");
        PlayGames.getAchievementsClient(this.activity).unlock(achievementID);
    }

    /**
     * * Method to increment the progress of an achievement
     */
    public void incrementAchievementProgress(PluginCall call) {
        Log.i(TAG, "incrementAchievementProgress has been called");
        var achievementID = call.getString("achievementID");
        var pointsToIncrement = call.getInt("pointsToIncrement");
        PlayGames.getAchievementsClient(this.activity).increment(achievementID, pointsToIncrement);
    }

    /**
     * * Method to get the total player score from a leaderboard
     */
    public void getUserTotalScore(PluginCall call) {
        Log.i(TAG, "getUserTotalScore has been called");
        var leaderboardID = call.getString("leaderboardID");
        var leaderboardScore = PlayGames
            .getLeaderboardsClient(this.activity)
            .loadCurrentPlayerLeaderboardScore(leaderboardID, LeaderboardVariant.TIME_SPAN_ALL_TIME, LeaderboardVariant.COLLECTION_PUBLIC);
        leaderboardScore
            .addOnSuccessListener(leaderboardScoreAnnotatedData -> {
                if (leaderboardScoreAnnotatedData != null) {
                    long userTotalScore = 0;
                    if (leaderboardScoreAnnotatedData.get() != null) {
                        userTotalScore = leaderboardScoreAnnotatedData.get().getRawScore();
                    }
                    JSObject result = new JSObject();
                    result.put("player_score", userTotalScore);
                    call.resolve(result);
                } else {
                    JSObject result = new JSObject();
                    result.put("player_score", 0);
                    call.resolve(result);
                }
            })
            .addOnFailureListener(e -> {
                Log.e(TAG, "Error getting player score", e);
                call.reject("Error getting player score: " + e.getMessage());
            });
    }

    /**
     * * Method to get Google Play Games authentication credential for Firebase
     *
     * @param call as PluginCall
     */
    public void getGooglePlayCredential(PluginCall call) {
        Log.i(TAG, "getGooglePlayCredential has been called");

        GamesSignInClient gamesSignInClient = PlayGames.getGamesSignInClient(this.activity);

        gamesSignInClient
            .isAuthenticated()
            .addOnCompleteListener(
                isAuthenticatedTask -> {
                    boolean isAuthenticated = (isAuthenticatedTask.isSuccessful() && isAuthenticatedTask.getResult().isAuthenticated());

                    if (!isAuthenticated) {
                        call.reject("User is not authenticated with Google Play Games");
                        return;
                    }

                    String serverClientId = call.getString("serverClientId", "");
                    if (serverClientId.isEmpty()) {
                        call.reject("serverClientId is required for Google Play Games credential");
                        return;
                    }

                    gamesSignInClient
                        .requestServerSideAccess(serverClientId, false)
                        .addOnCompleteListener(task -> {
                            if (task.isSuccessful()) {
                                String serverAuthCode = task.getResult();

                                JSObject credentialData = new JSObject();
                                credentialData.put("serverAuthCode", serverAuthCode);

                                JSObject result = new JSObject();
                                result.put("credential", credentialData);
                                result.put("providerId", "playgames.google.com");

                                call.resolve(result);
                            } else {
                                Log.e(TAG, "Failed to get server auth code", task.getException());
                                call.reject("Failed to get Google Play Games credential: " + task.getException().getMessage());
                            }
                        });
                }
            )
            .addOnFailureListener(e -> {
                Log.e(TAG, "Error checking authentication status", e);
                call.reject("Error checking authentication status: " + e.getMessage());
            });
    }

    // Save to cloud
    public void saveSnapshot(String snapshotName, String data, PluginCall call) {
        SnapshotsClient snapshotsClient = PlayGames.getSnapshotsClient(this.activity);

        snapshotsClient.open(snapshotName, true, SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED)
            .addOnSuccessListener(dataOrConflict -> {
                if (dataOrConflict.isConflict()) {
                    Snapshot snapshot = dataOrConflict.getConflict().getSnapshot();
                    resolveConflictAndSave(snapshotsClient, dataOrConflict.getConflict().getConflictId(), snapshot, data, call);
                    return;
                }

                Snapshot snapshot = dataOrConflict.getData();
                try {
                    snapshot.getSnapshotContents().writeBytes(data.getBytes("UTF-8"));
                    SnapshotMetadataChange metadataChange = new SnapshotMetadataChange.Builder()
                        .setDescription("Game save")
                        .build();
                    snapshotsClient.commitAndClose(snapshot, metadataChange)
                        .addOnSuccessListener(meta -> call.resolve())
                        .addOnFailureListener(e -> call.reject("Save failed: " + e.getMessage()));
                } catch (Exception e) {
                    call.reject("Error writing snapshot: " + e.getMessage());
                }
            })
            .addOnFailureListener(e -> call.reject("Failed to open snapshot: " + e.getMessage()));
    }

    private void resolveConflictAndSave(SnapshotsClient client, String conflictId, Snapshot snapshot, String data, PluginCall call) {
        try {
            snapshot.getSnapshotContents().writeBytes(data.getBytes("UTF-8"));
            SnapshotMetadataChange metadataChange = new SnapshotMetadataChange.Builder()
                .setDescription("Game save")
                .build();
            client.resolveConflict(conflictId, snapshot)
                .addOnSuccessListener(r -> call.resolve())
                .addOnFailureListener(e -> call.reject("Conflict resolve failed: " + e.getMessage()));
        } catch (Exception e) {
            call.reject("Error resolving conflict: " + e.getMessage());
        }
    }

    // Load from cloud
    public void loadSnapshot(String snapshotName, PluginCall call) {
        SnapshotsClient snapshotsClient = PlayGames.getSnapshotsClient(this.activity);

        snapshotsClient.open(snapshotName, false, SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED)
            .addOnSuccessListener(dataOrConflict -> {
                Snapshot snapshot = dataOrConflict.isConflict()
                    ? dataOrConflict.getConflict().getSnapshot()
                    : dataOrConflict.getData();

                try {
                    byte[] bytes = snapshot.getSnapshotContents().readFully();
                    String data = new String(bytes, "UTF-8");
                    snapshotsClient.discardAndClose(snapshot);

                    JSObject result = new JSObject();
                    result.put("data", data);
                    call.resolve(result);
                } catch (Exception e) {
                    call.reject("Error reading snapshot: " + e.getMessage());
                }
            })
            .addOnFailureListener(e -> {
                // Snapshot doesn't exist yet — fine for first launch
                JSObject result = new JSObject();
                result.put("data", null);
                call.resolve(result);
            });
    }
}