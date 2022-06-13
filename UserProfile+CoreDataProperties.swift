//
//  UserProfile+CoreDataProperties.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/12/22.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var imageID: String?
    @NSManaged public var username: String?

}

extension UserProfile : Identifiable {

}
