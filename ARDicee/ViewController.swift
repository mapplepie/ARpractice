//
//  ViewController.swift
//  ARDicee
//
//  Created by Mai Uchida on 2021/11/27.
//

import UIKit
import RealityKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "2k_neptune.jpeg")
//        cube.materials = [material]
//
//        let node = SCNNode()
//
//        node.position = SCNVector3(x:0, y:0.1, z:-0.5)
//        node.geometry = cube
//
//        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation , types: .existingPlane)
            
            if let hitResults = results.first{
                
                    let diceScene = SCNScene(named: "diceCollada.scn")!
                    if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            
                        diceNode.position = SCNVector3(
                            hitResults.worldTransform.columns.3.x,
                            hitResults.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                            hitResults.worldTransform.columns.3.z)
                        
                        diceArray.append(diceNode)
                        
                    sceneView.scene.rootNode.addChildNode(diceNode)
                        
                        
                        
             roll(dice: diceNode)
               }
            }
        }
    }
   
    
    func rollAll(){
        
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice: dice)
            }
        }
        
    }
    
    func roll(dice: SCNNode){
        
        let randomX = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        )
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
        
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x),height:CGFloat( planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        }else{
            return
        }
    }
}
