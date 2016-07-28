//
//  RVTransactionPageController.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 25.07.16.
//
//

import UIKit

final class RVTransactionPageController: UIPageViewController {

  //MARK: - Private var
  private var isAnimatingTransition = false

  private var currentController: UIViewController? {
    get {
      return viewControllers?.first
    }
    set(newValue) {
      guard let newValue = newValue else { return }
      guard !isAnimatingTransition else { return }
    
      isAnimatingTransition = true
      let viewControllers = [newValue]
      let direction = UIPageViewControllerNavigationDirection.Forward
      setViewControllers(viewControllers, direction: direction, animated: true) { [weak self] finished in
        if finished {
          dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let s = self {
              s.isAnimatingTransition = false
              s.setViewControllers(viewControllers, direction: direction, animated: false, completion: nil)
            }
          }
        }
      }
    }
  }

  //MARK: - Public functions
  func activateController(currencyShortName: String) {
    if let pageDatasource = dataSource as? RVTransactionPageControllerDataSource {
      currentController = pageDatasource.controller(currencyShortName)
    }
  }

  func becomeResponder() {
    if let controller = currentController as? RVTransactionItemViewController {
      controller.becomeResponder()
    }
  }

}
