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


class MovieViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var gradientView: UIView!
    
    @IBOutlet var networkBar: UITextView!
    @IBOutlet var searchBar: UISearchBar!
    
    var endpoint: String!
    var showSearch = false
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    let segmentedControls = ["now_playing", "top_rated"]
    
    
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CollectionView test")
        
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "navSearch"), animated: true)

        
        closeSearchbar()
        setBackgroundGradient()
        networkBar.hidden = true
        

        collectionView.dataSource = self
        collectionView.delegate = self
        //  For search bar later
        
        searchBar.delegate = self
        
        /* Condensed to MARK 1 and 2 */
        createCollection()
        
        //  Pulldown refresh
        //  Initializing a UIRefreshControl
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
	
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        else{
            return 0
        }
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCCell
        
        checkNet()
        //Low res + high res images
        let low_resolution = "https://image.tmdb.org/t/p/w45"
        let high_resolution = "https://image.tmdb.org/t/p/original"
        
        let movie = filteredMovies![indexPath.row]
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

    // MARK: WIP pull down request refresh
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
                self.collectionView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()	
        });
        task.resume()
        //showSearchbar()
        checkNet()
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
                            self.filteredMovies = responseDictionary["results"] as? [NSDictionary]
                            self.collectionView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                    }
                }
        });
        task.resume()
    
        checkNet()
        
    }
    
    // MARK 1
    func createURL() -> NSURL{
        let selectedSegment = segmentedControls[segmentedControl.selectedSegmentIndex]
        let urlPath = NSURL( string: "https://api.themoviedb.org/3/movie/\(selectedSegment)?api_key=\(apiKey)")
        return urlPath!
    }
    
    // Make the network connection to update our collection view. Flag if neccesary
    func createCollection(){
        let request = createURL()
        dataCall(request)
    }
    
    //  Search Bar stuff
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies?.filter({ (movies: NSDictionary) -> Bool in
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
        collectionView.reloadData()
    }

    // Check network conenction. Call this everytime we reload data or make a network conenction
    func checkNet(){
        if Reachability.isConnectedToNetwork() == true {
            networkBar.hidden = true
        } else {
            networkBar.hidden = false
        }
    }
    //Make collectionview background pretty with gradient
    func setBackgroundGradient(){
        let rect = self.collectionView.bounds
        let layer = Color.makeLayer(rect, input: "light")
        self.gradientView.layer.addSublayer(layer)
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
    
    // ================ SEQUES==========

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        if(segue.identifier == "cselected"){
            print("cselected")
            let movie = filteredMovies![indexPath!.row]
            let detailViewController = segue.destinationViewController as! selectedViewController
            detailViewController.movie = movie
            detailViewController.theme = "light"
        }
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        highlightCell(indexPath, flag: false)
        print("highlight")
    }
    func highlightCell(indexPath : NSIndexPath, flag: Bool) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        if flag {
            cell?.contentView.backgroundColor = UIColor.magentaColor()
        } else {
            cell?.contentView.backgroundColor = nil
        }
    }
    @IBAction func valueChange(sender: AnyObject) {
        createCollection()
    }
}
