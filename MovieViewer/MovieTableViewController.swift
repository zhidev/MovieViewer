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
        
        
        searchBar.delegate = self
        
        createTable()

        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        let tableBGView = UIImage(named: "gradiant-background")
        self.tableView.backgroundView = UIImageView.init(image: tableBGView, highlightedImage: tableBGView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataRetrieved:", name: "DataCallRetrievedTableView", object: nil)
        

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
        cell.filteredMovieData = movie
        /* Giant block of code moved into MovieTCell didSet of filteredMovieData */
        
        
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
        //dataCall(request)
        DataManager.dataCall(request, collectionOrTable: 1)
    }
    
    /*func dataCall(url: NSURL){
        Code refactoed into DataManager
    }*/
    
    
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
    
    func dataRetrieved(notification: NSNotification){
        let userInfo = notification.userInfo!["movieData"] as! [NSDictionary]
        self.tmovies = userInfo
        self.filteredtmovies = userInfo
        self.tableView.reloadData()
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }

}
