# ImperialCAD

## Description
ImperialCAD is a comprehensive integration designed to enhance role-playing in FiveM by combining functionalities from civilian management, emergency services, and interactive devices into a single, streamlined system.

## Features
- **Ingame Civilian Management & Features**
- **Ingame Emergency Services & Features**
- **Ingame ImperialCAD Tablet**

## Installation
1. Download the files from the GitHub repository.
2. Extract the folder into your `resources` directory in FiveM.
3. Add `ensure ImperialCAD` to your server's `server.cfg` file.

## Community Configuration
The script requires a community ID and API Secret Key from Imperial CAD:
- Locate your community ID in Admin Panel > Settings > Plugin.
- Add these lines to the top of your server.cfg file:

```
setr imperial_community_id "COMMUNITY_ID_HERE" 
setr imperialAPI "API_Secret_Key_HERE"
```

## Dependencies
- **OXLib**: Required for core functionalities.
- **ImperialLocation**: Essential for location-based services.
[ImperialLocation GitHub](https://github.com/Zippy01/ImperialLocation)

## Recommended Additional Resources
- **ImperialDuty**: Enhances in-game alerts and emergency service functionalities.
- **DriversLic**: Adds a realistic touch for managing driver's licenses.
[DriversLic GitHub](https://github.com/Zippy01/DriversLic)

## Commands
### Civilian
- `/setciv <SSN>` - Activates the civilian profile linked to the SSN.
- `/getciv` - Shows the active civilian profile.
- `/clearciv` - Clears the current civilian profile.
- `/regveh` - Registers the vehicle you are currently in.

### Tablet
- `/tablet` - Toggles the virtual tablet on or off.

### Emergency
- `/911 <description>` - Reports an emergency with a description.
- `/panic` - Activates a panic alert.
- `/rplate <plate>` - Retrieves information about a vehicle plate.
- `/ts <details>` - Initiates a traffic stop.
- `/attach <callnum>` - Attaches to an ongoing call.

## Contributing
Please fork the repository, make changes, and submit a pull request if you wish to contribute.

## License
This script is owned by Imperial Solutions. Unauthorized copying, distribution, or use of this script without explicit permission is prohibited and may lead to legal repercussions.
