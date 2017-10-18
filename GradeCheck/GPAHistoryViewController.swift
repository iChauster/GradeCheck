//
//  GPAHistoryViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 10/3/17.
//  Copyright © 2017 Ivan Chau. All rights reserved.
//

import UIKit

class GPAHistoryViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllersArray.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllersArray.count > previousIndex else {
            return nil
        }
        
        return viewControllersArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllersArray.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = viewControllersArray.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return viewControllersArray[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllersArray.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = viewControllersArray.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    var pageView : UIPageViewController!
    var cookie : String!
    var idString : String!
    let url = "http://gradecheck.herokuapp.com/"
    var viewControllersArray = [UIViewController]()
    let grades = ["09", "10", "11", "12"]
    override func viewDidLoad() {
        super.viewDidLoad()
        print(cookie)
        print(self.idString)
        dataSource = self
        delegate = self
        
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let id : String = UserDefaults.standard.object(forKey: "id") as! String
        let idString = "&id=" + id
        var postData = NSData(data: cookieString.data(using: String.Encoding.utf8)!) as Data
        postData.append(idString.data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: URL(string: url + "gradeHistory")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "Darn")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "Darn")
                if(httpResponse?.statusCode == 200){
                    DispatchQueue.main.async(execute: {
                        do{
                            let data = try JSONSerialization.jsonObject(with: data!, options: []) as! Array<Any>;
                            let history = data[0]
                            let dict = history as! Dictionary<String, Array<Any>>
                            print(dict)
                            for i in 0..<self.grades.count {
                                let str = self.grades[i]
                                if let a = dict[str] {
                                    print(a)
                                    let c = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YVC") as! YearViewController
                                    c.data = a
                                    c.yearString = str
                                    self.viewControllersArray.append(c)
                                }
                            }
                            self.setViewControllers([self.viewControllersArray[0]], direction: .forward, animated: true, completion: nil)
                            
                            
                        }catch{
                            
                        }
                    })
                    
                }
            }
        })
        
        dataTask.resume()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        //corrects scrollview frame to allow for full-screen view controller pages
        for subView in self.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            }
        }
        super.viewDidLayoutSubviews()
    }
    @objc func dismissController(){
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
