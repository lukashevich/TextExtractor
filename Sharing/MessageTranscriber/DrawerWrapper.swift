//
//  Wrapper.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 1/12/23.
//

import DrawerView

final class DrawerWrapper: UIViewController, DrawerViewDelegate {
  
  private var _importController: MessageTranscriber?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    _setupDrawerView()
   
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelAction)))
  }
  
  private func _setupDrawerView() {
    let drawerViewController = self.storyboard!.instantiateViewController(withIdentifier: "ImportController")
    let drawerView = self.addDrawerView(withViewController: drawerViewController)
    drawerView.setPosition(.closed, animated: false)
    drawerView.setPosition(.partiallyOpen, animated: true)
    drawerView.partiallyOpenHeight = UIScreen.main.bounds.height / 4
    drawerView.snapPositions = [.closed, .partiallyOpen, .open]
    drawerView.delegate = self
    drawerView.backgroundColor = .quaternarySystemFill
    
    _importController = drawerViewController as? MessageTranscriber
    _importController?.positionHandler = { position in
      drawerView.setPosition(position, animated: true)
    }
  }
  
  @objc func cancelAction() {
    let error = NSError(domain: "some.bundle.identifier", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "An error description"])
    extensionContext?.cancelRequest(withError: error)
  }
  
  func drawerDidMove(_ drawerView: DrawerView, drawerOffset: CGFloat) {
    switch drawerView.position {
    case .closed:
      guard let controller = _importController else { return }
      controller.close()
    default: break
    }
  }
}
