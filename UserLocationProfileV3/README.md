# User Location and Profile
- Display user's current location in human-readable format(city, state, country)
- Allow user to set profile image

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

[TODO]
- dismiss LocationServiceAuthorizationVC once user made decision on location service permission
