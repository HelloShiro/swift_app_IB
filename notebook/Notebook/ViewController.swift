//
//  ViewController.swift
//  Notebook
//
//  Created by SnoopyKing on 2017/10/27.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {

    var users: [Users] = []
    var isLoggedin : Bool = false
    
    @IBOutlet weak var tfUser: UITextField!
    @IBAction func btnLogin(_ sender: UIButton) {
        checkUser(username: tfUser.text!)
        if isLoggedin == false {
            save()
        }else{
            performSegue(withIdentifier: "gotoSecondViewController", sender: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func save(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //Users表使用的空間
        let users = Users(context: context)
        if tfUser.text != ""{
            users.username = tfUser.text
        }
        do {
            try context.save()
        } catch {
            print("There was an error.")
        }
    }
    func checkUser(username: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Users>(entityName: "Users")
        fetchRequest.predicate = NSPredicate(format: "username==[c]%@", username)
        do {
            users = try context.fetch(fetchRequest)
            if users.count > 0{
                if users[0].username != nil{
                    isLoggedin = true
                }
            }
        } catch  {
            print("Data could not be fetch")
        }
    }
}

