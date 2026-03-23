//
//  BasicMapViewController.swift
//  AccesAI
//
//  Created by DEVELOP02 on 23/03/26.
//


import GoogleMaps
import UIKit

class BasicMapViewController: UIViewController {
  var statusLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Seattle coordinates
    let camera = GMSCameraPosition(latitude: 47.6089945, longitude: -122.3410462, zoom: 14)
    let mapView = GMSMapView(frame: view.bounds, camera: camera)
    mapView.delegate = self
    view = mapView
    navigationController?.navigationBar.isTranslucent = false

    statusLabel = UILabel(frame: .zero)
    statusLabel.alpha = 0.0
    statusLabel.backgroundColor = .blue
    statusLabel.textColor = .white
    statusLabel.textAlignment = .center
    view.addSubview(statusLabel)
    statusLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      statusLabel.topAnchor.constraint(equalTo: view.topAnchor),
      statusLabel.heightAnchor.constraint(equalToConstant: 30),
      statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
}

extension BasicMapViewController: GMSMapViewDelegate {
  func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
    statusLabel.alpha = 0.8
    statusLabel.text = "Rendering"
  }

  func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
    statusLabel.alpha = 0.0
  }
}

#Preview {
    BasicMapViewController()
}
