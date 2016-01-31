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

    var tmovies: [NSDictionary]?
    var filteredtmovies: [NSDictionary]?
    
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
        
        if let posterPath = movie["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
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
            print("tselected segue test")
        
        print("fish")
        let movie = filteredtmovies![indexPath!.row]
        print("fish potato")
        let detailViewController = segue.destinationViewController as! selectedViewController
        print("fishy potato fish")
        detailViewController.movie = movie
        print("taco")
        print(detailViewController)
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

}
