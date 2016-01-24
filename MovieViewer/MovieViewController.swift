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

class MovieViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    
    //  For Search Filter
    //  Actually I dont think we even need this. TBD
    //var filteredMovies: [NSDictionary]? // TODO : Optional? Force Unwrap? ???? lets leave this here in case we need to change
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODOtableView.delegate = self
        //TODOtableView.dataSource = self
        collectionView.dataSource = self
        //  For search bar later
        
        searchBar.delegate = self
        
        
        
        /* Condensed to MARK 1 and 2 */
        let request = createURL()
        dataCall(request)
        
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
        let movie = filteredMovies![indexPath.row]
        /*let title = movie["title"] as! String
        let overview = movie["overview"] as! String*/
        let posterPath = movie["poster_path"] as! String
        
        
        let imageURL = NSURL(string: baseUrl + posterPath)
        let imageRequest = NSURLRequest(URL: imageURL!)
        
        /*cell.titleLabel.text = title
        print(title)*/
        /* cell.overviewLabel.text = overview
        print(overview) */
        
        
        //cell.posterView.setImageWithURL(imageURL!)
        //Changing the ^ to fade in
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
    
        
        
    }
    
    // MARK 1
    func createURL() -> NSURL{
        let urlPath = NSURL( string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        return urlPath!
    }
    
    //  Search Bar stuff (Need to pull up keyboard maybe)
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
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
}
