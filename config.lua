Config = {}

--This literally will just flood anything helpful for debugging, If your not debugging dont use it.
Config.debug = false

----QB Core Frame work, and its configuration - This is meant for base QBCore events, and functions.
Config.isQB = false -- Vehicles, Characters
Config.QBRegCurrent = false -- Literally will reigster a character when a previous is loaded (not created/deleted), as long as that unique citizen ID isnt already in the CAD.

--Nat2K15 Frame work, and its configuration
Config.isNat2K15 = false
Config.resourceName = "framework"

--This will mark them off duty once they leave the game. (Requires a verfified discord ID, and they must be active within your community on the CAD)
Config.cadkickonleave = true

--simply requires them to do /verify to ensure there discord ID matches a verified account within ImperialCAD
Config.requireVerify = false -- NOT FINISHED

--Should these chat commands exist:
Config.PlateThroughChat = false -- this is broken atm, dont use it.
Config.TsThroughChat = true
Config.AttachThroughChat = true
Config.Allow911Command = true -- This literally is for the /911 command, if you dont need it, disable it.

--Should a radius style blip appear on the map for new 911 calls? (This does require ImperialDuty)
Config.callBlip = true

--Traffic Stop command Related config (This is useless if your "Config.TsThroughChat" is false)
Config.trafficsnature = "Traffic Stop"
Config.trafficspriority = "3"
Config.trafficsstatus = "ACTIVE"