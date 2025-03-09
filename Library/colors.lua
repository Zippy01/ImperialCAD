local colorNames = {
    [0] = "Metallic Black",
    [1] = "Metallic Graphite",
    [2] = "Metallic Black Steel",
    [3] = "Metallic Dark Silver",
    [4] = "Metallic Silver",
    [5] = "Metallic Blue Silver",
    [6] = "Metallic Steel Gray",
    [7] = "Metallic Shadow Silver",
    [8] = "Metallic Stone Silver",
    [9] = "Metallic Midnight Silver",
    [10] = "Metallic Gun Metal",
    [11] = "Matte Black",
    [12] = "Matte Gray",
    [13] = "Matte Light Grey",
    [14] = "Util Black",
    [15] = "Util Black Poly",
    [16] = "Util Dark Silver",
    [17] = "Util Silver",
    [18] = "Util Gun Metal",
    [19] = "Util Shadow Silver",
    [20] = "Metallic Red",
    [21] = "Metallic Torino Red",
    [22] = "Metallic Formula Red",
    [23] = "Metallic Blaze Red",
    [24] = "Metallic Graceful Red",
    [25] = "Metallic Garnet Red",
    [26] = "Metallic Desert Red",
    [27] = "Metallic Cabernet Red",
    [28] = "Metallic Candy Red",
    [29] = "Metallic Sunrise Orange",
    [30] = "Metallic Classic Gold",
    [31] = "Metallic Orange",
    [32] = "Matte Red",
    [33] = "Matte Dark Red",
    [34] = "Matte Orange",
    [35] = "Metallic Dark Green",
    [36] = "Metallic Racing Green",
    [37] = "Metallic Sea Green",
    [38] = "Metallic Olive Green",
    [39] = "Metallic Green",
    [40] = "Metallic Gasoline Blue Green",
    [41] = "Matte Lime Green",
    [42] = "Dark Green",
    [43] = "Matte Green",
    [44] = "Worn Green",
    [45] = "Metallic Electric Blue",
    [46] = "Metallic Dark Blue",
    [47] = "Metallic Midnight Blue",
    [48] = "Metallic Saxon Blue",
    [49] = "Metallic Blue",
    [50] = "Metallic Mariner Blue",
    [51] = "Metallic Harbor Blue",
    [52] = "Metallic Diamond Blue",
    [53] = "Bright Green",
    [54] = "Metallic Nautical Blue",
    [55] = "Metallic Bright Blue",
    [56] = "Metallic Purple Blue",
    [57] = "Metallic Spinnaker Blue",
    [58] = "Metallic Ultra Blue",
    [59] = "Metallic Bright Purple",
    [60] = "Metallic Cream",
    [61] = "Metallic Ice White",
    [62] = "Metallic Frost White",
    [63] = "Metallic Saxon Blue",
[64] = "Blue",
[65] = "Mariner Blue",
[66] = "Harbor Blue",
[67] = "Diamond Blue",
[68] = "Surf Blue",
[69] = "Nautical Blue",
[70] = "Ultra Blue",
[71] = "Schafter Purple",
[72] = "Spinnaker Purple",
[73] = "Racing Blue",
[74] = "Light Blue",
[75] = "Util Dark Blue",
[76] = "Util Midnight Blue",
[77] = "Util Blue",
[78] = "Util Sea Foam Blue",
[79] = "Util Lightning blue",
[80] = "Util Maui Blue Poly",
[81] = "Util Bright Blue",
[82] = "Matte Dark Blue",
[83] = "Matte Blue",
[84] = "Matte Midnight Blue",
[85] = "Worn Dark blue",
[86] = "Worn Blue",
[87] = "Worn Light blue",
[88] = "Metallic Taxi Yellow",
[89] = "Metallic Race Yellow",
[90] = "Metallic Bronze",
[91] = "Metallic Yellow Bird",
[92] = "Metallic Lime",
[93] = "Metallic Champagne",
[94] = "Metallic Pueblo Beige",
[95] = "Metallic Dark Ivory",
[96] = "Metallic Choco Brown",
[97] = "Metallic Golden Brown",
[98] = "Metallic Light Brown",
[99] = "Metallic Straw Beige",
[100] = "Metallic Moss Brown",
[101] = "Metallic Biston Brown",
[102] = "Metallic Beechwood",
[103] = "Metallic Dark Beechwood",
[104] = "Metallic Choco Orange",
[105] = "Metallic Beach Sand",
[106] = "Metallic Sun Bleeched Sand",
[107] = "Metallic Cream",
[108] = "Util Brown",
[109] = "Util Medium Brown",
[110] = "Util Light Brown",
[111] = "Metallic White",
[112] = "Metallic Frost White",
[113] = "Worn Honey Beige",
[114] = "Worn Brown",
[115] = "Worn Dark Brown",
[116] = "Worn straw beige",
[117] = "Brushed Steel",
[118] = "Brushed Black steel",
[119] = "Brushed Aluminium",
[120] = "Chrome",
[121] = "Worn Off White",
[122] = "Util Off White",
[123] = "Worn Orange",
[124] = "Worn Light Orange",
[125] = "Metallic Securicor Green",
[126] = "Worn Taxi Yellow",
[127] = "police car blue",
[128] = "Matte Green",
[129] = "Matte Brown",
[130] = "Worn Orange",
[131] = "Matte White",
[132] = "Worn White",
[133] = "Worn Olive Army Green",
[134] = "Pure White",
[135] = "Hot Pink",
[136] = "Salmon Pink",
[137] = "Pfister Pink",
[138] = "Bright Orange",
[139] = "Red",
[140] = "Dark Red",
[141] = "Midnight Blue",
[142] = "Midnight Purple",
[143] = "Wine Red",
[144] = "Matte Black",
[145] = "Matte Gray",
[146] = "Light Gray",
[147] = "Util Black",
[148] = "Util Silver",
[149] = "Util Gun Metal",
[150] = "Util Shadow Silver",
[151] = "Worn Black",
[152] = "Worn Graphite",
[153] = "Worn Silver Grey",
[154] = "Worn Silver",
[155] = "Worn Blue Silver",
[156] = "Worn Shadow Silver",
[157] = "Metallic Red"

    -- Add more colors as needed
}

function GetVehicleColorName(vehicle)
    local primaryColor, _ = GetVehicleColours(vehicle)
    return colorNames[primaryColor] or "Unknown"
end
