//
//  TaskListDropDelegate.swift
//  RealmDBCW
//
//  Created by Kate on 06/11/2023.
//

import UIKit

extension TasksListTVC {
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            // Изменение порядка в базе данных Realm
//            let objectToMove = tasksLists[sourceIndexPath.row]
//            tasksLists.remove(at: sourceIndexPath.row)
//            tasksLists.insert(objectToMove, at: destinationIndexPath.row)
            
            // Обновление индексов с учетом нового порядка
            for (index, taskList) in tasksLists.enumerated() {
                taskList.sortIndex = index
            }
        }
    }
}
