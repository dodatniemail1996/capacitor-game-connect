import Foundation
import Capacitor
import GameKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

@objc(CapacitorGameConnectPlugin)
public class CapacitorGameConnectPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CapacitorGameConnectPlugin"
    public let jsName = "CapacitorGameConnect"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "signIn", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "showLeaderboard", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "showAchievements", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "submitScore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "unlockAchievement", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "incrementAchievementProgress", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getUserTotalScore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getGameCenterCredential", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getGooglePlayCredential", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "saveSnapshot", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "loadSnapshot", returnType: CAPPluginReturnPromise)
    ]

    private let implementation = CapacitorGameConnect()

    @objc func signIn(_ call: CAPPluginCall) {
        guard let viewController = self.bridge?.viewController else {
            call.reject("View controller not available")
            return
        }
        implementation.signIn(call, viewController)
    }
    
    @objc func showLeaderboard(_ call: CAPPluginCall) {
        guard let viewController = self.bridge?.viewController else {
            call.reject("View controller not available")
            return
        }
        implementation.showLeaderboard(call, viewController)
        call.resolve()
    }
    
    @objc func showAchievements(_ call: CAPPluginCall) {
        guard let viewController = self.bridge?.viewController else {
            call.reject("View controller not available")
            return
        }
        implementation.showAchievements(call, viewController)
        call.resolve()
    }
    
    @objc func submitScore(_ call: CAPPluginCall) {
        implementation.submitScore(call)
        call.resolve()
    }
    
    @objc func unlockAchievement(_ call: CAPPluginCall) {
        implementation.unlockAchievement(call)
        call.resolve()
    }
    
    @objc func incrementAchievementProgress(_ call: CAPPluginCall) {
        implementation.incrementAchievementProgress(call)
        call.resolve()
    }
    
    @objc func getUserTotalScore(_ call: CAPPluginCall) {
        implementation.getUserTotalScore(call)
    }

    @objc func getGameCenterCredential(_ call: CAPPluginCall) {
        implementation.getGameCenterCredential(call)
    }

    @objc func getGooglePlayCredential(_ call: CAPPluginCall) {
        call.reject("Google Play Games not available on iOS")
    }

    @objc func saveSnapshot(_ call: CAPPluginCall) {
        implementation.saveSnapshot(call)
    }

    @objc func loadSnapshot(_ call: CAPPluginCall) {
        implementation.loadSnapshot(call)
    }
}
