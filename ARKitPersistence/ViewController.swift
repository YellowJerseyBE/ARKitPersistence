//
//  ViewController.swift
//  ARKitPersistence
//
//  Created by Ananth Bhamidipati on 25/10/2018.
//  Copyright © 2018 YellowJersey. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // set session delegate
        self.sceneView.session.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //Set lighting to the view
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        setupUI()
        addTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration and run the view's session
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func resetTrackingConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
        
        setUpLabelsAndButtons(text: "Move the camera around to detect surfaces", canShowSaveButton: false)
    }
    
    func generateSphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        return sphereNode
    }
    
    func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapGestureRecognized(recognizer :UITapGestureRecognizer) {
        let touchLocation = recognizer.location(in: sceneView)
        guard let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlane).first
            else { return }
        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    func setupUI() {
        setUpLabelsAndButtons(text: "Move the camera around to detect surfaces", canShowSaveButton: false)
        loadButton.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
        clearButton.layer.cornerRadius = 10
    }
    
    func setUpLabelsAndButtons(text: String, canShowSaveButton: Bool) {
        self.infoLabel.text = text
        self.saveButton.isEnabled = canShowSaveButton
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Button Actions
    
    @IBAction func loadButtonAction(_ sender: Any) {
    }
    
    @IBAction func clearButtonAction(_ sender: Any) {
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        let sphereNode = generateSphereNode()
        DispatchQueue.main.async {
            node.addChildNode(sphereNode)
        }
    }
    
    // MARK: - ARSessionDelegate
    //shows the current status of the world map.
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable:
            setUpLabelsAndButtons(text: "Map Status: Not available", canShowSaveButton: false)
        case .limited:
            setUpLabelsAndButtons(text: "Map Status: Available but has Limited features", canShowSaveButton: false)
        case .extending:
            setUpLabelsAndButtons(text: "Map Status: Actively extending the map", canShowSaveButton: false)
        case .mapped:
            setUpLabelsAndButtons(text: "Map Status: Mapped the visible Area", canShowSaveButton: true)
        }
    }
}
