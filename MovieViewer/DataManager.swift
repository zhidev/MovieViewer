//
//  DataManager.swift
//  MovieViewer
//
//  Created by Douglas on 3/28/16.
//  Copyright © 2016 Dougli. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
	   class func dataCall(url: NSURL, collectionOrTable: Int){
        let request = NSURLRequest(
            URL: url,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //self.tmovies = responseDictionary["results"] as? [NSDictionary]
                            //self.filteredtmovies = responseDictionary["results"] as? [NSDictionary]
                            //self.tableView.reloadData()
                            //MBProgressHUD.hideHUDForView(self.view, animated: true)
                            let returnDictionary = responseDictionary["results"] as? [NSDictionary]
                            if collectionOrTable == 0{
                                NSNotificationCenter.defaultCenter().postNotificationName("DataCallRetrievedCollectionView", object: self, userInfo: ["movieData":returnDictionary!])
                            }
                            if collectionOrTable == 1{
                                NSNotificationCenter.defaultCenter().postNotificationName("DataCallRetrievedTableView", object: self, userInfo: ["movieData":returnDictionary!])
                            }
                    }
                }
        })
        task.resume()
        
    }
    
}
