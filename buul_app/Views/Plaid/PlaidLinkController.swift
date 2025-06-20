//
//  LinkKitSwiftUISupport.swift
//  LinkDemo-Swift
//
//  Copyright © 2020 Plaid Inc. All rights reserved.
//

import LinkKit
import SwiftUI

//// Plaid currently doesn't fully support SwiftUI. Therefore, we need to create a bridge from SwiftUI to UIKit.
//struct LinkController: UIViewControllerRepresentable {
//
//    private let handler: Handler
//
//    init(handler: Handler) {
//        self.handler = handler
//    }
//
//    // MARK: UIViewControllerRepresentable
//
//    final class Coordinator: NSObject {
//        private let parent: LinkController
//        private let handler: Handler
//
//        fileprivate init(parent: LinkController, handler: Handler) {
//            self.parent = parent
//            self.handler = handler
//        }
//
//        fileprivate func present(_ handler: Handler, in viewController: UIViewController) {
////            handler.open(presentUsing: .viewController(parent))
//            handler.open(presentUsing: .custom({ linkViewController in
//                viewController.addChild(linkViewController)
//                viewController.view.addSubview(linkViewController.view)
//                linkViewController.view.translatesAutoresizingMaskIntoConstraints = false
//                linkViewController.view.frame = viewController.view.bounds
//                NSLayoutConstraint.activate([
//                    linkViewController.view.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
//                    linkViewController.view.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
//                    linkViewController.view.widthAnchor.constraint(equalTo: viewController.view.widthAnchor),
//                    linkViewController.view.heightAnchor.constraint(equalTo: viewController.view.heightAnchor),
//                ])
//                linkViewController.didMove(toParent: viewController)
//            }))
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self, handler: handler)
//    }
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        context.coordinator.present(handler, in: viewController)
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // Empty implementation
//    }
//}



class PlaidViewController: UIViewController {
    var handler: Handler?

    init(handler: Handler) {
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    func openPlaidLink() {
        guard let handler = handler else {
//            print("Handler is nil, Link won't open")
            return
        }
        handler.open(presentUsing: .viewController(self))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openPlaidLink()
    }
}


import SwiftUI
import UIKit

struct PlaidViewControllerWrapper: UIViewControllerRepresentable {
    var handler: Handler
    
    func makeUIViewController(context: Context) -> PlaidViewController {
        return PlaidViewController(handler: handler)
    }

    func updateUIViewController(_ uiViewController: PlaidViewController, context: Context) {}
}

