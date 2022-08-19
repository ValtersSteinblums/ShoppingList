//
//  ShoppingTableViewController.swift
//  ShoppingList
//
//  Created by valters.steinblums on 18/08/2022.
//

import UIKit
import CoreData

class ShoppingTableViewController: UITableViewController {
    
    var shopping = [Shopping]()
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButton.image = UIImage.init(systemName: "arrow.up.arrow.down.square.fill")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        loadData()
    }
    
    func loadData() {
        let request: NSFetchRequest<Shopping> = Shopping.fetchRequest()
        do {
            // read up on sortDescriptor
            // basically, specifies how the objects should be ordered, when the core data is loaded (fetched)
            request.sortDescriptors = [NSSortDescriptor(key: "rowOrder", ascending: true)]
            
            if let result = try managedObjectContext?.fetch(request) {
                shopping = result
                self.tableView.reloadData()
            }
        } catch {
            print("Error in loading core data items.")
        }
    }
    
    func saveData() {
        do {
            try managedObjectContext?.save()
        } catch {
            print("Error in loading core data items.")
        }
        loadData()
    }
    
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Homework No.12", message: "Done by me, Valters", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // allows for the rows to be edited/moved
    // changes bttn img, depending on the state
    @IBAction func startEditButton(_ sender: Any) {
        isEditing = !isEditing
        
        switch isEditing {
        case true:
            editButton.image = UIImage.init(systemName: "checkmark.rectangle.portrait.fill")
        case false:
            editButton.image = UIImage.init(systemName: "arrow.up.arrow.down.square.fill")
        }
    }
    
#warning("add alert sheet for the trash button, to delete all items in the list")
    // read up on this tommorow too
    @IBAction func deleteAllItems(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete items", message: "Do you really want to delete all items from the list?", preferredStyle: .alert)
        
        let addDeleteButton = UIAlertAction(title: "Delete", style: .destructive) { action in
            // retrieve data from the persistent storage
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            // request that deletes all objects in the persistent storage
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.managedObjectContext?.execute(batchDeleteRequest)
            } catch {
                print("Error in the batch delete!!!")
            }
            self.saveData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(addDeleteButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addNewItem(_ sender: Any) {
        let alertController = UIAlertController(title: "Shopping Item", message: "What do you want to add to the list?", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter the title of your item"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .sentences
        }
#warning("add a counter texfield for the count number")
        alertController.addTextField { texField in
            texField.placeholder = "Enter the amount you would like to add"
            texField.autocorrectionType = .no
            texField.autocapitalizationType = .sentences
        }
        
        let addActionButton = UIAlertAction(title: "Add", style: .default) { action in
            let itemTextField = alertController.textFields?.first
            let countTextField = alertController.textFields?.last
            
            if let entity = NSEntityDescription.entity(forEntityName: "Shopping", in: self.managedObjectContext!) {
                let shop = NSManagedObject(entity: entity, insertInto: self.managedObjectContext)
                shop.setValue(itemTextField?.text, forKey: "item")
                shop.setValue(countTextField?.text, forKey: "count")
            }
            self.saveData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(addActionButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
        
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shopping.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath)
        
        let shop = shopping[indexPath.row]
        
        cell.textLabel?.text = "Item: \(shop.value(forKey: "item") ?? "")"
        cell.detailTextLabel?.text = "Count: \(shop.value(forKey: "count") ?? "")"
        cell.accessoryType = shop.completed ? .checkmark : .none
        
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    //    MARK: - Table View delegate
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            managedObjectContext?.delete(shopping[indexPath.row])
        }
        
        saveData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shopping[indexPath.row].completed = !shopping[indexPath.row].completed
        saveData()
    }
    
#warning("insert - move from one row to another")
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = shopping[fromIndexPath.row]
        
        shopping.remove(at: fromIndexPath.row)
        shopping.insert(itemToMove, at: destinationIndexPath.row)
        
        // go trough this for cycle, tomorrow
        // As I see it, we go trough the items in the shoppinglist and reasign the old order values with the newValue
        for (newValue, item) in shopping.enumerated() {
            item.setValue(newValue, forKey: "rowOrder")
        }
        
        tableView.reloadData()
        saveData()
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
