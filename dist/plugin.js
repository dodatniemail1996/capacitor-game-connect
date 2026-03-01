var capacitorCapacitorGameConnect = (function (exports, core) {
    'use strict';

    const CapacitorGameConnect = core.registerPlugin('CapacitorGameConnect', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.CapacitorGameConnectWeb()),
    });

    class CapacitorGameConnectWeb extends core.WebPlugin {
        /**
         * * Method to sign-in a user to Google Play Services
         * * TODO: migrate interface to a different file
         * * Add web support for signIn
         */
        async signIn() {
            return Promise.resolve({});
        }
        /**
         * Method to display the Leaderboards view from Google Play Services SDK
         *
         * @param leaderboardID as string
         */
        async showLeaderboard(options) {
            console.info('showLeaderboard function has been called', options);
            return Promise.resolve();
        }
        /**
         * * Method to submit a score to the Google Play Services SDK
         *
         * @returns Promise
         */
        async submitScore(options) {
            console.info('submitScore function has been called', options);
            return Promise.resolve();
        }
        /**
         * * Method to display the Achievements view from Google Play SDK
         *
         * @returns Promise
         */
        async showAchievements() {
            return Promise.resolve();
        }
        /**
         * * Method to unlock an achievement
         *
         * @returns  Promise
         */
        async unlockAchievement(options) {
            console.info('unlockAchievement function has been called', options);
            return Promise.resolve();
        }
        /**
         * * Method to increment the progress of an achievement
         *
         * @returns Promise
         */
        async incrementAchievementProgress(options) {
            console.info('incrementAchievementProgress function has been called', options);
            return Promise.resolve();
        }
        /**
         * * Function to get the total player score from a specific leaderboard
         *
         * @param options { leaderboardID: string }
         * @returns Promise<PlayerScore>
         */
        async getUserTotalScore(options) {
            console.info('getUserTotalScore function has been called', options);
            return Promise.resolve({});
        }
        /**
         * * Method to get Game Center authentication credential (Web not supported)
         *
         * @returns Promise
         */
        async getGameCenterCredential() {
            console.info('getGameCenterCredential function has been called');
            return Promise.reject('Game Center authentication not supported on web');
        }
        /**
         * * Method to get Google Play Games authentication credential (Web not supported)
         *
         * @returns Promise
         */
        async getGooglePlayCredential(options) {
            console.info('getGooglePlayCredential function has been called', options);
            return Promise.reject('Google Play Games authentication not supported on web');
        }
        /**
         * * Method to save a snapshot to Google Play Games cloud (Android only)
         *
         * @returns Promise
         */
        async saveSnapshot(options) {
            console.info('saveSnapshot function has been called', options);
            throw this.unimplemented('saveSnapshot is not available on web.');
        }
        /**
         * * Method to load a snapshot from Google Play Games cloud (Android only)
         *
         * @returns Promise
         */
        async loadSnapshot(options) {
            console.info('loadSnapshot function has been called', options);
            throw this.unimplemented('loadSnapshot is not available on web.');
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        CapacitorGameConnectWeb: CapacitorGameConnectWeb
    });

    exports.CapacitorGameConnect = CapacitorGameConnect;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
