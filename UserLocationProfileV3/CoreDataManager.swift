//
//  CoreDataManager.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/12/22.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let sharedManager = CoreDataManager()
    private var managedContext: NSManagedObjectContext
    private var userProfileEntity: NSEntityDescription
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    private init() {
        managedContext = appDelegate.persistentContainer.viewContext
        userProfileEntity = NSEntityDescription.entity(forEntityName: "UserProfile", in: managedContext)!
        
    }
    
    func registerUser(username: String) {
        let managedObject = UserProfile(context: managedContext)
        managedObject.setValue(username, forKey: "username")
        appDelegate.saveContext()
        print("user \(username) registered.")
    }
    
    func userExists(by username: String) -> Bool {
        let fetchRequest = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)
        
        do {
            if let _ = try managedContext.fetch(fetchRequest).first {
                print("user \(username) exists")
                return true
            }
        } catch {
            print("User not exist")
        }
        return false
    }
    
    func saveUserProfileImageID(forUser: String, withImage: String) -> Bool {
        let fetchRequest = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        fetchRequest.predicate = NSPredicate(format: "username = %@", forUser)
        
        do {
            if let record = try managedContext.fetch(fetchRequest).first {
                record.setValue(withImage, forKey: "imageID")
                appDelegate.saveContext()
                return true
            }
        } catch {
            print("failed to find the user record, save image for the user")
        }
        
        return false
    }
    
    func removeUserProfileImageID(fromUser username: String) {
        let fetchRequest = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)
        
        do {
            if let record = try managedContext.fetch(fetchRequest).first {
                record.setValue(nil, forKey: "imageID")
                appDelegate.saveContext()
            }
        } catch {
            print("Failed to delete imageID from the user \(username)")
        }
    }
    
    func getUserProfileImageID(forUser: String) -> String? {
        let fetchRequest = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        fetchRequest.predicate = NSPredicate(format: "username = %@", forUser)
        
        do {
            if let record = try managedContext.fetch(fetchRequest).first {
                if let imageID = record.imageID {
                    return imageID
                }
            }
        } catch {
            print("failed to find the user record, save image for the user")
        }
        
        return nil
    }
    
}
