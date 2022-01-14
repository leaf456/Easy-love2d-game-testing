local address, ishover, status, runtext, stage = "", false, "Idle. Use your keyboard to input the server address.", "Start", 1
local socket = require("socket.http")
local files, keyplaces1 = {}, {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "<", "l"}
local keyplaces2 = {{2, 4}, {1, 1}, {2, 1}, {3, 1}, {1, 2}, {2, 2}, {3, 2}, {1, 3}, {2, 3}, {3, 3}, {1, 4}, {3, 4}, {2, 5}}
local json, key, windowx, windowy = require("json"), "Python server for lua", love.graphics.getWidth(), love.graphics.getHeight()
function love.load()
	if love.filesystem.getInfo("lastinput.txt") ~= nil then
		address = love.filesystem.read("lastinput.txt")
	end
end
function px(value)
	return (value / 800) * windowx
end
function py(value)
	return (value / 600) * windowy
end
function love.draw()
	love.graphics.setColor(0.4, 0.4, 1)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(0.2, 0.2, 0.2)
	love.graphics.rectangle("fill", px(10), py(10), px(380), py(120))
	love.graphics.setColor(1, 1, 1)
	love.graphics.setNewFont(py(25))
	love.graphics.print("Enter local server address", px(35), py(15))
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", px(30), py(50), px(340), py(60))
	love.graphics.setColor(1, 1, 1)
	love.graphics.setNewFont(py(50))
	love.graphics.print(address, px(30), py(50))
	love.graphics.setNewFont(py(15))
	love.graphics.print("Tip: press L for localhost.", px(100), py(110))
	if ishover then love.graphics.setColor(0.1, 0.9, 0.1) else love.graphics.setColor(0.1, 1, 0.1) end
	love.graphics.rectangle("fill", px(410), py(10), px(280), py(120))
	love.graphics.setColor(1, 1, 1)
	love.graphics.setNewFont(py(100))
	love.graphics.print(runtext, px(420), py(10))
	love.graphics.setNewFont(py(20))
	love.graphics.print("Status: "..status, px(10), py(155))
	if files ~= nil then
		for i = 1, #files do
			love.graphics.setColor(0.2, 0.2, 1)
			love.graphics.rectangle("fill", px(10), py(160 + (20 * i)), px(300), py(20))
			love.graphics.setColor(1, 1, 1)
			love.graphics.print(files[i], px(10), py(158 + (20 * i)))
		end
	end
	love.graphics.setNewFont(py(60))
	for x = 1, #keyplaces1 do
		love.graphics.setColor(0.3, 0.8, 0.3)
		love.graphics.rectangle("fill", px(keyplaces2[x][1] * 75 + 320), py(keyplaces2[x][2] * 65 + 120), px(73), py(63))
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(keyplaces1[x], px(keyplaces2[x][1] * 75 + 330), py(keyplaces2[x][2] * 65 + 120))
	end
end
local function getfilecontentsfromserver(path, id)
	c, h = socket.request("http://"..address..":1234/"..path)
	if c ~= nil and h == 200 then
		files[id] = files[id].." - Done"
		return c
	else
		files[id] = files[id].." - failed"
		return "404"
	end
end
local function runfiles()
	love.draw = nil
	start = nil
	findindexof = nil
	getfilecontentsfromserver = nil
	love.update = nil
	love.mousepressed = nil
	keyboard = nil
	love.keypressed = nil
	ishover, status, runtext, stage, socket, json, key, files = nil, nil, nil, nil, nil, nil, nil, nil
	collectgarbage()
	if love.filesystem.getInfo("recived_data/main.lua") ~= nil then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setNewFont(12)
		chunk = love.filesystem.load("recived_data/main.lua")
		love.load = function () end
		chunk()
		love.load()
	end
end
local function start()
	if stage == 1 then
		status = "connecting..."
		c, h = socket.request("http://"..address..":1234")
		status = h
		if h == 200 and c ~= nil then
			if string.sub(c, 0, #key) == key then
				if love.filesystem.getInfo("lastinput.txt") ~= nil then
					love.filesystem.write("lastinput.txt", address)
				else
					local lastopened = love.filesystem.newFile("lastinput.txt")
					lastopened:open("w")
					lastopened:write(address)
					lastopened:close()
				end
				stage = 2
				files = json.decode(string.sub(c, #key + 1, #c))
				if love.filesystem.getInfo("recived_data") ~= nil then
					local oldfiles = love.filesystem.getDirectoryItems("recived_data")
					for q = 1, #oldfiles do
						love.filesystem.remove("recived_data/"..oldfiles[q])
					end
					love.filesystem.remove("recived_data")
				end
				love.filesystem.createDirectory("recived_data")
				for i = 1, #files do
					local file = love.filesystem.newFile("recived_data/"..files[i])
					file:open("w")
					file:write(getfilecontentsfromserver(files[i], i))
					file:close()
				end
			end
		end
	else
		runfiles()
	end
end
local function findindexof(array, name)
	for i = 1, #array do
		if array[i] == name then
			return i
		end
	end
	return -1
end
function gettouchbuttonidfromposition(x, y)
	for i = 1, #keyplaces2 do
		if (x > px(keyplaces2[i][1] * 75 + 320)) and (x < px(keyplaces2[i][1] * 75 + 320 + 73)) 
		and (y > py(keyplaces2[i][2] * 65 + 120)) and (y < py(keyplaces2[i][2] * 65 + 120 + 63)) then
			return i
		end
	end
	return -1
end
function love.touchpressed(id, x, y)
	if (x > px(30)) and (x < px(370)) and (y > py(50)) and (y < py(110)) then
		start()
	else
		local buttonid = gettouchbuttonidfromposition(x, y)
		if buttonid ~= -1 then
			if keyplaces1[buttonid] == "<" then
				keyboard("backspace")
			else
				keyboard(keyplaces1[buttonid])
			end
		end
	end
end
function love.update()
	x, y = love.mouse.getX(), love.mouse.getY()
	if (x > px(410)) and (x < px(690)) and (y > py(10)) and (y < py(130)) then
		ishover = true
		else
		ishover = false
	end
end
function love.mousepressed(x, y, b)
	if b == 1 then
		if (x > px(410)) and (x < px(690)) then if (y > py(10)) and (y < py(130)) then
			start()
		end end
	end
end
function keyboard(k)
	local allowedkeys = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "backspace", "l"}
	if findindexof(allowedkeys, k) ~= -1 then
		if k == "backspace" and (#address > 0) then address = string.sub(address, 1, #address - 1) else
			if k ~= "backspace" then
				if k == "l" then address = "localhost" else
					address = address..k
				end
			end
		end
	end
end
function love.keypressed(k)
	keyboard(k)
end