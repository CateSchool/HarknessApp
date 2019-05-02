//
//  ClassSection+CoreDataProperties.swift
//  Cate School Harkness Discussion Tracker
//
//  Created by cate on 4/20/19.
//  Copyright © 2019 cate. All rights reserved.
//
//

import Foundation
import CoreData


extension ClassSection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClassSection> {
        return NSFetchRequest<ClassSection>(entityName: "ClassSection")
    }

    @NSManaged public var nameOfSection: String?
    @NSManaged public var studentNames: [String]?

}
