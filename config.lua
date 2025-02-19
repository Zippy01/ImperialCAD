Config = {}

--This literally will just flood anything helpful for debugging, If your not debugging dont use it.
Config.debug = true

--Framework questions, if you check something that doesnt apply, itll throw alot of errors.
Config.isQB = false -- not finished [Currently chacters are created and deleted in CAD in junction with QB-Multichacter]
Config.isESX = false -- not started
Config.isND = false -- not started

--This will mark them off duty once they leave the game. (Requires a verfified discord ID, and they must be active within your community on the CAD)
Config.cadkickonleave = true

--simply requires them to do /verify to ensure there discord ID matches a verified account within ImperialCAD
Config.requireVerify = false -- NOT FINISHED

--Should these chat commands exist:
Config.PlateThroughChat = true
Config.TsThroughChat = true
Config.AttachThroughChat = true

--Should a radius style blip appear on the map for new 911 calls? (This does require ImperialDuty)
Config.callBlip = true


--Traffic Stop command Related config (This is useless if your "Config.TsThroughChat" is false)
Config.trafficsnature = "Traffic Stop"
Config.trafficspriority = "3"
Config.trafficsstatus = "ACTIVE"