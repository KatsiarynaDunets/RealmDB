//
//  StorageManager.swift
//  RealmDBCW
//
//  Created by Kate on 01/11/2023.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func getAllTasksLists() -> Results<TasksList> {
        realm.objects(TasksList.self)//.sorted(byKeyPath: "name")
    }
    
    static func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deleteAll error: \(error)")
        }
    }
    
    static func saveTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                realm.add(tasksList)
            }
        } catch {
            print("saveTasksList error: \(error)")
        }
    }
}

