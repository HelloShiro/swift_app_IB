//
//  DriverTableViewController.swift
//  uber
//
//  Created by SnoopyKing on 2017/11/8.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation


class DriverTableViewController: UITableViewController,CLLocationManagerDelegate {
    
    let ref = Database.database().reference()
    //定義一個存字典的宿主
    var passengerRequests:[DataSnapshot]=[]
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    @IBOutlet var driverTableView: UITableView!
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true, completion: nil)
        }catch{
            print(error)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.driverTableView.reloadData()
        }
    }
    
    func retrieveData(){
        
 ref.child("PassengerRequests").observe(DataEventType.childAdded) { (dataSnapShot) in
//            print(dataSnapShot.value)
            //假設一個字典
            if let passengerRequestDic = dataSnapShot.value as? [String:Any]{
                if passengerRequestDic["driverLat"] != nil{
                    
                }else{
                    //                print(passengerRequestDic["email"])
                    self.passengerRequests.append(dataSnapShot)
                    dataSnapShot.ref.removeAllObservers()
                    self.driverTableView.reloadData()
                }

            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate{
            driverLocation = coordinate
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapShot = passengerRequests[indexPath.row]
        //發送者改為snapShot
        performSegue(withIdentifier: "pickUpSegue", sender: snapShot)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickUpSegue"{
            let destinationVC = segue.destination as! PickUpViewController
            //sender真的成為snapShot時
            if let snapShot = sender as? DataSnapshot{
                if let passengerRequestsDic = snapShot.value as? [String:Any]{
                    if let email = passengerRequestsDic["email"] as? String{
                        if let latitude = passengerRequestsDic["latitude"] as? Double{
                            if let longitude = passengerRequestsDic["longitude"] as? Double{
                                destinationVC.passengerEmail = email
                                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                destinationVC.passengerLocation = location
                                destinationVC.driverLocation = driverLocation
                            }
                        }
                    }
                }
            }
            
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passengerRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PassengerDataCell
        //從宿主中提取使用者資訊
        let snapShot = passengerRequests[indexPath.row]
        if let passengerRequestsDic = snapShot.value as? [String:Any]{
            if let email = passengerRequestsDic["email"] as? String{
                if let latitude = passengerRequestsDic["latitude"] as? Double{
                    if let longitude = passengerRequestsDic["longitude"] as? Double{
                        let passengerCLLocation = CLLocation(latitude: latitude, longitude: longitude)
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let distance = passengerCLLocation.distance(from: driverCLLocation) / 1000
                        let roundedDistance = round(distance * 100)/100
                        if let image = UIImage(named: "defaultProfileImage"){
                            let passengerDetails = "\(roundedDistance) km"
                            cell.configureCell(profileImage: image, email: email, detail: passengerDetails)
                        }
                    }
                }
            }
        }
        
        return cell
    }
}
