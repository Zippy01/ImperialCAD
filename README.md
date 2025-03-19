# ImperialCAD

## Description
ImperialCAD is an advanced FiveM integration that enhances role-playing by combining civilian management, emergency services, and device interaction into a cohesive system, designed to interface with the external ImperialCAD.app.

## Features
- **Ingame Civilian Management & Features**
- **Ingame Emergency Services & Features**
- **Ingame ImperialCAD Tablet**
- **Over 15+ Developer Exports & Events**
- **Framework Integration for Nat2k15 & QB Core**

## Installation
1. Download from the GitHub repository.
2. Place the folder in your FiveM `resources` directory.
3. Review and configure `config.lua` to your liking.
3. Include `ensure ImperialCAD` in your `server.cfg`.

## Community Configuration
Required: a community ID and API Secret Key from Imperial CAD:
- Find the community ID in Admin Panel > Settings > Plugin.
- Add to `server.cfg`:

```
setr imperial_community_id "COMMUNITY_ID_HERE" 
set imperialAPI "API_Secret_Key_HERE"
```


## Dependencies
- **OXLib**: Core functionality.
- **ImperialLocation**: Location services.
[ImperialLocation GitHub](https://github.com/Zippy01/ImperialLocation)

## Recommended Additional Resources
- **ImperialDuty**: Enhances in-game alerts.
- **DriversLic**: Manages driver's licenses.
[DriversLic GitHub](https://github.com/Zippy01/DriversLic)

## Commands
### Civilian
- `/setciv <SSN>`
- `/getciv`
- `/clearciv`
- `/regveh`

### Tablet
- `/tablet`

### Emergency
- `/911 <description>`
- `/panic`
- `/rplate <plate>`
- `/ts <details>`
- `/attach <callnum>`

## Contributing
Fork, modify, and submit pull requests to contribute.

## License
Owned by Imperial Solutions. Unauthorized copying, distribution, or use without explicit permission is prohibited and may result in legal action.
