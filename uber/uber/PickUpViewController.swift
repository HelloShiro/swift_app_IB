//
//  PickUpViewController.swift
//  uber
//
//  Created by SnoopyKing on 2017/11/9.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class PickUpViewController: UIViewController,MKMapViewDelegate {

    var passengerEmail = ""
    var passengerLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    let ref = Database.database().reference()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func pickUpRequest(_ sender: UIButton) {
        ref.child("PassengerRequests").queryOrdered(byChild: "email").queryEqual(toValue: passengerEmail).observeSingleEvent(of: DataEventType.childAdded) { (dataSnapShot) in
           //添加元素到child
            dataSnapShot.ref.updateChildValues(["driverLat":self.driverLocation.latitude,"driverLon":self.driverLocation.longitude])
            //CLGeocoder 根據乘客當前的位置(CLLocation)導航
            let passengerCLLocation = CLLocation(latitude: self.passengerLocation.latitude, longitude: self.passengerLocation.longitude)
            //從clplacemarks(數組)要取得mapitem
            CLGeocoder().reverseGeocodeLocation(passengerCLLocation, completionHandler: { (clplacemarks, error) in
                if error != nil{
                    print(error)
                }else{
                    if let placemarks = clplacemarks{
                        if placemarks.count > 0{
                            let placeMark = MKPlacemark(placemark: placemarks[0])
                            let mapItem = MKMapItem(placemark: placeMark)
                            mapItem.name = self.passengerEmail
                            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
                        }
                    }
                }
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let span = MKCoordinateSpan(latitudeDelta: 0.0018, longitudeDelta: 0.0018)
        let region = MKCoordinateRegion(center: passengerLocation, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = passengerLocation
        annotation.title = passengerEmail
        mapView.addAnnotation(annotation)
    }

}
