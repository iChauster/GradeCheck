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
        return UIViewController()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return UIViewController()
    }
    
    var pageView : UIPageViewController!
    var cookie : String!
    var idString : String!
    //let url = "http://gradecheck.herokuapp.com/"
    let url = "http://localhost:2800/"
    override func viewDidLoad() {
        super.viewDidLoad()
        print(cookie)
        print(self.idString)
        self.dataSource = self
        let c = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YVC")
        var r = [c]
        self.setViewControllers(r, direction: .forward, animated: true, completion: nil)
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
                            var data = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            print(data)
                        }catch{
                            
                        }
                    })
                    
                }
            }
        })
        
        dataTask.resume()
        // Do any additional setup after loading the view.
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
