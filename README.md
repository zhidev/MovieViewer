Movie Viewer is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: 3 hours 40 minutes spent in total for required and optional

Time spent on additional: 2hour 40


## User Stories

The following **required** functionality is complete:

- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [x] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] User sees an error message when there's a networking error.
- [x] Movies are displayed using a CollectionView instead of a TableView.
- [X] User can search for a movie.
- [x] All images fade in as they are loading.
- [x] Customize the UI.

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!
- [x] Searchbar and keyboard fades out when user taps elsewhere
- [x] Transitions from Collection View to displaying Movie information
- [x] Switching between Collection View and Table View
- [x] Hide searchbar by clicking elsewhere
- [x] Fades searchbar in while doing a pull to refresh

The following storyboards are in mind:
- [ ] Keep a static gradient background for tableview cells while scrolling
- [ ] Favorites Tab
- [x] Remember what movie was selected and place so user doesn't have to scroll down again
- [ ] More cosmetics for MovieSelectedViewController (ie fading images in, sliding in text, etc.)
- [x] Mirror collectionVew to tableView




## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/G7Aqr04.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

-No auto-layout made some of the spacing really weird, for example tableview doesnt occupy the full simulator window
-CollectionView not working as intended for initiating a segue transition, unsure if its limited to collectionViews only or tableViews will experiment more later at my leisure, but the method didselectitematindexpath isnt working as intuitively as I thought
-Lots of fancy ways to create graphical art programmatically
-Adding a nav bar seems to complicate the view controllers or there were certain intuitive interactions I did that created issues later on

Biggest difficulty: Getting the collectionView to perform a segue while theres a view used as a background. I may have overcomplicated this step and the solutions found online seems too time consuming to tackle before getting other faster storyboards done with


## License

    Copyright 2016 Douglas Li

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


=====================================================================================
Week 2
Time Spent:
Required + Optional: 3 Hours 10 minutes
Additional: 20 minutes


The following **required** functionality is complete:
- [x] User can view movie details by tapping on a cell.
- [x] User can select from a tab bar for either Now Playing or Top Rated movies. *
- [x] Customize the selection effect of the cell.

* Instead of making 2 of the same type of View Controllers for Now Playing and Top Rated, 
I put two different view controller one containing a tableview and one containing a collection
view. Since this applies the same concept and techniques as mentioned I figured this is okay
and feels more natural to me. As for the top rated + now playing portions, refer to additional



The following **optional** features are implemented:
- [x] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [x] Customize the navigation bar.
- [x] Add in any optionals you didn't finish from last week.

The following **additional** features are implemented:
- [x] Moved Now Playing and Top Rated switching to a segmented control
- [x] Matched background view of detailed movies to keep the same view depending on which 
view we entered from
- [x] Hide segmented control with search bar so there isnt over clutter of information

## Video Walkthrough 

Here's a walkthrough of implemented user stories of week 2 of MovieViewer:

<img src='http://i.imgur.com/jg4KrXa.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

http://i.imgur.com/G7Aqr04.gif
GIF created with [LiceCap](http://www.cockos.com/licecap/).
