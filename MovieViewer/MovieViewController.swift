//
//  MovieViewController.swift
//  MovieViewer
//
//  Created by Douglas on 1/18/16.
//  Copyright © 2016 Dougli. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var movies: [NSDictionary]?
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        /* Condensed to MARK 1 and 2 */
        let request = createURL()
        dataCall(request)
        
        //  Pulldown refresh
        //  Initializing a UIRefreshControl
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }
        else{
            return 0
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        
        
        let imageURL = NSURL(string: baseUrl + posterPath)
    
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageURL!)
                return cell
    }

    // MARK: WIP pull down request refresh
    func refreshControlAction(refreshControl: UIRefreshControl) {
        print("MARK TEST")
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
                print("TEST")
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()	
        });
        task.resume()
    }
    
    
    // MARK 2
    func dataCall( url: NSURL ){
        let request = NSURLRequest(URL: url)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                    }
                }
        });
        task.resume()
    
        
        
    }
    
    // MARK 1
    func createURL() -> NSURL{
        let urlPath = NSURL( string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        return urlPath!
    }
    /*
    func scrollViewDidScroll(scrollView: UIScrollView) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        tableView.reloadData()
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }*/
    
    
}
