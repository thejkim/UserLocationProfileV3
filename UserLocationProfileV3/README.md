# User Location and Profile
- Display user's current location in human-readable format(city, state, country)
- Allow user to set profile image
- Display articles for current country
- Load article url in-app

# Requirement
<h3> 1. Geting and displaying user's current location <h3>

- Ask/check for access permission for location information
- Geocoding: longitude, latitude to address(city, state, country)

<h3> 2. User Profile <h3>

- Allow user to select image from photo library to set as profile image
- Save photo in document directory
- Save photo id in core data
- Load and display saved photo

<h3> 3. Multithreading <h3>

- Use subthread if applicable

# Contribution
[Jun 11]
- Anatomy of app: Location Tracking, Profile pages
- Singleton class for CLLocationManager implimented: ST_LocationManager
- Ask/check for access permission for location information: foreground, whenInUse, implemented

[Jun 12]
- Updated anatomy of app: login, location tracking, profile pages
- login: register or login by username
- Core Data created: UserProfile entity
- Singleton class for Core Data implemented: CoreDataManager
    - protocol ST_LocationManagerDelegate implemented: letting VC and this singleton class communicate each other
- Opening photo library / camera
- Setting user profile image
- Saving user profile image information
    1. Image to document directory
        - image name format: username_timestamp
    2. Image name as id into Core data
- Loading user profile image from document directory
    - filter file by username
- Replacing existing user profile image to newly selected image
- Deleting user profile image implemented
- Multithreading
    - Applied DispatchQueue main, global to appropriate places
        1. Geocoding: longitude, latitude -> city, state, country
        2. Saving user profile image information into Core Data and document directory
        3. Loading user profile image from document directory

[Jun 13]
- Unnecessary subthread removed
- Minor edits

[Jun 14]
- manage image content mode: set the user profile button's background image to be scaleAspectFill mode

[Jun 15]
- send GET Request to fetch articles for current location's country from newsapi.org
- download images, uploading up to 10 collected images in document directory
- remove old image if it reaches limit to download new file
- tableview to display article implemented
- open article link and load it in webview
- multithreading applied

[Jun 16]
- Reachability included: checks network reachability
- Uploading up to 10 collected images in document directory updated
    - once tapped to first 10 articles while loading articles

[Jun 17]
- Loading saved images fixed
- Found bug: Loading user profile image - fixed
- ~~"Loading" message for user profile~~ apprears once it starts loading, not beforehand
- Displaying activity indicator instead of displaying "loading" message while loading

[TODO]
- dismiss LocationServiceAuthorizationVC once user made decision on location service permission
