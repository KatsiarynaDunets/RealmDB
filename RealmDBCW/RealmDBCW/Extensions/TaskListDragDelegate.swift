//
//  TaskListDragDelegate.swift
//  RealmDBCW
//
//  Created by Kate on 06/11/2023.
//

import UIKit

extension TasksListTVC {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let taskList = tasksLists[indexPath.row]
        let itemProvider = NSItemProvider(object: taskList.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = taskList
        return [dragItem]
    }
}
