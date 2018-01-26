//
//  SecondViewController.swift
//  Notebook
//
//  Created by SnoopyKing on 2017/10/27.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var users : [Users] = []
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tv.dataSource = self
        tv.delegate = self
        fetch()
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return users.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = users[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "DELETE") { (rowAction, indexPath) in
            self.deleteItem(indexPath: indexPath)
            self.fetch()
            self.tv.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        return [deleteAction]
    }
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Users>(entityName: "Users")
        do{
            users = try context.fetch(fetchRequest)
        }catch{
            print("Data could not be fetch.")
        }
    }
    
    func deleteItem(indexPath: IndexPath){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(users[indexPath.row])
        do {
            try context.save()
        } catch  {
            print("Could not save data.")
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
