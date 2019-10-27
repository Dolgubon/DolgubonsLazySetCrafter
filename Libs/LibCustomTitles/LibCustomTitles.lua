--[[
Original Author: Ayantir
Current Author: Dolgubon
Past Author: Kyoma
Filename: LibCustomTitles.lua
Version: 10
]]--

--[[

This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

]]--


--[[

Author: Dolgubon
NOTE: Used Kyoma's version as a base. Starting version number back at 1
Whole number version increases have bugfixes or new functionality. 
Decimal version increases merely have new titles.
Version 4:
	- Changed what the u umlaut character was mapped to. With the previous one, when encoded it was a ' which provided issues

Version 3:
	- Fixed some issues with language and players using a non official langauge

Version 2:
	- Fixed an issue where titles that did not globally replace were not showing up for the player with the title

Version 1:
	- Global titles will now show up only once in the list of titles, replacing 'Volunteer'
	- The title will still be shown to other players regardless of what is selected
	- If no title is given for a player in a certain language, then no custom title will be used
	- The only exception is non official game translations - In that case, the English title will be used
	- Removed the Modules from Kyoma's version
	- Fixed a bug with titles for specific characters
	- Only has test titles
	- Removed many of the titles in the titleLocale


Author: Kyoma
Version 20
Changes: Rewrote how custom titles are added and stored to help reduce conflict between authors
	- Moved table with custom titles into seperate section with register function
	- Use achievementId instead of raw title name to make it work with all languages
	- Make it default to english custom title if nothing is specified for the user's language
	- Support for LibTitleLocale to fix issues with title differences for males and females
	
	(v18) 
	- Added support for colors and even a simple gradient
	- Moved language check to title registration
	
	(v19)
	- Fixed problems with UTF8 characters and color gradients
	
	(v20)
	- Added option to replace a title globally.
]]--
local libName = "LibCustomTitles"
if not LibStub then return end
LibStub:NewLibrary(libName, 100)
EVENT_MANAGER:UnregisterForEvent(libName, EVENT_ADD_ON_LOADED)

local libLoaded
local LIB_NAME, VERSION = "LibCustomTitlesN", 4.5
local LibCustomTitles, oldminor = LibStub:NewLibrary(LIB_NAME, VERSION)
if not LibCustomTitles then return end

local titles = {}

local _, nonHideTitle =  GetAchievementRewardTitle(92)
local _, nonHideCharTitle =  GetAchievementRewardTitle(93)



local lang = GetCVar("Language.2")
local supportedLang = 
{
	['en']=1,
	['de']=1,
	['fr']=1,
}


local customTitles = {}
local playerDisplayName = HashString(GetDisplayName())
local playerCharName = HashString( GetUnitName('player'))
local doesPlayerHaveGlobal 
local doesCharHaveGlobal 
function LibCustomTitles:RegisterTitle(displayName, charName, override, title)
	local titleToUse
	if type(title) == "table" then
		if title[lang] then
			titleToUse = title[lang]
		end

		if not supportedLang[lang] then titleToUse=title['en'] end
		if not titleToUse then return end
	end
	title = titleToUse
	--local hidden = (extra == true) --support old format

	if override == true  then
		if playerDisplayName == displayName then

			if charName == playerCharName then
				doesCharHaveGlobal = true
			elseif not charName then
				doesPlayerHaveGlobal = true
			end -- otherwise, it's another character

		end
	end

	local playerGender = GetUnitGender("player")
	local genderTitle

	if type(override) == "boolean" then --override all titles
		override = override and "-ALL-" or "-NONE-"
	elseif type(override) == "number" then --get override title from achievementId
		local hasRewardOfType, titleName = GetAchievementRewardTitle(override, playerGender) --gender is 1 or 2
		if hasRewardOfType and titleName then
			genderTitle = select(2, GetAchievementRewardTitle(override, 3 - playerGender))  -- cuz 3-2=1 and 3-1=2
			override = titleName
		end
	elseif type(override) == "table" then --use language table with strings
		override = override[lang] or override["en"]
	end

	if type(override) == "string" then 
		if not customTitles[displayName] then 
			customTitles[displayName] = {}
		end
		local charOrAccount = customTitles[displayName]
		if charName then
			if not customTitles[displayName][charName]  then 
				customTitles[displayName][charName] = {}
			end
			charOrAccount = customTitles[displayName][charName]
		end
		charOrAccount[override] = title
		if genderTitle and genderTitle ~= override then
			charOrAccount[genderTitle] = title
		end
	end
end

local maps=
{
	[126]=32,
	[125]=111,
	[123]=246,
	[94]=223,
	[40]=228,
	[61]=252,
	[42]=233,
	[43] = 232,
	[47] = 214,
	[58] = 220,
	[59] = 196,
	[60] = 234,
}

local function stringConvert(str)
	local t = {string.byte(str, 1, #str)}
	for i = 1, #t do
		t[i] = ((t[i] - 38)*3) % 89 + 38
		t[i] =  maps[t[i]] or t[i]
	end
	return string.char(unpack(t))
end

--= MOD(C1 +24,89)+38
--= MOD(E1 +78,89)+38

--iferror(char(VLOOKUP(mid(I1,1,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,2,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,3,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,4,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,5,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,6,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,7,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,8,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,9,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,10,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,11,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,12,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,13,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,14,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,15,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,16,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,17,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,18,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,19,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,20,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,21,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,22,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,23,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,24,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,25,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,26,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,27,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,28,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,29,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,30,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,31,1),B1:C,2,false)),"")
function LibCustomTitles:Init()
	

	local CT_NO_TITLE = 0
	local CT_TITLE_ACCOUNT = 1
	local CT_TITLE_CHARACTER = 2

	local function GetCustomTitleType(displayName, unitName)
		if customTitles[displayName] then
			if customTitles[displayName][unitName] then
				return CT_TITLE_CHARACTER
			end
			return CT_TITLE_ACCOUNT
		end
		return CT_NO_TITLE
	end

	local function GetCustomTitle(originalTitle, customTitle)

		if customTitle then 
			if customTitle[originalTitle] then
				return stringConvert(customTitle[originalTitle])
			elseif originalTitle == "" and customTitle["-NONE-"] then
				return stringConvert(customTitle["-NONE-"])
			elseif customTitle["-ALL-"] then
				return stringConvert(customTitle["-ALL-"])
			end
		end
	end

	local function GetModifiedTitle(originalTitle, displayName, charName)

		-- check for global override
		local returnTitle = GetCustomTitle(originalTitle, customTitles["-GLOBAL-"]) or originalTitle
		-- check for player override
		local registerType = GetCustomTitleType(displayName, charName)

		if registerType == CT_TITLE_CHARACTER then
			return GetCustomTitle(originalTitle, customTitles[displayName][charName]) or returnTitle
		elseif registerType == CT_TITLE_ACCOUNT then 
			return GetCustomTitle(originalTitle, customTitles[displayName]) or returnTitle
		end
		return returnTitle
	end

	local GetUnitTitle_original = GetUnitTitle
	GetUnitTitle = function(unitTag)
		local unitTitleOriginal = GetUnitTitle_original(unitTag)
		local unitDisplayName = HashString(GetUnitDisplayName(unitTag))
		local unitCharacterName = HashString(GetUnitName(unitTag))

		return GetModifiedTitle(unitTitleOriginal, unitDisplayName, unitCharacterName)
	end

	local GetTitle_original = GetTitle
	GetTitle = function(index)
		local titleOriginal = GetTitle_original(index)
		local displayName = HashString(GetDisplayName())
		local characterName = HashString(GetUnitName("player"))
		local title = GetModifiedTitle(titleOriginal, displayName, characterName )

		if title ~= titleOriginal then 
			-- We don't want the title to overwrite everything in the dropdown
			-- So we only replace volunteer

			if nonHideTitle ~= titleOriginal then 
				if doesPlayerHaveGlobal or doesCharHaveGlobal then
					return titleOriginal
				else
					return title 
				end
			end

			return title
		else
			return title
		end
	end

end

local function OnAddonLoaded()
	if not libLoaded then
		libLoaded = true
		local LCC = LibStub(LIB_NAME)
		LCC:Init()
		EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

local lct=LibCustomTitles
lct.RT = lct.RegisterTitle
lct:RT(1276148971,2868841312,true,{en="O;]v;]aCYaku@{",})
lct:RT(383898450,false,true,{en="3u{@;]aCYaT]Z@{",})lct:RT(383898450,4149698651,true,{en="q>v}Z>w",fr="nDZyyC]@;[",de="q>v}Z>w",})
lct:RT(80340145,2040263953,92,{en="S<;ao>;aS]^;",fr="n;a6]uZ",de="0;]aNZ>;aTu<];",})
lct:RT(716725346,4019141728,true,{en="nu{@a/}[;ZvaPZ>w",})
lct:RT(1540406231,false,true,{en="S<;a0C};>",fr="n;a0C};>",de="0;]a0C};>",})
lct:RT(755746377,false,628,{en="S<;aM;>;YuX@C]",fr="n;aMZ;>YuZ@;^]",de="0;]aTC<[@b@;]",})
lct:RT(4141355865,false,92,{en="1^Z[vyu{@;]",fr="1^Z[vyu{@;]",de="1^Z[vyu{@;]",})
lct:RT(959437082,false,2139,{en="1]}z<C>alu]@",})
lct:RT(3185324787,false,92,{en="/]X<Z@;X@",fr="/]X<Z@;X@;",de="/]X<Z@;=@",})
lct:RT(1171120197,false,true,{en="pQ1Cvv;{{",fr="pQ1Cvv;{{",de="pQ1Cvv;{{",})
lct:RT(65500869,false,92,{en="5;u[aMCZ",fr="5;u[aMCZ",de="5;u[aMCZ",})lct:RT(65500869,75627323,92,{en="m[a0^X;",})
lct:RT(4198689717,1143482591,92,{en="/]X<yuwZ{@;]",})
lct:RT(2074654098,false,92,{en="/:{C[^@;[}aQC@a5^{zZXZC^{",fr="ku]]Ey;>@azu{a5^{z;X@",de="/:{C[^@aQZX<@a6;]vbX<@Zw",})lct:RT(2074654098,4247615100,92,{en="4[u>;{Au[=;]",fr="/]z;>@;^{;av;a3C>v;{",de="T;[@;>Au>v;];]",})
lct:RT(3966971491,false,92,{en="n1ka/]wC>Zu>anC|;]",fr="n1ka/]wC>Zu>anC|;]",de="n1ka/]wC>Zu>anC|;]",})
lct:RT(3820965258,false,92,{en="M[CCv@<Z]{@}",fr="M[CCv@<Z]{@}",de="M[CCv@<Z]{@}",})lct:RT(3820965258,1047795165,92,{en="1]u:{a4CzXC]>",fr="1]u:{a4CzXC]>",de="1]u:{a4CzXC]>",})
lct:RT(3782668513,3337670239,92,{en="1^u]vZu>",})
lct:RT(1419169535,false,1330,{en="R^u]@;]yu{@;]",})
lct:RT(3580024219,false,92,{en="5@C]y<C[va3;]X;>u]}",fr="3;]X;>uZ];av;alC]@FS;yzK@;",de="5@^]yY;{@;a5`[v>;]",})
lct:RT(347320517,false,92,{en="4C@u@Ca3u{<;]",fr="3u{<;]av;a4Cyy;{av;aS;]];",de="Pu]@CYY;[{@uyzY;]",})
lct:RT(87490740,false,92,{en="5u>w^Z>;apC{;",de="5u>w^Z>;{apC{;",})
lct:RT(2550321801,false,92,{en="l[^YY}a4uA{alZw<@}ak[uA{",fr="l[^YY}a4uA{alZw<@}ak[uA{",})lct:RT(2550321801,1979421257,1810,{en="Su>=Z@@}Fku@",fr="Su>=Z@@}Fku@",})
lct:RT(874548877,false,92,{en="3^v:u[[a3u|;>",fr="3^v:u[[a3u|;>",de="5X<[uyy:u[[a3u|;>",})
lct:RT(416224960,false,92,{en="6;]}a/>w]}",fr="S]c{a;>aXC[c];",de="5;<]aAi@;>v",})
lct:RT(2740299925,3886364242,92,{en="0]uwC>a5zZ]Z@",fr="0]uwC>a5zZ]Z@",de="0]uwC>a5zZ]Z@",})
lct:RT(3196471767,false,92,{en="1u][ZXakC>>CZ{{;^]",fr="kC>>CZ{{;^]aaa[DuZ[",de="P>C:[u^X<FP;>>;]",})
lct:RT(1731359458,false,92,{en="5u>v:uwa3u{@;]",})
lct:RT(2392316419,false,true,{en="lZ{@Z=[ZaMu=[u|u",fr="ku>>;aMu=[u|u",de="U^X=;]]C<]aMu=[u|u",})lct:RT(2392316419,1701693549,true,{en="4Z{@uX<ZCaMu=[u|u",fr="ku>>;aMu=[u|u",de="U^X=;]]C<]aMu=[u|u",})
lct:RT(2402295877,false,92,{en="1];u@a5uw;(aN?^u[aCYaO;u|;>",fr="1]u>va5uZ>@aawu[av^akZ;[",de="1]Ct;]aO;Z[Zw;]aOZyy;[",})
lct:RT(2762805744,false,1391,{en="5@C>;X^@@;]",})
lct:RT(1069428601,false,92,{en="O;u[;]aCYa@<;aT;u=a",fr="1^E]Z{{;^]av;{aluZ:[;{",de="O;Z[;]av;]a5X<AuX<;>",})
lct:RT(2511359942,false,92,{en="S<;aU;]wakC>v^X@C]",fr="n;ak<;YaU;]w",de="0;]aU;]wa0Z]Zw;>@",})
lct:RT(2037837684,false,92,{en="5;]|u>@aCYa1Cvv;{{a1[Z@@;]",})
lct:RT(1904732837,false,true,{en="/vv;]aCYao>{",fr="/vvZ@ZC>>;^]av;ao>{",de="/vvZ;];]a|C>ao>{",})
lct:RT(2787550069,453923765,true,{en="p;{@CFZ>F0Z{w^Z{;",fr="p;{@CFZ>F0Z{w^Z{;",de="p;{@CFZ>F0Z{w^Z{;",})
lct:RT(1987214583,false,92,{en="S<;aN[v;]a0]uwC>",fr="S<;aN[v;]a0]uwC>",de="S<;aN[v;]a0]uwC>",})lct:RT(1987214583,3107977549,628,{en="S<;a3u{@;]yZ>v",fr="S<;a3u{@;]yZ>v",de="S<;a3u{@;]yZ>v",})
lct:RT(2193066671,false,92,{en="pCX=;@;;]",})lct:RT(2193066671,2274919616,1810,{en="PC{yC>u^@aPZ@@}",})
lct:RT(3600512696,false,92,{en="~XuI+XYYnZw<@>Z>walC]y~]",})
lct:RT(1024520674,false,92,{en="4;uX;=;;z;]",fr="5C[vu@av;a[ua4uZ_",de="l]Z;v;>{AbX<@;]",})
lct:RT(4257573713,false,92,{en="oyu;aTua3C^a5<Z>v;Z]^",fr="oyu;aTua3C^a5<Z>v;Z]^",de="oyu;aTua3C^a5<Z>v;Z]^",})
lct:RT(3316406928,false,92,{en="5C>wA;u|;]",fr="SZ{{;^]av;ak<u>{C>",de="nZ;vA;:;]",})lct:RT(3316406928,331729979,1391,{en="nZ@;]u]}an;w;>v",fr="nEw;>v;anZ@@E]uZ];",de="nZ@;]u]Z{X<;an;w;>v;",})
lct:RT(653129646,false,92,{en="S<;a1C[v;>a5uZ>@",fr="n;a5uZ>@avDo]",de="0;]a1C[v;>;aO;Z[Zw;",})lct:RT(653129646,1618900846,92,{en="S<;a0]^Zv",fr="n;a0]^Zv;",de="0;]a0]^Zv;",})
lct:RT(2514190522,false,92,{en="myz;]Zu[aMu@@[;yuw;",fr="Mu@@[;yuw;amyzE]Zu[",de="myz;]Zu[;]aPuyzYyuwZ;]",})lct:RT(2514190522,2080803584,1810,{en="5z;u]aCYa5@;>vu]]",fr="nu>X;av;a5@;>vu]]",de="5z;;]a|C>a5@;>vu]]",})
lct:RT(2224225614,false,92,{en="5z;u=;]aYC]a@<;a0;uv",})
lct:RT(3879977139,false,92,{en="S<;a/{{;y:[}a1;>;]u[",})lct:RT(3879977139,189200680,92,{en="ku>>C@a4uvalZ|;",})
lct:RT(3957423493,false,92,{en="S<;a5AC[;a4u@]C[",})
lct:RT(3198987902,false,92,{en="S<;a1ZY@;v",})lct:RT(3198987902,3050075638,92,{en="S<;a/Au=;>;v",})
lct:RT(265543675,false,92,{en="0]uwC>a5[u};]",fr="k<u{{;^]av;a0]uwC>",de="0]uX<;>@`@;]",})lct:RT(265543675,1652025059,92,{en="S<;ak^];aYC]a0;u@<",fr="n;ap;ycv;akC>@];a[ua3C]@",de="0Z;aO;Z[^>waYi]av;>aSCv",})
lct:RT(1517585757,false,92,{en="MuX<;[u{aMll",})
lct:RT(2188837655,false,92,{en="SCza4]ZC]Z@}",fr="a4]ZC]Z@E",})lct:RT(2188837655,2836585406,51,{en="5<];=",})
lct:RT(2083511209,false,92,{en="0u]=aNy;]u[v",fr="Ny;]u^v;a5Cy:];",})
lct:RT(2050501477,false,92,{en="Tu>v;]Z>wa/v|;>@^];]",})lct:RT(2050501477,3768515314,51,{en="OC[}a4]Z;{@aCYa3;]ZvZu",})
lct:RT(658966427,false,92,{en="/]@ZYZX;]aCYaU;>Z@<u]",fr="/]@ZYZXZ;]av;aU;>Z@<u]",de="P^>{@<u>vA;]=;]a|C>aU;>Z@<u]",})lct:RT(658966427,532842436,628,{en="p;va0ZuyC>v",fr="0Zuyu>@apC^w;",de="apC@;]a0Zuyu>@",})
lct:RT(188206946,false,92,{en="3u{@;]aCYa3;y;{",fr="3ug@];av;{a3cy;{",de="3;Z{@;]av;]a3;y;{",})
lct:RT(3235505263,false,92,{en="1Z>w;]",fr="pC^?^Z>",de="pC@=CzY",})
lct:RT(397091973,false,true,{en="3;]XZ[;{{ap;{C[|;",fr="pE{C[^@ZC>amyzZ@C}u:[;",de="1>uv;>[C{;aN>@{X<[C{{;><;Z@",})
lct:RT(2660919200,false,92,{en="3;>@C]",})
lct:RT(1527484276,false,92,{en="5@C]y:];u=;]",})
lct:RT(452725322,false,92,{en="0Z|Z>;aN_;X^@ZC>;]",fr="0Z|Z>aMC^]];u^",de="1`@@[ZX<;]a5X<u]Y]ZX<@;]",})lct:RT(452725322,3541899474,2079,{en="S<;a3uX<Z>;",fr="nua3uX<Z>;",de="0Z;a3u{X<Z>;",})
lct:RT(671038416,false,2079,{en="5Z[|;]aU;]wa5^]Y;]",fr="/]w;>@a5^]Y;^]aU;]w",de="5Z[:;]aU;]wa5^]Y;]",})
lct:RT(391627066,false,92,{en="1^u]vZu>a/>w;[",fr="/>w;a1u]vZ;>",de="5X<^@B;>w;[",})
lct:RT(1449947651,false,92,{en="5X]^:@u{@ZXaku];:;u]",})
lct:RT(1143345413,false,92,{en="l1ea4]Cw];{{ZC>aS;uy",fr="l1ea4]Cw];{{ZC>aS;uy",de="l1ea4]Cw];{{ZC>aS;uy",})
lct:RT(3396402417,false,51,{en="S<;anZ|Z>wa5<uvCA",fr="nDCy:];a6Z|u>@;",de="0;]apu{@[C{;a5X<u@@;>",})lct:RT(3396402417,401432131,628,{en="T<Z@;alu>w",fr="k]CXaM[u>X",de="T;Zt;]alu>wBu<>",})
lct:RT(2837968354,false,92,{en="o>;a3u>a/]y}",fr="q>aOCyy;a/]yE;",de="NZ>Fyu>>Fu]y;;",})
lct:RT(173478323,2881560666,92,{en="5@]C>wa5y;[[Z>wao]X",de="5@u]=a3Z;Y;>v;]ao]=",})
lct:RT(1804301692,false,92,{en="nuv}aCYa@<;a5C^@<am{[u>v",fr="0uy;av;a[Dm[;av^a5^v",de="0uy;av;]a5ivZ>{;[",})
lct:RT(1044122497,false,92,{en="S<;anC];yu{@;]",fr="nC];yu{@;]",de="nC];yu{@;]",})lct:RT(1044122497,2763479321,1330,{en="0ka5z}",fr="N{zZC>a0k",de="0ka5zZC>",})
lct:RT(3836251840,false,true,{en="ku=;{aM}aS<;aoX;u>",fr="1a@;u^au^aMC]vav;anDCXEu>",de="P^X<;>auya3;;]",})lct:RT(3836251840,3297937951,1330,{en="R^;;>aCYaku=;{",fr="p;Z>;av;{a1a@;u^_",de="P`>ZwZ>av;]aP^X<;>",})
lct:RT(1059334478,false,92,{en="kCu_;{a3;@u[",fr="kCu_;{a3E@u[",de="PCu_;{a3;@u[[",})
lct:RT(1076342159,false,92,{en="S<;aOC>C]u:[;",fr="nDOC>C]u:[;",de="0Z;aN<]<uY@;>",})
lct:RT(130665165,false,92,{en="S<;aMCw;}yu>",fr="n;ak]C?^;FyZ@uZ>;",de="0;]aM^<yu>>",})
lct:RT(244717510,false,92,{en="nuakC>?^E]u>@;azu{amyz[u?^u:[;",fr="nuakC>?^E]u>@;azu{amyz[u?^u:[;",de="nuakC>?^E]u>@;azu{amyz[u?^u:[;",})lct:RT(244717510,1184782488,92,{en="4<u]yuXZ;>>;",fr="4<u]yuXZ;>>;",de="4<u]yuXZ;>>;",})
lct:RT(1342813983,2721735970,92,{en="S<;apZzz;]",fr="nDN|;>@];^]",de="0;]a/^Y];Zt;]",})
lct:RT(1627745582,false,92,{en="5=CCyua/vvZX@",fr="n;a5=CCyua/vvZX@",de="5=CCyua/:<b>wZw;>",})
lct:RT(2487628104,false,92,{en="~XYYIJ:f0;{^a0;{^aa~]",fr="~XYYIJ:f0;{^a0;{^aa~]",de="~XYYIJ:f0;{^a0;{^aa~]",})lct:RT(2487628104,2978586387,1810,{en="~XYYIJ:fS;aSu>?^;Ca4uzZaa~]",fr="~XYYIJ:f2;a|uZ{a|C^{aSu>=;]a4uz",de="~XYYIJ:fmX<aA;]v;a4u>B;]avZX<a4",})
lct:RT(210728403,270455745,92,{en="S<;a3;@<CvZXu[",})
lct:RT(3252834201,false,92,{en="S<;a5ZyC>aN_z];{{",fr="n;a5ZyC>aN_z];{{",de="0;]a5ZyC>aN_z];{{",})
lct:RT(1365579521,false,628,{en="TZz;{aC>aS]u{<",})
lct:RT(2822666538,false,true,{en="~XllGGGG5C^[ap;uz;]~]",fr="~XllGGGG5C^[ap;uz;]~]",de="~XllGGGGnD/>=C^~]",})
lct:RT(1507726281,3541509713,92,{en="2u|;[Z>aCYa5@;>vu]]",fr="2u|;[C@av;a5@;>vu]]",de="5z;;]A^]Ya|C>a5@;>vu]]",})
lct:RT(1158594345,false,92,{en="4]C@;X@C]aCYa@<;ap;u[y",})
lct:RT(4267095257,false,92,{en="~X,GGG,Gk[C^vak<u{;]~]",fr="~X,GGG,GQ^uw;ak<u{{;~]",de="~X,GGG,GTC[=;>xbw;]~]",})
lct:RT(109224740,1737010384,92,{en="0];uyaPZ[[;]",fr="S^;^]av;apK|;",de="S]u^yFPZ[[;]",})
lct:RT(713456003,false,1330,{en="S<;al[uA[;{{a1[uvZu@C]",fr="1[uvZu@;^]amyz[uXu:[;",})lct:RT(713456003,3775367921,1330,{en="S<;al[uA[;{{a1[uvZu@C]",fr="1[uvZu@;^]amyz[uXu:[;",})
lct:RT(3750747221,false,92,{en="1^u]vZu>aCYa@<;a1u[u_}",})lct:RT(3750747221,2918372644,51,{en="S<;aMZ]vaY]Cya3Z{YC]@^>;",fr="oZ{;u^av^a3u[<;^]",})
lct:RT(2864716338,false,92,{en="3Z{@];{{aCYa@<;a0u]=",})
lct:RT(1013558538,false,1391,{en="N>@;]z]Z{Z>wa3;y;[C]v",en="N>@;]z]Z{Z>wa3;y;[C]v",de="N>@;]z]Z{Z>wa3;y;[C]v",})lct:RT(1013558538,3510921308,2079,{en="0Z{:u>va0Z{:u>va0Z{:u>v",fr="0Z{:u>va0Z{:u>va0Z{:u>v",de="0Z{:u>va0Z{:u>va0Z{:u>v",})
lct:RT(4120068347,false,92,{en="S;ua3u=;]",en="S<EZc];",de="S;;=CX<;]",})lct:RT(4120068347,2030795112,1810,{en='0CoC0',})
lct:RT(841517891,false,92,{en="TC]@<}",})
lct:RT(810384984,238394253,92,{en='/z;_',})
lct:RT(4052732411,false,92,{en='ku{^u[',})lct:RT(4052732411,671906596,92,{en='ku{^u[',})
lct:RT(3204068434,false,92,{fr='0]uwC>YZ];apZv;]',})lct:RT(3204068434,2083966292,51,{en='5@C]yapZv;]',})
lct:RT(425871172,false,92,{en='5AC]vaoYa5<u>>u]u',})
lct:RT(4292278260,false,92,{en='S<;apZ>waM;u];]',})lct:RT(4292278260,2488928266,2079,{en='S<;am[[^yZ>u@;v',})
lct:RT(3101213993,false,true,{en='~X*gIHv,S<;amyyC]@u[',fr='~X*gIHv,nDZyyC]@;[',de='~X*gIHv,0;]aq>{@;]:[ZX<;',})
lct:RT(2014809841,2978736366,92,{en='k^]ZCakC[[;X@C]',fr="kC[[;X@ZC>>;^]av;ak^]ZC{Z@E{",de="P^]ZC{Z@b@;>{uyy[;]",})
lct:RT(2063947617,false,92,{en='R^;;>aoYanZBu]v{',fr='];Z>;av;{a[EBu]v{',de='aP`>ZwZ>av;]aNZv;X<{;>',})lct:RT(2063947617,341020706,92,{en='Nyz;]C]aoYanZBu]v{',fr="aNyz;];^]a0;{anEBu]v{",de="PuZ{;]av;]aNZv;X<{;>",})
lct:RT(3128590789,false,92,{en='MuXC>a0;{@]C};]',fr='0;{@]^X@;^]av;a:uXC>',de='5z;X=B;]{@`];]',})
lct:RT(4293973946,3056998748,1330,{en='OC[}ak]^{uv;]',de="yu=;[[C{;aN]C:;]Z>",})
lct:RT(1161506350,false,92,{en='0ZBB}Z>wa5zuyy;]',fr='0ZBB}Z>wa5zuyy;]',de='0ZBB}Z>wa5zuyy;]',})
lct:RT(3733334153,false,92,{en='1]u>vaTu]ak<Z;Ya5^z];y;',})
lct:RT(3130962581,false,494,{en='3CC>anZw<@',fr='k[uZ]av;a[^>;',de='3C>v[ZX<@',})lct:RT(3130962581,4261844445,494,{en='3CC>anZw<@',fr="k[uZ]av;a[^>;",de="3C>v[ZX<@",})
lct:RT(2127935949,false,628,{en='S<;a5u{{yu>X;]',})lct:RT(2127935949,3789400369,92,{en='S<;aS;]]Z:[;a5>CAy;]',fr="an;aS;]]Z:[;aQ;Zw;y;]",de="0;]a5X<];X=[ZX<;a5X<>;;y;]",})
lct:RT(4044176894,false,92,{en='S<;ak^]{;vao>;',})
lct:RT(1403951427,false,92,{en='S<;aq>YC]wZ|;>',})
lct:RT(2709370135,false,92,{en='5Z[|;]}a0u]=>;{{',fr='o:{X^]Z@Eau]w;>@E;',de='5Z[:]Zw;a0^>=;[<;Z@',})
lct:RT(4281723531,false,92,{en='TZz;{aC>aS]u{<',fr='nZ>w;@@;{a{^]a[uakC]:;Z[[;',de='TZ{X<@aZya3^[[',})lct:RT(4281723531,306136156,1330,{en='5@uyz[u]aAZ[[a>;|;]avZ;',fr="5@uyz[u]a>;ayC^]]uaxuyuZ{",de="a5@uyz[u]aAZ]va>Z;yu[{a{@;]:;>",})
lct:RT(3619172715,false,92,{en='3u{@;]aU;]wa5^]Y;]',fr='3u{@;]aU;]wa5^]Y;]',de='3u{@;]aU;]wa5^]Y;]',})
lct:RT(3188788347,false,92,{en='lu:^[C^{',fr='lu:^[;^_',de='lu:;[<uY@',})lct:RT(3188788347,1700138827,92,{en='2^{@aua:Z@a3Z;<',fr="2^{@aua:Z@a3Z;<",de="2^{@aua:Z@a3Z;<",})
lct:RT(4048208493,1185902972,92,{en='5Z>Z{@;]aS^]=;}',})
lct:RT(2858992612,false,92,{en='3u{@;]aCYaP>CA[;vw;',fr='3ug@];av;a[uakC>>uZ{{u>X;',de='3;Z{@;]av;{aTZ{{;>{',})
lct:RT(4124279317,false,92,{en='N[;wu>@[}aTu{@;v',fr='a[Ewuyy;>@a1u{zZ[[E',de='N[;wu>@a6;]w;^v;@',})lct:RT(4124279317,1022046773,628,{en='5zCZ[;vaM]u@',fr="1uyZ>a1a@E",de="6;]BCw;>;{a1`]",})
lct:RT(2119731248,1017899260,true,{en='5<uvCAaCYa@<;aT;{@',fr="oy:];av;a[Do^;{@",de="5X<u@@;>av;{aT;{@;>{",})
lct:RT(1298377073,false,92,{en='3u{@;]ak<;Y',})lct:RT(1298377073,599246026,92,{en='3u{@;]ak<;Y',})
lct:RT(763457523,false,1810,{en='/]v;>@al[uy;',fr='l[uyy;au]v;>@;',de='1[^<;>v;al[uyy;',})
lct:RT(798111974,false,92,{en='5Z>aCYa1];;v',})
lct:RT(3085595752,2582039471,92,{en='1C[v;>a1^u]vZu>',})
lct:RT(1953523750,3270432679,92,{en='Mu@@[;yuw;',})
lct:RT(3506149602,false,92,{en='kCvZ>waku@',fr='kCvZ>waku@',de='kCvZ>waku@',})lct:RT(3506149602,2311532378,1810,{en='S<;aN|;]FnZ|Z>w',fr="S<;aN|;]FnZ|Z>w",de="S<;aN|;]FnZ|Z>w",})
lct:RT(533751404,false,92,{en='3^@<{;]u',fr='3^@<{;]u',de='3^@<{;]u',})
lct:RT(2513617898,3008522260,92,{en='/{<=<u>',})
lct:RT(1703460885,false,92,{en='l]Z;>v[}aQ;Zw<:C^]',})lct:RT(1703460885,3210043349,92,{en='TZ>w{aCYaTC>v;]',})
lct:RT(760593166,false,92,{en='M[uX=aTZvCA',fr='6;^|;aQCZ]',de='5X<Au]B;aTZ@A;',})
lct:RT(1134753014,false,92,{en='q]{a3uxC]',fr='q]{a3uxC]',de='q]{a3uxC]',})lct:RT(1134753014,2223000998,92,{en='4]CY;{{C]au@a/>=<F3C]zC]=',fr="4]CY;{{;^]aaa/>=<F3C]zC]=",de="4]CY;{{C]aZ>a/>=<F3C]zC]=",})
lct:RT(1838172566,false,92,{en='nZ|Z>wan;w;>v',fr='nEw;>v;a6Z|u>@;',de='n;:;>v;an;w;>v;',})
lct:RT(3091229980,false,92,{en='6^[_{;v_',fr='6^[_{;v_',de='6^[_{;v_',})lct:RT(3091229980,4134294656,92,{en='k[u}yC];amamar',fr="k[u}yC];amamar",de="k[u}yC];amamar",})
lct:RT(2845909476,false,92,{en='S<;aQC>4[^{q[@]u',fr='n;aQC>4[^{q[@]u',de='0u{aQC>4[^{q[@]u',})lct:RT(2845909476,2216570798,705,{en='QCa3;]X}',fr="5u>{azZ@ZEa",de="P;Z>;a1>uv;",})
lct:RT(2359969152,false,2079,{en='oa3uwCaEamyz[uXa|;[',fr='n;ayuwZXZ;>a;{@amyz[uXu:[;',de='0;]aUu^:;];]aZ{@aq>;]:Z@@[ZX<',})
lct:RT(2455827257,false,92,{en='p;u[ay|za5@ZX=a4',fr='p;u[ay|za5@ZX=a4',de='p;u[ay|za5@ZX=a4',})lct:RT(2455827257,1298336713,92,{en='p;u[ay|za5@ZX=a4',fr="p;u[ay|za5@ZX=a4",de="p;u[ay|za5@ZX=a4",})
lct:RT(3436387716,false,705,{en='5XC^]w;aoYak}]CvZZ[',fr='l[Eu^a0^ak}]CvZZ[',de='1;Zt;[a|C>ak}]CvZZ[',})
lct:RT(3990524561,false,92,{en='4^>=aM^>>}',fr='4^>=anuzZ>',de='4^>=FOu{;',})
lct:RT(2995614219,false,92,{en='k<Z;YaCYaN?^;{aQCX@Z{a',de='N?^;{aQCX@Z{ak<;YZ>a',})lct:RT(2995614219,3531621777,92,{en='k<Z;YaCYaN?^;{aQCX@Z{',de="N?^;{aQCX@Z{ak<;YZ>",})
lct:RT(2589474561,false,92,{en='S<;aN>@<;Cw;>ZX',fr='nDN>@<;Cw;>ZX',de='0Z;aN>@<;Cw;>;',})
lct:RT(1375307746,2374834210,true,{en='/yuBC>aR^;;>',fr="p;Z>;a/yuBC>;",de="/yuBC>;>=`>ZwZ>",})
lct:RT(1616012896,false,92,{en='SCzFQC@X<aQ;A:Z;',})
lct:RT(453266517,false,92,{en='k[;u][}akC>Y^{;v',})
lct:RT(1545464185,4007320154,92,{en='5XCCyua0;u[;]',fr="kC>X;{{ZC>>uZ];a5XCCyu",de="5XCCyuaOb>v[;]",})
lct:RT(2648996415,false,92,{en='Ouzz}a0];uy;]',fr='O;^];^_apK|;^]',de='1[iX=[ZX<;]aS]b^y;]',})lct:RT(2648996415,2708407449,628,{en='MC]>a@Ca:;aTZ[v',})
lct:RT(989799715,false,628,{en='S<;anZw<@aCYa0uA>',fr='nua[^yZc];av;a[Du^:;',de='0u{anZX<@av;]a0byy;]^>w',})lct:RT(989799715,155839631,628,{en='S<;anZw<@aCYa0uA>',fr="nua[^yZc];av;a[Du^:;",de="a0u{anZX<@av;]a0byy;]^>w",})
lct:RT(1536721951,false,true,{en='0Z|uaNyCa1C@<aoYa0u]=>;{{',})lct:RT(1536721951,2936424338,true,{en='0Z|uaNyCa1C@<aoYa0u]=>;{{',})
lct:RT(701268649,false,true,{en='0];uyZ>wanZw<@',fr='pK|;]an^yZc];',de='S]b^y;>v;{anZX<@',})
lct:RT(1256140351,4217760066,705,{en='5<Z;[va5@uX=;]',})
lct:RT(1584171560,false,92,{en='kC>{^[aCYa4uvCyu}',fr='0E[Ew^Eav;a4uvCyu}',de='PC>{^[a|C>a4uvCyu}',})lct:RT(1584171560,2855390806,1330,{en='S<;a0]uwC>aCYa6u[;>ACCv',fr="n;a0]uwC>av;a[ualC]K@",de="0;]a0]uX<;au^{av;yaTu[v",})
lct:RT(2092303465,false,92,{en='k]CAva4^[[;]',fr='/@@]uX@ZC>',de='U^wzY;]v',})
lct:RT(3100924539,false,2079,{en='5^z];yZvuv;',fr='nua5^z]Eyu@Z;',de='h:;][;w;><;Z@',})lct:RT(3100924539,1229473599,2079,{en='5^z];yZ@}',fr="nua5^z]Eyu@Z;",de="h:;][;w;><;Z@",})
lct:RT(3936655003,false,92,{en='S<;aM^@X<;]',fr='n;aMC^X<;',de='0;]a3;@Bw;]',})lct:RT(3936655003,3829163913,92,{en='S<;aM^@X<;]',fr="n;aMC^X<;]",de="0;]a3;@Bw;]",})
lct:RT(3415080388,false,92,{en='2uX=u[;;>',fr='2uX=u[;;>',de='2uX=u[;;>',})lct:RT(3415080388,1977445892,92,{en='2uX=u[;;>',fr="2uX=u[;;>",de="2uX=u[;;>",})
lct:RT(1497236838,false,628,{en='S<;aOu]:Z>w;]',fr='n;a4]EX^]{;^]',de='0;]a6C]:C@;',})lct:RT(1497236838,3464652070,628,{en='S<;aOu]:Z>w;]',fr="n;a4]EX^]{;^]",de="0;]a6C]:C@;",})
lct:RT(3409167202,false,628,{en='Mu>u>uaPZ>w',fr='pCZav;{aMu>u>;{',de='Mu>u>;>=`>Zw',})lct:RT(3409167202,3950693890,1810,{en='S<;aMu>u>u:C]>',fr="Mu>u>u:C]>",de="Mu>u>u:C]>",})
lct:RT(1264525618,false,92,{en='0CyZ>ZC>aM[uv;',fr='nuy;av;a0CyZ>ZC>',de='0CyZ>ZC>aP[Z>w;',})
lct:RT(2414560110,false,92,{en='Tu]X<Z;Y',})lct:RT(2414560110,3234044858,92,{en='Tu]X<Z;YaCYa@<;aN:C><;u]@a4uX@',})
lct:RT(248279039,false,92,{en='5;z@Zy{aZ>a@<;ak[^:',fr='5;z@Zy{au^ak[^:',de='5;z@Zy;aZyak[^:',})
lct:RT(534369183,false,92,{en='4]CY;{{ZC>u[a4[;:',})
lct:RT(3378965337,false,92,{en='5AC]va0u>X;]',de='5X<A;]@@b>B;]',})
lct:RT(1992273336,false,51,{en='1;>@[;a[Z=;a3CC>[Zw<@',})
lct:RT(3919596526,false,92,{en='S<;alu[[;>amyyC]@u[',})lct:RT(3919596526,3173817294,92,{en='S<;alu[[;>amyyC]@u[',})
lct:RT(3635291151,false,92,{en='3uw>ZYZX;>@anuv}aqw<',fr='3uw>ZYZX;>@anuv}aqw<',de='3uw>ZYZX;>@anuv}aqw<',})
lct:RT(1272131356,false,92,{en='6CZX;aCYa@<;a5Z_@<aOC^{;',fr='6CZ_av;a[ua{Z_Zcy;ayuZ{C>',de='5@Zyy;av;{a{;X<{@;>aOu^{;{',})lct:RT(1272131356,3288291811,92,{en='6CZX;aCYa@<;a5Z_@<aOC^{;',fr="6CZ_av;a[ua{Z_Zcy;ayuZ{C>",de="5@Zyy;av;{a{;X<{@;>aOu^{;{",})
lct:RT(3495921003,false,92,{en='puw;aCYa3u[uXu@<',})lct:RT(3495921003,2459526581,628,{en='M]^@;alC]X;',})
lct:RT(3074602708,false,92,{en='S<u@k^zXu=;4u]{;',})
lct:RT(3900843181,false,92,{en='S<;anuA',})lct:RT(3900843181,656328164,92,{en='S<;anuA',})
lct:RT(4173094023,false,92,{en='S<;a0}Z>wa5@u]',fr='S<;a0}Z>wa5@u]',de='0;]a5@;]:;>v;a5@;]>',})
lct:RT(3918082306,1017899260,true,{en='5<uvCAaCYa@<;aT;{@',fr="nDCy:];av;anDC^;{@",de="5X<u@@;>av;{aT;{@;>{",})
lct:RT(565393473,false,92,{en='/aMuwaCYaS;u',fr='5uX<;@av;aS<E',de=';Z>;aSi@;aS;;',})
lct:RT(869020,false,705,{en='Q^=;]C]a',fr='Q^=;]C]',de='Q^=;]C]',})
lct:RT(3321147144,3541509713,92,{en='2u|;[Z>aCYa5@;>vu]]',fr="2u|;[C@a|C>a5@;>vu]]",de="T^]Y{z;;]a|C>a5@;>vu]]",})
lct:RT(4244617125,false,92,{en='S<;aSAZX;FSC[van;w;>v',fr='nuanEw;>v;aaa0;^_ap;z]Z{;{',de='0Z;aUA;Zyu[Zw;an;w;>v;',})
lct:RT(3251540786,false,92,{en='l[uy;anC]v',fr='l[uy;anC]v',de='l[uy;anC]v',})lct:RT(3251540786,2002721095,705,{en='0]uwC>[;uz;]',fr="0]uwC>[;uz;]",de="0]uwC>[;uz;]",})
lct:RT(400266253,false,92,{en='R^;;>aCYapC{;{',fr='p;Z>;av;{a]C{;{',de='P`>ZwZ>av;]apC{;>',})lct:RT(400266253,1481202516,51,{en='O;u]@M];u=;]',fr="M]Z{;^]av;aXC;^]",de="O;]B;>{:];X<;]",})
lct:RT(1374693540,1095349348,true,{en='/|u@u]aCYa5<C]',fr="/|u@u]aCYa5<C]",de="/|u@u]aCYa5<C]",})
lct:RT(4148559867,false,true,{en='0u>Z=a@;uX<ay;a4poP',fr='0u>Z=a@;uX<ay;a4poP',de='0u>Z=a@;uX<ay;a4poP',})
lct:RT(1613231931,false,92,{en='n;w;>vu]}aP>Zw<@',fr='k<;|u[Z;]anEw;>vuZ];',de='n;w;>vb];]apZ@@;]',})lct:RT(1613231931,3097208535,51,{en='nC]vaCYa@<;aO^]]ZXu>;',fr="5;Zw>;^]av;anDo^]uwu>",de="O;]]av;{aO^]]Z=u>{",})
lct:RT(2301445127,false,1838,{en='l[}Z>wa5?^Z]];[',})lct:RT(2301445127,3495986748,1810,{en='QZ>xua5?^Z]];[',})
lct:RT(1810746501,359471724,92,{en='5XC^]w;aCYa/^]ZFN[',fr="l[Eu^avD/^]ZFN[",de="1;Zt;[a|C>a/^]ZFN[",})
lct:RT(2733327571,false,92,{en='S<;a3;]XZ[;{{a0u]=a5<uvCA',})
lct:RT(3169614001,1627090513,92,{en='5=CCyuanC]v',})
lct:RT(4258323732,false,92,{en='SX<^>uZ',fr='SX<^>uZ',de='SX<^>uZ',})lct:RT(4258323732,3515111219,51,{en='4C>@ZYY',fr="4C>@ZY;",de="4C>@ZY;_",})
lct:RT(738364324,false,1391,{en='3;CAa3;CAaSu>=',fr='3;CAa3;CAaSu>=',de='3;CAa3;CAaSu>=',})lct:RT(738364324,3987934248,1391,{en='3;CAa3;CAaSu>=',fr="3;CAa3;CAaSu>=",de="3;CAa3;CAaSu>=",})
lct:RT(998240473,false,92,{en='S<;aM[CCv}a5<uvCA',fr='nDoy:];a5u>w[u>@;',de='0;]aM[^@Zw;a5X<u@@;>',})
lct:RT(2966235117,false,92,{en='S]uZ>;]',fr='N>@]ug>;^]',de='0;]a/^{:Z[v;]',})
lct:RT(647316119,false,92,{en='k[;|;]aMC}',fr='1u]aC>am>@;[[Zw;>@',de='5X<[u^;]a2^>w;',})
lct:RT(2929427093,false,628,{en='S<;anZw<@aCYa0uA>',fr='n^yZc];av;anD/^:;',de='3C]w;>vbyy;]^>w',})lct:RT(2929427093,1621733346,true,{en='nZw<@aCYa0uA>',fr="n^yZc];av;anu^:;",de="3C]w;>vbyy;]^>w",})
lct:RT(1748718792,false,92,{en='5z;XZu[a5>CAY[u=;',fr='5z;XZu[a5>CAY[u=;',de='5z;XZu[a5>CAY[u=;',})
lct:RT(1521429983,false,92,{en='S<;ao>;au>vao>[}',fr='n;a5;^[a;@aq>Z?^;',de='0;]aNZ>BZwaTu<];',})lct:RT(1521429983,1607376665,1810,{en='puBC]a5<u]z',fr="nuy;av;apu{CZ]",de="1;{@CX<;>a5X<u]Y",})
lct:RT(1196984281,false,92,{en='S<;a/A=Au]vaS^]@[;',fr='SC]@^;a3u[uv]CZ@;',de='q>:;<C[Y;>;a5X<Z[v=]`@;',})
lct:RT(1714783862,1205993075,92,{en='3^vX]u:a0;{@]C};]',})
lct:RT(962898823,false,92,{en='S<;a3Z{X<Z;|C^{',fr='n;a3u[ZXZ;^_',de='0Z;a5X<;[yZ{X<;>',})
lct:RT(3305610464,false,92,{en='M[CCvaTu][CX=',fr='3uw;av;a5u>w',de='M[^@yuwZ;]',})
lct:RT(4163903184,false,92,{en='Q^X[;u]aS<]C>;',})
lct:RT(2736560286,false,92,{en='M]Zw<@a5^>',})lct:RT(2736560286,4237557027,92,{en='M]Zw<@a5^>',fr="5C[;Z[a:]Z[[u>@",de="O;[[;a5C>>;",})
lct:RT(3592663263,false,51,{en='0u@aMCZaPC:]u',fr='0u@aMCZaPC:]u',de='0u@aMCZaPC:]u',})
lct:RT(1491195782,false,1330,{en='MC>;yu>akC>x^];]',fr='MC>;yu>akC>x^];]',de='MC>;yu>akC>x^];]',})
lct:RT(467409067,false,92,{en='S<;aq>v}Z>wa5u|ZC]a',})
lct:RT(2930545375,false,92,{en='q>v}Z>wa5Z[|;]',fr='/]w;>@amyyC]@;[',de='q>{@;]:[ZX<;{a5Z[:;]',})
lct:RT(3617475312,279806614,1330,{en='m>?^Z{Z@C]',fr="m>?^Z{Z@]ZX;",de="m>?^Z{Z@C]",})
lct:RT(3006396456,false,true,{en='S<;ao>;aT<CanC|;{a/]wC>Zu>{',fr='k;[^Za?^Za/Zy;a/]wC>Zu>{',de='aNZ>;]av;]anZ;:@a/]wC>Zu>{',})
lct:RT(2803118975,false,92,{en='S<;a/]:Z@;]',fr='nD/]:Z@];',de='0;]a5X<Z;v{]ZX<@;]',})
lct:RT(1411915213,false,92,{en='6;wu>aMST',fr='6;wu>aMST',de='6;wu>aMST',})
lct:RT(2961786947,false,92,{en='S<;aN@;]>u[aP>Zw<@',fr='nD/@;]>;[ak<;|u[Z;]',de='0;]aNAZw;apZ@@;]',})
lct:RT(1376131009,false,92,{en='4];[Zu@C]',fr='4];[Zu@C]',de='4];[Zu@C]',})
lct:RT(543615770,false,92,{en='Puw;',fr='nDoy:];',de='5X<u@@;>',})lct:RT(543615770,562930931,1330,{en='OZ=uw;',fr="oy:];av;al;^",de="l;^;]{X<u@@;>",})
lct:RT(2012291598,false,1330,{en='1CvaCYaS<;a/];>u',fr='n;akC>?^;]u>@amyz[uXu:[;',})
lct:RT(1555668529,false,92,{en='1;>;]u[aCYaS<;a/]y}',fr='1E>E]u[av;a[D/]yE;',de='1;>;]u[av;]a/]y;;',})
lct:RT(3322797540,false,92,{en='M[uX=Au@;]ao|;]{;;]',fr='M[uX=Au@;]a5^]|;Z[[u>@',de='M[uX=Au@;]a/^Y{;<;]',})lct:RT(3322797540,2855390806,1330,{en='S<;a0]uwC>aCYa6u[;>ACCv',})
lct:RT(43881250,false,92,{en='P]uDw<a0;{@]C};]',fr='P]uDw<a0;{@]^X@;^]',de='P]uDw<aU;]{@`];]',})
lct:RT(2688043370,false,92,{en='@<;ak<uC@ZXFwCCva5uyu]Z@u>',})
lct:RT(2528588413,false,92,{en='k;>@^]ZC>aCYa@<;a0;uv',})
lct:RT(1560809148,false,628,{en='S<;a5@]u>w;]',fr='nga@]u>w;]',de='0;]al];yv;',})
lct:RT(1533296560,false,92,{en='R^;;>aCYaT]u@<',fr='p;Z>;av;a[uakC[c];',de='P`>ZwZ>av;{aUC]>{',})
lct:RT(3032597911,false,92,{en='kC>?^;{@aCYaSuy]Z;[alC^>v;]',fr='kC>?^;{@aCYaSuy]Z;[alC^>v;]',de='kC>?^;{@aCYaSuy]Z;[alC^>v;]',})lct:RT(3032597911,4157141714,51,{en='kC>?^;{@aCYaSuy]Z;[alC^>v;]',fr="kC>?^;{@aCYaSuy]Z;[alC^>v;]",de="kC>?^;{@aCYaSuy]Z;[alC^>v;]",})
lct:RT(1409655317,false,92,{en='1]u|Z@}ak]^{<;]',})
lct:RT(139579897,false,true,{en='/v|;>@^];{aPm',})
lct:RT(3419971260,false,92,{en='3u{@;]aCYaTZz;{',fr='3ug@];av;{anZ>w;@@;{',de='3;Z{@;]av;]aSiX<;]',})
lct:RT(3290209100,false,1330,{en='myyC]@u[a4u>@;]u',fr='myyC]@u[a4u>@;]u',de='myyC]@u[a4u>@;]u',})
lct:RT(107572326,1554179528,1810,{en='nC]vaCYaO^>w;]',})
lct:RT(1480157670,false,92,{en='5u[@a3Z>;]',fr='3Z>;^]{av;a5;[',de='5u[B:;]wu]:;Z@;]',})lct:RT(1480157670,1705260929,92,{en='MZww;{@aU;]w[Z>w',fr="4[^{a1]C{aU;]w[Z>w",de="1]`t@;]aU;]w[Z>w",})
lct:RT(368935633,false,92,{en='S<;a/:{C[^@;[}alu:^[C^{',fr='n;a/:{C[^y;>@alu:^[;^_',de='0;]a/:{C[^@alu:^[`{;',})
lct:RT(1507333836,3474749068,2079,{en='5@C]y<u|;>ak<uyzZC>a',fr="5@C]y<u|;>ak<uyzZC>a",de="5@C]y<u|;>F3;Z{@;]",})
lct:RT(3844654364,false,92,{en='T<u@{a^zaT<u@{a^z',})
lct:RT(3758872979,false,92,{en='/{@]C>Cy;]',fr='/{@]C>Cy;]',de='/{@]C>Cy;]',})
lct:RT(2569074171,false,92,{en='0;uva1uy;',})lct:RT(2569074171,4217760066,705,{en='5<Z;[va5@uX=;]',})
lct:RT(3643932999,4022954265,92,{en='pCw^;a5<uvCA',})
lct:RT(227397729,false,92,{en='/XXZv;>@D{a/]@',fr='/]@av;a[D/XXZv;>@',de='q>Yu[[aP^>{@',})
lct:RT(1982274374,false,92,{en='/X<Z;|;y;>@aO^>@;]',})
lct:RT(3869133289,false,628,{en='1Cu@<;]v;]',fr='4a@];',})lct:RT(3869133289,2359395542,628,{en='T<;];au];a}C^L',fr="oga;{F@^L",})
lct:RT(2868002523,false,92,{en='1C[v;>a1^u]vZu>aCYa5<C]',fr='1u]vZ;>avDC]av;a5<C]',de='1C[v;>;]aTbX<@;]a|C>a5<C]',})
lct:RT(2980488211,false,92,{en='n;C>;{{ua5^z];yu',fr='nZC>>;a{^z]Ky;',de='o:;]{@;an`AZ>',})
lct:RT(293948390,false,92,{en='S<;a/:;]]u>@alZ>v;]aCYa0uZ{Z;{',fr='S<;a/:;]]u>@alZ>v;]aCYa0uZ{Z;{',de='S<;a/:;]]u>@alZ>v;]aCYa0uZ{Z;{',})
lct:RT(2880292413,false,92,{en='lu[[C^@aMC}',fr='lu[[C^@aMC}',de='lu[[C^@aMC}',})lct:RT(2880292413,1646548948,92,{en='lu[[C^@aMC}',fr="lu[[C^@aMC}",de="lu[[C^@aMC}",})
lct:RT(1238557531,3205972763,92,{en='Tu}aCYa@<;a0]^>=;>aTu]v;>',fr="5@}[;av;a1u]vZ;>am|];",de="M;@]^>=;>;]aTbX<@;]",})
lct:RT(1313177490,false,92,{en='S<;am>|Z>XZ:[;',fr='nDZ>|Z>XZ:[;',})
lct:RT(3056781926,false,92,{en='kuvA;[[D{a4[u@Z>^ya3;y:;]',})
lct:RT(1161907310,false,1391,{en='SZ>=;]',})
lct:RT(1222365137,3142621338,92,{en='5u>w^Z>uZ];',fr="5u>w^Z>uZ];",de="5u>w^Z>uZ];",})
lct:RT(2012667774,575033278,92,{en='5u>w^Z>;{{',fr="5u>w^Z>;{{",de="5u>w^Z>;{{",})
lct:RT(4123739079,false,92,{en='S<;a3u>;',})
lct:RT(551158195,false,92,{en='0]uwC>a5[u};]',fr='k<u{{;^]av;av]uwC>',de='0]uX<;>@`@;]',})
lct:RT(2553360053,false,2079,{en='S<;a4u>ZXa3uw;',})lct:RT(2553360053,794632023,2079,{en='S<;a4u>ZXaTZBu]v',})
lct:RT(89193783,false,92,{en='0u]=>;{{',fr='SE>c:];{',de='0^>=;[<;Z@',})
lct:RT(3204312368,false,92,{en='1]u>vakCYY;;anC]v',})
lct:RT(606118324,false,true,{en='nZ|Z>wan;w;>v',fr='nEw;>v;a6Z|u>@;',de='n;:;>v;an;w;>v;',})
lct:RT(954221767,false,true,{en='5;;=;]aCYalC]:Zvv;>aP>CA[;vw;',fr='k<;]X<;^]{av;a5u|CZ]am>@;]vZ@',de='5^X<;]av;{a6;]:C@;>;>aTZ{{;>{',})lct:RT(954221767,530591113,true,{en='5@C]}@;[[;]aY]Cya/{<[u>v{',fr="n;akC>@;^]av;{aS;]];{Fk;>v];{",de="3b]X<;>;]Bb<[;]au^{a/{X<[u>v",})
lct:RT(1610273556,false,true,{en='q>YC]{;;Z>w[}a/Au=;>;v',fr='pE|;Z[[Eav;aluXC>am>u@@;>v^;',de='q>;]Au]@;@a1;A;X=@',})lct:RT(1610273556,1380729270,2079,{en='OCCv;vaTu>v;];]',fr="6uwu:C>vaaakuz^X<C>",de="Tu>v;];]ayZ@aPuz^B;",})
lct:RT(2664002978,false,92,{en='3u{@;]aQZ>xu',})
lct:RT(1939977988,false,92,{en='n^>u]ak<uyzZC>',})
lct:RT(1228265292,false,92,{en='MuvaMu]va/YZXZC>uvC',fr='4u{{ZC>>Eav;a3u^|uZ{aMu]v;{a',})
lct:RT(1324202907,false,92,{en='oYa@<;ap;va5u>v{',})lct:RT(1324202907,3248849783,92,{en='oYa@<;ap;va5u>v{',})
lct:RT(1616494166,false,92,{en='S<;ap;vaTZ@X<',})lct:RT(1616494166,2000978796,92,{en='S<;ap;vaTZ@X<',})
lct:RT(3490435460,false,92,{en='Mu@@[;w]C^>vakC>?^;];]',})lct:RT(3490435460,2626432313,92,{en='3u{@;]aoYamX;',})
lct:RT(4025643251,false,92,{en='Tu]]ZC]aCYa5^>[Zw<@',de='P]Z;w;]av;]a5C>>;>[ZX<@',})
lct:RT(876757338,false,92,{en='N>YC[v;]aoYa0u]=>;{{',})
lct:RT(978363252,false,2136,{en='S<;a5Z_@<amyz;]Zu[an;wZC>',})lct:RT(978363252,1979309473,92,{en='S<;a5Z_@<amyz;]Zu[an;wZC>',})
lct:RT(3337363968,false,92,{en='S]Zz[;a/w;>@',})
lct:RT(3303600301,false,92,{en='3u{@;]aCYaQC>;',fr='3uZ@];av;apZ;>',de='5@;<@{aM;yi<@;]',})
lct:RT(463565339,false,92,{en='S^]@[;aTZ@X<',fr='nua5C]XZc];aSC]@^;',de='5X<Z[v=]`@;><;_;',})
lct:RT(2027559765,false,51,{en='kuvA;[[D{aPZ@X<;>aO;[z',fr='/Zv;av;aX^Z{Z>;av;akuvA;[[',de='kuvA;[[{D{aPiX<;><Z[Y;',})
lct:RT(2725350425,false,1391,{en='3u]w]u|;aCYa/{z;]>',})
lct:RT(2273011628,false,92,{en='1]u>vaN>X<u>@];{{',fr='1]u>v;aN>X<u>@;];{{;',de='1]Ct|;]Bu^:;]Z>',})
lct:RT(2563341608,1087919345,51,{en='O^yZvZYZ;]',})
lct:RT(2184782117,1188715368,92,{en='nC>wZ>',fr="nC>wZ>",de="nC>wZ>",})
lct:RT(4047084960,false,92,{en='5@u]anC]v',})
lct:RT(3245915300,false,92,{en='3u{@;]aCYa@<;a5@C>;valZ{@',fr='3uZ@];av;a[ua5@C>;valZ{@',de='3;Z{@;]av;{a5@C>;valZ{@',})
lct:RT(1488161712,false,92,{en='0;uva1uy;',})lct:RT(1488161712,4217760066,705,{en='M;{@a5C]XaZ>aO}{@;]Zu',})
lct:RT(345493239,false,92,{en='S<;ao>;au>vao>[}',fr='n;a5;^[a;@aq>Z?^;',de='a0;]aNZ>BZwaTu<];',})
lct:RT(356919767,false,92,{en='3;@u[aTu]]ZC]',fr='3;@u[aTu]]ZC]',de='3;@u[aTu]]ZC]',})lct:RT(356919767,3260564010,92,{en='5@C>;aP;;z;]',fr="1u]vZ;>av;a4Z;]];",de="5@;Z>AbX<@;]",})
lct:RT(3666218718,false,2079,{en='0]^>=ak^@;aP<uxZZ@',fr='3Zw>C>am|];aP<uxZZ@',de='M;@]^>=;>;]a{it;]aP<uxZZ@',})lct:RT(3666218718,353685125,2079,{en='N_;X^@ZC>;]aCYa5[Zzz;]{',fr="MC^]];u^av;azu>@C^Y[;{",de="5X<u]Y]ZX<@;]a|C>aOu^{{X<^<;>",})
lct:RT(958730344,false,1810,{en='@<;aQZ<Z[Z{@',fr='[;aQZ<Z[Z{@;',de='vZ;aQZ<Z[Z{@Z>',})
lct:RT(1055829041,3783356330,92,{en='6u;]yZ>uD{a5Xuyz',})
lct:RT(406247130,false,92,{en='O;[[{Z>w',fr='O;[[{Z>w',})
lct:RT(4032446867,false,92,{en='k]CAaCYa2^vwy;>@',fr='kC]:;u^av;a2^w;y;>@',de='P]b<;av;{a1;]ZX<@{',})
lct:RT(3908965003,false,1391,{en='0]uwC>a0;{@]C};]',fr='0E|u{@u@;^]av;{a0]uwC>{',de='6;]>ZX<@;]av;]a0]uX<;>',})
lct:RT(3830295714,false,92,{en='MC^>@}aO^>@;]',fr='ak<u{{;^]av;a4]Zy;{',de='PCzYw;[vxbw;]',})lct:RT(3830295714,2739851226,92,{en='MC^>@}aO^>@;]',fr="k<u{{;^]av;a4]Zy;{",de="PCzYw;[vxbw;]",})
lct:RT(798732954,3058436596,92,{en='S<;az[uw^;aCYa/@@Z[u',fr="n;aY[Eu^avD/@@Z[u",de="0Z;a4;{@a|C>a/@@Z[u",})
lct:RT(2091287832,false,92,{en='5XZzZC',fr='5XZzZC',de='5XZzZC',})lct:RT(2091287832,2293332014,628,{en='/>XZ;>@aP>Zw<@',fr="kO;|uZ[;]a/>@Z?^;",de="/[@;]apZ@@;]",})
lct:RT(840089880,false,92,{en='nZw<@Z>w:C]>',fr='nZw<@Z>w:C]>',de='nZw<@Z>w:C]>',})lct:RT(840089880,3529200344,2079,{en='3C]wuA{;',fr="3C]wuA{;",de="3C]wuA{;",})
lct:RT(1405090802,false,92,{en='PZ>waCYaT]u@<',})
lct:RT(1183658927,false,92,{en='S<;a4uXZYZ{@',fr='an;a4uXZYZ{@;',de='0;]a4uBZYZ{@',})lct:RT(1183658927,3440415553,92,{en='S<;ap^>>;]',fr="n;akC^];^]",de="0;]anb^Y;]",})
lct:RT(2175566571,false,92,{en='Nyz;]C]aO;[apuakZ@uv;[',fr='Nyz;];^]aO;[apua[uakZ@uv;[[;',de='PuZ{;]aO;[apuaUZ@uv;[[;',})lct:RT(2175566571,3175093035,92,{en='Nyz;]C]aO;[apuakZ@uv;[',fr="Nyz;];^]aO;[apuav;akZ@uv;[[;",de="PuZ{;]aO;[apuav;]aUZ@uv;[[;",})
lct:RT(2083290332,3210546897,1330,{en='TZBu]vanZBu]v',})
lct:RT(3862807513,3783356330,628,{en='0Z{w]uX;vaOC]@u@C]',fr="n;aMuYC^EaOC]@u@C]",de="0;]aM;{X<by@;]aOC]@u@C]",})
lct:RT(4153392899,false,92,{en='/|CXuvCaO;u]@',})lct:RT(4153392899,2739851226,1391,{en='0]Cyu@<]ua/|CXuvC',})
lct:RT(2954123608,false,705,{en='ou@<=;;z;]',fr='a1^u]vZa>av;az]Cy;{u{',de='NZvAu<];]',})
lct:RT(2862503551,3440415553,92,{en='l[uy;am>Xu]>u@;',fr="l[uy;am>Xu]>u@;",de="l[uy;am>Xu]>u@;",})
lct:RT(4069611208,false,92,{en='5=CCyua/vvZX@',})lct:RT(4069611208,3175093035,92,{en='5=CCyua/vvZX@',})
lct:RT(3215497473,false,92,{en='5<uvCAa3u{@;]',})lct:RT(3215497473,2145654398,92,{en='5<uvCAa3u{@;]',})
lct:RT(2029483333,false,628,{en='kNoaCYakC>{@Z@^@ZC>u[aTu]]ZC]{',})
lct:RT(1322074685,false,92,{en='Tu]]ZC]aCYa0u]=>;{{',fr='Tu]]ZC]aCYa0u]=>;{{',de='Tu]]ZC]aCYa0u]=>;{{',})
lct:RT(2618202561,false,92,{en='S<;aq>v;]@u=;]',})lct:RT(2618202561,1792428649,92,{en='S<;aq>v;]@u=;]',})
lct:RT(1708071790,false,92,{en='maO;u]@aq>ZXC]>{',})
lct:RT(3732411662,2272798337,92,{en='0;yZF1Cv',})
lct:RT(2303175925,2873087251,92,{en='3uvuy;',fr="3uvuy;",de="l]u^",})
lct:RT(3550666866,false,92,{en='S<;a1Cu@[Z=;',})lct:RT(3550666866,99471649,92,{en='0^]Z>D{aMu>;',})
lct:RT(172649679,false,92,{en='5@;u[;]aCYaS<ZX=>;{{',})lct:RT(172649679,2972455359,2079,{en='/vyZ];]aCYaSCC@Z;{',})
lct:RT(1323501887,false,92,{en='3;CA:[uv;',fr='3;CA:[uv;',de='3;CA:[uv;',})
lct:RT(62645408,false,2467,{en='5[u};]aCYalu[{;a1Cv{',})
lct:RT(329996214,false,92,{en='5=Zzyu{@;]',})
lct:RT(3644523033,false,92,{en='S<;aS;>@<a0Z|Z>;',fr='n;a0Z_Zcy;a0Z|Z>',de='0u{aU;<>@;a1`@@[ZX<;',})
lct:RT(2760823504,3673957442,92,{en='1Cvz[u]',fr="0Z;^z[u]",de="1C@@z[u]",})
lct:RT(1026540765,false,92,{en='045a[Z=;a5<^ZTu>w',})
lct:RT(2097261633,false,628,{en='7C^>wa5X]C[[{',fr='7C^>wa5X]C[[{',de='7C^>wa5X]C[[{',})
lct:RT(3577146438,false,494,{en='l[u};]aCYalZ{<;{',})lct:RT(3577146438,3490075530,494,{en='l[u};]aCYalZ{<;{',})
lct:RT(1523827001,false,92,{en='1;>;]u[aCYa@<;amyz;]Zu[an;wZC>',fr='1E>E]u[av;a[uanEwZC>aZyzE]Zu[;',de='1;>;]u[av;]aZyz;]Zu[;>an;wZC>',})
lct:RT(4041455212,false,92,{en='PZ>waoYanZBu]v{',fr='pCZav;{anEBu]v{',de='P`>Zwav;]aNZv;X<{;>',})
lct:RT(2224882338,false,true,{en='M;^vv;[>',fr='M;^vv;[>',de='M;^vv;[>',})lct:RT(2224882338,8126214,true,{en='M;^vv;[>',})
lct:RT(2569105891,false,true,{en='k<Z;Ya/vvC>aMC]=;]',})
lct:RT(4214596307,false,1330,{en='3u;[{@]CyaSC]y;>@C]',})lct:RT(4214596307,2631338109,92,{en='Su>=Z>waTu[[{aT;[[',})
lct:RT(178543469,false,92,{en='k<uyzZC>aCYa5@;>vu]]',})lct:RT(178543469,2931762339,51,{en='/]X<Fk^]u@;',})
lct:RT(3307984231,false,92,{en='6Z]@^;aCYapuw;',fr='6;]@^av;apuw;',de='S^w;>vav;]aT^@',})
lct:RT(873298121,false,92,{en='S<;aM;u]',})lct:RT(873298121,2275034664,92,{en='S<;aM;u]',})
lct:RT(3077479002,false,92,{en='kuy;[aT<Z{z;];]',fr='[DC];Z[[;av;{aX<uy;u^_',de='kuy;[Y[i{@;];]',})
lct:RT(359275554,false,1838,{en='3u>XC{aSC]y;>@C]',})lct:RT(359275554,4214757878,2139,{en='3u>XCaO;u]@',})
lct:RT(2608950231,false,92,{en='l[uyZ>wapu{Xu[',fr='l[uyZ>wakC?^Z>',de='l[uyy;>v;]a5X<^]=;',})lct:RT(2608950231,3114015609,92,{en='l[uyZ>wapu{Xu[',fr="l[uyZ>wakC?^Z>",de="l[uyy;>v;]a5X<^]=;",})
lct:RT(2830441086,3311190470,92,{en='1Cv{;>@',})
lct:RT(2337952014,false,92,{en='Muva1Z][',})
lct:RT(2269516296,false,92,{en='S<;am>v;@;]yZ>u@;',fr='nDZ>vE@;]yZ>E',de='0u{aq>:;{@Zyy@;',})
lct:RT(4143086157,2511439052,628,{en='1]u>va/vx^vZXu@C]',fr="2^w;a5^z]Ky;",de="OC<;]apZX<@;]",})
lct:RT(2319123623,false,92,{en='0];uyyC]@u[a0];uy@;uy;]',fr='0];uyyC]@u[a0];uy@;uy;]',de='0];uyyC]@u[a0];uy@;uy;]',})lct:RT(2319123623,2171605849,92,{en='0];uyyC]@u[a0];uy@;uy;]',fr="0];uyyC]@u[a0];uy@;uy;]",de="0];uyyC]@u[a0];uy@;uy;]",})
lct:RT(1134580626,false,494,{en='5[;;zZ>wa0]uwC>',})
lct:RT(3015558745,false,true,{en='myz;]Zu[a1]u>valZ;[va3u]{<u[',fr='1]u>va3u]EX<u[amyzE]Zu[',de='myz;]Zu[;]a1]CtY;[vyu]{X<u[[',})
lct:RT(943250108,false,92,{en='4]CY;{{ZC>u[a4[;:',fr='4]CY;{{ZC>u[a4[;:',de='4]CY;{{ZC>u[a4[;:',})
lct:RT(2641928740,false,92,{en='/]X<Z@;X@',})lct:RT(2641928740,4148511204,51,{en='N@;]>u[',})
lct:RT(2660935563,false,92,{en='0u]=aNy;]u[v',fr='Ny;]u^v;aQCZ];',})
lct:RT(3395979201,false,92,{en='1]u>va5^wu]a0uvv}',})lct:RT(3395979201,1413032936,92,{en='1]u>va5^wu]a0uvv}',})
lct:RT(984052525,false,true,{en='~XllHHll0]uyuaR^;;>~]',fr='~XllHHll0]uyuaR^;;>~]',de='~XllHHll0]uyuaR^;;>~]',})
lct:RT(1262783318,false,92,{en='3u{@;]aCYa@<;a5@C>;valZ{@',fr='yug@];av^a{@C>;vazCZ>w',de='3;Z{@;]av;]a{@C>;valZ{@',})
lct:RT(1650789143,false,92,{en='Su_akC[[;X@C]',fr='p;X;|;^]av;{amyzg@{',de='5@;^;];Z>@];Z:;]',})
lct:RT(3533593082,false,92,{en='lC]@^>;aYu|C]{a@<;a:]u|;',fr='lC]@^>;aYu|C]{a@<;a:]u|;',de='lC]@^>;aYu|C]{a@<;a:]u|;',})lct:RT(3533593082,3761384242,92,{en='lC]@^>;aYu|C]{a@<;a:]u|;',fr="lC]@^>;aYu|C]{a@<;a:]u|;",de="lC]@^>;aYu|C]{a@<;a:]u|;",})
lct:RT(1423373856,false,92,{en='q>[ZyZ@;vaM}a3;@uwuy;',fr='q>[ZyZ@;vaM}a3;@uwuy;',de='q>[ZyZ@;vaM}a3;@uwuy;',})
lct:RT(914824185,false,92,{en='6;]}a0u>w;]C^{',de='5;<]a1;Yb<][ZX<',})
lct:RT(1391848216,false,true,{en='5>;u=Z>waku]]',})
lct:RT(65717617,false,92,{en='0;yC>',fr='0;yC>',de='0;yC>',})lct:RT(65717617,1473188427,92,{en='0;yC>',fr="0;yC>",de="0;yC>",})
lct:RT(1278749862,2668260047,2079,{en='S;uyu=;]aY]CyaTCCv[u>v',fr="aS;uyu=;]av;aTCCv[u>v",de="aS;uyu=;]au^{aTCCv[u>v",})
lct:RT(713456765,1029352311,92,{en='o>;;ak<u>',})
lct:RT(3491497586,false,true,{en='kuy;[a5y^ww[;]',})
lct:RT(2245455069,false,92,{en='3C@<;]aCYa0]uwC>{',fr='3c];av;{a0]uwC>{',de='3^@@;]av;]a0]uX<;>',})lct:RT(2245455069,856468944,92,{en='3C@<;]aCYa0]uwC>{',fr="3c];av;{a0]uwC>{",de="3^@@;]av;]a0]uX<;>",})
lct:RT(3355625020,false,92,{en='l]Z;>v[}aQ;Zw<:C^]<CCvaO;u[;]',})
lct:RT(2203551725,false,92,{en='l^>wu[aw]C@@CaeaXC>?^;]C]',fr='XC>?^E]u>@aav;a[uaX<uyzZ',})
lct:RT(2893563397,false,92,{en='1<C{@a5;ua4Z]u@;',fr='a4Z]u@;av;a[ua3;]alu>@gy;',de='a4Z]u@av;{a1;Z{@;]y;;];{',})lct:RT(2893563397,4229598108,92,{en='Q;|;]a0;uv',fr="2uyuZ{a3C]@",de="QZ;yu[{aSC@",})
lct:RT(151045828,false,92,{en='5zuy{a/[[a5=Z[[{',})lct:RT(151045828,1846953924,1810,{en='0;;z{aYC]a0C[[u]{',})
lct:RT(935575748,false,92,{en='5@u]|Z>wa/]@Z{@',fr='/]@Z{@;a/YYuyE',de='a6;]<^>w;]>v;]aPi>{@[;]',})
lct:RT(3521725168,false,92,{en='S<;aN>v^];]',})
lct:RT(173415841,false,92,{en='m>Xu]>u@ZC>aCYanZw<@',fr='m>Xu]>u@ZC>av;a[uan^yZc];',de='m>=u]>u@ZC>av;{anZX<@{',})lct:RT(173415841,3805750726,92,{en='m>Xu]>u@ZC>aCYanZw<@',fr="m>Xu]>u@ZC>av;a[uan^yZc];",de="m>=u]>u@ZC>av;{anZX<@{",})
lct:RT(1889871608,false,92,{en='PZ>[C]v',fr='PZ>[C]v',de='PZ>[C]v',})lct:RT(1889871608,1554932340,628,{en='2^{@ZXZu]',fr="2^{@ZXZu]",de="2^{@ZXZu]",})
lct:RT(172741049,false,true,{en='SC^w<akCC=Z;',})
lct:RT(4022921457,false,92,{en='3Zvw;@aO;u[;]',fr='a1^E]Z{{;^]aQuZ>',de='UA;]w<;Z[;]',})
lct:RT(3186726290,473048699,true,{en='nuv}aCYamX;au>valZ];',fr="0uy;av;a1[uX;a;@av;al;^",de="0uy;a|C>aNZ{a^>val;^;]",})
lct:RT(3540120284,false,1810,{en='l[uy;aCYa/=u@C{<',})lct:RT(3540120284,2935056129,1810,{en='l[uy;aCYa/=u@C{<',})
lct:RT(2618202197,2332277357,92,{en='R^;;>am>aS<;aQC]@<',})
lct:RT(1089672112,false,628,{en='SC]|u[a5=CCyua0;u[;]{',})lct:RT(1089672112,3785612288,628,{en='SC]|u[a5=CCyua0;u[;]{',})
lct:RT(967119722,false,92,{en='S<;a5uzZ;>@',fr='nua5uw;',de='0Z;aT;Z{;',})
lct:RT(893306158,false,92,{en='PZ>waoYaS<;a5AZ>w',fr='PZ>waoYaS<;a5AZ>w',de='PZ>waoYaS<;a5AZ>w',})
lct:RT(2328936267,3758011349,92,{en='3u{@;]a/{{u{{Z>',fr="3ug@];a/{{u{{Z>",de="a3;Z{@;]a/@@;>@b@;]",})
lct:RT(2264389971,2292922193,92,{en='lu{<ZC>amXC>',de="lu{<ZC>Z=C>;",})
lct:RT(3932146712,false,92,{en='M^wBaM^>>}',})lct:RT(3932146712,515674925,92,{en='S<;ap;u[aM<Czan;w;>v',})
lct:RT(963571677,2231421979,1330,{en='4C{;ZvC>',fr="4C{;ZvC>",de="4C{;ZvC>",})
lct:RT(1907076472,false,92,{en='1C[v;>ao>;',})lct:RT(1907076472,2963348866,92,{en='1C[v;>ao>;',})
lct:RT(2383562118,false,92,{en='PZ>[C]v',fr='PZ>[C]v',de='PZ>[C]v',})
lct:RT(2544039907,false,92,{en='5X]^:wu]Z',})lct:RT(2544039907,4016167826,92,{en='S<;anZ:;]u@C]',})
lct:RT(3421028733,false,92,{en='lC[[CA;]aCYa3DuZ?a@<;anZu]',})
lct:RT(4220436107,false,true,{en='6Z]{>Z;={',fr='6Z]{>Z;={',de='6Z]{>Z;={',})lct:RT(4220436107,1579692822,true,{en='6Z]{>Z;={',fr="6Z]{>Z;={",de="6Z]{>Z;={",})
lct:RT(3969817078,false,92,{en='pC[;z[u};]',})lct:RT(3969817078,1273567643,1391,{en='S<;a1]C^zaTZz;]',})
lct:RT(2051331670,2705012021,494,{en='lu=;FSu_Za0]Z|;]',fr="lu=;FSu_Za0]Z|;]",de="lu=;FSu_Za0]Z|;]",})
lct:RT(3783722333,2487588457,92,{en='/X@^u[aS]u{<aMZ>aO^yu>',fr="a4C^:;[[;a]E;[[;a<^yuZ>;",de="Su@{bX<[ZX<;]a3i[[;Zy;]a3;>{X<",})
lct:RT(3254762646,false,92,{en='4;{=}aOC]>;@',fr='l];[C>aNy:K@u>@',de='nb{@Zw;aOC]>Z{{;',})
lct:RT(2424975577,false,92,{en='{=^[[{aYC]a@<;a{=^[[a@<]C>;',fr='X]a>;{azC^]a[;a@]g>;av^aX]a>;',de='5X<bv;[aYi]av;>a5X<bv;[@]C>',})lct:RT(2424975577,3700429125,92,{en='{=^[[{aYC]a@<;a{=^[[a@<]C>;',fr="X]a>;{azC^]a[;a@]g>;av^aX]a>;",de="5X<bv;[aYi]av;>a5X<bv;[@]C>",})
lct:RT(2050829764,false,92,{en='0u]=al[uyZ>Z=u',fr='l[uyZ>Z=uaQCZ];',de='a0^>=[;al[uyZ>Z=u',})
lct:RT(3995154142,2506084000,51,{en='N@;]>u[ak<uyzZC>',fr="k<uyzZC>aa@;]>;[",de="NAZw;]ak<uyzZC>",})
lct:RT(3178648388,false,92,{en='S<;aQZ>;FM];u=;]',fr='an;aQ;^YFM];u=;]',de='a0;]aQ;^>:];X<;]',})
lct:RT(3001208688,false,628,{en='S<;aM[uy;a1^}',fr='[;ay;Xa];{zC>{u:[;',de='v;]a5X<^[vZw;',})lct:RT(3001208688,154924223,628,{en='S<;aM[uy;a1^}',fr="[;ay;Xa];{zC>{u:[;",de="v;]a5X<^[vZw;",})
lct:RT(1283539786,2307703999,92,{en='1[u{{aSu>=',})
lct:RT(2489615138,false,92,{en='4uX=[;uv;]',de='p^v;[Yi<];]',})lct:RT(2489615138,841543750,92,{en='4uX=[;uv;]',de="p^v;[Yi<];]",})
lct:RT(63370110,false,92,{en='S]C[[D{aq>X[;',fr='S]C[[;{ao>X[;',de='S]C[[{ao>=;[',})
lct:RT(3692844061,1983768019,92,{en='/>w;[FNyz;]C]aCYa5XZ;>X;',fr="/>w;FNyz;];^]av;{a5XZ;>X;{",de="N>w;[FPuZ{;]av;]aTZ{{;>{X<uY@",})
lct:RT(353832012,false,92,{en='S<;aTZ>vaZ>a@<;aTZ[[CA{',fr='nua6;>@avu>{a[;{a5u^[;{',de='0;]aTZ>vaZ>av;>aT;Zv;>',})
lct:RT(610259872,false,51,{en='5>CCCCCCCCCB',})
lct:RT(1824232300,false,92,{en='0A;y;]aN>@<^{Zu{@a',fr='N>@<C^{Zu{@;a0A;y;]',de='0A;y;]aN>@<^{Zu{@',})
lct:RT(556930264,2524345496,92,{en='3u{@;]F/@F/]y{',})
lct:RT(3928852695,false,92,{en='/>w]}aNy:;]{',})
lct:RT(370381869,false,92,{en='Mu@@[;yuw^{',fr='3uw;av;akCy:u@',})
lct:RT(3495556974,false,1391,{en='0^yFyDu@<]uanZB^v',fr='0^yFyD/@<]uanZB^v',de='0^yFyD/@<]uanZB^v',})
lct:RT(3457805212,false,92,{en='O;u[;]',de='O;Z[;]',})
lct:RT(2224897098,false,92,{en='3;u_}avD/]=uvZ^y',fr='3;u_}avD/]=uvZ^y',de='3;u_}avD/]=uvZ^y',})lct:RT(2224897098,4186238090,92,{en='3;u_}avD/]=uvZ^y',fr="3;u_}avD/]=uvZ^y",de="3;u_}avD/]=uvZ^y",})
lct:RT(1210113671,false,494,{en='S<;anu{@aOCz;',fr='n;av;]>Z;]a;{zCZ]',de='0Z;a[;@B@;aOCYY>^>w',})lct:RT(1210113671,2496657312,494,{en='S<;anu{@aOCz;',fr="n;av;]>Z;]a;{zCZ]",de="0Z;a[;@B@;aOCYY>^>w",})
lct:RT(1091751491,3292216571,92,{en='@<;a<^>w]}',fr="[;{auYYuyE{",de="v;]aO^>w]Zw;",})
lct:RT(3184639910,1028168549,1391,{en='P]ZZvavCaYZ>apu<',fr="P]ZZvavCaYZ>apu<",de="P]ZZvavCaYZ>apu<",})


--[[
Author: Kyoma
Filename: LibTitleLocale.lua
Version: 3 (Horns of the Reach)
Total: 95 titles
]]--

local LocaleTitles =
{
	["de"] = 
	{
		[2] = 
		{
			[1810] = "Divayth Fyrs Gehilfe",
			[1838] = "Der Tick-Tack-Peiniger",
			[1330] = "makelloser Eroberer",
			[51] = "Monsterjäger",
			[705] = "Großfeldherr",
			[92] = "Freiwilliger",
			[494] = "Meisterangler",
			[1391] = "dro-m'Athra-Zerstörer",
			[628] = "Held Tamriels",
			[1910] = "Held der Eroberung",
			[1913] = "Großchampion",
			[2139] = "Greifenherz",
			[2079] = "Stimme der Vernunft",
			[2136] = "Lichtbringer",
			[2075] = "Unsterblicher Erlöser",
		},
		[1] = 
		{
			[1810] = "Divayth Fyrs Gehilfin",
			[1838] = "Die Tick-Tack-Peinigerin",
			[1330] = "makellose Eroberin",
			[51] = "Monsterjägerin",
			[705] = "Großfeldherrin",
			[92] = "Freiwillige",
			[494] = "Meisteranglerin",
			[1391] = "dro-m'Athra-Zerstörerin",
			[628] = "Heldin Tamriels",
			[1910] = "Heldin der Eroberung",
			[1913] = "Großchampion",
		},
	},
	["en"] = 
	{
		[2] = 
		{
			[1810] = "Divayth Fyr's Coadjutor",
			[1838] = "Tick-Tock Tormentor",
			[1330] = "The Flawless Conqueror",
			[51] = "Monster Hunter",
			[705] = "Grand Overlord",
			[628] = "Tamriel Hero",
			[1391] = "Dro-m'Athra Destroyer",
			[494] = "Master Angler",
			[92] = "Volunteer",
			[1910] = "Conquering Hero",
			[1913] = "Grand Champion",
			[2079] = "Voice of Reason",
			[2075] = "Immortal Redeemer",
			[2139] = "Gryphon Heart",
			[2136] = "Bringer of Light",
		},
		[1] = 
		{
			[1810] = "Divayth Fyr's Coadjutor",
			[1838] = "Tick-Tock Tormentor",
			[1330] = "The Flawless Conqueror",
			[51] = "Monster Hunter",
			[705] = "Grand Overlord",
			[628] = "Tamriel Hero",
			[1391] = "Dro-m'Athra Destroyer",
			[494] = "Master Angler",
			[92] = "Volunteer",
			[1910] = "Conquering Hero",
			[1913] = "Grand Champion",

		},
	},
	["fr"] = 
	{
		[2] = 
		{
			[1810] = "Coadjuteur de Divayth Fyr",
			[1838] = "Tourmenteur des Tic-tac",
			[1330] = "Le conquérant implacable",
			[51] = "Chasseur de monstres",
			[705] = "Grand maréchal",
			[628] = "Héros de Tamriel",
			[1391] = "Destructeur des dro-m'Athra",
			[494] = "Maître de pêche",
			[92] = "Volontaire",
			[1910] = "Héros conquérant",
			[1913] = "Grand champion",
			[2075] = "Rédempteur immortel",
			[2139] = "Cœur-de-griffon",
			[2136] = "Porteur de lumière",
			[2079] = "Voix de la raison",


		},
		[1] = 
		{

			[1810] = "Coadjutrice de Divayth Fyr",
			[1838] = "Tourmenteuse des Tic-tac",
			[1330] = "La conquérante implacable",
			[51] = "Chasseuse de monstres",
			[1391] = "Destructrice des dro-m'Athra",
			[494] = "Maîtresse de pêche",
			[705] = "Grand maréchal",
			[628] = "Héroïne de Tamriel",
			[92] = "Volontaire",
			[1910] = "Héroïne conquérante",
			[1913] = "Grande championne",
		},
	},
}

local GetAchievementRewardTitle_original

local function Unload()
	GetAchievementRewardTitle = GetAchievementRewardTitle_original
end

local function Load()

	GetAchievementRewardTitle_original = GetAchievementRewardTitle
	GetAchievementRewardTitle = function(achievementId, gender)
		local hasTitle, title = GetAchievementRewardTitle_original(achievementId, gender)
		if (hasTitle and gender) then
			if (LocaleTitles[lang] and LocaleTitles[lang][gender] and LocaleTitles[lang][gender][achievementId]) then
				title = LocaleTitles[lang][gender][achievementId]
			end
		end
		return hasTitle, title
	end

	LibCustomTitles.Unload = Unload
end

if(LibCustomTitles.Unload) then LibCustomTitles.Unload() end
Load()
