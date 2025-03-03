# UV-AMSE-2025
## Flutter Development
### Install projects
#### using the pre built apk
Simply download the apk in the [Releases section](https://github.com/Rayyze/UV-AMSE-2025/releases) of the github repository.
#### using flutter and chromium
Install flutter onto your machine and add it to the path environement variable.
Install chromium (or chrome).
open a terminal in the project you want to run (mediawind or slideit folders) and run 
```bash
flutter run -d chrome --release
```
### Project GraceWind (formerly MediaWind)
#### Objectives
The goal of this first project was to create an application to manage media (of any kind) with a favorite system.
#### features
 - Browse Information : Search and filter data. 
 - Favorite Items : Save and manage your favorite entries.
 - Live Data : Always up-to-date with the latest API content.

I chose to use the [Elden Ring fan API](https://eldenring.fanapis.com) and manage the entries as if they were media. I created macro categories that contain real categories which are treated as subcategories. Each page available in the menu allow access to one category except for about and home, home fetches all entries from the API. Each page allow for precise searching through keywords and filters.

#### Additional information 

The logo was made by myself and is also the icon for the app on phone.
    
The favorites feature works on web browsers but does not store info between instances due to how shared preferences works on browsers however the feature work as intended on android devices.

### Project SlideIt
#### Objectives
The goal of this second project was to create a game of sliding puzzle featuring images.
#### features
    - Choose between random images and images from gallery
    - Settings to manage difficulty, size, volume and dark/light mode
    - Undo last move
    - Estimation of number of moves
    - Continue previous game
#### Additional information 

The logo was made by myself and is also the icon for the app on phone.
    
The continue game feature works on web browsers but does not store info between instances due to how shared preferences works on browsers however the feature work as intended on android devices.