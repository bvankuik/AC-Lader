 //
//  MainViewController.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 06/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate, CLLocationManagerDelegate,
    GMUClusterRendererDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var chargerDetailsButton: UIBarButtonItem!
    
    private let gmsMapView: GMSMapView
    private let locationManager = CLLocationManager()
    private var chargerTypes: [ChargerType] = ChargerType.makeChargerTypes()
    private var clusterManager: GMUClusterManager?
    private var kmlLoaded = false
    private var isFirstStart = true
    private var selectedChargerItem: ChargerItem?
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            return
        case .notDetermined:
            return
        case .restricted:
            return
        default:
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            dlog("No locations")
            return
        }
        
        dlog("Updating to \(location.coordinate.latitude),\(location.coordinate.longitude)")
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: UserDefaults.standard.float(forKey: constants.defaults.zoomKey))
        self.gmsMapView.camera = camera
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        dlog("Error: \(error.localizedDescription)")
    }
    
    // MARK: - GMUClusterRendererDelegate
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let chargerItem = marker.userData as? ChargerItem {
            marker.icon = chargerItem.type.image
        }
    }
    
    // MARK: - GMUClusterManagerDelegate
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: self.gmsMapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        self.gmsMapView.moveCamera(update)
        return false
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let chargerItem = marker.userData as? ChargerItem else {
            return true
        }

        self.selectedChargerItem = chargerItem
        marker.title = chargerItem.name
        marker.snippet = chargerItem.snippet
        self.gmsMapView.selectedMarker = marker
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        dlog("\(marker.accessibilityFrame)")
        self.performSegue(withIdentifier: "ChargerDetailsSegue", sender: self)
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        self.selectedChargerItem = nil
    }
    
    // MARK: - UIPopoverPresentationDelegate
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        if let navigationController = controller.presentedViewController as? UINavigationController {
            navigationController.topViewController?.navigationItem.leftBarButtonItem = closeButton
            return navigationController
        } else {
            return nil
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public functions
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        let currentZoom = self.gmsMapView.camera.zoom
        UserDefaults.standard.set(currentZoom, forKey: constants.defaults.zoomKey)
        UserDefaults.standard.synchronize()
        dlog("Defaults saved")
    }
    
    // MARK: - Private functions
    
    private func loadKML() {
        for chargerType in self.chargerTypes {
            chargerType.parse()
            
            if let kmlParser = chargerType.kmlParser {
                dlog(String(format: "Found %d placemarks, %d styles",
                        kmlParser.placemarks.count, kmlParser.styles.count))
            }
        }
    }
    
    private func renderCluster() {
        let images = [#imageLiteral(resourceName: "cluster"), #imageLiteral(resourceName: "cluster"), #imageLiteral(resourceName: "cluster"), #imageLiteral(resourceName: "cluster"), #imageLiteral(resourceName: "cluster")]
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [5, 10, 25, 50, 100], backgroundImages: images)
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: self.gmsMapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        self.clusterManager = GMUClusterManager(map: self.gmsMapView, algorithm: algorithm, renderer: renderer)
        
        //
        
        var chargerItems: [ChargerItem] = []
        for chargerType in self.chargerTypes where !chargerType.isHidden {
            guard let kmlParser = chargerType.kmlParser else {
                continue
            }
            
            for geometryContainer in kmlParser.placemarks {
                guard let placemark = geometryContainer as? GMUPlacemark,
                    let position = placemark.geometry as? GMUPoint else {
                    continue
                }
                
                let item = ChargerItem(position: position.coordinate,
                                       name: placemark.title ?? "No title",
                                       type: chargerType)
                item.htmlSnippet = placemark.snippet
                chargerItems.append(item)
            }
        }
        
        //
        
        self.clusterManager?.add(chargerItems)
        self.clusterManager?.cluster()
        self.clusterManager?.setDelegate(self, mapDelegate: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.presentationController?.delegate = self

        guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Programmer error")
        }

        if let viewController = navigationController.topViewController as? SettingsViewController {
            viewController.chargerTypes = self.chargerTypes
        } else if let viewController = navigationController.topViewController as? ChargerDetailsViewController {
            viewController.chargerItem = self.selectedChargerItem
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ChargerDetailsSegue" && self.selectedChargerItem == nil {
            let message = "First select a charger!"
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(dismissAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    // MARK: - View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "AC Fast Chargers"
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        
        self.gmsMapView.translatesAutoresizingMaskIntoConstraints = false
        self.gmsMapView.isMyLocationEnabled = true
        self.gmsMapView.settings.rotateGestures = false
        self.gmsMapView.settings.myLocationButton = true
        self.view.addSubview(self.gmsMapView)
        
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillTerminate, object: app)
        
        let constraints = [
            self.gmsMapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.gmsMapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.gmsMapView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.gmsMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        self.view.addConstraints(constraints)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.locationManager.requestWhenInUseAuthorization()
        if !kmlLoaded {
            self.loadKML()
            self.kmlLoaded = true
        }
        self.renderCluster()
        
        if self.isFirstStart {
            self.isFirstStart = false
            self.gmsMapView.animate(toZoom: UserDefaults.standard.float(forKey: constants.defaults.zoomKey))
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        GMSServices.provideAPIKey(constants.apiKey)
        self.gmsMapView = GMSMapView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        GMSServices.provideAPIKey(constants.apiKey)
        self.gmsMapView = GMSMapView()
        super.init(coder: aDecoder)
    }
}
