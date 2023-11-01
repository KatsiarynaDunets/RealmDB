//
//  TasksListModel.swift
//  RealmDBCW
//
//  Created by Kate on 01/11/2023.
//

import Foundation
import RealmSwift

class TasksList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}
