//
//  ViewController.swift
//  RealmDBCW
//
//  Created by Kate on 01/11/2023.
//

import RealmSwift
import UIKit



class TasksListTVC: UITableViewController, UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        coordinator.session.loadObjects(ofClass: NSString.self) { [weak self] items in
            guard let self = self, let strings = items as? [String], let realm = try? Realm() else { return }

            for string in strings {
                if let objectToDelete = realm.object(ofType: TasksList.self, forPrimaryKey: string) {
                    do {
                        try realm.write {
                            realm.delete(objectToDelete)
                        }
                        tableView.deleteRows(at: [destinationIndexPath], with: .automatic)
                    } catch {
                        print("Error deleting object: \(error)")
                    }
                    
                    let config = Realm.Configuration(
                      
                        schemaVersion: 1,

                       
                        migrationBlock: { migration, oldSchemaVersion in
                            if (oldSchemaVersion < 1) {
                                migration.enumerateObjects(ofType: TasksList.className()) { oldObject, newObject in
                                 newObject!["sortIndex"] = 0
                                 }
                            }
                        }
                    )

                    Realm.Configuration.defaultConfiguration = config
                    do {
                        let realm = try Realm()
                    } catch {
                        print("Error opening Realm: \(error)")
                    }
                }
            }
        }
    }
    
    // Results - отображает данны в режиме реального времени
    var tasksLists: Results<TasksList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clean all Realm DB
        // StorageManager.deleteAll()
        
        // выборка из DB + сортировка
        tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
        tableView.dragInteractionEnabled = true

        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonSystemItemSelector))
        navigationItem.setRightBarButton(add, animated: true)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        let byKeyPath = sender.selectedSegmentIndex == 0 ? "name" : "date"
        tasksLists = tasksLists.sorted(byKeyPath: byKeyPath)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let taskList = tasksLists[indexPath.row]
        cell.configure(with: taskList)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentList = tasksLists[indexPath.row]
        
        let deleteContextualAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            StorageManager.deleteTasksList(tasksList: currentList)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editContextualAction = UIContextualAction(style: .destructive, title: "Edit") { [weak self] _, _, _ in
            self?.alertForAddAndUpdatesListTasks(currentList: currentList, indexPath: indexPath)
        }
        
        let doneContextualAction = UIContextualAction(style: .destructive, title: "Done") { [weak self] _, _, _ in
            StorageManager.makeAllDone(tasksList: currentList)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        deleteContextualAction.backgroundColor = .red
        editContextualAction.backgroundColor = .gray
        doneContextualAction.backgroundColor = .green
        
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [doneContextualAction, editContextualAction, deleteContextualAction])
        
        return swipeActionsConfiguration
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TasksTVC,
           let indexPath = tableView.indexPathForSelectedRow
        {
            let currentTasksList = tasksLists[indexPath.row]
            destinationVC.currentTasksList = currentTasksList
        }
    }
    
    @objc
    private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesListTasks()
    }
    
    private func alertForAddAndUpdatesListTasks(currentList: TasksList? = nil, indexPath: IndexPath? = nil) {
        let title = currentList == nil ? "New list" : "Edit List"
        let messege = "Please insert list name"
        let doneButtonName = currentList == nil ? "Save" : "Update"
        
        let alertController = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { [weak self] _ in
            
            guard let self,
                  let newListName = alertTextField.text,
                  !newListName.isEmpty else { return }
            
            /// логика редактирования
            if let currentList = currentList,
               let indexPath = indexPath
            {
                StorageManager.editeTasksList(tasksList: currentList, newListName: newListName)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                /// логика создания нового объекта
                let taskList = TasksList()
                taskList.name = newListName
                StorageManager.saveTasksList(tasksList: taskList)
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextField { textField in
            alertTextField = textField
            alertTextField.text = currentList?.name
            alertTextField.placeholder = "List name"
        }
        
        present(alertController, animated: true)
    }
}
