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
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    

    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test")

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
	
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "closeSearchbar")
        view.addGestureRecognizer(tap)
        
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
        
        let movie = filteredMovies![indexPath.row]
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: imageURL!)
            cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition can leave this for now
                    // maybe use place holder image
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
        showSearchbar()
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
        let urlPath = NSURL( string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
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
     // TODO create first responder to make keyboard come otu when begin editting in searcdhbar. additional optional
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {

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
        let layer = Color.makeLayer(rect)
        self.gradientView.layer.addSublayer(layer)
    }
    
    
    //Calls this function when the tap is recognized.
    func closeSearchbar() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        searchBar.endEditing(true)
        //searchBar.hidden = true
        UIView.animateWithDuration(0.4, animations: {
            self.searchBar.alpha = 0
        })
        print("search hide")
        
    }
    func showSearchbar(){
        //searchBar.hidden = false
        print("search show")
        UIView.animateWithDuration(0.4, animations: {
            self.searchBar.alpha = 1
        })
    }
    
    // ================ SEQUES==========
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "selected"{
            let controller = segue.destinationViewController as! selectedViewController

            print("testerino pizzarino")
            
        }
        if segue.identifier == "tableview"{
        }
        else{
            assert(false , "Shouldn't see this, unrecognized segue : \(segue.identifier)")
        }

    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("potato")
        self.performSegueWithIdentifier("selected", sender: self)
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
}
