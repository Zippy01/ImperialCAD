Config = {}

--This literally will just flood anything helpful for debugging, If your not debugging dont use it.
Config.debug = false
Config.DisableVersionCheck = false -- Why would you even do this? It disbales the version check on resource start

--Make it so the tablet only can be accessed inside of a emergency vehicle? 
Config.tabletCarRestriction = false

----QB Core Frame work, and its configuration - This is meant for base QBCore events, and functions.
Config.isQB = false -- Vehicles, Characters
Config.QBRegCurrent = false -- Literally will register a character when a previous is loaded (not created/deleted), as long as that unique citizen ID isnt already in the CAD.

--Nat2K15 Frame work, and its configuration
Config.isNAT2K15 = false
Config.resourceName = "framework"

----QBX Core Frame work, and its configuration - This is meant for base QBCore events, and functions.
Config.isQBX = false

--ERS Integration / Support - Simply tells our ImperialCAD resource to listen for the ERS events and integrations. (This required the Advanced plan or higher)
Config.ERSsupport = false
Config.UseERSPulloverEnded = false -- This often results in premature call closes and isnt recommended, but if set to true we will close your current call if ERS says your pullover is ended.
Config.UseERSCalloutEnded = false -- This may results in premature call closes, but if set to true we will close your current call if ERS says your callout has ended.
Config.UseERSCalloutCompletedSuccesfully = false -- This may results in premature call closes, but if set to true we will close your current call if ERS says your callout was completed.
Config.ImperialDutySync = true -- ImperialDuty will sync with the event ERS transmit based on shift toggles.

--Enable livemap support? (This requires a Premium plan)
Config.livemap = false

--This will mark them off duty once they leave the game. (Requires a verfified discord ID, and they must be active within your community on the CAD)
Config.cadkickonleave = true

--simply requires them to do /verify to ensure there discord ID matches a verified account within ImperialCAD
Config.requireVerify = false -- NOT FINISHED

-- This will determine how often (in seconds) ImperialLocation will update each users current postal, city, and county for ImperialCAD API calls. (Only change this if you are experincing performance issues.) 
Config.locationFrequency = 10

Config.DisableDutyCommand = false -- Enabling this basically just listens for its events to mark users duty for in-game notis and prevents our command from registering

Config.GiveLEOWeapons = true -- If you want to give weapons to the players who go on duty as LEO

Config.LEOWeapons = {
    "WEAPON_COMBATPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_NIGHTSTICK",
    "WEAPON_FLASHLIGHT",
    "WEAPON_CARBINERIFLE",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PUMPSHOTGUN"
}

Config.GiveFIREWeapons = true -- If you want to give weapons to the players who go on duty as FIRE

Config.FIREWeapons = {
    "WEAPON_FIREEXTINGUISHER",
}

Config.SendWebhook = false -- If you want to send a webhook when someone goes on/off duty

Config.WebhookURL = "WEBHOOK URL HERE" -- Webhook URL

--Should these chat commands exist:
Config.TsThroughChat = true
Config.PlateThroughChat = true -- Allows users to run a plate using the /rplate command
Config.AttachThroughChat = true
Config.Allow911Command = true -- This will allow /a911 for Anonymous calls and /911 for normal calls that trys to send a caller based on active civ or username, if you dont need it, disable it.
Config.callCooldown = 60 -- Seconds a player must wait before sending another 911 call.

--Should a radius style blip appear on the map for new 911 calls? (This works with ImperialDuty)
Config.callBlip = true
Config.callBlipDuration = 5 --In minutes

--Traffic Stop command Related config (This is useless if your "Config.TsThroughChat" is false)
Config.trafficsnature = "Traffic Stop"
Config.trafficspriority = "3"
Config.trafficsstatus = "ACTIVE"


-- If you touch anything on the left of the equal sign, aka not inside of the quotes on the right you will break everything.
-- For example; Chaning setciv to activeciv would be { setciv = "activeciv", }
Config.commands = {
    setciv = "setciv", -- The command to set the players active ImperialCAD character. This is used for the ID script, reg vehicle command, any other in-game char actions, and will attempt to set this as the active civilian in their imperialcad civilian panel.
    getciv = "getciv", -- Prints all the current locally stored ImperialCAD character data
    clearciv = "clearciv", -- CLears the current locally stored ImperialCAD character data
    regveh = "regveh", -- Register players current vehicle to their currently locally selected ImperialCAD character
    id = "id", -- Allows players to view their ID of their currently selected ImperialCAD character
    hideid = "hideid", -- To hide any ID on the players screen
    giveid = "giveid", -- Allows the player to show the closest player within 2m their currently selected ImperialCAD character
    duty = "duty", -- Lets the FiveM resource know the user wants to enage with the cad from in-game? (idk how to word it ngl)
    tablet = "tablet", -- How players will open the ImperialCAD Iframe tablet.
}
