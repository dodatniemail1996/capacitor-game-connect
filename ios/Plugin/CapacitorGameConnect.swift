import Foundation
import GameKit
import Capacitor
import AuthenticationServices

#if canImport(UIKit)
import UIKit
#endif

@objc public class CapacitorGameConnect: NSObject, GKGameCenterControllerDelegate {
    private var pendingSignInCalls: [CAPPluginCall] = []
    private var isPresentingAuth = false

    private func describeGameKitError(_ error: Error) -> String {
        if let gkError = error as? GKError {
            return "\(gkError.localizedDescription) (GKError code \(gkError.code.rawValue))"
        }
        let nsError = error as NSError
        return "\(nsError.localizedDescription) (\(nsError.domain) code \(nsError.code))"
    }

    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true);
    }

    private func topMostViewController(from root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController {
            return topMostViewController(from: presented)
        }
        if let nav = root as? UINavigationController, let visible = nav.visibleViewController {
            return topMostViewController(from: visible)
        }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return topMostViewController(from: selected)
        }
        return root
    }

    private func bestPresentingViewController(fallback: UIViewController) -> UIViewController {
#if canImport(UIKit)
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let window = scene.windows.first(where: { $0.isKeyWindow }),
           let root = window.rootViewController {
            return topMostViewController(from: root)
        }
#endif
        return topMostViewController(from: fallback)
    }

    @objc func signIn(_ call: CAPPluginCall, _ viewController: UIViewController) {
        let localPlayer = GKLocalPlayer.local

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            call.keepAlive = true
            self.pendingSignInCalls.append(call)

            if localPlayer.isAuthenticated {
                let result: [String: Any] = [
                    "player_name": localPlayer.displayName,
                    "player_id": localPlayer.gamePlayerID
                ]
                let calls = self.pendingSignInCalls
                self.pendingSignInCalls.removeAll()
                calls.forEach { c in
                    c.keepAlive = false
                    c.resolve(result)
                }
                return
            }

            if localPlayer.authenticateHandler == nil {
                localPlayer.authenticateHandler = { [weak self] gcAuthVC, error in
                    DispatchQueue.main.async {
                        guard let self = self else { return }

                        if let error = error {
                            let calls = self.pendingSignInCalls
                            self.pendingSignInCalls.removeAll()
                            self.isPresentingAuth = false
                            calls.forEach { c in
                                c.keepAlive = false
                                c.reject("Authentication failed: \(error.localizedDescription)")
                            }
                            return
                        }

                        if localPlayer.isAuthenticated {
                            let result: [String: Any] = [
                                "player_name": localPlayer.displayName,
                                "player_id": localPlayer.gamePlayerID
                            ]
                            let calls = self.pendingSignInCalls
                            self.pendingSignInCalls.removeAll()
                            self.isPresentingAuth = false
                            calls.forEach { c in
                                c.keepAlive = false
                                c.resolve(result)
                            }
                            return
                        }

                        if let gcAuthVC = gcAuthVC {
                            // Present auth UI from the currently top-most VC (scene-safe).
                            if !self.isPresentingAuth {
                                self.isPresentingAuth = true
                                let presenter = self.bestPresentingViewController(fallback: viewController)
                                presenter.present(gcAuthVC, animated: true)
                            }
                            return
                        }

                        // No UI to present and still not authenticated (often means user canceled / restrictions).
                        let calls = self.pendingSignInCalls
                        self.pendingSignInCalls.removeAll()
                        self.isPresentingAuth = false
                        calls.forEach { c in
                            c.keepAlive = false
                            c.reject("[GameServices] local player is not authenticated")
                        }
                    }
                }
            } else if !self.isPresentingAuth {
                // Handler exists but player isn't authenticated yet.
                // Do nothing: the existing handler will eventually supply a view controller or auth result.
            }
        }
    }

    @objc func getGameCenterCredential(_ call: CAPPluginCall) {
        guard GKLocalPlayer.local.isAuthenticated else {
            call.reject("Player is not authenticated with Game Center")
            return
        }
        // Get the Game Center authentication credential for Firebase
        GKLocalPlayer.local.fetchItems { (publicKeyUrl, signature, salt, timestamp, error) in
            DispatchQueue.main.async {
                if let error = error {
                    call.reject("Failed to get Game Center credential: \(error.localizedDescription)")
                    return
                }
                guard let publicKeyUrl = publicKeyUrl,
                      let signature = signature,
                      let salt = salt else {
                    call.reject("Failed to get Game Center credential data")
                    return
                }
                // Create credential data compatible with Firebase GameCenterAuthProvider
                let credentialData: [String: Any] = [
                    "playerID": GKLocalPlayer.local.gamePlayerID,
                    "publicKeyURL": publicKeyUrl.absoluteString,
                    "signature": signature.base64EncodedString(),
                    "salt": salt.base64EncodedString(),
                    "timestamp": timestamp,
                    "displayName": GKLocalPlayer.local.displayName,
                    "bundleId": Bundle.main.bundleIdentifier as Any
                ]
                let result: [String: Any] = [
                    "credential": credentialData,
                    "providerId": "gc.apple.com"
                ]
                call.resolve(result as PluginCallResultData)
            }
        }
    }

    @objc func showLeaderboard(_ call: CAPPluginCall, _ viewController: UIViewController) {
        let leaderboardID = String(call.getString("leaderboardID") ?? "") // Property to get the leaderboard ID
        DispatchQueue.main.async {
            let leaderboardViewController = GKGameCenterViewController()
            leaderboardViewController.viewState = .leaderboards
            leaderboardViewController.leaderboardIdentifier = leaderboardID
            leaderboardViewController.gameCenterDelegate = self
            leaderboardViewController.leaderboardTimeScope = .allTime
            viewController.present(leaderboardViewController, animated: true)
        }
    }

    @objc func showAchievements(_ call: CAPPluginCall, _ viewController: UIViewController) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated")
            call.reject("Player is not authenticated")
            return
        }

        print("[GameServices] Showing Achievements")
        DispatchQueue.main.async {
            let achievementsViewController = GKGameCenterViewController()
            achievementsViewController.gameCenterDelegate = self
            achievementsViewController.viewState = .achievements
            viewController.present(achievementsViewController, animated: true)
        }
    }

    @objc func submitScore(_ call: CAPPluginCall) {
        let leaderboardID = String(call.getString("leaderboardID") ?? "") // Property to get the leaderboard ID
        let score = Int64(call.getInt("totalScoreAmount") ?? 0) // Property to get the total score to submit

        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated")
            call.reject("Player is not authenticated")
            return
        }

        let scoreReporter = GKScore(leaderboardIdentifier: leaderboardID)
        scoreReporter.value = Int64(score)
        scoreReporter.context = 0

        let scoreArray: [GKScore] = [scoreReporter]

        GKScore.report(scoreArray, withCompletionHandler: { error in
            if let error = error {
                // Handle score submission error
                print("Score submission failed with error: \(error.localizedDescription)")
                call.reject("Score submission failed, try again.")
            } else {
                let result = [
                    "type": "success",
                    "message": "Score has been submitted successfully"
                ]
                // Score submitted successfully
                print("Score submitted")
                call.resolve(result as PluginCallResultData)
            }
        })
    }

    @objc func unlockAchievement(_ call: CAPPluginCall) {
            print("unlockAchievement:called")
            setProgressAchievement(call, 100.0)
    }

    @objc func incrementAchievementProgress(_ call: CAPPluginCall) {
        print("progressAchievement:called")
        setProgressAchievement(call, call.getDouble("pointsToIncrement"))
    }

    private func setProgressAchievement(_ call: CAPPluginCall, _ pointsToIncrement: Double?) {

        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated")
            call.reject("Player is not authenticated")
            return
        }

        let result = [
            "type": "success",
            "message": "Achievement Progress Was Updating"
        ]

        let achievementID = call.getString("achievementID") ?? ""
        let progressComplete = pointsToIncrement ?? 100.0

        print("[GameServices] Setting Achievement Percentage \(progressComplete)")

        let achievementToComplete = GKAchievement(identifier: achievementID)
        achievementToComplete.showsCompletionBanner = true
        achievementToComplete.percentComplete = progressComplete

        GKAchievement.report([achievementToComplete]) { error in
            guard error == nil else {
                print("Error updating achievement \(error?.localizedDescription ?? "")")
                call.reject("Error updating achievement \(error?.localizedDescription ?? "")")
                return
            }
            call.resolve(result as PluginCallResultData)
        }
    }

    @objc func getUserTotalScore(_ call: CAPPluginCall) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated")
            call.reject("Player is not authenticated")
            return
        }

        let leaderboardID = String(call.getString("leaderboardID") ?? "") // * Property to get the leaderboard ID
        let leaderboard = GKLeaderboard() // * LeaderBoard functions
        var userTotalScore = 0 // * Property to store user total score
        leaderboard.identifier = leaderboardID // * LeaderBoard we are going to use for
        leaderboard.playerScope = .global // * Section to use
        leaderboard.timeScope = .allTime // * Time to search for

        leaderboard.loadScores { (scores, error) in
            let hasScore = scores ?? nil
            if hasScore != nil {
                if let error = error {
                    call.reject("Error loading leaderboard score: \(error.localizedDescription)")
                } else if let scores = scores {
                    for score in scores {
                        if score.player.gamePlayerID == GKLocalPlayer.local.gamePlayerID {
                            userTotalScore = Int(score.value)
                        }
                    }
                }
            } else {
                userTotalScore = 0
            }
            let result = [
                "player_score": userTotalScore
            ]
            call.resolve(result as PluginCallResultData)
        }
    }

    @objc func saveSnapshot(_ call: CAPPluginCall) {
        let snapshotName = call.getString("snapshotName") ?? "game-save"

        guard let dataString = call.getString("data") else {
            call.reject("data is required")
            return
        }

        guard GKLocalPlayer.local.isAuthenticated else {
            call.reject("Player is not authenticated")
            return
        }

        guard let data = dataString.data(using: .utf8) else {
            call.reject("Could not encode snapshot data as UTF-8")
            return
        }

        GKLocalPlayer.local.saveGameData(data, withName: snapshotName) { _, error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    let details = self?.describeGameKitError(error) ?? error.localizedDescription
                    call.reject("Save failed: \(details)")
                } else {
                    call.resolve()
                }
            }
        }
    }

    @objc func loadSnapshot(_ call: CAPPluginCall) {
        let snapshotName = call.getString("snapshotName") ?? "game-save"

        guard GKLocalPlayer.local.isAuthenticated else {
            call.reject("Player is not authenticated")
            return
        }

        GKLocalPlayer.local.fetchSavedGames { [weak self] savedGames, error in
            DispatchQueue.main.async {
                guard let self = self else {
                    call.reject("Plugin instance no longer available")
                    return
                }

                if let error = error {
                    call.reject("Failed to load snapshots: \(self.describeGameKitError(error))")
                    return
                }

                guard let savedGames = savedGames else {
                    // No error, but no saved games available (can happen if Saved Games/iCloud isn't available).
                    call.resolve(["data": NSNull()])
                    return
                }

                let matches = savedGames.filter { $0.name == snapshotName }
                if matches.isEmpty {
                    call.resolve(["data": NSNull()])
                    return
                }

                let selected = matches.max { lhs, rhs in
                    (lhs.modificationDate ?? .distantPast) < (rhs.modificationDate ?? .distantPast)
                } ?? matches[0]

                selected.loadData { data, loadError in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {
                            call.reject("Plugin instance no longer available")
                            return
                        }
                        if let loadError = loadError {
                            call.reject("Error reading snapshot: \(self.describeGameKitError(loadError))")
                            return
                        }

                        guard let data = data else {
                            call.resolve(["data": NSNull()])
                            return
                        }

                        let decoded = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)

                        if matches.count > 1 {
                            GKLocalPlayer.local.resolveConflictingSavedGames(matches, with: data) { _, resolveError in
                                DispatchQueue.main.async {
                                    if let resolveError = resolveError {
                                        print("Failed to resolve snapshot conflicts: \(self.describeGameKitError(resolveError))")
                                    }
                                    call.resolve(["data": decoded])
                                }
                            }
                        } else {
                            call.resolve(["data": decoded])
                        }
                    }
                }
            }
        }
    }
}
