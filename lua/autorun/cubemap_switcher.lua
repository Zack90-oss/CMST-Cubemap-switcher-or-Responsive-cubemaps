local concommand = concommand
local coroutine = coroutine
local engine = engine
local net = net
local util = util
local file = file
local game = game
local hook = hook
local math = math
local string = string
local surface = surface
local table = table
local ents = ents

local CLIENT = CLIENT
local error = error
local ErrorNoHalt = ErrorNoHalt
local ipairs = ipairs
local isstring = isstring
local IsValid = IsValid
local Material = Material
local next = next
local pairs = pairs
local print = print
local PrintTable = PrintTable
local SERVER = SERVER
local RealTime = RealTime
local Vector = Vector
local SysTime = SysTime
local tonumber = tonumber
local SetClipboardText = SetClipboardText
local LocalPlayer = LocalPlayer
local CreateClientConVar = CreateClientConVar

--local list_map_mdl_vmt_sound = list_map_mdl_vmt_sound

CreateClientConVar("cubemap_switcher_disable","0",true,false,"Disables cubemap switching")

if(SERVER)then
	util.AddNetworkString("cubemap_switcher_lightpos")
end

function Getlist_map_mdl_vmt_sound()
	return list_map_mdl_vmt_sound
end

local Getlist_map_mdl_vmt_sound = Getlist_map_mdl_vmt_sound

module("cubemap_switcher")

FolderName="+cubemap_switcher"	-- + to get this folder on top of almost everything else

function CheckModuleInstalation()
	if(!Getlist_map_mdl_vmt_sound())then
		ErrorNoHalt("[Cubemap switcher]list_map_mdl_vmt_sound module isn't present. Download addon https://steamcommunity.com/sharedfiles/filedetails/?id=969978989\n")
		return false
	end
	return true
end

local cache = {}
function GetCacheTable()
	return cache
end

function CacheMaterialNames()
	if !CheckModuleInstalation() then return end
	
	cache = {}
	cache["default"]={}
	local files = Getlist_map_mdl_vmt_sound().scanBsp(nil,false,"materials","vmt")
	for path,_ in pairs(files)do
		local exppath = string.Explode("/",path)
		exppath=exppath[#exppath]
		local expname = string.Explode("_",exppath)
		
		local rejected = false
		if(#expname<3)then
			rejected = true
		else
			for i=1,3 do
				local str = string.StripExtension(expname[#expname+(1-i)])
				if(!tonumber(str))then
					rejected = true
				end
			end
		end
		if(!rejected)then
			local name = string.TrimLeft(path,"materials/")
			table.insert(cache["default"],name)
		end
	end
	return cache
end

--Easy Distribution--
function DistributeCacheTable()
	local origcache = table.Copy(cache)
	cache = {}
	for dontcare,tbl in pairs(origcache)do
		for whoasked,path in pairs(tbl)do
			local vmt = Material(path)
			local envname = vmt:GetString("$envmap")
			--print(envname)
			if(envname and envname~="debugempty")then	--What is debugempty??
				cache[envname] = cache[envname] or {}
				table.insert(cache[envname],path)
			end
		end
	end
	return cache
end

local lightpos = {}
local awaiting_GetFinishedFunction = false

local set_Invert = false
local set_NotStandalone = false

function DistributeCacheTableByDistance()--Use next func StartDistributeCacheTableByDistance() cause it auto requests from server
	local origcache = table.Copy(cache)
	cache = {}
	for cname,tbl in pairs(origcache)do
		local cpos = string.Explode("/",cname)
		--print(cpos)
		cpos = string.Explode("_",string.TrimLeft(string.StripExtension(cpos[#cpos]),"c"))
		--PrintTable(cpos)
		if(#cpos<3)then
			print("Cubemap "..cname.." doesn't have an origin!")
		else
			cpos = Vector(cpos[1],cpos[2],cpos[3])
			local bestdist = math.huge
			local bestname = "nolight"
			for _,lightinfo in pairs(lightpos)do
				local ligpos = lightinfo.Pos
				local lightname = lightinfo.Name
				
				local dist = cpos:DistToSqr(ligpos)
				if(dist<bestdist)then
					bestdist = dist
					bestname = lightname
				end
			end
			cache[bestname]=cache[bestname] or {}
			for _,extcname in pairs(origcache[cname] or {}) do
				table.insert(cache[bestname],extcname)
			end
		end
	end
	if(awaiting_GetFinishedFunction)then
		awaiting_GetFinishedFunction=false
		return GetFinishedFunction(set_Invert,set_NotStandalone)
	end
	return cache
end

local complete_DistributeCacheTableByDistance = false
local awaiting_DistributeCacheTableByDistance = false
function StartDistributeCacheTableByDistance()
	if(CLIENT)then
		if(!complete_DistributeCacheTableByDistance)then
			complete_DistributeCacheTableByDistance=false
			awaiting_DistributeCacheTableByDistance=true
			RequestLightPos()
		else
			return DistributeCacheTableByDistance()
		end
	end
	if(SERVER)then
		GetLightPos()
		PrintTable(lightpos)
		return DistributeCacheTableByDistance()
	end
end
--Easy Distribution--

if(CLIENT)then
	function RequestLightPos()
		net.Start("cubemap_switcher_lightpos")
		net.SendToServer()
	end	

	net.Receive("cubemap_switcher_lightpos",function(len)
		lightpos=net.ReadTable()
		if(awaiting_DistributeCacheTableByDistance)then
			awaiting_DistributeCacheTableByDistance=false
			complete_DistributeCacheTableByDistance=true
			StartDistributeCacheTableByDistance()
		end
	end)
end
if(SERVER)then
	function GetLightPos()
		lightpos={}
		local lights = ents.FindByClass("light")
		for i,light in pairs(lights)do
			table.insert(lightpos,{Name=light:GetName(),Pos=light:GetPos()})
		end
	end
	
	function SendLightPos(ply)
		GetLightPos()
		net.Start("cubemap_switcher_lightpos")
			net.WriteTable(lightpos)--Anyways
		net.Send(ply)
	end
	
	net.Receive("cubemap_switcher_lightpos",function(len,ply)
		if(ply:IsAdmin())then
			SendLightPos(ply)
		end
	end)

	function SwitchLights(lightname,state)
		local lights
		if(!lightname)then
			lights = ents.FindByClass("light")
		else
			lights = ents.FindByName(lightname)
		end
		for i,p in pairs(lights)do
			if(state)then
				p:Fire("TurnOn")
			else
				p:Fire("TurnOff")
			end
		end
	end
end

function ConstructFunction(NotStandalone,Invert)
	if !CheckModuleInstalation() then return end
	local func = "--Cubemap Switcher code (https://steamcommunity.com/sharedfiles/filedetails/?id=2901811539)\n"
	
	--print(NotStandalone)
	if(Invert=="1" or Invert==true)then
		func = func.."local dc_invertmode = true\n"
	end
	
	func = func..[[local dc_materialnames=util.JSONToTable(']]..util.TableToJSON(cache).."')\n"
	
	if(!NotStandalone and (NotStandalone=="1" or NotStandalone==true))then
		func = func..[[
if(CLIENT)then
	cubemap_switcher = cubemap_switcher or {}
	function cubemap_switcher.SwitchCubemaps(chunk,mode)
		local path = "maps/dc_"..game.GetMap().."/"
		local pathtoold = "maps/"..game.GetMap().."/"
		
		for i,vmtpath in pairs(chunk or {})do
			local vmt = Material(vmtpath)
			local envpath = vmt:GetString("$envmap")--:GetName()
			if(envpath)then
				local pathsplit = string.Explode("/",envpath)
				local envname = pathsplit[#pathsplit]
				
				if(mode==true)then
					path=pathtoold
				end
				
				--print(vmtpath,path..envname)
				vmt:SetTexture("$envmap",path..envname)
			end
		end
	end
end
]]	
	end
	
	func = func..[[
local DC_ChangedTable={}

local function DC_IsChanged(val,id)
	local meta = DC_ChangedTable 
	if( meta[id] == val )then return false end
	meta[id]=val
	return true
end	
if(SERVER)then
	util.AddNetworkString("dc_]]..game.GetMap()..[[")
	util.AddNetworkString("dc_]]..game.GetMap()..[[_request")
	
	local dc_lightents = {
		["light"]=true,
		["light_spot"]=true,
	}
	
	hook.Add( "AcceptInput", "dc_]]..game.GetMap()..[[", function( ent, name, activator, caller, data )
		if ( dc_lightents[ent:GetClass()] ) then
			local mode = nil
			if(name=="TurnOn")then
				mode = true
			elseif(name=="TurnOff")then
				mode = false
			elseif(name=="Toggle")then
				if(ent:GetInternalVariable("spawnflags")==1)then
					mode = true
				else
					mode = false
				end
			end
			if(dc_invertmode)then
				mode = !mode
			end
			if(isbool(mode) and DC_IsChanged(mode,ent:GetName()))then
				net.Start("dc_]]..game.GetMap()..[[")
					net.WriteBool( mode )
					net.WriteString( ent:GetName() )
				net.Broadcast()
			end
		end
	end )
	
	net.Receive( "dc_]]..game.GetMap()..[[_request", function( len, ply ) 
		if(!ply.dc_RequestedFullUpdate)then
			ply.dc_RequestedFullUpdate=true
			for lightname,_ in pairs(dc_materialnames)do
				local light = ents.FindByName(lightname)[1]
				local mode = nil
				if(light:GetInternalVariable("spawnflags")==1)then
					mode = false
				else
					mode = true
				end
				if(dc_invertmode)then
					mode = !mode
				end
				net.Start("dc_]]..game.GetMap()..[[")
					net.WriteBool( mode )
					net.WriteString( lightname )
				net.Broadcast()				
			end
		end
	end)	
end
if(CLIENT)then
	local dc_convar = CreateClientConVar("cubemap_switcher_disable","0",true,false,"Disables cubemap switching")
	net.Receive( "dc_]]..game.GetMap()..[[", function( len ) 
		local mode = net.ReadBool()
		local chunkid = net.ReadString()
		
		local chunk = dc_materialnames[chunkid]
		if(!chunk)then
			chunk = dc_materialnames["default"]
		end
		
		if(!dc_convar:GetBool())then
			cubemap_switcher.SwitchCubemaps(chunk,mode)
		end
	end)
	
	hook.Add( "ClientSignOnStateChanged", "dc_]]..game.GetMap()..[[", function(id,old,new)
		if(new==SIGNONSTATE_FULL)then
			net.Start("dc_]]..game.GetMap()..[[_request")
			net.SendToServer()
		end
	end)
end]]
	
	return func
end

function GetFinishedFunction(Invert,NotStandalone,DoPreparations)
	if !CheckModuleInstalation() then return end
	
	if(DoPreparations)then
		CacheMaterialNames()
		DistributeCacheTable()
		awaiting_GetFinishedFunction = true
		StartDistributeCacheTableByDistance()
	end
	if(awaiting_GetFinishedFunction)then return end
	local func = ConstructFunction(NotStandalone,Invert)
	set_Invert=false
	set_NotStandalone=false
	
	print(func)
	print("--This probably isn't all the code, this function creates a file with complete code at garrysmod/data/"..FolderName)
	if(CLIENT)then
		SetClipboardText(func)
		LocalPlayer():ChatPrint("Code was set into the clipoard buffer. CTRL + V it into the .lua file located at the *youraddon*/lua/autorun/*yourmapname*.lua")
	end
	file.CreateDir(FolderName)
	file.Write(FolderName.."/dc_"..game.GetMap()..".txt",func)
	return func
end

function WritePakFile()--Use WriteCubemapTextures() instead
	print("File was written into data/mapname.dat\nYou must change it's extension to .zip and open it to gain everyting you need(you need only the .vtf files in the main folder e.g. c0_-896_112.hdr.vtf, c0_-896_112.vtf and so on)")
	file.Write(game.GetMap()..".zip.dat",file.Read("maps/"..game.GetMap()..".bsp","GAME"))
end

local yieldIfNeeded
local function makeYieldFunction()
	local maxDuration = math.max( 1/20, engine.TickInterval() )  -- max = min( 20 fps, tickrate )
	local entered = SysTime()
	local now
	function yieldIfNeeded()
		now = SysTime()
		if now>entered+maxDuration then
			coroutine.yield()
			entered = now
		end
	end
end

local function stopSearch()
	hook.Remove( "Think", "cubemap_switcher" )
end

function WriteCubemapTextures(NoYield,ply)
	searchThread = coroutine.create( function()
		makeYieldFunction()
		
		bspPath = "maps/"..game.GetMap()..".bsp"
		local bsp = file.Open( bspPath, "rb", "GAME" )
		if bsp then
			local filedata = bsp:Read()
		
			local startsearchpos = 1
		
			local found,efound = string.find(filedata,"VTF",startsearchpos)
			
			if(found)then
				local filename = "_noname_(this should not exist).vtf"
				
				local endofnamesearch = false
				local iteration = 3
				local finstr = nil
				while(!endofnamesearch)do
					if(!NoYield)then
						yieldIfNeeded()--
						--coroutine.yield()
					end
					
					local str = string.sub(filedata,found-iteration,found-1)
					if(string.StartWith(str,"\0"))then
						filename = string.Explode("/",string.gsub(finstr,"\0",""))
						filename = filename[#filename]
						endofnamesearch=true
						break
					end
					finstr = str
					iteration = iteration + 1
				end
				print("extracting",filename)
				
				
				bsp:Seek(found-1)
				local start = true
				
				while(found)do
					local total = ""
					local stopped = false

					--Name check--
					local expname = string.Explode("_",filename)
					
					local rejected = false
					rejected = false
					if(#expname<3)then
						rejected = true
						print("rejected",filename)
					else
						for i=1,3 do
							local str = string.StripExtension(string.TrimLeft(string.StripExtension(expname[#expname+(1-i)]),"c"))
							if(!tonumber(str))then
								rejected = true
								print("rejected",filename)
							end
						end
					end
					
					if(filename=="cubemapdefault.vtf")then	--exclusion
						rejected=false
					end
					--Name check--
					
					while(!stopped and !rejected)do
						if(!NoYield)then
							yieldIfNeeded()--
							--coroutine.yield()
						end
						local line = bsp:ReadLine()
						if(!line)then
							stopSearch()--
							print("Extracting done into","garrysmod/data/"..FolderName.."/dc_"..game.GetMap().."/...")
							--if(CLIENT)then
								ply:ChatPrint("Cubemaps was written into garrysmod/data/"..FolderName.."/dc_"..game.GetMap())
								ply:ChatPrint("Move this folder into *youraddon*/materials/maps/")
							--end
							return
						end
						
						if(!start and string.find(line,"VTF"))then
							stopped = true
							break
						end
						start=false
						total = total..line
					end
					
					if(!rejected)then
						total = string.gsub(total,"\n","\0") --Replace all LF's with NUL's
						file.CreateDir(FolderName.."/dc_"..game.GetMap()) --There's still a few more useless but harmless lines, i won't get rid of them cause i'm lazy
						file.Write(FolderName.."/dc_"..game.GetMap().."/"..filename,total)
					end
					
					startsearchpos=efound
					found,efound = string.find(filedata,"VTF",startsearchpos)
					if(!found)then return end
					filename = "_noname_(this should not exist).vtf"	
					local endofnamesearch = false
					local iteration = 3
					local finstr = nil
					while(!endofnamesearch)do
						if(!NoYield)then
							yieldIfNeeded()--
							--coroutine.yield()
						end
						local str = string.sub(filedata,found-iteration,found-1)
						if(string.StartWith(str,"\0"))then
							filename = string.Explode("/",string.gsub(finstr,"\0",""))
							filename = filename[#filename]
							endofnamesearch=true
							break
						end
						finstr = str
						iteration = iteration + 1
					end
					print("extracting",filename)

					
					bsp:Seek(found-1)
					start = true
				end
			end
		end
	
	end)
	
	hook.Add( "Think", "cubemap_switcher", function()
		local alive,msgOrFinished = coroutine.resume( searchThread )
		if alive and msgOrFinished then
			stopSearch()
		elseif(!alive)then
			stopSearch()
		end
	end )	

	--stopSearch()
end

DC_Textures = DC_Textures or {}
function SwitchCubemaps(chunk,mode)
	--local chunk = tbl[id]
	local path = "maps/dc_"..game.GetMap().."/"
	local pathtoold = "maps/"..game.GetMap().."/"
	
	for i,vmtpath in pairs(chunk or {})do
		local vmt = Material(vmtpath)
		--print(vmt:GetTexture("$envmap"))
		local envpath = vmt:GetString("$envmap")--:GetName()
		if(envpath)then
			local pathsplit = string.Explode("/",envpath)
			local envname = pathsplit[#pathsplit]
			
			if(mode==true)then
				path=pathtoold
			end
			
			--print(vmtpath,path..envname)
			vmt:SetTexture("$envmap",path..envname)
		end
	end
end
--cubemap_switcher.SwitchCubemaps()

if(CLIENT)then
	concommand.Add("cubemap_switcher_getfunction",function(ply,cmd,args)
		GetFinishedFunction(nil,!args[1],true)
	end)
	
	concommand.Add("cubemap_switcher_getfunction_inverted",function(ply,cmd,args)
		set_Invert=true
		set_NotStandalone=!args[1]
		GetFinishedFunction(true,!args[1],true)
	end)	

	concommand.Add("cubemap_switcher_writecubemaps",function(ply,cmd,args)
		WriteCubemapTextures()
	end)
	
	concommand.Add("cubemap_switcher_writepakfile",function(ply,cmd,args)
		WritePakFile()
	end)	
	
	concommand.Add("cubemap_switcher_help",function(ply,cmd,args)
		print("Step 1: Turn off the lights.\n You must turn off all switchable lights on your map, use 'cubemap_switcher_turnlights 0' to do this")
		print("Step 2: Bake unlit cubemaps.\n Bake your cubemaps now, use 'buildcubemaps'")
		print("Step 3: Extract unlit cubemaps.\n Extract your cubemaps, use 'cubemap_switcher_writecubemaps' and follow instructions written in the chat after it finishes extraction. Your game mast be un-paused.")
		print("Step 4: Bake default cubemaps.\n Restart the map, then turn on all switchable lights on your map, use 'cubemap_switcher_turnlights 1' to do this. Then bake cubemaps, use 'buildcubemaps'")
		print("Step 5: Get the function.\n Restart the map again and then use 'cubemap_switcher_getfunction' and follow instructions written in the chat after it finishes extraction.")
		print("Step Final: Restart your game and enjoy.")
		print("If you still don't understand something, you can ask for help in the addon's comments or in discussions.")
	end)	
end

if(SERVER)then
	concommand.Add("cubemap_switcher_turnlights",function(ply,cmd,args)
		if(ply:IsAdmin())then
			if(args[1]=="1")then
				SwitchLights(nil,true)
			else
				SwitchLights(nil,false)
			end
		end
	end)
end