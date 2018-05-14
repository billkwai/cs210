//
//  PageViewController.swift
//  PageControl
//
//  Created by Colin Dolese on 2/17/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class HomePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    
    var pageControl = UIPageControl()
    
    // MARK: UIPageViewControllerDataSource
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: StoryboardConstants.ExploreEventsParentVC),
                self.newVc(viewController: StoryboardConstants.LeaderboardTable),
               self.newVc(viewController: StoryboardConstants.UserEventsTable)]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self

        
        
        
        // This sets up the first view that will show up on our page control
        let firstViewController = orderedViewControllers[1]
        setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        
        configurePageControl()
        
        // Do any additional setup after loading the view.
    }
    
    func presentLeftView() {
        let currentIndex = pageControl.currentPage
        if currentIndex == 0 {
            return
        }
        self.setViewControllers([orderedViewControllers[currentIndex - 1]], direction: .reverse, animated: true, completion: nil)
        
        pageControl.currentPage = currentIndex - 1
    }
    
    func presentRightView() {
        let currentIndex = pageControl.currentPage
        if currentIndex == orderedViewControllers.count + 1 {
            return
        }
        self.setViewControllers([orderedViewControllers[currentIndex + 1]], direction: .forward, animated: true, completion: nil)
        
        pageControl.currentPage = currentIndex + 1
        
    }
    
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 1
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    
    // MARK: Delegate methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            //return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            //return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
}
