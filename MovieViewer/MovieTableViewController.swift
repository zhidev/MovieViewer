//
//  MovieTableViewController.swift
//  MovieViewer
//
//  Created by Douglas on 1/24/16.
//  Copyright © 2016 Dougli. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!

    var tmovies: [NSDictionary]?
    var filteredtmovies: [NSDictionary]?
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        createTable()

        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredtmovies = filteredtmovies {
            return filteredtmovies.count
        }
        else{
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTCell", forIndexPath: indexPath) as! MovieTCell
        
        let movie = filteredtmovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let posterPath = movie["poster_path"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.posterView.setImageWithURL(imageUrl!)
        
        print("row: \(indexPath.row)")
        return cell
    }
    
    func createURL() -> NSURL{
        let urlPath = NSURL( string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        return urlPath!
    }
    
    func createTable(){
        let request = createURL()
        dataCall(request)
    }
    func dataCall(url: NSURL){
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
                            self.filteredtmovies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                    }
                }
        })
        task.resume()
    }
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // ... Create the NSURLRequest (myRequest) ...
        let request = NSURLRequest(URL: createURL() )
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                
                // ... Use the new data to update the data source ...
                
                // Reload the tableView now that there is new data
                // + Show & Hide HUD and junk
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.tableView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
        });
        task.resume()
        //showSearchbar()
        //checkNet()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredtmovies = searchText.isEmpty ? tmovies : tmovies?.filter({ (movies: NSDictionary) -> Bool in
            if let title = movies["title"] as? String {
                if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                }
                else{
                    return false
                }
            }
            return false
        })
        tableView.reloadData()
    }
}
