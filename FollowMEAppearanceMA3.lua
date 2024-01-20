local pluginName     = select(1,...);
local componentName  = select(2,...);
local signalTable    = select(3,...);
local my_handle      = select(4,...);
----------------------------------------------------------------------------------------------------------------


local PlugTitle = "FollowMEAppearanceMA3"

local messageDescription =  "USE WITH CAUTION, TAKE BACKUPS.\n\n"




-- Almost never tested.
-- No support is given.

-- Github: https://github.com/kinglevel
-- Instagram: @kinglevel
-- Please commit or post updates for the community


--[[
                      /mMNh-
                      NM33My
                      -ydds`
                        /.
                        ho
         +yy/          `Md           +yy/
        .N33N`         +MM.         -N33N`
         -+o/          hMMo          o++-
            d:        `MMMm         oy
-:.         yNo`      +MMMM-       yM+        .:-`
d33N:       /MMh.     dMMMMs     -dMM.       :N33d
+ddd:       `MMMm:   .MMMMMN    /NMMd        :hdd+
  ``hh+.     hMMMN+  +MMMMMM: `sMMMMo     -ody `
    -NMNh+.  +MMMMMy`d_SUM_My.hMMMMM-  -odNMm`
     /MMMMNh+:MMMMMMmMMMMMMMNmMMMMMN-odNMMMN-
      oMMMMMMNMMMMMMMMMMMMMMMMMMMMMMNMMMMMM/
       hMMMMMMMMM---LEDvard---MMMMMMMMMMMMo
       `mMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMh
        .NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMm`
         :mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm-
        `://////////////////////////////.
    -+ymMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNho/.

"Vision will blind. Severance ties. Median am I. True are all lies"

███╗   ███╗███████╗███████╗██╗  ██╗██╗   ██╗ ██████╗  ██████╗  █████╗ ██╗  ██╗
████╗ ████║██╔════╝██╔════╝██║  ██║██║   ██║██╔════╝ ██╔════╝ ██╔══██╗██║  ██║
██╔████╔██║█████╗  ███████╗███████║██║   ██║██║  ███╗██║  ███╗███████║███████║
██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║██║   ██║██║   ██║██║   ██║██╔══██║██╔══██║
██║ ╚═╝ ██║███████╗███████║██║  ██║╚██████╔╝╚██████╔╝╚██████╔╝██║  ██║██║  ██║
╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝



README: https://github.com/kinglevel/FollowMEAppearanceMA3

]]--



require "gma3_helpers"




--taken from systemtest
local function GetRTChannelFor(subfixture, attribute)
    local f = ObjectList(subfixture)[1]
    if f ~= nil then
        local attrIdx = GetAttributeIndex(attribute);
        local uiIdx = GetUIChannelIndex(f.SubfixtureIndex, attrIdx);
        local chUi = GetUIChannel(uiIdx);
        if chUi == nil then
            return nil
        end
        return GetRTChannel(chUi.rt_index);
    end
    return nil
end


--Absolute dmx adress for given attribute
local function absoluteAddr(fixid, attribute)
  local x = GetRTChannelFor("Fixture "..fixid, attribute)
  local y = x.patch["coarse"] + 1
  return y
end



--Absolute dmx adress to Universe and Adress
local function AbsAdressToUniAddr(absoluteAddress)
  local addressesPerUniverse = 512
  local universe = math.floor((absoluteAddress - 1) / addressesPerUniverse) + 1
  local address = ((absoluteAddress - 1) % addressesPerUniverse) + 1
  return universe, address
end



--Get dmx value
local function DMXvalue(AbsAddr)
  local universe, address = AbsAdressToUniAddr(AbsAddr)
  --Printf("Absolute address: ".. AbsAddr)
  --Printf("Universe: ".. universe.." Adress: "..address)
  local x = GetDMXValue(address, universe)
  --return dmx 8-bit
  return x
end




local function updateValues(fixtures)

  for i = 1, #fixtures do
    local x = absoluteAddr(fixtures[i].fix, fixtures[i].attr)
    local y = DMXvalue(x)
    fixtures[i].value = y
  end

  return fixtures
end




--sleep
local clock = os.clock

local function sleep(n)
	local t0 = clock()
	while clock() - t0 <= n do end
end





local function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
          copy[deepcopy(orig_key)] = deepcopy(orig_value)
      end
      setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end








local function tablesDiffer(table1, table2)
  -- Check if both tables are actually tables
  if type(table1) ~= "table" or type(table2) ~= "table" then
      return false
  end

  -- Function to compare two values
  local function compareValues(v1, v2)
      if type(v1) == "table" and type(v2) == "table" then
          return tablesDiffer(v1, v2)
      else
          return v1 ~= v2
      end
  end

  -- Check all keys and values in table1 against table2
  for key, value in pairs(table1) do
      if compareValues(value, table2[key]) then
          return true
      end
  end

  -- Check all keys and values in table2 against table1
  for key, value in pairs(table2) do
      if compareValues(value, table1[key]) then
          return true
      end
  end

  return false
end




local function updateLayout(fixtures, appearances)

  for i = 1, #fixtures do

    local fixtureID = fixtures[i].fix
    local fixtureValue = fixtures[i].value
    local datapool = fixtures[i].datapool
    local layout = fixtures[i].layout

    for k = 1, #appearances do


      if tonumber(appearances[k].value) == fixtureValue then
        Cmd("Assign " .. appearances[k].appearance .. " At Fixture " .. fixtureID)
      end


    end


  end


end




local function loop(fixtures, appearances)

  local previous = updateValues(fixtures)
  
  --tick tock
  while true do
    local current = updateValues(fixtures)
    --check if stuff has changed
    if tablesDiffer(current, previous) then
      updateLayout(fixtures, appearances)
    end
    --make a real copy of the table to compare
    previous = deepcopy(current)
    --stability
    sleep(0.1)
  end

end







local function Main(displayHandle)
  Printf(PlugTitle)



  --init fixture tables
  local fixtures = {}
  local appearances = {}


  --Fixtures to adjust
  table.insert(fixtures, {fix = "201", attr= "TARGET"})
  table.insert(fixtures, {fix = "202", attr= "TARGET"})
  table.insert(fixtures, {fix = "203", attr= "TARGET"})
  table.insert(fixtures, {fix = "204", attr= "TARGET"})
  table.insert(fixtures, {fix = "205", attr= "TARGET"})
  table.insert(fixtures, {fix = "206", attr= "TARGET"})
  table.insert(fixtures, {fix = "207", attr= "TARGET"})
  table.insert(fixtures, {fix = "208", attr= "TARGET"})
  table.insert(fixtures, {fix = "209", attr= "TARGET"})
  table.insert(fixtures, {fix = "210", attr= "TARGET"})
  table.insert(fixtures, {fix = "211", attr= "TARGET"})
  table.insert(fixtures, {fix = "212", attr= "TARGET"})

  --Appearances and DMX values 
  table.insert(appearances, {appearance="Appearance 20", value="0"})
  table.insert(appearances, {appearance="Appearance 21", value="3"})
  table.insert(appearances, {appearance="Appearance 22", value="5"})
  table.insert(appearances, {appearance="Appearance 23", value="7"})
  table.insert(appearances, {appearance="Appearance 24", value="10"})
  table.insert(appearances, {appearance="Appearance 25", value="13"})
  table.insert(appearances, {appearance="Appearance 26", value="15"})
  table.insert(appearances, {appearance="Appearance 27", value="18"})
  table.insert(appearances, {appearance="Appearance 28", value="20"})
  table.insert(appearances, {appearance="Appearance 29", value="23"})
  table.insert(appearances, {appearance="Appearance 30", value="26"})
  table.insert(appearances, {appearance="Appearance 31", value="28"})
  table.insert(appearances, {appearance="Appearance 32", value="31"})



  loop(fixtures, appearances)




  Printf("done")

end





return Main
