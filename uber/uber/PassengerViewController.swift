//
//  PassengerViewController.swift
//  uber
//
//  Created by SnoopyKing on 2017/11/8.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class PassengerViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true, completion: nil)
        }catch{
            print(error)
        }
    }
    let locationManager = CLLocationManager()
    var scooterHasBeenCalled: Bool = false
    var userLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    //指派一个 FIRDatabaseReference 实例 -> reference()得到資料庫
    let reference: DatabaseReference = Database.database().reference()
    var driverOnTheWay = false
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBAction func callScooter(_ sender: UIButton) {
        
        if !driverOnTheWay{
            if let email = Auth.auth().currentUser?.email{
                if scooterHasBeenCalled {
                    //刪除數據
                    //依照子項目(email)排列observe目錄中的key,再對照value,再監聽事件(項目增加),並對項目動作
                    reference.child("PassengerRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(DataEventType.childAdded, with: { (dataSnapShot) in
                        dataSnapShot.ref.removeValue()
                        self.reference.child("PassengerRequests").removeAllObservers()
                    })
                    cancelScooterMode()
                    
                }else{
                    callScooterMode()
                    let passengerRequestDic: [String:Any] = ["email":email, "latitude":userLocation.latitude, "longitude":userLocation.longitude]
                    
                    //寫入數據 reference參考的數據庫的目錄(child)名為(PassengerRequests) 隨機生成pk的id 並設值
                    reference.child("PassengerRequests").childByAutoId().setValue(passengerRequestDic)
                }
            }
        }

    }
    func callScooterMode(){
        buttonOutlet.setTitle("Cancel Finding", for: UIControlState.normal)
        buttonOutlet.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        buttonOutlet.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControlState.normal)
        scooterHasBeenCalled = true
    }
    func cancelScooterMode(){
        buttonOutlet.setTitle("Find a Scooter", for: UIControlState.normal)
        buttonOutlet.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
        buttonOutlet.setTitleColor(#colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1), for: UIControlState.normal)
        scooterHasBeenCalled = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //將mapView接收到的數據與信息告訴我們的viewcontroller(也必須接受協議)
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //當未被用戶允許存取所在地區時,請求允許
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined{
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.updateLocation()
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //取得用戶的座標(從傳入的參數manager或自定義的locationManager)
        if let coordinate : CLLocationCoordinate2D = manager.location?.coordinate{
            
            if driverOnTheWay{
                displayDriverAndPassenger()
            }else{
                userLocation = coordinate
                let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0018, longitudeDelta: 0.0018))
                mapView.setRegion(region, animated: true)
                mapView.removeAnnotations(mapView.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "My Location"
                mapView.addAnnotation(annotation)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func updateLocation(){
        if let email = Auth.auth().currentUser?.email{
            reference.child("PassengerRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(DataEventType.childAdded, with: { (dataSnapShot) in
                self.callScooterMode()
                if let driverRequestDic = dataSnapShot.value as? [String:Any]{
                    if let driverLat = driverRequestDic["driverLat"] as? Double{
                        if let driverLon = driverRequestDic["driverLon"] as? Double{
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            
                            self.displayDriverAndPassenger()
                            self.reference.child("PassengerRequests").removeAllObservers()
                        }
                    }
                }
            })
        }
    }
    func displayDriverAndPassenger(){
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let passengerCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance  = driverCLLocation.distance(from: passengerCLLocation)/1000
        let roundDistance = round(distance*100)/100
        buttonOutlet.setTitle("距離您\(roundDistance)km", for: UIControlState.normal)
        mapView.removeAnnotations(mapView.annotations)
        let passengerAnnotation = MKPointAnnotation()
        passengerAnnotation.coordinate = userLocation
        passengerAnnotation.title = "你"
        mapView.addAnnotation(passengerAnnotation)
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "司機"
        mapView.addAnnotation(driverAnnotation)
        let latDetla = abs(driverLocation.latitude - userLocation.latitude) * 2.5
        let lonDetla = abs(driverLocation.longitude - userLocation.longitude) * 2.5
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDetla, longitudeDelta: lonDetla))
        mapView.setRegion(region, animated: true)
    }
}
