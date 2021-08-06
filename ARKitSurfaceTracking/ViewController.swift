import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var arSceneView: ARSCNView!
    var isLoaded: Bool = false
    var modelNode: SCNNode?
    var lastRotation: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arSceneView.delegate = self
        //        arSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        addPinchGesture()
        //        addRotationGesture()
        //        addMoveGesture()
        addRotationByPanGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arSceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (!isLoaded) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            //let floor = createFloor(planeAnchor: planeAnchor)
            //            let floor = createFloor()
            //            node.addChildNode(floor)
            //            let model = show3DModel(modelName: "nike.usdz")
            let model = show3DModel(planeAnchor: planeAnchor, modelName: "model_r.usdz")
            modelNode = model
            node.addChildNode(model)
            isLoaded = true
            
            //            let (min, max) = modelNode!.boundingBox
            //            let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
            //            let box = SCNBox(width: CGFloat(size.x), height: CGFloat(size.y), length: CGFloat(size.z), chamferRadius: 0.0)
            //            let boxNode = SCNNode(geometry: box)
            //            boxNode.position.y = size.y/2
            //            node.addChildNode(boxNode)
        }
    }
    
    func createFloor() -> SCNNode {
        let node = SCNNode()
        let geometry = SCNPlane(width: 1.0, height: 1.0)
        node.geometry = geometry
        node.eulerAngles.x = -Float.pi/2
        node.opacity = 0.25
        return node
    }
    
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        node.geometry = geometry
        node.eulerAngles.x = -Float.pi/2
        node.opacity = 0.6
        return node
    }
    
    func show3DModel(modelName: String) -> SCNNode{
        let scene = SCNScene(named: modelName)
        let node = scene!.rootNode
        node.scale = SCNVector3Make(0.05, 0.05, 0.05)
        //        node.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        return node
    }
    
    func show3DModel(planeAnchor: ARPlaneAnchor, modelName: String) -> SCNNode{
        let scene = SCNScene(named: modelName)
        let node = scene!.rootNode
        //        node.scale = SCNVector3Make(0.1, 0.1, 0.1)
        node.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        return node
    }
    
    func addPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinchToScale(_:)))
        arSceneView.addGestureRecognizer(pinchGesture)
    }
    
    func addRotationGesture() {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        arSceneView.addGestureRecognizer(rotationGesture)
    }
    
    func addRotationByPanGesture() {
        let rotationGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanToRotate(_:)))
        arSceneView.addGestureRecognizer(rotationGesture)
    }
    
    func addMoveGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanToMove(_:)))
        arSceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func didPinchToScale(_ gesture: UIPinchGestureRecognizer) {
        if (isLoaded) {
            let originalScale = modelNode?.scale
            switch gesture.state {
            case .began:
                gesture.scale = CGFloat(originalScale!.x)
            case .changed:
                var newScale: SCNVector3
                if (gesture.scale < 0.5) {
                    newScale = SCNVector3(0.5, 0.5, 0.5)
                }
                else if (gesture.scale > 3) {
                    newScale = SCNVector3(3, 3, 3)
                }
                else {
                    newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
                }
                modelNode?.scale = newScale
            default:
                break
            }
        }
    }
    
    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        if (isLoaded) {
            switch gesture.state {
            case .changed:
                modelNode?.eulerAngles.y = self.lastRotation + (-Float(gesture.rotation))
            case .ended:
                lastRotation += Float(gesture.rotation)
            default:
                break
            }
        }
    }
    
    @objc func didPanToRotate(_ gesture: UIPanGestureRecognizer) {
        if (isLoaded) {
            switch gesture.state {
            case .changed:
                modelNode?.eulerAngles.y = (self.lastRotation + Float(gesture.translation(in: gesture.view).x)) * 0.005
            case .ended:
                lastRotation += Float(gesture.translation(in: gesture.view).x)
            default:
                break
            }
        }
    }
    
    @objc func didPanToMove(_ gesture: UIPanGestureRecognizer) {
        if (isLoaded) {
            if (gesture.numberOfTouches == 1) {
                switch gesture.state {
                case .changed:
                    let translation = gesture.translation(in: gesture.view)
                    let newPositionX = (modelNode?.position.x)! + Float(translation.x/5000)
                    let newPositionZ = (modelNode?.position.z)! + Float(translation.y/5000)
                    modelNode?.position = SCNVector3Make(newPositionX, (modelNode?.position.y)!, newPositionZ)
                default:
                    break
                }
            }
        }
    }
}

