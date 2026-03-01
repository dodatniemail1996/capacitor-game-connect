<p align="center">
  <img src="https://s3.amazonaws.com/tw-inlineimages/467579/0/0/ff47c124a5732bf549b43532a7ac19e1.png"/>
</p>
<p align="center">
  <a href="http://www.openforge.io/">Official Website</a> |
  <a href="https://www.youtube.com/@OpenForge/videos">Subscribe to Youtube Channel</a> 
</p>

# Introduction
Capacitor plugin for connecting and using services by Apple Game Center and Google Play Game Services. Features included are access to Sign-In, Leaderboard, Achievements, and Cloud Save (Snapshots).

---

| Capacitor Version | Support Status |
|-------------------|:--------------:|
| Capacitor v8      |    TESTING     | 
| Capacitor v7      |    TESTING     | 
| Capacitor v6      |       ✅       | 
| Capacitor v5      |       ✅       |
| Capacitor v4      |       ✅       |
| Capacitor v3      |       ✅       |

✅ - Supported
🚧 - WIP Support
❌ - No plans to support

## Maintainers

The lovely folks at OpenForge! Feel free to tag any of the following:

| Maintainer | Github |
| ---------- | :----: |
| Ricardo   | @Ricardo385 |
| Paulina | @paulpauldevelops |
| Jedi | @jedihacks |

## Example Projects

Checkout these existing Ionic/Angular/Capacitor mobile game with the plugin installed and integrated:

- [Rock The Steps](https://github.com/openforge/rock-the-steps-app)
- [OpenFarm](https://github.com/openforge/openfarm-puzzle-game)

# Getting Started

## Install

```bash
npm install @openforge/capacitor-game-connect
npx cap sync
```

## Additional Code Setup

## Android

In order to use the plugin, you need to make sure to include this meta-data tag in your `AndroidManifest.xml` file of your app:

```xml
<meta-data android:name="com.google.android.gms.games.APP_ID" android:value="@string/game_services_project_id"/>
```

Then you need to set your Game Services Project ID in your `strings.xml` file inside your `app/src/main/res/values.xml`:

```xml
<string translatable="false"  name="game_services_project_id">YOU_APP_ID</string>
```

- Then on your `MainActivity.class` file you will need to import and register the plugin in your onCreate method:

```ts
@Override
public void onCreate(Bundle savedInstanceState) {
    registerPlugin(CapacitorGameConnectPlugin.class);
    super.onCreate(savedInstanceState);
}
```

## Setup for Android

Follow this guide to configure correctly your Google Play Console to be able to use the Capacitor Game Connect plugin:

1. Go to your [Google Play Console](https://play.google.com/console)
2. If you don't have an app created, create one as a Game.
3. Go to Play Games Services under Grow section.
    - Cick Configuration
    - Select the option 'No, my game doesn't use Google APIs', set a name and click Create.
4. Let's create a OAuth consent screen in Google Cloud Platform:
    - Go to your [Google Cloud Platform](https://console.cloud.google.com/). Make sure you have selected the correct app you want to create the OAuth consent screen.
    - Go to APIs & Services section, then in the sidebar click on OAuth consent screen
    - Choose your User Type (External or Internal) and click Create.
    - Fill the App Informationn required filds and then click on Save and Continue button at the bottom.
    - On the Scopes tab, click on Add or remove scopes and in the Search box type the following:
        - `auth/games` and click enter.
        - Select the two options that appears. `.../auth/games` and `./auth/games_lite`
        - Then start a new search and type `drive.appdata` and select the option showed.
        - Click the Update button.
        - Click Save and Continue button at the bottom.
    - Let's add your Test Users. ** This will be super important because your Google Play Services will only work with these users while is not into Production
        - Click Add Users button and type your users email.
        - Click Add.
        - Click Save and Continue button.
    - And that's all! Click on Back to Dashboard button and then click on Publish App button to finish creating your OAuth consent screen.
    - If you want to modify you information there, simple click on Back To Testing button and then click on Edit App at the top.
5. Back to your Google Play Console
6. In the Credentials section, click on Add Credential
    - Select the Type "Android"
    - Fill the other options
    - On the Authorization section, click Create OAuth client.
        - In the Popup that has been displayed, click on the `Create OAuth Client ID` link attached. This will be open a new window redirecting to the Google Cloud Platform Credentials section.
        - Select the Application Type. Should be Android.
        - Name your OAuth 2.0 client
        - Type your package name of your application.
        - Run the following command in your terminal:
            - `keytool -keystore path-to-debug-or-production-keystore -list -v`
            - If you don't have your keystore created yet, you can follow [this link](https://developer.android.com/studio/publish/app-signing#generate-key) to create it.
            - Once you get your SHA-1 certificate fingerprint, copy and paste it into the required field.
            - Click Create and then back to your Google Play Console.
    - Now that you have completed created your Credential ID, click in the dropdown option and select the one you have created.
    - Click Save Changes button at the bottom.
7. Back to your configurations and click Review and Publish button at the top.
    - Review if there are Actions Required to complete and fill them.

## Creating Achievements on Android

Before use the `Achievement Methods` of the plugin, you need to setup your Achievements and Leaderboards in your Google Play Console following the next steps:

1. Navigate to your Google Play Console portal and select your app.
2. On the sidebar, go to Grow section and then Setup and management
3. Click Leaderboards and configure it by filling the fields. Then click save and publish your changes
4. Click Achievements and configure it by filling the fields. Then click save and publish your changes
5. Make sure all your changes are published by going to the Publishing section.

## Setup for iOS

1. Click on Target App in xcode
2. Add team to Signing and Capabilities
3. Add Game Center Capability
4. Go to your Apps in https://appstoreconnect.apple.com/ and add your application
5. Scroll down in your App Store tab from your application view and check the Game Center field
6. Go to Services tab and configure both Leaderboards and Achievements
7. Go back to App Store tab and select you Leaderboards and Achievements configurations

## Cloud Save (Snapshots) — Android

The plugin supports Google Play Games **Snapshots API** for cloud save, which is required by the [Google Play Games Level Up program](https://developer.android.com/games/guidelines). It allows players to back up and restore game progress across devices.

### Enable Snapshots in the OAuth Consent Screen

When setting up your OAuth consent screen (step 4 above), make sure the `drive.appdata` scope is included — this is what grants access to the Snapshots API.

### Usage

After signing in, you can back up and restore your game state as a JSON string.

```typescript
import { CapacitorGameConnect } from '@openforge/capacitor-game-connect';
import { get, set } from 'idb-keyval';

// Keys that should be backed up (must match your Zustand store keys)
const STORE_KEYS = ['game-store', 'settings-store'];
const SNAPSHOT_NAME = 'game-save';

// Back up all stores to the cloud
export async function backupToCloud(): Promise<void> {
  const backup: Record<string, any> = {};
  for (const key of STORE_KEYS) {
    const value = await get(key);
    if (value !== undefined) backup[key] = value;
  }

  await (CapacitorGameConnect as any).saveSnapshot({
    snapshotName: SNAPSHOT_NAME,
    data: JSON.stringify(backup),
  });
}

// Restore all stores from the cloud. Returns true if data was found.
export async function restoreFromCloud(): Promise<boolean> {
  const result = await (CapacitorGameConnect as any).loadSnapshot({
    snapshotName: SNAPSHOT_NAME,
  });

  if (!result.data) return false;

  const backup = JSON.parse(result.data);
  for (const [key, value] of Object.entries(backup)) {
    await set(key, value as any);
  }

  return true;
}
```

Call these after sign-in in your app bootstrap:

```typescript
await CapacitorGameConnect.signIn();

const restored = await restoreFromCloud();
if (restored) {
  // Reload so Zustand picks up the restored IndexedDB data
  window.location.reload();
}

// Call backupToCloud() after meaningful game events (level complete, purchase, etc.)
await backupToCloud();
```

> **Note:** `saveSnapshot` and `loadSnapshot` are not yet in the plugin's TypeScript definitions. Until they are, cast the client as shown above or extend the type locally:
> ```typescript
> const GameConnect = CapacitorGameConnect as typeof CapacitorGameConnect & {
>   saveSnapshot(options: { snapshotName: string; data: string }): Promise<void>;
>   loadSnapshot(options: { snapshotName: string }): Promise<{ data: string | null }>;
> };
> ```

## API

<docgen-index>

* [`signIn()`](#signin)
* [`showLeaderboard(...)`](#showleaderboard)
* [`submitScore(...)`](#submitscore)
* [`showAchievements()`](#showachievements)
* [`unlockAchievement(...)`](#unlockachievement)
* [`incrementAchievementProgress(...)`](#incrementachievementprogress)
* [`getUserTotalScore(...)`](#getusertotalscore)
* [`getGameCenterCredential()`](#getgamecentercredential)
* [`getGooglePlayCredential(...)`](#getgoogleplaycredential)
* [`saveSnapshot(...)`](#savesnapshot)
* [`loadSnapshot(...)`](#loadsnapshot)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### signIn()

```typescript
signIn() => Promise<{ player_name: string; player_id: string; }>
```

* Method to sign-in a user

**Returns:** <code>Promise&lt;{ player_name: string; player_id: string; }&gt;</code>

--------------------


### showLeaderboard(...)

```typescript
showLeaderboard(options: { leaderboardID: string; }) => Promise<void>
```

* Method to display the Leaderboards

| Param         | Type                                    |
| ------------- | --------------------------------------- |
| **`options`** | <code>{ leaderboardID: string; }</code> |

--------------------


### submitScore(...)

```typescript
submitScore(options: { leaderboardID: string; totalScoreAmount: number; }) => Promise<void>
```

* Method to submit a score to the Google Play Services SDK

| Param         | Type                                                              |
| ------------- | ----------------------------------------------------------------- |
| **`options`** | <code>{ leaderboardID: string; totalScoreAmount: number; }</code> |

--------------------


### showAchievements()

```typescript
showAchievements() => Promise<void>
```

* Method to display the Achievements view

--------------------


### unlockAchievement(...)

```typescript
unlockAchievement(options: { achievementID: string; }) => Promise<void>
```

* Method to unlock an achievement

| Param         | Type                                    |
| ------------- | --------------------------------------- |
| **`options`** | <code>{ achievementID: string; }</code> |

--------------------


### incrementAchievementProgress(...)

```typescript
incrementAchievementProgress(options: { achievementID: string; pointsToIncrement: number; }) => Promise<void>
```

* Method to increment the progress of an achievement

| Param         | Type                                                               |
| ------------- | ------------------------------------------------------------------ |
| **`options`** | <code>{ achievementID: string; pointsToIncrement: number; }</code> |

--------------------


### getUserTotalScore(...)

```typescript
getUserTotalScore(options: { leaderboardID: string; }) => Promise<PlayerScore>
```

* Method to get total player score from a leaderboard

| Param         | Type                                    | Description |
| ------------- | --------------------------------------- | ----------- |
| **`options`** | <code>{ leaderboardID: string; }</code> | : string }  |

**Returns:** <code>Promise&lt;<a href="#playerscore">PlayerScore</a>&gt;</code>

--------------------


### getGameCenterCredential()

```typescript
getGameCenterCredential() => Promise<{ credential: string; providerId: string; }>
```

* Method to get Game Center authentication credential

**Returns:** <code>Promise&lt;{ credential: string; providerId: string; }&gt;</code>

--------------------


### getGooglePlayCredential(...)

```typescript
getGooglePlayCredential(options: { serverClientId: string; }) => Promise<{ credential: string; providerId: string; }>
```

* Method to get Google Play Games authentication credential

| Param         | Type                                     |
| ------------- | ---------------------------------------- |
| **`options`** | <code>{ serverClientId: string; }</code> |

**Returns:** <code>Promise&lt;{ credential: string; providerId: string; }&gt;</code>

--------------------


### saveSnapshot(...)

```typescript
saveSnapshot(options: { snapshotName: string; data: string; }) => Promise<void>
```

* Method to save game data to a Google Play Games cloud snapshot
* Android only — required for Google Play Games Level Up program

| Param         | Type                                                 |
| ------------- | ---------------------------------------------------- |
| **`options`** | <code>{ snapshotName: string; data: string; }</code> |

--------------------


### loadSnapshot(...)

```typescript
loadSnapshot(options: { snapshotName: string; }) => Promise<{ data: string | null; }>
```

* Method to load game data from a Google Play Games cloud snapshot
* Android only — returns null if no snapshot exists yet (e.g. first install)

| Param         | Type                                   |
| ------------- | -------------------------------------- |
| **`options`** | <code>{ snapshotName: string; }</code> |

**Returns:** <code>Promise&lt;{ data: string | null; }&gt;</code>

--------------------


### Interfaces


#### PlayerScore

| Prop               | Type                |
| ------------------ | ------------------- |
| **`player_score`** | <code>number</code> |

</docgen-api>

# Testing Limitations

### Android
In order to test the functionality, you must have a physical Android device. Trying to connect to Google Play Services through Android Studio Emulator/Simulator will not work.
Note: Certain functionality may require having to sign your APK when building to your device.