//
//  ViewController.swift
//  Nano7App
//
//  Created by Igor Samoel da Silva on 16/11/21.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,UIGestureRecognizerDelegate {
    
    
    var issAnnotationView: MKAnnotationView?
    let issPointAnnotation = MKPointAnnotation()
    var imagemSatelite: UIImage?
    let locationManager = CLLocationManager()
    
    lazy var popUp: UIView = {
        let popUp = UIView(frame: CGRect(x: -300, y: -300, width: 224, height: 200))
        popUp.center = CGPoint(x: 237, y: 83)
        popUp.backgroundColor = .init(red: 54, green: 54, blue: 54, alpha: 0.0011)
        popUp.isHidden = true
        return popUp
    }()
    
    lazy var label: UILabel = {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 260))
        label.center = CGPoint(x: 350, y: 83)
        label.numberOfLines = 12
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    
    lazy var issButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    
    
    lazy var map : MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        return map
    }()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupContraints()
        changeMapButton()
        
        //Add MapView Delegate
        map.delegate = self
        
        //Add LocationManager Delegate
        locationManager.delegate = self
        
        updateIssLocation()
        setISSRegion()
        configureLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // show iss regin in map
        setISSRegion()
    }
    
    
    
    ///Method that center in iss location
    private func setISSRegion() {
        self.map.setRegion(MKCoordinateRegion(center: self.issPointAnnotation.coordinate, latitudinalMeters: CLLocationDistance(8000000), longitudinalMeters: 8000000), animated: true)
    }
    
    
    private func configureLocation() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestLocation()
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.map.showsUserLocation = true
        }
        
    }
    
    
    //Function to adding custom pin
    private func addCustomPin(){
        let pin = MKPointAnnotation()
        pin.title = "ISS here"
        map.addAnnotation(pin)
    }
    
    
    func setupImage(_ annotation: MKAnnotationView){
        let overlay = UIButton(frame: annotation.bounds)
        annotation.isUserInteractionEnabled = true
        overlay.backgroundColor = UIColor.red.withAlphaComponent(0.0)
        overlay.addTarget(self, action: #selector(showISSInfos), for: UIControl.Event.touchUpInside)
        annotation.addSubview(overlay)
    }
    
    
    
    @objc func showISSInfos(){
        self.popUp.isHidden.toggle()
        self.label.isHidden.toggle()
    }
    
    @objc func buttonAction(button: UIButton){
        if map.mapType == .hybridFlyover {
            map.mapType = .standard
        }else{
            map.mapType = .hybridFlyover
        }
        
    }
    
    func changeMapButton(){
        let button = UIButton()
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        button.backgroundColor = .white
        let largeBoldMap = UIImage(systemName: "map.circle.fill", withConfiguration: largeConfig)
        button.layer.cornerRadius = 8
        button.setImage(largeBoldMap, for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
        
        //Button constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    
    private func updateIssLocation() {
        IssAPI.shared.request { iss in
            DispatchQueue.main.async {
                self.issPointAnnotation.coordinate = iss.getCoordinate()
                self.setISSRegion()
            }
        }
        
        //Cria o timer que atualiza as posições a cada 1.2 segundos
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { timer in
            //Solicita as informações da ISS
            IssAPI.shared.request { iss in
                DispatchQueue.main.async {
                    //Atribui as novas coordenas para a Annotation da ISS
                    self.issPointAnnotation.coordinate = iss.getCoordinate()
                    //Atualiza as labels de informações da ISS
                    self.label.text = "Nome: \(iss.name.uppercased())\nLatitude: \(iss.latitude)\nLongitude: \(iss.longitude)\nAltitude: \(iss.altitude)\nVelocidade: \(iss.velocity)\nVisibilidade: \(iss.visibility)\nPegadas: \(iss.footprint)\n"
                    //Atualiza a órbita que a ISS irá percorrer
                        self.updateOrbitPathOverlays()
                }
            }
        }
        
        map.addAnnotation(issPointAnnotation)
    }
    
    
    func updateOrbitPathOverlays() {
        
        //Solicita as 11 posições futuras da ISS
        IssAPI.shared.requestISSOrbit { locations in
            
            var coordinates: [CLLocationCoordinate2D] = []
            
            //Atribuição das latitudes e longitudes de cada ponto
            locations.forEach { location in
                coordinates.append(location.getCoordinate())
            }
            
            //Criação da overlay da orbita que a ISS irá percorrer
            let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
            
            DispatchQueue.main.async {
                //Remoção da órbita antiga
                self.map.removeOverlays(self.map.overlays)
                //Atribuição da nova órbita
                self.map.addOverlay(polyline)
            }
        }
    }
    
    
    
    func setupContraints() {
        self.view.addSubview(self.map)
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        map.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    }
}


extension MapViewController: MKMapViewDelegate {
    
    //function to show custom pin at map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: "custom")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            
            annotationView?.canShowCallout = true
        }
        else{
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = UIImage(named: "IssIcon")
        
        self.issAnnotationView = annotationView
        self.imagemSatelite = annotationView?.image
        
        if self.issAnnotationView != nil{
            self.setupImage(self.issAnnotationView!)
            self.issAnnotationView?.addSubview(self.popUp)
            self.issAnnotationView?.addSubview(self.label)
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKGeodesicPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 2
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
}



extension MapViewController: CLLocationManagerDelegate {
    //New Locations from user device
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    
    //Resquest location fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Erro")
    }
    
    
}
