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

class MovieTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet var tableView: UITableView!

    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var bgView: UIView!
    var tmovies: [NSDictionary]?
    var filteredtmovies: [NSDictionary]?
    
   let segmentedControls = ["now_playing", "top_rated"]
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    var showSearch = false
    
    @IBOutlet var searchBar: UISearchBar!
    //@IBOutlet var networkBar: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setBackgroundGradient()
       // networkBar.hidden = true
        
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "navSearch"), animated: true)
        
        closeSearchbar()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        print("TableView Test")
        
        searchBar.delegate = self
        
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
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        //Low res + high res images
        let low_resolution = "https://image.tmdb.org/t/p/w45"
        let high_resolution = "https://image.tmdb.org/t/p/original"
        
        if let posterPath = movie["poster_path"] as? String {
            let lowRes = NSURL(string: low_resolution + posterPath)
            let highRes = NSURL(string: high_resolution + posterPath)
            
            //let imageURL = NSURL(string: baseUrl + posterPath)
            //let imageRequest = NSURLRequest(URL: imageURL!)
            let lowImageRequest = NSURLRequest(URL: lowRes!)
            let highImageRequest = NSURLRequest(URL: highRes!)
            cell.posterView.setImageWithURLRequest(
                lowImageRequest,
                placeholderImage: nil,
                success: { (lowImageRequest, lowImageResponse, lowImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = lowImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        cell.posterView.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            cell.posterView.setImageWithURLRequest(
                                highImageRequest,
                                placeholderImage: lowImage,
                                success: { (highImageRequest, highImageResponse, highImage) -> Void in
                                    
                                    cell.posterView.image = highImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select row at indexpath")
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.blueColor()
        cell!.selectedBackgroundView = backgroundView
    }
    
    func createURL() -> NSURL{
        let selectedSegment = segmentedControls[segmentedControl.selectedSegmentIndex]
        let urlPath = NSURL( string: "https://api.themoviedb.org/3/movie/\(selectedSegment)?api_key=\(apiKey)")
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
                            self.tmovies = responseDictionary["results"] as? [NSDictionary]
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
        //checkNet()
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        if(segue.identifier == "tselected"){
        
            let movie = filteredtmovies![indexPath!.row]
            let detailViewController = segue.destinationViewController as! selectedViewController
            detailViewController.movie = movie
            detailViewController.theme = "dark"
        }
    }
    
    //Make tableview background pretty with gradient
    /*func setBackgroundGradient(){
        let rect = self.tableView.bounds
        let layer = Color.makeLayer(rect)
        self.bgView.layer.addSublayer(layer)
        self.tableView.layer.addSublayer(layer)
        self.tableView.backgroundView?.addSubview(bgView)
    }*/
    
    /*func checkNet(){
        if Reachability.isConnectedToNetwork() == true {
            networkBar.hidden = true
        } else {
            networkBar.hidden = false
        }
    }*/
    
    //  Search Bar stuff
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredtmovies = searchText.isEmpty ? tmovies : tmovies?.filter({ (tmovies: NSDictionary) -> Bool in
            if let title = tmovies["title"] as? String {
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
    
    //Calls this function when the nav search button is recognized.
    func navSearch(){
        showSearch = !showSearch
        if( showSearch){
            showSearchbar()
        }
        else{
            closeSearchbar()
        }
    }
    
    func closeSearchbar() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        searchBar.endEditing(true)
        //searchBar.hidden = true
        UIView.animateWithDuration(0.4, animations: {
            self.searchBar.alpha = 0
        })
        print("search hide")
        searchBar.resignFirstResponder()
        
    }
    func showSearchbar(){
        //searchBar.hidden = false
        print("search show")
        UIView.animateWithDuration(0.4, animations: {
            self.searchBar.alpha = 1
        })
        searchBar.becomeFirstResponder()
    }
    @IBAction func valueChange(sender: AnyObject) {
        createTable()
    }

}
