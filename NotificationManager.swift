//
//  NotificationManager.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import Foundation
import UserNotifications

/// Manages local notifications for note reminders and job follow-ups
/// Uses UNUserNotificationCenter for iOS notification system
class NotificationManager: NSObject, ObservableObject {
    /// Shared instance for app wide notification management
    static let shared = NotificationManager()
    
    /// Tracks current notification authorization status
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    /// Private initializer with notification center setup
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkPermission()
    }
    
    /// Checks current notification permission status
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionStatus = settings.authorizationStatus
            }
        }
    }
    
    /// Requests notification permission from user
    /// - Returns: Boolean indicating if permission was allowed
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            // Update UI with permission result
            await MainActor.run {
                self.permissionStatus = granted ? .authorized : .denied
            }
            
            return granted
        } catch {
            print("❌ Notification permission error: \(error)")
            return false
        }
    }
    
    /// Schedules a reminder notification for a note
    /// - Parameters:
    ///   - title: Notification title
    ///   - body: Notification content
    ///   - date: When to trigger the notification
    /// - Returns: Unique identifier for the scheduled notification
    func scheduleNoteReminder(title: String, body: String, date: Date) -> String {
        let id = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = "📝 \(title)"
        content.body = body
        content.sound = .default
        content.userInfo = ["type": "note", "id": id]
        
        // Convert date to calendar components for precise scheduling
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        return id
    }
    
    /// Schedules a follow-up notification for a job application
    /// - Parameters:
    ///   - company: Company name for notification title
    ///   - position: Job position for notification body
    ///   - date: When to trigger the follow-up
    /// - Returns: Unique identifier for the scheduled notification
    func scheduleJobFollowUp(company: String, position: String, date: Date) -> String {
        let id = "job_\(company)_\(Date().timeIntervalSince1970)"
        let content = UNMutableNotificationContent()
        content.title = "👔 Follow Up: \(company)"
        content.body = "Remember to follow up for \(position) position"
        content.sound = .default
        content.userInfo = ["type": "job", "id": id]
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        return id
    }
    
    /// Cancels a specific scheduled notification
    /// - Parameter id: Notification identifier to cancel
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    /// Cancels all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate
/// Handles notification presentation when app is in foreground
extension NotificationManager: UNUserNotificationCenterDelegate {
    /// Determines how notifications are presented when app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and play sound even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
