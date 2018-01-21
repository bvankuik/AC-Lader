 //
//  MainViewController.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 06/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import UIKit
import GooglePlacePicker
 
class MainViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate,
    GMUClusterRendererDelegate, UIPopoverPresentationControllerDelegate, GMSPlacePickerViewControllerDelegate {
    private let gmsMapView: GMSMapView
    private var chargerTypes: [ChargerType] = ChargerType.makeChargerTypes()
    private var clusterManager: GMUClusterManager?
    private var kmlLoaded = false
    private var isFirstStart = true
    private var selectedChargerItem: ChargerItem?
    
    // MARK: - GMSPlacePickerViewControllerDelegate
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        dlog()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        dlog("place = \(place)")
        viewController.dismiss(animated: true, completion: nil)

        let newCamera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 12)
        let update = GMSCameraUpdate.setCamera(newCamera)
        self.gmsMapView.moveCamera(update)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        dlog("Error: \(error.localizedDescription)")
        viewController.dismiss(animated: true, completion: nil)
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
        guard let chargerItem = marker.userData as? ChargerItem else {
            return
        }
        self.selectedChargerItem = chargerItem
        self.performSegue(withIdentifier: "ChargerDetailsSegue", sender: self)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        self.gmsMapView.isMyLocationEnabled = true
        return false
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeAction))
        if let navigationController = controller.presentedViewController as? UINavigationController {
            navigationController.topViewController?.navigationItem.leftBarButtonItem = doneButton
            return navigationController
        } else {
            return nil
        }
    }
    
    // MARK: - Actions
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func infoButtonAction() {
        dlog()
    }
    
    @IBAction func searchButtonAction(_ sender: UIBarButtonItem) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        self.present(placePicker, animated: true, completion: nil)
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
                    dlog("Couldn't get GMUPlacemark and GMUPoint from KML parser")
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
    
    private func commonInit() {
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.presentationController?.delegate = self

        if  let navigationController = segue.destination as? UINavigationController,
            let viewController = navigationController.topViewController as? SettingsViewController {
            viewController.chargerTypes = self.chargerTypes
        } else if let navigationController = segue.destination as? UINavigationController,
            let viewController = navigationController.topViewController as? ChargerDetailsViewController {
            viewController.chargerItem = self.selectedChargerItem
        } else if let viewController = segue.destination as? GMSPlacePickerViewController {
            viewController.delegate = self
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
        
        self.gmsMapView.translatesAutoresizingMaskIntoConstraints = false
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
        if !kmlLoaded {
            self.loadKML()
            self.kmlLoaded = true
        }
        self.renderCluster()
        
        if self.isFirstStart {
            self.isFirstStart = false
            self.gmsMapView.animate(toZoom: UserDefaults.standard.float(forKey: constants.defaults.zoomKey))
            self.gmsMapView.camera = GMSCameraPosition.camera(withLatitude: constants.initialPosition.latitude, longitude: constants.initialPosition.longitude, zoom: constants.defaults.zoomValue)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        GMSServices.provideAPIKey(constants.apiKey)
        GMSPlacesClient.provideAPIKey(constants.apiKey)
        self.gmsMapView = GMSMapView()
        super.init(coder: aDecoder)
    }
}
