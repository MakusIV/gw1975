


-- 1975 Georgian War (gw1975.lua)
-- subject:  Campaign with Dynamic Enviroments.
--           gw1975.lua is based on Moose framework (https://flightcontrol-master.github.io/MOOSE_DOCS/)


-- author: MarkusIV
-- state:   functionla for gw1975 Campaign








-- variable
--- loggingLevel
-- 0 = nessun messaggio di log, 1 = error, 2 = severe, 3 = warning, 4 = info, 5 = fine, 6 = finer/enter/exit, 7 = finest
local loggingLevel = 0


-- Debug messages for ARTY
ARTY.Debug = false --If true, send debug messages to all.

-- Debug messages for WAREHOUSE
WAREHOUSE.Debug = false --If true, send debug messages to all.

-- Status messages for WAREHOUSE
WAREHOUSE.Report = false -- If true, send status messages to coalition.








------------------------------------------------------------------------------------ DEFINE FUNCTIONS -----------------------------------------------------------------------































------------------------------------------------------------------------------------ UTILITY FUNCTIONS ----------------------------------------------------------------------

-- General use functions



--- Registra in dcs.log le info di log
--
-- @param type = il tipo di logging: enter, exit, error, severe, warning, info, fine, finer, finest
-- @param info = info da inserire in base al type:
-- type = enter, exit  info = 'name function'
-- type = info error, warning, info, fine, finer, finest ={ 'name function' , 'info' }
-- 0 = nessun messaggio di log,   1 = error, 2 = severe, 3 = warning, 4 = info, 5 = fine, 6 = finer/enter/exit, 7 = finest
--
function logging(type, info)

    local msg = '1975GW - '
    local msg1 = 'Function:  '

    if type == 'enter' and loggingLevel > 5 then  env.info( msg .. 'ENTER - ' .. msg1 .. info) end

    if type == 'exit'  and loggingLevel > 5 then  env.info( msg .. 'EXIT - ' .. msg1 .. info ) end

    if type == 'error' and loggingLevel > 0 then  env.info( msg .. 'ERROR - '  .. msg1 .. info[1] .. '     -     message:' .. info[2] ) end

    if type == 'severe' and loggingLevel > 1 then  env.info( msg .. 'SEVERE - ' .. msg1 .. info[1] .. '     -     message:' .. info[2] ) end

    if type == 'warning' and loggingLevel > 2 then  env.info( msg .. 'WARNING - ' .. msg1 .. info[1] .. '     -     message:' .. info[2] ) end

    if type == 'info' and loggingLevel > 3 then  env.info( msg .. 'INFO - ' .. msg1 .. info[1] .. '     -     message:' .. info[2] ) end

    if type == 'fine' and loggingLevel > 4 then  env.info( msg .. 'FINE - ' .. msg1 .. info[1] .. '     -     message:' .. info[2] ) end

    if type == 'finer' and loggingLevel > 5 then  env.info( msg .. 'FINER - ' .. msg1 .. info[1] .. '     -     message:' .. info[2] ) end

    if type == 'finest' and loggingLevel > 6 then  env.info( msg .. 'FINEST - ' .. msg1 .. info[1] .. '     -     message:' .. info[2] ) end

    return

end



--- Imposta il livello di log impostando la variabile loggingLevel.
--
--  @param level = 1 = error, 2 = severe, 3 = warning, 4 = info, 5 = fine, 6 = finer, 7 = finest
--
function setLoggingLevel(level)


    if level == 'notlog'  then loggingLevel = 0 end

    if level == 'error'  then loggingLevel = 1 end

    if level == 'severe'  then loggingLevel = 2 end

    if level == 'warning'  then loggingLevel = 3 end

    if level == 'info'  then loggingLevel = 4 end

    if level == 'fine'  then loggingLevel = 5 end

    if level == 'finer'  then loggingLevel = 6 end

    if level == 'finest'  then loggingLevel = 7 end

    return

end




--- Controlla se i parametri sono presenti. Restituisce true se presente altrimenti false
-- @param param: tabella contenente i parametri
-- @param present: tabella contenente le posizioni dei parametri da verificare
function checkParam(param, present)

  if present == null then return true end

  if present == 'all' then -- richiesta la verifica di tutti i parametri

    for _, par in pairs(param) do

      if par == null then return false end

    end

    return true

  end -- end if

  -- present dovrebbe essere una tabella di numeri dovresti inserire un controllo

  for _, i in pairs(present) do

    if param[i] == null then return false end

  end

  return true

end




-- local typeTakeoff = { AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Takeoff.Runway, AI_A2A_DISPATCHER.Takeoff.Air }


--- Return type of Landing
function landing(percAir, percRnwy)

  local debug = false

  if debug then logging('enter', 'landing(percAir, percRnwy)') end

  percAir = math.floor( percAir * 10 ) or 4
  percRnwy = math.floor( percRnwy  * 10 ) or 4
  local percBox = 10 - percRnwy -  percAir

  if ( percAir + percRnwy + percBox )  ~= 10 then

    percAir = 5
    percRnwy = 3
    percBox = 2

  end

  if debug then logging('finest', { 'landing(percAir, percRnwy)' , '    - percAir = ' .. percAir .. ' - percRnwy = ' .. percRnwy .. ' - percBox = ' .. percBox  } ) end

  local a = 1
  local b = 1
  local c = 1
  local i = 1

  local casi = {'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null'}

  while i  < 10 do

    if a <= percAir then casi[i] = 'air'  a = a + 1  i = i + 1 end
    if b <= percRnwy then casi[i] = 'rnwy' b = b + 1  i = i + 1 end
    if c <= percBox then casi[i] = 'box' c = c + 1  i = i + 1 end

  end

  local typeLanding = casi[ math.random( 1, 10 ) ]

  if typeLanding == 'air' then ret = AI_A2A_DISPATCHER.Landing.NearAirbase
  elseif typeLanding == 'rnwy' then ret = AI_A2A_DISPATCHER.Landing.AtRunway
  else ret = AI_A2A_DISPATCHER.Landing.AtEngineShutdown
  end

  if debug then logging('finest', { 'landing(percAir, percRnwy)' , '    - AI_A2A_DISPATCHER.Landing.NearAirbase = ' .. AI_A2A_DISPATCHER.Landing.NearAirbase .. ' - AI_A2A_DISPATCHER.Landing.AtRunway = ' .. AI_A2A_DISPATCHER.Landing.AtRunway .. ' - AI_A2A_DISPATCHER.Landing.AtEngineShutdown = ' .. AI_A2A_DISPATCHER.Landing.AtEngineShutdown  } ) end
  if debug then logging('finest', { 'landing(percAir, percRnwy)' , '    - percAir = ' .. percAir .. ' - percRnwy = ' .. percRnwy .. ' - percBox = ' .. percBox .. ' - typeLanding = ' .. typeLanding .. ' - ret = ' .. ret  } ) end
  if debug then logging('exit', 'landing(percAir, percRnwy)') end

  return ret

end


--- Return type of take off
--
function takeOff(percAir, percRnwy, percHot)

  local debug = false

  if debug then logging('enter', 'takeOff(percAir, percRnwy, percHot)') end

  percAir = math.floor( percAir * 10 ) or 3
  percRnwy = math.floor( percRnwy * 10 ) or 4
  percHot = math.floor( percHot * 10 ) or 2
  local percBox = 10 - percRnwy -  percAir - percHot


  if ( percAir + percRnwy + percHot + percBox )  ~= 10 then

    percAir = 3
    percRnwy = 4
    percHot =  2
    percBox = 1

  end

  if debug then logging('finest', { 'takeOff(percAir, percRnwy, percHot)' , '    - percAir = ' .. percAir .. ' - percRnwy = ' .. percRnwy .. ' - percHot = ' .. percHot .. ' - percBox = ' .. percBox  } ) end

  local a = 1
  local b = 1
  local c = 1
  local d = 1
  local i = 1
  local casi = {'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null'}


  while i < 10 do

    if a <= percAir then casi[i] = 'air'  a = a + 1  i = i + 1 end
    if b <= percRnwy then casi[i] = 'rnwy' b = b + 1   i = i + 1 end
    if c <= percHot then casi[i] = 'hot' c = c + 1   i = i + 1 end
    if d <= percBox then casi[i] = 'box' d = d + 1   i = i + 1 end

  end

  local typeTakeOff = casi[ math.random( 1, 10 ) ]

  if typeTakeOff == 'air' then ret = AI_A2A_DISPATCHER.Takeoff.Air
  elseif typeTakeOff == 'rnwy' then ret = AI_A2A_DISPATCHER.Takeoff.Runway
  elseif typeTakeOff == 'hot' then ret = AI_A2A_DISPATCHER.Takeoff.Hot
  else ret = AI_A2A_DISPATCHER.Takeoff.Cold
  end


  if debug then logging('finest', { 'takeOff(percAir, percRnwy, percHot)' , '    - AI_A2A_DISPATCHER.Takeoff.Cold = ' .. AI_A2A_DISPATCHER.Takeoff.Cold .. ' - AI_A2A_DISPATCHER.Takeoff.Hot = ' .. AI_A2A_DISPATCHER.Takeoff.Hot .. ' - AI_A2A_DISPATCHER.Takeoff.Runway = ' .. AI_A2A_DISPATCHER.Takeoff.Runway .. ' - AI_A2A_DISPATCHER.Takeoff.Air = ' .. AI_A2A_DISPATCHER.Takeoff.Air  } ) end
  if debug then logging('finest', { 'takeOff(percAir, percRnwy, percHot)' , '    - percAir = ' .. percAir .. ' - percRnwy = ' .. percRnwy .. ' - percHot = ' .. percHot .. ' - percBox = ' .. percBox .. ' - typeTakeOff = ' .. typeTakeOff .. ' - ret = ' .. ret  } ) end
  if debug then logging('exit', 'takeOff(percAir, percRnwy, percHot)') end

  return ret

end







--- Restituisce un vettore contenente numenti da 1 a num_pos disposti casualmente
-- @param: num_pos il numero di posizioni da sorteggiare (max 30)
function defineRequestPosition(num_pos)

  local debug = false

  if debug then logging('enter', 'defineRequestPosition(num_pos)') end

  num_pos = num_pos or 1

  if num_pos > 30 then num_pos = 30 end
  if num_pos < 1 then num_pos = 1 end
  if debug then logging('finest', { 'defineRequestPosition(num_pos)' , 'num_pos = ' .. num_pos  } ) end
  local pos = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}
  local pos_f = {}

  for i = 1, num_pos do

    local b = math.random(num_pos-#pos_f)
    pos_f[ i ] = pos[ b ]
    table.remove( pos, b )
    if debug then logging('finest', { 'defineRequestPosition(num_pos)' , 'pos_f[' .. i .. '] = ' .. pos_f[ i ] .. ' - removed pos[' .. #pos_f .. '] = ' .. pos_f[#pos_f]  } ) end

  end

  if debug then logging('exit', 'defineRequestPosition(num_pos)') end

  return pos_f

end











-- Restituisce un vettore di num_wh elementi nel quale solo max_wh elementi sono true
--
function randomTrueFalseList(n, max_true)

  local gh = defineRequestPosition(n)

  local active_wh = {}

  for j = 1, n do

    local found = false

    for i = 1, max_true do

      if j == gh[i] then

        active_wh[j] = true
        found = true

      end

      if not found then active_wh[j] = false end

    end

  end

  if loggingLevel > 6 then

    for i = 1, n do

      logging('finest', { 'randomTrueFalseList(n, max_true)' , 'active_wh [ ' .. i .. ' ] = ' .. tostring( active_wh[ i ] ) } )

    end


  end

  return active_wh

end













--- Restituisce velocita' e altitudine comprese tra i paramentri della funzione
-- @param: min_vel, max_vel, min_alt, max_alt
function defineSpeedAndAltitude(min_vel, max_vel, min_alt, max_alt)

    local debug = false

    if debug then logging('enter', 'defineSpeedAndAltitude(min_vel, max_vel, min_alt, max_alt)') end

    max_vel = max_vel or 999
    min_vel = min_vel or max_vel

    max_alt = max_alt or 5000
    min_alt = min_alt or max_alt

    if min_vel < 0 or min_vel > 3000 then min_vel = 100 end
    if max_vel < 0 or max_vel > 3000 then max_vel = 200 end
    if min_alt < 10 or min_alt > 20000 then min_vel = 1000 end
    if max_alt < 10 or max_alt > 20000 then max_vel = 2000 end


    local speed = math.random( min_vel, max_vel )
    local altitude = math.random( min_alt, max_alt )

    if debug then logging('exit', 'defineSpeedAndAltitude(min_vel, max_vel, min_alt, max_alt)') end

    return speed, altitude

end



--- Restituisce i parametri necessari per configurare una BAI Mission di tipo target
-- @param: type_aircraft ('fighter_bomber', 'bomber', 'helicopter')
function calcParamForBAI(type_aircraft)

  local debug = false

  if debug then logging('enter', 'calcParamForBAI(type_aircraft)') end

  type_aircraft = type_aircraft or 'nil'

  local speed_patrol_max = 300
  local speed_patrol_min = 200
  local speed_attack = math.random(00, 300)
  local altitude_attack = math.random(500, 1000)
  local altitude_patrol_max = 3000
  local altitude_patrol_min = 1000

  if type_aircraft == 'fighter_bomber' then
    speed_patrol_max = 700
    speed_patrol_min = 500
    speed_attack = math.random(400, 600)
    altitude_attack = math.random(3000, 4000)
    altitude_patrol_max = 8000
    altitude_patrol_min = 5000

  elseif type_aircraft == 'bomber' then
    speed_patrol_max = 600
    speed_patrol_min = 500
    speed_attack = math.random(400, 500)
    altitude_attack = math.random(6000, 9000)
    altitude_patrol_max = 12000
    altitude_patrol_min = 7000

  else --hely
    logging('warning', { 'calcParamForBAI(type_aircraft)' , 'type_aircraft not found: ', type_aircraft} )
  end


  local attack_angle = math.random( 0 , 360 )
  local num_attack = math.random( 1 , 4 )

  local time_to_engage = math.random( 1 , 300 )
  local time_to_RTB = 3600


   -- 'AI.Task.WeaponExpend.ALL , AI.Task.WeaponExpend.FOUR, AI.Task.WeaponExpend.HALF, AI.Task.WeaponExpend.ONE, AI.Task.WeaponExpend.QUARTER, AI.Task.WeaponExpend.TWO'

  local num_weapon = AI.Task.WeaponExpend.QUARTER

  if num_attack == 1 then
    num_weapon = AI.Task.WeaponExpend.ALL

  elseif num_attack == 2 then
    num_weapon = AI.Task.WeaponExpend.HALF

  else
    -- se gli attacchi sono 3 li porta a 4 in modo da impostare un rilascio di weapon pari ad 1/4
      num_attack = 4

  end

  if debug then logging('finest', { 'calcParamForBAI(type_aircraft)' , 'speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB: ' .. speed_attack .. ' - ' .. altitude_attack .. ' - ' .. speed_patrol_min .. ' - ' .. altitude_patrol_min .. ' - ' .. speed_patrol_max .. ' - ' .. altitude_patrol_max .. ' - ' .. attack_angle  .. ' - ' .. num_attack .. ' - ' .. num_weapon .. ' - ' .. time_to_engage .. ' - ' .. time_to_RTB } ) end
  if debug then logging('exit', 'calcParamForBAI(type_aircraft)') end

  return speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB

end


function addGroupSet( targetGroupSet, groupSet )

  local debug = false

  if debug then logging('enter', 'addGroupSet(targetGroupSet, groupSet)') end

  for _, _group in pairs(groupSet:GetSet()) do

    local group = _group --Wrapper.Group#GROUP
    targetGroupSet:AddGroup(group)
    if debug then logging('finest', { 'addGroupSet(targetGroupSet, groupSet)' , 'added group: ' .. group:GetName() .. ' in set_group: ' .. targetGroupSet:GetObjectNames()} ) end

  end -- end for

  if debug then logging('exit', 'addGroupSet(targetGroupSet, groupSet)') end

end


function printGroupSet( groupSet )

  local names = 'Name for ' .. groupSet:GetObjectNames()

  for _, _group in pairs( groupSet:GetSet()) do

    local group = _group --Wrapper.Group#GROUP

    names = names .. ' - ' .. group:GetName()

  end -- end for

  return names

end




-- END UTILITY FUNCTION






















------------------------------------------------------------------------------    MISSION FUNCTIONS  -------------------------------------------------------------------------

-- Mission's use functions


-- Configure the detectionGroup with route and task
-- @param detectionGroup = dedicated group for detection
-- @param targetZone = destination zone for detection task
-- @param airbase = home airbase
-- @param altitude = route altitude
-- @param altitudeDetection + detection task altitude
-- @param speedPerc = speed route (perc of max speed)
function assignDetectionGroupTask(detectionGroup, targetZone, airbase, altitude, altitudeDetection, speedPerc )

    logging( 'enter', 'assignDetectionGroupTask()' )

    -- detectionGroup:StartUncontrolled()
    detectionGroup:OptionROTPassiveDefense()
    local ToCoord = targetZone:GetRandomCoordinate():SetAltitude( altitude )
    local HomeCoord = airbase:GetCoordinate():SetAltitude( altitude )
    local task = detectionGroup:TaskOrbitCircle( altitudeDetection, detectionGroup:GetSpeedMax() * speedPerc, ToCoord )
    local WayPoints = {}
    WayPoints[ 1 ] = airbase:GetCoordinate():WaypointAirTakeOffParking()
    WayPoints[ 2 ] = ToCoord:WaypointAirTurningPoint( nil, detectionGroup:GetSpeedMax() * speedPerc, { task }, "Orbiting for detection threats" )
    WayPoints[ 3 ] = HomeCoord:WaypointAirTurningPoint()
    WayPoints[ 4 ] = airbase:GetCoordinate():WaypointAirLanding()
    detectionGroup:Route( WayPoints )

    logging( 'exit', 'assignDetectionGroupTask()' )

end


-- Configure the detectionGroup with route and task
-- @param detectionGroup = dedicated group for detection
-- @param targetZone = destination zone for detection task
-- @param airbase = home airbase
-- @param altitude = route altitude
-- @param altitudeDetection + detection task altitude
-- @param speedPerc = speed route (perc of max speed)
function assignDetectionGroupSetTask(detectionGroupSet, targetZone, airbase, altitude, altitudeDetection, speedPerc )

    logging( 'enter', 'assignDetectionGroupSetTask()' )



    for _, _group in pairs(detectionGroupSet:GetSet()) do
      -- seleziona ogni gruppo appartenente al set


      local group = _group --Wrapper.Group#GROUP

      -- Start uncontrolled aircraft.
      group:StartUncontrolled()


      assignDetectionGroupTask(group, targetZone, airbase, altitude, altitudeDetection, speedPerc )

    end

    logging( 'exit', 'assignDetectionGroupSetTask()' )

end


--- Configure the AI-A2G Dispatcher
-- @param A2GDispatcher
-- @param defenceRadius
-- @param defenceReactivity
-- @param HQ
-- @param takeoff
-- @param landing
-- @param overhead
-- @param damageThrs
-- @param patrolLimit
-- @param tacticalDisplay
function configureAI_A2GDispatcher( A2GDispatcher, defenceRadius, defenceReactivity, HQ, takeoff, landing, overhead, damageThrs, patrolLimit, tacticalDisplay )

    logging( 'enter', 'configureAI_A2GDispatcher()' )

    tacticalDisplay = tacticalDisplay or false
    defenceReactivity = defenceReactivity or 'low'
    A2GDispatcher:SetTacticalDisplay( tacticalDisplay )
    A2GDispatcher:SetDefenseRadius( defenceRadius ) -- 50Km la cas vanno bene a 30 km, le sead  devono avere piu' aerei di attacco overhead=0.5 distanza boh, le bai la distanza deve essere alta: la ricognizione deve vedere i target lontani

    if defenceReactivity == 'low' then A2GDispatcher:SetDefenseReactivityLow()
    elseif defenceReactivity == 'medium' then A2GDispatcher:SetDefenseReactivityMedium()
    elseif defenceReactivity == 'high' then A2GDispatcher:SetDefenseReactivityHigh()
    else SetDefenseReactivityLow() end

    A2GDispatcher:AddDefenseCoordinate( HQ:GetName(), HQ:GetCoordinate() )
    A2GDispatcher:SetDefaultTakeoff( takeoff )
    A2GDispatcher:SetDefaultLanding( landing )
    A2GDispatcher:SetDefaultOverhead( overhead )
    A2GDispatcher:SetDefaultDamageThreshold( damageThrs )
    A2GDispatcher:SetDefaultPatrolLimit( patrolLimit )

    logging( 'exit', 'configureAI_A2GDispatcher()' )

end


--- A2GDispatcher Configuration to CAS mission execution
--  @param: A2GDispatcher
--  @param: squadronName =  name of the squadron
--  @param: takeOff =  type of takeoff
--  @param: landing  =  type of landing
--  @param: takeoffInterval  =  time distance from sequenzial takeoff
--  @param: overHead = ratio num_defenceAircraft/num_ground_threat
--  @param: minSpeed = min speed of mission
--  @param: maxSpeed = max speed of mission
--  @param: minAlt = min altitude of mission
--  @param: maxSpeed = max altitude of mission
function configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, takeoff, landing, takeoffInterval, overHead, minSpeed, maxSpeed, minAlt, maxAlt)

    logging( 'enter', 'configureAI_A2G_CAS_Mission()' )

    if squadronName == nil then logging('warning', { 'configureAI_A2G_CAS_Mission()' , 'squadronName is nil!! EXIT' } ) return end
    if A2GDispatcher == nil then logging('warning', { 'configureAI_A2G_CAS_Mission()' , 'A2GDispatcher is nil!! EXIT' } ) return end

    A2GDispatcher:SetSquadronCas( squadronName, minSpeed, maxSpeed, minAlt, maxAlt )

    if takeoff then A2GDispatcher:SetSquadronTakeoff( squadronName, takeoff ) end
    if landing then A2GDispatcher:SetSquadronLanding( squadronName, landing ) end
    if takeoffInterval then A2GDispatcher:SetSquadronTakeoffInterval( squadronName, takeoffInterval ) end -- dipende dal numero di slot disponibili: farp = 4, airbase = molti. Il tempo è calcola valutando 60 s necessari ad un aereo per liberare lo slot
    if overHead then A2GDispatcher:SetSquadronOverhead(squadronName, overHead) end


    logging( 'exit', 'configureAI_A2G_CAS_Mission()' )

end


--- A2GDispatcher Configuration to PATROL CAS mission execution
--  @param: A2GDispatcher
--  @param: squadronName =  name of the squadron
--  @param: targetZone = zone of target
--  @param: patrolInterval = ratio num_defenceAircraft/num_ground_threat
--  @param: minSpeed = min speed of mission
--  @param: maxSpeed = max speed of mission
--  @param: minAlt = min altitude of mission
--  @param: maxSpeed = max altitude of mission
function configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, targetZone, patrolInterval, minAlt, maxAlt, minSpeedRoute, maxSpeedRoute, minSpeedEngage, maxSpeedEngage, typeAltitude )

    logging( 'enter', 'configureAI_A2G_PATROL_CAS_Mission()' )

    if squadronName == nil then logging('warning', { 'configureAI_A2G_PATROL_CAS_Mission()' , 'squadronName is nil!! EXIT' } ) return end
    if A2GDispatcher == nil then logging('warning', { 'configureAI_A2G_PATROL_CAS_Mission()' , 'A2GDispatcher is nil!! EXIT' } ) return end

    patrolInterval = patrolInterval or 1
    minAlt = minAlt or 1000
    maxAlt = maxAlt or 2000
    minSpeedRoute = minSpeedRoute or 400
    maxSpeedRoute = maxSpeedRoute or 500
    minSpeedEngage = minSpeedEngage or 400
    maxSpeedEngage =  maxSpeedEngage or 500
    typeAltitude = typeAltitude or 'RADIO'

    A2GDispatcher:SetSquadronCasPatrol( squadronName, targetZone, minAlt, maxAlt, minSpeedRoute, maxSpeedRoute, minSpeedEngage, maxSpeedEngage, typeAltitude )
    A2GDispatcher:SetSquadronCasPatrolInterval(squadronName, patrolInterval)

    logging( 'exit', 'configureAI_A2G_PATROL_CAS_Mission()' )

end



--- A2GDispatcher Configuration to BAI mission execution
--  @param: A2GDispatcher
--  @param: squadronName =  name of the squadron
--  @param: takeOff =  type of takeoff
--  @param: landing  =  type of landing
--  @param: takeoffInterval  =  time distance from sequenzial takeoff
--  @param: overHead = ratio num_defenceAircraft/num_ground_threat
--  @param: minSpeed = min speed of mission
--  @param: maxSpeed = max speed of mission
--  @param: minAlt = min altitude of mission
--  @param: maxSpeed = max altitude of mission
function configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, takeoff, landing, takeoffInterval, overHead, minSpeed, maxSpeed, minAlt, maxAlt)

    logging( 'enter', 'configureAI_A2G_BAI_Mission()' )

    if squadronName == nil then logging('warning', { 'configureAI_A2G_BAI_Mission()' , 'squadronName is nil!! EXIT' } ) return end
    if A2GDispatcher == nil then logging('warning', { 'configureAI_A2G_BAI_Mission()' , 'A2GDispatcher is nil!! EXIT' } ) return end

    A2GDispatcher:SetSquadronBai( squadronName, minSpeed, maxSpeed, minAlt, maxAlt )

    if takeoff then A2GDispatcher:SetSquadronTakeoff( squadronName, takeoff ) end
    if landing then A2GDispatcher:SetSquadronLanding( squadronName, landing ) end
    if takeoffInterval then A2GDispatcher:SetSquadronTakeoffInterval( squadronName, takeoffInterval ) end -- dipende dal numero di slot disponibili: farp = 4, airbase = molti. Il tempo è calcola valutando 60 s necessari ad un aereo per liberare lo slot
    if overHead then A2GDispatcher:SetSquadronOverhead(squadronName, overhead) end


    logging( 'exit', 'configureAI_A2G_BAI_Mission()' )

end


--- A2GDispatcher Configuration to PATROL BAI mission execution
--  @param: A2GDispatcher
--  @param: squadronName =  name of the squadron
--  @param: targetZone = zone of target
--  @param: patrolInterval = ratio num_defenceAircraft/num_ground_threat
--  @param: minSpeed = min speed of mission
--  @param: maxSpeed = max speed of mission
--  @param: minAlt = min altitude of mission
--  @param: maxSpeed = max altitude of mission
function configureAI_A2G_PATROL_BAI_Mission( A2GDispatcher, squadronName, targetZone, patrolInterval, minAlt, maxAlt, minSpeedRoute, maxSpeedRoute, minSpeedEngage, maxSpeedEngage, typeAltitude )

    logging( 'enter', 'configureAI_A2G_PATROL_BAI_Mission()' )

    if squadronName == nil then logging('warning', { 'configureAI_A2G_PATROL_BAI_Mission()' , 'squadronName is nil!! EXIT' } ) return end
    if A2GDispatcher == nil then logging('warning', { 'configureAI_A2G_PATROL_BAI_Mission()' , 'A2GDispatcher is nil!! EXIT' } ) return end

    patrolInterval = patrolInterval or 1
    minAlt = minAlt or 1000
    maxAlt = maxAlt or 2000
    minSpeedRoute = minSpeedRoute or 400
    maxSpeedRoute = maxSpeedRoute or 500
    minSpeedEngage = minSpeedEngage or 400
    maxSpeedEngage =  maxSpeedEngage or 500
    typeAltitude = typeAltitude or 'RADIO'

    A2GDispatcher:SetSquadronBaiPatrol( squadronName, targetZone, minAlt, maxAlt, minSpeedRoute, maxSpeedRoute, minSpeedEngage, maxSpeedEngage, typeAltitude )
    A2GDispatcher:SetSquadronBaiPatrolInterval(squadronName, patrolInterval)

    logging( 'exit', 'configureAI_A2G_PATROL_BAI_Mission()' )

end



--- A2GDispatcher Configuration to SEAD mission execution
--  @param: A2GDispatcher
--  @param: squadronName =  name of the squadron
--  @param: takeOff =  type of takeoff
--  @param: landing  =  type of landing
--  @param: takeoffInterval  =  time distance from sequenzial takeoff
--  @param: overHead = ratio num_defenceAircraft/num_ground_threat
--  @param: minSpeed = min speed of mission
--  @param: maxSpeed = max speed of mission
--  @param: minAlt = min altitude of mission
--  @param: maxSpeed = max altitude of mission
function configureAI_A2G_SEAD_Mission( A2GDispatcher, squadronName, takeoff, landing, takeoffInterval, overHead, minSpeed, maxSpeed, minAlt, maxAlt)

    logging( 'enter', 'configureAI_A2G_SEAD_Mission()' )

    if squadronName == nil then logging('warning', { 'configureAI_A2G_SEAD_Mission()' , 'squadronName is nil!! EXIT' } ) return end
    if A2GDispatcher == nil then logging('warning', { 'configureAI_A2G_SEAD_Mission()' , 'A2GDispatcher is nil!! EXIT' } ) return end

    A2GDispatcher:SetSquadronSead( squadronName, minSpeed, maxSpeed, minAlt, maxAlt )

    if takeoff then A2GDispatcher:SetSquadronTakeoff( squadronName, takeoff ) end
    if landing then A2GDispatcher:SetSquadronLanding( squadronName, landing ) end
    if takeoffInterval then A2GDispatcher:SetSquadronTakeoffInterval( squadronName, takeoffInterval ) end -- dipende dal numero di slot disponibili: farp = 4, airbase = molti. Il tempo è calcola valutando 60 s necessari ad un aereo per liberare lo slot
    if overHead then A2GDispatcher:SetSquadronOverhead(squadronName, overhead) end


    logging( 'exit', 'configureAI_A2G_CAS_Mission()' )

end



--- A2GDispatcher Configuration to PATROL CAS mission execution
--  @param: A2GDispatcher
--  @param: squadronName =  name of the squadron
--  @param: targetZone = zone of target
--  @param: patrolInterval = ratio num_defenceAircraft/num_ground_threat
--  @param: minSpeed = min speed of mission
--  @param: maxSpeed = max speed of mission
--  @param: minAlt = min altitude of mission
--  @param: maxSpeed = max altitude of mission
function configureAI_A2G_PATROL_SEAD_Mission( A2GDispatcher, squadronName, targetZone, patrolInterval, minAlt, maxAlt, minSpeedRoute, maxSpeedRoute, minSpeedEngage, maxSpeedEngage, typeAltitude )

    logging( 'enter', 'configureAI_A2G_PATROL_SEAD_Mission()' )

    if squadronName == nil then logging('warning', { 'configureAI_A2G_PATROL_SEAD_Mission()' , 'squadronName is nil!! EXIT' } ) return end
    if A2GDispatcher == nil then logging('warning', { 'configureAI_A2G_PATROL_SEAD_Mission()' , 'A2GDispatcher is nil!! EXIT' } ) return end

    patrolInterval = patrolInterval or 1
    minAlt = minAlt or 1000
    maxAlt = maxAlt or 2000
    minSpeedRoute = minSpeedRoute or 400
    maxSpeedRoute = maxSpeedRoute or 500
    minSpeedEngage = minSpeedEngage or 400
    maxSpeedEngage =  maxSpeedEngage or 500
    typeAltitude = typeAltitude or 'RADIO'

    A2GDispatcher:SetSquadronSeadPatrol( squadronName, targetZone, minAlt, maxAlt, minSpeedRoute, maxSpeedRoute, minSpeedEngage, maxSpeedEngage, typeAltitude )
    A2GDispatcher:SetSquadronSeadPatrolInterval(squadronName, patrolInterval)

    logging( 'exit', 'configureAI_A2G_PATROL_SEAD_Mission()' )

end




--- SUPPRESSION

--- applica la Functionality SUPPRESSION al group passato come parametro
-- @param: group:         single group
-- @param: retreatZone:   the retreat zone
-- @param: fallback:      if true active fallBack action during enemy attack
-- @param: takeCover:     if true active takeCover action during enemy attack
-- @param: delay:         suppression start delay
function suppressionGroup(group, retreatZone, fallBack, takeCover, delay)

    --SUPPRESSION.SetSuppressionTime() can be used to set the time a goup gets suppressed.
    --SUPPRESSION.SetRetreatZone() sets the retreat zone and enables the possiblity for the group to retreat.
    --SUPPRESSION.SetFallbackDistance() sets a value how far the unit moves away from the attacker after the fallback event.
    --SUPPRESSION.SetFallbackWait() sets the time after which the group resumes its mission after a FallBack event.
    --SUPPRESSION.SetTakecoverWait() sets the time after which the group resumes its mission after a TakeCover event.
    --SUPPRESSION.SetTakecoverRange() sets the radius in which hideouts are searched.
    --SUPPRESSION.SetTakecoverPlace() explicitly sets the place where the group will run at a TakeCover event.
    --SUPPRESSION.SetMinimumFleeProbability() sets the minimum probability that a group flees (FallBack or TakeCover) after a hit. Note taht the probability increases with damage.
    --SUPPRESSION.SetMaximumFleeProbability() sets the maximum probability that a group flees (FallBack or TakeCover) after a hit. Default is 90%.
    --SUPPRESSION.SetRetreatDamage() sets the damage a group/unit can take before it is ordered to retreat.
    --SUPPRESSION.SetRetreatWait() sets the time a group waits in the retreat zone after a retreat.
    --SUPPRESSION.SetDefaultAlarmState() sets the alarm state a group gets after it becomes CombatReady again.
    --SUPPRESSION.SetDefaultROE() set the rules of engagement a group gets after it becomes CombatReady again.
    --SUPPRESSION.FlareOn() is mainly for debugging. A flare is fired when a unit is hit, gets suppressed, recovers, dies.
    --SUPPRESSION.SmokeOn() is mainly for debugging. Puts smoke on retreat zone, hideouts etc.
    --SUPPRESSION.MenuON() is mainly for debugging. Activates a radio menu item where certain functions like retreat etc. can be triggered manually.


    local debug = false

    if debug then logging('enter', 'suppressionGroup(group, retreatZone, fallBack, takeCover, delay)') end

    delay = delay or 1
    fallBack = fallBack or false
    takeCover = takeCover or false

    if nil == group or not group:IsGround() then logging('warning', { 'suppressionGroup(group, retreatZone, fallBack, takeCover, delay)' , 'group is nil or not ground unit: Suppression dont defined! Exit' } ) return nil end


    local groupSuppression = SUPPRESSION:New(group)
    groupSuppression:Fallback(fallBack)
    groupSuppression:Takecover(takeCover)

    groupSuppression:__Start(delay)

    if debug then logging('exit', 'suppressionGroup(group, retreatZone, fallBack, takeCover, delay)') end

    return

end -- end function


  --- applica la Functionality SUPPRESSION al groupset passato come parametro
  -- @param: group:         single group
  -- @param: retreatZone:   the retreat zone
  -- @param: fallback:      if true active fallBack action during enemy attack
  -- @param: takeCover:     if true active takeCover action during enemy attack
  -- @param: delay:         suppression start delay
function suppressionGroupSet(groupSet, retreatZone, fallBack, takeCover, delay)

    local debug = false

    if debug then logging('enter', 'suppressionGroupSet(group, retreatZone, fallBack, takeCover, delay)') end

    delay = delay or 1
    fallBack = fallBack or false
    takeCover = takeCover or false

    if nil == group or not group:IsGround() then logging('warning', { 'suppressionGroupSet(group, retreatZone, fallBack, takeCover, delay)' , 'group is nil or not ground unit: Suppression dont defined! Exit' } ) return nil end


    for _, _group in pairs(groupSet:GetSet()) do

      local group = _group --Wrapper.Group#GROUP
      suppressionGroup(group, retreatZone, fallBack, takeCover, delay)

    end -- end for

    if debug then logging('exit', 'suppressionGroupSet(group, retreatZone, fallBack, takeCover, delay)') end

    return

end -- end function










--- DETECTION


-- detectionAREAS

--- Create a detection zone based on a group of detector units.
--  The detector group is created utilizing detector units with name formed with prefix_detector.
--
--
-- @param detectionSetGroup: set of detection GROUP
-- @param range:  distanza massima di valutazione se due o piu' target appartengono ad uno stesso gruppo (30km x aerei modern, 10 km per ww2, 1 km per ground)
-- @param filterCategories: set of filter for of unit: nil all category will be detected
-- @param distanceProbability:  probability of detection @ 10000 m (0 - 1)
-- @param alfaProbability:  probability of detection @ 0 degree of delta respect front visual detection (0 - 1)
-- @param zoneProbability: array of a The ZONE_BASE object and a ZoneProbability pair..: ex: { { Zone1, 0.1 }, { Zone2, 0.1 } }
-- @param typeDetection: set of sensor detector: nil for all sensor activation (visual, radar, optical, irst, rwr, dlink)
-- @return DETECTION_AREAS
-- function detection( prefix_detector, range, categories, distanceProbability, alphaProbability, zoneProbability, typeDetection )
function detectionAREAS( detectionSetGroup, range, filterCategories, distanceProbability, alphaProbability, zoneProbability, typeDetection )

    local debug = false

    if debug then logging('enter', 'detectionAREAS( detectionSetGroup, ... )') end

    if range == nil then logging('warning', { 'DetectionAREAS( detectionSetGroup, ... )' , 'range is nil: DetectionAREAS dont defined' } ) return nil end

    if detectionSetGroup == nil then logging('warning', { 'DetectionAREAS( detectionSetGroup, ... )' , 'detectionSetGroup is nil: DetectionAREAS dont defined' } ) return nil end

    local Detection = DETECTION_AREAS:New( detectionSetGroup, range )


  -- Filter Category
  -- Unit.Category.AIRPLANE
  -- Unit.Category.GROUND_UNIT
  -- Unit.Category.HELICOPTER
  -- Unit.Category.SHIP
  -- Unit.Category.STRUCTURE
  -- DetectionObject:FilterCategories( { Unit.Category.AIRPLANE, Unit.Category.HELICOPTER } )
  if filterCategories ~= nil then Detection:FilterCategories(filterCategories) end

  -- when you first use the DETECTION derived classes, that you don't use these filters. Only when you experience unrealistic behaviour in your missions, these filters could be applied
  if distanceProbability ~= nil then Detection:SetDistanceProbability(distanceProbability) end
  if alphaProbability ~= nil then Detection:SetAlphaAngleProbability(alphaProbability) end
  if zoneProbability ~= nil then Detection:SetZoneProbability(zoneProbability) end -- for set probability refer at cloudy zone
  -- zoneProbability: Typically, this kind of filter would be applied for very specific areas were a detection needs to be very realisting for AI not to detect so easily targets within a forrest or village rich area.

  -- type of detection
  -- By default, detection will return detected objects with all the detection sensors available
  if typeDetection ~= nil then

      for _, type in pairs(typeDetection) do

          if type == 'visual' then Detection:InitDetectVisual(true)

          elseif type == 'optical' then Detection:InitDetectOptical(true)

          elseif type == 'radar' then Detection:InitDetectRadar(true)

          elseif type == 'irst' then Detection:InitDetectIRST(true)

          elseif type == 'rwr' then Detection:InitDetectRWR(true)

          elseif type == 'dlink' then Detection:InitDetectDLINK(true)

          else

              logging('warning', { 'detectionAREAS( prefix_detector, range, categories, distanceProbability, typeDetection )' , 'detectionType not recognized: ' .. type  } )

          end -- end if then else

      end -- end for

  end

  if debug then logging('exit', 'detectionAREAS( detectionSetGroup, ... )') end

  return Detection

end



-- detectionUNITS

--- Create a detection zone based on a group of detector units.
--  The detector group is created utilizing detector units with name formed with prefix_detector.
--
-- @param detectionSetGroup: set of detection GROUP
-- @param range:  range max of detection target
-- @param filterCategories: set of filter for of unit: nil all category will be detected
-- @param distanceProbability:  probability of detection @ 10000 m (0 - 1)
-- @param alfaProbability:  probability of detection @ 0 degree of delta respect front visual detection (0 - 1)
-- @param zoneProbability: array of a The ZONE_BASE object and a ZoneProbability pair..: ex: { { Zone1, 0.1 }, { Zone2, 0.1 } }
-- @param typeDetection: set of sensor detector: nil for all sensor activation (visual, radar, optical, irst, rwr, dlink)
-- @return DETECTION_UNITS
-- function detection( prefix_detector, range, categories, distanceProbability, alphaProbability, zoneProbability, typeDetection )
function detectionUNITS( detectionSetGroup, range, filterCategories, distanceProbability, alphaProbability, zoneProbability, typeDetections )

  local debug = false

  if debug then logging('enter', 'detectionUNITS( detectionSetGroup, ... )') end

  if range == nil then logging('warning', { 'DetectionUNITS( detectionSetGroup, ... )' , 'range is nil: DetectionUNITS dont defined' } ) return nil end

  if detectionSetGroup == nil then logging('warning', { 'detectionUNITS( detectionSetGroup, ... )' , 'detectionSetGroup is nil: DetectionUNITS dont defined' } ) return nil end

  local Detection = DETECTION_UNITS:New( detectionSetGroup )


  if range ~= nil then Detection:SetAcceptRange( range ) end

  -- Filter Category
  -- Unit.Category.AIRPLANE
  -- Unit.Category.GROUND_UNIT
  -- Unit.Category.HELICOPTER
  -- Unit.Category.SHIP
  -- Unit.Category.STRUCTURE
  -- DetectionObject:FilterCategories( { Unit.Category.AIRPLANE, Unit.Category.HELICOPTER } )
  if filterCategories ~= nil then Detection:FilterCategories(filterCategories) end

  -- when you first use the DETECTION derived classes, that you don't use these filters. Only when you experience unrealistic behaviour in your missions, these filters could be applied
  if distanceProbability ~= nil then Detection:SetDistanceProbability(distanceProbability) end

  if alphaProbability ~= nil then Detection:SetAlphaAngleProbability(alphaProbability) end

  if zoneProbability ~= nil then Detection:SetZoneProbability(zoneProbability) end -- for set probability refer at cloudy zone
  -- zoneProbability: Typically, this kind of filter would be applied for very specific areas were a detection needs to be very realisting for AI not to detect so easily targets within a forrest or village rich area.


  -- GetDetectedItemByIndex(Index)
  -- GetDetectedUnitTypeName(DetectedUnit)

  -- type of detection
  -- By default, detection will return detected objects with all the detection sensors available
  if typeDetections ~= nil then

      for _, type in pairs(typeDetections) do

          if type == 'visual' then Detection:InitDetectVisual(true)

          elseif type == 'optical' then Detection:InitDetectOptical(true)

          elseif type == 'radar' then Detection:InitDetectRadar(true)

          elseif type == 'irst' then Detection:InitDetectIRST(true)

          elseif type == 'rwr' then Detection:InitDetectRWR(true)

          elseif type == 'dlink' then Detection:InitDetectDLINK(true)

          else

              logging('warning', { 'detectionAREAS( prefix_detector, range, categories, distanceProbability, typeDetection )' , 'detectionType not recognized: ' .. typeDetections  } )

          end -- end if then else

      end -- end for

  end -- end if

  if debug then logging('exit', 'detectionUNITS( detectionSetGroup, ... )') end

  return Detection

end







---  Detection dedicata alla AI_A2A
-- @param prefix_detector: il prefisso degli EWR o AWACS utilizzati per la detection
-- @param range: il raggio di valutazione se un insieme di aerei appartiene ad un singolo gruppo
-- @param filterCategories:
-- @param distanceProbability:
-- @param alphaProbability:
-- @param zoneProbability:
-- @param typeDetection:
function detectionAI_A2A(prefix_detector, range, filterCategories, distanceProbability, alphaProbability, zoneProbability, typeDetection )

    local debug = false

    if debug then logging('enter', ' detectionAI_A2A(prefix_detector, ... )') end

    local DetectionSetGroup = SET_GROUP:New() -- crea ilk set dei gruppi detection (probabilmente devono essere già attivi in ME: vedi gli EWR)
    DetectionSetGroup:FilterPrefixes( prefix_detector )
    DetectionSetGroup:FilterStart()
    local detection = detectionAREAS( DetectionSetGroup, range, filterCategories, distanceProbability, alphaProbability, zoneProbability, typeDetection )

    if debug then logging('exit', ' detectionAI_A2A(prefix_detector, ... )') end

    return detection

end



--- Gestisce le missioni AWACS
-- fornisce un sistema di rilevamento AWACS
-- al momento è limitato alla comunicazione dei rilevamenti mediante un commandCenter
-- @param awacsGroup: il gruppo generato dalla warehouse che effettua l'awacs
-- @param commandCenter: il command center per le comuncazioni
-- @param rejectedZone: il set di zone da escludere nella detection { ZoneReject1, ZoneReject2 }
function activeAWACS( awacsSetGroup, home, commandCenter, rejectedZone, battleZone, awacsAltitude, toHomeAltitude)

    local debug = false
    local messageActivation = false

    toHomeAltitude = toHomeAltitude or 5000
    awacsAltitude = awacsAltitude or 5000

    if debug then logging('enter', 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )') end

    if awacsSetGroup == nil then logging('warning', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'awacsSetGroup is nil: Exit!' } ) return nil end

    if commandCenter == nil then logging('warning', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'commandCenter is nil: Exit!' } ) return nil end

    if battleZone == nil then logging('warning', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'battleZone is nil: Exit!' } ) return nil end

    if debug then logging('finest', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'awacsSetGroup = ' .. awacsSetGroup:GetObjectNames() ..  '  -  commandCenter = ' .. commandCenter:GetName() .. ' - battleZone: ' .. battleZone:GetName() .. ' - awacsAltitude: ' .. awacsAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude } ) end


    --- NOTA:  devi utilizzare un setGroup di AWAC già prodotto dalla warehouse con prefisso opportuno



    -- Target coordinate!
    local ToCoord = battleZone:GetCoordinate():SetAltitude(awacsAltitude)
    -- Home coordinate.
    local HomeCoord = home:GetCoordinate():SetAltitude(toHomeAltitude)

    for _,_group in pairs(awacsSetGroup:GetSet()) do

          local group = _group --Wrapper.Group#GROUP

          -- Start uncontrolled aircraft.
          group:StartUncontrolled()
          group:OptionROEHoldFire()
          group:EnRouteTaskAWACS()



          -- IL TASK e' NELLA CLASSE WRAPPER CONTROLLABLE

          --local task = group:TaskHoldPosition(3600) -- 1h
          local task = group:TaskOrbitCircle(awacsAltitude, group:GetSpeedMax() * 0.5, ToCoord)

          -- Define waypoints.
          local WayPoints = {}

          -- Take off position.
          WayPoints[1] = home:GetCoordinate():WaypointAirTakeOffParking()
          -- Begin bombing run 20 km south of target.
          WayPoints[2] = ToCoord:WaypointAirTurningPoint(nil, group:GetSpeedMax() * 0.7, {task}, "Awacs action!")
          -- Return to base.
          WayPoints[3] = HomeCoord:WaypointAirTurningPoint()
          -- Land at homebase. Bombers are added back to stock and can be employed in later assignments.
          WayPoints[4] = home:GetCoordinate():WaypointAirLanding()

          -- Route bombers.
          group:Route(WayPoints)

    end -- end for



    --activeAWACS( awacsSetGroup, battleZone, 1 )
    logging('finest', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'Execute go to zone' } )

    -- The enemy is approaching.
    --
    -- # Test cases:
    --
    -- 1. Observe the detection reporting of both the Recce.
    -- 2. Eventually all units should be detected by both Recce.

    -- detectionAREAS( detectionSetGroup, range, filterCategories, distanceProbability, alphaProbability, zoneProbability, typeDetection )
    local AwacsDetection = detectionAREAS( awacsSetGroup, 50000, { Unit.Category.AIRPLANE, Unit.Category.HELICOPTER }, nil, nil, nil, {'radar'} )


    if debug then

      if nil ~= AwacsDetection then
        logging('finest', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'AwacsDetection for awacsSetGroup is active' } )

      else
        logging('warning', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'AwacsDetection for awacsSetGroup is nil: activeAWACS in nil' } ) return nil

      end

    end

    if rejectedZone ~= nil then AwacsDetection:SetRejectZones( rejectedZone ) end

    AwacsDetection:Start()


    if messageActivation then

        --- OnAfter Transition Handler for Event Detect.
        -- @param Functional.Detection#DETECTION_UNITS self
        -- @param #string From The From State string.
        -- @param #string Event The Event string.
        -- @param #string To The To State string.
        function AwacsDetection:OnAfterDetect(From,Event,To)

          if debug then logging('finest', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'AWACS: Detect!' } ) end

          local DetectionReport = AwacsDetection:DetectedReportDetailed()

          if DetectionReport then

            commandCenter:MessageToCoalition( DetectionReport, 15, "AWACS: Detect!" )

          else

            commandCenter:MessageToCoalition( "AWACS: Detect! But report not avalaible" )

          end

        end-- end function AwacsDetection:OnAfterDetect(From,Event,To)

    end -- if messageActivation


    if debug then logging('exit', 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )') end

end -- end function activeAWACS( awacsSetGroup, commandCenter )



--- Gestisce le missioni JTAC
-- fornisce un sistema di rilevamento complementare alla detection utulizzazta in AI.A2A
-- controllo delle azioni aeree a supporto della manovra terrestre
-- @param awacsGroup: il gruppo generato dalla warehouse che effettua l'awacs
-- @param hq: l'HQ
function activeJTAC( type, home, jtacSetGroup, commandCenter, rejectedZone, battleZone)

    local debug = false

    local messageActivation = false

    if debug then logging('enter', 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )') end

    if jtacSetGroup == nil then logging('warning', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'jtacSetGroup is nil. Exit' } ) return nil end

    if type == nil then logging('warning', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'type is nil. Exit' } ) return nil end

    if battleZone == nil then logging('warning', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'battleZone is nil. Exit' } ) return nil end

    if commandCenter == nil then logging('warning', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'commandCenter is nil. Exit' } ) return nil end

    if debug then logging('finest', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'jtacSetGroup = ' .. jtacSetGroup:GetObjectNames() .. 'type = ' .. type .. '  -  commandCenter = ' .. commandCenter:GetName() .. ' - battleZone: ' .. battleZone:GetName() } ) end

    local ToCoord = battleZone:GetRandomCoordinate()
    -- Home coordinate.
    local HomeCoord=home:GetCoordinate()


    -- go to battleZone
    if type =='ground' then --activeGO_TO_ZONE_GROUND( jtacSetGroup, battleZone, false, 1 )

      for _, _group in pairs(jtacSetGroup:GetSet()) do
        -- seleziona ogni gruppo appartenente al set


        local group = _group --Wrapper.Group#GROUP
        --group:StartUncontrolled()

        group:EnRouteTaskEWR()

        -- Route group to Battle zone.

        local groupCoord = group:GetCoordinate()
        local route, length, exist = groupCoord:GetPathOnRoad( ToCoord )

        if debug then logging('finest', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone, battleZone )' , 'routeToRoad exist = ' .. tostring(exist) .. '  -  length = ' .. tostring(length) } ) end


        if exist then

          if debug then logging('finest', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone, battleZone )' , 'routeToRoad' } ) end
          -- Ottimizzazione: evita il ricalcolo della route. Cmq dai un occhiata a Moose group:RouteGroundOnRoad per una eventuale modifica
          -- group:RoutePush( route )
          group:RouteGroundOnRoad( ToCoord, group:GetSpeedMax() )

        else

          if debug then logging('finest', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone, battleZone )' , 'execute routeToGround' } ) end
          group:RouteGroundTo( ToCoord, group:GetSpeedMax() )

        end -- end if then

        --if debug then logging('finest', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone, battleZone )' , 'task = '.. task } ) end

      end -- end for


    elseif type =='air' then

      local altitude = math.random(300, 1000)
      ToCoord:SetAltitude(altitude)
      HomeCoord:SetAltitude(1000)


      for _, _group in pairs(jtacSetGroup:GetSet()) do

            local group = _group --Wrapper.Group#GROUP

            -- Start uncontrolled aircraft.
            group:StartUncontrolled()
            group:OptionROEHoldFire()
            group:EnRouteTaskAWACS()

            --local task = group:TaskHoldPosition(1800) -- 30'
            local task = group:TaskOrbitCircle(altitude, group:GetSpeedMax() * 0.5, ToCoord)


            -- Define waypoints.
            local WayPoints = {}

            -- Take off position.
            WayPoints[1] = home:GetCoordinate():WaypointAirTakeOffParking()
            -- Begin bombing run 20 km south of target.
            WayPoints[2] = ToCoord:WaypointAirTurningPoint(nil, group:GetSpeedMax(), {task}, "JTAC action!")
            -- Return to base.
            WayPoints[3] = HomeCoord:WaypointAirTurningPoint()
            -- Land at homebase. Bombers are added back to stock and can be employed in later assignments.
            WayPoints[4] = home:GetCoordinate():WaypointAirLanding()

            -- Route bombers.
            group:Route(WayPoints)

      end -- end for

    else
        logging('warning', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'type not found. Exit' } ) return nil
    end


    --- NOTA:  devi utilizzare un setGroup di JTAC già prodotto dalla warehouse con prefisso opportuno


    -- Filter Category
    -- Unit.Category.AIRPLANE
    -- Unit.Category.GROUND_UNIT
    -- Unit.Category.HELICOPTER
    -- Unit.Category.SHIP
    -- Unit.Category.STRUCTURE

    -- detectionAREAS( detectionSetGroup, range, filterCategories, distanceProbability, alphaProbability, zoneProbability, typeDetection )
    local RecceDetection = detectionUNITS( jtacSetGroup, 3000, { Unit.Category.GROUND_UNIT }, nil, nil, nil, {'visual','optical', 'irst'} )


    if debug then

      if nil ~= RecceDetection then
        logging('finest', { 'activeJTAC( awacsSetGroup, commandCenter, rejectedZone )' , 'RecceDetection for jtacSetGroup is active' } )

      else
        logging('warning', { 'activeJTAC( awacsSetGroup, commandCenter, rejectedZone )' , 'RecceDetection for jtacSetGroup is nil: activeJTAC in nil' } ) return nil

      end

    end


    if rejectedZone ~= nil then RecceDetection:SetRejectZones( rejectedZone ) end

    RecceDetection:Start()


    if messageActivation then

        --- OnAfter Transition Handler for Event Detect.
        -- @param Functional.Detection#DETECTION_UNITS self
        -- @param #string From The From State string.
        -- @param #string Event The Event string.
        -- @param #string To The To State string.
        function RecceDetection:OnAfterDetect(From,Event,To)

          if debug then logging('finest', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'JTAC: Detect!' } ) end

          local DetectionReport = RecceDetection:ReportSummary()

          commandCenter:MessageToCoalition( DetectionReport, 15, "JTAC: Detect!" )

        end-- end function RecceDetection:OnAfterDetect(From,Event,To)

      end -- if messageActivation



    if debug then logging('exit', 'activeAWACS( type, awacsSetGroup, commandCenter )') end


end





function designateTarget(recceSetGroup, attackSetGroup, commanCenter, Detection)

    RecceDesignation = DESIGNATE:New( CC, RecceDetection, AttackSet )

    -- This sets the threat level prioritization on
    RecceDesignation:SetThreatLevelPrioritization( true )

    -- Set the possible laser codes.
    RecceDesignation:GenerateLaserCodes()

    RecceDesignation:AddMenuLaserCode( 1113, "Lase with %d for Su-25T" )

    RecceDesignation:AddMenuLaserCode( 1680, "Lase with %d for A-10A" )

    -- Start the detection process in 5 seconds.
    RecceDesignation:__Detect( -5 )


end





--- Configure the AI-A2A Dispatcher
-- @param A2GDispatcher
-- @param defenceRadius
-- @param defenceReactivity
-- @param HQ
-- @param takeoff
-- @param landing
-- @param overhead
-- @param damageThrs
-- @param patrolLimit
-- @param tacticalDisplay
function configureAI_A2ADispatcher( A2ADispatcher, engage_radius, gci_radius, takeoff, landing, overhead, damageThrs, tacticalDisplay )

    logging( 'enter', 'configureAI_A2ADispatcher()' )

    tacticalDisplay = tacticalDisplay or false

    -- Set the ground intercept radius as the radius to ground control intercept detected targets from the nearest airbase.
    A2ADispatcher:SetGciRadius( gci_radius )
    -- Initialize the dispatcher, setting up a radius of 50km where any airborne friendly without an assignment within 50km radius from a detected target, will engage that target.
    A2ADispatcher:SetEngageRadius( engage_radius )
    A2ADispatcher:SetTacticalDisplay( tacticalDisplay )

    A2ADispatcher:SetDefaultTakeoff( takeoff )
    A2ADispatcher:SetDefaultLanding( landing )
    A2ADispatcher:SetDefaultOverhead( overhead )
    A2ADispatcher:SetDefaultDamageThreshold( damageThrs )


    logging( 'exit', 'configureAI_A2ADispatcher()' )

end






-- ASSIGN CAP

--  assign_cap viene modificato in base alla situazione definendo le missioni CAP in base alle zone tattiche definite.

--- Setting up and authorize CAP mission for Squadron assigned at specific airbase.
--
--
--  @param cap_zone:  specific cap zone name created in ME
--  @param cap_name:  cap name
--  @param alt_min: minimum CAP altitude
--  @param alt_max: maximum CAP altitude
--  @param speed_min_patrol: minimum patrol CAP speed
--  @param speed_max_patrol: maximum patrol CAP speed
--  @param speed_min_engage: minimum engage CAP speed
--  @param speed_max_engage: maximum engage CAP speed
--  @param num_cap_squad: number of squad assigned for single CAP mission
--  @param min_time_new_cap: minimum time for spawn a CAP mission
--  @param max_time_new_cap: maximum time for spawn a CAP mission
--  @param probability: not used
--  @param take_off: AI_A2A_DISPATCHER.<*>  (  AI_A2A_DISPATCHER.Takeoff.Air/Runway/Hot/Cold  )
--  @param landing:  AI_A2A_DISPATCHER.<*> ( AI_A2A_DISPATCHER.Landing.AtRunway/NearAirbase/AtEngineShutdown )
--  @param A2ADispatcher:  AI_A2A_DISPATCHER
function assign_cap ( cap_zone, cap_name, alt_min, alt_max, speed_min_patrol, speed_max_patrol,
                      speed_min_engage, speed_max_engage, num_cap_squad, min_time_new_cap, max_time_new_cap,
                      probability, take_off, landing, A2ADispatcher )

  local zone = ZONE_POLYGON:New( cap_zone, GROUP:FindByName( cap_zone ) )
  A2ADispatcher:SetSquadronCap( cap_name, zone, alt_min, alt_max, speed_min_patrol, speed_max_patrol, speed_min_engage, speed_max_engage )
  A2ADispatcher:SetSquadronCapInterval( cap_name, num_cap_squad, min_time_new_cap, max_time_new_cap, probability )
  A2ADispatcher:SetSquadronTakeoff( cap_name, take_off )
  A2ADispatcher:SetSquadronLanding( cap_name, landing )


end


-- ASSIGN GCI

--  assign_gci viene modificato in base alla situazione definendo le missioni GCI in base alle zone tattiche relative alle basi aeree e alle zone strategiche definite.


--- Setting up and authorize GCI mission for Squadrons assigned at specific airbase.
--
--
--  @param airbase_name:  airbase name
--  @param speed_min_gci: minimum GCI speed
--  @param speed_max_gci: maximum GCI speed
--  @param A2ADispatcher:  AI_A2A_DISPATCHER
function assign_gci (airbase_name, speed_min_gci, speed_max_gci, take_off, landing, A2ADispatcher)

   -- Activate airbase for gci operation
   A2ADispatcher:SetSquadronGci( airbase_name, speed_min_gci, speed_max_gci )
   A2ADispatcher:SetSquadronTakeoff( airbase_name, take_off )
   A2ADispatcher:SetSquadronLanding( airbase_name, landing )

end







--- Restituisce una ZONE conformemente al tipo richiesto
--
-- @param zoneName = il nome della zona e/o del percorso che definisce la zona (per la zone_polygon)
-- @param type = circle o polygon
--
function defineZone(zoneName, type)

  if type == 'polygon' then

    zone = ZONE_POLYGON:New( zoneName, GROUP:FindByName( zoneName ) )

  elseif type == 'circle' then

    zone = ZONE:New( zoneName )

  end

  return zone

end


--- Attiva il task CAP per un asset assegnato
--
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param capZoneName = il nome della Zone assegnata per la CAP
-- @param typeZoneName = il tipo della Zone assegnata per la CAP: circle o polygon
-- @param engageRange = la distanza massima di ingaggio rispetto alla CAP
-- @param engageZone = la zona dove la presenza di un nemico comporta l'ingaggio della CAP
-- @param patrolFloorAltitude = altezza minima della CAP nella patrol zone
-- @param patrolCeilAltitude = altezza massima della CAP nella patrol zone
-- @param minSpeedPatrol = velocit� minima di pattugliamento
-- @param maxSpeedPatrol = velocit� massima di pattugliamento
-- @param minSpeedEngage = velocit� minima di ingaggio
-- @param maxSpeedEngage = velocit� massima di ingaggio
--
function activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbaseName )

      local debug = false
      -- nota: inserire il mission accomplish se le munizioni sono finite, l'eventuale check del fuel, se danneggiato ecc.

      local homeAirbase = AIRBASE:FindByName( homeAirbaseName ) -- wrapper AIRBASE

      if debug then logging('finest', { 'activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbaseName )' , 'homeAirbase coord = ' .. homeAirbase:GetCoordinate():ToStringLLDDM()  } ) end

      for _,group in pairs(groupset:GetSetObjects()) do

        -- attiva tutti gli aerei uncontrolled
        group:StartUncontrolled()

        CAP = AI_A2A_CAP:New(group, patrolZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage)

        CAP:SetHomeAirbase(homeAirbase)

        -- Tell the program to use the object (in this case called CAPPlane) as the group to use in the CAP function
        CAP:SetControllable(group)

        -- set engage rules
        if engageRange ~= nil then

          -- Set enage range from aircraft
          CAP:SetEngageRange(engageRange)

        elseif engageZone ~= nil then

          -- Set enage zone
          CAP:SetEngageZone(engageZone)

        else

          -- Default: Set enage range to 20 km from aircraft
          CAP:SetEngageRange(20000)

        end

        -- Start CAP
        CAP:Start()
        CAP:Patrol()

        -- codice per durata CAP?

      end -- for

      return

end -- function








--- Attiva il task BAI per un asset assegnato
--
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param typeOfBAI = tipo di BAI richiesta = 'bombing': bombarda il centro della engage zone, 'target': Attacca i target
-- @param patrolZoneName = il nome della Zone assegnata per la patrol
-- @param engageZoneName = il nome della Zone di ingaggio
-- @param engageSpeed =  velocit� di attacco
-- @param engageAltitude = quota di attacco
-- @param engageWeaponExpend = numero di weapon da sganciare
-- @param engageAttackQty = numero attacchi
-- @param engageDirection = direzione angolare di attacco
-- @param targets = il wrapper:group dei target
-- @param requestNumberKill = il numero di target distrutti utilizzato per valutare il completamento della missione
-- @param patrolFloorAltitude = altezza minima  nella patrol zone
-- @param patrolCeilAltitude = altezza massima nella patrol zone
-- @param minPatrolSpeed = velocit� minima di pattugliamento
-- @param maxPatrolSpeed = velocit� massima di pattugliamento
-- @param timeToEngage = timer per l'ingaggiare
-- @param timeToRTB = timer per l'RTB
-- @param delay = ritardo di attesa per l'attivazione della missione
--
-- OK
--
function activeBAI(nameMission, groupset, typeOfBAI, patrolZone, engageZone, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, targets, percRequestKill, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission )


          if typeOfBAI == 'bombing' then -- bombing engageZone center


            for _, group in pairs(groupset:GetSetObjects()) do

                  local group = group --Wrapper.Group#GROUP

                  -- Start uncontrolled aircraft.
                  group:StartUncontrolled()

                  -- self:E( "BAI Mission: " .. nameMission .. ": group = " .. group .." started!!" )
                  -- MESSAGE:New("BAI Mission: " .. nameMission .. ": group = " .. group .." started!!", 10):ToAll()


                  BAI = AI_BAI_ZONE:New(patrolZone, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, engageZone)

                  -- Tell the program to use the object (in this case called BAIPlane) as the group to use in the BAI function
                  BAI:SetControllable(group)

                  --local Check, CheckScheduleID

                  -- Tell the BAI not to search for potential targets in the BAIEngagementZone, but rather use the center of the BAIEngagementZone as the bombing location.
                  BAI:SearchOff() -- bombing engageZone center

                  -- inserire una funzione evento se le munizioni sono finite -- accomplish, rtb se non e' automatico

                  -- Start BAI
                  BAI:__Start(delayMission)

                  -- Engage after timeToEngage.
                  BAI:__Engage(timeToEngage, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection)

                  -- RTB after timeToRTB.
                  BAI:__RTB(timeToRTB)

                  -- RTB delay after first engage
                  function BAI:OnAfterEngage(Controllable, From, Event, To)

                      BAI:__RTB(600) --10'

                  end

            end -- end for




          elseif typeOfBAI == 'target' and targets ~= nil then -- bombing targets

              for _, group in pairs(groupset:GetSetObjects()) do

                  local group = group --Wrapper.Group#GROUP

                  -- Start uncontrolled aircraft.
                  group:StartUncontrolled()

                  -- MESSAGE:New("BAI Mission: " .. nameMission .. ": group = " .. group .." started!!", 10):ToAll()

                  -- self:E( "BAI Mission: " .. nameMission .. ": group = " .. group .." started!!" )

                  BAI = AI_BAI_ZONE:New(patrolZone, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, engageZone)

                  -- Tell the program to use the object (in this case called BAIPlane) as the group to use in the BAI function
                  BAI:SetControllable(group)

                  local Check, CheckScheduleID


                  -- Function checking if targets are still alive: utilizzata per stabilire se la missione e' stata eseguita (imposta BAI_Accomplish a 1)
                  local function CheckTargets()

                        local nTargets = targets:GetSize()
                        local nInitial = targets:GetInitialSize()
                        local nDead = nInitial-nTargets
                        local requestNumberKill = nInitial * percRequestKill
                        --[[
                        if targets:IsAlive() and nDead < requestNumberKill then

                          MESSAGE:New(string.format("BAI Mission: " .. nameMission .. ": %d of %d red targets still alive. At least %d targets need to be eliminated.", nTargets, nInitial, requestNumberKill), 5):ToAll()

                        else

                          MESSAGE:New("BAI Mission: " .. nameMission .. ": The required red targets are destroyed. Mission accomplish!", 10):ToAll()
                          BAI:__Accomplish(1) -- Now they should fly back to the patrolzone and patrol (nota che l'accomplish nella funzione evento ordina l'RTB vedi sotto).

                        end -- end if
                        ]]

                        if not ( targets:IsAlive() ) or nDead >= requestNumberKill then

                          MESSAGE:New("BAI Mission: " .. nameMission .. ": The required red targets are destroyed. Mission accomplish!", 10):ToAll()
                          BAI:__Accomplish(1) -- Now they should fly back to the patrolzone and patrol (nota che l'accomplish nella funzione evento ordina l'RTB vedi sotto).

                        end -- end if



                  end  -- end local function


                    -- Schedula la funzione locale CheckTargets() con un ritardo iniziale di 600 secondi (10') e successivamente una frequenza di ripetizione di 300 (5') secondi.
                    -- Start scheduler to monitor number of targets and so order RTB.
                    Check, CheckScheduleID = SCHEDULER:New(group, CheckTargets, {}, 600, 300)

                  -- inserire una funzione evento se le munizioni sono finite -- accomplish, rtb se non e' automatico


                  -- When the targets in the zone are destroyed, (see scheduled function), the planes will return home ...
                  function BAI:OnAfterAccomplish( Controllable, From, Event, To )

                        MESSAGE:New( "BAI Mission:" .. nameMission .." Sending the aircraft back to base.", 30):ToAll()
                        Check:Stop(CheckScheduleID) -- chiude lo Scheduler
                        BAI:__RTB(1) -- qui viene ordinato l'RTB ma potresti eliminarlo in modo che la BAI rimanga nella patrol zone in attesa di successivi comandi

                  end -- end function

                  -- RTB delay after first engage
                  function BAI:OnAfterEngage(Controllable, From, Event, To)

                      BAI:__RTB(600) -- 10'

                  end

                  -- Start BAI
                  BAI:__Start(delayMission)

                  -- Engage after timeToEngage.
                  BAI:__Engage(timeToEngage, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection)

                  -- RTB after timeToRTB.
                  BAI:__RTB(timeToRTB)

              end -- end for

          end -- end if


          return

end -- end function








--- Attiva il task RECON per un asset assegnato
--
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param home = il nome della warehouse airbase di partenza
-- @param target = il target (es warehouse.tblisi)
-- @param toTargetAltitude = altitudine relativa alla rotta verso il target
-- @param toHomeAltitude = altitudine relativa alla rotta verso la airbase
-- @param reconDirection = la direzione di attacco
-- @param reconAltitude = altitudine di attacco
-- @param reconRunDistance = distanza dal target per l'inizio del run
-- @param reconRunDirection = direzione del run
-- @param speedReconRun = velocit� di attacco
--
function activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )


    --i task sono descritti in controllable:
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Controllable.html
    local debug = false

    if debug then logging('enter', 'activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )') end

    if debug and nil == groupset then logging('warning', { 'activeRECON( .. )' , 'groupset is nil. Exit!' } ) return nil end

    if debug and nil == target then logging('warning', { 'activeRECON( .. )' , 'target is nil. Exit!' } ) return nil end

    if debug and nil == home then logging('warning', { 'activeRECON( .. )' , 'homebase is nil. Exit!' } ) return nil end

    if debug then logging('finest', { 'activeRECON( .. )' , 'group = ' .. groupset:GetObjectNames() } ) end


    for _, _group in pairs(groupset:GetSet()) do

          local group = _group --Wrapper.Group#GROUP

          -- Start uncontrolled aircraft.
          group:StartUncontrolled()
          group:OptionROTEvadeFire()

          -- Target coordinate!
          local ToCoord = target:GetCoordinate():SetAltitude(toTargetAltitude)

          -- Home coordinate.
          local HomeCoord = home:GetCoordinate():SetAltitude(toHomeAltitude)

          -- Task recon from direction <reconDirection> at altitude <reconAltitude>.


          --TaskRouteToZone(Zone, Randomize, Speed, Formation)
          --TaskRoute(Points)


          --local task=group:TaskBombing(target:GetCoordinate():GetVec2(), false, "All", nil , bombingDirection, bombingAltitude, bombQuantity)
          --local task = group:TaskHoldPosition(20) -- 20 s for recognition
          local task = group:TaskOrbitCircle(toTargetAltitude, speedReconRun, ToCoord)


          -- Define waypoints.
          local WayPoints={}

          -- Take off position.
          WayPoints[1]=home:GetCoordinate():WaypointAirTakeOffParking()

          -- NOTA: ho commentato il WayPoints[2] originale per testare se il gorup esegue comunque la rotta
          -- in ogni caso prova anche l'originale.
          -- Begin bombing run 20 km south of target.
          --WayPoints[2]=ToCoord:Translate(reconRunDistance, reconRunDirection):WaypointAirTurningPoint(nil, speedBombRun, {task}, "RECON Run")
          WayPoints[2]=ToCoord:Translate(reconRunDistance, reconRunDirection):WaypointAirTurningPoint(nil, speedReconRun, {task}, "Recognition!")

          -- Return to base.
          WayPoints[3]=HomeCoord:WaypointAirTurningPoint()
          -- Land at homebase. Bombers are added back to stock and can be employed in later assignments.
          WayPoints[4]=home:GetCoordinate():WaypointAirLanding()

          -- Route bombers.
          group:Route(WayPoints)

    end -- end for

    return

end -- end function






--- Attiva il task STRATEGIC BOMBING per un asset assegnato
--
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param home = il nome della warehouse airbase di partenza
-- @param target = il target (es warehouse.tblisi o una zona)
-- @param toTargetAltitude = altitudine relativa alla rotta verso il target
-- @param toHomeAltitude = altitudine relativa alla rotta verso la airbase
-- @param bombingDirection = la direzione di attacco
-- @param bombingAltitude = altitudine di attacco
-- @param diveBomb = true : esegue il bombing in picchiata
-- @param bombRunDistance = distanza dal target per l'inizio del run
-- @param bombRunDirection = direzione del run
-- @param speedBombRun = velocita' di attacco
--
function activeBOMBING(groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )

        for _,_group in pairs(groupset:GetSet()) do

              local group=_group --Wrapper.Group#GROUP

              -- Start uncontrolled aircraft.
              group:StartUncontrolled()

              -- Target coordinate!
              local ToCoord=target:GetCoordinate():SetAltitude(toTargetAltitude)

              -- Home coordinate.
              local HomeCoord=home:GetCoordinate():SetAltitude(toHomeAltitude)

              -- Task bomb Sukhumi warehouse using all bombs (2032) from direction 180 at altitude 5000 m.
              -- IL TASK � NELLA CLASSE WRAPPER CONTROLLABLE
              --local task=group:TaskBombing(target:GetCoordinate():GetVec2(), false, "All", nil , bombingDirection, bombingAltitude, bombQuantity)
              local task=group:TaskBombing(target:GetCoordinate():GetVec2(), true, "All", nil , bombingDirection, bombingAltitude, nil, diveBomb)

              -- Define waypoints.
              local WayPoints={}

              -- Take off position.
              WayPoints[1]=home:GetCoordinate():WaypointAirTakeOffParking()
              -- Begin bombing run 20 km south of target.
              WayPoints[2]=ToCoord:Translate(bombRunDistance, bombRunDirection):WaypointAirTurningPoint(nil, speedBombRun, {task}, "Bombing Run")
              -- Return to base.
              WayPoints[3]=HomeCoord:WaypointAirTurningPoint()
              -- Land at homebase. Bombers are added back to stock and can be employed in later assignments.
              WayPoints[4]=home:GetCoordinate():WaypointAirLanding()

              -- Route bombers.
              group:Route(WayPoints)

        end -- end for

        return

end -- end function





--- Attiva il task STRATEGIC BOMBING AIRBASE per un asset assegnato
--
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param home = il nome della warehouse airbase di partenza
-- @param airbase = the target (es warehouse.tblisi)
-- @param toTargetAltitude = altitudine relativa alla rotta verso il target
-- @param toHomeAltitude = altitudine relativa alla rotta verso la airbase
-- @param bombingDirection = la direzione di attacco
-- @param bombingAltitude = altitudine di attacco
-- @param diveBomb = true : esegue il bombing in picchiata
-- @param bombRunDistance = distanza dal target per l'inizio del run
-- @param bombRunDirection = direzione del run
-- @param speedBombRun = velocit� di attacco
--
function activeBombingAirbase(groupset, home, airbase, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )

    for _,_group in pairs(groupset:GetSet()) do

          local group=_group --Wrapper.Group#GROUP

          -- Start uncontrolled aircraft.
          group:StartUncontrolled()

          -- Target coordinate!
          local ToCoord=target:GetCoordinate():SetAltitude(toTargetAltitude)

          -- Home coordinate.
          local HomeCoord=home:GetCoordinate():SetAltitude(toHomeAltitude)

          -- Task bomb Sukhumi warehouse using all bombs (2032) from direction 180 at altitude 5000 m.
          -- IL TASK � NELLA CLASSE WRAPPER CONTROLLABLE
          --local task=group:TaskBombing(target:GetCoordinate():GetVec2(), false, "All", nil , bombingDirection, bombingAltitude, bombQuantity)
          local task=group:TaskBombingRunway(airbase, nil, "All", nil , bombingDirection, true)

          -- Define waypoints.
          local WayPoints={}

          -- Take off position.
          WayPoints[1]=home:GetCoordinate():WaypointAirTakeOffParking()
          -- Begin bombing run 20 km south of target.
          WayPoints[2]=ToCoord:Translate(bombRunDistance, bombRunDirection):WaypointAirTurningPoint(nil, speedBombRun, {task}, "Bombing Run")
          -- Return to base.
          WayPoints[3]=HomeCoord:WaypointAirTurningPoint()
          -- Land at homebase. Bombers are added back to stock and can be employed in later assignments.
          WayPoints[4]=home:GetCoordinate():WaypointAirLanding()

          -- Route bombers.
          group:Route(WayPoints)

    end -- end for

    return

end -- end function



--- Attiva il task STRATEGIC BOMBING GROUP per un asset assegnato
--
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param home = il nome della warehouse airbase di partenza
-- @param targetGroup = the target group
-- @param toTargetAltitude = altitudine relativa alla rotta verso il target
-- @param toHomeAltitude = altitudine relativa alla rotta verso la airbase
-- @param bombingDirection = la direzione di attacco
-- @param bombingAltitude = altitudine di attacco
-- @param bombRunDistance = distanza dal target per l'inizio del run
-- @param bombRunDirection = direzione del run
-- @param speedBombRun = velocit� di attacco
--
function activeBombingGroup(groupset, home, targetGroup, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun )

        for _,_group in pairs(groupset:GetSet()) do

              local group=_group --Wrapper.Group#GROUP

              -- Start uncontrolled aircraft.
              group:StartUncontrolled()

              -- Target coordinate!
              local ToCoord=targetGroup:GetCoordinate():SetAltitude(toTargetAltitude)

              -- Home coordinate.
              local HomeCoord=home:GetCoordinate():SetAltitude(toHomeAltitude)

              -- Task bomb Sukhumi warehouse using all bombs (2032) from direction 180 at altitude 5000 m.
              -- IL TASK � NELLA CLASSE WRAPPER CONTROLLABLE
              --local task=group:TaskBombing(target:GetCoordinate():GetVec2(), false, "All", nil , bombingDirection, bombingAltitude, bombQuantity)
              local task=group:TaskAttackGroup(targetGroup, nil, "All", nil , bombingDirection, bombingAltitude, false)

              -- Define waypoints.
              local WayPoints={}

              -- Take off position.
              WayPoints[1]=home:GetCoordinate():WaypointAirTakeOffParking()
              -- Begin bombing run 20 km south of target.
              WayPoints[2]=ToCoord:Translate(bombRunDistance, bombRunDirection):WaypointAirTurningPoint(nil, speedBombRun, {task}, "Bombing Run")
              -- Return to base.
              WayPoints[3]=HomeCoord:WaypointAirTurningPoint()
              -- Land at homebase. Bombers are added back to stock and can be employed in later assignments.
              WayPoints[4]=home:GetCoordinate():WaypointAirLanding()

              -- Route bombers.
              group:Route(WayPoints)

        end -- end for

        return

end -- end function






--- Attiva l'invio di ground asset nella zone.
-- @param groupset = il set di Group
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
function activeGO_TO_ZONE_GROUND( groupset, battleZone, offRoad, speedPerc )

    local debug = false

    if debug then logging('enter', 'activeGO_TO_ZONE_GROUND( group, battlezone, offRoad, speedPerc )') end

    if debug and nil == groupset then logging('warning', { 'activeGO_TO_ZONE_GROUND( group, battlezone, offRoad, speedPerc )' , 'group is nil. Exit!' } ) return nil end

    if debug and nil == battleZone then logging('warning', { 'activeGO_TO_ZONE_GROUND( group, battlezone, offRoad, speedPerc )' , 'battleZone is nil. Exit!' } ) return nil end

    if debug then logging('finest', { 'activeGO_TO_ZONE_GROUND( group, battlezone, offRoad, speedPerc )' , 'battlezone = ' .. battleZone:GetName() .. '  -  group = ' .. groupset:GetObjectNames() .. '  -  offRoad = ' .. tostring(offRoad) .. '  -  speedPerc = ' .. tostring(speedPerc) } ) end

    if nil == offRoad or offRoad ~= true then offRoad = false end

    if nil == speedPerc or speedPerc > 1 or speedPerc < 0.1 then speedPerc = 0.7 end

    -- radius=radius or 100


    for _,group in pairs(groupset:GetSet()) do
      -- seleziona ogni gruppo appartenente al set


      local group = group --Wrapper.Group#GROUP
      --group:StartUncontrolled()

      -- Route group to Battle zone.
      local ToCoord = battleZone:GetRandomCoordinate()
      local groupCoord = group:GetCoordinate()
      local route, length, exist = groupCoord:GetPathOnRoad( ToCoord )

      if debug then logging('finest', { 'activeGO_TO_ZONE_GROUND( group, battlezone, offRoad, speedPerc )' , 'routeToRoad exist = ' .. tostring(exist) .. '  -  length = ' .. tostring(length) } ) end


      if exist and not offRoad then

        if debug then logging('finest', { 'activeGO_TO_ZONE_GROUND( group, battlezone, offRoad, speedPerc )' , 'routeToRoad' } ) end
        -- Ottimizzazione: evita il ricalcolo della route. Cmq dai un occhiata a Moose group:RouteGroundOnRoad per una eventuale modifica
        -- group:RoutePush( route )
        group:RouteGroundOnRoad( ToCoord, group:GetSpeedMax() * speedPerc )

      else

        if debug then logging('finest', { 'activeGO_TO_ZONE_GROUND( group, battlezone, offRoad, speedPerc )' , 'execute routeToGround' } ) end
        group:RouteGroundTo( ToCoord, group:GetSpeedMax() * speedPerc )

      end -- end if then

    end -- end for


    if debug then logging('exit', 'activeGO_TO_ZONE_GROUND( group, battlezone, offRoad, speedPerc )') end

    return

end -- end function







--- Attiva l'invio di gorund asset nella battlezone.
-- NOTA: Nella funzione � presente la schedulazione dell'autodistruzione degli asset
--  al raggiungimento della zona. L'autodistruzione � stata inserita per testare il reinvio degli asset
-- @param groupset = il set dei gruppo (asset) proveniente dalla warehouse
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param task = il task essegnato al groupset
-- @param offRoad (optional - default = false): se true utilizza il percorso fuori strada
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
-- @param suppression (optional) : applica la suppression a tutti i gruppi del groupset
-- @param suppr_param (optional) : lista contenente i parametri necessari per applicare la suppression.
-- DA IMPLEMENTARE I DIVERSI TASK DI ESECUZIONI
function activeGO_TO_BATTLE( groupset, battleZone, task, offRoad, speedPerc, suppression, suppr_param )

        local debug = false

        if debug then logging('enter', 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )') end

        offRoad = offRoad or false
        suppression = suppression or false

        if suppr_param == nil then logging('warning', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'suppr_param is nil. No suppression applied!' } ) suppression = nil end

        if debug and nil == groupset then logging('warning', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'group is nil. Exit!' } ) return nil end

        if debug and nil == battleZone then logging('warning', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'battleZone is nil. Exit!' } ) return nil end

        if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'battlezone = ' .. battleZone:GetName() .. '  -  group = ' .. groupset:GetObjectNames() .. '  -  offRoad = ' .. tostring(offRoad) .. '  -  speedPerc = ' .. tostring(speedPerc) } ) end

        if nil == speedPerc or speedPerc > 1 or speedPerc < 0.1 then speedPerc = 0.7 end

        -- radius=radius or 100


        for _, _group in pairs(groupset:GetSet()) do
          -- seleziona ogni gruppo appartenente al set


          local group = _group --Wrapper.Group#GROUP
          --group:StartUncontrolled()

          if suppression then suppressionGroup(group, suppr_param.retreatZone, suppr_param.fallBack, suppr_param.takeCover, suppr_param.delay) end

          -- Route group to Battle zone.
          local ToCoord = battleZone:GetRandomCoordinate()
          local groupCoord = group:GetCoordinate()
          local route, length, exist = groupCoord:GetPathOnRoad( ToCoord )

          if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'routeToRoad exist = ' .. tostring(exist) .. '  -  length = ' .. tostring(length) } ) end


          if exist and not offRoad then

            if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'routeToRoad' } ) end
            -- Ottimizzazione: evita il ricalcolo della route. Cmq dai un occhiata a Moose group:RouteGroundOnRoad per una eventuale modifica
            -- group:RoutePush( route )
            group:RouteGroundOnRoad( ToCoord, group:GetSpeedMax() * speedPerc )

          else

            if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'execute routeToGround' } ) end
            group:RouteGroundTo( ToCoord, group:GetSpeedMax() * speedPerc )

          end -- end if then

          if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'task = '.. task } ) end

          -- task per attacco diretto
          if task == 'enemy_attack' then

            -- After 3-5 minutes we create an explosion to destroy the group.
            -- sostituisce con task per enemy attack: search & destroy

            --SCHEDULER:New(nil, Explosion, {group, 50}, math.random(180, 300))
            group:EnRouteTaskEngageTargets(500, Group.Category.GROUND, 1) --boh


          elseif task == 'fire_at_point' then

            -- After 3-5 minutes we create an explosion to destroy the group.
            -- sostituisce con task per enemy attack: search & destroy

            --SCHEDULER:New(nil, Explosion, {group, 50}, math.random(180, 300))
            group:TaskFireAtPoint(ToCoord, 200, nil, nil)


          elseif task == 'patrol' then

            -- After 3-5 minutes we create an explosion to destroy the group.
            -- sostituisce con task per enemy attack: search & destroy

            --SCHEDULER:New(nil, Explosion, {group, 50}, math.random(180, 300))
            group:TaskFireAtPoint(ToCoord, 200, nil, nil)

        elseif task == 'hold' then

            -- After 3-5 minutes we create an explosion to destroy the group.
            -- sostituisce con task per enemy attack: search & destroy

            --SCHEDULER:New(nil, Explosion, {group, 50}, math.random(180, 300))
            group:OptionROEHoldFire()
            group:OptionROEReturnFire()

        elseif task == 'jtac' then

          -- After 3-5 minutes we create an explosion to destroy the group.
          -- sostituisce con task per enemy attack: search & destroy

          --SCHEDULER:New(nil, Explosion, {group, 50}, math.random(180, 300))
          group:OptionROEHoldFire()
          group:EnRouteTaskEWR()


          else

            logging('warning', { 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )' , 'task unknow: '.. task } )

          end  --end if


        end -- end for


        if debug then logging('exit', 'activeGO_TO_BATTLE( groupset, battlezone, task, offRoad, speedPerc, suppression, suppr_param )') end

        return

end -- end function





--- Invia il groupset artillery asset nella firing zone e attiva il fuoco sulla zona target.
-- @param groupset = il set dei gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param param (optional) : lista contenente ulteriori parametri
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeGO_TO_ARTY( groupset, battleZone, param, onRoad, speed )

  local debug = false

  if debug then logging('enter', 'activeGO_TO_ARTY( groupset, battlezone )') end

  if debug then logging('finest', { 'activeGO_TO_ARTY( groupset, battlezone )' , 'gorupsetName: ' .. groupset:GetObjectNames() .. ' - battleZone: ' .. battleZone:GetName() } ) end

  local battleZone = battleZone -- the zone object
  local ToCoord = battleZone:GetRandomCoordinate()

  for _,group in pairs(groupset:GetSet()) do

    local group = group --Wrapper.Group#GROUP
    --group:StartUncontrolled()

  -- task per fuoco di artiglieria di bersagli fissi
    local listTargetInfo = param.listTargetInfo
    local command_center = param.commandCenter
    local groupResupplySet = param.resupplySet
    local speed = param.speed
    local onRoad = param.onRoad
    local maxDistance = param.maxDistance
    local maxFiringRange = param.maxFiringRange

    local numOtherAmmo = {

      [ARTY.WeaponType.Cannon] = 0,
      [ARTY.WeaponType.Auto] = 0,
      [ARTY.WeaponType.TacticalNukes] = 0,
      [ARTY.WeaponType.IlluminationShells] = 0,
      [ARTY.WeaponType.Rockets] = 0,
      [ARTY.WeaponType.CruiseMissile] = 0,
      [ARTY.WeaponType.SmokeShells] = 0

    }


    -- il numero di ammo max e' definito o illimitato?
    for _, item in pairs(listTargetInfo) do

      if debug then logging('finest', { 'activeGO_TO_ARTY( groupset, battlezone )' , 'item.weaponType = ' .. tostring(item.weaponType) .. ' - item.num_shots = ' .. tostring(item.num_shots) .. '  -  item.num_engagements = ' .. tostring(item.num_engagements) .. ' -  numOtherAmmo[item.weaponType] = ' .. tostring(numOtherAmmo[item.weaponType]) } ) end
      numOtherAmmo[item.weaponType] = numOtherAmmo[item.weaponType] + item.num_shots * item.num_engagements
      if debug then logging('finest', { 'activeGO_TO_ARTY( groupset, battlezone )' , 'numOtherAmmo[item.weaponType] = ' .. tostring(numOtherAmmo[item.weaponType]) } ) end

    end


    if debug then logging('finest', { 'activeGO_TO_ARTY( groupset, battlezone )' , 'execute artillery_firing tasking   -  ' .. 'num target zone = ' .. #listTargetInfo .. '  -  groupResupplySet = ' .. groupResupplySet:GetObjectNames() .. '-  speed = ' .. tostring(speed) .. '-  onRoad = ' .. tostring(onRoad) .. '-  maxDistance = ' .. tostring(maxDistance) .. '-  maxFiringRange = ' .. tostring(maxFiringRange) } ) end

    ArtyPositionAndFireAtTarget(group, groupResupplySet, ToCoord, listTargetInfo, command_center, activateDetectionReport, speed, onRoad, maxDistance, maxFiringRange, numOtherAmmo)

  end -- end for

  if debug then logging('exit', 'activeGO_TO_GO_TO_ARTYWarehouse( groupset, battlezone )') end

  return

end -- end function








--- Attiva un gruppo di artiglieria mediante indicazioni fornite da un gruppo di ricognizione
-- @param nameRecceUnits = prefisso delle unita dedicate alla ricognizione
-- @param command_Center = il command_center
-- @param activateDetectionReport = true: attiva la visualizzazione dei detection report false la disattiva
--
function RecceGroundDetection(RecceSetGroup, command_Center, activateDetectionReport, delayDetection, persistTimeOfMessage)

    local debug = false

    -- determina il recceGroup selezionandolo da tutte le unita' definite Recce (Recce #001, ..)
    --RecceSetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameRecceUnits ):FilterStart()

    -- determina l'arty group selezionandolo da tutte le unita' definite Artillery (Artillery #001, ..)
    --ArtillerySetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameArtyUnits ):FilterStart()

    -- devi utilizzare i gruppi e non i setGorup che credo siano considerati gia' attivi su ME. Quindi
    -- Creare il grouppo da template, posizionarlo e tramite setGroud associarlo al set da utilizzare qui

    -- quindi OK LA WAREHOUSE CON OnAfterSelfRequest  genera un groupSet!!!!!!

    if debug then logging('enter', 'RecceGroundDetection(RecceSetGroup, command_Center, activateDetectionReport, delayDetection, persistTimeOfMessage') end

    if debug then logging('info', { 'RecceGroundDetection(RecceSetGroup, command_Center, activateDetectionReport, delayDetection)' , 'RecceSetGroup name: ' .. RecceSetGroup:GetObjectNames() .. ' - activateDetectionReport: ' .. activateDetectionReport == TRUE .. ' - delayDetection: ' .. delayDetection .. ' - persistTimeOfMessage: ' .. persistTimeOfMessage }) end

    local RecceGroundDetection = DETECTION_UNITS:New( RecceSetGroup )

    RecceGroundDetection:SetRefreshTimeInterval( delayDetection )

    RecceGroundDetection:Start()



    if activateDetectionReport then

        --- OnAfter Transition Handler for Event Detect.
        -- @param Functional.Detection#DETECTION_UNITS self
        -- @param #string From The From State string.
        -- @param #string Event The Event string.
        -- @param #string To The To State string.
        -- e' possibile che sia necessario inserire questa funzione nel main per non perdere l'informazione dell'evento (la detection da trasmettere)

        function RecceGroundDetection:OnAfterDetect(From,Event,To)

          if debug then logging('enter', 'RecceGroundDetection:OnAfterDetect(From,Event,To)') end

          local DetectionReport = RecceGroundDetection:DetectedReportDetailed()

          if not DetectionReport then

            if debug then logging('exit', 'RecceGroundDetection:OnAfterDetect(From,Event,To) - DetectionReport not avalaible') end
            return nil

          end

          local coalition = command_Center:GetCoalition()

          --command_center:GetPositionable():MessageToAll( DetectionReport, persistTimeOfMessage, "" )
          command_center:GetPositionable():MessageToCoalition(DetectionReport, Duration, persistTimeOfMessage, "")

          if debug then logging('exit', 'RecceGroundDetection:OnAfterDetect(From,Event,To)') end

        end

    end

    if debug then logging('exit', 'RecceGroundDetection(RecceSetGroup, command_Center, activateDetectionReport, delayDetection, persistTimeOfMessage') end

    return RecceGroundDetection

end




--- Attiva un gruppo di artiglieria mediante indicazioni fornite da un gruppo di ricognizione
-- @param coalition = nome della coalizione
-- @param nameRecceUnits = prefisso delle unita dedicate alla ricognizione
-- @param nameArtyUnits = prefisso delle unita di artiglieria
-- @param command_Center = il command_center
-- @param activateDetectionReport = true: attiva la visualizzazione dei detection report false la disattiva
--
function ArtyFiringFromRecceDetection(RecceGroundDetection, ArtillerySetGroup)

  local debug = false

  -- determina il recceGroup selezionandolo da tutte le unita' definite Recce (Recce #001, ..)
  --RecceSetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameRecceUnits ):FilterStart()

  -- determina l'arty group selezionandolo da tutte le unita' definite Artillery (Artillery #001, ..)
  --ArtillerySetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameArtyUnits ):FilterStart()

  -- devi utilizzare i gruppi e non i setGorup che credo siano considerati gia' attivi su ME. Quindi
  -- Creare il grouppo da template, posizionarlo e tramite setGroud associarlo al set da utilizzare qui

  -- quindi OK LA WAREHOUSE CON OnAfterSelfRequest  genera un groupSet!!!!!!

  if debug then logging('enter', 'ArtyFiringFromRecceDetection(RecceGroundDetection, ArtillerySetGroup)') end
  if debug then logging('finest', { 'ArtyFiringFromRecceDetection(RecceGroundDetection, ArtillerySetGroup)' , 'ArtillerySetGroup: ' .. ArtillerySetGroup  }) end

  local RecceDetection = RecceGroundDetection

  local ArtilleryTime = {}

  --- tempo di attesa in secondi per l'assegnazione di un nuovo bersaglio
  --  nota che questo tempo dovrebbe essere coordinato con il raggio dell'area bersaglio e la velocita di attraversamento di bersagli mobili
  --  vm = 500 m / 20 m/s (72 km/h)  =  25 s
  --  180 s --> vm = 10 km/h
  -- e' necessario introdurre una valutazione della velocita' del target se v = 0 --> 300 s  v =10 --> 180 v = 72  -- > 25  t = (500/vm) se t<300 -> t = 300
  --
  local ArtilleryAim = 180

  --- Raggio della zona di bombardamento. Il target rilevato e' al centro della zona
  local radiusTarget = 500

  --- Numero di tiri
  local num_ammo = 4

  --- Tempo di attesa di attivazione del tiro (s)
  local activated_time = 0.5

  if debug then logging('finest', { 'ArtyFiringFromRecceDetection(RecceGroundDetection, ArtillerySetGroup)' , 'ArtilleryAim: ' .. ArtilleryAim .. ' - radiusTarget: ' .. radiusTarget .. ' - num_ammo: ' .. num_ammo .. ' - activated_time: ' .. activated_time }) end
  --- OnAfter Transition Handler for Event Detect.
  -- @param Functional.Detection#DETECTION_UNITS self
  -- @param #string From The From State string.
  -- @param #string Event The Event string.
  -- @param #string To The To State string.
  -- @param Wrapper.Unit#UNIT DetectedUnits
  function RecceDetection:OnAfterDetected( From, Event, To, DetectedUnits )

    if debug then logging('enter', 'RecceDetection:OnAfterDetected())') end
    if debug then logging('finest', { 'RecceDetection:OnAfterDetected( From, Event, To, DetectedUnits )' , 'RecceSetGroup name: ' .. DetectedUnits:GetObjectNames() .. ' - activateDetectionReport: ' .. activateDetectionReport == TRUE .. ' - delayDetection: ' .. delayDetection .. ' - persistTimeOfMessage: ' .. persistTimeOfMessage }) end

    if not(DetectedUnits) then

      if debug then logging('finest', { 'RecceDetection:OnAfterDetected( From, Event, To, DetectedUnits )' , 'DetectedUnit not avalaible: exit' }) end
      return nil

    end



    for DetectedUnitID, DetectedUnit in pairs( DetectedUnits ) do

          -- local velocitaMedia = DetectedUnit:GetVelocityMPS() -- forse non e' il caso: troppo pesante e poco utile
          -- local ArtilleryAim = raidusTarget / velocitaMedia

          local DetectedUnit = DetectedUnit -- Wrapper.Unit#UNIT
          local Artillery = ArtillerySetGroup:GetRandom() -- Wrapper.Group#GROUP --

          if ArtilleryTime[Artillery] and ArtilleryTime[Artillery] <= timer.getTime() - ArtilleryAim then -- se sono passati almeno 180 secondi resetta il tempo per un nuovo tiro
              ArtilleryTime[Artillery] = nil
          end

          if not ArtilleryTime[Artillery] then -- l'Arty scelto non e' impegnato in un tiro

              local Task = Artillery:TaskFireAtPoint( DetectedUnit:GetVec2(), radiusTarget, num_ammo ) -- coord, radius_fire, num_ammo
              Artillery:SetTask( Task, activated_time ) -- task, time_to_task_activate
              ArtilleryTime[Artillery] = timer.getTime()
          end

    end
      if debug then logging('exit', 'RecceDetection:OnAfterDetected())') end
  end

  if debug then logging('exit', 'ArtyFireAndDetection(RecceSetGroup, ArtillerySetGroup, command_Center, activateDetectionReport)') end
end




--- Attiva un gruppo di artiglieria inviandolo nellzona di tiro e assegnandoli gli obiettivi
-- @param ArtilleryGroup = gruppo di artglieria
-- @param groupResupplySet = gruppo di rifornimento
-- @param moveCoordinate = coordinate della zona di tiro assegnata
-- @param listTargetInfo = lista contenente le informazioni dei diversi obiettivi
-- @param command_Center = il command_center
-- @param activateDetectionReport = true: attiva la visualizzazione dei detection report false la disattiva
-- @param activateDetectionReport = il command_center
-- @param speed = la velocita' del gruppo in km/h
-- @param onRoad = se true i mezzi utilizzano se disponibile la strada
-- @param maxDistance = la massima distanza nella quale e' possibile effettuare l'avvicinamento automatico per il tiro
-- @param maxFiringRange = la massima distanza di tiro in m (dafault 1000)
--
function ArtyPositionAndFireAtTarget(ArtilleryGroup, groupResupplySet, moveCoordinate, listTargetInfo, command_Center, activateDetectionReport, speed, onRoad, maxDistance, maxFiringRange, numOtherAmmo)

  -- ARTY.WeaponType.Auto: Automatic weapon selection by the DCS logic. This is the default setting.
  -- ARTY.WeaponType.Cannon: Only cannons are used during the attack. Corresponding ammo type are shells and can be defined by ARTY.SetShellTypes.
  -- ARTY.WeaponType.Rockets: Only unguided are used during the attack. Corresponding ammo type are rockets/nurs and can be defined by ARTY.SetRocketTypes.
  -- ARTY.WeaponType.CruiseMissile: Only cruise missiles are used during the attack. Corresponding ammo type are missiles and can be defined by ARTY.SetMissileTypes.
  -- ARTY.WeaponType.TacticalNukes: Use tactical nuclear shells. This works only with units that have shells and is described below.
  -- ARTY.WeaponType.IlluminationShells: Use illumination shells. This works only with units that have shells and is described below.
  -- ARTY.WeaponType.SmokeShells: Use smoke shells. This works only with units that have shells and is described below.

  local debug = false

  if debug then logging('enter', 'ArtyPositionAndFireAtTarget(ArtilleryGroup, resupplyGroupTemplate, moveCoordinate, listTargetInfo, command_Center, activateDetectionReport)') end

  if debug then logging('finest', { 'ArtyPositionAndFireAtTarget()' , '  ArtilleryGroup: ' .. ArtilleryGroup:GetName() .. '  -  groupResupplySet: ' .. groupResupplySet:GetObjectNames() .. '  -  moveCoordinate: ' .. tostring(moveCoordinate.z) .. ',' .. tostring(moveCoordinate.y) .. ',' .. tostring(moveCoordinate.z)} ) end

--  ARTY.Debug = true

  --- Raggio della zona di bombardamento. Il target rilevato e' al centro della zona
  local radiusTarget = 500

  --- Numero di tiri per ogni engagments
  local num_shots = 4

  --- numero di ingaggi
  local num_engagements = 4

  --- priority
  local priority = 1 -- 1 (high), 100 (low)


  if nil == maxFiringRange then maxFiringRange = 50000 end



  -- Assigning Multiple Targets

  -- Creat a new ARTY object from a artilleryGroup group.
  artyGroup=ARTY:New(ArtilleryGroup)

  for index, num in pairs(numOtherAmmo) do

    if index == ARTY.WeaponType.TacticalNukes then artyGroup:SetTacNukeShells(num) end
    if index == ARTY.WeaponType.IlluminationShells then artyGroup:SetIlluminationShells(num) end
    if index == ARTY.WeaponType.Rockets then artyGroup.Nrockets0 = num end
    if index == ARTY.WeaponType.CruiseMissile then artyGroup.Nmissiles0 = num end
    if index == ARTY.WeaponType.SmokeShells then artyGroup:SetSmokeShells(num) end

  end


  -- Define a rearming group. This is a Transport ammo truck (blue: M818, M181  red Ural-375).
  --local groupResupply = SPAWN:New( resupplyGroupTemplate ) -- prova a togliere local  QUI ***************************

  local groupResupply -- solo per il if debug then logging
  -- prende l'ultimo gruppo: da migliorare inserendo una lista di resupplyGreoup presa dal set. Il set e' costituito dal numero di gruppi inseriti nel warehouse _addRequest (vedi 31160 set di 2 gruppi)
  for _,group in pairs(groupResupplySet:GetSet()) do

    local group = group --Wrapper.Group#GROUP

    artyGroup:SetRearmingGroup( group )
    groupResupply = group -- solo per il if debug then logging

  end

  -- Set the max firing range. A artilleryGroup unit has a range of 20 km.
  artyGroup:SetMaxFiringRange(maxFiringRange)

  --AssignMoveCoord(coord, time, speed, onroad, cancel, name, unique) INUTILE QUI
  -- artyGroup:AssignMoveCoord(moveCoordinate)


  -- radius=radius or 100

  if nil ~= moveCoordinate then

    if nil == onRoad or onRoad ~= true then onRoad = false end

    if nil == speed then speed = 70 end

    artyGroup:AssignMoveCoord(moveCoordinate, nil, speed, onroad)

  end


  local maxdistance = 20 -- 30km
  local onroad = true

  -- artyGroup:SetAutoRelocateToFiringRange(maxdistance, onroad)

  if debug then logging('finest', { 'ArtyPositionAndFireAtTarget()' , '  artyGroupName: ' .. artyGroup.DisplayName .. '  -   resupplyGroup' .. groupResupply:GetName()  .. '  -  shellType (total,  shells, rocket, missile): ' .. string.format('%i  %i  %i %i', artyGroup:GetAmmo( false ) ) } ) end

  -- ARTY:AssignTargetCoord(coord, prio, radius, nshells, maxengage, time, weapontype, name, unique)

  -- Low priorty (90) target, will be engage last. Target is engaged two times. At each engagement five shots are fired.
  -- artilleryGroup:AssignTargetCoord(GROUP:FindByName("Red Targets 3"):GetCoordinate(),  90, nil,  5, 2)
  -- Medium priorty (nil=50) target, will be engage second. Target is engaged two times. At each engagement ten shots are fired.
  --artilleryGroup:AssignTargetCoord(GROUP:FindByName("Red Targets 1"):GetCoordinate(), nil, nil, 10, 2)

  -- High priorty (10) target, will be engage first. Target is engaged three times. At each engagement twenty shots are fired.

  for _, targetInfo in pairs(listTargetInfo) do

    local targetDistance = moveCoordinate:Get2DDistance(targetInfo.targetCoordinate)
    if debug then logging('finest', { 'ArtyPositionAndFireAtTarget()' , '  targetInfo = ' .. tostring(targetInfo.targetCoordinate.x) .. ',' .. tostring(targetInfo.targetCoordinate.y)  .. ',' .. tostring(targetInfo.targetCoordinate.z) .. '  -  targetInfo.num_engagements = ' .. targetInfo.num_engagements .. '  -  targetDistance = ' .. tostring(targetDistance)} ) end
    if debug then logging('finest', { 'ArtyPositionAndFireAtTarget()' , '  targetPriority = ' .. tostring(targetInfo.priority) .. '  -  radiusTarget = ' .. tostring(targetInfo.radiusTarget)  .. '  -  num_shots = ' .. tostring(targetInfo.num_shots) .. '  -  targetInfo.weaponType = ' .. tostring(targetInfo.weaponType) } ) end
    artyGroup:AssignTargetCoord( targetInfo.targetCoordinate,  targetInfo.priority, targetInfo.radiusTarget, targetInfo.num_shots, targetInfo.num_engagements, nil, targetInfo.weaponType)

  end

  -- Start ARTY process.
  artyGroup:Start()

  function ARTY:OnAfterOpenFire(artyGroup, From, Event, To, target)

    local debug = false

    if debug then logging('finest', { 'ArtyPositionAndFireAtTarget()' , ' TEST OnAfterOpenFire(Controllable, From, Event, To, target)'} ) end

  end


  if debug then logging('exit', 'ArtyPositionAndFireAtTarget(ArtilleryGroup, resupplyGroupTemplate, moveCoordinate, listTargetInfo, command_Center, activateDetectionReport)') end

end -- end function







--- Invia il group AFAC nella Afac Zone con assegnato il gruppo di attacco dedicato.
-- @param groupset = il set dei gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param param (optional) : lista contenente ulteriori parametri
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeAFAC( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)

  local debug = false
  -- VEDI LE MISSIONI DES (DESIGNATE) IN PARTICOLARE LA DES 101

  if debug then logging('enter', 'activeAFAC( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)') end


  local afacZone = afaczone[1] -- the zone object


  if debug then logging('finest', { 'activeAFAC( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)' , 'afacgroupsetName: ' .. facgroupset:GetObjectNames() .. 'attackgroupsetName: ' .. attackgroupset:GetObjectNames() .. '  -  mission: ' .. nameMission  .. '  -  zone: ' .. afaczone[2] } ) end



  for _, facgroup in pairs(facgroupset:GetSet()) do


    -- muovi verso la zona

    local facGroup = facgroup --Wrapper.Group#GROUP

    if debug then logging('finest', { 'activeAFAC( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)' , 'afacgroup: ' .. facGroup:GetName() } ) end

    -- GLI HELO 'FUMANO' (non e' la posizione della FARP prova a cambiare in heliport singolo: fuma uguale o prova 1 solo: fuma uguale)
    -- NON PERMANE NELLA ZONA VEDI ALTRI TASK IN CONTROLLABLE

    facGroup:StartUncontrolled()
    facGroup:TaskRouteToZone(afacZone, true, 56, nil)
    facGroup:PatrolZones( { afacZone }, 200, "Vee" )

    -- assegna per ogni gruppo AFAC tutti i gruppi ATTACK
    for _, attackgroup in pairs(attackgroupset:GetSet()) do

      local attackGroup = attackgroup --Wrapper.Group#GROU
      if debug then logging('finest', { 'activeAFAC( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)' , 'attackGroup: ' .. attackGroup:GetName() } ) end
      facGroup:TaskAttackGroup(attackGroup, nil, nil, nil)

    end --end for

  end --end for

  if debug then logging('exit', 'activeAFAC( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)') end

  return

end -- end function



--- Invia il group AFAC nella Afac Zone con assegnato il gruppo di attacco dedicato.
-- @param groupset = il set dei gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param param (optional) : lista contenente ulteriori parametri
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeCAS_AFAC( attackgroupset, patrolzone, nameMission )

  local debug = false
  -- VEDI LE MISSIONI DES (DESIGNATE) IN PARTICOLARE LA DES 101

  if debug then logging('enter', 'activeCAS_AFAC( groupset, ' .. patrolzone[2] .. ', ' .. nameMission .. ' ) ') end


  local patrolZone = patrolzone[1] -- the zone object

  if debug then logging('finest', { 'activeCAS_AFAC( groupset, ' .. patrolzone[2] .. ', ' .. nameMission .. ' ) ' , 'attackgroupsetName: ' .. attackgroupset:GetObjectNames() .. '  -  mission: ' .. nameMission  .. '  -  patrol zone: ' .. patrolzone[2] } ) end


  for _, attackgroup in pairs(attackgroupset:GetSet()) do


    -- muovi verso la zona

    local attackGroup = attackgroup --Wrapper.Group#GROUP
    if debug then logging('finest', { 'activeCAS_AFAC( groupset, ' .. patrolzone[2] .. ', ' .. nameMission .. ' ) ' , 'attack group: ' .. attackGroup:GetName() } ) end
    attackGroup:StartUncontrolled()
    attackGroup:TaskRouteToZone(patrolZone, true, 56, nil)
    attackGroup:PatrolZones( { patrolZone }, 200, "Vee" )
    -- GLI HELO 'FUMANO' (non e' la posizione della FARP prova a cambiare in heliport singolo o prova 1 solo)
    -- NON PERMANE NELLA ZONA VEDI ALTRI TASK IN CONTROLLABLE

  end --end for

  if debug then logging('exit', 'activeCAS_AFAC( groupset, ' .. patrolzone[2] .. ', ' .. nameMission .. ' ) ') end

  return

end -- end function




--- Genera un gruppo dedicato alla detection AI_A2G
-- @param name = il nome del gruppo
-- @param aircraftTemplate = il template dell'aereo
-- @param routeAltitude = la quota della rotta
-- @param detectionAltitude = la quota del task detection
-- @param homeAirbase = l'airbase di partenza'
-- @param detectionZone = la zona relativa la task detection
function generateDetectioA2G_Group(name, detectionGroup, aircraftTemplate, routeAltitude, detectionAltitude, airbase, detectionZone)

  local debug = false

  if debug then logging('enter', 'generateDetectioA2G_Group(name, aircraftTemplate, routeAltitude, detectionAltitude, homeAirbase, detectionZone)') end

  --local airbase = AIRBASE:FindByName(homeAirbase)
  --logging('info', { 'generateDetectioA2G_Group(name, aircraftTemplate, routeAltitude, detectionAltitude, homeAirbase, detectionZone)' , 'airbase = ' .. airbase:GetName() } )

  --detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)
  logging('finest', { 'generateDetectioA2G_Group(name, aircraftTemplate, routeAltitude, detectionAltitude, homeAirbase, detectionZone)' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

  detectionGroup:StartUncontrolled()
  detectionGroup:OptionROTPassiveDefense()

  -- Route group to afac zone.
  local ToCoord = afacZone.detectionZone:GetRandomCoordinate():SetAltitude(routeAltitude)

  -- Home coordinate.
  local HomeCoord=airbase:GetCoordinate():SetAltitude(routeAltitude)

  --local groupCoord = detectionGroup:GetCoordinate() -- NON SERVE
  --detectionGroup:RouteAirTo(ToCoord, POINT_VEC3.RoutePointAltType.BARO, POINT_VEC3.RoutePointType.TurningPoint, POINT_VEC3.RoutePointAction.TurningPoint, detectionGroup:GetSpeedMax(), nil)
  -- inserisci un task come orbitATPoint
  --GROUP:OptionROTPassiveDefense()
  --GROUP:TaskOrbitCircle(Altitude, Speed, Coordinate)

  -- Task bomb Sukhumi warehouse using all bombs (2032) from direction 180 at altitude 5000 m.
  -- IL TASK � NELLA CLASSE WRAPPER CONTROLLABLE
  --local task=group:TaskBombing(target:GetCoordinate():GetVec2(), false, "All", nil , bombingDirection, bombingAltitude, bombQuantity)
  local task = detectionGroup:TaskOrbitCircle(detectionAltitude, detectionGroup:GetSpeedMax() * 0.6, ToCoord)

  -- Define waypoints.
  local WayPoints={}

  -- Take off position.
  WayPoints[1]=airbase:GetCoordinate():WaypointAirTakeOffParking()
  -- Begin bombing run 20 km south of target.
  WayPoints[2]=ToCoord:WaypointAirTurningPoint(nil, detectionGroup:GetSpeedMax() * 0.6, {task}, "Detection for ground threat")
  -- Return to base.
  WayPoints[3]=HomeCoord:WaypointAirTurningPoint()
  -- Land at homebase. Bombers are added back to stock and can be employed in later assignments.
  WayPoints[4]=airbase:GetCoordinate():WaypointAirLanding()

  detectionGroup:Route(WayPoints)


  if debug then logging('exit', 'generateDetectioA2G_Group(name, aircraftTemplate, routeAltitude, detectionAltitude, homeAirbase, detectionZone)') end

  return

end

------------------------------------------------------------------------------- END DEFINE FUNCTIONS -------------------------------------------------------------------------------
















































































-------------------------------------------------------------------------------- ASSET TEMPLATE -------------------------------------------------------------------------------------------


-- RED AIR FORCE TEMPLATE
--
local air_template_red = {

          GCI_Mig_21Bis = 'SQ red GCI Mig_21Bis', -- GCI
          GCI_H_Mig_21Bis = 'SQ red H GCI Mig_21Bis',
          GCI_L_Mig_21Bis = 'SQ red L GCI Mig_21Bis',
          GCI_B_Mig_21Bis = 'SQ red B GCI Mig_21Bis',
          GCI_Mig_23MLD = 'SQ red GCI Mig_23MLD',
          GCI_Mig_25PD = 'SQ red GCI Mig_25PD',
          GCI_Mig_19P = 'SQ red GCI Mig_19P',
          CAP_Mig_21Bis = 'SQ red CAP Mig_21Bis', -- CAP
          CAP_H_Mig_21Bis = 'SQ red CAP H Mig_21Bis',
          CAP_L_Mig_21Bis = 'SQ red CAP L Mig_21Bis',
          CAP_Mig_23MLD = 'SQ red CAP Mig_23MLD',
          CAP_Mig_25PD = 'SQ red CAP Mig_25PD',
          CAP_H_Mig_25PD = 'SQ red CAP H Mig_25PD',
          CAP_Mig_19P = 'SQ red CAP Mig_19P',
          CAS_Mig_27K_Bomb = 'SQ red CAS Mig_27K Bomb', -- CAS
          CAS_Mig_27K_Rocket = 'SQ red CAS Mig_27K Rocket',
          CAS_Su_17M4_Rocket = 'SQ red CAS Su_17M4 Rocket',
          CAS_Su_17M4_Bomb = 'SQ red CAS Su_17M4 Bomb',
          CAS_Su_17M4_Cluster = 'SQ red CAS Su_17M4 Cluster',
          CAS_MI_24V = 'SQ red CAS MI_24V',
          CAS_L_39C_Rocket = 'SQ red CAS L_39C Rocket',
          CAS_Mi_8MTV2 = 'SQ red CAS Mi-8MTV2',
          CAS_Su_25_Rocket = 'SQ red CAS Su-25 Rocket',
          CAS_Su_25_Missile = 'SQ red CAS Su-25 Missile',
          CAS_Su_25_Bomb = 'SQ red CAS Su-25 Bomb',
          GA_SU_24M_HRocket = 'SQ red GA SU_24M HRocket', -- GA
          GA_SU_24M_Bomb = 'SQ red GA SU_24M Bomb',
          GA_SU_24M_HBomb = 'SQ red GA SU_24M HBomb',
          GA_Mig_27K_Bomb_Light = 'SQ Red BOM_Sparse_Light Mig-27K',
          GA_Mig_27K_Sparse_Light = 'SQ Red Cluster Mig-27K',
          GA_Mig_27K_ROCKET_Heavy = 'SQ Red ROCKET_Sparse_Heavy Mig-27K',
          GA_Mig_27K_ROCKET_Light = 'SQ Red ROCKET_Sparse_Light Mig-27K',
          GA_Mig_27K_Missile_R = 'SQ red GA Mig_27K Missile R',
          GA_Mig_27K_Missile_L = 'SQ red GA Mig_27K Missile L',
          GA_Su_25_Missile = 'SQ red GA Su-25 Missile',
          GA_Su_25_Bomb = 'SQ red GA Su-25 Bomb',
          REC_Mig_25RTB = 'SQ red REC Mig_25RTB',  -- RECCE
          REC_SU_24MR = 'SQ red REC SU_24MR',
          BOM_TU_22_Bomb = 'SQ red BOM TU_22', -- INTERDICTION
          BOM_TU_22_Nuke = 'SQ red BOM TU_22 Nuke',
          BOM_SU_24_Bomb = 'SQ red BOM SU_24',
          BOM_SU_24_Structure = 'SQ red BOM SU_24 Structure',
          BOM_SU_17_Structure = 'SQ red BOM SU_17 Structure',
          BOM_MIG_27K_Structure = 'SQ red BOM MIG_27K Structure',
          BOM_MIG_27K_Airbase = 'SQ red BOM MIG_27K Airbase',
          TRAN_AN_26 = 'SQ red TRA AN_26', -- TRANSPORT
          TRAN_YAK_40 = 'SQ red TRA YAK_40',
          TRAN_MI_24 = 'SQ red TRAN MI_24V',
          TRAN_MI_26 = 'SQ red TRAN MI_26',
          AWACS_TU_22 = 'SQ red AWACS TU_22',   -- AWACS
          AWACS_Mig_25RTB = 'SQ red AWACS Mig_25RTB',
          AFAC_Yak_52 = 'SQ red FAC YAK-52',  -- AFAC
          AFAC_L_39C = 'SQ red FAC L-39C',
          AFAC_Mi_8MTV2 = 'SQ red FAC Mi-8MTV2',
          AFAC_MI_24 = 'SQ red FAC Mi-24',
          SEAD_SU_17 = 'SQ red SEAD Su_17M4',
          SEAD_MIX_SU_17 = 'SQ red SEAD MIX Su_17M4',
          SEAD_SU_24 = 'SQ red SEAD Su_24M'

}







-- BLUE AIR FORCE TEMPLATE
--- template definiti in ME
local air_template_blue = {

          GCI_Mig_21Bis = 'SQ blue GCI Mig_21Bis', -- GCI
          GCI_L_Mig_21Bis = 'SQ blue L GCI Mig_21Bis',
          GCI_H_Mig_21Bis = 'SQ blue H GCI Mig_21Bis',
          GCI_F_4 = 'SQ blue GCI F_4',
          GCI_F_5 = 'SQ blue GCI F_5',
          GCI_F_14A = 'SQ blue GCI F_14A',
          GCI_AJS_37 = 'SQ blue GCI AJS-37',
          CAP_F_4 = 'SQ blue CAP F_4', -- CAP
          CAP_F_5 = 'SQ blue CAP F_5',
          CAP_Mig_21Bis = 'SQ blue CAP Mig_21Bis',
          CAP_L_Mig_21Bis = 'SQ blue CAP L Mig_21Bis',
          CAP_H_Mig_21Bis = 'SQ blue CAP H Mig_21Bis',
          CAP_B_Mig_21Bis = 'SQ blue B GCI Mig_21Bis',
          CAP_L_39ZA = 'SQ blue CAP L_39ZA',  -- CAS
          CAP_AJS_37 = 'SQ blue CAP AJS-37',
          CAS_Su_17M4_Rocket = 'SQ blue CAS Su_17M4 Rocket',
          CAS_Su_17M4_Bomb = 'SQ blue CAS Su_17M4 Bomb',
          CAS_Su_17M4_Cluster = 'SQ blue CAS Su_17M4 Cluster',
          CAS_MI_24V = 'SQ blue CAS MI_24V',
          CAS_UH_1H = 'SQ blue CAS UH_1H',
          CAS_UH_60A = 'SQ blue CAS UH_60A',
          CAS_SA_342 = 'SQ blue CAS SA_342',
          CAS_Antitank_SA_342 = 'SQ blue CAS SA_342 Antitank',
          CAS_Mistral_SA_342 = 'SQ blue CAS SA_342 Mistral',
          CAS_L_39C_Rocket = 'SQ blue CAS L_39C Rocket',
          CAS_L_39ZA_HRocket = 'SQ blue CAS L_39ZA HRocket',
          CAS_F_4E_Rocket = 'SQ blue CAS F_4E Rocket',
          CAS_F_4E_Cluster = 'SQ blue CAS F_4E Cluster',
          CAS_F_4E_Heavy_Bomb = 'SQ blue CAS F_4E Heavy Bomb',
          CAS_F_4E_Light_Bomb = 'SQ blue CAS F_4E Light Bomb',
          CAS_AV_88_Rocket = 'SQ blue CAS AV_88 Rocket',
          CAS_AV_88_Cluster = 'SQ blue CAS AV_88 Cluster',
          CAS_AV_88_Bomb = 'SQ blue CAS AV_88 Bomb',
          CAS_F_5E_3_Rocket = 'SQ blue CAS F_5E_3 Rocket',
          CAS_F_5E_3_Bomb = 'SQ blue CAS F_5E_3 Bomb',
          CAS_F_5E_3_Cluster = 'SQ blue CAS F_5E_3 Cluster',
          CAS_AJS_37 = 'SQ blue CAS AJS-37',
          CAS_A_10A_Rocket = 'SQ blue CAS A-10A Rocket',
          CAS_A_10A_Bomb = 'SQ blue CAS A-10A Bomb',
          CAS_A_10A_Missile = 'SQ blue CAS A-10A Missile',
          GA_A_10A_Missile = 'SQ blue GA A-10A Missile',
          GA_A_10A_Bomb = 'SQ blue GA A-10A Bomb',
          REC_L_39ZA = 'SQ blue REC L_39ZA',  -- RECCE
          REC_F_4 = 'SQ blue REC F_4',
          BOM_SU_24_Bomb = 'SQ blue BOM SU_24', -- INTERDICTION
          BOM_B_1B = 'SQ blue BOM B_1B',
          B_1B_HBomb = 'SQ blue BOM B_1B HBomb',
          BOM_B_52H = 'SQ blue BOM B_52H',
          BOM_F_4_E_Structure = 'SQ blue Structure BOM F4-E',
          BOM_F_4_E_Sparse_Heavy = 'SQ blue Structure BOM_Heavy F4-E',
          BOM_F_4_E_Sparse_Light = 'SQ blue Structure BOM_Sparse_Light F4-E',
          BOM_F_4_E_Sparse_Cluster = 'SQ blue Sparse BOM_Cluster F4-E',
          BOM_AV_88_Structure = 'SQ blue BOM C-AV88 Structure',
          BOM_AV_88_Heavy_Structure = 'SQ blue BOM C-AV88 Heavy Structure',
          BOM_AJS_37 = 'SQ blue BOM AJS-37',
          BOM_Mi_8MTV2 = 'SQ blue BOM Mi-8MTV2',
          TRAN_AN_26 = 'SQ blue TRAN AN_26', -- TRANSPORT
          TRAN_YAK_40 = 'SQ blue TRANSPORT YAK_40',
          TRAN_UH_1H = 'SQ blue TRAN UH_1H',
          TRAN_UH_60A = 'SQ blue TRAN UH_60A',
          TRAN_CH_47 = 'SQ blue TRAN CH_47',
          TRAN_MI_24 = 'SQ blue TRAN MI_24V',
          TRAN_C_130 = 'SQ blue TRAN C_130',
          AWACS_F_4 = 'SQ blue AWACS F_4', -- AWACS
          AWACS_B_1B = 'SQ blue AWACS B_1B',
          AFAC_Yak_52 = 'SQ blue FAC Yak-52', -- AFAC
          AFAC_L_39ZA = 'SQ blue FAC L-39ZA',
          AFAC_AV_88 = 'SQ blue FAC AV-88',
          AFAC_MI_24 = 'SQ blue FAC Mi-24',
          AFAC_SA342L = 'SQ blue FAC SA342L',
          AFAC_UH_1H = 'SQ blue FAC UH_1H',
          SEAD_F_4E_L = 'SQ blue SEAD L F_4E',
          SEAD_F_4E_M = 'SQ blue SEAD M F_4E',
          SEAD_F_4E_H = 'SQ blue SEAD H F_4E',
          SEAD_AJS37 = 'SQ blue SEAD AJS37'
}




-- RED GROUND FORCE TEMPLATE
  local ground_group_template_red = {

    antitankA = 'RUSSIAN ANTITANK SQUAD', -- ANTITANK
    antitankB = 'RUSSIAN ANTITANK SQUAD BIS',
    antitankC = 'RUSSIAN ANTITANK SQUAD TRIS',
    mechanizedA = 'RUSSIAN MECHANIZED SQUAD', -- MECHANIZED
    mechanizedB = 'RUSSIAN MECHANIZED SQUAD BIS',
    mechanizedC = 'RUSSIAN MECHANIZED SQUAD TRIS',
    ArtiKatiusha = 'RUSSIAN ARTILLERY KATIUSHA SQUAD', -- ARTILLERY
    ArtiGwozdika = 'RUSSIAN ARTILLERY GWOZDIKA SQUAD',
    ArtiHeavyMortar = 'RUSSIAN HEAVY MORTAR SQUAD',
    ArtiAkatsia = 'RUSSIAN ARTILLERY AKATSIA SQUAD',
    ArmorA = 'RUSSIAN ARMOR SQUAD', -- ARMOR
    ArmorB = 'RUSSIAN ARMOR SQUAD BIS',
    ResupplyTrucksColumn = 'GW_1975 Russian  Resupply Trucks Column',-- RESUPPLY
    TransportA = 'RUSSIAN TRANSPORT SQUAD',
    TransportB = 'RUSSIAN TRANSPORT SQUAD BIS',
    TroopTransport = 'RUSSIAN TROOP TRANSPORT SQUAD',
    Truck = 'Red_Truck',
    ArtilleryResupply = 'RUSSIAN ARTILLERY RESUPPLY TRUCK',
    jtac = 'RUSSIAN JTAC SQUAD',
    AAA_Basic = 'RUSSIAN AAA Basic SQUAD',
    AAA_Normal = 'RUSSIAN AAA Normal SQUAD',
    AAA_High = 'RUSSIAN AAA  High SQUAD'


  }










-- BLUE GROUND FORCE TEMPLATE
--- Template defininti in ME
local ground_group_template_blue = {

  antitankA = 'GEORGIAN ANTITANK SQUAD', -- ANTITANK: WAREHOUSE.Attribute.GROUND_TANK
  antitankB = 'GEORGIAN ANTITANK SQUAD BIS',
  antitankC = 'GEORGIAN ANTITANK SQUAD TRIS',
  mechanizedA = 'GEORGIAN MECHANIZED SQUAD', -- MECHANIZED: WAREHOUSE.Attribute.GROUND_APC
  mechanizedB = 'GEORGIAN MECHANIZED SQUAD BIS',
  mechanizedC = 'GEORGIAN MECHANIZED SQUAD TRIS',
  ArtiKatiusha = 'GEORGIAN ARTILLERY KATIUSHA SQUAD', -- ARTILLERY: WAREHOUSE.Attribute.GROUND_ARTILLERY
  ArtiGwozdika = 'GEORGIAN ARTILLERY GWOZDIKA SQUAD',
  ArtiHeavyMortar = 'GEORGIAN HEAVY MORTAR SQUAD',
  ArtiAkatsia = 'GEORGIAN ARTILLERY AKATSIA SQUAD',
  ArmorA = 'GEORGIAN ARMOR SQUAD', -- ARMOR: WAREHOUSE.Attribute.GROUND_TANK
  ArmorB = 'GEORGIAN ARMOR SQUAD BIS',
  ResupplyTrucksColumn = 'GW_1975 Georgian Resupply Trucks Column', -- RESUPPLY: WAREHOUSE.Attribute.GROUND_TRUCK
  TransportA = 'GEORGIAN TRANSPORT SQUAD',
  TransportB = 'GEORGIAN TRANSPORT SQUAD BIS',
  TroopTransport = 'GEORGIAN TROOP TRANSPORT SQUAD',
  Truck = 'Blue_Truck',
  ArtilleryResupply = 'GEORGIAN ARTILLERY RESUPPLY TRUCK',
  jtac = 'GEORGIAN JTAC SQUAD',
  AAA_Basic = 'GEORGIAN AAA Basic SQUAD',
  AAA_Normal = 'GEORGIAN AAA Normal SQUAD',
  AAA_High = 'GEORGIAN AAA  High SQUAD'


}







-------------------------------------------------------------------------------- END ASSET TEMPLATE -------------------------------------------------------------------------------------------

























local airbase_red = { AIRBASE.Caucasus.Mozdok, AIRBASE.Caucasus.Maykop_Khanskaya, AIRBASE.Caucasus.Novorossiysk, AIRBASE.Caucasus.Mineralnye_Vody, AIRBASE.Caucasus.Nalchik,
                        AIRBASE.Caucasus.Beslan, AIRBASE.Caucasus.Gelendzhik, AIRBASE.Caucasus.Krasnodar_Pashkovsky, AIRBASE.Caucasus.Anapa_Vityazevo, AIRBASE.Caucasus.Krasnodar_Center, AIRBASE.Caucasus.Krymsk } -- aeroporti attivi in ME

local airbase_blue = { AIRBASE.Caucasus.Kutaisi, AIRBASE.Caucasus.Sochi_Adler, AIRBASE.Caucasus.Senaki_Kolkhi, AIRBASE.Caucasus.Gudauta, AIRBASE.Caucasus.Sukhumi_Babushara, AIRBASE.Caucasus.Kobuleti, AIRBASE.Caucasus.Tbilisi_Lochini, AIRBASE.Caucasus.Soganlug,
                        AIRBASE.Caucasus.Vaziani } -- aeroporti attivi in ME






local typeTakeoff = { AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Takeoff.Runway, AI_A2A_DISPATCHER.Takeoff.Air }

local typeLanding = { AI_A2A_DISPATCHER.Landing.NearAirbase, AI_A2A_DISPATCHER.Landing.AtRunway, AI_A2A_DISPATCHER.Landing.AtEngineShutdown }

local targetPoints = {

  airbase = { math.random( 70, 100 ) },
  ewr_site = { math.random( 70, 100 ) },
  port = { math.random( 70, 100 ) },
  farp = { math.random( 50, 100 ) },
  warehouse = { math.random( 30, 60 ) },
  warehouse_big = { math.random( 70, 100 ) },
  storage_area = { math.random( 10, 30 ) },
  power_plant_area = { math.random( 20, 30 ) },
  production_plant_area = { math.random( 10, 30 ) },
  station = { math.random( 10, 30 ) },
  railway = { math.random( 10, 20 ) },
  bridge = { math.random( 10, 30 ) },
  front_zone = { math.random( 10, 30 ) },
  armored = { math.random( 4, 6 ) },
  mechanized = { math.random( 4, 6 ) },
  antitank = { math.random( 4, 6 ) },
  sam = { math.random( 5, 10 ) },
  hq = { math.random( 10, 20 ) }

}






































































































-----------------------------------------------------------------------------------------------------------    THE CONFLICT --------------------------------------------------------------------------------------------





---- CONFLICT CONFIGURATION


-- la Zona del conflitto attivata
local conflictZone = 'Zone 1: South Ossetia'

-- stato attivazione warehouse
local activeWarehouse = true

-- stato attivazione conflitto aereo
local activeAirWar = true

-- stato attivazione conflitto terrestre
local activeGroundWar = true

-- stato attivazione conflitto navale
local activeSeaWar = false



-- Civilian Traffic activation

local blue_civilian_traffic = false


-- AI_A2A Activation
local active_AI_A2A_red = true
local active_AI_A2A_blue = true




-- AI_A2G Activation
local activeAI_A2G_Dispatching_Red = true
local activeAI_A2G_Dispatching_Blue = true


-- BALANCER activation
local activeBalancer = false



local activation_code = {

  [ 1 ] = 'WH (warehouse) activation',
  [ 2 ] = 'AI_CAS activation',
  [ 3 ] = 'AI_BAI activation',
  [ 4 ] = 'AI_SEAD activation',
  [ 5 ] = 'WH_CAP activation',
  [ 6 ] = 'WH_GA activation',
  [ 7 ] = 'WH_BOMBING',
  [ 8 ] = 'WH_BAI activation',
  [ 9 ] = 'WH_AWACS activation',
  [ 10 ] = 'WH_RECON_Activation',
  [ 11 ] = 'WH_TRANSPORT activation',
  [ 12 ] = 'WH_Ground_Attack Activation',
  [ 13 ] = 'WH_JTAC activation',
  [ 14 ] = 'WH_Ground_Transport',
  [ 15 ] = 'WH_AFAC activation',
  [ 16 ] = 'AI_CAP activation',
  [ 17 ] = 'AI_GCI activation'

}



local wh_selected = { Warehouse = { blue = {}, red = {} }, Warehouse_AB = { blue = {}, red = {} }}

wh_selected.Warehouse.blue = randomTrueFalseList(2,1)
wh_selected.Warehouse.red = randomTrueFalseList(3,1)
wh_selected.Warehouse_AB.blue = randomTrueFalseList(4,2)
wh_selected.Warehouse_AB.red = randomTrueFalseList(3,2)





local wh_activation = {


  Warehouse = {

    blue = {

       Zestafoni     =   { wh_selected.Warehouse.blue[1], false, false, false, false, true, false, false, false, true, true, true, true, true, true, false, false },
       Gori          =   { true, true, false, false, false, true, false, false, false, true, true, true, true, true, true, false, false },
       Khashuri      =   { wh_selected.Warehouse.blue[2], false, false, false, false, true, true, true, true, true, true, true, true, true, true, false, false }

    },

    red = {

      Biteta        =   { wh_selected.Warehouse.red[1], true, false, false, false, true, false, false, false, true, true, true, true, true, true, false, false },
      Didi          =   { true, true, false, false, false, true, false, false, false, true, true, true, true, true, true, false, false },
      Kvemo_Sba     =   { wh_selected.Warehouse.red[2], false, false, false, false, true, false, false, false, true, true, true, true, true, true, false, false },
      Alagir        =   { wh_selected.Warehouse.red[3], false, false, false, false, true, false, false, false, true, true, true, true, true, true, false, false }

    }

  },

  Warehouse_AB = {

    blue = {

      Vaziani       =   { wh_selected.Warehouse_AB.blue[1], true, true, true, false, true, true, true, true, true, true, false, false, false, true, false, true },
      Soganlug      =   { wh_selected.Warehouse_AB.blue[2], true, true, true, false, true, true, true, true, true, true, false, false, false, true, true, true },
      Tbilisi       =   { wh_selected.Warehouse_AB.blue[3], true, true, true, false, true, true, true, true, true, true, false, false, false, true, false, false },
      Kutaisi       =   { wh_selected.Warehouse_AB.blue[4], true, true, true, false, true, true, true, true, true, true, false, false, false, true, true, true },
      Kvitiri       =   { false, true, true, true, false, true, true, true, true, true, true, false, false, false, true, false, false },
      Kvitiri_Helo  =   { false, true, true, true, false, true, true, true, true, true, true, false, true, false, true, false, false },
      Batumi        =   { true, true, true, true, false, true, true, true, true, true, true, false, false, false, true, false, true }

    },

    red = {

      Mozdok        =   { wh_selected.Warehouse_AB.red[1], true, true, true, false, true, true, true, true, true, true, false, false, false, true, true, false },
      Mineralnye    =   { wh_selected.Warehouse_AB.red[2], true, true, true, false, true, true, true, true, true, true, false, false, false, true, true, true },
      Beslan        =   { true, true, true, true, false, true, true, true, true, true, true, false, false, false, true, false, true },
      Nalchik       =   { wh_selected.Warehouse_AB.red[3], true, true, true, false, true, true, true, true, true, true, false, false, false, true, true, false }

    }

  }


}






---------------------------- Asset skill

local AssetSkill = {

  red = {

    ground = { 4, 6 },
    tank =   { 4, 6 },
    artillery = { 4, 6 },
    sam = { 4, 6 },
    fighter_bomber = { 4, 6 },
    fighter = { 4, 6 },
    bomber = { 4, 6 },
    transport = { 5, 6 },
    afac = { 5, 6 },
    awacs = { 5, 6 },
    recon = { 5, 6 }

  },

  blue = {

    ground = { 5, 6 },
    tank =   { 5, 6 },
    artillery = { 5, 6 },
    sam = { 5, 6 },
    fighter_bomber = { 5, 6 },
    fighter = { 4, 6 },
    bomber = { 5, 6 },
    transport = { 5, 6 },
    afac = { 5, 6 },
    awacs = { 5, 6 },
    recon = { 5, 6 }

  }

}



-------------------- Asset Quantity for Warehouse request

local AssetQty = {

  red = {

    air = {

      patrol = { 1, 2 },
      cas = { 1, 2 },
      ga = { 1, 2 },
      bomb = { 1, 2 },
      recon = { 1, 1 },
      transport = { 1, 1 },
      heavy_bomb = { 1, 1 }

    },

    heli = {

      patrol = { 1, 2 },
      cas = { 1, 2 },
      ga = { 1, 2 },
      bomb = { 1, 2 },
      recon = { 1, 1 },
      transport = { 1, 2 }

    },

    ground = {

      attack = { 1, 1 },
      arti = { 1, 1 },
      recon = { 1, 1 },
      transport = { 1, 1 }

    }

  },

  blue = {

    air = {

      patrol = { 1, 2 },
      cas = { 1, 2 },
      ga = { 1, 2 },
      bomb = { 1, 2 },
      recon = { 1, 1 },
      transport = { 1, 1 },
      heavy_bomb = { 1, 1 }

    },

    heli = {

      patrol = { 1, 2 },
      cas = { 1, 2 },
      ga = { 1, 2 },
      bomb = { 1, 2 },
      recon = { 1, 1 },
      transport = { 1, 2 }

    },

    ground = {

      attack = { 1, 1 },
      arti = { 1, 1 },
      recon = { 1, 1 },
      transport = { 1, 1 }

    }

  }

}





-- TakeOff and Landing setting for AI_A2A and AI_A2G Dispatching
-- perc<xxx> is probability for specific takeoff or landing type
local parAirbOp = {

  -- take off = { percAir, percRnwy, percHot}  box is calculated ,
  -- landing = {percAir, percRnwy}  box is calculated

  cap = { takeOff( 0.2, 0.1, 0.5 ), landing( 0.5, 0.2 ) },
  gci = { takeOff( 0.1, 0.2, 0.7 ), landing( 0.5, 0.2 ) },
  cas = { takeOff( 0.2, 0.1, 0.5 ), landing( 0.5, 0.2 ) },
  bai = { takeOff( 0.2, 0.1, 0.5 ), landing( 0.5, 0.2 ) },
  sead = { takeOff( 0.2, 0.1, 0.5 ), landing( 0.5, 0.2 ) }

}



--- WAREHOUSE SCHEDULE TIMING CONFIGURATION

    -- AIR --
local startReqTimeAir = 10 -- wh start request delay after schedulation - ritardo di avvio delle wh request dopo la schedulazione delle stesse
local waitReqTimeAir = math.random(1200, 3000) -- 20'- 50' delay for next request - tempo di attesa tra due request successive per asset aerei
local start_sched = math.random(10, 180) -- 120 start_sched = ritardo in secondi nella attivazione dello scheduler. NOTA: può essere inteso come il tempo necessario per attivare le missioni dipendente dall'efficienza della warehouse
local interval_sched = 4200  -- DEPRECATED interval_sched = intervallo in secondi della schedulazione (ciclo) della funzione. Nota: è necessario valutare l'effetto della OnAfterDelivered o OnAfterDead
local rand_sched = 0.01  -- rand_sched = percentuale di variazione casuale per l'intervallo di schedulazione
local activeAirRequestRatio = 2 -- 2 e' il numero di request coesistenti appartenenti a due distinte schedulazioni

-- GROUND --
local startReqTimeGround = 10 -- ritardo di avvio delle wh request dopo la schedulazione delle stesse
local waitReqTimeGround = math.random(1800, 3600) -- 30'- 60' tempo di attesa tra due request successive per asset terrestri
local start_ground_sched = math.random(10, 180) -- start_sched = ritardo in secondi nella attivazione dello scheduler. NOTA: può essere inteso come il tempo necessario per attivare le missioni dipendente dall'efficienza della warehouse
local interval_ground_sched = 5400 -- DEPRECATED interval_sched = intervallo in secondi della schedulazione (ciclo) della funzione. Nota: è necessario valutare l'effetto della OnAfterDelivered o OnAfterDead
local rand_ground_sched = 0.01 -- rand_sched = percentuale di variazione casuale per l'intervallo di schedulazione
local activeGroundRequestRatio = 2 -- 2 e' il numero di request coesistenti appartenenti a due distinte schedulazioni



if loggingLevel >= 4 then

  logging('info', { 'wh_activation' , 'list' } )

  for i1, k1 in pairs(wh_activation) do

    logging('info', { i1, '' } )

    for i2, k2 in pairs(k1) do

      logging('info', { i2, '' } )

      for i3, k3 in pairs(k2) do

        logging('info', { i3, '' } )

        for i4, k4 in pairs(k3) do

          local tf

          if k4 then tf ='true' else tf = 'false' end

          logging('info', { activation_code[ i4 ] .. ': ', tf } )

        end

      end

    end

  end

end








logging('info', { 'main' , 'conflictZone code module activated = ' ..  conflictZone } )
logging('info', { 'main' , 'Activation code module for Warehouse, Air War, Ground War, SeaWar active = ' .. tostring(activeWarehouse) .. ' , ' .. tostring(activeAirWar) .. ' , ' .. tostring(activeGroundWar) .. ' , ' .. tostring(activeSeaWar) } )

-- Qui l'eventuale codice per stabilire la zona del conflitto
--  conflictZone = conflictZone()






















-----------------------------  TARGET -------------------------------------------------------------------------------------------


if conflictZone == 'Zone 1: South Ossetia' then





   -- Static Object che rappresentano target startegici (BAI, PINPOINT)
   local staticObject = {

      Warehouse = {

        blue = {

           Zestafoni    =   { STATIC:FindByName( "Warehouse ZESTAFONI" ), "Warehouse ZESTAFONI",  targetPoints.warehouse }, --Functional.Warehouse#WAREHOUSE
           Gori          =   { STATIC:FindByName( "Warehouse GORI" ), "Warehouse GORI",  targetPoints.warehouse_big },  --Functional.Warehouse#WAREHOUSE
           Khashuri      =   { STATIC:FindByName( "Warehouse KHASHURI" ), "Warehouse KHASHURI",  targetPoints.warehouse }   --Functional.Warehouse#WAREHOUSE

        },

        red = {

          Biteta        =   { STATIC:FindByName( "Warehouse Biteta" ), "Warehouse Biteta",  targetPoints.warehouse },--Functional.Warehouse#WAREHOUSE
          Didi          =   { STATIC:FindByName( "Warehouse Didi" ), "Warehouse Didi",  targetPoints.warehouse_big }, --Functional.Warehouse#WAREHOUSE
          Kvemo_Sba     =   { STATIC:FindByName( "Warehouse Kvemo Sba" ), "Warehouse Kvemo Sba",  targetPoints.warehouse }, --Functional.Warehouse#WAREHOUSE
          Alagir        =   { STATIC:FindByName( "Warehouse Alagir" ), "Warehouse Alagir",  targetPoints.warehouse_big }  --Functional.Warehouse#WAREHOUSE

        }

      }, -- end Warehouse


      Farp = {

        blue = {

          Zestafoni  =    { STATIC:FindByName( "Farp ZESTAFONI" ), "Farp ZESTAFONI",  targetPoints.farp }, --Functional.Warehouse#WAREHOUSE
          Khashuri   =    { STATIC:FindByName( "FARP KHASHURI" ), "FARP KHASHURI",  targetPoints.farp },  --Functional.Warehouse#WAREHOUSE
          Gori       =    { STATIC:FindByName( "FARP GORI" ), "FARP GORI",  targetPoints.farp },   --Functional.Warehouse#WAREHOUSE
          Kvitiri      =    { STATIC:FindByName( "FARP Kvitiri" ), "FARP Kvitiri",  targetPoints.farp },   --Functional.Warehouse#WAREHOUSE
          Kvitiri_Helo =    { STATIC:FindByName( "FARP Kvitiri Helo" ), "FARP Kvitiri Helo",  targetPoints.farp }   --Functional.Warehouse#WAREHOUSE


        },

        red = {

          Biteta        =  { STATIC:FindByName( "FARP  Biteta" ), "FARP  Biteta",  targetPoints.farp },  --Functional.Warehouse#WAREHOUSE
          Didi_1          =  { STATIC:FindByName( "FARP Didi 1" ), "FARP Didi 1",  targetPoints.farp },   --Functional.Warehouse#WAREHOUSE
          Didi_2          =  { STATIC:FindByName( "FARP Didi 2" ), "FARP Didi 2",  targetPoints.farp },   --Functional.Warehouse#WAREHOUSE
          Kvemo_Sba     =  { STATIC:FindByName( "FARP Kvemo Sba" ), "FARP Kvemo Sba",  targetPoints.farp },   --Functional.Warehouse#WAREHOUSE
          Alagir        =  { STATIC:FindByName( "FARP Alagir" ), "FARP Alagir",  targetPoints.farp }   --Functional.Warehouse#WAREHOUSE

        }

      }, -- end Farp

      Warehouse_AB = {

        blue = {

          Vaziani       =   { STATIC:FindByName( "Warehouse Vaziani Airbase" ), "Warehouse Vaziani Airbase",  targetPoints.airbase },  --Functional.Warehouse#WAREHOUSE
          Soganlug      =   { STATIC:FindByName( "Warehouse Soganlug Airbase" ), "Warehouse Soganlug Airbase",  targetPoints.airbase },   --Functional.Warehouse#WAREHOUSE
          Tbilisi       =   { STATIC:FindByName( "Warehouse Tbilisi Airbase" ), "Warehouse Tbilisi Airbase",  targetPoints.airbase },   --Functional.Warehouse#WAREHOUSE
          Kutaisi       =   { STATIC:FindByName( "Warehouse Kutaisi Airbase"),  "Warehouse Kutaisi Airbase",  targetPoints.airbase },  --Functional.Warehouse#WAREHOUSE
          Kvitiri       =   { STATIC:FindByName( "Warehouse KVITIRI"), "Warehouse KVITIRI",  targetPoints.airbase },   --Functional.Warehouse#WAREHOUSE
          Kvitiri_Helo  =   { STATIC:FindByName( "Warehouse KVITIRI HELO"),  "Warehouse KVITIRI HELO",  targetPoints.airbase },  --Functional.Warehouse#WAREHOUSE
          Batumi        =   { STATIC:FindByName( "Warehouse Batumi"), "Warehouse Batumi",  targetPoints.airbase }     --Functional.Warehouse#WAREHOUSE

        },

        red = {

          Mozdok        =   { STATIC:FindByName( "Warehouse Mozdok Airbase"), "Warehouse Mozdok Airbase",  targetPoints.airbase },   --Functional.Warehouse#WAREHOUSE
          Mineralnye    =   { STATIC:FindByName( "Warehouse Mineralnye Airbase"), "Warehouse Mineralnye Airbase",  targetPoints.airbase },    --Functional.Warehouse#WAREHOUSE
          Beslan        =   { STATIC:FindByName( "Warehouse Beslan Airbase"), "Warehouse Beslan Airbase",  targetPoints.airbase },   --Functional.Warehouse#WAREHOUSE
          Nalchik       =   { STATIC:FindByName( "Warehouse Nalchik Airbase"), "Warehouse Nalchik Airbase",  targetPoints.airbase }    --Functional.Warehouse#WAREHOUSE

        }


      },  -- end Warehouse_AB


      Stucture = {

        blue = {

          Zestafoni_Railway_Station       =   { STATIC:FindByName( "Zestafoni Railway Station" ), "Zestafoni Railway Station",  targetPoints.station },
          Agara_Railway_Station           =   { STATIC:FindByName( "Agara Railway Station" ), "Agara Railway Station",  targetPoints.station },
          Gori_Storage_Asset_1              =   { STATIC:FindByName( "Gori Storage Area #001" ), "Gori Storage Area #001",  targetPoints.storage_area },
          Gori_Storage_Asset_2              =   { STATIC:FindByName( "Gori Storage Area #002" ), "Gori Storage Area #002",  targetPoints.storage_area },
          Gori_Storage_Asset_3              =   { STATIC:FindByName( "Gori Storage Area #003" ), "Gori Storage Area #003",  targetPoints.storage_area },
          Gori_Storage_Asset_4              =   { STATIC:FindByName( "Gori Storage Area #004" ), "Gori Storage Area #004",  targetPoints.storage_area },
          Gori_Storage_Asset_5              =   { STATIC:FindByName( "Gori Storage Area #005" ), "Gori Storage Area #005",  targetPoints.storage_area },
          Gori_Storage_Asset_6              =   { STATIC:FindByName( "Gori Storage Area #006" ), "Gori Storage Area #006",  targetPoints.storage_area },
          Gori_Storage_Asset_7              =   { STATIC:FindByName( "Gori Storage Area #007" ), "Gori Storage Area #007",  targetPoints.storage_area },
          Gori_Storage_Asset_8              =   { STATIC:FindByName( "Gori Storage Area #008" ), "Gori Storage Area #008",  targetPoints.storage_area },
          Gori_Storage_Asset_9              =   { STATIC:FindByName( "Gori Storage Area #009" ), "Gori Storage Area #009",  targetPoints.storage_area },
          Kaspi_Storage_Asset_1             =   { STATIC:FindByName( "Storage Area Kaspi" ), "Storage Area Kaspi",  targetPoints.storage_area },
          Kaspi_Storage_Asset_2             =   { STATIC:FindByName( "Storage Area Kaspi #001" ), "Storage Area Kaspi #001",  targetPoints.storage_area },
          Kaspi_Storage_Asset_3             =   { STATIC:FindByName( "Storage Area Kaspi #002" ), "Storage Area Kaspi #002",  targetPoints.storage_area },
          Kaspi_Storage_Asset_4             =   { STATIC:FindByName( "Storage Area Kaspi #003" ), "Storage Area Kaspi #003",  targetPoints.storage_area },
          Zestafoni_Storage_Asset_1         =   { STATIC:FindByName( "Storage Area Zestafoni" ), "Storage Area Zestafoni",  targetPoints.storage_area },
          Zestafoni_Storage_Asset_2         =   { STATIC:FindByName( "Storage Area Zestafoni #001" ), "Storage Area Zestafoni #001",  targetPoints.storage_area },
          Zestafoni_Storage_Asset_3         =   { STATIC:FindByName( "Storage Area Zestafoni #002" ), "Storage Area Zestafoni #002",  targetPoints.storage_area },
          Khashuri_Storage_Asset_1         =   { STATIC:FindByName( "Blue Khashuri Magazine" ), "Blue Khashuri Magazine",  targetPoints.storage_area },
          Khashuri_Storage_Asset_2         =   { STATIC:FindByName( "Blue Khashuri Magazine #001" ), "Blue Khashuri Magazine #001",  targetPoints.storage_area },
          Khashuri_Storage_Asset_3         =   { STATIC:FindByName( "Blue Khashuri Magazine #002" ), "Blue Khashuri Magazine #002",  targetPoints.storage_area }


        },

        red = {

          Biteta_Storage_Asset_1            =   { STATIC:FindByName( "Biteta Storage Area #001" ), "Biteta Storage Area #001",  targetPoints.storage_area },
          Biteta_Storage_Asset_2            =   { STATIC:FindByName( "Biteta Storage Area #002" ), "Biteta Storage Area #002",  targetPoints.storage_area },
          Biteta_Storage_Asset_3            =   { STATIC:FindByName( "Biteta Storage Area #003" ), "Biteta Storage Area #003",  targetPoints.storage_area },
          Biteta_Storage_Asset_4            =   { STATIC:FindByName( "Biteta Storage Area #004" ), "Biteta Storage Area #004",  targetPoints.storage_area },
          Biteta_Storage_Asset_5            =   { STATIC:FindByName( "Biteta Storage Area #005" ), "Biteta Storage Area #005",  targetPoints.storage_area },
          Biteta_Storage_Asset_6            =   { STATIC:FindByName( "Biteta Storage Area #006" ), "Biteta Storage Area #006",  targetPoints.storage_area },
          Biteta_Storage_Asset_7            =   { STATIC:FindByName( "Biteta Storage Area #007" ), "Biteta Storage Area #007",  targetPoints.storage_area },
          Biteta_Storage_Asset_8            =   { STATIC:FindByName( "Biteta Storage Area #008" ), "Biteta Storage Area #008",  targetPoints.storage_area },
          Kvemo_Sba_Storage_Asset_1         =   { STATIC:FindByName( "Kvemo Sba Storage Area #001" ), "Kvemo Sba Storage Area #001",  targetPoints.storage_area },
          Kvemo_Sba_Storage_Asset_2         =   { STATIC:FindByName( "Kvemo Sba Storage Area #002" ), "Kvemo Sba Storage Area #002",  targetPoints.storage_area },
          Kvemo_Sba_Storage_Asset_3         =   { STATIC:FindByName( "Kvemo Sba Storage Area #003" ), "Kvemo Sba Storage Area #003",  targetPoints.storage_area },
          Kvemo_Sba_Storage_Asset_5         =   { STATIC:FindByName( "Kvemo Sba Storage Area #005" ), "Kvemo Sba Storage Area #005",  targetPoints.storage_area },
          Kvemo_Sba_Storage_Asset_6         =   { STATIC:FindByName( "Kvemo Sba Storage Area #006" ), "Kvemo Sba Storage Area #006",  targetPoints.storage_area },
          Kvemo_Kosha_Storage_Asset_1         =   { STATIC:FindByName( "Red Structure Kvemo Kosha #002" ), "Red Structure Kvemo Kosha #002",  targetPoints.storage_area },
          Kvemo_Kosha_Storage_Asset_2         =   { STATIC:FindByName( "Red Structure Kvemo Kosha #001" ), "Red Structure Kvemo Kosha #001",  targetPoints.storage_area },
          Kvemo_Kosha_Storage_Asset_3         =   { STATIC:FindByName( "Red Structure Kvemo Kosha" ), "Red Structure Kvemo Kosha",  targetPoints.storage_area }



        }


      } -- end structure


    -- INSERIRE qui gli altri target: strategic, army e quelli sotto gia' definiti

  } -- end staticObject



  if loggingLevel >= 4 then

    logging('info', { '- LIST STATIC OBJECT TABLE - ' , 'object: ' .. #staticObject } )

    for i1, k1 in pairs( staticObject) do

      logging('info', { ' - staticObject - ', i1 .. ' - object: ' .. #k1} )

      for i2, k2 in pairs(k1) do

        logging('info', { ' - staticObject - ', i2 .. ' - object: ' .. #k2 } )

        for i3, k3 in pairs(k2) do

          logging('info', { ' - staticObject - ', ' - ' .. i3 .. ' - ' .. k3[1]:GetName() .. '  -  ' .. k3[3][1] } )

          --for i4, k4 in pairs(k3) do


            --logging('info', {i4, ''} )
            --logging('info', { i4, k4[2] .. ' -  points: ' .. k4[3] } )

          --end

        end

      end

    end

  end






  -- Zone definite su target strutture (edifici, ponti) startegici (BAI, PINPOINT)
  local zoneTargetStructure = {

    Red_Didi_Bridges = {

      { ZONE:New('Target_Zone_Didi_Bridge_1'), 'Target_Zone_Didi_Bridge_1', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_2'), 'Target_Zone_Didi_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_3'), 'Target_Zone_Didi_Bridge_3', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_4'), 'Target_Zone_Didi_Bridge_4', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_5'), 'Target_Zone_Didi_Bridge_5', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_6'), 'Target_Zone_Didi_Bridge_6', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_7'), 'Target_Zone_Didi_Bridge_7', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_8'), 'Target_Zone_Didi_Bridge_8', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_9'), 'Target_Zone_Didi_Bridge_9', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_10'), 'Target_Zone_Didi_Bridge_10', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_11'), 'Target_Zone_Didi_Bridge_11', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_12'), 'Target_Zone_Didi_Bridge_12', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_13'), 'Target_Zone_Didi_Bridge_13', targetPoints.bridge }



    },

    Red_Biteta_Bridges = {


      { ZONE:New('Target Zone Biteta Storage Area'), 'Target Zone Biteta Storage Area', targetPoints.storage_area }


    },

    Red_Kvemo_Sba_Bridges = {


      { ZONE:New('Target Zone Kvemo Sba Storage Area'), 'Target Zone Kvemo Sba Storage Area', targetPoints.storage_area }


    },



    Blue_Kutaisi_Bridges = {

      { ZONE:New('Target_Zone_Kutaisi_Bridge_1'), 'Target_Zone_Kutaisi_Bridge_1', targetPoints.bridge },
      { ZONE:New('Target_Zone_Kutaisi_Bridge_2'), 'Target_Zone_Kutaisi_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Kutaisi_Bridge_3'), 'Target_Zone_Kutaisi_Bridge_3', targetPoints.bridge }


    },

    Red_Farm = {

      { ZONE:New('Target Zone Biteta Storage Area'), 'Target Zone Biteta Storage Area', targetPoints.storage_area },
      { ZONE:New('Target Zone Kvemo Sba Storage Area'), 'Target Zone Kvemo Sba Storage Area', targetPoints.storage_area }

    },

    Red_Military_Base = {

      { ZONE:New('Target_Zone_Beslan_EWR_Site'), 'Target_Zone_Beslan_EWR_Site', targetPoints.ewr_site }

    },

    Blue_Zestafoni_Bridges = {

      { ZONE:New('Target_Zone_Zestafoni_Bridge_1'), 'Target_Zone_Zestafoni_Bridge_1', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_2'), 'Target_Zone_Zestafoni_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_3'), 'Target_Zone_Zestafoni_Bridge_3', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_4'), 'Target_Zone_Zestafoni_Bridge_4', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_5'), 'Target_Zone_Zestafoni_Bridge_5', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_6'), 'Target_Zone_Zestafoni_Bridge_6', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_7'), 'Target_Zone_Zestafoni_Bridge_7', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_8'), 'Target_Zone_Zestafoni_Bridge_8', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_9'), 'Target_Zone_Zestafoni_Bridge_9', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_10'), 'Target_Zone_Zestafoni_Bridge_10', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_11'), 'Target_Zone_Zestafoni_Bridge_11', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_12'), 'Target_Zone_Zestafoni_Bridge_12', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_13'), 'Target_Zone_Zestafoni_Bridge_13', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_14'), 'Target_Zone_Zestafoni_Bridge_14', targetPoints.bridge },
      { ZONE:New('Target_Zone_Zestafoni_Bridge_15'), 'Target_Zone_Zestafoni_Bridge_15', targetPoints.bridge }

    },

    Blue_Gori_Bridges = {

      { ZONE:New('Target_Zone_Gori_Bridge_1'), 'Target_Zone_Gori_Bridge_1', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_2'), 'Target_Zone_Gori_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_3'), 'Target_Zone_Gori_Bridge_3', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_4'), 'Target_Zone_Gori_Bridge_4', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_5'), 'Target_Zone_Gori_Bridge_5', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_6'), 'Target_Zone_Gori_Bridge_6', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_7'), 'Target_Zone_Gori_Bridge_7', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_8'), 'Target_Zone_Gori_Bridge_8', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_9'), 'Target_Zone_Gori_Bridge_5', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_10'), 'Target_Zone_Gori_Bridge_10', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_11'), 'Target_Zone_Gori_Bridge_11', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_12'), 'Target_Zone_Gori_Bridge_12', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_13'), 'Target_Zone_Gori_Bridge_13', targetPoints.bridge },
      { ZONE:New('Target_Zone_Gori_Bridge_14'), 'Target_Zone_Gori_Bridge_14', targetPoints.bridge }


    },

    Blue_Tbilisi_Bridges = {

      { ZONE:New('Target_Zone_Tbilisi_Bridge_1'), 'Target_Zone_Tbilisi_Bridge_1', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_2'), 'Target_Zone_Tbilisi_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_3'), 'Target_Zone_Tbilisi_Bridge_3', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_4'), 'Target_Zone_Tbilisi_Bridge_4', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_5'), 'Target_Zone_Tbilisi_Bridge_5', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_6'), 'Target_Zone_Tbilisi_Bridge_6', targetPoints.bridge }
    },

    Blue_Farm = {

      { ZONE:New('Target Zone Gori Storage Area'), 'Target Zone Gori Storage Area', targetPoints.storage_area },
      { ZONE:New('Target_Zone_Zestafoni_Structure'), 'Target_Zone_Zestafoni_Structure', targetPoints.storage_area },
      { ZONE:New('Kaspi Target Zone'), 'Kaspi Target Zone', targetPoints.storage_area }

    },

    Blue_Military_Base = {

      { ZONE:New('Target_Zone_Kutaisi_EWR'), 'Target_Zone_Kutaisi_EWR', targetPoints.ewr_site }

    }

  }




 -- da
  local cargoZone = {

      Warehouse = {

        blue = {

           Zestafoni     =   ZONE:New( "Warehouse ZESTAFONI Spawn Zone" ),
           Gori          =   ZONE:New( "Gori WH Spawn Zone" ),
           Khashuri      =   ZONE:New( "Warehouse KHASHURI Spawn Zone" )


        },

        red = {

          Biteta        =   ZONE:New( "Warehouse Biteta Spawn Zone" ),
          Didi          =   ZONE:New( "Didi Warehouse Spawn Zone" ),
          Kvemo_Sba     =   ZONE:New( "Kvemo_Sba Warehouse Spawn Zone" ),
          Alagir        =   ZONE:New( "Alagir Warehouse Spawn Zone" )

        }

      },

      Warehouse_AB = {

        blue = {

          Vaziani       =   ZONE:New( "VazianiPickupZone" ),
          Soganlug      =   ZONE:New( "TbilisiPickupZone" ),
          Tbilisi       =   ZONE:New( "TbilisiPickupZone" ),
          Kutaisi       =   ZONE:New( "KutaisiPickupZone" ),
          Kvitiri       =   ZONE:New( "KvitiriPickupZone" ),
          Kvitiri_Helo  =   ZONE:New( "Kvitiri_HeloPickupZone" ),
          Batumi        =   ZONE:New( "BatumiPickupZone" )

        },

        red = {

          Mozdok        =   ZONE:New( "MozdockPickupZone" ),
          Mineralnye    =   ZONE:New( "MineralnyePickupZone" ),
          Beslan        =   ZONE:New( "BeslanPickupZone" ),
          Nalchik       =   ZONE:New( "NalchikPickupZone" )

        }

      },

      Stucture = {

        blue = {

          --Zestafoni_Railway_Station       =   ZONE:New( "PickupZone" ),
          --Agara_Railway_Station      =   ZONE:New( "PickupZone" )


        },

        red = {



        }

      }

  }






  -- le zone del fronte presidiate dai red
  local redFrontZone = {

        TSKHINVALI = { ZONE:New("TSKHINVALI") , "TSKHINVALI", targetPoints.front_zone },
        SATIHARI = { ZONE:New("SATIHARI") , "SATIHARI", targetPoints.front_zone },
        DIDMUKHA = { ZONE:New("DIDMUKHA") , "DIDMUKHA", targetPoints.front_zone },
        DIDI_CUPTA = { ZONE:New("DIDI_CUPTA") , "DIDI_CUPTA", targetPoints.front_zone },
        CZ_ONI = { ZONE:New("CZ_ONI") , "CZ_ONI", targetPoints.front_zone },
        CZ_PEREVI = { ZONE:New("CZ_PEREVI") , "CZ_PEREVI", targetPoints.front_zone }

  }

  -- le zone del fronte presidiate dai blue
  local blueFrontZone = {

        TSVERI = { ZONE:New("TSVERI") , "TSVERI", targetPoints.front_zone },
        TKVIAVI = { ZONE:New("TKVIAVI") , "TKVIAVI", targetPoints.front_zone },
        GORI = { ZONE:New("GORI") , "GORI", targetPoints.front_zone },
        HEOBA = { ZONE:New("HEOBA") , "HEOBA", targetPoints.front_zone },
        CZ_AMBROLAURI = { ZONE:New("CZ_AMBROLAURI") , "CZ_AMBROLAURI", targetPoints.front_zone },
        CZ_CHIATURA = { ZONE:New("CZ_CHIATURA") , "CZ_CHIATURA", targetPoints.front_zone }

  }

  -- Zone for red patrol mission: zone in territorio dei red
  local redPatrolZone = {

      mineralnye = { ZONE:New("Patrol_Zone_Mineralnye") , "Patrol_Zone_Mineralnye", targetPoints.front_zone },
      nalchik = { ZONE:New("Patrol_Zone_Nalchik") , "Patrol_Zone_Nalchik", targetPoints.front_zone },
      beslan = { ZONE:New("Patrol_Zone_Beslan") , "Patrol_Zone_Beslan", targetPoints.front_zone }

  }

  -- Zone for blue patrol mission: zone in territorio dei blue
  local bluePatrolZone = {

      tbilisi = { ZONE:New("Patrol_Zone_Tbilisi") , "Patrol_Zone_Tbilisi", targetPoints.front_zone },
      vaziani = { ZONE:New("Patrol_Zone_Vaziani") , "Patrol_Zone_Vaziani", targetPoints.front_zone },
      soganlug = { ZONE:New("Patrol_Zone_Soganlug") , "Patrol_Zone_Soganlug", targetPoints.front_zone },
      kutaisi = { ZONE:New("Patrol_Zone_Kutaisi") , "Patrol_Zone_Kutaisi", targetPoints.front_zone }

  }

  -- i target per l'arty dei blue
  -- imposterei target dei blue e toglierei il prefisso BLUE verifica la posizione delle zone
  local targetZoneForBlueArty = {

    DIDMUKHA_1 = { ZONE:New("RED_TARZ_DIDMUKHA_1") , "RED_TARZ_DIDMUKHA_1", targetPoints.front_zone },
    DIDMUKHA_2 = { ZONE:New("RED_TARZ_DIDMUKHA_2") , "RED_TARZ_DIDMUKHA_2", targetPoints.front_zone },
    DIDMUKHA_3 = { ZONE:New("RED_TARZ_DIDMUKHA_3") , "RED_TARZ_DIDMUKHA_3", targetPoints.front_zone },

    SATHIARI_1 = { ZONE:New("RED_TARZ_SATHIARI_1") , "RED_TARZ_SATHIARI_1", targetPoints.front_zone },
    SATHIARI_2 = { ZONE:New("RED_TARZ_SATHIARI_2") , "RED_TARZ_SATHIARI_2", targetPoints.front_zone },
    SATHIARI_3 = { ZONE:New("RED_TARZ_SATHIARI_3") , "RED_TARZ_SATHIARI_3", targetPoints.front_zone },

    TSKHINVALI_1 = { ZONE:New("RED_TARZ_TSKHINVALI_1") , "RED_TARZ_TSKHINVALI_1", targetPoints.front_zone },
    TSKHINVALI_2 = { ZONE:New("RED_TARZ_TSKHINVALI_2") , "RED_TARZ_TSKHINVALI_2", targetPoints.front_zone },

  }

  -- i target  per l'arty dei red
  local targetZoneForRedArty = {

    TKVIAVI_1 =   { ZONE:New("BLUE_TARZ_TKVIAVI_1") , "BLUE_TARZ_TKVIAVI_1", targetPoints.front_zone },
    TKVIAVI_2 =   { ZONE:New("BLUE_TARZ_TKVIAVI_2") , "BLUE_TARZ_TKVIAVI_2", targetPoints.front_zone },
    TKVIAVI_3 =   { ZONE:New("BLUE_TARZ_TKVIAVI_3") , "BLUE_TARZ_TKVIAVI_3", targetPoints.front_zone },
    TKVIAVI_4 =   { ZONE:New("BLUE_TARZ_TKVIAVI_4") , "BLUE_TARZ_TKVIAVI_4", targetPoints.front_zone },

    TSVERI_1 =   { ZONE:New("BLUE_TARZ_TSVERI_1") , "BLUE_TARZ_TSVERI_1", targetPoints.front_zone },
    TSVERI_2 =   { ZONE:New("BLUE_TARZ_TSVERI_2") , "BLUE_TARZ_TSVERI_2", targetPoints.front_zone },
    TSVERI_3 =   { ZONE:New("BLUE_TARZ_TSVERI_3") , "BLUE_TARZ_TSVERI_3", targetPoints.front_zone },
    TSVERI_4 =   { ZONE:New("BLUE_TARZ_TSVERI_4") , "BLUE_TARZ_TSVERI_4", targetPoints.front_zone },
    TSVERI_5 =   { ZONE:New("BLUE_TARZ_TSVERI_5") , "BLUE_TARZ_TSVERI_5", targetPoints.front_zone },
    TSVERI_6 =   { ZONE:New("BLUE_TARZ_TSVERI_6") , "BLUE_TARZ_TSVERI_6", targetPoints.front_zone },

    KHASHURI_1 =  { ZONE:New("BLUE_TARZ_KHASHURI_1") , "BLUE_TARZ_KHASHURI_1", targetPoints.front_zone },
    KHASHURI_2 =  { ZONE:New("BLUE_TARZ_KHASHURI_2") , "BLUE_TARZ_KHASHURI_2", targetPoints.front_zone }

  }

  local afacZone = {

    Didmukha_Tsveri =       { ZONE:New("AFAC_ZONE_Didmukha_Tsveri") , "AFAC_ZONE_Didmukha_Tsveri", targetPoints.front_zone },
    Tskhunvali_Tkviavi =    { ZONE:New("AFAC_ZONE_Tskhunvali_Tkviavi") , "AFAC_ZONE_Tskhunvali_Tkviavi", targetPoints.front_zone },
    Sathiari_Tkviavi =      { ZONE:New("AFAC_ZONE_Sathiari_Tkviavi") , "AFAC_ZONE_Sathiari_Tkviavi", targetPoints.front_zone },
    Didi_South =            { ZONE:New("AFAC_ZONE_Didi_South") , "AFAC_ZONE_Didi_South", targetPoints.front_zone },
    Khashuri_Est =          { ZONE:New("AFAC_ZONE_Khashuri_Est") , "AFAC_ZONE_Khashuri_Est", targetPoints.front_zone }

  }



  local redAwacsZone = {

    nalchik =       ZONE:New("Red AWACS ZONE NALCHIK"),
    beslan =        ZONE:New("Red AWACS ZONE BESLAN") ,
    alagir =        ZONE:New("Red AWACS ZONE ALAGIR")

  }

  local blueAwacsZone = {

    kutaisi =       ZONE:New("Blue AWACS ZONE KUTAISI"),
    gori =          ZONE:New("Blue AWACS ZONE GORI") ,
    tbilisi =       ZONE:New("Blue AWACS ZONE TBILISI")

  }



  local redGroundGroup = {

    { GROUP:FindByName('GW_1975 Russian Armor Defence@Nabakevi'), targetPoints.armored },
    { GROUP:FindByName('Russian Antitank Defence@Didmukha'), targetPoints.antitank },
    { GROUP:FindByName('Russian Mechanized Defence@Didmukha'), targetPoints.mechanized },
    { GROUP:FindByName('Russian Antitank Defence@Tskhinvali'), targetPoints.antitank },
    { GROUP:FindByName('RU HQ AirDefence'), targetPoints.sam },
    { GROUP:FindByName('Russian Antitank Defence@Sathiari'), targetPoints.antitank },
    { GROUP:FindByName('RED_HQ'), targetPoints.hq },
    { GROUP:FindByName('GW_1975 Russian Mechanized Defence@Oni'), targetPoints.mechanized },
    { GROUP:FindByName('SAM SA-2 Biteta'), targetPoints.sam },
    { GROUP:FindByName('SAM SA-6 Didi Farp'), targetPoints.sam },
    { GROUP:FindByName('SAM SA-6 Kvemo Sba Farp'), targetPoints.sam },
    { GROUP:FindByName('SAM SA-2 Beslan EWR'), targetPoints.sam },
    { GROUP:FindByName('DF CCCP EWR  Mineralnye'), targetPoints.ewr_site },
    { GROUP:FindByName('DF CCCP EWR  Beslan'), targetPoints.ewr_site },
    { GROUP:FindByName('Alagir SAM-2 Defence'), targetPoints.sam }



  }

  local blueGroundGroup = {

    { GROUP:FindByName('Georgian Armored Defence@Khashuri'), targetPoints.armored },
    { GROUP:FindByName('Georgian Mechanized Defence@Tsveri'), targetPoints.mechanized },
    { GROUP:FindByName('Georgian Antitank Defence@Tsveri B'), targetPoints.antitank },
    { GROUP:FindByName('Mecha Nato Group 1'), targetPoints.mechanized },
    { GROUP:FindByName('GW_1975 Russian Armor Defence@Nabakevi #003'), targetPoints.armored },
    { GROUP:FindByName('Georgian AAA HQ'), targetPoints.sam },
    { GROUP:FindByName('BLUE_HQ'), targetPoints.hq },
    { GROUP:FindByName('Georgian Mechanized Defence@Tkviavi B'), targetPoints.mechanized },
    { GROUP:FindByName('NATO GROUND MECHA ATTACK A #017'), targetPoints.mechanized },
    { GROUP:FindByName('Georgian Mechanized Defence Squad@Tkviavi B'), targetPoints.mechanized },
    { GROUP:FindByName('DF GEORGIA EWR Kutaisi'), targetPoints.ewr_site },
    { GROUP:FindByName('SAM SA-2 EWR Kutaisi'), targetPoints.sam },
    { GROUP:FindByName('Georgian SA-3 Kutaisi'), targetPoints.sam },
    { GROUP:FindByName('DF GEORGIA EWR Tbilisi'), targetPoints.ewr_site },
    { GROUP:FindByName('SAM SA-2 Tbilisi'), targetPoints.sam },
    { GROUP:FindByName('Georgian SA-3 Vaziani'), targetPoints.sam },
    { GROUP:FindByName('Georgian SA-3 Tbilisi'), targetPoints.sam }


  }




    -- CAP ZONE



  local cap_zone_db_red = {

    [1] = 'RED CAP ZONE BESLAN',
    [2] = 'RED CAP ZONE NALCHIK',
    [3] = 'RED CAP ZONE TEBERDA',
    [4] = 'RED CAP ZONE SOCHI'

    }


  local cap_zone_db_blue = {

    [1] = 'BLUE CAP ZONE TBILISI',
    [2] = 'BLUE CAP ZONE KUTAISI',
    [3] = 'BLUE CAP ZONE SUKUMI',
    [4] = 'BLUE CAP ZONE SOCHI GUDAUTA'

    }







































  ------------------------------------------------------------------------------  SCORING & TARGET ASSIGN -------------------------------------------------------------------------------

  -- Static, Group an Zone that are specific target (for pinpoint mission)
  local specific_target = {

    red = { group_targ = {}, zone_targ = {}, static_targ = {} },
    blue = { group_targ = {}, zone_targ = {}, static_targ = {} }

  }

  -- Zone that are searching area target
  local global_target_zone = { red = {}, blue = {} }


  Scoring = SCORING:New( "1975_GW_Scoring" )

  Scoring:SetScaleDestroyScore( 100 )

  Scoring:SetScaleDestroyPenalty( 400 )

  local gtrg, gtrz, gtrs, gtbg, gtbz, gtbs, gtr, gtb = 1, 1, 1, 1, 1, 1, 1, 1

  --Scoring:AddUnitScore( UNIT:FindByName( "Unit #001" ), 200 )


  -- Assignment for targetZone
  for k, targetZone in pairs(zoneTargetStructure) do

    logging( 'finest', { 'main' , 'assign score an target for: ' .. k } )

    for i = 1, #targetZone do

      Scoring:AddZoneScore( targetZone[i][1], targetZone[i][3] )
      logging('finest', { 'main' , 'assign score@: ' .. targetZone[i][1]:GetName()  .. ' - score value = ' .. targetZone[i][3][1] } )

      if string.find( k,'Blue')  then

        specific_target.blue.zone_targ[gtbz] = targetZone[i][1]
        logging('finest', { 'main' , 'assign specific_target.blue.zone_targ[ ' .. gtbz .. '] = '  .. targetZone[i][1]:GetName() } )
        gtbz = gtbz + 1

      elseif string.find( k,'Red')  then

        specific_target.red.zone_targ[gtrz] = targetZone[i][1]
        logging('finest', { 'main' , 'assign specific_target.red.zone_targ[ ' .. gtrz .. '] = ' .. targetZone[i][1]:GetName() } )
        gtrz = gtrz + 1

      end

    end

  end



  -- Assignment for redFrontZone
  for _, v in pairs(redFrontZone) do

    Scoring:AddZoneScore( v[1], v[3] )
    global_target_zone.red[gtr] = v[1]
    logging('finest', { 'main' , 'assign score and global_target_zone.red[ ' .. gtr .. '] = ' .. v[1]:GetName() .. ' - score value = ' .. v[3][1] } )
    gtr = gtr + 1

  end


  -- Assignment for blueFrontZone
  for _, v in pairs(blueFrontZone) do

    Scoring:AddZoneScore( v[1], v[3] )
    global_target_zone.blue[gtb] = v[1]
    logging('finest', { 'main' , 'assign score and global_target.blue[ ' .. gtb .. '] = ' .. v[1]:GetName() .. ' - score value = ' .. v[3][1] } )
    gtb = gtb + 1

  end


  -- Assignment for afacZone
  for i = 1, #afacZone do

    Scoring:AddZoneScore( afacZone[i][1], afacZone[i][3] )

  end

  -- Assignment for targetZoneForBlueArty
  for _, v in pairs(targetZoneForBlueArty) do

    Scoring:AddZoneScore( v[1], v[3] )
    global_target_zone.red[gtr] = v[1]
    logging('finest', { 'main' , 'assign score and global_target_zone.red[ ' .. gtr .. '] = ' .. v[1]:GetName() .. ' - score value = ' .. v[3][1] } )
    gtr = gtr + 1

  end

  -- Assignment for targetZoneForRedArty
  for _, v in pairs(targetZoneForRedArty) do

    Scoring:AddZoneScore( v[1], v[3] )
    global_target_zone.blue[gtb] = v[1]
    logging('finest', { 'main' , 'assign score and global_target_zone.red[ ' .. gtb .. '] = ' .. v[1]:GetName() .. ' - score value = ' .. v[3][1] } )
    gtb = gtb + 1

  end



  -- Assignment for staticObject
  logging('finest', { 'main' , 'num static_object = ' .. #staticObject } )

  for k, type in pairs( staticObject ) do

    logging('finest', { 'main' , 'static_object - type: ' .. k } )

    for h, faction in pairs(type) do

      logging('finest', { 'main' , 'static_object - faction: ' .. h } )

        for j, targetObject in pairs(faction) do

          Scoring:AddStaticScore( targetObject[1], targetObject[3] )

          if string.find( h,'blue')  then

            specific_target.blue.static_targ[gtbs] = targetObject[1]
            logging('finest', { 'main' , ' - assign score and specific_target.blue.static_targ[ ' .. gtbs .. '] = ' .. targetObject[1]:GetName() .. ' - score value = ' .. targetObject[3][1] } )
            gtbs = gtbs + 1

          elseif string.find( h,'red')  then

            specific_target.red.static_targ[gtbs] = targetObject[1]
            logging('finest', { 'main' , ' - assign score and specific_target.red.static_targ[ ' .. gtrs .. '] = ' .. targetObject[1]:GetName() .. ' - score value = ' .. targetObject[3][1] } )
            gtrs = gtrs + 1

          end

        end

    end

  end





  -- Assignment for redGroundGroup
  for i = 1, #redGroundGroup do

    Scoring:AddScoreGroup( redGroundGroup[i][1], redGroundGroup[i][2] )
    specific_target.red.group_targ[gtrg] = redGroundGroup[i][1]
    logging('finest', { 'main' , 'assign score and specific_target.red.group_targ[ ' .. gtrg .. '] = ' .. redGroundGroup[i][1]:GetName() .. ' - score value = ' .. redGroundGroup[i][2][1] } )
    gtrg = gtrg + 1

  end

  -- Assignment for blueGroundGroup
  for i = 1, #blueGroundGroup do

    Scoring:AddScoreGroup( blueGroundGroup[i][1], blueGroundGroup[i][2] )
    specific_target.blue.group_targ[gtbg] = blueGroundGroup[i][1]
    logging('finest', { 'main' , 'assign score and specific_target.blue.group_targ[ ' .. gtbg .. '] = ' .. blueGroundGroup[i][1]:GetName() .. ' - score value = ' .. blueGroundGroup[i][2][1] } )
    gtbg = gtbg + 1

  end




  ------------------------------------------------------------------------------------------------------------------------------------------------------------------


  if loggingLevel >= 4 then

    --- Printing logging info for specific_target table
    for k, v in pairs(specific_target) do

      logging( 'info', { 'main' , 'specific_target - faction = ' .. k } )

      for h, w in pairs(v) do

        logging( 'info', { 'main' , 'specific_target - target type = ' .. h } )

        for _, j in pairs(w)  do

          logging( 'info', { 'main' , 'specific_target - target name = ' .. j:GetName() } )

        end

      end

    end


    --- Printing logging info for global_target_zone table
    for k, v in pairs(global_target_zone) do

      logging( 'info', { 'main' , 'global_target_zone - faction = ' .. k } )

      for h, w in pairs(v) do

        logging( 'info', { 'main' , 'global_target_zone - target name = ' .. w:GetName() } )

      end

    end

  end
























































  -- Crea il blue command center selezionando l'unita' HQ
  HQ_BLUE = GROUP:FindByName( 'BLUE_HQ' )
  blue_command_center = COMMANDCENTER:New( HQ_BLUE, 'BLUE_HQ' )

  -- Crea il blue command center selezionando l'unita' HQ
  HQ_RED = GROUP:FindByName( 'RED_HQ' )
  red_command_center = COMMANDCENTER:New( HQ_RED, 'RED_HQ' )


  -- SET_Group dedicati alla Detection A2G
  -- Red side
  detectionGroupSetRed = SET_GROUP:New() -- Defense a set of group objects, called DetectionSetGroup.
  detectionGroupSetRed:FilterPrefixes( { "SQ red REC", "SQ red FAC", "RUSSIAN JTAC", "SQ red REC" } ) -- The DetectionSetGroup will search for groups that start with the name



  -- Blue side
  detectionGroupSetBlue = SET_GROUP:New() -- Defense a set of group objects, called DetectionSetGroup.
  detectionGroupSetBlue:FilterPrefixes( { "SQ blue REC", "SQ blue FAC", "GEORGIAN JTAC", "SQ blue REC" } ) -- The DetectionSetGroup will search for groups that start with the name



  -- SET_Group dedicati alla Detection A2A
  -- Red side
  detectionGroupSetRedA2A = SET_GROUP:New() -- Defense a set of group objects, called DetectionSetGroup.
  detectionGroupSetRedA2A:FilterPrefixes( { "DF CCCP AWACS", "DF CCCP EWR", "SQ red AWACS" } ) -- The DetectionSetGroup will search for groups that start with the name



  -- Blue side
  detectionGroupSetBlueA2A = SET_GROUP:New() -- Defense a set of group objects, called DetectionSetGroup.
  detectionGroupSetBlueA2A:FilterPrefixes( { "DF GEORGIA AWACS", "DF GEORGIA EWR", "DF USA EWR", "DF USA AWACS", "SQ blue AWACS" } ) -- The DetectionSetGroup will search for groups that start with the name



























  -- WAREHOUSE



  logging('info', { 'main' , ' --------------------------------------------------  INIT WAREHOUSE SYSTEM'} )


















  -- CREATING WAREHOUSE
  local warehouse={}

  warehouse.Didi          =   WAREHOUSE:New( staticObject.Warehouse.red.Didi[ 1 ], staticObject.Warehouse.red.Didi[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Biteta        =   WAREHOUSE:New( staticObject.Warehouse.red.Biteta[ 1 ], staticObject.Warehouse.red.Biteta[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Kvemo_Sba     =   WAREHOUSE:New( staticObject.Warehouse.red.Kvemo_Sba[ 1 ], staticObject.Warehouse.red.Kvemo_Sba[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Alagir        =   WAREHOUSE:New( staticObject.Warehouse.red.Alagir[ 1 ], staticObject.Warehouse.red.Alagir[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Mineralnye    =   WAREHOUSE:New( staticObject.Warehouse_AB.red.Mineralnye[ 1 ], staticObject.Warehouse_AB.red.Mineralnye[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Mozdok        =   WAREHOUSE:New( staticObject.Warehouse_AB.red.Mozdok[ 1 ], staticObject.Warehouse_AB.red.Mozdok[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Beslan        =   WAREHOUSE:New( staticObject.Warehouse_AB.red.Beslan[ 1 ], staticObject.Warehouse_AB.red.Beslan[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Nalchik       =   WAREHOUSE:New( staticObject.Warehouse_AB.red.Nalchik[ 1 ], staticObject.Warehouse_AB.red.Nalchik[ 2 ])  --Functional.Warehouse#WAREHOUSE


  warehouse.Batumi        =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Batumi[ 1 ], staticObject.Warehouse_AB.blue.Batumi[ 2 ])   --Functional.Warehouse#WAREHOUSE
  warehouse.Kutaisi       =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Kutaisi[ 1 ],  staticObject.Warehouse_AB.blue.Kutaisi[ 2 ] )  --Functional.Warehouse#WAREHOUSE
  warehouse.Kvitiri       =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Kvitiri[ 1 ], staticObject.Warehouse_AB.blue.Kvitiri[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Kvitiri_Helo  =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Kvitiri_Helo[ 1 ], staticObject.Warehouse_AB.blue.Kvitiri_Helo[ 2 ])  --Functional.Warehouse#WAREHOUSE
  warehouse.Zestafoni     =   WAREHOUSE:New( staticObject.Warehouse.blue.Zestafoni[ 1 ], staticObject.Warehouse.blue.Zestafoni[ 2 ] )  --Functional.Warehouse#WAREHOUSE
  warehouse.Khashuri      =   WAREHOUSE:New( staticObject.Warehouse.blue.Khashuri[ 1 ], staticObject.Warehouse.blue.Khashuri[ 2 ] )  --Functional.Warehouse#WAREHOUSE
  warehouse.Gori          =   WAREHOUSE:New( staticObject.Warehouse.blue.Gori[ 1 ], staticObject.Warehouse.blue.Gori[ 2 ] )  --Functional.Warehouse#WAREHOUSE
  warehouse.Tbilisi       =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Tbilisi[ 1 ], staticObject.Warehouse_AB.blue.Tbilisi[ 2 ] )  --Functional.Warehouse#WAREHOUSE                                      warehouse.Vaziani = WAREHOUSE:New( staticObject.Warehouse_AB.blue.Vaziani[ 1 ], staticObject.Warehouse_AB.blue.Vaziani[ 2 ] )  --Functional.Warehouse#WAREHOUSE
  warehouse.Vaziani       =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Vaziani[ 1 ], staticObject.Warehouse_AB.blue.Vaziani[ 2 ] )  --Functional.Warehouse#WAREHOUSE
  warehouse.Soganlug      =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Soganlug[ 1 ], staticObject.Warehouse_AB.blue.Soganlug[ 2 ] )  --Functional.Warehouse#WAREHOUSE




  local warehouse_red = {

    farp = {

      warehouse.Didi,
      warehouse.Biteta,
      warehouse.Kvemo_Sba,
      warehouse.Alagir
    },

    airbase = {

      warehouse.Mineralnye,
      warehouse.Mozdok,
      warehouse.Beslan,
      warehouse.Nalchik
    }
  }

  local warehouse_blue = {

    farp = {

      warehouse.Zestafoni,
      warehouse.Khashuri,
      warehouse.Gori
    },

    airbase = {

      warehouse.Batumi,
      warehouse.Kutaisi,
      warehouse.Kvitiri,
      warehouse.Kvitiri_Helo,
      warehouse.Tbilisi,
      warehouse.Vaziani,
      warehouse.Soganlug

    }
  }



























  --------------------------------         RED WAREHOUSE OPERATION   ------------------------------------------------------------------------------------------































  -------------------------------------- red DIDI warehouse operations -------------------------------------------------------------------------------------------------------

  if wh_activation.Warehouse.red.Didi[ 1 ] then

      logging('info', { 'main' , 'addAsset Didi warehouse'} )

      warehouse.Didi:SetSpawnZone( ZONE:New("Didi Warehouse Spawn Zone") )
      warehouse.Didi:Start()


      warehouse.Didi:AddAsset(                 "Infantry Platoon Alpha",                   30)
      warehouse.Didi:AddAsset(                ground_group_template_red.antitankA,         10,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])] )
      warehouse.Didi:AddAsset(                ground_group_template_red.antitankB,         10,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])] )
      warehouse.Didi:AddAsset(                ground_group_template_red.antitankC,         10,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])] )
      warehouse.Didi:AddAsset(                ground_group_template_red.ArtiAkatsia,       10,           WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])] )
      warehouse.Didi:AddAsset(                ground_group_template_red.ArtiGwozdika,      10,           WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])] )
      warehouse.Didi:AddAsset(                ground_group_template_red.ArtiKatiusha,      10,           WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])] )
      warehouse.Didi:AddAsset(                ground_group_template_red.ArtilleryResupply, 10,           WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])] )
      warehouse.Didi:AddAsset(                ground_group_template_red.jtac,              10,           WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])] )
      warehouse.Didi:AddAsset(                air_template_red.TRAN_MI_26,                 20,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 1500, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])] ) -- attack
      warehouse.Didi:AddAsset(                air_template_red.AFAC_MI_24,                 20,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC
      warehouse.Didi:AddAsset(                air_template_red.AFAC_Mi_8MTV2,              20,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC


      logging('info', { 'main' , 'addrequest Didi warehouse'} )


      local didi_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
      local num_mission = 4
      local num_mission_helo = 3
      local depart_time_helo = defineRequestPosition( num_mission_helo ) -- heli mission
      local depart_time = defineRequestPosition( num_mission ) -- ground mission
      local pos = 1
      local pos_heli = 1
      local startReqTimeArtillery = 1 -- Arty groups have first activation
      local startReqTimeGround = startReqTimeArtillery + 420 -- Mech Groups are activated after 7'
      local sched_interval =  math.max(num_mission, num_mission_helo) * waitReqTimeGround / activeGroundRequestRatio

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local didi_sched = SCHEDULER:New( warehouse.Didi,

        function()

          -- artillery request
          warehouse.Didi:__AddRequest( startReqTimeArtillery, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.ArtilleryResupply, 1, nil, nil, nil, 'DIDI_Artillery_Resupply' )
          warehouse.Didi:__AddRequest( startReqTimeArtillery + 120 , warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.ArtiAkatsia, 1, nil, nil, nil, 'DIDI_Artillery_Ops')

          if wh_activation.Warehouse.red.Didi[ 15 ] and pos_heli <= num_mission_helo then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_MI_24, AssetQty.red.heli.recon[1], AssetQty.red.heli.recon[2], nil, nil, nil, 'AFAC_ZONE_Tskhunvali_Tkviavi') pos_heli = pos_heli + 1 end
          if wh_activation.Warehouse.red.Didi[ 15 ] and pos_heli <= num_mission_helo then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_Mi_8MTV2, AssetQty.red.heli.recon[1], AssetQty.red.heli.recon[2], nil, nil, nil, 'AFAC_ZONE_Khashuri_Est') pos_heli = pos_heli + 1 end
          if wh_activation.Warehouse.red.Didi[ 15 ] and pos_heli <= num_mission_helo then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_Mi_8MTV2, AssetQty.red.heli.recon[1], AssetQty.red.heli.recon[2], nil, nil, nil, 'AFAC_Didmukha_Tsveri') pos_heli = pos_heli + 1 end
          if wh_activation.Warehouse.red.Didi[ 12 ] and pos <= num_mission then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankA, math.random( AssetQty.red.ground.attack[1], AssetQty.red.ground.attack[2] ), nil, nil, nil, 'tkviavi_attack_1' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Didi[ 12 ] and pos <= num_mission then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, math.random( AssetQty.red.ground.attack[1], AssetQty.red.ground.attack[2] ), nil, nil, nil, 'tkviavi_attack_2' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Didi[ 12 ] and pos <= num_mission then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankC, math.random( AssetQty.red.ground.attack[1], AssetQty.red.ground.attack[2] ), nil, nil, nil, 'tseveri_attack_1' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Didi[ 13 ] and pos <= num_mission then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.jtac, math.random( AssetQty.red.ground.recon[1], AssetQty.red.ground.recon[2] ), nil, nil, nil, 'JTAC Tsveri' ) pos = pos + 1  end

          logging('finer', { 'Didi scheduler function' , 'addRequest Didi warehouse'} )

        end, {}, start_ground_sched * didi_efficiency_influence, sched_interval, rand_ground_sched

      ) -- END SCHEDULER


      local groupResupplySet

      -- Take care of the spawned units.
      function warehouse.Didi:OnAfterSelfRequest( From,Event,To,groupset,request )

        logging('enter', 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' )

        local groupset = groupset --Core.Set#SET_GROUP
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        local suppr_param = {retreatZone = nil, fallBack = true, takeCover = true, delay = 300}

        -- Get assignment of this request.
        local assignment = warehouse.Didi:GetAssignment(request)

        logging('finer', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

        if assignment == 'tkviavi_attack_1' then

            activeGO_TO_BATTLE( groupset, redFrontZone.TSKHINVALI[1], 'enemy_attack', false, 1, true, suppr_param  )


        elseif assignment == 'tkviavi_attack_2' then

            activeGO_TO_BATTLE( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1, true, suppr_param  )


        elseif assignment == 'tseveri_attack_1' then

            activeGO_TO_BATTLE( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1, true, suppr_param )


        elseif assignment =='AFAC_ZONE_Tskhunvali_Tkviavi' then

          activeJTAC( 'air', warehouse.Didi, groupset, red_command_center, nil, afacZone.Tskhunvali_Tkviavi[ 1 ] )


        elseif assignment == 'AFAC_ZONE_Didmukha_Tsveri' then

          activeJTAC( 'air', warehouse.Didi, groupset, red_command_center, nil, afacZone.Didmukha_Tsveri[ 1 ] )



        elseif assignment == 'AFAC_Khashuri_Est' then -- att: Jtac are ground mission (i think)

          activeJTAC( 'air', warehouse.Didi, groupset, red_command_center, nil, afacZone.Khashuri_Est[ 1 ] )



        elseif assignment == 'JTAC Tsveri' then -- att: Jtac are ground mission (i think)

          activeJTAC( 'ground', warehouse.Didi, groupset, red_command_center, nil, afacZone.Didmukha_Tsveri[ 1 ] )



        -- launch mission function: arty resupply
        elseif assignment == 'DIDI_Artillery_Resupply' then

          groupResupplySet = groupset
          -- controlla se targetZoneForRedArty.TSVERI_5 e' coerente come posizione
          --rndTrgGori.artillery[ pos_arty[ 1 ] + 1 ][ 2 ]
          activeGO_TO_ZONE_GROUND( groupset, targetZoneForBlueArty.TSKHINVALI_2[1], false, 1 )



        -- launch mission function: arty
        elseif assignment == 'DIDI_Artillery_Ops' then

            nameArtyUnits = groupset:GetObjectNames()   -- "Artillery"
            -- nameRecceUnits = recceArtyGroup.GetName()  -- "Recce"
            activateDetectionReport = false


            -- lista dei target e delle ammo
            param = {

                listTargetInfo = {

                    --targetInfo.targetCoordinate,  targetInfo.priority, targetInfo.radiusTarget, targetInfo.num_shots, targetInfo.num_engagements, nil, targetInfo.weaponType

                    [1] = {
                      targetCoordinate = targetZoneForRedArty.TKVIAVI_2[1]:GetRandomCoordinate(),
                      priority = 10,
                      radiusTarget = 500,
                      num_shots = 10,
                      num_engagements = 10,
                      weaponType = ARTY.WeaponType.Auto
                    },

                    [2] = {
                      targetCoordinate = targetZoneForRedArty.TKVIAVI_3[1]:GetRandomCoordinate(),
                      priority = 50,
                      radiusTarget = 500,
                      num_shots = 10,
                      num_engagements = 7,
                      weaponType = ARTY.WeaponType.Auto
                    },

                    [3] = {
                      targetCoordinate = targetZoneForRedArty.TKVIAVI_4[1]:GetRandomCoordinate(),
                      priority = 50,
                      radiusTarget = 500,
                      num_shots = 10,
                      num_engagements = 7,
                      weaponType = ARTY.WeaponType.Auto
                    }

                },

                commandCenter = blue_command_center,

                resupplySet = groupResupplySet,

                speed = 60, -- km/h Akatsia max 60 km/h

                onRoad = true,

                maxDistance = 20,

                maxFiringRange = 17000 -- Akatsia min range 0.3 km, max range 17.0 km


            }


            logging('info', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  -  groupSet = ' .. groupset:GetObjectNames() .. ' -  num target assigned = ' .. #param .. ' -  groupResupplySet = ' .. groupResupplySet:GetObjectNames()  } )

            activeGO_TO_ARTY( groupset, targetZoneForBlueArty.TSKHINVALI_2[1], param, true, 70 )

        else

            logging('warning', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )


        end -- if elseif else


      end -- end function warehouse.Didi:OnAfterSelfRequest( From,Event,To,groupset,request )


  end -- wh_activation.Warehouse.red.Didi then

  -- END red DIDI warehouse operations -------------------------------------------------------------------------------------------------------------------------













































  ---------------------------------------------- red BITETA warehouse operations ------------------------------------------------------------------------------------------------------------

  if wh_activation.Warehouse.red.Biteta[ 1 ] then

      -- Biteta warehouse e' una supply line warehouse: funziona da collegamento per il trasferimento degli asset tra i diversi nodi della supply line



      warehouse.Biteta:SetSpawnZone(ZONE:New("Warehouse Biteta Spawn Zone"))

      warehouse.Biteta:Start()

      -- Biteta: front farp-warehouse.  Receive resupply from Didi

      warehouse.Biteta:AddAsset(                "Infantry Platoon Alpha", 50 )
      warehouse.Biteta:AddAsset(              ground_group_template_red.antitankC,        10,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])])
      warehouse.Biteta:AddAsset(              ground_group_template_red.antitankB,        10,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])])
      warehouse.Biteta:AddAsset(              air_template_red.CAS_MI_24V,                20,           WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]    ) -- attack
      warehouse.Biteta:AddAsset(              air_template_red.TRAN_MI_24,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           1500, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]   ) -- attack
      warehouse.Biteta:AddAsset(              air_template_red.AFAC_MI_24,                10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC
      warehouse.Biteta:AddAsset(              air_template_red.AFAC_Mi_8MTV2,             10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC

      logging('info', { 'main' , 'addAsset Biteta warehouse' } )


      local ambrolauri_attack_1 = 'AMBROLAURI_attack_1'
      local chiatura_attack_1 = 'CHIATURA_attack_1'

      logging('info', { 'main' , 'addRequest Biteta warehouse'} )

      --local depart_time = defineRequestPosition(3)
      local biteta_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)

      local num_mission = 3
      local num_mission_helo = 1
      local depart_time = defineRequestPosition( num_mission )
      local depart_time_heli = defineRequestPosition( num_mission_helo ) -- heli mission
      local pos = 1
      local pos_heli = 1
      local sched_interval =  math.max(num_mission, num_mission_helo) * waitReqTimeGround / activeGroundRequestRatio

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local biteta_sched = SCHEDULER:New( warehouse.Biteta,

        function()

          if wh_activation.Warehouse.red.Biteta[ 12 ] and pos <= num_mission then warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, math.random( AssetQty.red.ground.attack[1], AssetQty.red.ground.attack[2] ), nil, nil, nil, 'AMBROLAURI_attack_1' ) pos = pos + 1 end
          if wh_activation.Warehouse.red.Biteta[ 12 ] and pos <= num_mission then warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, math.random( AssetQty.red.ground.attack[1], AssetQty.red.ground.attack[2] ), nil, nil, nil, 'CHIATURA_attack_1' ) pos = pos + 1 end
          if wh_activation.Warehouse.red.Biteta[ 14 ] and pos <= num_mission  then warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.TransportA, math.random( AssetQty.red.ground.transport[1], AssetQty.red.ground.transport[2] ), nil, nil, nil, 'Transfert to Didi' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Biteta[ 15 ] and pos_heli <= num_mission_helo then warehouse.Didi:__AddRequest( startReqTimeGround + ( depart_time_heli[ pos_heli ] + 1 ) * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_Mi_8MTV2, math.random( AssetQty.red.heli.recon[1], AssetQty.red.heli.recon[2] ), nil, nil, nil, 'AFAC_CZ_ONI') pos_heli = pos_heli + 1 end
          --warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[3] * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, 2, nil, nil, nil, 'PEREVI_APC' ) pos = pos + 1 end

          logging('finer', { 'Biteta scheduler function' , 'addRequest Biteta warehouse'} )

        end, {}, start_ground_sched * biteta_efficiency_influence, sched_interval, rand_ground_sched

      )  -- END SCHEDULER



      -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
      -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati

      function warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)

          logging('enter', 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' )

          local groupset = groupset --Core.Set#SET_GROUP
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem
          local suppr_param = {retreatZone = nil, fallBack = true, takeCover = true, delay = 300}

          -- Get assignment of this request.
          local assignment=warehouse.Biteta:GetAssignment(request)

          logging('info', { 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

          if assignment == 'AMBROLAURI_attack_1' then

              activeGO_TO_BATTLE( groupset, blueFrontZone.CZ_AMBROLAURI[1], 'enemy_attack', false, 1, true, suppr_param)


          elseif assignment == 'CHIATURA_attack_1' then

              activeGO_TO_BATTLE( groupset, blueFrontZone.CZ_CHIATURA[1], 'enemy_attack', false, 1, true, suppr_param )


          elseif assignment == 'AFAC_CZ_ONI' then

              activeJTAC( 'air', warehouse.Didi, groupset, red_command_center, nil, afacZone.Tskhunvali_Tkviavi[ 1 ] )



          else

              logging('warning', { 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )

          end -- if elsif else


          logging('exit', 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' )

      end -- end function




  end -- wh_activation.Warehouse.red.Biteta then

  -- END red BITETA warehouse operations --------------------------------------------------------------------------------------------------------------------------
















































  ------------------------------------------------- red Warehouse KVEMO_SBA operations -------------------------------------------------------------------------------------------------------------------------

  if wh_activation.Warehouse.red.Kvemo_Sba[1] then


      warehouse.Kvemo_Sba:Start()

      -- Kvemo_Sba: link farp-wharehouse.  Send resupply to Didi, Batumi. Receive resupply from Beslan, Mineralny, Alagir, Nalchik

      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankA,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]  )
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankB,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]  )
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankC,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]  )
      warehouse.Kvemo_Sba:AddAsset(               air_template_red.CAS_MI_24V,               12,                WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter_bomber[2])]    ) -- attack
      warehouse.Kvemo_Sba:AddAsset(               air_template_red.CAS_Mi_8MTV2,             12,                WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]   ) -- transport
      warehouse.Kvemo_Sba:AddAsset(               air_template_red.TRAN_MI_26,               10,                WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 20000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]  ) -- transport
      warehouse.Kvemo_Sba:AddAsset(               air_template_red.AFAC_MI_24,               10,                WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC
      warehouse.Kvemo_Sba:AddAsset(               air_template_red.AFAC_Mi_8MTV2,            10,                WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArmorA,          10,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]    ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArmorB,          10,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]   ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiAkatsia,     10,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])]   ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiGwozdika,    10,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])]    ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiKatiusha,    10,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])]    ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiHeavyMortar, 10,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])]    ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedA,     10,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]    ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedB,     10,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]    ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedC,     10,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]   ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankA,       10,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]   ) -- Ground troops
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TransportA,      10,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]   ) -- transport
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TransportB,      10,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]   ) -- transport
      warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TroopTransport,  10,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]   ) -- transport troop


      logging('info', { 'main' , 'addAsset Kvemo_Sba warehouse'} )



      logging('info', { 'main' , 'Define blueFrontZone = ' .. 'blueFrontZone' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa
      logging('info', { 'main' , 'addrequest Kvemo_Sba warehouse'} )


      local kvemo_sba_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
      local num_mission = 3
      local num_mission_helo = 0
      --local depart_time_heli = defineRequestPosition( num_mission_helo ) -- heli mission
      local depart_time = defineRequestPosition( num_mission ) -- ground mission
      local pos = 1
      --local pos_heli = 1
      local sched_interval =  math.max(num_mission, num_mission_helo) * waitReqTimeGround / activeGroundRequestRatio

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local kvemo_sba_sched = SCHEDULER:New( warehouse.Kvemo_Sba,

        function()

          -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
          -- if true and pos_heli <= num_mission_helo  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_MI_24V, math.random( min_cas_skill , max_cas_skill ), nil, nil, nil, 'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi') pos_heli = pos_heli + 1  end
          -- if true and pos_heli <= num_mission_helo  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Mi_8MTV2, math.random( min_cas_skill , max_cas_skill ), nil, nil, nil, 'ATTACK_ZONE_HELO_Didmukha_Tsveri') pos_heli = pos_heli + 1  end
          -- NON APPAIONO GLI AFAC HELO: sono apparsi cambiando AFAC in NOTHING nel template e cambiando in averege lo skill !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          -- if true and (pos_heli-2) <= num_mission_helo  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + ( depart_time_heli[ pos_heli-2 ] + 1 ) * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_MI_24, 1, nil, nil, nil, 'ATTACK_ZONE_HELO') end
          -- if true and (pos_heli-1) <= num_mission_helo then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + ( depart_time_heli[ pos_heli-1 ] + 1 ) * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_Mi_8MTV2, 1, nil, nil, nil, 'ATTACK_ZONE_HELO') end
          -- riutilizzo gli stessi indici in quanto essendo ground veichle appaiono nella warehouse spawn zone diversa dal FARP degli helo
          if wh_activation.Warehouse.red.Kvemo_Sba[12] and pos <= num_mission  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankA, math.random( AssetQty.red.ground.attack[1], AssetQty.red.ground.attack[2] ), nil, nil, nil, 'tkviavi_attack' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Kvemo_Sba[14] and pos <= num_mission  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.TroopTransport, math.random( AssetQty.red.ground.attack[1], AssetQty.red.ground.attack[2] ), nil, nil, nil, 'Transfert to Didi' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Kvemo_Sba[14] and pos <= num_mission  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.TransportB, math.random(AssetQty.red.ground.transport[1], AssetQty.red.ground.transport[2]), nil, nil, nil, 'Transfert to Biteta' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Kvemo_Sba[11] and pos <= num_mission  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.TRAN_MI_26, math.random( AssetQty.red.heli.transport[1], AssetQty.red.heli.transport[2] ), nil, nil, nil, 'Transfert to Biteta' ) pos = pos + 1  end

          logging('finer', { 'Kvemo_Sba scheduler function' , 'addRequest Kvemo_Sba warehouse'} )

        end, {}, start_ground_sched * kvemo_sba_efficiency_influence, sched_interval, rand_ground_sched

      ) -- END SCHEDULER




      -- Take care of the spawned units.
      function warehouse.Kvemo_Sba:OnAfterSelfRequest( From,Event,To,groupset,request )

        logging('enter', 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' )
        logging('info', { 'main' , 'warehouse.Kvemo_Sba:OnAfterDelivered(From,Event,To,request) - ' .. 'request.assignment: ' .. request.assignment })

        local groupset = groupset --Core.Set#SET_GROUP
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        local suppr_param = {retreatZone = nil, fallBack = true, takeCover = true, delay = 300}

        -- Get assignment of this request.
        local assignment = warehouse.Kvemo_Sba:GetAssignment(request)

        logging('finer', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )


        if assignment == 'tkviavi_attack' then

           activeGO_TO_BATTLE( groupset, redFrontZone.TSKHINVALI[1], 'enemy_attack', false, 1, true, suppr_param )


        else

          logging('warning', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )


        end -- if elseif else


      end -- end function warehouse.Kvemo_Sba:OnAfterSelfRequest( From,Event,To,groupset,request )



  end -- wh_activation.Warehouse.red.Kvemo_Sba then
  ------------------------------------------------- END red Warehouse KVEMO_SBA operations -------------------------------------------------------------------------------------------------------------------------
























































  ------------------------------------------------- red Warehouse ALAGIR operations -------------------------------------------------------------------------------------------------------------------------



  if wh_activation.Warehouse.red.Alagir[1] then


      warehouse.Alagir:Start()

      -- Alagir: link wharehouse.  Send resupply to Didi, Kvemo_Sba. Receive resupply from Beslan, Mineralnye, Nalchik

      logging('info', { 'main' , 'addAsset Kvemo_Sba warehouse'} )

      warehouse.Alagir:AddAsset(               air_template_red.CAS_MI_24V,               52,                WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter_bomber[2])]    ) -- attack
      warehouse.Alagir:AddAsset(               air_template_red.CAS_Mi_8MTV2,             52,                WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]   ) -- transport
      warehouse.Alagir:AddAsset(               air_template_red.TRAN_MI_26,               50,                WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 20000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]  ) -- transport
      warehouse.Alagir:AddAsset(               air_template_red.AFAC_MI_24,               50,                WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC
      warehouse.Alagir:AddAsset(               air_template_red.AFAC_Mi_8MTV2,            50,                WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC
      warehouse.Alagir:AddAsset(               ground_group_template_red.antitankA,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]  )
      warehouse.Alagir:AddAsset(               ground_group_template_red.antitankB,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]  )
      warehouse.Alagir:AddAsset(               ground_group_template_red.antitankC,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]  )
      warehouse.Alagir:AddAsset(               ground_group_template_red.ArmorA,          50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]    ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.ArmorB,          50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]   ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.ArtiAkatsia,     50,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])]   ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.ArtiGwozdika,    50,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])]    ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.ArtiKatiusha,    50,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])]    ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.ArtiHeavyMortar, 50,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.artillery[1], AssetSkill.red.artillery[2])]    ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.mechanizedA,     50,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]    ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.mechanizedB,     50,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]    ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.mechanizedC,     50,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]   ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.antitankA,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.tank[1], AssetSkill.red.tank[2])]   ) -- Ground troops
      warehouse.Alagir:AddAsset(               ground_group_template_red.TransportA,      50,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]   ) -- transport
      warehouse.Alagir:AddAsset(               ground_group_template_red.TransportB,      50,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]   ) -- transport
      warehouse.Alagir:AddAsset(               ground_group_template_red.TroopTransport,  50,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.ground[1], AssetSkill.red.ground[2])]   ) -- transport troop




      logging('info', { 'main' , 'addrequest Alagir warehouse'} )

      local alagir_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
      local num_mission = 3
      local num_mission_helo = 2
      local depart_time_heli = defineRequestPosition( num_mission_helo ) -- heli mission
      local depart_time = defineRequestPosition( num_mission ) -- ground mission
      local pos = 1
      local pos_heli = 1
      local sched_interval =  math.max(num_mission, num_mission_helo) * waitReqTimeGround / activeGroundRequestRatio

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local alagir_sched = SCHEDULER:New( warehouse.Alagir,

        function()

          -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
          if wh_activation.Warehouse.red.Alagir[11] and pos_heli <= num_mission_helo  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_MI_24V, math.random( AssetQty.red.heli.transport[1], AssetQty.red.heli.transport[2] ), nil, nil, nil, 'Transfer to Biteta') pos_heli = pos_heli + 1  end
          if wh_activation.Warehouse.red.Alagir[11] and pos_heli <= num_mission_helo  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Mi_8MTV2, math.random( AssetQty.red.heli.transport[1], AssetQty.red.heli.transport[2] ), nil, nil, nil, 'Transfer to Kvemo_Sba') pos_heli = pos_heli + 1  end
          -- inserisci missioni cargoSet

          -- riutilizzo gli stessi indici in quanto essendo ground veichle appaiono nella warehouse spawn zone diversa dal FARP degli helo
          if wh_activation.Warehouse.red.Alagir[14] and pos <= num_mission  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.TroopTransport, math.random( AssetQty.red.ground.transport[1], AssetQty.red.ground.transport[2] ), nil, nil, nil, 'Transfert to Batumi' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Alagir[14] and pos <= num_mission  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.TroopTransport, math.random( AssetQty.red.ground.transport[1], AssetQty.red.ground.transport[2] ), nil, nil, nil, 'Transfert to Kvemo_Sba' ) pos = pos + 1  end
          if wh_activation.Warehouse.red.Alagir[14] and pos <= num_mission  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.TransportA, math.random( AssetQty.red.ground.transport[1], AssetQty.red.ground.transport[2] ), nil, nil, nil, 'Transfert to Didi' ) pos = pos + 1  end

          logging('finer', { 'Alagir scheduler function' , 'addRequest Alagir warehouse'} )

        end, {}, start_ground_sched * alagir_efficiency_influence, sched_interval, rand_ground_sched

      ) -- END SCHEDULER


      -- Take care of the spawned units.
      function warehouse.Alagir:OnAfterSelfRequest( From,Event,To,groupset,request )

        logging('enter', 'warehouse.Alagir:OnAfterSelfRequest(From,Event,To,groupset,request)' )
        logging('info', { 'main' , 'warehouse.Alagir:OnAfterDelivered(From,Event,To,request) - ' .. 'request.assignment: ' .. request.assignment })

        local groupset = groupset --Core.Set#SET_GROUP
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        -- Get assignment of this request.
        local assignment = warehouse.Kvemo_Sba:GetAssignment(request)

        logging('finer', { 'warehouse.Alagir:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

      end -- end function warehouse.Alagir:OnAfterSelfRequest( From,Event,To,groupset,request )



  end -- wh_activation.Warehouse.red.Alagir then

  ------------------------------------------------- END Warehouse ALAGIR operations -------------------------------------------------------------------------------------------------------------------------



























































  ---------------------------------------------------------------- red Mineralnye warehouse operations -------------------------------------------------------------------------------------------------------------------------

  if wh_activation.Warehouse_AB.red.Mineralnye[1] then


      logging('info', { 'main' , 'init Warehouse MINERALNYE operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa

      warehouse.Mineralnye:Start()


      -- Mineralnye e' una delle principale warehouse russe nell'area. Qui sono immagazzinate la maggior parte degli asset da impiegare nella zona dei combattimenti
      -- Send resupply to Kvemo_Sba

      logging('info', { 'main' , 'addAsset Mineralnye warehouse'} )

      warehouse.Mineralnye:AddAsset(            air_template_red.CAP_Mig_21Bis,             10,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])] ) -- Fighter
      warehouse.Mineralnye:AddAsset(            air_template_red.GCI_Mig_21Bis,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]  )
      warehouse.Mineralnye:AddAsset(            air_template_red.BOM_SU_24_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.bomber[1], AssetSkill.red.bomber[2])]  ) -- Bomber - Cas
      warehouse.Mineralnye:AddAsset(            air_template_red.BOM_TU_22_Bomb,            15,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.bomber[1], AssetSkill.red.bomber[2])]  )
      warehouse.Mineralnye:AddAsset(            air_template_red.BOM_SU_24_Structure,       10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.bomber[1], AssetSkill.red.bomber[2])]  )
      warehouse.Mineralnye:AddAsset(            air_template_red.GA_SU_24M_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.bomber[1], AssetSkill.red.bomber[2])]  )
      warehouse.Mineralnye:AddAsset(            air_template_red.GA_Su_25_Missile,          10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.bomber[1], AssetSkill.red.bomber[2])]  )
      warehouse.Mineralnye:AddAsset(            air_template_red.AWACS_TU_22,               10,         WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.awacs[1], AssetSkill.red.awacs[2])]  )
      warehouse.Mineralnye:AddAsset(            air_template_red.REC_SU_24MR,               10,         WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.awacs[1], AssetSkill.red.awacs[2])]  )
      warehouse.Mineralnye:AddAsset(            air_template_red.CAS_MI_24V,                10,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]       ) -- attack
      warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_MI_24,                24,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]  ) -- transport
      warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_AN_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]    ) -- transport
      warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_MI_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]    ) -- transport
      warehouse.Mineralnye:AddAsset(            ground_group_template_red.Truck,             3 )



      logging('info', { 'main' , 'addrequest Mineralnye warehouse'} )




      local mineralnye_efficiency_influence = math.random(10, 20) * 0.1 -- Influence start_sched (from 1 to inf)
      local num_mission = 9
      local depart_time = defineRequestPosition( num_mission )
      local pos = 1
      local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
      local offSetStartSchedule = 300 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
      local requestStartTime = startReqTimeAir + offSetStartSchedule

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local mineralnye_sched = SCHEDULER:New( staticObject.Warehouse_AB.red.Mineralnye[ 1 ],

        function()

          -- Priority Mission Request
          if wh_activation.Warehouse_AB.red.Mineralnye[9]  then warehouse.Mineralnye:__AddRequest( startReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AWACS_TU_22, 1, nil, nil, nil, "AWACS")  end
          -- Normal Mission Request
          if wh_activation.Warehouse_AB.red.Mineralnye[15] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.REC_SU_24MR, 1, nil, nil, nil, "AFAC_afacZone.Tskhunvali_Tkviavi") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mineralnye[8] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Bomb, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BAI POINT") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mineralnye[5] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, math.random( AssetQty.red.air.patrol[1], AssetQty.red.air.patrol[2] ), nil, nil, nil, "PATROL") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mineralnye[7] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_TU_22_Bomb, math.random( AssetQty.red.air.heavy_bomb[1], AssetQty.red.air.heavy_bomb[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mineralnye[7] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.GA_Mig_27K_Missile_R, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mineralnye[7] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mineralnye[7] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mineralnye[7] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_TU_22_Bomb, math.random( AssetQty.red.air.heavy_bomb[1], AssetQty.red.air.heavy_bomb[2] ), nil, nil, nil, "BOMBING FARM") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mineralnye[11] and pos <= num_mission then warehouse.Mineralnye:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Alagir, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.TRAN_MI_26, math.random( AssetQty.red.heli.transport[1], AssetQty.red.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end


          logging('info', { 'main' , 'Mineralnye scheduler - start time:' .. start_sched *  mineralnye_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * ( 1 - rand_sched ) .. ' - ' .. sched_interval * ( 1 + rand_sched ) } )

      end, {}, start_sched * mineralnye_efficiency_influence, sched_interval, rand_sched

      ) -- end mineralnye_sched = SCHEDULER:New( nil, ..)


        -- Do something with the spawned aircraft.
      function warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)

        --local groupset=groupset --Core.Set#SET_GROUP
        --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        logging('enter', 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' )
        logging('info', { 'main' , 'warehouse.Mineralnye:OnAfterDelivered(From,Event,To,request) - ' .. 'request.assignment: ' .. request.assignment })

        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        if request.assignment == "AFAC_afacZone.Tskhunvali_Tkviavi" then

          local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Mineralnye_Vody )

          assignDetectionGroupSetTask(groupset, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )


        elseif request.assignment == "AWACS" then

          logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - awacsZone: ' .. redAwacsZone.alagir:GetName() } )

          activeAWACS( groupset, warehouse.Mineralnye, red_command_center, nil, redAwacsZone.alagir, math.random(6000, 9000), 6000 )






        elseif request.assignment == "BAI POINT" then

          --[[
          local avalaible_target_zones = {

              zoneTargetStructure.Blue_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Kutaisi_Bridges) ][1],
              zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
              zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
              zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
              zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1],
              zoneTargetStructure.Blue_Farm[math.random( 1, #zoneTargetStructure.Blue_Farm) ][1]

          }
          ]]


          local engageZone = specific_target.blue.zone_targ[ math.random(1, #specific_target.blue.zone_targ) ]--avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
          local patrolZone = redPatrolZone.mineralnye[1]

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Mineralnye against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )









        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
        elseif request.assignment == "PATROL" then

          local homeAirbase =  AIRBASE.Caucasus.Mineralnye_Vody
          local patrolZone =  redPatrolZone.mineralnye[1]
          local engageRange = math.random(10000, 20000)
          local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
          local patrolFloorAltitude = 4000
          local patrolCeilAltitude = 9000
          local minSpeedPatrol = 400
          local maxSpeedPatrol = 600
          local minSpeedEngage = 600
          local maxSpeedEngage = 1000

          logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
          logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

          activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )






        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING AIRBASE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mineralnye
          local target = warehouse_blue.airbase[ math.random( 1, #warehouse_blue.airbase ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING WAREHOUSE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mineralnye
          local target = warehouse_blue.farp[ math.random( 1, #warehouse_blue.farp ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING MIL ZONE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mineralnye
          local target = zoneTargetStructure.Blue_Military_Base[ math.random( 1, #zoneTargetStructure.Blue_Military_Base ) ][1]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING FARM" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mineralnye
          local target = zoneTargetStructure.Blue_Farm[ math.random( 1, #zoneTargetStructure.Blue_Farm ) ][1]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING STRUCTURE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mineralnye
          local target = specific_target.blue.zone_targ[ math.random(1, #specific_target.blue.zone_targ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )







        ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
    elseif request.assignment == "TRANSPORT INFANTRY FARP" then

          -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
          --local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Mineralnye", 5000, nil)
          --local pickupZone =  cargoZone.Warehouse_AB.red.Mineralnye
          --local deployZone =  cargoZone.Warehouse.red.Alagir
          --local speed = math.random( 100 , 250 )

          --logging('info', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

          --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )

    elseif request.assignment == "AWACS" then

          --local homeAirbase =  AIRBASE.Caucasus.Batumi
          --local patrolZone =  bluePatrolZone.kutaisi[1]
          --local engageRange = math.random(10000, 20000)
          --local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
          --local patrolFloorAltitude = 7000
          --local patrolCeilAltitude = 9000
          --local minSpeedPatrol = 400
          --local maxSpeedPatrol = 600
          --local maxSpeedEngage = 1000
          --local minSpeedEngage = 600

          logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. bluePatrolZone.kutaisi[1]:GetName() } )
          --logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

          -- addGroupSet(detectionGroupSetBlue, groupset)

          activeAWACS( groupset, warehouse.Mineralnye, red_command_center, nil, redAwacsZone.alagir, math.random(7000,9000), 5000 )



        else

          logging('warning', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

        end-- end if..elseif

        logging('exit', 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' )

      end -- end function warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)



      --- When the helo is out of fuel, it will return to the carrier and should be delivered.
      function warehouse.Mineralnye:OnAfterDelivered(From,Event,To,request)

          local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          logging('info', { 'warehouse.Mineralnye:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })

          --[[
          -- So we start another request.
          if request.assignment=="PATROL" then

            logging('info', { 'warehouse.Mineralnye:OnAfterDelivered(From,Event,To,request)' , 'Mineralnye scheduled PATROL mission' })
              --activeCAPWarehouse(groupset, "Patrol Zone Mineralnye", 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

          end

          if request.assignment=="BAI TARGET" then

            logging('info', { 'warehouse.Mineralnye:OnAfterDelivered(From,Event,To,request)' , 'Mineralnye scheduled BAI TARGET mission' })
            activeBAIWarehouseA('Interdiction from Mineralnye to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], 400, 1000, AI.Task.WeaponExpend.ALL, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

          end -- end if
          ]]

      end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)


  end -- end wh_activation.Warehouse_AB.red.Mineralnye then
  ---------------------------------------------------------------- END red Mineralnye warehouse operations -------------------------------------------------------------------------------------------------------------------------




















































  ------------------------------------------------------------------ red Mozdok warehouse operations -------------------------------------------------------------------------------------------------------------------------

  if wh_activation.Warehouse_AB.red.Mozdok[1] then


      -- Mozdok e' una delle principale warehouse russe nell'area. Qui sono immagazzinate la maggior parte degli asset da impiegare nella zona dei combattimenti
      -- Send resupply to Kvemo_Sba, Beslan
      -- warehouse.Didi:SetSpawnZone(ZONE:New("Didi Warehouse Spawn Zone"))

      logging('info', { 'main' , 'addAsset Mozdok warehouse'} )

      warehouse.Mozdok:Start()

      warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_21Bis,             10,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]   )
      warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_21Bis,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]   )
      warehouse.Mozdok:AddAsset(                air_template_red.BOM_SU_24_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.bomber[1], AssetSkill.red.bomber[2])]  )
      warehouse.Mozdok:AddAsset(                air_template_red.BOM_SU_24_Structure,       10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.bomber[1], AssetSkill.red.bomber[2])]  )
      warehouse.Mozdok:AddAsset(                air_template_red.BOM_TU_22_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.bomber[1], AssetSkill.red.bomber[2])]  )
      warehouse.Mozdok:AddAsset(                air_template_red.REC_SU_24MR,               10,         WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.awacs[1], AssetSkill.red.awacs[2])]  )
      warehouse.Mozdok:AddAsset(                air_template_red.CAS_Mig_27K_Rocket,        10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter[2])]  )
      warehouse.Mozdok:AddAsset(                air_template_red.CAS_MI_24V,                12,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter[2])]     ) -- attack
      warehouse.Mozdok:AddAsset(                air_template_red.GA_SU_24M_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter[2])]  )
      warehouse.Mozdok:AddAsset(                air_template_red.GA_SU_24M_HRocket,         10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter[2])]  )
      warehouse.Mozdok:AddAsset(                air_template_red.GA_Su_25_Bomb,             10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter[2])]  )
      warehouse.Mozdok:AddAsset(                air_template_red.TRAN_MI_24,                12,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           1500, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]  ) -- transport
      warehouse.Mozdok:AddAsset(                air_template_red.TRAN_MI_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])] ) -- transport
      warehouse.Mozdok:AddAsset(                air_template_red.TRAN_AN_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])] ) -- transport

      logging('info', { 'main' , 'addrequest Mozdok warehouse'} )

      local mozdok_efficiency_influence = math.random(10, 20) * 0.1 -- Influence start_sched (from 1 to inf)
      local num_mission = 10
      local depart_time = defineRequestPosition(9)
      local pos = 1
      local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
      local offSetStartSchedule = 300 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
      local requestStartTime = startReqTimeAir + offSetStartSchedule

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local mozdok_sched = SCHEDULER:New( staticObject.Warehouse_AB.red.Mozdok[ 1 ],

        function()

          -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
          if wh_activation.Warehouse_AB.red.Mozdok[8] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BAI POINT") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[8] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.GA_SU_24M_HRocket, math.random( AssetQty.red.air.ga[1], AssetQty.red.air.ga[2] ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[7] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_TU_22_Bomb, math.random( AssetQty.red.air.heavy_bomb[1], AssetQty.red.air.heavy_bomb[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[5] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, math.random( AssetQty.red.air.patrol[1], AssetQty.red.air.patrol[2] ), nil, nil, nil, "PATROL") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[7] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[7] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[7] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Mig_27K_Bomb, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING FARM") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[7] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[11] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvemo_Sba, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.TRAN_MI_26, math.random( AssetQty.red.heli.transport[1], AssetQty.red.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Mozdok[15] and pos <= num_mission then warehouse.Mozdok:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.REC_SU_24MR, 1, nil, nil, nil, "AFAC_afacZone.Tskhunvali_Tkviavi") pos = pos + 1  end

          logging('info', { 'main' , 'Mozdok scheduler - start time:' .. start_sched *  mozdok_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * (1-rand_sched) .. ' - ' .. sched_interval * (1+rand_sched)} )


      end, {}, start_sched * mozdok_efficiency_influence, sched_interval, rand_sched

      ) -- end mozdok_sched = SCHEDULER:New( nil, ..)

      -- Do something with the spawned aircraft.
      function warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)

        --local groupset=groupset --Core.Set#SET_GROUP
        --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        logging('enter', 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' )
        logging('info', { 'main' , 'warehouse.Mozdok:OnAfterDelivered(From,Event,To,request) - ' .. 'request.assignment: ' .. request.assignment })

        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        if request.assignment == "AFAC_afacZone.Tskhunvali_Tkviavi" then

          local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Mozdok )

          assignDetectionGroupSetTask(groupset, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )



        elseif request.assignment == "BAI POINT" then

          --[[
          local avalaible_target_zones = {

              zoneTargetStructure.Blue_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Kutaisi_Bridges) ][1],
              zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
              zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
              zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
              zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

          }
          ]]

          local engageZone = specific_target.blue.zone_targ[ math.random(1, #specific_target.blue.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
          local patrolZone = redPatrolZone.beslan[1]

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Mozdok against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )





        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        elseif request.assignment == "BAI TARGET" then

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
          local percRequestKill = math.random( 0 , 100 ) * 0.01
          local target = blueGroundGroup[ math.random( 1, #blueGroundGroup ) ][ 1 ]
          local patrolZone = redPatrolZone.beslan[1]
          local engageZone = blueFrontZone.TSVERI[1]

          for _, v in pairs(redFrontZone) do

            if math.random(1,10) < 5 then

              engageZone = v[1]
              break

            end -- end if

          end -- end for


          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Mozdok', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )






        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
        elseif request.assignment == "PATROL" then

          local homeAirbase =  AIRBASE.Caucasus.Mozdok
          local patrolZone =  redPatrolZone.beslan[1]
          local engageRange = math.random(10000, 20000)
          local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
          local patrolFloorAltitude = 4000
          local patrolCeilAltitude = 9000
          local minSpeedPatrol = 400
          local maxSpeedPatrol = 600
          local minSpeedEngage = 600
          local maxSpeedEngage = 1000

          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

          activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )




        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING AIRBASE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mozdok
          local target = warehouse_blue.airbase[ math.random( 1, #warehouse_blue.airbase ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING WAREHOUSE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mozdok
          local target = warehouse_blue.farp[ math.random( 1, #warehouse_blue.farp ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING MIL ZONE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mozdok
          local target = zoneTargetStructure.Blue_Military_Base[ math.random( 1, #zoneTargetStructure.Blue_Military_Base ) ][1]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING STRUCTURE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mozdok
          local target = specific_target.blue.zone_targ[ math.random(1, #specific_target.blue.zone_targ) ] --zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges ) ][1]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING FARM" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Mozdok
          local target = zoneTargetStructure.Blue_Farm[ math.random( 1, #zoneTargetStructure.Blue_Farm ) ][1]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )








        ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
        elseif request.assignment == "TRANSPORT INFANTRY FARP" then



          -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
          --local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Mozdok", 5000, nil)

          --local pickupZone =  cargoZone.Warehouse_AB.red.Mozdok
          --local deployZone =  cargoZone.Warehouse.red.Alagir
          --local speed = math.random( 100 , 250 )

          --logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )


        else

          logging('warning', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

        end -- end if..elseif

        logging('exit', 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' )

      end -- end function warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)




      --- When the helo is out of fuel, it will return to the carrier and should be delivered.
      function warehouse.Mozdok:OnAfterDelivered(From,Event,To,request)

        local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        logging('info', { 'warehouse.Mozdok:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })

        --[[
        -- So we start another request.
        if request.assignment=="PATROL" then

          logging('info', { 'warehouse.Mozdok:OnAfterDelivered(From,Event,To,request)' , 'Mozdok scheduled PATROL mission' })
            --activeCAPWarehouse(groupset, "Patrol Zone Mozdok", 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

        end

        if request.assignment=="BAI TARGET" then

          logging('info', { 'warehouse.Mozdok:OnAfterDelivered(From,Event,To,request)' , 'Mozdok scheduled BAI TARGET mission' })
          activeBAIWarehouseA('Interdiction from Mozdok to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], 400, 1000, AI.Task.WeaponExpend.ALL, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

        end -- end if

        ]]

      end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)

  end -- end wh_activation.Warehouse_AB.red.Mozdok then
  ------------------------------------------------------------------ END red Mozdok warehouse operations -------------------------------------------------------------------------------------------------------------------------




























































  ------------------------------------------------------------------ red Beslan warehouse operations -------------------------------------------------------------------------------------------------------------------------

  if wh_activation.Warehouse_AB.red.Beslan[1] then

      logging('info', { 'main' , 'addAsset Beslan warehouse'} )

      warehouse.Beslan:Start()

      -- Beslan e' una delle principale warehouse russe nell'area.
      -- Receive reupply from Mozdok and Mineralnye. Send resupply to Kvemo_Sba

      warehouse.Beslan:AddAsset(               air_template_red.CAP_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]  )
      warehouse.Beslan:AddAsset(               air_template_red.GCI_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]  )
      warehouse.Beslan:AddAsset(               air_template_red.CAS_MI_24V,                10,           WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]       ) -- attack
      warehouse.Beslan:AddAsset(               air_template_red.CAS_Su_17M4_Rocket,        10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Beslan:AddAsset(               air_template_red.CAS_Su_17M4_Bomb,          10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Beslan:AddAsset(               air_template_red.CAS_Su_17M4_Cluster,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Beslan:AddAsset(               air_template_red.GA_Su_25_Missile,          10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Beslan:AddAsset(               air_template_red.BOM_SU_24_Bomb,            10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Beslan:AddAsset(               air_template_red.BOM_SU_24_Structure,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Beslan:AddAsset(               air_template_red.BOM_SU_17_Structure,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])] )
      warehouse.Beslan:AddAsset(               air_template_red.REC_SU_24MR,               10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])] )
      warehouse.Beslan:AddAsset(               air_template_red.AWACS_Mig_25RTB,           10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])] )
      warehouse.Beslan:AddAsset(               air_template_red.TRAN_MI_24,                24,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]  ) -- transport
      warehouse.Beslan:AddAsset(               air_template_red.TRAN_MI_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]   ) -- transport
      warehouse.Beslan:AddAsset(               air_template_red.TRAN_AN_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]   ) -- transport
      warehouse.Beslan:AddAsset(               air_template_red.TRAN_YAK_40,                4,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])] ) -- transport
      warehouse.Beslan:AddAsset(               air_template_red.AFAC_L_39C,                10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC
      warehouse.Beslan:AddAsset(               air_template_red.AFAC_Yak_52,               10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])] ) -- AFAC

      logging('info', { 'main' , 'AddRequest Beslan warehouse'} )




      local beslan_efficiency_influence = math.random(10, 20) * 0.1 -- Influence start_sched (from 1 to inf)
      local num_mission = 9
      local depart_time = defineRequestPosition( num_mission )
      local pos = 1
      local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
      local offSetStartSchedule = 300 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
      local requestStartTime = startReqTimeAir + offSetStartSchedule


      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local beslan_sched = SCHEDULER:New( staticObject.Warehouse_AB.red.Beslan[ 1 ],

        function()

          -- Priority Mission Request
          if wh_activation.Warehouse_AB.red.Beslan[9] then warehouse.Beslan:__AddRequest( startReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AWACS_Mig_25RTB, 1, nil, nil, nil, "AWACS")  end -- sostituire con un AWACS su 24 da realizzare
          -- Normal Mission Request
          if wh_activation.Warehouse_AB.red.Beslan[8] and pos <= num_mission  then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Cluster, math.random( AssetQty.red.air.cas[1], AssetQty.red.air.cas[2] ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Beslan[8] and pos <= num_mission  then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Bomb, math.random( AssetQty.red.air.cas[1], AssetQty.red.air.cas[2] ), nil, nil, nil, "BAI TARGET 2") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Beslan[8] and pos <= num_mission  then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BAI BOMBING STRUCTURE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Beslan[7] and pos <= num_mission  then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_17_Structure, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Beslan[7] and pos <= num_mission  then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.GA_Mig_27K_Missile_R, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE GORI") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Beslan[7] and pos <= num_mission  then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Beslan[7] and pos <= num_mission  then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE TBILISI") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Beslan[11] and pos <= num_mission then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvemo_Sba, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.TRAN_MI_26, math.random( AssetQty.red.heli.transport[1], AssetQty.red.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Beslan[15] and pos <= num_mission  then warehouse.Beslan:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.REC_SU_24MR, 1, nil, nil, nil, "AFAC_afacZone.Tskhunvali_Tkviavi") pos = pos + 1  end

          logging('info', { 'main' , 'Beslan scheduler - start time:' .. start_sched *  beslan_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * (1-rand_sched) .. ' - ' .. sched_interval * ( 1 + rand_sched)} )

      end, {}, start_sched * beslan_efficiency_influence, sched_interval, rand_sched

      )


      -- Do something with the spawned aircraft.
      function warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)

        --local groupset=groupset --Core.Set#SET_GROUP
        --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        logging('enter', 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' )
        logging('info', { 'main' , 'warehouse.Beslan:OnAfterDelivered(From,Event,To,request) - ' .. 'request.assignment: ' .. request.assignment })

        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        if request.assignment == "AFAC_afacZone.Didmukha_Tsveri" then

          local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Beslan )

          assignDetectionGroupSetTask(groupset, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )




        elseif request.assignment == "BAI TARGET" then

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
          local percRequestKill = math.random( 0 , 100 ) * 0.01
          local target = blueGroundGroup[ math.random( 1, #blueGroundGroup ) ][ 1 ]
          local patrolZone = redPatrolZone.nalchik[1]
          local engageZone = blueFrontZone.TKVIAVI[1]

          for _, v in pairs(redFrontZone) do

            if math.random(1,10) < 5 then

              engageZone = v[1]
              break

            end -- end if

          end -- end for


          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Beslan', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )








        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
        elseif request.assignment == "AWACS" then

          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - awacsZone: ' .. redAwacsZone.beslan:GetName() } )

          activeAWACS( groupset, warehouse.Beslan, red_command_center, nil, redAwacsZone.beslan, math.random(6000, 9000), 6000 )





        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BAI TARGET 2" then


          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
          local percRequestKill = math.random( 0 , 100 ) * 0.01
          local target = blueGroundGroup[ math.random( 1, #blueGroundGroup ) ][ 1 ]
          local patrolZone = redPatrolZone.beslan[1]
          local engageZone = blueFrontZone.TKVIAVI[1]

          for _, v in pairs(redFrontZone) do

            if math.random(1,10) < 5 then

              engageZone = v[1]
              break

            end -- end if

          end -- end for


          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Beslan', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )




          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BAI BOMBING STRUCTURE" then

          --[[
          local avalaible_target_zones = {

              zoneTargetStructure.Blue_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Kutaisi_Bridges) ][1],
              zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
              zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
              zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
              zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

          }
          ]]

          local engageZone = specific_target.blue.zone_targ[ math.random(1, #specific_target.blue.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
          local patrolZone = redPatrolZone.beslan[1]

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Beslan against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )







        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING AIRBASE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Beslan
          local target = warehouse_blue.airbase[ math.random( 1, #warehouse_blue.airbase ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING WAREHOUSE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Beslan
          local target = warehouse_blue.farp[ math.random( 1, #warehouse_blue.farp ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING STRUCTURE GORI" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Beslan
          local target = zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges ) ][1]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )



        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING STRUCTURE TBILISI" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Beslan
          local target = zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges ) ][1]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






        ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
    elseif request.assignment == "TRANSPORT INFANTRY FARP" then

          -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
          --local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Beslan", 5000, nil)
          --local pickupZone =  cargoZone.Warehouse_AB.red.Beslan
          --local deployZone =  cargoZone.Warehouse.red.Alagir
          --local speed = math.random( 100 , 250 )

          --logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

          --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )


        else

          logging('warning', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

        end -- end if..elseif

        logging('exit', 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' )

      end -- end function warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)


      --- When the helo is out of fuel, it will return to the carrier and should be delivered.
      function warehouse.Beslan:OnAfterDelivered(From,Event,To,request)

        local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        logging('info', { 'warehouse.Beslan:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })

        --[[
        -- So we start another request.
        if request.assignment=="PATROL" then

          logging('info', { 'warehouse.Beslan:OnAfterDelivered(From,Event,To,request)' , 'Beslan scheduled PATROL mission' })
            --activeCAPWarehouse(groupset, "Patrol Zone Beslan", 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

        end

        if request.assignment=="BAI TARGET" then

          logging('info', { 'warehouse.Beslan:OnAfterDelivered(From,Event,To,request)' , 'Beslan scheduled BAI TARGET mission' })
          activeBAIWarehouseA('Interdiction from Beslan to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], 400, 1000, AI.Task.WeaponExpend.ALL, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

        end -- end if
        ]]

      end -- end function warehouse.Beslan:OnAfterDelivered(From,Event,To,request)

  end -- end wh_activation.Warehouse_AB.red.Beslan then
  ----------------------------------------------------------------- END red Beslan warehouse operations -------------------------------------------------------------------------------------------------------------------------




























































  ------------------------------------------------------------------- red Nalchik warehouse operations ------------------------------------------------------------------------------------------------------------------------

  if wh_activation.Warehouse_AB.red.Nalchik[1] then



      warehouse.Nalchik:Start()
      -- Nalchik e' una delle principale warehouse russe nell'area.
      -- Receive reupply from Mozdok and Mineralnye. Send resupply to Kvemo_Sba

      warehouse.Nalchik:AddAsset(               air_template_red.CAP_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.CAP_Mig_23MLD,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.GCI_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.GCI_Mig_23MLD,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter[1], AssetSkill.red.fighter[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.CAS_MI_24V,                10,           WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]       ) -- attack
      warehouse.Nalchik:AddAsset(               air_template_red.CAS_Mig_27K_Bomb,          10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.CAS_Mig_27K_Rocket,        10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.GA_Mig_27K_ROCKET_Heavy,   10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.GA_Mig_27K_ROCKET_Light,   10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.GA_Mig_27K_Bomb_Light,     10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.GA_Su_25_Bomb,             10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.BOM_MIG_27K_Structure,     10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.BOM_MIG_27K_Airbase,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.fighter_bomber[1], AssetSkill.red.fighter_bomber[2])]  )
      warehouse.Nalchik:AddAsset(               air_template_red.TRAN_MI_24,                24,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]   ) -- transport
      warehouse.Nalchik:AddAsset(               air_template_red.TRAN_MI_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]   ) -- transport
      warehouse.Nalchik:AddAsset(               air_template_red.TRAN_AN_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]   ) -- transport
      warehouse.Nalchik:AddAsset(               air_template_red.TRAN_YAK_40,            10,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.transport[1], AssetSkill.red.transport[2])]  ) -- transport
      warehouse.Nalchik:AddAsset(               air_template_red.AFAC_L_39C,                10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])]  ) -- AFAC
      warehouse.Nalchik:AddAsset(               air_template_red.AFAC_Yak_52,               10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])]  ) -- AFAC
      warehouse.Nalchik:AddAsset(               air_template_red.REC_Mig_25RTB,             10,           WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.red.afac[1], AssetSkill.red.afac[2])]  ) -- AFAC

      logging('info', { 'main' , 'addAsset Nalchik warehouse'} )



      logging('info', { 'main' , 'addrequest Nalchik warehouse'} )


      local nalchik_efficiency_influence = math.random(10, 20) * 0.1 -- Influence start_sched (from 1 to inf)
      local num_mission = 9
      local depart_time = defineRequestPosition( num_mission )
      local pos = 1
      local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
      local offSetStartSchedule = 300 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
      local requestStartTime = startReqTimeAir + offSetStartSchedule


      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local nalchik_sched = SCHEDULER:New( staticObject.Warehouse_AB.red.Nalchik[ 1 ],

        function()

          -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
          if wh_activation.Warehouse_AB.red.Nalchik[8] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Mig_27K_Rocket, math.random(AssetQty.red.air.cas[1], AssetQty.red.air.cas[2]), nil, nil, nil, "BAI TARGET") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Nalchik[5] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, math.random(AssetQty.red.air.patrol[1], AssetQty.red.air.patrol[2]), nil, nil, nil, "PATROL") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Nalchik[8] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.GA_Mig_27K_Bomb_Light, math.random( AssetQty.red.air.ga[1], AssetQty.red.air.ga[2] ), nil, nil, nil, "BAI TARGET 2") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Nalchik[8] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_MIG_27K_Structure, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BAI POINT") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Nalchik[7] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_MIG_27K_Airbase, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Nalchik[7] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_MIG_27K_Structure, math.random( AssetQty.red.air.cas[1], AssetQty.red.air.cas[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Nalchik[7] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_MIG_27K_Structure, math.random( AssetQty.red.air.bomb[1], AssetQty.red.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE KHASHURI") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Nalchik[11] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Alagir, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.TRAN_MI_26, math.random(AssetQty.red.heli.transport[1], AssetQty.red.heli.transport[2]), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
          if wh_activation.Warehouse_AB.red.Nalchik[15] and pos <= num_mission then warehouse.Nalchik:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.REC_Mig_25RTB, 1, nil, nil, nil, "AFAC_ZONE_Tskhunvali_Tkviavi") pos = pos + 1  end
          logging('info', { 'main' , 'Nalchik scheduler - start time:' .. start_sched *  nalchik_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * (1-rand_sched) .. ' - ' .. sched_interval * (1+rand_sched)} )

      end, {}, start_sched * nalchik_efficiency_influence, sched_interval, rand_sched

      )


      -- Do something with the spawned aircraft.
      function warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)

        --local groupset=groupset --Core.Set#SET_GROUP
        --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        logging('enter', 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' )
        logging('info', { 'main' , 'warehouse.Nalchik:OnAfterDelivered(From,Event,To,request) - ' .. 'request.assignment: ' .. request.assignment })


        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        if assignment =='AFAC_ZONE_Tskhunvali_Tkviavi' then

          local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Nalchik )

          assignDetectionGroupTask(groupset, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )


        elseif request.assignment == "BAI TARGET" then

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
          local percRequestKill = math.random( 0 , 100 ) * 0.01
          local target = blueGroundGroup[ math.random( 1, #blueGroundGroup ) ][ 1 ]
          local patrolZone = redPatrolZone.nalchik[1]
          local engageZone = blueFrontZone.GORI[1]

          for _, v in pairs(redFrontZone) do

            if math.random(1,10) < 5 then

              engageZone = v[1]
              break

            end -- end if

          end -- end for


          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Nalchik', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )







        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
        elseif request.assignment == "PATROL" then


          local homeAirbase =  AIRBASE.Caucasus.Nalchik
          local patrolZone =  redPatrolZone.nalchik[1]
          local engageRange = math.random(10000, 20000)
          local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
          local patrolFloorAltitude = 4000
          local patrolCeilAltitude = 9000
          local minSpeedPatrol = 400
          local maxSpeedPatrol = 600
          local minSpeedEngage = 600
          local maxSpeedEngage = 1000

          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

          activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )






        ------------------------------------------------------------------------------------------------------ assignment for BAI
        elseif request.assignment == "BAI TARGET 2" then

          --[[
          local avalaible_target_zones = {

              zoneTargetStructure.Blue_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Kutaisi_Bridges) ][1],
              zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
              zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
              zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
              zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

          }
          ]]

          local engageZone = specific_target.blue.zone_targ[ math.random(1, #specific_target.blue.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
          local patrolZone = redPatrolZone.nalchik[1]

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Nalchik against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )




        ------------------------------------------------------------------------------------------------------ assignment for BAI
        elseif request.assignment == "BAI POINT" then

          --[[
          local avalaible_target_zones = {

              zoneTargetStructure.Blue_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Kutaisi_Bridges) ][1],
              zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
              zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
              zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
              zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

          }
          ]]

          local engageZone = specific_target.blue.zone_targ[ math.random(1, #specific_target.blue.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
          local patrolZone = redPatrolZone.nalchik[1]

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Nalchik against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )







        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING AIRBASE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Nalchik
          local target = warehouse_blue.airbase[ math.random( 1, #warehouse_blue.airbase ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )







        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING WAREHOUSE" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Nalchik
          local target = warehouse_blue.farp[ math.random( 1, #warehouse_blue.farp ) ]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
        elseif request.assignment == "BOMBING STRUCTURE KHASHURI" then

          -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

          local home = warehouse.Nalchik
          local target = zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges ) ][1]
          local toTargetAltitude = math.random(5000, 7000)
          local toHomeAltitude = math.random(3000, 5000)
          local bombingDirection = math.random(270, 359)
          local bombingAltitude = math.random(4000, 6000)
          local diveBomb = false
          local bombRunDistance = 20000
          local bombRunDirection = math.random(270, 359)
          local speedBombRun = math.random(400, 600)

          logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

          activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )








        ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
    elseif request.assignment == "TRANSPORT INFANTRY FARP" then


          -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
          --local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Nalchik", 5000, nil)
          --local pickupZone =  cargoZone.Warehouse_AB.red.Nalchik
          --local deployZone =  cargoZone.Warehouse.red.Alagir
          --local speed = math.random( 100 , 250 )

          --logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

          --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )

        else

          logging('warning', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

        end -- end if ..elseif

        logging('exit', 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' )

      end -- end function warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)





      --- When the helo is out of fuel, it will return to the carrier and should be delivered.
      function warehouse.Nalchik:OnAfterDelivered(From,Event,To,request)

        local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        logging('info', { 'warehouse.Nalchik:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })

        --[[
        -- So we start another request.
        if request.assignment=="PATROL" then

          logging('info', { 'warehouse.Nalchik:OnAfterDelivered(From,Event,To,request)' , 'Nalchik scheduled PATROL mission' })
            --activeCAPWarehouse(groupset, "Patrol Zone Nalchik", 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

        end

        if request.assignment=="BAI TARGET" then

          logging('info', { 'warehouse.Nalchik:OnAfterDelivered(From,Event,To,request)' , 'Nalchik scheduled BAI TARGET mission' })
          activeBAIWarehouseA('Interdiction from Nalchik to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], 400, 1000, AI.Task.WeaponExpend.ALL, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

        end -- end if
        ]]

      end -- end function warehouse.Nalchik:OnAfterDelivered(From,Event,To,request)

  end --  end wh_activation.Warehouse_AB.red.Nalchik then
  ------------------------------------------------------------------- END red Nalchik warehouse operations -------------------------------------------------------------------------------------------------------------------------

























































































  ----------------------------------------------------------- BLUE WAREHOUSE OPERATIONS
























  ------------------------------------------------- blue Warehouse ZESTAFONI operations -------------------------------------------------------------------------------------------------------------------------

  if wh_activation.Warehouse.blue.Zestafoni[1] then


      warehouse.Zestafoni:SetSpawnZone(ZONE:New("Warehouse ZESTAFONI Spawn Zone"))
      warehouse.Zestafoni:Start()


      -- Zestafoni e' la warehouse di collegamento per rifornire khashuri e Gori
      warehouse.Zestafoni:AddAsset(           ground_group_template_blue.antitankB,          10,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])] )
      warehouse.Zestafoni:AddAsset(           ground_group_template_blue.antitankA,          10,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])] )
      warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_UH_1H,                  10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  )  -- Transport
      warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_UH_60A,                 10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  )  -- Transport
      warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_CH_47,                  10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
      warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TransportA,         10,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
      warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TransportB,         10,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
      warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TroopTransport,     10,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
      warehouse.Zestafoni:AddAsset(           air_template_blue.CAS_MI_24V,                  12,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]       ) -- Attack
      warehouse.Zestafoni:AddAsset(           air_template_blue.AFAC_MI_24,                  10,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])]  ) -- AFAC
      warehouse.Zestafoni:AddAsset(           air_template_blue.AFAC_SA342L,                 10,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])]  ) -- AFAC
      warehouse.Zestafoni:AddAsset(           ground_group_template_blue.ArtilleryResupply,  10,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport

      logging('info', { 'main' , 'addAsset Zestafoni warehouse'} )

      -- ZESTAFONI warehouse e' una frontline warehouse: invia gli asset sul campo con task assegnato. Didi e' rifornita da Biteta Warehouse

      logging('info', { 'main' , 'addrequest Zestafoni warehouse'} )


      local zestafoni_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
      local num_mission = 5 -- the number of mission request ( _addRequest() )
      local num_mission_helo = 0
      local depart_time = defineRequestPosition(num_mission)
      local pos = 1
      local sched_interval =  math.max(num_mission, num_mission_helo) * waitReqTimeGround / activeGroundRequestRatio

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local zestafoni_sched = SCHEDULER:New( warehouse.Zestafoni,

        function()

          if wh_activation.Warehouse.blue.Zestafoni[12] and pos <= num_mission then warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Zestafoni, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ) , nil, nil, nil, 'CZ_PEREVI_attack_1' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Zestafoni[12] and pos <= num_mission then warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Zestafoni, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'CZ_PEREVI_attack_2' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Zestafoni[12] and pos <= num_mission then warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Zestafoni, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'CZ_ONI_attack_3' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Zestafoni[14] and pos <= num_mission then warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Khashuri, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.TroopTransport, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'Troop_transport' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Zestafoni[14] and pos <= num_mission then warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Khashuri, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.TransportA, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'Ground_transport' ) pos = pos + 1  end
      end, {}, start_ground_sched * zestafoni_efficiency_influence, sched_interval, rand_ground_sched

      ) -- END SCHEDULER

      -- l'eventuale variazione causale dei parametri di missione la devi fare sulla AddRequest: io la farei solo sulle quantit�





      -- Take care of the spawned units.
      function warehouse.Zestafoni:OnAfterSelfRequest( From,Event,To,groupset,request )

        logging('enter', 'warehouse.ZESTAFONI:OnAfterSelfRequest(From,Event,To,groupset,request)' )

        local groupset = groupset --Core.Set#SET_GROUP
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        local suppr_param = {retreatZone = nil, fallBack = true, takeCover = true, delay = 300}

        -- Get assignment of this request.
        local assignment = warehouse.Zestafoni:GetAssignment(request)

        logging('info', { 'warehouse.ZESTAFONI:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

        if assignment == 'CZ_PEREVI_attack_1' then

            activeGO_TO_BATTLE( groupset, redFrontZone.CZ_PEREVI[1], 'enemy_attack', false, 1, true, suppr_param )

        elseif assignment == 'CZ_PEREVI_attack_2' then

            activeGO_TO_BATTLE( groupset, redFrontZone.CZ_ONI[1], 'enemy_attack', false, 1, true, suppr_param  )

        elseif assignment == 'CZ_ONI_attack_3' then

            activeGO_TO_BATTLE( groupset, redFrontZone.CZ_PEREVI[1], 'enemy_attack', false, 1, true, suppr_param  )

        else

            logging('warning', { 'warehouse.Zestafoni:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )

        end

      end -- end function


      --[[


      -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
      -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati
      --
      function warehouse.Zestafoni:OnAfterAssetDead( From, Event, To, asset, request )

          local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment.
          local assignment = warehouse.Zestafoni:GetAssignment( request )

          logging('info', { 'warehouse.Zestafoni:OnAfterAssetDead(From, Event, To, asset, request)' , 'assignment = ' .. assignment .. '  - assetGroupName = ' .. asset.templatename } )

          -- Request resupply for dead asset from Batumi.
          warehouse.Kutaisi:AddRequest( warehouse.Zestafoni, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, nil, nil, nil, nil, "Resupply" )

          -- Send asset to Battle zone either now or when they arrive.
          warehouse.Zestafoni:AddRequest( warehouse.Zestafoni, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment )

      end -- end function

      ]]

  end -- end wh_activation.Warehouse.blue.Zestafoni then
  ------------------------------------------------- END blue Warehouse ZESTAFONI operations -------------------------------------------------------------------------------------------------------------------













































    ----------------------------------------------- blue Warehouse KHASHURI operations ------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse.blue.Khashuri[1] then


        -- Khashuri e' una warehouse del fronte
        --warehouse.Khashuri:AddAsset( "Infantry Platoon Alpha", 50 )


        warehouse.Khashuri:SetSpawnZone(ZONE:New("Warehouse KHASHURI Spawn Zone"))

        warehouse.Khashuri:Start()

        warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankA,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])] )
        warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankC,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])] )
        warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankB,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])] )
        warehouse.Khashuri:AddAsset(           air_template_blue.CAS_MI_24V,                  12,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]       ) -- Attack
        warehouse.Khashuri:AddAsset(           air_template_blue.TRAN_UH_1H,                  10,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] )  -- Transport
        warehouse.Khashuri:AddAsset(           air_template_blue.AFAC_MI_24,                  10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])] ) -- AFAC
        warehouse.Khashuri:AddAsset(           air_template_blue.AFAC_SA342L,                 10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])] ) -- AFAC
        warehouse.Khashuri:AddAsset(           ground_group_template_blue.ArtilleryResupply,  10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
        warehouse.Khashuri:AddAsset(           ground_group_template_blue.TransportA,         10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
        warehouse.Khashuri:AddAsset(           ground_group_template_blue.TransportB,         10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
        warehouse.Khashuri:AddAsset(           ground_group_template_blue.TroopTransport,     10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
        logging('info', { 'main' , 'addAsset Khashuri warehouse'} )
        -- Khashuri warehouse e' una frontline e link warehouse

        logging('info', { 'main' , 'init Warehouse KHASHURI operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa


        -- random targets
        local rndTrgKhashuri = {

          -- [1] = number of mission
          -- [pos mission][1] = name of mission
          -- [pos mission][2] = name of mission
          -- [pos mission][3] = asset group name
          -- [pos mission][4] = quantity
          -- [pos mission][5] = target zone
          -- [pos mission][6] = type of mission

          mechanized = {

            {'DIDMUKHA_attack_1',  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1 , redFrontZone.DIDMUKHA, 'mech_attack'  }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'DIDMUKHA_attack_2',  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, 1, redFrontZone.DIDMUKHA, 'mech_attack'  } -- 3
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          },

          helo = {}

          }



      local khashuri_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
      local num_mission = 4 -- the number of mission request ( _addRequest() )
      local num_mission_helo = 0
      local depart_time = defineRequestPosition( num_mission )
      local pos = 1
      local sched_interval =  math.max(num_mission, num_mission_helo) * waitReqTimeGround / activeGroundRequestRatio

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local khashuri_sched = SCHEDULER:New( warehouse.Khashuri,

        function()

          if wh_activation.Warehouse.blue.Khashuri[12] and pos <= num_mission then warehouse.Khashuri:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Khashuri,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'DIDMUKHA_attack_1' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Khashuri[12] and pos <= num_mission then warehouse.Khashuri:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Khashuri,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'DIDMUKHA_attack_2' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Khashuri[14] and pos <= num_mission then warehouse.Khashuri:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,      WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.TransportA, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'DIDMUKHA_attack_2' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Khashuri[14] and pos <= num_mission then warehouse.Khashuri:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,      WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.TroopTransport, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'DIDMUKHA_attack_2' ) pos = pos + 1  end

      end, {}, start_ground_sched * khashuri_efficiency_influence, sched_interval, rand_ground_sched

      )  -- END SCHEDULER


      -- l'eventuale variazione causale dei parametri di missione la devi fare sulla AddRequest: io la farei solo sulle quantit�

      logging('info', { 'main' , 'addRequest Khashuri warehouse'} )



      -- Take care of the spawned units.
      function warehouse.Khashuri:OnAfterSelfRequest( From,Event,To,groupset,request )

        logging('enter', 'warehouse.Khashuri:OnAfterSelfRequest(From,Event,To,groupset,request)' )

        local groupset = groupset --Core.Set#SET_GROUP
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        local suppr_param = {retreatZone = nil, fallBack = true, takeCover = true, delay = 300}

        -- Get assignment of this request.
        local assignment = warehouse.Khashuri:GetAssignment(request)

        logging('info', { 'warehouse.Khashuri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  -  groupSet = ' .. groupset:GetObjectNames()} )

        if assignment == 'DIDMUKHA_attack_1' then

            activeGO_TO_BATTLE( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1, true, suppr_param)


        elseif assignment == 'DIDMUKHA_attack_2' then

            activeGO_TO_BATTLE( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1, true, suppr_param)

        else

            logging('warning', { 'warehouse.Zestafoni:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )

        end -- if elsif else

        logging('exit', 'warehouse.Khashuri:OnAfterSelfRequest(From,Event,To,groupset,request)' )


      end -- end function


      --[[

      -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di zestafoni (link) quando gli asset vengono distrutti
      -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati
      --
      function warehouse.Khashuri:OnAfterAssetDead( From, Event, To, asset, request )

          logging('enter', 'warehouse.Zestafoni:OnAfterAssetDead( From, Event, To, asset, request )' )

          local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

            -- Get assignment.
          local assignment = warehouse.Khashuri:GetAssignment( request )

          logging('info', { 'warehouse.Didmukha:OnAfterAssetDead(From, Event, To, asset, request)' , 'assignment = ' .. assignment .. '  -  assetGroupName = ' .. asset.templatename } )

            -- Request resupply for dead asset from Batumi.

            warehouse.Zestafoni:AddRequest( warehouse.Satihari, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, nil, nil, nil, nil, "Resupply" )

            -- Send asset to Battle zone either now or when they arrive.
            warehouse.Satihari:AddRequest( warehouse.Satihari, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment )

            logging('exit', 'warehouse.Zestafoni:OnAfterAssetDead( From, Event, To, asset, request )' )

      end -- end function

      ]]

    end -- end wh_activation.Warehouse.blue.Khashuri then
    ----------------------------------------------- END blue Warehouse KHASHURI operations --------------------------------------------------------------------------------------------------------------------














































    ------------------------------------------------ blue Warehouse GORI operations ----------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse.blue.Gori[1] then

      logging('info', { 'main' , 'addAsset Gori warehouse'} )

      warehouse.Gori:SetSpawnZone(ZONE:New("Gori WH Spawn Zone"))
      warehouse.Gori:Start()


      warehouse.Gori:AddAsset(               ground_group_template_blue.antitankA,          10,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.antitankB,          10,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.antitankC,          10,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.ArmorA,             10,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.ArmorB,             10,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiAkatsia,        10,         WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]  )
      warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiGwozdika,       10,         WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]  ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiKatiusha,       10,         WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]  ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiHeavyMortar,    10,         WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]  ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedA,        10,         WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedB,        10,         WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    ) -- Ground troops
      warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedC,        10,         WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    ) -- Ground troops
      warehouse.Gori:AddAsset(               air_template_blue.CAS_MI_24V,                  12,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]       ) -- Attack
      warehouse.Gori:AddAsset(               air_template_blue.TRAN_UH_1H,                  10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] )  -- Transport
      warehouse.Gori:AddAsset(               air_template_blue.TRAN_UH_60A,                 10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
      warehouse.Gori:AddAsset(               ground_group_template_blue.TroopTransport,     10,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
      warehouse.Gori:AddAsset(               ground_group_template_blue.ArtilleryResupply,  10,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
      warehouse.Gori:AddAsset(               ground_group_template_blue.jtac,               10,         WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
      warehouse.Gori:AddAsset(               air_template_blue.AFAC_MI_24,                  10,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])] ) -- AFAC
      warehouse.Gori:AddAsset(               air_template_blue.AFAC_UH_1H,                  10,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])] ) -- AFAC
      warehouse.Gori:AddAsset(               air_template_blue.AFAC_SA342L,                 10,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])] ) -- AFAC


      logging('info', { 'main' , 'addrequest Gori warehouse'} )


      local gori_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
      local num_mission = 7 -- the number of mission request ( _addRequest() )
      local depart_time = defineRequestPosition( num_mission )
      local num_mission_helo = 3 -- the number of mission request ( _addRequest() )
      local depart_time_helo = defineRequestPosition( num_mission_helo )
      local pos = 1
      local pos_heli = 1
      local startReqTimeArtillery = 1 -- Arty groups have first activation
      local startReqTimeGround = startReqTimeArtillery + 420 -- Mech Groups are activated after 7'
      local sched_interval =  math.max(num_mission, num_mission_helo) * waitReqTimeGround / activeGroundRequestRatio

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local gori_sched = SCHEDULER:New( warehouse.Gori,

        function()

          -- artillery request
          warehouse.Gori:__AddRequest( startReqTimeArtillery, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.ArtilleryResupply, 1, nil, nil, nil, 'GORI_Artillery_Resupply' )
          warehouse.Gori:__AddRequest( startReqTimeArtillery + 120 , warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.ArtiAkatsia, 1, nil, nil, nil, 'GORI_Artillery_Ops')


          if wh_activation.Warehouse.blue.Gori[12] and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC,       math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ) , nil, nil, nil, 'TSKHINVALI_Attack_APC' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Gori[12] and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ) , nil, nil, nil, 'TSKHINVALI_attack_2' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Gori[12] and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ) , nil, nil, nil, 'DIDMUKHA_attack_1' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Gori[12] and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ) , nil, nil, nil, 'SATIHARI_attack_1' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Gori[12] and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, math.random( AssetQty.blue.ground.attack[1], AssetQty.blue.ground.attack[2] ), nil, nil, nil, 'SATIHARI_attack_2' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Gori[13] and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.jtac, math.random( AssetQty.blue.ground.recon[1], AssetQty.blue.ground.recon[2] ), nil, nil, nil, 'JTAC_SATIHARI' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Gori[13] and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.jtac, math.random( AssetQty.blue.ground.recon[1], AssetQty.blue.ground.recon[2] ), nil, nil, nil, 'JTAC_TSKHINVALI' ) pos = pos + 1  end
          if wh_activation.Warehouse.blue.Gori[15] and pos_heli <= num_mission_helo then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Gori,   WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_SA342L, math.random( AssetQty.blue.heli.recon[1], AssetQty.blue.heli.recon[2] ), nil, nil, nil, 'AFAC_ZONE_HELO_Tskhunvali_Tkviavi') pos_heli = pos_heli + 1  end
          if wh_activation.Warehouse.blue.Gori[15] and pos_heli <= num_mission_helo then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Gori,   WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_SA342L,  math.random( AssetQty.blue.heli.recon[1], AssetQty.blue.heli.recon[2] ), nil, nil, nil, 'AFAC_ZONE_Tskhunvali_Tkviavi') pos_heli = pos_heli + 1 end
          if wh_activation.Warehouse.blue.Gori[15] and pos_heli <= num_mission_helo then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_UH_1H,  math.random( AssetQty.blue.heli.recon[1], AssetQty.blue.heli.recon[2] ), nil, nil, nil, 'AFAC_ZONE_Didmukha_Tsveri') pos_heli = pos_heli + 1 end

          logging('finer', { 'gori scheduler function' , 'addRequest Gori warehouse'} )

        end, {}, start_ground_sched *  gori_efficiency_influence, sched_interval, rand_ground_sched

      ) -- end gori_sched


      local groupResupplySet

      -- Take care of the spawned units.
      function warehouse.Gori:OnAfterSelfRequest( From,Event,To,groupset,request )

        logging('enter', 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' )

        local groupset = groupset --Core.Set#SET_GROUP
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem
        local suppr_param = {retreatZone = nil, fallBack = true, takeCover = true, delay = 300}

        -- Get assignment of this request.
        local assignment = warehouse.Gori:GetAssignment(request)

        logging('finer', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  -  groupSet = ' .. groupset:GetObjectNames()} )

        -- launch mission functions: mech
        if assignment == 'TSKHINVALI_Attack_APC' then

            activeGO_TO_BATTLE( groupset, redFrontZone.TSKHINVALI[1], 'enemy_attack', false, 1, true, suppr_param )


        elseif assignment == 'TSKHINVALI_attack_2' then

            activeGO_TO_BATTLE( groupset, redFrontZone.TSKHINVALI[1], 'enemy_attack', false, 1, true, suppr_param )


        elseif assignment == 'DIDMUKHA_attack_1' then

            activeGO_TO_BATTLE( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1, true, suppr_param )



        elseif assignment == 'SATIHARI_attack_1' then

            activeGO_TO_BATTLE( groupset, redFrontZone.SATIHARI[1], 'enemy_attack', false, 1, true, suppr_param )



        elseif assignment == 'SATIHARI_attack_2' then

             activeGO_TO_BATTLE( groupset, redFrontZone.DIDI_CUPTA[1], 'enemy_attack', false, 1, true, suppr_param )


        -- launch mission functions: helo
        elseif assignment == 'AFAC_ZONE_Tskhunvali_Tkviavi' then

            logging('finer', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , '                  ----------->               ATTENZIONE   GORI AFAC MISSION               <---------------                       '} )

            activeJTAC( 'air', warehouse.Gori, groupset, blue_command_center, nil, afacZone.Didmukha_Tsveri[ 1 ] )



        elseif assignment == 'AFAC_ZONE_Didmukha_Tsveri' then

            logging('finer', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , '                  ----------->               ATTENZIONE   GORI AFAC MISSION               <---------------                       '} )

            activeJTAC( 'air', warehouse.Gori, groupset, blue_command_center, nil, afacZone.Tskhunvali_Tkviavi[ 1 ] )



        elseif assignment == 'AFAC_ZONE_HELO_Tskhunvali_Tkviavi' then

            -- addGroupSet(detectionGroupSetBlue, groupset)

            logging('finer', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , '                  ----------->               ATTENZIONE   GORI AFAC MISSION               <---------------                       '} )

            activeJTAC( 'air', warehouse.Gori, groupset, blue_command_center, nil, redFrontZone.TSKHINVALI[ 1 ] )



        elseif assignment == 'JTAC_SATIHARI' then

            -- addGroupSet(detectionGroupSetBlue, groupset)

            activeJTAC( 'ground', warehouse.Gori, groupset, blue_command_center, nil, redFrontZone.SATIHARI[1] )



        elseif assignment == 'JTAC_TSKHINVALI' then

            -- addGroupSet(detectionGroupSetBlue, groupset)

            activeJTAC( 'ground', warehouse.Gori, groupset, blue_command_center, nil, redFrontZone.TSKHINVALI[1] )




        -- launch mission function: arty resupply
        elseif assignment == 'GORI_Artillery_Resupply' then

          groupResupplySet = groupset
          -- controlla se targetZoneForRedArty.TSVERI_5 e' coerente come posizione
          --rndTrgGori.artillery[ pos_arty[ 1 ] + 1 ][ 2 ]
          activeGO_TO_ZONE_GROUND( groupset, targetZoneForRedArty.TSVERI_5[1], false, 1 )




        -- launch mission function: arty
        elseif assignment == 'GORI_Artillery_Ops' then

            nameArtyUnits = groupset:GetObjectNames()   -- "Artillery"
            -- nameRecceUnits = recceArtyGroup.GetName()  -- "Recce"
            activateDetectionReport = false


            -- lista dei target e delle ammo
            param = {

                listTargetInfo = {

                    --targetInfo.targetCoordinate,  targetInfo.priority, targetInfo.radiusTarget, targetInfo.num_shots, targetInfo.num_engagements, nil, targetInfo.weaponType

                    [1] = {
                      targetCoordinate = targetZoneForBlueArty.DIDMUKHA_1[1]:GetRandomCoordinate(),
                      priority = 10,
                      radiusTarget = 500,
                      num_shots = 10,
                      num_engagements = 10,
                      weaponType = ARTY.WeaponType.Auto
                    },

                    [2] = {
                      targetCoordinate = targetZoneForBlueArty.DIDMUKHA_2[1]:GetRandomCoordinate(),
                      priority = 50,
                      radiusTarget = 500,
                      num_shots = 10,
                      num_engagements = 7,
                      weaponType = ARTY.WeaponType.Auto
                    },

                    [3] = {
                      targetCoordinate = targetZoneForBlueArty.DIDMUKHA_2[1]:GetRandomCoordinate(),
                      priority = 50,
                      radiusTarget = 500,
                      num_shots = 10,
                      num_engagements = 7,
                      weaponType = ARTY.WeaponType.Auto
                    },

                    [4] = {
                      targetCoordinate = targetZoneForBlueArty.DIDMUKHA_3[1]:GetRandomCoordinate(),
                      priority = 70,
                      radiusTarget = 500,
                      num_shots = 10,
                      num_engagements = 5,
                      weaponType = ARTY.WeaponType.Auto
                    }


                },

                commandCenter = blue_command_center,

                resupplySet = groupResupplySet,

                speed = 60, -- km/h Akatsia max 60 km/h

                onRoad = true,

                maxDistance = 20,

                maxFiringRange = 17000 -- Akatsia min range 0.3 km, max range 17.0 km


            }


            logging('info', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  -  groupSet = ' .. groupset:GetObjectNames() .. ' -  num target assigned = ' .. #param .. ' -  groupResupplySet = ' .. groupResupplySet:GetObjectNames()  } )

            activeGO_TO_ARTY( groupset, targetZoneForRedArty.TSVERI_5[1], param, true, 70 )

        else

            logging('warning', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )

        end

        logging('exit', 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' )

      end -- function warehouse.Gori:OnAfterSelfRequest( From,Event,To,groupset,request )


      --[[

      -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
      -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati
      --
      function warehouse.Gori:OnAfterAssetDead( From, Event, To, asset, request )

        logging('enter', 'warehouse.Gori:OnAfterAssetDead( From, Event, To, asset, request )' )

        local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment.
        local assignment = warehouse.Gori:GetAssignment( request )

        logging('info', { 'warehouse.Gori:OnAfterAssetDead(From, Event, To, asset, request)' , 'assignment = ' .. assignment .. '  - assetGroupName = ' .. asset.templatename } )

          -- Request resupply for dead asset from Batumi.

          warehouse.Soganlug:AddRequest( warehouse.Gori, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, nil, nil, nil, nil, "Resupply" )

          -- Send asset to Battle zone either now or when they arrive.
          warehouse.Gori:AddRequest( warehouse.Gori, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment )

          logging('exit', 'warehouse.Gori:OnAfterAssetDead( From, Event, To, asset, request )' )

      end --  warehouse.Gori:OnAfterAssetDead( From, Event, To, asset, request )

      ]]


    end -- wh_activation.Warehouse.blue.Gori then
    ----------------------------------------------- END blue Warehouse GORI operations -------------------------------------------------------------------------------------------------------------------------





























































    ------------------------------------------------- blue Warehouse BATUMI operations -------------------------------------------------------------------------------------------------------------------------


    if wh_activation.Warehouse_AB.blue.Batumi[1] then


        --  Batumi e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Batumi - Zestafoni - Gori
        -- Batumi e' utilizzato come aeroporto militare. Da Batumi decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.



        warehouse.Batumi:Start()

        warehouse.Batumi:AddAsset(              air_template_blue.CAP_F_5,                  10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]    ) -- Fighter
        warehouse.Batumi:AddAsset(              air_template_blue.CAP_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAP_AJS_37,               10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.GCI_F_4,                  10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.GCI_F_14A,                10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.GCI_AJS_37,               10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_F_4E_Rocket,          10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.REC_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_F_4_E_Structure,      10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_F_4_E_Sparse_Heavy,   10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_F_4_E_Sparse_Light,   10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_F_4_E_Sparse_Cluster, 10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_AV_88_Structure,      10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_AV_88_Heavy_Structure,10,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_AJS_37,               10,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_AV_88_Bomb,           10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_AV_88_Cluster,        10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_AV_88_Rocket,         10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_F_5E_3_Bomb,          10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_F_5E_3_Rocket,        10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_F_5E_3_Cluster,       10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_AJS_37,               10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_B_1B,                 10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.bomber[1], AssetSkill.blue.bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_B_52H,                10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.bomber[1], AssetSkill.blue.bomber[2])]  )
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_AN_26,               10,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE, 9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_C_130,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE, 9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Batumi:AddAsset(               air_template_blue.TRAN_UH_1H,              10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 2000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport ) -- Transport
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_UH_60A,              10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,  4000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_CH_47,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 12700, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Batumi:AddAsset(               air_template_blue.AWACS_F_4,               10,            WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.awacs[1], AssetSkill.blue.awacs[2])]     ) -- AWACS
        warehouse.Batumi:AddAsset(              air_template_blue.AWACS_B_1B,               10,             WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.awacs[1], AssetSkill.blue.awacs[2])]  ) -- AWACS

        logging('info', { 'main' , 'addAsset Batumi warehouse'} )

        local batumi_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
        local num_mission = 9
        local depart_time = defineRequestPosition( num_mission )
        local pos = 1
        local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
        local offSetStartSchedule = 300 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
        local requestStartTime = startReqTimeAir + offSetStartSchedule

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local batumi_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Batumi[ 1 ],

          function()



             -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive

             -- Priority Mission Request
             if wh_activation.Warehouse_AB.blue.Batumi[9] then warehouse.Batumi:__AddRequest( startReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AWACS_B_1B, 1, nil, nil, nil, "AWACS")  end
             -- Normal Mission Request
             if wh_activation.Warehouse_AB.blue.Batumi[15] and pos <= num_mission  then warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.REC_F_4, math.random( AssetQty.blue.air.recon[1], AssetQty.blue.air.recon[2] ), nil, nil, nil, "AFAC_afacZone.Didmukha_Tsveri") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Batumi[8] and pos <= num_mission  then  warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Cluster, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if wh_activation.Warehouse_AB.blue.Batumi[8] and pos <= num_mission  then warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_B_1B, math.random( AssetQty.blue.air.heavy_bomb[1], AssetQty.blue.air.heavy_bomb[2] ), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if wh_activation.Warehouse_AB.blue.Batumi[7] and pos <= num_mission  then warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_B_1B, math.random( AssetQty.blue.air.heavy_bomb[1], AssetQty.blue.air.heavy_bomb[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Batumi[7] and pos <= num_mission  then warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_B_52H, math.random( AssetQty.blue.air.heavy_bomb[1], AssetQty.blue.air.heavy_bomb[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Batumi[7] and pos <= num_mission  then warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_B_52H, math.random( AssetQty.blue.air.heavy_bomb[1], AssetQty.blue.air.heavy_bomb[2] ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Batumi[11] and pos <= num_mission  then warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_C_130, math.random( AssetQty.blue.air.transport[1], AssetQty.blue.air.transport[2] ), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Batumi[11] and pos <= num_mission  then warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Batumi[10] and pos <= num_mission  then warehouse.Batumi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.REC_F_4, math.random( AssetQty.blue.air.recon[1], AssetQty.blue.air.recon[2] ), nil, nil, nil, "RECON AIRBASE") pos = pos + 1  end

             logging('info', { 'main' , 'Batumi scheduler - start time:' .. start_sched *  batumi_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * (1-rand_sched) .. ' - ' .. sched_interval * (1+rand_sched)} )

         end, {}, start_sched *  batumi_efficiency_influence, sched_interval, rand_sched

        ) -- end  tblisi_sched = SCHEDULER:New( nil, ..)



        -- Do something with the spawned aircraft.
        function warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)



          logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })



          ------------------------------------------------------------------------------------------------------ assignment for BAI asset

          if request.assignment == "AFAC_afacZone.Didmukha_Tsveri" then

            local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Batumi )

            assignDetectionGroupSetTask(groupset, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )



          elseif request.assignment == "BAI TARGET" then

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ][ 1 ]
            local patrolZone = bluePatrolZone.kutaisi[1]
            local engageZone = redFrontZone.TSKHINVALI[1]

            for _, v in pairs(redFrontZone) do

              if math.random(1,10) < 5 then

                engageZone = v[1]
                break

              end -- end if

            end -- end for


            logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Batumi', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )



          ----------------------------------------------------------------------------------------------------- assignment for BAI asset
          elseif request.assignment == "BAI STRUCTURE" then

              --[[
              local avalaible_target_zones = {

                  zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                  zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                  --zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

              }
              ]]

              local engageZone = specific_target.red.zone_targ[ math.random(1, #specific_target.red.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
              local patrolZone = bluePatrolZone.kutaisi[1]

              speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

              activeBAI( 'Interdiction from Batumi against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )






          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset

        elseif request.assignment == "AWACS" then


            logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - awacslZone: ' .. blueAwacsZone.kutaisi:GetName() } )

            activeAWACS( groupset, warehouse.Batumi, blue_command_center, nil, blueAwacsZone.kutaisi, math.random(7000,9000), 5000 )

            --[[
            local toTargetAltitude = math.random(7000, 9000)
            local toHomeAltitude = math.random(3000, 5000)
            local reconDirection = math.random(270, 359)
            local reconAltitude = math.random(5000, 7000)
            local reconRunDistance = 20000
            local reconRunDirection = math.random(270, 359)
            local speedReconRun = math.random(400, 600)
            local targets = { cargoZone.Warehouse_AB.red.Mozdok, cargoZone.Warehouse_AB.red.Mineralnye, cargoZone.Warehouse_AB.red.Beslan, cargoZone.Warehouse_AB.red.Nalchik }
            local target = targets[ math.random( 1 , #targets ) ]
            local home =  warehouse.Batumi


            logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home.alias .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

            activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )


            ]]




          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING AIRBASE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

              local home = warehouse.Batumi
              local toTargetAltitude = math.random(5000, 7000)
              local toHomeAltitude = math.random(3000, 5000)
              local bombingDirection = math.random(270, 359)
              local bombingAltitude = math.random(4000, 6000)
              local diveBomb = false
              local bombRunDistance = 20000
              local bombRunDirection = math.random(270, 359)
              local speedBombRun = math.random(400, 600)

              local target = warehouse_red.airbase[ math.random( 1, #warehouse_red.airbase ) ]

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

              activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING WAREHOUSE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

              local home = warehouse.Batumi
              local target = warehouse_red.farp[ math.random( 1, #warehouse_red.farp ) ]
              local toTargetAltitude = math.random(5000, 7000)
              local toHomeAltitude = math.random(3000, 5000)
              local bombingDirection = math.random(270, 359)
              local bombingAltitude = math.random(4000, 6000)
              local diveBomb = false
              local bombRunDistance = 20000
              local bombRunDirection = math.random(270, 359)
              local speedBombRun = math.random(400, 600)

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

              activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )




          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING MIL ZONE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

              local home = warehouse.Batumi
              local target = zoneTargetStructure.Red_Military_Base[ math.random( 1, #zoneTargetStructure.Red_Military_Base ) ][1]
              local toTargetAltitude = math.random(5000, 7000)
              local toHomeAltitude = math.random(3000, 5000)
              local bombingDirection = math.random(270, 359)
              local bombingAltitude = math.random(4000, 6000)
              local diveBomb = false
              local bombRunDistance = 20000
              local bombRunDirection = math.random(270, 359)
              local speedBombRun = math.random(400, 600)

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

              activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






          ------------------------------------------------------------------------------------------------------ assignment for TRANSPORT asset
      elseif request.assignment == "TRANSPORT VEHICLE AIRBASE" then



              -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
              --local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Nalchik", 5000, nil)

              --local destination = AIRBASE.Caucasus.Tbilisi_Lochini --airbase_blue[ math.random( 1 , #airbase_blue ) ]
              --local speed = math.random( 300 , 500 )

              --logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - : ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count: ' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )

              --activeCargoAirPlane( groupset, AIRBASE.Caucasus.Tbilisi_Lochini, AIRBASE.Caucasus.Batumi, speed, cargoGroupSet )







          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY FARP" then



            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Nalchik", 5000, nil)

            --local pickupZone =  cargoZone.Warehouse_AB.blue.Batumi
            --local deployZone =  cargoZone.Warehouse.blue.Gori
            --local speed = math.random( 100 , 250 )

            --logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - : ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count: ' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )
            --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )




      ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "DISPATCHING AIRBASE TRANSPORT" then


            local cargoGroupSet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
            local AirplanesSet = groupset

            logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() } )

            local PickupZoneSet = SET_ZONE:New()
            local DeployZoneSet = SET_ZONE:New()

            PickupZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Batumi ) )
            DeployZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Kutaisi ) )
            DeployZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Tbilisi_Lochini ) )

            AICargoDispatcherAirplanes = AI_CARGO_DISPATCHER_AIRPLANE:New( AirplanesSet, cargoGroupSet, PickupZoneSet, DeployZoneSet )

            AICargoDispatcherAirplanes.SetPickupRadius(1000, 30)--: Sets or randomizes the pickup location for the carrier around the cargo coordinate in a radius defined an outer and optional inner radius.
            AICargoDispatcherAirplanes.SetPickupSpeed(600, 350)--: Set the speed or randomizes the speed in km/h to pickup the cargo.
            AICargoDispatcherAirplanes.SetPickupHeight(9000, 3000)--: Set the height or randomizes the height in meters to pickup the cargo.
            AICargoDispatcherAirplanes.SetDeployRadius(1000, 30)--: Sets or randomizes the deploy location for the carrier around the cargo coordinate in a radius defined an outer and an optional inner radius.
            AICargoDispatcherAirplanes.SetDeploySpeed(400, 300)--: Set the speed or randomizes the speed in km/h to deploy the cargo.
            AICargoDispatcherAirplanes.SetDeployHeight(7000, 4000)--: Set the height or randomizes the height in meters to deploy the cargo.
            AICargoDispatcherAirplanes.SetHomeZone(AIRBASE.Caucasus.Batumi)


            AICargoDispatcherAirplanes:Start()

            function AICargoDispatcherAirplanes:OnAfterLoaded( From, Event, To, CarrierGroup, Cargo, CarrierUnit, PickupZone )

               logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterLoaded ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterPickedUp( From, Event, To, CarrierGroup, PickupZone )

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterPickedUp ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end


            function AICargoDispatcherAirplanes:OnAfterDeploy( From, Event, To, CarrierGroup, Coordinate, Speed, Height, DeployZone )

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterDeploy ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterUnload( From, Event, To, CarrierGroup, DeployZone )

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterUnload ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterUnload( From, Event, To, CarrierGroup, Cargo, CarrierUnit, DeployZone )

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterUnload ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterUnloaded( From, Event, To, CarrierGroup, Cargo, CarrierUnit, DeployZone )

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterUnloaded ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterDeployed( From, Event, To, CarrierGroup, DeployZone )

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterDeployed ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )










          ------------------------------------------------------------------------------------------------------ assignment for RECON asset
        elseif request.assignment == "RECON AIRBASE" then

              local toTargetAltitude = math.random(7000, 9000)
              local toHomeAltitude = math.random(3000, 5000)
              local reconDirection = math.random(270, 359)
              local reconAltitude = math.random(5000, 7000)
              local reconRunDistance = 20000
              local reconRunDirection = math.random(270, 359)
              local speedReconRun = math.random(400, 600)
              local targets = { cargoZone.Warehouse_AB.red.Mozdok, cargoZone.Warehouse_AB.red.Mineralnye, cargoZone.Warehouse_AB.red.Beslan, cargoZone.Warehouse_AB.red.Nalchik }
              local target = targets[ math.random( 1 , #targets ) ]
              local home =  warehouse.Batumi


              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home.alias .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

              -- addGroupSet(detectionGroupSetBlue, groupset)

              activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )


          else

            logging('warning', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

          end -- end if ...elseif


        end --  warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)


          --- When the helo is out of fuel, it will return to the carrier and should be delivered.
         -- DA ELIMINARE: LA RIPETIZIONE DELLA MISSIONE E' ESEGUITA DALLO SCHEDULER
        function warehouse.Batumi:OnAfterDelivered(From,Event,To,request)

          -- le diverse opzioni disponibili per la scelta casuale della missione
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          logging('info', { 'warehouse.Batumi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled mission number - request.assignment: ' .. request.assignment })

          -- manca il groupset
          -- So we start another request.
          --if request.assignment=="PATROL" then

            --local pos = math.random( 1 , #param )

            --logging('info', { 'warehouse.Batumi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled PATROL mission number:  - pos: ' .. pos .. ' - groupset name: ' .. groupset:GetObjectNames()} )
            --activeCAPWarehouse(groupset, redFrontZone.BAI_Zone_Batumi[2], 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )
            -- warehouse.Batumi:AddRequest(warehouse.Pampa, WAREHOUSE.Descriptor.ATTRIBUTE, request.cargoattribute, request.ndelivered, WAREHOUSE.TransportType.APC, WAREHOUSE.Quantity.ALL)

          --end

          --if request.assignment=="BAI STRUCTURE" then

            --logging('info', { 'warehouse.Batumi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled BAI STRUCTURE mission number:  - pos: ' .. pos .. ' - groupset name: ' .. groupset:GetObjectNames()} )
            --activeBAIWarehouseT('Interdiction from Batumi', groupset, 'target', redFrontZone.BAI_Zone_Batumi[2], redFrontZone.BAI_Zone_Batumi[2], 400, 1000, 4, 2, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

          --end -- end if

        end -- end warehouse.Batumi:OnAfterDelivered(From,Event,To,request)

    end -- wh_activation.Warehouse_AB.blue.Batumi then
    ------------------------------------------------- END blue Warehouse BATUMI operations -------------------------------------------------------------------------------------------------------------------------



















































    ------------------------------------------------- blue Warehouse KUTAISI operations -------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse_AB.blue.Kutaisi[1] then


        warehouse.Kutaisi:Start()

        --  Kutaisi e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Kutaisi - Zestafoni - Gori
        -- Kutaisi e' utilizzato come aeroporto militare. Da Kutaisi decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.

        warehouse.Kutaisi:AddAsset(               air_template_blue.CAP_Mig_21Bis,            20,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]   ) -- Fighter
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAP_F_5,                  20,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]   ) -- Fighter
        warehouse.Kutaisi:AddAsset(               air_template_blue.REC_L_39ZA,                10,            WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.recon[1], AssetSkill.blue.recon[2])]  ) -- Reco
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_F_5E_3_Rocket,        10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_F_5E_3_Cluster,       10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,          10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_L_39ZA_HRocket,       10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_AN_26,                10,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_C_130,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport ) -- Transport
        warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_CH_47,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Kutaisi:AddAsset(               air_template_blue.AWACS_F_4,                 10,             WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.awacs[1], AssetSkill.blue.awacs[2])] ) -- AWACS
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.Truck,           10,             WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankA,       10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankB,       10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankC,       10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArmorA,          10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArmorB,          10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,            WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,            WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedA,     10,            WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedB,     10,            WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedC,     10,            WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TransportA,      10,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TransportB,      10,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TroopTransport,  10,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport

        logging('info', { 'main' , 'addAsset Kutaisi warehouse'} )





        local kutaisi_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
        local num_mission = 11
        local depart_time = defineRequestPosition( num_mission )
        local pos = 1
        local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
        local offSetStartSchedule = 300 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
        local requestStartTime = startReqTimeAir + offSetStartSchedule

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local kutaisi_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Kutaisi[ 1 ],

          function()



             -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
             -- Priority Mission
             if wh_activation.Warehouse_AB.blue.Kutaisi[9] then warehouse.Kutaisi:__AddRequest( startReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AWACS_F_4, 1, nil, nil, nil, "AWACS")  end
             -- Normal Mission Request
             if wh_activation.Warehouse_AB.blue.Kutaisi[15] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.REC_L_39ZA, math.random( AssetQty.blue.air.recon[1], AssetQty.blue.air.recon[2] ), nil, nil, nil, "AFAC_afacZone.Didmukha_Tsveri") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Kutaisi[8] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Cluster, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if wh_activation.Warehouse_AB.blue.Kutaisi[8] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if wh_activation.Warehouse_AB.blue.Kutaisi[5] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, math.random( AssetQty.blue.air.patrol[1], AssetQty.blue.air.patrol[2] ), nil, nil, nil, "PATROL") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Kutaisi[7] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Kutaisi[7] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Kutaisi[7] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Kutaisi[11] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_C_130, math.random( AssetQty.blue.air.transport[1], AssetQty.blue.air.transport[2] ), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Kutaisi[11] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Kutaisi[11] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, math.random( AssetQty.blue.ground.transport[1], AssetQty.blue.ground.transport[2] ), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
             if wh_activation.Warehouse_AB.blue.Kutaisi[10] and pos <= num_mission then warehouse.Kutaisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.REC_L_39ZA, math.random( AssetQty.blue.air.recon[1], AssetQty.blue.air.recon[2] ), nil, nil, nil, "RECON FARP") pos = pos + 1  end


             logging('info', { 'main' , 'Tblisi scheduler - start time:' .. start_sched *  kutaisi_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * (1-rand_sched) .. ' - ' .. sched_interval * (1+rand_sched)} )

         end, {}, start_sched *  kutaisi_efficiency_influence, sched_interval, rand_sched

      ) -- end  tblisi_sched = SCHEDULER:New( nil, ..)



      -- Do something with the spawned aircraft.
      function warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)



        logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })



        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        if request.assignment == "AFAC_afacZone.Didmukha_Tsveri" then

          local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Kutaisi )

          assignDetectionGroupSetTask(groupset, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )



        elseif request.assignment == "BAI TARGET" then

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
          local percRequestKill = math.random( 0 , 100 ) * 0.01
          local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ][ 1 ]
          local patrolZone = bluePatrolZone.kutaisi[1]
          local engageZone = redFrontZone.TSKHINVALI[1]

          for _, v in pairs(redFrontZone) do

            if math.random(1,10) < 5 then

              engageZone = v[1]
              break

            end -- end if

          end -- end for


          logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Kutaisi', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )



        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        elseif request.assignment == "BAI STRUCTURE" then

            --[[
            local avalaible_target_zones = {

                zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                --zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

            }
            ]]

            local engageZone = specific_target.red.zone_targ[ math.random(1, #specific_target.red.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
            local patrolZone = bluePatrolZone.kutaisi[1]

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Kutaisi against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )






        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset

        elseif request.assignment == "AWACS" then

          logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - awacsZone: ' .. blueAwacsZone.kutaisi:GetName()} )

          activeAWACS( groupset, warehouse.Kutaisi, blue_command_center, nil, blueAwacsZone.kutaisi, math.random(5000, 9000), 5000 )






        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset

        elseif request.assignment == "PATROL" then

          local homeAirbase =  AIRBASE.Caucasus.Kutaisi
          local patrolZone =  bluePatrolZone.kutaisi[1]
          local engageRange = math.random(10000, 20000)
          local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
          local patrolFloorAltitude = 4000
          local patrolCeilAltitude = 9000
          local minSpeedPatrol = 400
          local maxSpeedPatrol = 600
          local minSpeedEngage = 600
          local maxSpeedEngage = 1000

          logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
          logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

          activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )




        ------------------------------------------------------------------------------------------------------ assignment for PATROL PATROL WITH ENGAGE ZONE (NON ATTIVO: NON INSERITO NELLE ADDREQUEST)
        elseif request.assignment == "PATROL WITH ENGAGE ZONE" then

          local homeAirbase =  AIRBASE.Caucasus.Kutaisi
          local engageZone = redFrontZone.TSKHINVALI[1]

          for _, v in pairs(redFrontZone) do

            if math.random(1,10) < 5 then

              engageZone = v[1]
              break

            end -- end if

          end -- end for


          local patrolZone =  bluePatrolZone.kutaisi[1]
          local engageRange = math.random(10000, 20000)
          local patrolFloorAltitude = 4000
          local patrolCeilAltitude = 9000
          local minSpeedPatrol = 400
          local maxSpeedPatrol = 600
          local minSpeedEngage = 600
          local maxSpeedEngage = 1000


          logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
          logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

          activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )





        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
        elseif request.assignment == "BOMBING AIRBASE" then

            -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Kutaisi
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            local target = warehouse_red.airbase[ math.random( 1, #warehouse_red.airbase ) ]

            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )







        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
        elseif request.assignment == "BOMBING WAREHOUSE" then

            -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Kutaisi
            local target = warehouse_red.farp[ math.random( 1, #warehouse_red.farp ) ]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )







          elseif request.assignment == "BOMBING MIL ZONE" then

            -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Kutaisi
            local target = zoneTargetStructure.Red_Military_Base[ math.random( 1, #zoneTargetStructure.Red_Military_Base ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






          ------------------------------------------------------------------------------------------------------ assignment for TRANSPORT asset
          elseif request.assignment == "TRANSPORT VEHICLE AIRBASE" then


            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles Kutaisi", 5000, nil)

            --local destination = AIRBASE.Caucasus.Batumi --airbase_blue[ math.random( 1 , #airbase_blue ) ]
            --local speed = math.random( 300 , 500 )

            --logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - : ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )

            --activeCargoAirPlane( groupset, AIRBASE.Caucasus.Kutaisi, destination, speed, cargoGroupSet )







        ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
        elseif request.assignment == "TRANSPORT INFANTRY FARP" then


            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kutaisi", 5000, nil)

            --local pickupZone =  cargoZone.Warehouse_AB.blue.Kutaisi
            --local deployZone =  cargoZone.Warehouse.blue.Gori
            --local speed = math.random( 100 , 250 )

            --logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - : ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )







        ------------------------------------------------------------------------------------------------------ assignment for RECON asset
        elseif request.assignment == "RECON FARP" then

            local toTargetAltitude = math.random(7000, 9000)
            local toHomeAltitude = math.random(3000, 5000)
            local reconDirection = math.random(270, 359)
            local reconAltitude = math.random(5000, 7000)
            local reconRunDistance = 20000
            local reconRunDirection = math.random(270, 359)
            local speedReconRun = math.random(400, 600)
            local targets = { cargoZone.Warehouse.red.Biteta, cargoZone.Warehouse.red.Didi, cargoZone.Warehouse.red.Kvemo_Sba, cargoZone.Warehouse.red.Alagir }
            local target = targets[ math.random( 1 , #targets ) ]
            local home = warehouse.Kutaisi


            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home.alias .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

            -- -- addGroupSet(detectionGroupSetBlue, groupset)

            activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )








        ------------------------------------------------------------------------------------------------------ assignment for RECON asset
        elseif request.assignment == "TRANSFER MECHANIZED SELFPROPELLED" then

            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - tblisi scheduled mission number - request.assignment: ' .. request.assignment .. '  - ASSET DELIVERD: ACQUISITO DALLA WAREHOUSE DI DESTINAZIONE' })

        else

            logging('warning', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

        end -- end if ...elseif


      end  --end  function warehouse.Kutaisi:OnAfterSelfRequest(From, Event, To, groupset, request)




      --- When the helo is out of fuel, it will return to the carrier and should be delivered.
      -- DA ELIMINARE: LA RIPETIZIONE DELLA MISSIONE E' ESEGUITA DALLO SCHEDULER
      function warehouse.Kutaisi:OnAfterDelivered(From,Event,To,request)

        -- le diverse opzioni disponibili per la scelta casuale della missione
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        logging('info', { 'warehouse.Kutaisi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled mission number - request.assignment: ' .. request.assignment })

        -- manca il groupset
        -- So we start another request.
        --if request.assignment=="PATROL" then

          --local pos = math.random( 1 , #param )

          --logging('info', { 'warehouse.Kutaisi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled PATROL mission number:  - pos: ' .. pos .. ' - groupset name: ' .. groupset:GetObjectNames()} )
          --activeCAPWarehouse(groupset, redFrontZone.BAI_Zone_Kutaisi[2], 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )
          -- warehouse.Batumi:AddRequest(warehouse.Pampa, WAREHOUSE.Descriptor.ATTRIBUTE, request.cargoattribute, request.ndelivered, WAREHOUSE.TransportType.APC, WAREHOUSE.Quantity.ALL)

        --end

        --if request.assignment=="BAI STRUCTURE" then

          --logging('info', { 'warehouse.Kutaisi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled BAI STRUCTURE mission number:  - pos: ' .. pos .. ' - groupset name: ' .. groupset:GetObjectNames()} )
          --activeBAIWarehouseT('Interdiction from Kutaisi', groupset, 'target', redFrontZone.BAI_Zone_Kutaisi[2], redFrontZone.BAI_Zone_Kutaisi[2], 400, 1000, 4, 2, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

        --end -- end if

      end -- end warehouse.Kutaisi:OnAfterDelivered(From,Event,To,request)

    end -- wh_activation.Warehouse_AB.blue.Kutaisi then

    ------------------------------------------------- END blue Warehouse KUTAISI operations -------------------------------------------------------------------------------------------------------------------------



































































    ------------------------------------------------- blue Warehouse KVITIRI operations -------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse_AB.blue.Kvitiri[1] then


        warehouse.Kvitiri:Start()

        --  Kvitiri e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Kvitiri - Zestafoni - Gori
        -- Kvitiri e' utilizzato come aeroporto militare. Da Kvitiri decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.

        warehouse.Kvitiri:AddAsset(               air_template_blue.CAP_L_39ZA,                 10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]    ) -- Fighter
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAP_F_5,                    10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]    ) -- Fighter
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_F_5E_3_Rocket,          10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber BAI
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_F_5E_3_Cluster,         10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber BAI
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,            10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber BAI
        warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_AN_26,                 10,             WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_C_130,                 10,             WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_CH_47,                 10,             WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.AFAC_L_39ZA,                10,             WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_L_39C_Rocket,           10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Bomber
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_L_39ZA_HRocket,         10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]     ) -- Heli CAS
        warehouse.Kvitiri:AddAsset(               air_template_blue.REC_L_39ZA,                 10,             WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.recon[1], AssetSkill.blue.recon[2])]  ) -- AWACS

        logging('info', { 'main' , 'addAsset Kvitiri warehouse'} )

        -- blue Kvitiri warehouse operations

        logging('info', { 'main' , 'addrequest Kvitiri warehouse'} )



        local kvitiri_efficiency_influence = math.random(10, 20) * 0.1
        local num_mission = 12
        local depart_time = defineRequestPosition( num_mission )
        local pos = 1
        local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
        local offSetStartSchedule = 300 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
        local requestStartTime = startReqTimeAir + offSetStartSchedule

        local kvitiri_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Kvitiri[ 1 ],

            function()




              -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive

                if wh_activation.Warehouse_AB.blue.Kvitiri[8] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_L_39ZA_HRocket, math.random(AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2]), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
                if wh_activation.Warehouse_AB.blue.Kvitiri[8] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random(AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2]), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
                if wh_activation.Warehouse_AB.blue.Kvitiri[5] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_L_39ZA, math.random( AssetQty.blue.air.patrol[1], AssetQty.blue.air.patrol[2] ), nil, nil, nil, "PATROL") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[8] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, math.random( AssetQty.blue.air.patrol[1], AssetQty.blue.air.patrol[2] ), nil, nil, nil, "PATROL WITH ENGAGE ZONE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[7] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Cluster, math.random(AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2]), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[7] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random(AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2]), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[7] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2]), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[7] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2]), nil, nil, nil, "BOMBING STRUCTURE BITETA") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[11] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, math.random(AssetQty.blue.air.transport[1], AssetQty.blue.air.transport[2]), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[11] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random(AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2]), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[11] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, math.random(AssetQty.blue.ground.transport[1], AssetQty.blue.ground.transport[2]), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri[15] and pos <= num_mission then warehouse.Kvitiri:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_L_39ZA, 1, nil, nil, nil, "AFAC_afacZone.Didmukha_Tsveri") pos = pos + 1  end -- AFAC
                logging('info', { 'main' , 'Kvitiri scheduler - start time:' .. start_sched *  kvitiri_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * ( 1 - rand_sched ) .. ' - ' .. sched_interval * ( 1 + rand_sched ) } )

            end, {}, start_sched * kvitiri_efficiency_influence, sched_interval, rand_sched

        ) -- end  vaziani_sched = SCHEDULER:New( nil, ..)







        -- Do something with the spawned aircraft.
        function warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)

          logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' ,  ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })


          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "AFAC_afacZone.Didmukha_Tsveri" then

            local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Kvitiri )

            assignDetectionGroupSetTask(groupset, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )






          elseif request.assignment == "BAI TARGET" then


            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')


            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local  percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ][ 1 ]
            local patrolZone = bluePatrolZone.tbilisi[1]
            local engageZone = redFrontZone.TSKHINVALI[1]

            for _, v in pairs(redFrontZone) do

              if math.random(1,10) < 5 then

                engageZone = v[1]
                break

              end -- end if

            end -- end for


            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Kvitiri', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )




          elseif request.assignment == "BAI STRUCTURE" then

            --[[
            local avalaible_target_zones = {

                zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

            }
            ]]

            local engageZone = specific_target.red.zone_targ[ math.random(1, #specific_target.red.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
            local patrolZone = bluePatrolZone.vaziani[1]


            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Kvitiri against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )





          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
          elseif request.assignment == "PATROL" then

              -- groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage
              local homeAirbase =  AIRBASE.Caucasus.Kvitiri
              local patrolZone =  bluePatrolZone.vaziani[1] --bluePatrolZone[ math.random( 1, #bluePatrolZone ) ]
              local engageRange = math.random(10000, 20000)
              local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
              local patrolFloorAltitude = 4000
              local patrolCeilAltitude = 9000
              local minSpeedPatrol = 400
              local maxSpeedPatrol = 600
              local minSpeedEngage = 600
              local maxSpeedEngage = 1000

              logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
              logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

              activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase)




          ------------------------------------------------------------------------------------------------------ assignment for PATROL MIG 21 asset
          elseif request.assignment == "PATROL WITH ENGAGE ZONE" then

            local homeAirbase =  AIRBASE.Caucasus.Kvitiri
            local engageZone = redFrontZone.TSKHINVALI[1]

            for _, v in pairs(redFrontZone) do

              if math.random(1,10) < 5 then

                engageZone = v[1]
                break

              end -- end if

            end -- end for

            local patrolZone =  bluePatrolZone.vaziani[1] --bluePatrolZone[ math.random( 1, #bluePatrolZone ) ]
            local engageRange = math.random(10000, 20000)
            local patrolFloorAltitude = 4000
            local patrolCeilAltitude = 9000
            local minSpeedPatrol = 400
            local maxSpeedPatrol = 600
            local minSpeedEngage = 600
            local maxSpeedEngage = 1000

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

            activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )





          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING AIRBASE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Kvitiri
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            local target = warehouse_red.airbase[ math.random( 1, #warehouse_red.airbase ) ]

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING WAREHOUSE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Kvitiri
            local target = warehouse_red.farp[ math.random( 1, #warehouse_red.farp ) ]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING MIL ZONE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Kvitiri
            local target = zoneTargetStructure.Red_Military_Base[ math.random( 1, #zoneTargetStructure.Red_Military_Base ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING STRUCTURE BITETA" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Kvitiri
            local target = zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )




          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT VEHICLE AIRBASE" then



              -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
              --local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles Kvitiri", 5000, nil)


              --local destination = airbase_blue[ math.random( 1 , #airbase_blue ) ]
              --local speed = math.random( 300 , 500 )

              --logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )

              --activeCargoAirPlane( groupset, AIRBASE.Caucasus.Kvitiri, destination, speed, cargoGroupSet )






          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY FARP" then


            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kvitiri", 5000, nil)

            --local pickupZone =  cargoZone.Warehouse_AB.blue.Kvitiri
            --local deployZone =  cargoZone.Warehouse.blue.Zestafoni
            --local speed = math.random( 100 , 250 )

            --logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )




          ------------------------------------------------------------------------------------------------------ assignment for RECON asset
          elseif request.assignment == "RECON AIRBASE" then

            local toTargetAltitude = math.random(7000, 9000)
            local toHomeAltitude = math.random(3000, 5000)
            local reconDirection = math.random(270, 359)
            local reconAltitude = math.random(5000, 7000)
            local reconRunDistance = 20000
            local reconRunDirection = math.random(270, 359)
            local speedReconRun = math.random(400, 600)
            local targets = { cargoZone.Warehouse_AB.red.Mozdok, cargoZone.Warehouse_AB.red.Mineralnye, cargoZone.Warehouse_AB.red.Beslan, cargoZone.Warehouse_AB.red.Nalchik }
            local target = targets[ math.random( 1 , #targets ) ]
            local home =  warehouse.Kvitiri

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home.alias .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

            -- addGroupSet(detectionGroupSetBlue, groupset)

            activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )







          elseif request.assignment == "TRANSFER MECHANIZED SELFPROPELLED" then

              logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - tblisi scheduled mission number - request.assignment: ' .. request.assignment .. '  - ASSET DELIVERD: ACQUISITO DALLA WAREHOUSE DI DESTINAZIONE' })

          else

              logging('warning', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

          end  -- end if ...elseif



        end -- end function warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)



        --- quando ritorna alla base viene 'riassorbito' e quindi viene lanciato questo evento. Utilizzato per rilanciare la missione dopo un RTB
        -- puo' non servire se le missioni sono schedulate
        function warehouse.Kvitiri:OnAfterDelivered(From,Event,To,request)

              -- le diverse opzioni disponibili per la scelta casuale della missione
              local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

              logging('info', { 'warehouse.Kvitiri:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })
              -- manca il groupset
              -- So we start another request.
              --[[
              if request.assignment=="PATROL" then

                  logging('info', { 'warehouse.Kvitiri:OnAfterDelivered(From,Event,To,request)' , 'vaziani scheduled PATROL mission'})
                  activeCAPWarehouse(groupset, redFrontZone.BAI_Zone_Kvitiri[2], 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

              end

              if request.assignment=="BAI TARGET" then

                logging('info', { 'warehouse.Kvitiri:OnAfterDelivered(From,Event,To,request)' , 'vaziani scheduled BAI TARGET mission'})
                activeBAIWarehouseT('Interdiction from Kvitiri', groupset, 'target', redFrontZone.BAI_Zone_Kvitiri[2], redFrontZone.BAI_Zone_Kvitiri[2], 400, 1000, 4, 2, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

              end -- end if

              ]]

        end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)



    end -- end wh_activation.Warehouse_AB.blue.Kvitiri then
    ------------------------------------------------- END blue Warehouse KVITIRI operations -------------------------------------------------------------------------------------------------------------------------
































































    ------------------------------------------------- blue Warehouse KVITIRI_HELO operations -------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[1] then

        warehouse.Kvitiri_Helo:Start()

        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_UH_1H,               10,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_UH_60A,              15,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_CH_47,               15,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_UH_1H,                10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]    ) -- Heli CAS
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_UH_60A,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]    ) -- Heli CAS
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_SA_342,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]    ) -- Heli CAS
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.AFAC_UH_1H,               10,            WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])]    ) -- Heli AFAC
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.AFAC_SA342L,              10,            WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])]    ) -- Heli AFAC
        warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.TransportA,      10,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    ) -- Ground Transport
        warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.TransportB,      10,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    ) -- Ground Transport
        warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.TroopTransport,  10,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    ) -- Ground Transport


        logging('info', { 'main' , 'addAsset Kvitiri_Helo warehouse'} )


        -- blue Kvitiri_Helo warehouse operations

        logging('info', { 'main' , 'addrequest Kvitiri_Helo warehouse'} )



        local kvitiri_helo_efficiency_influence = math.random(10, 20) * 0.1
        local num_mission = 3
        local num_mission_helo = 5
        local depart_time_heli = defineRequestPosition( num_mission_helo ) -- heli mission
        local depart_time = defineRequestPosition( num_mission )
        local pos = 1
        local pos_heli = 1
        local sched_interval =  math.max(num_mission, num_mission_helo) * waitReqTimeGround / activeGroundRequestRatio

        local kvitiri_helo_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Kvitiri_Helo[ 1 ],

            function()

                if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[11] and pos_heli <= num_mission_helo then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time_heli[ pos_heli ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_UH_1H, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP GORI") pos_heli = pos_heli + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[11] and pos_heli <= num_mission_helo then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time_heli[ pos_heli ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_UH_60A, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP KHASHURI") pos_heli = pos_heli + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[11] and pos_heli <= num_mission_helo then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time_heli[ pos_heli ] * waitReqTimeAir, warehouse.Khashuri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT VEHICLE FARP ZESTAFONI") pos_heli = pos_heli + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[11] and pos_heli <= num_mission_helo then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time_heli[ pos_heli ] * waitReqTimeAir, warehouse.Zestafoni, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY AIRBASE") pos_heli = pos_heli + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[10] and pos_heli <= num_mission_helo then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time_heli[ pos_heli ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_SA342L, 1, nil, nil, nil, "RECON FARP") pos_heli = pos_heli + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[14] and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeAir, warehouse.Zestafoni, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.TransportA, math.random( AssetQty.blue.ground.transport[1], AssetQty.blue.ground.transport[2] ), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[14] and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.TransportB, math.random( AssetQty.blue.ground.transport[1], AssetQty.blue.ground.transport[2] ), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[14] and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeAir, warehouse.Khashuri, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.TroopTransport, math.random( AssetQty.blue.ground.transport[1], AssetQty.blue.ground.transport[2] ), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
                logging('info', { 'main' , 'Kvitiri_Helo scheduler - start time:' .. start_sched *  kvitiri_helo_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * ( 1 - rand_sched ) .. ' - ' .. sched_interval * ( 1 + rand_sched ) } )

            end, {}, start_sched * kvitiri_helo_efficiency_influence, sched_interval, rand_sched

        ) -- end  vaziani_sched = SCHEDULER:New( nil, ..)







        -- Do something with the spawned aircraft.
        function warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)

          logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' ,  ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })




          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
          if request.assignment == "TRANSPORT INFANTRY FARP GORI" then


            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kvitiri_Helo", 5000, nil)


            --local pickupZone =  cargoZone.Warehouse_AB.blue.Kvitiri_Helo
            --local deployZone =  cargoZone.Warehouse.blue.Gori
            --local speed = math.random( 100 , 250 )

            --logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )








          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY FARP KHASHURI" then


            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kvitiri_Helo #001", 5000, nil)


            --local pickupZone =  cargoZone.Warehouse_AB.blue.Kvitiri_Helo
            --local deployZone =  cargoZone.Warehouse.blue.Khashuri
            --local speed = math.random( 100 , 250 )

            --logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )








          ------------------------------------------------------------------------------------------------------ assignment for TRANSPORT asset
      elseif request.assignment == "TRANSPORT VEHICLE FARP ZESTAFONI" then


            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles Kvitiri_Helo", 5000, nil)


            --local pickupZone =  cargoZone.Warehouse_AB.blue.Kvitiri_Helo
            --local deployZone =  cargoZone.Warehouse.blue.Zestafoni
            --local speed = math.random( 100 , 250 )

            --logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )








          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY AIRBASE" then



              -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
              --local  cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kvitiri_Helo #002", 5000, nil)


              --local destination = AIRBASE.Caucasus.Vaziani
              --local speed = math.random( 100 , 250 )

              --logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

              --activeCargoAirPlane( groupset, AIRBASE.Caucasus.Kvitiri_Helo, destination, speed, cargoGroupSet )







          ------------------------------------------------------------------------------------------------------ assignment for RECON asset
        elseif request.assignment == "RECON FARP" then

            local toTargetAltitude = math.random(7000, 9000)
            local toHomeAltitude = math.random(3000, 5000)
            local reconDirection = math.random(270, 359)
            local reconAltitude = math.random(5000, 7000)
            local reconRunDistance = 20000
            local reconRunDirection = math.random(270, 359)
            local speedReconRun = math.random(400, 600)
            local targets = { cargoZone.Warehouse.red.Biteta, cargoZone.Warehouse.red.Didi, cargoZone.Warehouse.red.Kvemo_Sba, cargoZone.Warehouse.red.Alagir }
            local target = targets[ math.random( 1 , #targets ) ]
            local home = warehouse.Kvitiri_Helo

            logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home.alias .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

            -- addGroupSet(detectionGroupSetBlue, groupset)

            activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )






          elseif request.assignment == "TRANSFER MECHANIZED SELFPROPELLED" then

              logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - tblisi scheduled mission number - request.assignment: ' .. request.assignment .. '  - ASSET DELIVERD: ACQUISITO DALLA WAREHOUSE DI DESTINAZIONE' })


          else

              logging('warning', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

          end -- end if ...elseif

        end  --end  function warehouse.Kobuleti:OnAfterSelfRequest(From, Event, To, groupset, request)


        --- quando ritorna alla base viene 'riassorbito' e quindi viene lanciato questo evento. Utilizzato per rilanciare la missione dopo un RTB
        -- puo' non servire se le missioni sono schedulate
        function warehouse.Kvitiri_Helo:OnAfterDelivered(From,Event,To,request)

              -- le diverse opzioni disponibili per la scelta casuale della missione
              local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

              logging('info', { 'warehouse.Kvitiri_Helo:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })
              -- manca il groupset
              -- So we start another request.
              --[[
              if request.assignment=="PATROL" then

                  logging('info', { 'warehouse.Kvitiri_Helo:OnAfterDelivered(From,Event,To,request)' , 'vaziani scheduled PATROL mission'})
                  activeCAPWarehouse(groupset, redFrontZone.BAI_Zone_Kvitiri_Helo[2], 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

              end

              if request.assignment=="BAI TARGET" then

                logging('info', { 'warehouse.Kvitiri_Helo:OnAfterDelivered(From,Event,To,request)' , 'vaziani scheduled BAI TARGET mission'})
                activeBAIWarehouseT('Interdiction from Kvitiri_Helo', groupset, 'target', redFrontZone.BAI_Zone_Kvitiri_Helo[2], redFrontZone.BAI_Zone_Kvitiri_Helo[2], 400, 1000, 4, 2, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

              end -- end if

              ]]

        end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)


    end -- end wh_activation.Warehouse_AB.blue.Kvitiri_Helo then
    ------------------------------------------------- END blue Warehouse KVITIRI_HELO operations -------------------------------------------------------------------------------------------------------------------------


















    ------------------------------------------------------------ blue Warehouse TBILISI operations ----------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse_AB.blue.Tbilisi[1] then -- true activate tbilisi wh operations

      -- Nota: Tipo Operazioni Bomber, Transport, AWACS


      logging('info', { 'main' , 'init Warehouse TBILISI operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa

      -- INITIALIZE WAREHOUSE.


      -- START WAREHOUSE
      warehouse.Tbilisi:Start()

      logging('info', { 'main' , 'addAsset Tbilisi warehouse'} )
      -- ADD ASSET
      -- Tbilisi e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
      -- Tbilisi - Gori
      -- Tbilisi e' utilizzato come aeroporto internazionale civile e non e' attaccato dalla forze sovietiche. Da Tbilisi decollano voli per trasporto merci e missioni di pinpoint strike e BAI.
      -- non decollano elicotteri



       warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]    ) -- Fighter
       warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]    ) -- Fighter
       warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_AJS_37,               10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]    ) -- Fighter
       warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,          10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber CAS
       warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_5E_3_Rocket,        10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber CAS
       warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_5E_3_Cluster,       10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber CAS
       warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_AJS_37,               10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber CAS
       warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_AN_26,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]   ) -- Transport
       warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_C_130,               10,         WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,               9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]    ) -- Transport
       warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_CH_47,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]   ) -- Transport
       warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           15,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber
       warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_B_52H,                10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.bomber[1], AssetSkill.blue.bomber[2])]   ) -- Bomber
       warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Structure,      10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber
       warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Heavy,   10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber
       warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Light,   10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber
       warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Cluster, 10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Bomber
       warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_B_1B,                 10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.bomber[1], AssetSkill.blue.bomber[2])]   ) -- Bomber
       warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_AJS_37,               10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.bomber[1], AssetSkill.blue.bomber[2])]   ) -- Bomber
       warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_MI_24V,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]    ) -- Heli CAS
       warehouse.Tbilisi:AddAsset(               air_template_blue.AWACS_B_1B,               10,           WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.awacs[1], AssetSkill.blue.awacs[2])]   ) -- AWACS
       warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_L_39ZA,              10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])]   ) -- AFAC
       warehouse.Tbilisi:AddAsset(               air_template_blue.REC_L_39ZA,               10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])]   ) -- AFAC EXPERIMENTAL PROTOTYPE
       warehouse.Tbilisi:AddAsset(               air_template_blue.REC_F_4,                  10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])]   ) -- AFAC EXPERIMENTAL PROTOTYPE
       warehouse.Tbilisi:AddAsset(               air_template_blue.AWACS_F_4,                10,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.afac[1], AssetSkill.blue.afac[2])]   ) -- AWACS
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedA,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]      ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedB,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]      ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedC,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]      ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArmorA,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArmorB,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.artillery[1], AssetSkill.blue.artillery[2])]    ) -- Ground troops
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TransportA,      12,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]   ) -- Transport
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TransportB,      10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]   ) -- Transport
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TroopTransport,  10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]   ) -- Transport
       warehouse.Tbilisi:AddAsset(               ground_group_template_blue.Truck,           10,           WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]   ) -- Transport






      -- blue Tbilisi warehouse operations

      logging('info', { 'main' , 'addrequest Tbilisi warehouse'} )

      local tblisi_efficiency_influence = math.random(10, 20) * 0.1  -- Influence start_sched (from 1 to inf)
      local num_mission = 6
      local depart_time = defineRequestPosition( num_mission )
      local pos = 1
      local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
      local offSetStartSchedule = 0 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
      local requestStartTime = startReqTimeAir + offSetStartSchedule

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local tblisi_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Tbilisi[ 1 ],

        function()



           -- Priority Mission Request
           if wh_activation.Warehouse_AB.blue.Tbilisi[9] then warehouse.Tbilisi:__AddRequest( startReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AWACS_F_4, 1, nil, nil, nil, "AWACS")  end
           -- Normal Mission Request
           if wh_activation.Warehouse_AB.blue.Tbilisi[8] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Cluster, math.random( AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2] ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
           if wh_activation.Warehouse_AB.blue.Tbilisi[8] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
           if wh_activation.Warehouse_AB.blue.Tbilisi[5] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_AJS_37, math.random( AssetQty.blue.air.patrol[1], AssetQty.blue.air.patrol[2] ), nil, nil, nil, "PATROL") pos = pos + 1  end
           if wh_activation.Warehouse_AB.blue.Tbilisi[7] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_AJS_37, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
           if wh_activation.Warehouse_AB.blue.Tbilisi[7] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
           if wh_activation.Warehouse_AB.blue.Tbilisi[7] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_AJS_37, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
           --if wh_activation.Warehouse_AB.blue.Tbilisi[11] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, math.random( AssetQty.blue.air.transport[1], AssetQty.blue.air.transport[2] ), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
           --if wh_activation.Warehouse_AB.blue.Tbilisi[11] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_C_130, math.random( AssetQty.blue.air.transport[1], AssetQty.blue.air.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY AIRBASE") pos = pos + 1  end
           --if wh_activation.Warehouse_AB.blue.Tbilisi[11] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Zestafoni, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
           --if wh_activation.Warehouse_AB.blue.Tbilisi[11] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT CRATE FARP") pos = pos + 1  end
           --if wh_activation.Warehouse_AB.blue.Tbilisi[11] and pos <= num_mission then warehouse.Tbilisi:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_C_130, math.random( AssetQty.blue.air.transport[1], AssetQty.blue.air.transport[2] ), nil, nil, nil, "DISPATCHING AIRBASE TRANSPORT") pos = pos + 1  end


           logging('info', { 'main' , 'Tblisi scheduler - start time:' .. start_sched * tblisi_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * ( 1 - rand_sched ) .. ' - ' .. sched_interval * ( 1 + rand_sched ) } )

       end, {}, start_sched * tblisi_efficiency_influence, sched_interval, rand_sched

      ) -- end  tblisi_sched = SCHEDULER:New( nil, ..)



      -- Do something with the spawned aircraft.
      function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)



        logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })



        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        if request.assignment == "BAI TARGET" then

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
          local percRequestKill = math.random( 0 , 100 ) * 0.01
          local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ][ 1 ]
          local patrolZone = bluePatrolZone.tbilisi[1]
          local engageZone = redFrontZone.TSKHINVALI[1]

          for _, v in pairs(redFrontZone) do

            if math.random(1,10) < 5 then

              engageZone = v[1]
              break

            end -- end if

          end -- end for


          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Tbilisi', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )



        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        elseif request.assignment == "BAI STRUCTURE" then

          --[[
          local avalaible_target_zones = {

              zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
              zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
              zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

          }
          ]]

          local engageZone = specific_target.red.zone_targ[ math.random(1, #specific_target.red.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
          local patrolZone = bluePatrolZone.tbilisi[1]

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

          activeBAI( 'Interdiction from Tbilisi against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )






        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset

      elseif request.assignment == "AWACS" then

          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - awacsZone: ' .. blueAwacsZone.tbilisi:GetName() } )

          activeAWACS( groupset, warehouse.Tbilisi, blue_command_center, nil, blueAwacsZone.tbilisi, math.random(5000, 9000), 5000 )






        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset

        elseif request.assignment == "PATROL" then

          local homeAirbase =  AIRBASE.Caucasus.Tbilisi_Lochini
          local patrolZone =  bluePatrolZone.tbilisi[1]
          local engageRange = math.random(10000, 20000)
          local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
          local patrolFloorAltitude = 4000
          local patrolCeilAltitude = 9000
          local minSpeedPatrol = 400
          local maxSpeedPatrol = 600
          local minSpeedEngage = 600
          local maxSpeedEngage = 1000

          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

          activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )




        ------------------------------------------------------------------------------------------------------ assignment for PATROL PATROL WITH ENGAGE ZONE (NON ATTIVO: NON INSERITO NELLE ADDREQUEST)
        elseif request.assignment == "PATROL WITH ENGAGE ZONE" then

          local homeAirbase =  AIRBASE.Caucasus.Tbilisi_Lochini
          local engageZone = redFrontZone.TSKHINVALI[1]

          for _, v in pairs(redFrontZone) do

            if math.random(1,10) < 5 then

              engageZone = v[1]
              break

            end -- end if

          end -- end for


          local patrolZone =  bluePatrolZone.tbilisi[1]
          local engageRange = math.random(10000, 20000)
          local patrolFloorAltitude = 4000
          local patrolCeilAltitude = 9000
          local minSpeedPatrol = 400
          local maxSpeedPatrol = 600
          local minSpeedEngage = 600
          local maxSpeedEngage = 1000


          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

          activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )




        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
        elseif request.assignment == "BOMBING AIRBASE" then

            -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Tbilisi
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            local target = warehouse_red.airbase[ math.random( 1, #warehouse_red.airbase ) ]

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
        elseif request.assignment == "BOMBING WAREHOUSE" then

            -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Tbilisi
            local target = warehouse_red.farp[ math.random( 1, #warehouse_red.farp ) ]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )




          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING MIL ZONE" then

            -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Tbilisi
            local target = zoneTargetStructure.Red_Military_Base[ math.random( 1, #zoneTargetStructure.Red_Military_Base ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






        ------------------------------------------------------------------------------------------------------ assignment for TRANSPORT asset
        elseif request.assignment == "TRANSPORT VEHICLE AIRBASE" then



            --local cargoGroupSet = SET_CARGO:New():FilterTypes( 'Vehicles' ):FilterStart()


            --local destination = AIRBASE.Caucasus.Kutaisi --airbase_blue[ math.random( 1 , #airbase_blue ) ]
            --local speed = math.random( 300 , 500 )

            --logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )
            --activeCargoAirPlane( groupset, AIRBASE.Caucasus.Kutaisi, AIRBASE.Caucasus.Tbilisi_Lochini, speed, cargoGroupSet )








        ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
        elseif request.assignment == "TRANSPORT INFANTRY AIRBASE" then



          --local cargoGroupSet = SET_CARGO:New():FilterTypes( 'Infantry' ):FilterStart()


          --local destination = AIRBASE.Caucasus.Kutaisi --airbase_blue[ math.random( 1 , #airbase_blue ) ]
          --local speed = math.random( 300 , 500 )

          --logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )
          --activeCargoAirPlane( groupset, AIRBASE.Caucasus.Kutaisi, AIRBASE.Caucasus.Tbilisi_Lochini, speed, cargoGroupSet )









          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
          elseif request.assignment == "TRANSPORT INFANTRY FARP" then



            --local cargoGroupSet = SET_CARGO:New():FilterTypes( 'Infantry' ):FilterStart()


            --local pickupZone =  cargoZone.Warehouse_AB.blue.Tbilisi
            --local deployZone =  cargoZone.Warehouse.blue.Gori
            --local speed = math.random( 100 , 250 )

            --logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )
            --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )



        ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
        elseif request.assignment == "TRANSPORT CRATE FARP" then


              --local cargoGroupSet = SET_CARGO:New():FilterTypes( 'Workmaterials' ):FilterStart()


              --local pickupZone =  cargoZone.Warehouse_AB.blue.Tbilisi
              --local deployZone =  cargoZone.Warehouse.blue.Gori
              --local speed = math.random( 100 , 250 )

              --logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )
              --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )






      ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "DISPATCHING AIRBASE TRANSPORT" then



            local cargoGroupSet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
            local AirplanesSet = groupset

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() } )

            local PickupZoneSet = SET_ZONE:New()
            local DeployZoneSet = SET_ZONE:New()

            PickupZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Tbilisi_Lochini ) )
            DeployZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Kutaisi ) )
            DeployZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Batumi ) )

            AICargoDispatcherAirplanes = AI_CARGO_DISPATCHER_AIRPLANE:New( AirplanesSet, cargoGroupSet, PickupZoneSet, DeployZoneSet )

            AICargoDispatcherAirplanes.SetPickupRadius(1000, 30)--: Sets or randomizes the pickup location for the carrier around the cargo coordinate in a radius defined an outer and optional inner radius.
            AICargoDispatcherAirplanes.SetPickupSpeed(600, 350)--: Set the speed or randomizes the speed in km/h to pickup the cargo.
            AICargoDispatcherAirplanes.SetPickupHeight(9000, 3000)--: Set the height or randomizes the height in meters to pickup the cargo.
            AICargoDispatcherAirplanes.SetDeployRadius(1000, 30)--: Sets or randomizes the deploy location for the carrier around the cargo coordinate in a radius defined an outer and an optional inner radius.
            AICargoDispatcherAirplanes.SetDeploySpeed(400, 300)--: Set the speed or randomizes the speed in km/h to deploy the cargo.
            AICargoDispatcherAirplanes.SetDeployHeight(7000, 4000)--: Set the height or randomizes the height in meters to deploy the cargo.
            AICargoDispatcherAirplanes.SetHomeZone(AIRBASE.Caucasus.Tbilisi_Lochini)


            AICargoDispatcherAirplanes:Start()

            function AICargoDispatcherAirplanes:OnAfterLoaded( From, Event, To, CarrierGroup, Cargo, CarrierUnit, PickupZone )

               logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterLoaded ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterPickedUp( From, Event, To, CarrierGroup, PickupZone )

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterPickedUp ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end


            function AICargoDispatcherAirplanes:OnAfterDeploy( From, Event, To, CarrierGroup, Coordinate, Speed, Height, DeployZone )

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterDeploy ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterUnload( From, Event, To, CarrierGroup, DeployZone )

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterUnload ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterUnload( From, Event, To, CarrierGroup, Cargo, CarrierUnit, DeployZone )

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterUnload ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterUnloaded( From, Event, To, CarrierGroup, Cargo, CarrierUnit, DeployZone )

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterUnloaded ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            function AICargoDispatcherAirplanes:OnAfterDeployed( From, Event, To, CarrierGroup, DeployZone )

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request):    **** OnAfterDeployed ****  ' , 'groupset name: ' .. CarrierGroup:GetObjectNames() .. ' - cargoGroupSet: ' .. Cargo:GetObjectNames() .. ' - cargo.count: ' .. Cargo:Count() .. ' - CarrierUnit: ' .. CarrierUnit:GetName() .. ' - PickupZone: ' .. PickupZone:GetName() } )

            end

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )







        ------------------------------------------------------------------------------------------------------ assignment for RECON asset
      elseif request.assignment == "RECON FARP" then

            local toTargetAltitude = math.random(7000, 9000)
            local toHomeAltitude = math.random(3000, 5000)
            local reconDirection = math.random(270, 359)
            local reconAltitude = math.random(5000, 7000)
            local reconRunDistance = 20000
            local reconRunDirection = math.random(270, 359)
            local speedReconRun = math.random(400, 600)
            local targets = { cargoZone.Warehouse.red.Biteta, cargoZone.Warehouse.red.Didi, cargoZone.Warehouse.red.Kvemo_Sba, cargoZone.Warehouse.red.Alagir }
            local target = targets[ math.random( 1 , #targets ) ]
            local home = warehouse.warehouse.Tbilisi

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home.alias .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

            -- addGroupSet(detectionGroupSetBlue, groupset)

            activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )




        ------------------------------------------------------------------------------------------------------ assignment for RECON asset
        elseif request.assignment == "TRANSFER MECHANIZED SELFPROPELLED" then


            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - tblisi scheduled mission number - request.assignment: ' .. request.assignment .. '  - ASSET DELIVERD: ACQUISITO DALLA WAREHOUSE DI DESTINAZIONE' })


        else

          logging('warning', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

        end



      end  --end  function warehouse.Tbilisi:OnAfterSelfRequest(From, Event, To, groupset, request)




        --- When the helo is out of fuel, it will return to the carrier and should be delivered.
       -- DA ELIMINARE: LA RIPETIZIONE DELLA MISSIONE E' ESEGUITA DALLO SCHEDULER
      function warehouse.Tbilisi:OnAfterDelivered(From,Event,To,request)

        -- le diverse opzioni disponibili per la scelta casuale della missione
        local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        logging('info', { 'warehouse.Tbilisi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled mission number - request.assignment: ' .. request.assignment })

        -- manca il groupset
        -- So we start another request.
        --if request.assignment=="PATROL" then

          --local pos = math.random( 1 , #param )

          --logging('info', { 'warehouse.Tbilisi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled PATROL mission number:  - pos: ' .. pos .. ' - groupset name: ' .. groupset:GetObjectNames()} )
          --activeCAPWarehouse(groupset, redFrontZone.BAI_Zone_Tbilisi[2], 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )
          -- warehouse.Batumi:AddRequest(warehouse.Pampa, WAREHOUSE.Descriptor.ATTRIBUTE, request.cargoattribute, request.ndelivered, WAREHOUSE.TransportType.APC, WAREHOUSE.Quantity.ALL)

        --end

        --if request.assignment=="BAI STRUCTURE" then

          --logging('info', { 'warehouse.Tbilisi:OnAfterDelivered(From,Event,To,request)' , 'tblisi scheduled BAI STRUCTURE mission number:  - pos: ' .. pos .. ' - groupset name: ' .. groupset:GetObjectNames()} )
          --activeBAIWarehouseT('Interdiction from Tbilisi', groupset, 'target', redFrontZone.BAI_Zone_Tbilisi[2], redFrontZone.BAI_Zone_Tbilisi[2], 400, 1000, 4, 2, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

        --end -- end if

      end -- end warehouse.Tbilisi:OnAfterDelivered(From,Event,To,request)

    end -- end if tbilisi_wh_activation
    ------------------------------------------------------------ END blue Warehouse TBILISI operations ----------------------------------------------------------------------------------------------------------------------------





































































    ------------------------------------------------------------ blue Warehouse Vaziani operations ----------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse_AB.blue.Vaziani[1] then

        logging('info', { 'main' , 'init Warehouse VAZIANI operations' } )


        warehouse.Vaziani:Start()

        -- Vaziani e' un aeroporto vicino Tbilisi dove sono gestiti le risorse aeree fighter, reco, cas transport

        warehouse.Vaziani:AddAsset(              air_template_blue.GCI_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  )
        warehouse.Vaziani:AddAsset(              air_template_blue.CAP_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  )
        warehouse.Vaziani:AddAsset(              air_template_blue.CAP_L_39ZA,               10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  )
        warehouse.Vaziani:AddAsset(              air_template_blue.CAS_Su_17M4_Rocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Bomber BAI
        warehouse.Vaziani:AddAsset(              air_template_blue.CAS_Su_17M4_Bomb,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Bomber BAI
        warehouse.Vaziani:AddAsset(              air_template_blue.CAS_Su_17M4_Cluster,      10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Bomber BAI
        warehouse.Vaziani:AddAsset(              air_template_blue.CAS_L_39C_Rocket,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Bomber BAI
        warehouse.Vaziani:AddAsset(              air_template_blue.GA_A_10A_Bomb,            10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Bomber BAI
        warehouse.Vaziani:AddAsset(              air_template_blue.CAS_MI_24V,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]   ) -- Heli CAS
        warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_UH_1H,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  ) -- Transport
        warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_UH_60A,              10,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]    ) -- Transport
        warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_CH_47,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]   ) -- Transport
        warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_AN_26,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  )
        warehouse.Vaziani:AddAsset(              air_template_blue.AFAC_L_39ZA,              10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Bomber BAI
        warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]    ) -- Ground troops
        warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]    ) -- Ground troops
        warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]    ) -- Ground troops
        warehouse.Vaziani:AddAsset(              ground_group_template_blue.TransportA,      10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]   ) -- Transport
        warehouse.Vaziani:AddAsset(              ground_group_template_blue.TransportB,      10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]   ) -- Transport
        warehouse.Vaziani:AddAsset(              ground_group_template_blue.TroopTransport,  10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]    )-- Transport

        logging('info', { 'main' , 'addAsset Vaziani warehouse'} )



        -- blue Vaziani warehouse operations

        logging('info', { 'main' , 'addrequest Vaziani warehouse'} )


        local vaziani_efficiency_influence = math.random(10, 20) * 0.1
        local num_mission = 8
        local depart_time = defineRequestPosition( num_mission )
        local pos = 1
        local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
        local offSetStartSchedule = 300 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
        local requestStartTime = startReqTimeAir + offSetStartSchedule

        local vaziani_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Vaziani[ 1 ],

            function()



                if wh_activation.Warehouse_AB.blue.Vaziani[15] and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_L_39ZA, 1, nil, nil, nil, "AFAC_afacZone.Didmukha_Tsveri")  end -- AFAC, ...
                if wh_activation.Warehouse_AB.blue.Vaziani[8] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_MI_24V, math.random( AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2] ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
                if wh_activation.Warehouse_AB.blue.Vaziani[8] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_SU_24_Bomb, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
                if wh_activation.Warehouse_AB.blue.Vaziani[5] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_L_39ZA, math.random( AssetQty.blue.air.patrol[1], AssetQty.blue.air.patrol[2] ), nil, nil, nil, "PATROL") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Vaziani[5] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_Mig_21Bis, math.random( AssetQty.blue.air.patrol[1], AssetQty.blue.air.patrol[2] ), nil, nil, nil, "PATROL WITH ENGAGE ZONE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Vaziani[7] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Cluster, math.random( AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Vaziani[7] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Bomb, math.random( AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Vaziani[7] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
                if wh_activation.Warehouse_AB.blue.Vaziani[7] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE BITETA") pos = pos + 1  end
                --if wh_activation.Warehouse_AB.blue.Vaziani[11] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, math.random( AssetQty.blue.air.transport[1], AssetQty.blue.air.transport[2] ), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
                --if wh_activation.Warehouse_AB.blue.Vaziani[11] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Khashuri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( AssetQty.blue.heli.transport[1], AssetQty.blue.heli.transport[2] ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
                --if wh_activation.Warehouse_AB.blue.Vaziani[14] and pos <= num_mission then warehouse.Vaziani:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, math.random( AssetQty.blue.ground.transport[1], AssetQty.blue.ground.transport[2] ), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end

                logging('info', { 'main' , 'Vaziani scheduler - start time:' .. start_sched *  vaziani_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * ( 1 - rand_sched ) .. ' - ' .. sched_interval * ( 1 + rand_sched ) } )

            end, {}, start_sched * vaziani_efficiency_influence, sched_interval, rand_sched

        ) -- end  vaziani_sched = SCHEDULER:New( nil, ..)







        -- Do something with the spawned aircraft.
        function warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)

          logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' ,  ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })


          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "AFAC_afacZone.Didmukha_Tsveri" then

            local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Vaziani )

            assignDetectionGroupSetTask(groupset, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )


          elseif request.assignment == "BAI TARGET" then


            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')


            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local  percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ][ 1 ]
            local patrolZone = bluePatrolZone.tbilisi[1]
            local engageZone = redFrontZone.TSKHINVALI[1]

            for _, v in pairs(redFrontZone) do

              if math.random(1,10) < 5 then

                engageZone = v[1]
                break

              end -- end if

            end -- end for


            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Vaziani', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )



          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          elseif request.assignment == "BAI STRUCTURE" then

            --[[
            local avalaible_target_zones = {

                zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

            }
            ]]

            local engageZone = specific_target.red.zone_targ[ math.random(1, #specific_target.red.zone_targ) ] --avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
            local patrolZone = bluePatrolZone.vaziani[1]


            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Vaziani against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )





          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
          elseif request.assignment == "PATROL" then

              -- groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage
              local homeAirbase =  AIRBASE.Caucasus.Vaziani
              local patrolZone =  bluePatrolZone.vaziani[1] --bluePatrolZone[ math.random( 1, #bluePatrolZone ) ]
              local engageRange = math.random(10000, 20000)
              local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
              local patrolFloorAltitude = 4000
              local patrolCeilAltitude = 9000
              local minSpeedPatrol = 400
              local maxSpeedPatrol = 600
              local minSpeedEngage = 600
              local maxSpeedEngage = 1000

              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

              activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase)




          ------------------------------------------------------------------------------------------------------ assignment for PATROL MIG 21 asset
          elseif request.assignment == "PATROL WITH ENGAGE ZONE" then

            local homeAirbase =  AIRBASE.Caucasus.Vaziani
            local engageZone = redFrontZone.TSKHINVALI[1]

            for _, v in pairs(redFrontZone) do

              if math.random(1,10) < 5 then

                engageZone = v[1]
                break

              end -- end if

            end -- end for

            local patrolZone =  bluePatrolZone.vaziani[1] --bluePatrolZone[ math.random( 1, #bluePatrolZone ) ]
            local engageRange = math.random(10000, 20000)
            local patrolFloorAltitude = 4000
            local patrolCeilAltitude = 9000
            local minSpeedPatrol = 400
            local maxSpeedPatrol = 600
            local minSpeedEngage = 600
            local maxSpeedEngage = 1000

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

            activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase )





          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING AIRBASE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Vaziani
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            local target = warehouse_red.airbase[ math.random( 1, #warehouse_red.airbase ) ]

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING WAREHOUSE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Vaziani
            local target = warehouse_red.farp[ math.random( 1, #warehouse_red.farp ) ]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING MIL ZONE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Vaziani
            local target = zoneTargetStructure.Red_Military_Base[ math.random( 1, #zoneTargetStructure.Red_Military_Base ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING STRUCTURE BITETA" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Vaziani
            local target = zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )




          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
          elseif request.assignment == "TRANSPORT VEHICLE AIRBASE" then



              --local destination = airbase_blue[ math.random( 1 , #airbase_blue ) ]

              --local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles", 5000, nil)


              --local speed = math.random( 300 , 500 )

              --logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )

              --activeCargoAirPlane( groupset, AIRBASE.Caucasus.Vaziani, destination, speed, cargoGroupSet )





          ----------------------------------------------------------------------------------------------------- assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY FARP" then



              --local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Vaziani", 5000, nil)


              --local pickupZone =  cargoZone.Warehouse_AB.blue.Vaziani
              --local deployZone =  cargoZone.Warehouse.blue.Khashuri
              --local speed = math.random( 100 , 250 )

              --logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

              --activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )




          ------------------------------------------------------------------------------------------------------ assignment for RECON asset
          elseif request.assignment == "RECON AIRBASE" then

            local toTargetAltitude = math.random(7000, 9000)
            local toHomeAltitude = math.random(3000, 5000)
            local reconDirection = math.random(270, 359)
            local reconAltitude = math.random(5000, 7000)
            local reconRunDistance = 20000
            local reconRunDirection = math.random(270, 359)
            local speedReconRun = math.random(400, 600)
            local targets = { cargoZone.Warehouse_AB.red.Mozdok, cargoZone.Warehouse_AB.red.Mineralnye, cargoZone.Warehouse_AB.red.Beslan, cargoZone.Warehouse_AB.red.Nalchik }
            local target = targets[ math.random( 1 , #targets ) ]
            local home = warehouse.Vaziani

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home.alias .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

            -- addGroupSet(detectionGroupSetBlue, groupset)

            activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )





          ------------------------------------------------------------------------------------------------------ assignment for ground transport
          elseif request.assignment == "TRANSFER MECHANIZED SELFPROPELLED" then

              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - tblisi scheduled mission number - request.assignment: ' .. request.assignment .. '  - ASSET DELIVERD: ACQUISITO DALLA WAREHOUSE DI DESTINAZIONE' })

          else

              logging('warning', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

          end -- end if ..elseif

        end  --end  function warehouse.Kobuleti:OnAfterSelfRequest(From, Event, To, groupset, request)

        --- quando ritorna alla base viene 'riassorbito' e quindi viene lanciato questo evento. Utilizzato per rilanciare la missione dopo un RTB
        -- puo' non servire se le missioni sono schedulate
        function warehouse.Vaziani:OnAfterDelivered(From,Event,To,request)

              -- le diverse opzioni disponibili per la scelta casuale della missione
              local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

              logging('info', { 'warehouse.Vaziani:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })

              if request.assignment=="AFAC_afacZone.Didmukha_Tsveri" then

                  logging('info', { 'warehouse.Vaziani:OnAfterDelivered(From,Event,To,request)' , 'vaziani scheduled AFAC_afacZone.Didmukha_Tsveri'})
                  warehouse.Vaziani:__AddRequest( startReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_L_39ZA, 1, nil, nil, nil, "AFAC_afacZone.Didmukha_Tsveri")

              end

        end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)

        function warehouse.Vaziani:OnAfterDead(From,Event,To,request)

              -- le diverse opzioni disponibili per la scelta casuale della missione
              local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

              logging('info', { 'warehouse.Vaziani:OnAfterDead(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })

              if request.assignment=="AFAC_afacZone.Didmukha_Tsveri" then

                  logging('info', { 'warehouse.Vaziani:OnAfterDelivered(From,Event,To,request)' , 'vaziani scheduled AFAC_afacZone.Didmukha_Tsveri'})
                  warehouse.Vaziani:__AddRequest( startReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_L_39ZA, 1, nil, nil, nil, "AFAC_afacZone.Didmukha_Tsveri")

              end

        end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)


    end --end wh_activation.Warehouse_AB.blue.Vaziani
    ------------------------------------------------------------ END blue Warehouse Vaziani operations ----------------------------------------------------------------------------------------------------------------------------































































    -------------------------------------------------------------- blue Warehouse Soganlug operations ----------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse_AB.blue.Soganlug[1] then



        warehouse.Soganlug:Start()


        -- Soganlug e' un aeroporto vicino Tbilisi dove sono gestiti le risorse aeree fighter, reco, cas, transport


        warehouse.Soganlug:AddAsset(              air_template_blue.GCI_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])] )
        warehouse.Soganlug:AddAsset(              air_template_blue.GCI_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])] )
        warehouse.Soganlug:AddAsset(              air_template_blue.GCI_AJS_37,               10,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])] )
        warehouse.Soganlug:AddAsset(              air_template_blue.CAP_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])]  ) -- Fighter
        warehouse.Soganlug:AddAsset(              air_template_blue.CAP_AJS_37,               10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter[1], AssetSkill.blue.fighter[2])] )
        warehouse.Soganlug:AddAsset(              air_template_blue.CAS_F_4E_Rocket,          10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber BAI
        warehouse.Soganlug:AddAsset(              air_template_blue.CAS_L_39C_Rocket,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber BAI
        warehouse.Soganlug:AddAsset(              air_template_blue.CAS_L_39ZA_HRocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber BAI
        warehouse.Soganlug:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber CAS
        warehouse.Soganlug:AddAsset(               air_template_blue.CAS_F_5E_3_Rocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber CAS
        warehouse.Soganlug:AddAsset(               air_template_blue.CAS_F_5E_3_Cluster,      10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber CAS
        warehouse.Soganlug:AddAsset(               air_template_blue.CAS_AJS_37,              10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber CAS
        warehouse.Soganlug:AddAsset(               air_template_blue.CAS_A_10A_Rocket,        10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber CAS
        warehouse.Soganlug:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Heavy,   10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber
        warehouse.Soganlug:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Light,   10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber
        warehouse.Soganlug:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Cluster, 10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber
        warehouse.Soganlug:AddAsset(               air_template_blue.BOM_AJS_37,               10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])] ) -- Bomber
        warehouse.Soganlug:AddAsset(              air_template_blue.CAS_UH_1H,                10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Heli CAS
        warehouse.Soganlug:AddAsset(              air_template_blue.CAS_UH_60A,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.fighter_bomber[1], AssetSkill.blue.fighter_bomber[2])]  ) -- Heli CAS
        warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_AN_26,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] )
        warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_UH_1H,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_UH_60A,              10,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])]  ) -- Transport
        warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_CH_47,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_C_130,               10,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,              9000, nil, nil, AI.Skill[ math.random(AssetSkill.blue.transport[1], AssetSkill.blue.transport[2])] ) -- Transport
        warehouse.Soganlug:AddAsset(              ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
        warehouse.Soganlug:AddAsset(              ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
        warehouse.Soganlug:AddAsset(              ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.tank[1], AssetSkill.blue.tank[2])]  ) -- Ground troops
        warehouse.Soganlug:AddAsset(              ground_group_template_blue.TransportA,      10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
        warehouse.Soganlug:AddAsset(              ground_group_template_blue.TransportB,      10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])] ) -- Transport
        warehouse.Soganlug:AddAsset(              ground_group_template_blue.TroopTransport,  10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(AssetSkill.blue.ground[1], AssetSkill.blue.ground[2])]  )-- Transport

        logging('info', { 'main' , 'addAsset Soganlug warehouse'} )


        -- Nota: Tipo Operazioni CAP, GCI, CAS, SEAD, RECO, AWACS, Transport


        logging('info', { 'main' , 'init Warehouse Soganlug operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa

        -- Red targets at Soganlug X (late activated). for test
        local RedTargets=GROUP:FindByName("Russian Antitank Defence@Sathiari")


        -- blue Soganlug warehouse operations

        logging('info', { 'main' , 'addrequest Soganlug warehouse'} )


        local depart_time = defineRequestPosition(9) -- list of position

        local soganlug_efficiency_influence = math.random(10, 20) * 0.1 -- Influence start_sched (from 1 to inf)
        local num_mission = 8
        local depart_time = defineRequestPosition( num_mission )
        local pos = 1
        local sched_interval =   num_mission * waitReqTimeAir / activeAirRequestRatio
        local offSetStartSchedule = 0 -- offSet per il ritardo di attivazione delle request. Serve per dare la precedenza a request prioritarie
        local requestStartTime = startReqTimeAir + offSetStartSchedule

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local soganlug_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Soganlug[ 1 ],

          function()



            if wh_activation.Warehouse_AB.blue.Soganlug[8] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket,  math.random( AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2] ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
            if wh_activation.Warehouse_AB.blue.Soganlug[8] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Cluster,  math.random( AssetQty.blue.air.cas[1], AssetQty.blue.air.cas[2] ), nil, nil, nil, "BAI TARGET BIS") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
            if wh_activation.Warehouse_AB.blue.Soganlug[5] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_AJS_37, math.random( AssetQty.blue.air.patrol[1], AssetQty.blue.air.patrol[2] ), nil, nil, nil, "PATROL") pos = pos + 1  end
            if wh_activation.Warehouse_AB.blue.Soganlug[7] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_AJS_37, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
            if wh_activation.Warehouse_AB.blue.Soganlug[7] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
            if wh_activation.Warehouse_AB.blue.Soganlug[7] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_AJS_37, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE KUTAISI") pos = pos + 1  end
            if wh_activation.Warehouse_AB.blue.Soganlug[7] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Heavy, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE DIDI") pos = pos + 1  end
            if wh_activation.Warehouse_AB.blue.Soganlug[7] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Heavy, math.random( AssetQty.blue.air.bomb[1], AssetQty.blue.air.bomb[2] ), nil, nil, nil, "BOMBING STRUCTURE KVEMO_SBA") pos = pos + 1  end
            --if wh_activation.Warehouse_AB.blue.Soganlug[5] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_4, 2, nil, nil, nil, "PATROL F4") pos = pos + 1  end
          --  if wh_activation.Warehouse_AB.blue.Soganlug[11] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, 2, nil, nil, nil, "TRANSFER MIG 21") pos = pos + 1  end
          --  if wh_activation.Warehouse_AB.blue.Soganlug[11] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, 2, nil, nil, nil, "TRANSPORT") pos = pos + 1  end
          --  if wh_activation.Warehouse_AB.blue.Soganlug[11] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_UH_60A, 2, nil, nil, nil, "TRANSPORT 2") pos = pos + 1  end
          --  if wh_activation.Warehouse_AB.blue.Soganlug[14] and pos <= num_mission then warehouse.Soganlug:__AddRequest( requestStartTime + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, 2, nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
            logging('info', { 'main' , 'Soganlug scheduler - start time:' .. start_sched *  soganlug_efficiency_influence .. ' ; scheduling time: ' .. sched_interval * ( 1 - rand_sched ) .. ' - ' .. sched_interval * ( 1 + rand_sched ) } )

        end, {}, start_sched * soganlug_efficiency_influence, sched_interval, rand_sched

        )




        -- Do something with the spawned aircraft.
        function warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)


          logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })


          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TARGET" then


            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ][ 1 ]
            local patrolZone = bluePatrolZone.soganlug[1]
            local engageZone = redFrontZone.DIDI_CUPTA[1]

            for _, v in pairs(redFrontZone) do

              if math.random(1,10) < 5 then

                engageZone = v[1]
                break

              end -- end if

            end -- end for


            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Soganlug', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )




          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          elseif request.assignment == "BAI TARGET BIS" then

              speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

              -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
              local percRequestKill = math.random( 0 , 100 ) * 0.01
              local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ][ 1 ]
              local patrolZone = bluePatrolZone.soganlug[1]
              local engageZone = redFrontZone.SATIHARI[1]

              for _, v in pairs(redFrontZone) do

                if math.random(1,10) < 5 then

                  engageZone = v[1]
                  break

                end -- end if

              end -- end for


              logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName()  .. ' - percRequestKill: ' .. percRequestKill .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - targetZone: ' .. engageZone:GetName() } )
              logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

              activeBAI( 'Interdiction from Soganlug', groupset, 'target', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, target, percRequestKill, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )






          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
          elseif request.assignment == "PATROL" then

            -- groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage
            local homeAirbase =  AIRBASE.Caucasus.Soganlug
            local patrolZone =  bluePatrolZone.soganlug[1] --bluePatrolZone[ math.random( 1, #bluePatrolZone ) ]
            local engageRange = math.random(10000, 20000)
            local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
            local patrolFloorAltitude = 4000
            local patrolCeilAltitude = 9000
            local minSpeedPatrol = 400
            local maxSpeedPatrol = 600
            local minSpeedEngage = 600
            local maxSpeedEngage = 1000

            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageRange: ' .. engageRange .. ' - engageZone: ' .. engageZone:GetName()} )
            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

            activePATROL(groupset, patrolZone, engageRange, engageZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage, homeAirbase)







        ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING AIRBASE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Soganlug
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            local target = warehouse_red.airbase[ math.random( 1, #warehouse_red.airbase ) ]

            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING WAREHOUSE" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Soganlug
            local target = warehouse_red.farp[ math.random( 1, #warehouse_red.farp ) ]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            local target = warehouse_red.airbase[ math.random( 1, #warehouse_red.airbase ) ]

            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target.alias } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )







          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING STRUCTURE KUTAISI" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Soganlug
            local target = zoneTargetStructure.Red_Farm[ math.random( 1, #zoneTargetStructure.Red_Farm ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )






          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING STRUCTURE DIDI" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Soganlug
            local target = zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )





          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          elseif request.assignment == "BOMBING STRUCTURE KVEMO_SBA" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

            local home = warehouse.Soganlug
            local target = zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges ) ][1]
            local toTargetAltitude = math.random(5000, 7000)
            local toHomeAltitude = math.random(3000, 5000)
            local bombingDirection = math.random(270, 359)
            local bombingAltitude = math.random(4000, 6000)
            local diveBomb = false
            local bombRunDistance = 20000
            local bombRunDirection = math.random(270, 359)
            local speedBombRun = math.random(400, 600)

            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:GetName() } )

            activeBOMBING( groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, diveBomb, bombRunDistance, bombRunDirection, speedBombRun )



          else

            logging('warning', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )


          end

        end  --end  function warehouse.Kobuleti:OnAfterSelfRequest(From, Event, To, groupset, request)

        --- When the helo is out of fuel, it will return to the carrier and should be delivered.
        function warehouse.Soganlug:OnAfterDelivered(From,Event,To,request)

              -- le diverse opzioni disponibili per la scelta casuale della missione
              local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

              logging('info', { 'warehouse.Soganlug:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })
            --[[
              -- manca il groupset
              -- So we start another request.
              if request.assignment=="PATROL" then

                logging('info', { 'warehouse.Soganlug:OnAfterDelivered(From,Event,To,request)' , 'Soganlug scheduled PATROL mission' })
                activeCAPWarehouse(groupset, redFrontZone.BAI_Zone_Soganlug[2], 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

              end

              if request.assignment=="BAI TARGET" then

                logging('info', { 'warehouse.Soganlug:OnAfterDelivered(From,Event,To,request)' , 'Soganlug scheduled BAI TARGET mission' })
                activeBAIWarehouseT('Interdiction from Soganlug', groupset, 'target', redFrontZone.BAI_Zone_Soganlug[2], redFrontZone.BAI_Zone_Soganlug[2], 400, 1000, 4, 2, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

              end -- end if
              ]]

        end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)

    end -- end wh_activation.Warehouse_AB.blue.Soganlug then
    -------------------------------------------------------------END blue Soganlug operations ----------------------------------------------------------------------------------------------------------------------------




























































    -------------------------------------------------- END WAREHOUSE OPERATIONS




















































  --      AIRWAR (CAP e GCI ONLY)








  -- END CAP ZONE

































  ------------------------------------------------------------------------   AI A2A Dispatching ---------------------------------------------------------------




  if active_AI_A2A_red then


    -- RED FORCE CAP-GCI

    -- NOTA: UTILIZZATO SOLO PER LE CAP E GCI AI-



    -- Nota le GCI sono attivate quando non c'e' nessuno aereo alleato disponibile per l'ingaggio dell'incursore
    --
    -- Il dispatcher() imposta l'intercettazione dalla base pi� vicina distante meno del gci_radius. Credo che la base pi� vicina dovrebbe essere scelta da quelle abilitate trmite assign_gci
    --
    -- Credo che per poter utilizzare esclusivamente le gci suad devi dedicare a loro l'uso di un aeroporto: quindi scegli per le cap gli aeroporti vicino al fronte, mentre quelli lontani per i gci


    logging('info', { 'active_AI_A2A_red' , 'Starting'} )



    -- Setup generale


    detectionGroupSetRedA2A:FilterStart() -- This command will start the dynamic filtering, so when groups spawn in or are destroyed

    local detection = DETECTION_AREAS:New( detectionGroupSetRedA2A, 45000, { Unit.Category.AIRPLANE, Unit.Category.HELICOPTER }, nil, nil, nil, {'radar', 'rwr', 'dlink'} )

    --- detection red: e' la distanza massima di valutazione se due o piu' aerei appartengono ad uno stesso gruppo (30km x modern, 10 km per ww2)
    -- i distanza impostata a 30 km. Considera che più piccola è questa distanza e maggiore potrebbe essere l'attivazione delle GCI (conseguente alla presenza di più enemy group)
    -- local Detection_Red = detection(prefix_detector.red, 30000)

    -- local Detection_Red = detectionAI_A2A( prefix_detector.red, 30000, {Unit.Category.AIRPLANE, Unit.Category.HELICOPTER}, nil, nil, nil, nil )

    --- A2ADispatcher red:
    -- distanza massima di attivazione GCI = 70 km (rispetto le airbase),
    -- distanza massima autorizzazione all'ingaggio per aerei alleati nelle vicinanze (le CAP): 20000
    -- true/false: view tactital display
    --local A2ADispatcher_Red = dispatcher(detection, 70000, 20000, true)

    -- A2ADispatcher:
    -- definisci la distanza GCI in modo da attivare gli intercettori solo per nemici prossimi alle airbase e/o zone strategiche: vedi su ME 50km
    -- definisci la distanza CAP in modo da includere tutte le zone strategicamente importanti e 'sfiorare' quelle del fronte in modo da evitare che le CAP si annullino tra loro
    -- valuta su ME queste due didtanze
    A2ADispatcher = AI_A2A_DISPATCHER:New( detection )
    configureAI_A2ADispatcher( A2ADispatcher, 70000, 60000, A2ADispatcher.Takeoff.Runway, A2ADispatcher.Landing.AtRunway, 0.6, 0.4, false )




    -- Setup Red CAP e GCI

    local num_group = math.random(1, 3)
    local min_time_cap = 300
    local max_time_cap = 900
    local min_alt = 4000
    local max_alt = 9000
    local min_speed_patrol = 500
    local max_speed_patrol = 800
    local min_speed_engage = 800
    local max_speed_engage = 1200

    -- AWACS
    --local spawnDetectionGroup = SPAWN:New( air_template_red.AWACS_TU_22 )
    --spawnDetectionGroup:SpawnScheduled( 3600, 0.3 )
    --spawnDetectionGroup:InitCleanUp(180)
    --local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Mineralnye_Vody )

    --local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)
    --local detectionGroup = spawnDetectionGroup:SpawnFromVec2(airbase:GetCoordinate():GetVec2(), 1000)

    --logging('info', { 'activeAI_A2A_Dispatching_Red' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

    --assignDetectionGroupTask(detectionGroup, redAwacsZone.alagir, airbase, 7000, 9000, 0.5 )





    if wh_activation.Warehouse_AB.red.Mozdok[1] then

      logging('info', { 'wh_activation.Warehouse_AB.red.Mozdok' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.red.Mozdok[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.red.Mozdok[17]) } )

      A2ADispatcher:SetSquadron('Mozdok CAP', AIRBASE.Caucasus.Mozdok, {air_template_red.CAP_Mig_21Bis, air_template_red.CAP_Mig_23MLD}, 15)
      A2ADispatcher:SetSquadron('Mozdok GCI', AIRBASE.Caucasus.Mozdok, {air_template_red.GCI_Mig_21Bis, air_template_red.GCI_H_Mig_21Bis, air_template_red.GCI_L_Mig_21Bis, air_template_red.GCI_B_Mig_21Bis, air_template_red.GCI_Mig_19P}, 15)

      if wh_activation.Warehouse_AB.red.Mozdok[16] then assign_cap ( cap_zone_db_red[1], 'Mozdok CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.red.Mozdok[17] then assign_gci('Mozdok GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher) end

    end




    if wh_activation.Warehouse_AB.red.Beslan[1] then

      logging('info', { 'wh_activation.Warehouse_AB.red.Beslan' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.red.Beslan[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.red.Beslan[17]) } )

      A2ADispatcher:SetSquadron('Beslan GCI', AIRBASE.Caucasus.Beslan, {air_template_red.GCI_H_Mig_21Bis, air_template_red.GCI_Mig_21Bis}, 15)
      A2ADispatcher:SetSquadron('Beslan CAP', AIRBASE.Caucasus.Beslan, air_template_red.CAP_Mig_23MLD, 15)

      if wh_activation.Warehouse_AB.red.Beslan[16] then assign_cap ( cap_zone_db_red[2], 'Beslan CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.red.Beslan[17] then assign_gci('Beslan GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher) end

    end



    if wh_activation.Warehouse_AB.red.Nalchik[1] then

      logging('info', { 'wh_activation.Warehouse_AB.red.Nalchik' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.red.Nalchik[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.red.Nalchik[17]) } )

      A2ADispatcher:SetSquadron('Nalchik GCI', AIRBASE.Caucasus.Nalchik, {air_template_red.GCI_Mig_25PD, air_template_red.GCI_H_Mig_21Bis}, 15)
      A2ADispatcher:SetSquadron('Nalchik CAP', AIRBASE.Caucasus.Nalchik, {air_template_red.CAP_Mig_23MLD, air_template_red.CAP_H_Mig_21Bis, air_template_red.CAP_Mig_19P}, 15)

      if wh_activation.Warehouse_AB.red.Nalchik[16] then assign_cap ( cap_zone_db_red[1], 'Nalchik CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.red.Nalchik[17] then assign_gci('Nalchik GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher) end

    end


    if wh_activation.Warehouse_AB.red.Mineralnye[1] then

      logging('info', { 'wh_activation.Warehouse_AB.red.Mineralnye' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.red.Mineralnye[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.red.Mineralnye[17]) } )

      A2ADispatcher:SetSquadron('Mineralnye GCI', AIRBASE.Caucasus.Mineralnye_Vody, {air_template_red.GCI_Mig_25PD, air_template_red.GCI_H_Mig_21Bis, air_template_red.GCI_B_Mig_21Bis}, 15)
      A2ADispatcher:SetSquadron('Mineralnye CAP', AIRBASE.Caucasus.Mineralnye_Vody, {air_template_red.CAP_Mig_23MLD, air_template_red.CAP_Mig_21Bis}, 15)


      if wh_activation.Warehouse_AB.red.Mineralnye[16] then assign_cap ( cap_zone_db_red[2], 'Mineralnye CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.red.Mineralnye[17] then assign_gci('Mineralnye GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher) end

    end


  end -- if active_AI_A2A_red








  if active_AI_A2A_blue then


    -- BLUE FORCE CAP-GCI (OK)


      logging('info', { 'active_AI_A2A_blue' , 'Starting'} )

    -- Kutaisi


    -- Setup generale

    --- detection blue: e' la distanza massima di rilevamento dei radar
    -- i distanza impostata a 100 km
    -- local Detection_Blue = detection(prefix_detector.blue, 30000)
    --local Detection_Blue = detectionAI_A2A( prefix_detector.blue, 30000, categories, nil, nil, nil, nil )

    --- A2ADispatcher blue:
    -- distanza massima di attivazione GCI = 70 km (rispetto le aribase),
    -- distanza massima autorizzazione all'ingaggio per aerei alleati nelle vicinanze
    -- true/false: view tactital display
    --local A2ADispatcher_Blue = dispatcher(Detection_Blue, 70000, 20000, true)

    detectionGroupSetBlueA2A:FilterStart() -- This command will start the dynamic filtering, so when groups spawn in or are destroyed

    local detection = DETECTION_AREAS:New( detectionGroupSetBlueA2A, 50000, {Unit.Category.AIRPLANE, Unit.Category.HELICOPTER}, nil, nil, nil, {'radar', 'rwr', 'dlink'} )

    -- A2ADispatcher:
    A2ADispatcher = AI_A2A_DISPATCHER:New( detection )
    configureAI_A2ADispatcher( A2ADispatcher, 75000, 65000, A2ADispatcher.Takeoff.Runway, A2ADispatcher.Landing.AtRunway, 0.6, 0.4, false )


    -- Setup Red CAP e GCI

    local num_group = math.random(1, 3)
    local min_time_cap = 300
    local max_time_cap = 900
    local min_alt = 4000
    local max_alt = 9000
    local min_speed_patrol = 500
    local max_speed_patrol = 800
    local min_speed_engage = 800
    local max_speed_engage = 1200


    -- AWACS
    --local spawnDetectionGroup = SPAWN:New( air_template_blue.AWACS_B_1B )
    --spawnDetectionGroup:SpawnScheduled( 3600, 0.3 )
    --spawnDetectionGroup:InitCleanUp(180)
    --local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Batumi )
    --local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)
    --local detectionGroup = spawnDetectionGroup:SpawnFromVec2(airbase:GetCoordinate():GetVec2(), 1000)

    --logging('info', { 'activeAI_A2A_Dispatching_Blue' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

    --assignDetectionGroupTask(detectionGroup, blueAwacsZone.kutaisi, airbase, 7000, 9000, 0.5 )



    -- Setup cap e gci

    -- CAP and GCI

    if wh_activation.Warehouse_AB.blue.Kutaisi[1] then

      logging('info', { 'wh_activation.Warehouse_AB.blue.Kutaisi' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Kutaisi[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Kutaisi[17]) } )

      A2ADispatcher:SetSquadron('Kutaisi CAP', AIRBASE.Caucasus.Kutaisi, air_template_blue.CAP_F_5, 15 )
      A2ADispatcher:SetSquadron('Kutaisi GCI', AIRBASE.Caucasus.Kutaisi, air_template_blue.GCI_F_5, 15 )

      if wh_activation.Warehouse_AB.blue.Kutaisi[16] then assign_cap ( cap_zone_db_blue[1], 'Kutaisi CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.blue.Kutaisi[17] then assign_gci('Kutaisi GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher ) end

    end



    if wh_activation.Warehouse_AB.blue.Vaziani[1] then

      logging('info', { 'wh_activation.Warehouse_AB.blue.Vaziani' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Vaziani[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Vaziani[17]) } )

      A2ADispatcher:SetSquadron('Vaziani CAP', AIRBASE.Caucasus.Vaziani, {air_template_blue.CAP_F_4, air_template_blue.CAP_F_5}, 15)
      A2ADispatcher:SetSquadron('Vaziani GCI', AIRBASE.Caucasus.Vaziani, {air_template_blue.GCI_F_4, air_template_blue.GCI_F_5}, 15)

      if wh_activation.Warehouse_AB.blue.Vaziani[16] then assign_cap ( cap_zone_db_blue[2], 'Vaziani CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.blue.Vaziani[17] then assign_gci('Vaziani GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher ) end

    end



    if wh_activation.Warehouse_AB.blue.Soganlug[1] then

      logging('info', { 'wh_activation.Warehouse_AB.blue.Soganlug' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Soganlug[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Soganlug[17]) } )

      A2ADispatcher:SetSquadron('Soganlug CAP', AIRBASE.Caucasus.Soganlug, { air_template_blue.CAP_L_Mig_21Bis, air_template_blue.CAP_AJS_37 }, 15)
      A2ADispatcher:SetSquadron('Soganlug GCI', AIRBASE.Caucasus.Soganlug, { air_template_blue.GCI_Mig_21Bis, air_template_blue.GCI_AJS_37}, 15)

      if wh_activation.Warehouse_AB.blue.Soganlug[16] then assign_cap ( cap_zone_db_blue[1], 'Soganlug CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.blue.Soganlug[17] then assign_gci('Soganlug GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher ) end

    end



    if wh_activation.Warehouse_AB.blue.Tbilisi[1] then

      logging('info', { 'wh_activation.Warehouse_AB.blue.Tbilisi' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Tbilisi[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Tbilisi[17]) } )

      A2ADispatcher:SetSquadron('Tbilisi CAP', AIRBASE.Caucasus.Tbilisi_Lochini, {air_template_blue.CAP_AJS_37, air_template_blue.CAP_Mig_19P}, 15)
      A2ADispatcher:SetSquadron('Tbilisi GCI', AIRBASE.Caucasus.Tbilisi_Lochini, {air_template_blue.GCI_Mig_19P, air_template_blue.GCI_AJS_37}, 15)

      if wh_activation.Warehouse_AB.blue.Tbilisi[16] then assign_cap ( cap_zone_db_blue[2], 'Tbilisi CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.blue.Tbilisi[17] then assign_gci('Tbilisi GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher ) end

    end




    if wh_activation.Warehouse_AB.blue.Batumi[1] then

      logging('info', { 'wh_activation.Warehouse_AB.blue.Batumi' , 'CAP activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Batumi[16]) .. 'GCI activation: ' .. tostring(wh_activation.Warehouse_AB.blue.Batumi[17]) } )

      A2ADispatcher:SetSquadron('Batumi GCI', AIRBASE.Caucasus.Batumi, {air_template_blue.GCI_F_14A, air_template_blue.GCI_F_4, air_template_blue.CAP_AJS_37}, 15)
      A2ADispatcher:SetSquadron('Batumi CAP', AIRBASE.Caucasus.Batumi, {air_template_blue.CAP_AJS_37, air_template_blue.CAP_F_4}, 15)

      if wh_activation.Warehouse_AB.blue.Batumi[16] then assign_cap ( cap_zone_db_blue[1], 'Batumi CAP', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, parAirbOp.cap[ 1 ], parAirbOp.cap[ 2 ], A2ADispatcher ) end
      if wh_activation.Warehouse_AB.blue.Batumi[17] then assign_gci('Batumi GCI', 800, 1200, parAirbOp.gci[ 1 ], parAirbOp.gci[ 2 ], A2ADispatcher ) end

    end

  end -- if active_AI_A2A_blue















































  ------------------------------------------------------------------------   AI A2G Dispatching ---------------------------------------------------------------



  -- info @ https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/AI.AI_A2G_Dispatcher.html



  if activeAI_A2G_Dispatching_Red then


      logging('enter', 'activeAI_A2G_Dispatching_Red' )


      -- il detectionSetGroup va istanziato globalmente e suddiviso nelle diverse zone:
      -- detectionSetGroupHq1, ..
      -- dalle Farp vengono generati voli FAC e addizionati ai detectionSetGroup di competenza
      -- conviene suddividere tra gli aeroporti le tipologie SEAD, BAI e CAS
      -- local detectionGroup = generateDetectioA2G_Group(name, aircraftTemplate, routeAltitude, detectionAltitude)


      detectionGroupSetRed:FilterStart() -- This command will start the dynamic filtering, so when groups spawn in or are destroyed,

      -- This command defines the reconnaissance network.
      -- It will group any detected ground enemy targets within a radius of 1km. (crea un gruppo per tutte le unita' detected (rilevate) presenti in una circonferenza di raggio 1 km)
      -- It uses the DetectionSetGroup, which defines the set of reconnaissance groups to detect for enemy ground targets.


      --printGroupSet( detectionGroupSetRed )

      local activeAI_A2G_Dispatching_HQ1 = true -- per il teatro 1: Ossetia Scenario


      -- A2G Dispatching for Red HQ1 OSSETIA SCENARIO
      if activeAI_A2G_Dispatching_HQ1 then



         local detection = DETECTION_AREAS:New( detectionGroupSetRed, 1000 )

         -- Setup the A2A dispatcher, and initialize it.
         local A2GDispatcher = AI_A2G_DISPATCHER:New( detection )

         configureAI_A2GDispatcher( A2GDispatcher, 30000, 'medium', HQ_RED, A2GDispatcher.Takeoff.Runway, A2GDispatcher.Landing.AtRunway, 0.4, 0.6, 3, false )



         -- A2G BESLAN (Squadron Su-17, Su-24)

         if wh_activation.Warehouse_AB.red.Beslan[1] then

             -- SPAWN DETECTION AIRCRAFT AT AIRBASE
             --[[
             local spawnDetectionGroup = SPAWN:New( air_template_red.REC_SU_24MR )
             spawnDetectionGroup:SpawnScheduled( 3600, 0.5 )
             spawnDetectionGroup:InitCleanUp(180)
             local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Beslan )
             local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)




             logging('info', { 'Warehouse_AB.red.Beslan - activeAI_A2G_Dispatching_Red' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

             assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )


             logging('info', { 'Warehouse_AB.red.Beslan - activeAI_A2G_Dispatching_Red' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


             function detectionGroup:OnEventDead( EventData )

                --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                logging('info', { 'Warehouse_AB.red.Beslan - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                -- When the last detectionGroup of the group is declared dead, respawn the group.
                if detectionGroup:GetSize() == 1 then

                  detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                  logging('info', { 'Warehouse_AB.red.Beslan - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                  assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

                end

             end -- end function detectionGroup:OnEventDead( EventData )



            function detectionGroup:OnEventLand( EventData )

                     --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                     logging('info', { 'Warehouse_AB.red.Beslan - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                     -- When the last detectionGroup of the group is declared dead, respawn the group.
                     if detectionGroup:GetSize() == 1 then

                       detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                       logging('info', { 'Warehouse_AB.red.Beslan - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                       assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

                     end

            end -- end function detectionGroup:OnEventLand( EventData )
            ]]


               -- SEAD: Suppression of Air Defenses, which are ground targets that have medium or long range radar emitters.
               -- CAS : Close Air Support, when there are enemy ground targets close to friendly units.
               -- BAI : Battlefield Air Interdiction, which are targets further away from the frond-line


             local casTemplateAirplane = { air_template_red.CAS_Su_17M4_Rocket, air_template_red.CAS_Su_17M4_Cluster, air_template_red.CAS_Su_17M4_Bomb, air_template_red.GA_SU_24M_HRocket }
             local baiTemplate = { air_template_red.GA_SU_24M_Bomb, air_template_red.BOM_SU_24_Bomb, air_template_red.BOM_SU_24_Structure, air_template_red.BOM_SU_17_Structure }
             local seadTemplate = { air_template_red.SEAD_SU_17, air_template_red.SEAD_MIX_SU_17, air_template_red.SEAD_SU_24 }

             if wh_activation.Warehouse_AB.red.Beslan[2] then

               -- Set Defence Squadron
               local squadronName = "Beslan CAS"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Beslan, casTemplateAirplane, 20 )

               -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
               configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], nil, 0.3, 500, 700, 2000, 4000)

               -- PATROL CAS MISSION
               configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, redFrontZone.SATIHARI[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')


             end

             if wh_activation.Warehouse_AB.red.Beslan[3] then


                -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
               squadronName = "Beslan BAI"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Beslan, baiTemplate, 20 )
               configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

             end


             if wh_activation.Warehouse_AB.red.Beslan[4] then

               -- PATROL SEAD MISSION: invia attacchi in zona Patrol pronti ad intervenire se rilevata minaccia SAM
               squadronName = "Beslan SEAD"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Beslan, seadTemplate, 20 )
               configureAI_A2G_SEAD_Mission( A2GDispatcher, squadronName, parAirbOp.sead[ 1 ], parAirbOp.sead[ 2 ], nil, 0.5, 700, 500, 2000, 3500)
               --configureAI_A2G_PATROL_SEAD_Mission( A2GDispatcher, squadronName, afacZone.Tskhunvali_Tkviavi[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

             end



         end -- if wh_activation.Warehouse_AB.red.Beslan


         -- A2G Nalchik (Squadron Su-17, Mig-27, Reco Mig 25)

         if wh_activation.Warehouse_AB.red.Nalchik[1] then

             -- SPAWN DETECTION AIRCRAFT AT AIRBASE
             --[[
             local spawnDetectionGroup = SPAWN:New( air_template_red.REC_Mig_25RTB )
             local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Nalchik )
             local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)


             logging('info', { 'Warehouse_AB.red.Nalchik - activeAI_A2G_Dispatching_Red' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

             assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

             logging('info', { 'Warehouse_AB.red.Nalchik - activeAI_A2G_Dispatching_Red' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


             function detectionGroup:OnEventDead( EventData )

                --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                logging('info', { 'Warehouse_AB.red.Nalchik - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                -- When the last detectionGroup of the group is declared dead, respawn the group.
                if detectionGroup:GetSize() == 1 then

                  detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                  logging('info', { 'Warehouse_AB.red.Nalchik - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                  assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

                end

             end -- end function detectionGroup:OnEventDead( EventData )



             function detectionGroup:OnEventLand( EventData )

                     --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                     logging('info', { 'Warehouse_AB.red.Nalchik - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                     -- When the last detectionGroup of the group is declared dead, respawn the group.
                     if detectionGroup:GetSize() == 1 then

                       detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                       logging('info', { 'Warehouse_AB.red.Nalchik - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                       assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

                     end

             end -- end function detectionGroup:OnEventLand( EventData )
             ]]

             --A2GDispatcher:SetDefaultGrouping()

             local casTemplateAirplane = { air_template_red.CAS_Su_17M4_Rocket, air_template_red.CAS_Su_17M4_Cluster, air_template_red.CAS_Su_17M4_Bomb }
             local baiTemplate = { air_template_red.GA_SU_24M_HRocket, air_template_red.GA_Mig_27K_Bomb_Light, air_template_red.GA_Mig_27K_Sparse_Light, air_template_red.GA_Mig_27K_Missile_R }
             local seadTemplate = { air_template_red.SEAD_SU_17, air_template_red.SEAD_MIX_SU_17 }


             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             if wh_activation.Warehouse_AB.red.Nalchik[2] then

               local squadronName = "Nalchik CAS"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Beslan, casTemplateAirplane, 20 )
               configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], nil, 0.3, 500, 700, 2000, 4000)

               -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
               configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, redFrontZone.SATIHARI[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

             end


             -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
             if wh_activation.Warehouse_AB.red.Nalchik[3] then

               squadronName = "Nalchik BAI"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Nalchik, baiTemplate, 20 )
               configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

             end


             -- PATROL SEAD MISSION: invia attacchi in zona Patrol pronti ad intervenire se rilevata minaccia SAM
             if wh_activation.Warehouse_AB.red.Nalchik[4] then

               squadronName = "Nalchik SEAD"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Nalchik, seadTemplate, 20 )
               configureAI_A2G_PATROL_SEAD_Mission( A2GDispatcher, squadronName, afacZone.Tskhunvali_Tkviavi[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

             end



         end -- if wh_activation.Warehouse_AB.red.Nalchik


         -- A2G Mineralnye (squadron Mig-27 CAS e BAI, Su_24 Sead)

         if wh_activation.Warehouse_AB.red.Mineralnye[1] then

             -- SPAWN DETECTION AIRCRAFT AT AIRBASE
             --[[
             local spawnDetectionGroup = SPAWN:New( air_template_red.REC_SU_24MR )
             local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Mineralnye_Vody )
             local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

             logging('info', { 'Warehouse_AB.red.Mineralnye - activeAI_A2G_Dispatching_Red' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

             assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

             logging('info', { 'Warehouse_AB.red.Mineralnye - activeAI_A2G_Dispatching_Red' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


             function detectionGroup:OnEventDead( EventData )

                --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                logging('info', { 'detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                -- When the last detectionGroup of the group is declared dead, respawn the group.
                if detectionGroup:GetSize() == 1 then

                  detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                  logging('info', { 'Warehouse_AB.red.Mineralnye - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                  assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

                end

             end -- end function detectionGroup:OnEventDead( EventData )



             function detectionGroup:OnEventLand( EventData )

                     --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                     logging('info', { 'Warehouse_AB.red.Mineralnye - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                     -- When the last detectionGroup of the group is declared dead, respawn the group.
                     if detectionGroup:GetSize() == 1 then

                       detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                       logging('info', { 'Warehouse_AB.red.Mineralnye - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                       assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

                     end

             end -- end function detectionGroup:OnEventLand( EventData )
             ]]

             --A2GDispatcher:SetDefaultGrouping()

             local casTemplateAirplane = { air_template_red.CAS_Mig_27K_Bomb, air_template_red.CAS_Mig_27K_Rocket, air_template_red.GA_Mig_27K_Bomb_Light, air_template_red.GA_Mig_27K_ROCKET_Heavy, air_template_red.GA_Mig_27K_ROCKET_Light, air_template_red.GA_Mig_27K_Sparse_Light }
             local baiTemplate = { air_template_red.GA_Mig_27K_ROCKET_Light, air_template_red.GA_Mig_27K_Bomb_Light, air_template_red.GA_Mig_27K_ROCKET_Heavy, air_template_red.GA_Mig_27K_Sparse_Light, air_template_red.GA_Mig_27K_Missile_R, air_template_red.GA_Mig_27K_Missile_L }
             local seadTemplate = { air_template_red.SEAD_SU_24 }


             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             if wh_activation.Warehouse_AB.red.Mineralnye[2] then

               local squadronName =  "Mineralnye CAS"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Mineralnye_Vody, casTemplateAirplane, 20 )
               configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], nil, 0.3, 500, 700, 2000, 4000)

               -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
              --configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, redFrontZone.SATIHARI[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

             end

             -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
             if wh_activation.Warehouse_AB.red.Mineralnye[3] then

               squadronName = "Mineralnye BAI"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Mineralnye_Vody, baiTemplate, 20 )
               configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

             end

             -- PATROL SEAD MISSION: invia attacchi in zona Patrol pronti ad intervenire se rilevata minaccia SAM
             if wh_activation.Warehouse_AB.red.Mineralnye[4] then

               squadronName = "Mineralnye SEAD"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Mineralnye_Vody, seadTemplate, 20 )
               --configureAI_A2G_PATROL_SEAD_Mission( A2GDispatcher, squadronName, afacZone.Tskhunvali_Tkviavi[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')
               configureAI_A2G_SEAD_Mission( A2GDispatcher, squadronName, parAirbOp.sead[ 1 ], parAirbOp.sead[ 2 ], nil, 0.5, 700, 500, 2000, 3500)

             end

         end -- if wh_activation.Warehouse_AB.red.Mineralnye



         -- A2G Mozdok (Squadron Tu-22, Su-24 solo Bai)

         if wh_activation.Warehouse_AB.red.Mozdok[1] then

             -- SPAWN DETECTION AIRCRAFT AT AIRBASE
             --[[
             local spawnDetectionGroup = SPAWN:New( air_template_red.REC_SU_24MR )
             local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Mozdok )
             local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

             logging('info', { 'Warehouse_AB.red.Mozdok - activeAI_A2G_Dispatching_Red' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

             assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

             logging('info', { 'Warehouse_AB.red.Mozdok - activeAI_A2G_Dispatching_Red' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


             function detectionGroup:OnEventDead( EventData )

                --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                logging('info', { 'Warehouse_AB.red.Mozdok - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                -- When the last detectionGroup of the group is declared dead, respawn the group.
                if detectionGroup:GetSize() == 1 then

                  detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                  logging('info', { 'Warehouse_AB.red.Mozdok - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                  assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

                end

             end -- end function detectionGroup:OnEventDead( EventData )



             function detectionGroup:OnEventLand( EventData )

                     --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                     logging('info', { 'Warehouse_AB.red.Mozdok - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                     -- When the last detectionGroup of the group is declared dead, respawn the group.
                     if detectionGroup:GetSize() == 1 then

                       detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                       logging('info', { 'Warehouse_AB.red.Mozdok - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                       assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 7000, 2000, 0.5 )

                     end

             end -- end function detectionGroup:OnEventLand( EventData )
             ]]
                 --A2GDispatcher:SetDefaultGrouping()

             --local casTemplateAirplane = { air_template_red.CAS_Mig_27K_Bomb, air_template_red.CAS_Mig_27K_Rocket, air_template_red.GA_Mig_27K_Bomb_Light, air_template_red.GA_Mig_27K_ROCKET_Heavy, air_template_red.GA_Mig_27K_ROCKET_Light, air_template_red.GA_Mig_27K_Sparse_Light}
             local baiTemplate = { air_template_red.BOM_TU_22_Bomb, air_template_red.BOM_SU_24_Bomb, air_template_red.BOM_SU_24_Structure, air_template_red.GA_SU_24M_HRocket }
             --local seadTemplate = { air_template_red.SEAD_SU_24 }


             -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
             if wh_activation.Warehouse_AB.red.Mozdok[3] then

               local squadronName = "Mozdok BAI"
               A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Mozdok, baiTemplate, 30 )
               configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

             end


         end -- if wh_activation.Warehouse_AB.red.Mozdok



         -- A2G DIDI_CUPTA

         if wh_activation.Warehouse.red.Didi[1] then

             -- SPAWN DETECTION AIRCRAFT AT AIRBASE

             local spawnDetectionGroup = SPAWN:New( air_template_red.AFAC_Mi_8MTV2 )
             local detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.red.Didi_1[1] )
             local airbase = warehouse.Didi



             logging('info', { 'Warehouse.red.Didi - activeAI_A2G_Dispatching' , 'airbase = ' .. airbase.alias .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

             assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 1000, 700, 0.5 )

             logging('info', { 'Warehouse.red.Didi - activeAI_A2G_Dispatching' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


             function detectionGroup:OnEventDead( EventData )

                --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                logging('info', { 'Warehouse.red.Didi - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                -- When the last detectionGroup of the group is declared dead, respawn the group.
                if detectionGroup:GetSize() == 1 then

                  detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.red.Didi_1[1] )

                  logging('info', { 'Warehouse.red.Didi - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                  assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 1000, 700, 0.5 )

                end

             end -- end function detectionGroup:OnEventDead( EventData )



             function detectionGroup:OnEventLand( EventData )

                     --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                     logging('info', { 'Warehouse.red.Didi - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                     -- When the last detectionGroup of the group is declared dead, respawn the group.
                     if detectionGroup:GetSize() == 1 then

                       detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.red.Didi_1[1] )

                       logging('info', { 'Warehouse.red.Didi - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                       assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 1000, 700, 0.5 )

                     end

             end -- end function detectionGroup:OnEventLand( EventData )

             local casTemplateHeli = { air_template_red.CAS_MI_24V, air_template_red.CAS_Mi_8MTV2 }
             local seadTemplateHeli = { air_template_red.CAS_Mi_8MTV2 }


             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             if wh_activation.Warehouse.red.Didi[2] then

               local squadronName = "Didi CAS"
               A2GDispatcher:SetSquadron( squadronName, staticObject.Farp.red.Didi_1[1]:GetName(), casTemplateHeli, 20) -- FARP Didi
               configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], 60 * 4, 0.3, 200, 300, 700, 1500)

               -- PATROL CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
               configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, afacZone.Sathiari_Tkviavi[1], 1, 300, 700, 200, 300, 200, 300, 'RADIO')

             end


         end -- if wh_activation.Warehouse_AB.red.Didi



         -- A2G Biteta

         if wh_activation.Warehouse.red.Biteta[1] then

             -- SPAWN DETECTION AIRCRAFT AT AIRBASE

             local spawnDetectionGroup = SPAWN:New( air_template_red.AFAC_Mi_8MTV2 )
             --spawnDetectionGroup:SpawnScheduled( 3600, 0.3 )
             --spawnDetectionGroup:InitCleanUp(600)
             local detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Warehouse.red.Biteta[1] )
             local airbase = warehouse.Biteta

             logging('info', { 'Warehouse.red.Biteta - activeAI_A2G_Dispatching' , 'airbase = ' .. airbase.alias .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

             assignDetectionGroupTask(detectionGroup, afacZone.Didi_South[ 1 ], airbase, 1000, 700, 0.5 )

             logging('info', { 'Warehouse.red.Biteta - activeAI_A2G_Dispatching' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


             function detectionGroup:OnEventDead( EventData )

                --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                logging('info', { 'Warehouse.red.Biteta - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                -- When the last detectionGroup of the group is declared dead, respawn the group.
                if detectionGroup:GetSize() == 1 then

                  detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Warehouse.red.Biteta[1] )

                  logging('info', { 'Warehouse.red.Biteta - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                  assignDetectionGroupTask(detectionGroup, afacZone.Didi_South[ 1 ], airbase, 1000, 700, 0.5 )

                end

             end -- end function detectionGroup:OnEventDead( EventData )



            function detectionGroup:OnEventLand( EventData )

                     --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                     logging('info', { 'Warehouse.red.Biteta - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                     -- When the last detectionGroup of the group is declared dead, respawn the group.
                     if detectionGroup:GetSize() == 1 then

                       detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Warehouse.red.Biteta[1] )

                       logging('info', { 'Warehouse.red.Biteta - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                       assignDetectionGroupTask(detectionGroup, afacZone.Didi_South[ 1 ], airbase, 1000, 700, 0.5 )

                     end

            end -- end function detectionGroup:OnEventLand( EventData )


             local casTemplateHeli = { air_template_red.CAS_MI_24V, air_template_red.CAS_Mi_8MTV2 }
             --local seadTemplateHeli = { air_template_red.CAS_Mi_8MTV2 }

             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             if wh_activation.Warehouse.red.Biteta[2] then

               local squadronName = "Biteta CAS"
               A2GDispatcher:SetSquadron( squadronName, staticObject.Farp.red.Biteta[1]:GetName(), casTemplateHeli, 20 ) --FARP Biteta
               configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], 60 * 4, 0.3, 200, 300, 700, 1500)

               -- PATROL CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
               configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, redFrontZone.SATIHARI[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

             end

         end -- if wh_activation.Warehouse_AB.red.Biteta


      end -- if activeAI_A2G_Dispatching_HQ1


  end -- if activeAI_A2G_Dispatching_Red


  if activeAI_A2G_Dispatching_Blue then

    logging('enter', 'activeAI_A2G_Dispatching_Blue' )


    -- il detectionSetGroup va istanziato globalmente e suddiviso nelle diverse zone:
    -- detectionSetGroupHq1, ..
    -- dalle Farp vengono generati voli FAC e addizionati ai detectionSetGroup di competenza
    -- conviene suddividere tra gli aeroporti le tipologie SEAD, BAI e CAS
    -- local detectionGroup = generateDetectioA2G_Group(name, aircraftTemplate, routeAltitude, detectionAltitude)


    detectionGroupSetBlue:FilterStart() -- This command will start the dynamic filtering, so when groups spawn in or are destroyed,


    local activeAI_A2G_Dispatching_HQ1 = true -- per il teatro 1

    -- A2G Dispatching for Red HQ1
    if activeAI_A2G_Dispatching_HQ1 then


       -- GENERATION AND ACTIVATION OF AI_A2G_DISPATCHER


       -- NOTA: dovrebbe acquisire dinamicamente i nuovi gruppi detection: verificare con i gruppi generati dalle WH. Devono comunque essere definiti i template in ME e attivati dalle WH prima(?) della creazione della AI_A2G??
       -- quindi devi trasformarla in una funzione e la stessa cosa dovrebbe essere realizzata per AI_A2A.
       -- NO! Per separare la gestione delle operazioni terrestri (WH) da quelle aeree (AI_A2A, AI_A2G) la generazione dei detection group deve essere gestita qui:
       -- con uno scheduler che periodicamente lancia missioni detection ovvero (meglio) utilizzando lo spawn di un template e utilizzare una funzione evento (OnEventDead) per rigenerare awacs, recon e AFAC, distrutti.
       -- mentre le FAC, JTAC dovrebbero continuare ad essere gestite dalla WH.

       -- This command defines the reconnaissance network.
       -- It will group any detected ground enemy targets within a radius of 1km. (crea un gruppo per tutte le unita' detected (rilevate) presenti in una circonferenza di raggio 1 km)
       -- It uses the DetectionSetGroup, which defines the set of reconnaissance groups to detect for enemy ground targets.
       local detection = DETECTION_AREAS:New( detectionGroupSetBlue, 1000 )

       -- Setup the A2A dispatcher, and initialize it.
       local A2GDispatcher = AI_A2G_DISPATCHER:New( detection )

       configureAI_A2GDispatcher( A2GDispatcher, 30000, 'medium', HQ_BLUE, A2GDispatcher.Takeoff.Runway, A2GDispatcher.Landing.AtRunway, 0.4, 0.6, 3, false )



       -- A2G Vaziani (Squadron B1-B, B-52, F4 Rec)

       if wh_activation.Warehouse_AB.blue.Batumi[1] then

           -- SPAWN DETECTION AIRCRAFT AT AIRBASE

           local spawnDetectionGroup = SPAWN:New( air_template_blue.REC_F_4 )
           local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Batumi )
           local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)


           logging('info', { 'Warehouse_AB.blue.Batumi - activeAI_A2G_Dispatching' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

           assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

           logging('info', { 'Warehouse_AB.blue.Batumi - activeAI_A2G_Dispatching' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )



           function detectionGroup:OnEventDead( EventData )

              --self:E( { "Size ", Size = detectionGroup:GetSize() } )
              logging('info', { 'Warehouse_AB.blue.Batumi - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

              -- When the last detectionGroup of the group is declared dead, respawn the group.
              if detectionGroup:GetSize() == 1 then

                detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                logging('info', { 'Warehouse_AB.blue.Batumi - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

              end

            end -- end function detectionGroup:OnEventDead( EventData )



            function detectionGroup:OnEventLand( EventData )

                   --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                   logging('info', { 'Warehouse_AB.blue.Batumi - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                   -- When the last detectionGroup of the group is declared dead, respawn the group.
                   if detectionGroup:GetSize() == 1 then

                     detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                     logging('info', { 'Warehouse_AB.blue.Batumi - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                     assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

                   end

            end -- end function detectionGroup:OnEventLand( EventData )


            local baiTemplate = { air_template_blue.BOM_B_1B, air_template_blue.BOM_B_52H}




            -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
            if wh_activation.Warehouse_AB.blue.Batumi[3] then

              local squadronName = "Batumi BAI"
              A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Batumi, baiTemplate, 20 )
              configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

            end

       end -- if wh_activation.Warehouse_AB.red.Batumi




       -- A2G Vaziani (Squadron Su-17, F4 Rec)

       if wh_activation.Warehouse_AB.blue.Vaziani[1] then

           -- SPAWN DETECTION AIRCRAFT AT AIRBASE
           --[[
           local spawnDetectionGroup = SPAWN:New( air_template_blue.REC_F_4 )
           local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Vaziani )
           --spawnDetectionGroup:SpawnScheduled( 3600, 0.3 )
           --spawnDetectionGroup:InitCleanUp(600)

           local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)
           --local detectionGroup = spawnDetectionGroup:SpawnFromVec2(airbase:GetCoordinate():GetVec2(), 1000)

           logging('info', { 'Warehouse_AB.blue.Vaziani - activeAI_A2G_Dispatching_Blue' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

           assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

           logging('info', { 'Warehouse_AB.blue.Vaziani - activeAI_A2G_Dispatching_Blue' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


           function detectionGroup:OnEventDead( EventData )

              --self:E( { "Size ", Size = detectionGroup:GetSize() } )
              logging('info', { 'Warehouse_AB.blue.Vaziani - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

              -- When the last detectionGroup of the group is declared dead, respawn the group.
              if detectionGroup:GetSize() == 1 then

                detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                logging('info', { 'Warehouse_AB.blue.Vaziani - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

              end

           end -- end function detectionGroup:OnEventDead( EventData )



          function detectionGroup:OnEventLand( EventData )

                   --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                   logging('info', { 'Warehouse_AB.blue.Vaziani - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                   -- When the last detectionGroup of the group is declared dead, respawn the group.
                   if detectionGroup:GetSize() == 1 then

                     detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                     logging('info', { 'Warehouse_AB.blue.Vaziani - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                     assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

                   end

          end -- end function detectionGroup:OnEventLand( EventData )

          ]]

          local casTemplateAirplane = { air_template_blue.CAS_Su_17M4_Rocket, air_template_blue.CAS_Su_17M4_Bomb, air_template_blue.CAS_Su_17M4_Cluster }
          local baiTemplate = { air_template_blue.CAS_Su_17M4_Bomb, air_template_blue.CAS_Su_17M4_Rocket, air_template_blue.CAS_Su_17M4_Cluster}
          local seadTemplate = { air_template_blue.SEAD_F_4E_L, air_template_blue.SEAD_F_4E_M, air_template_blue.SEAD_F_4E_H }

          if wh_activation.Warehouse_AB.blue.Vaziani[2] then

            local squadronName = "Vaziani CAS"
            A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Vaziani, casTemplateAirplane, 30 )

             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], nil, 0.3, 500, 700, 2000, 4000)

             -- PATROL CAS MISSION
             configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, redFrontZone.SATIHARI[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

          end

           -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
          if wh_activation.Warehouse_AB.blue.Vaziani[3] then

             squadronName = "Vaziani BAI"
             A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Vaziani, baiTemplate, 20 )
             configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

          end


           -- PATROL SEAD MISSION: invia attacchi in zona Patrol pronti ad intervenire se rilevata minaccia SAM
          if wh_activation.Warehouse_AB.blue.Vaziani[4] then

             squadronName = "Vaziani SEAD"
             A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Vaziani, seadTemplate, 20 )
             --configureAI_A2G_PATROL_SEAD_Mission( A2GDispatcher, squadronName, afacZone.Tskhunvali_Tkviavi[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')
             configureAI_A2G_SEAD_Mission( A2GDispatcher, squadronName, parAirbOp.sead[ 1 ], parAirbOp.sead[ 2 ], nil, 0.5, 700, 500, 2000, 3500)

          end

       end -- if wh_activation.Warehouse_AB.red.Vaziani








       -- A2G Soganlug (Squadron Su-17, F4 Rec)

       if wh_activation.Warehouse_AB.blue.Soganlug[1] then

           -- SPAWN DETECTION AIRCRAFT AT AIRBASE
           --[[
           local spawnDetectionGroup = SPAWN:New( air_template_blue.REC_F_4 )
           local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Soganlug )
           --spawnDetectionGroup:SpawnScheduled( 3600, 0.3 )
           --spawnDetectionGroup:InitCleanUp(600)

           local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)
           --local detectionGroup = spawnDetectionGroup:SpawnFromVec2(airbase:GetCoordinate():GetVec2(), 1000)

           logging('info', { 'Warehouse_AB.blue.Soganlug - activeAI_A2G_Dispatching_Blue' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

           assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

           logging('info', { 'Warehouse_AB.blue.Soganlug - activeAI_A2G_Dispatching_Blue' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


           function detectionGroup:OnEventDead( EventData )

              --self:E( { "Size ", Size = detectionGroup:GetSize() } )
              logging('info', { 'Warehouse_AB.blue.Soganlug - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

              -- When the last detectionGroup of the group is declared dead, respawn the group.
              if detectionGroup:GetSize() == 1 then

                detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                logging('info', { 'Warehouse_AB.blue.Soganlug - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

              end

           end -- end function detectionGroup:OnEventDead( EventData )



          function detectionGroup:OnEventLand( EventData )

                   --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                   logging('info', { 'Warehouse_AB.blue.Soganlug - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                   -- When the last detectionGroup of the group is declared dead, respawn the group.
                   if detectionGroup:GetSize() == 1 then

                     detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                     logging('info', { 'Warehouse_AB.blue.Soganlug - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                     assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

                   end

          end -- end function detectionGroup:OnEventLand( EventData )
          ]]

           local casTemplateAirplane = { air_template_blue.CAS_AJS_37, air_template_blue.CAS_F_4E_Rocket, air_template_blue.CAS_F_5E_3_Rocket, air_template_blue.CAS_F_5E_3_Bomb, air_template_blue.CAS_F_5E_3_Cluster }
           local baiTemplate = { air_template_blue.BOM_AJS_37, air_template_blue.BOM_F_4_E_Sparse_Heavy, air_template_blue.BOM_F_4_E_Sparse_Cluster, air_template_blue.BOM_F_4_E_Sparse_Light}
           local seadTemplate = { air_template_blue.SEAD_AJS37, air_template_blue.SEAD_F_4E_H }

           if wh_activation.Warehouse_AB.blue.Soganlug[2] then

             local squadronName = "Soganlug CAS"
             A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Soganlug, casTemplateAirplane, 30 )

             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], nil, 0.3, 500, 700, 2000, 4000)

             -- PATROL CAS MISSION
             configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, redFrontZone.SATIHARI[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

           end

           -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
           if wh_activation.Warehouse_AB.blue.Soganlug[3] then

             squadronName = "Soganlug BAI"
             A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Soganlug, baiTemplate, 20 )
             configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

           end


           -- PATROL SEAD MISSION: invia attacchi in zona Patrol pronti ad intervenire se rilevata minaccia SAM
           if wh_activation.Warehouse_AB.blue.Soganlug[4] then

             squadronName = "Soganlug SEAD"
             A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Soganlug, seadTemplate, 20 )
             --configureAI_A2G_PATROL_SEAD_Mission( A2GDispatcher, squadronName, afacZone.Tskhunvali_Tkviavi[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')
             configureAI_A2G_SEAD_Mission( A2GDispatcher, squadronName, parAirbOp.sead[ 1 ], parAirbOp.sead[ 2 ], nil, 0.5, 700, 500, 2000, 3500)

           end

       end -- if wh_activation.Warehouse_AB.red.Soganlug







       -- A2G Kutaisi (Squadron F4, F5)

       if wh_activation.Warehouse_AB.blue.Kutaisi[1] then

           -- SPAWN DETECTION AIRCRAFT AT AIRBASE
           --[[
           local spawnDetectionGroup = SPAWN:New( air_template_blue.REC_F_4 )
           local airbase = AIRBASE:FindByName( AIRBASE.Caucasus.Kutaisi )
           local detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

           logging('info', { 'Warehouse_AB.blue.Kutaisi - activeAI_A2G_Dispatching_Blue' , 'airbase = ' .. airbase:GetName() .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

           assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

           logging('info', { 'Warehouse_AB.blue.Kutaisi - activeAI_A2G_Dispatching_Blue' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


           function detectionGroup:OnEventDead( EventData )

              --self:E( { "Size ", Size = detectionGroup:GetSize() } )
              logging('info', { 'Warehouse_AB.blue.Kutaisi - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

              -- When the last detectionGroup of the group is declared dead, respawn the group.
              if detectionGroup:GetSize() == 1 then

                detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                logging('info', { 'Warehouse_AB.blue.Kutaisi - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

              end

           end -- end function detectionGroup:OnEventDead( EventData )



           function detectionGroup:OnEventLand( EventData )

                   --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                   logging('info', { 'Warehouse_AB.blue.Kutaisi - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                   -- When the last detectionGroup of the group is declared dead, respawn the group.
                   if detectionGroup:GetSize() == 1 then

                     detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                     logging('info', { 'Warehouse_AB.blue.Kutaisi - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                     assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

                   end

           end -- end function detectionGroup:OnEventLand( EventData )
           ]]

           local casTemplateAirplane = { air_template_blue.CAS_L_39C_Rocket, air_template_blue.CAS_L_39ZA_HRocket, air_template_blue.CAS_F_5E_3_Bomb, air_template_blue.CAS_F_5E_3_Cluster, air_template_blue.BOM_F_4_E_Sparse_Light, air_template_blue.BOM_F_4_E_Sparse_Cluster, air_template_blue.CAS_F_5E_3_Bomb, air_template_blue.CAS_F_5E_3_Cluster }
           local baiTemplate = { air_template_blue.CAS_F_5E_3_Bomb, air_template_blue.BOM_F_4_E_Sparse_Heavy, air_template_blue.CAS_F_5E_3_Cluster, air_template_blue.BOM_F_4_E_Sparse_Light}
           local seadTemplate = { air_template_blue.SEAD_F_4E_L, air_template_blue.SEAD_F_4E_M, air_template_blue.SEAD_F_4E_H }


           if wh_activation.Warehouse_AB.blue.Kutaisi[2] then

             -- Set Defence Squadron
             local squadronName = "Kutaisi CAS"
             A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Kutaisi, casTemplateAirplane, 20 )

             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], nil, 0.3, 500, 700, 2000, 4000)

             -- PATROL CAS MISSION
             configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, redFrontZone.SATIHARI[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

           end


           -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
           if wh_activation.Warehouse_AB.blue.Kutaisi[3] then

             squadronName = "Kutaisi BAI"
             A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Kutaisi, baiTemplate, 20 )
             configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

           end


           -- PATROL SEAD MISSION: invia attacchi in zona Patrol pronti ad intervenire se rilevata minaccia SAM
           if wh_activation.Warehouse_AB.blue.Kutaisi[4] then

             squadronName = "Kutaisi SEAD"
             A2GDispatcher:SetSquadron( squadronName, AIRBASE.Caucasus.Kutaisi, seadTemplate, 20 )
             configureAI_A2G_PATROL_SEAD_Mission( A2GDispatcher, squadronName, afacZone.Tskhunvali_Tkviavi[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

           end


       end -- if wh_activation.Warehouse_AB.red.Kutaisi




       -- A2G Kvitiri (Squadron F5, L-39)

       if wh_activation.Warehouse_AB.blue.Kvitiri[1] then

           -- SPAWN DETECTION AIRCRAFT AT AIRBASE
           --[[
           local spawnDetectionGroup = SPAWN:New( air_template_blue.REC_L_39ZA )
           local airbase = warehouse.Kvitiri
           --spawnDetectionGroup:SpawnScheduled( 3600, 0.3 )
           --spawnDetectionGroup:InitCleanUp(600)

           --local detectionGroup = spawnDetectionGroup:SpawnFromVec2(airbase:GetCoordinate():GetVec2(), 1000)
           local detectionGroup = spawnDetectionGroup:SpawnFromStatic(staticObject.Warehouse_AB.blue.Kvitiri[1])

           logging('info', { 'Warehouse_AB.blue.Kvitiri - activeAI_A2G_Dispatching_Red' , 'airbase = ' .. airbase.alias .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

           assignDetectionGroupTask(detectionGroup, afacZone.Didmukha_Tsveri[ 1 ], airbase, 4000, 2000, 0.5 )

           logging('info', { 'Warehouse_AB.blue.Kvitiri - activeAI_A2G_Dispatching_Blue' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


           function detectionGroup:OnEventDead( EventData )

              --self:E( { "Size ", Size = detectionGroup:GetSize() } )
              logging('info', { 'Warehouse_AB.blue.Kvitiri - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

              -- When the last detectionGroup of the group is declared dead, respawn the group.
              if detectionGroup:GetSize() == 1 then

                detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                logging('info', { 'Warehouse_AB.blue.Kvitiri - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                detectionGroup:StartUncontrolled()
                detectionGroup:OptionROTPassiveDefense()
                detectionGroup:Route(WayPoints)

              end

           end -- end function detectionGroup:OnEventDead( EventData )



           function detectionGroup:OnEventLand( EventData )

                   --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                   logging('info', { 'Warehouse_AB.blue.Kvitiri - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                   -- When the last detectionGroup of the group is declared dead, respawn the group.
                   if detectionGroup:GetSize() == 1 then

                     detectionGroup = spawnDetectionGroup:SpawnAtAirbase(airbase, SPAWN.Takeoff.Cold)

                     logging('info', { 'Warehouse_AB.blue.Kvitiri - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                     detectionGroup:StartUncontrolled()
                     detectionGroup:OptionROTPassiveDefense()
                     detectionGroup:Route(WayPoints)

                   end

           end -- end function detectionGroup:OnEventLand( EventData )
           ]]

           --local casTemplateAirplane = { air_template_blue.CAS_L_39C_Rocket, air_template_blue.CAS_L_39ZA_HRocket, air_template_blue.CAS_F_5E_3_Bomb, air_template_blue.CAS_F_5E_3_Cluster }
           local casTemplate = { air_template_blue.CAS_UH_1H, air_template_blue.CAS_SA_342, air_template_blue.CAS_Antitank_SA_342, air_template_blue.CAS_Mistral_SA_342 }
           local baiTemplate = { air_template_blue.BOM_Mi_8MTV2 }
           local seadTemplate = { air_template_blue.CAS_Mistral_SA_342 }

           if wh_activation.Warehouse_AB.blue.Kvitiri[2] then

             local squadronName = "Kvitiri CAS"
             A2GDispatcher:SetSquadron( squadronName, staticObject.Farp.blue.Kvitiri[1]:GetName(), casTemplate, 20 ) --FARP Kvitiri

             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
              configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], nil, 0.3, 500, 700, 2000, 4000)

              -- PATROL CAS MISSION
              --configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, redFrontZone.SATIHARI[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')

            end



           -- BAI MISSION: invia attacchi se rilevate minaccia nel territorio nemico
           if wh_activation.Warehouse_AB.blue.Kvitiri[3] then

             squadronName = "Kvitiri BAI"
             A2GDispatcher:SetSquadron( squadronName, staticObject.Farp.blue.Kvitiri[1]:GetName(), baiTemplate, 20 ) --FARP Kvitiri
             configureAI_A2G_BAI_Mission( A2GDispatcher, squadronName, parAirbOp.bai[ 1 ], parAirbOp.bai[ 2 ], nil, 0.5, 500, 700, 3000, 5000)

           end


           -- PATROL SEAD MISSION: invia attacchi in zona Patrol pronti ad intervenire se rilevata minaccia SAM
           if wh_activation.Warehouse_AB.blue.Kvitiri[4] then

             squadronName = "Kvitiri SEAD"
             A2GDispatcher:SetSquadron( squadronName, staticObject.Farp.blue.Kvitiri[1]:GetName(), seadTemplate, 20 ) --FARP Kvitiri
             --configureAI_A2G_PATROL_SEAD_Mission( A2GDispatcher, squadronName, afacZone.Tskhunvali_Tkviavi[1], 1, 2000, 3500, 400, 600, 500, 700, 'RADIO')
             configureAI_A2G_SEAD_Mission( A2GDispatcher, squadronName, parAirbOp.sead[ 1 ], parAirbOp.sead[ 2 ], nil, 0.5, 700, 500, 2000, 3500)

           end


       end -- if wh_activation.Warehouse_AB.red.Kvitiri




       -- A2G Kvitiri_Helo

       if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[1] then

           -- SPAWN DETECTION AIRCRAFT AT AIRBASE

           local spawnDetectionGroup = SPAWN:New( air_template_blue.AFAC_UH_1H )
           local airbase = warehouse.Kvitiri_Helo
           local detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.blue.Kvitiri_Helo[1] )

           logging('info', { 'Warehouse_AB.blue.Kvitiri_Helo - activeAI_A2G_Dispatching' , 'airbase = ' .. airbase.alias .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

           assignDetectionGroupTask(detectionGroup, redFrontZone.CZ_PEREVI[ 1 ], airbase, 1000, 700, 0.5 )

           logging('info', { 'Warehouse_AB.blue.Kvitiri_Helo - activeAI_A2G_Dispatching' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


           function detectionGroup:OnEventDead( EventData )

              --self:E( { "Size ", Size = detectionGroup:GetSize() } )
              logging('info', { 'Warehouse_AB.blue.Kvitiri_Helo - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

              -- When the last detectionGroup of the group is declared dead, respawn the group.
              if detectionGroup:GetSize() == 1 then

                detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.blue.Kvitiri_Helo[1] )

                logging('info', { 'Warehouse_AB.blue.Kvitiri_Helo - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                assignDetectionGroupTask(detectionGroup, redFrontZone.CZ_PEREVI[ 1 ], airbase, 1000, 700, 0.5 )

              end

           end -- end function detectionGroup:OnEventDead( EventData )



           function detectionGroup:OnEventLand( EventData )

                   --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                   logging('info', { 'Warehouse_AB.blue.Kvitiri_Helo - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                   -- When the last detectionGroup of the group is declared dead, respawn the group.
                   if detectionGroup:GetSize() == 1 then

                     detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.blue.Kvitiri_Helo[1] )

                     logging('info', { 'Warehouse_AB.blue.Kvitiri_Helo - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                     assignDetectionGroupTask(detectionGroup, redFrontZone.CZ_PEREVI[ 1 ], airbase, 1000, 700, 0.5 )

                   end

           end -- end function detectionGroup:OnEventLand( EventData )

           local casTemplate = { air_template_blue.CAS_UH_1H, air_template_blue.CAS_SA_342, air_template_blue.CAS_Antitank_SA_342, air_template_blue.CAS_Mistral_SA_342, air_template_blue.BOM_Mi_8MTV2 }

           if wh_activation.Warehouse_AB.blue.Kvitiri_Helo[2] then

             local squadronName = "Kvitiri_Helo CAS"
             -- CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             A2GDispatcher:SetSquadron( squadronName, staticObject.Farp.blue.Kvitiri_Helo[1]:GetName(), casTemplate, 50 ) -- FARP Kvitiri Helo
             configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], 60 * 4, 0.3, 200, 300, 700, 1500)


             -- PATROL CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             --configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, afacZone.Sathiari_Tkviavi[1], 1, 300, 700, 200, 300, 200, 300, 'RADIO')

           end

       end -- if wh_activation.Warehouse_AB.red.Kvitiri_Helo






       -- A2G GORI

       if wh_activation.Warehouse.blue.Gori[1] then

           -- SPAWN DETECTION AIRCRAFT AT AIRBASE

           local spawnDetectionGroup = SPAWN:New( air_template_blue.AFAC_UH_1H )
           local detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.blue.Gori[1] )
           local airbase = warehouse.Gori

           logging('info', { 'Warehouse.blue.Gori - activeAI_A2G_Dispatching' , 'airbase = ' .. airbase.alias .. 'name detectionGroup = ' .. detectionGroup:GetName() } )

           assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 1000, 700, 0.5 )

           logging('info', { 'Warehouse.blue.Gori - activeAI_A2G_Dispatching' , 'add detectionGroup = ' .. detectionGroup:GetName() .. ' in ' .. detectionGroupSetRed:GetObjectNames() .. ' - NOW PRINT ELEMENT OF SET' } )


           function detectionGroup:OnEventDead( EventData )

              --self:E( { "Size ", Size = detectionGroup:GetSize() } )
              logging('info', { 'Warehouse.blue.Gori - detectionGroup:OnEventDead( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

              -- When the last detectionGroup of the group is declared dead, respawn the group.
              if detectionGroup:GetSize() == 1 then

                detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.blue.Gori[1] )

                logging('info', { 'Warehouse.blue.Gori - detectionGroup:OnEventDead( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 1000, 700, 0.5 )

              end

           end -- end function detectionGroup:OnEventDead( EventData )


           function detectionGroup:OnEventLand( EventData )

                   --self:E( { "Size ", Size = detectionGroup:GetSize() } )
                   logging('info', { 'Warehouse.blue.Gori - detectionGroup:OnEventLand( EventData )' , 'detectionGroup:GetSize() = ' .. detectionGroup:GetSize() } )

                   -- When the last detectionGroup of the group is declared dead, respawn the group.
                   if detectionGroup:GetSize() == 1 then

                     detectionGroup = spawnDetectionGroup:SpawnFromStatic( staticObject.Farp.blue.Gori[1] )

                     logging('info', { 'Warehouse.blue.Gori - detectionGroup:OnEventLand( EventData )' , 'name detectionGroup = ' .. detectionGroup:GetName() } )

                     assignDetectionGroupTask(detectionGroup, afacZone.Tskhunvali_Tkviavi[ 1 ], airbase, 1000, 700, 0.5 )

                   end

           end -- end function detectionGroup:OnEventLand( EventData )

           local casTemplateHeli = { air_template_blue.CAS_UH_1H, air_template_blue.CAS_SA_342, air_template_blue.CAS_Antitank_SA_342, CAS_Mistral_SA_342, air_template_blue.BOM_Mi_8MTV2 }


           if wh_activation.Warehouse.blue.Gori[2] then

             local squadronName = "Gori CAS"
             A2GDispatcher:SetSquadron( squadronName, staticObject.Farp.blue.Gori[1]:GetName(), casTemplateHeli, 20 ) -- FARP GORI
             configureAI_A2G_CAS_Mission( A2GDispatcher, squadronName, parAirbOp.cas[ 1 ], parAirbOp.cas[ 2 ], 60 * 4, 0.3, 200, 300, 700, 1500)

             -- PATROL CAS MISSION: invia attacchi se rilevata minaccia a ground amiche
             configureAI_A2G_PATROL_CAS_Mission( A2GDispatcher, squadronName, afacZone.Sathiari_Tkviavi[1], 1, 300, 700, 200, 300, 200, 300, 'RADIO')

           end

       end -- if wh_activation.Warehouse_AB.red.Gori


    end -- if activeAI_A2G_Dispatching_HQ1



  end -- if activeAI_A2G_Dispatching_Blue



  ------------------------------------------------------------------------   AI A2G Dispatching ---------------------------------------------------------------























  ------------------------------------------- CIVILIAN AIR TRAFFIC ------------------------------------------------------------------------------------------------------------------------------

  -- RAT (Random Air Traffic) OK

  -- Name: RAT-005 - Restricted Coalition
  -- Author: funkyfranky
  -- Date Created: 24 Sep 2017
  --
  -- # Situation:
  --
  -- Spawn several aircraft of the same type at airports belonging to a certain coalition.
  -- In the mission editor, we have set Sochi-Adler, Gelendzhik, Batumi, Senaki-Kolkhi and Kutaisi to red.
  -- Likewise, Tbilisi-Lochini, Beslan, Nalchik, Mozdok and Mineralnye-Vody were set to blue.
  --
  -- # Test cases:
  --
  -- 1. Observe three Yak-40 aircraft being spawned at red airports only. The will also only get destination airports belonging to that coalition.
  -- 2. Observe three Yak-40 being spawned at blue airports only. The coalition of the aircraft is changed manually.


  ---   airbase   table
  --
  --    AIRBASE.Caucasus.Gelendzhik
  --    AIRBASE.Caucasus.Krasnodar_Pashkovsky
  --    AIRBASE.Caucasus.Sukhumi_Babushara
  --    AIRBASE.Caucasus.Gudauta
  --    AIRBASE.Caucasus.Batumi
  --    AIRBASE.Caucasus.Senaki_Kolkhi
  --    AIRBASE.Caucasus.Kobuleti
  --    AIRBASE.Caucasus.Kutaisi
  --    AIRBASE.Caucasus.Tbilisi_Lochini
  --    AIRBASE.Caucasus.Soganlug
  --    AIRBASE.Caucasus.Vaziani
  --    AIRBASE.Caucasus.Anapa_Vityazevo
  --    AIRBASE.Caucasus.Krasnodar_Center
  --    AIRBASE.Caucasus.Novorossiysk
  --    AIRBASE.Caucasus.Krymsk
  --    AIRBASE.Caucasus.Maykop_Khanskaya
  --    AIRBASE.Caucasus.Sochi_Adler
  --    AIRBASE.Caucasus.Mineralnye_Vody
  --    AIRBASE.Caucasus.Nalchik
  --    AIRBASE.Caucasus.Mozdok
  --    AIRBASE.Caucasus.Beslan




  local interval_civ_sched = 1800
  local start_civ_sched = 10
  local rand_civ_sched = 0.30



  ------------------------------------------- RED CIVILIAN AIR TRAFFIC ------------------------------------------------------------------------------------------------------------------------------

  local red_civilian_traffic = false

  if red_civilian_traffic then

    local civilian_aircraft = {

      air_template_red.TRAN_AN_26,
      air_template_red.TRAN_YAK_40,
      --air_template_red.TRAN_MI_26

    }

    -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
    local red_civilian_traffic_sched = SCHEDULER:New( nil,

        function()

          -- Create RAT object. Additionally, to the template group name we give the group an alias to be able to distinguish to another group created from this template.
          local civ_transport = RAT:New( civilian_aircraft[ math.random( 1, #civilian_aircraft ) ], "red civilian transport" )

          -- Change coalition of Antonof to red.
          civ_transport:SetCoalitionAircraft("red")


          -- This restricts the possible departure and destination airports the airports belonging to the red coalition.
          -- Here it is important that in the mission editor enough (>2) airports have been set to red! Otherwise there will be no possible departure and/or destination airports.
          civ_transport:SetCoalition("sameonly")

          -- Explicitly exclude Senaki from possible departures and destinations.
          civ_transport:ExcludedAirports("Nalchik", "Beslan", "Nalchik", "Mineralnye_Vody")

          -- Spawn from 1 to 4 aircraft.
          civ_transport:Spawn(math.random(1, 4))

          logging('info', { 'main' , 'blue_civilian_traffic_sched SCHEDULER - start time:' .. start_civ_sched .. ' ; scheduling time: ' .. interval_civ_sched * ( 1 - rand_civ_sched ) } )

        end, {}, start_civ_sched, interval_civ_sched, rand_civ_sched

    ) -- end  scheduler

  end -- end if red_civilian_traffic

  ------------------------------------------- END RED CIVILIAN AIR TRAFFIC ------------------------------------------------------------------------------------------------------------------------------































  ------------------------------------------- BLUE CIVILIAN AIR TRAFFIC ------------------------------------------------------------------------------------------------------------------------------



  if blue_civilian_traffic then

    local civilian_aircraft = {

      air_template_blue.TRAN_AN_26,
      air_template_blue.TRAN_YAK_40,
      --air_template_blue.TRAN_UH_60A,
      --air_template_blue.TRAN_CH_47,
      air_template_blue.TRAN_C_130

    }

    -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
    local blue_civilian_traffic_sched = SCHEDULER:New( nil,

        function()

          -- Create RAT object. Alias is "Yak Blue". If the same template is used multiple times, it is important to give each RAT object an indiviual name!
          local civ_transport=RAT:New(civilian_aircraft[math.random(1, #civilian_aircraft)], "blue civilian transport")

          -- Change coalition of Yak to blue.
          civ_transport:SetCoalitionAircraft("blue")

          -- This restricts the possible departure and destination airports the airports belonging to the blue coalition since the coalition is changed manually.
          civ_transport:SetCoalition("sameonly")

          -- We also change the livery of these groups. If a table of liveries is given, each spawned group gets a random livery.
          civ_transport:Livery({"Georgian Airlines"})

          -- Explicitly exclude Nalchik from possible departures and destinations.
          civ_transport:ExcludedAirports({"Kutaisi", "Gudauta", "Sochi-Adler"})



            -- Spawn from 1 to 4 aircraft.
            civ_transport:Spawn(math.random(1, 4))

           logging('info', { 'main' , 'blue_civilian_traffic_sched SCHEDULER - start time:' .. start_civ_sched .. ' ; scheduling time: ' .. interval_civ_sched * ( 1 - rand_civ_sched ) } )

        end, {}, start_civ_sched, interval_civ_sched, rand_civ_sched

    ) -- end  scheduler

  end -- end if

  ------------------------------------------- END BLUE CIVILIAN AIR TRAFFIC ------------------------------------------------------------------------------------------------------------------------------













end -- end if conflictZone == 'Zone 1: South Ossetia' then
