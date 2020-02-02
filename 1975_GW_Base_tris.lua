
--[[


1975 Georgian War


oggetto:    lua script file dedicato alla realizzazione di un server DCS in cui è attiva una campagna dinamica.



autor: Marco Bellafante

stato:   sviluppo

branch: ristrutturazione farp






note sviluppo:

sono disabilitate diverse warehouse
sono disabilitate diverse request x didi, batumi, kutaisi, tbilisi e GORI
sono disabilitati i voli civili
disabilitato l'airbalancer


30.1.2020:
Fai un test abilitando solo AI_DISPATCH_CARGO, RECON e AWACS




26.1.2020:
- organizzare il task AWACS in modo che effettui un task orbit di durata definita ad una determinata altezza
- Recon @ batumi non partono
- i cargoHeli e Plane decollano ma orbitano intorno alla airbase e poiu atterrano: rivedere funzioni di pickup, deploy, load ecc.






commentate le addRequest di Tbilisi, Gori, Batumi (da decommentare)
ridotti i tempi di gestione dei  warehouse SCHEDULER



5.1.2020:  assegnare un nome ai gruppi aerei/ground per poter essere utilizzati per info, come detection (awacs) e come targets
 vedere come la detection agisce nella AI.AI.A2A per utilizzarla nelle patrol da warehouse e/o nel balancer


23.12.2019

la funzione OnAfterDelivered(From,Event,To,request) per tutte le WH puo' essere eliminata: lo scheduler si occupa del rinvio degli asset
Aggiornare il codice nelle funzioni OnAfterSelfRequest, OnAfterAssetDead come per le _addRequest



30.5.19:

in activeGO_TO_ZONE_GROUND modificare il parametro battlezone in toCoord in qnuanto queste sono rilevate nella activeGO_TO_ZONE_GROUND
in  ArtyPositionAndFireAtTarget inserire e gestire i parametri moveCoordinate, speed e onroad e  e modificare le chiamate a questa funzione prima in activeGO_TO_ZONE_GROUND
dopo verificato il funziomanento inserirla solo in activeGO_TO_ARTY


in tutte le warehouse c'e un gruppo sconosciuto



NOTA: il file dcs.log in C:\Users\marco\Saved Games\DCS.openbeta\Logs aggiunge in coda tutti gli eventi di una sessione DCS: se non viene chiuso DCS
      i log di diverse missioni vengono accodati, guarda l'orario degli eventi per distinguerli tra le diverse missioni.

definisci in ME tutti i template relativi alle unit� da utilizzare: Aircraft, Veichle, Ship, ecc. utilizzando la nomenclatura definita in Moose:

per Aircraft:
name, pilot: = SQ <coalition> <role> <aircraft>
<role> : = GCI , CAP_Long, CAP_Medium, ATTACK_1, ... ecc..
<aircraft> := SU-27, ....
<coalition> := red, blue

per Veichle:

warhouse:


verifica se in runtime riesci ad interrogare il database di DCS sugli aerei:

mediante il nome dell'unita' template es: nome = 'SQ red CAP Mig_23MLD', unit.findByName(name), name_missile = unit.getDescr.getMissile.name, out_info(name_missile)





 LOAD MISSION LOG FILE:

    filename = 'F:\\Programmi\\luaDevTool\\workspace\\Test_Moose_Missions\\My Mission\\moose.lua'
    dofile(filename) se il file e' in lua come credo che sia (mission.lua)


 PARSING MISSION LOG FILE:

   airbase avalaible, airbase_aircraft_avalaible,

   valutare la possibilita' di duplicare il file log di missione salvandolo con un nome specifico per l'utilizzo nella missione


   analisi:

   - valutazione perdite in relazione al contingente militare (*) di riferimento per la zona




 (*): il contingente militare e' costituito da tutte le unita'/gruppi (tactical_group) che agiscono in una determinata zona tattica (tactical_zone) (**)

 (**): la zona tattica puo' essere rappresentata mediante una trigger zone. Il "fronte" puo' essere rappresentato da zone tattiche riposizionabili in runtime (?).
 NOTA: l'eventuale aggiornamento della situazione puo' essere effettuato in runtime (come nei server multiplayer) in modo da realizzare una situazione dinamica.
 La chiusura della missione comporterebbe solo il salvataggio dello stato attuale.





  per spawning:

https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Core.Spawn.html
https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master/SPA%20-%20Spawning


-- La detection non dovrebbe essere modificato in quanto serve solo ad associare al sistema di rilevamento tutte le unita' di rilevameno con nome conforme al prefix_detector.

-- La posizione delle detector units (EWR) puo' eventualmente essere cambiata in base alla evoluzione della situazione.

-- Il dispatcher potrebbe essere modificato in base alla situazione: il gci_radius potrebbe essere ridotto cosi come l'engage radius.

-- assign_squadron_at_airbase viene modificato in base alla situazione: gli squadroni assegnati alla specifica airbase e il numero di aerei disponibili.

-- assign_gci viene modificato in base alla situazione definendo le missioni GCI in base alle zone tattiche relative alle basi aeree e alle zone strategiche definite.

-- assign_cap viene modificato in base alla situazione definendo le missioni CAP in base alle zone tattiche definite.




  GRUPPO TATTICO TERRESTRE
  tactical_ground_group: tabella contenente l'elenco dei gruppi tattici con definita per ciascuna unita' la posizione (vect3d?) e . Il gruppo tattico ha una warhouse contenente
  i rifornimenti per le unita'. Al gruppo tattico e' associato il morale (che incidera' negli skill di combattimento), la tactical_zone dove agisce, la categoria di appartenenza
  (artiglieria, fanteria(meccanizzata), corazzati, Air defence ecc.).

  ZONA TATTICA TERRESTRE
  tactical_ground_zone: tabella contenente la posizione delle trigger zone (vect3d?)

  GRUPPO TATTICO AEREO

  ZONA TATTICA AEREA




]]--


-- variable
--- loggingLevel
-- 0 = nessun messaggio di log, 1 = error, 2 = severe, 3 = warning, 4 = info, 5 = fine, 6 = finer/enter/exit, 7 = finest
local loggingLevel = 7


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



-- END UTILITY FUNCTION






















------------------------------------------------------------------------------    MISSION FUNCTIONS  -------------------------------------------------------------------------
-- Mission's use functions




--- DETECTION


-- detectionAREAS

--- Create a detection zone based on a group of detector units.
--  The detector group is created utilizing detector units with name formed with prefix_detector.
--
--
-- @param detectionSetGroup: set of detection GROUP
-- @param range:  range max of detection target
-- @param filterCategories: set of filter for of unit: nil all category will be detected
-- @param distanceProbability:  probability of detection @ 10000 m (0 - 1)
-- @param alfaProbability:  probability of detection @ 0 degree of delta respect front visual detection (0 - 1)
-- @param zoneProbability: array of a The ZONE_BASE object and a ZoneProbability pair..: ex: { { Zone1, 0.1 }, { Zone2, 0.1 } }
-- @param typeDetection: set of sensor detector: nil for all sensor activation (visual, radar, optical, irst, rwr, dlink)
-- @return DETECTION_AREAS
-- function detection( prefix_detector, range, categories, distanceProbability, alphaProbability, zoneProbability, typeDetection )
function detectionAREAS( detectionSetGroup, range, filterCategories, distanceProbability, alphaProbability, zoneProbability, typeDetection )

    local debug = true

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

  local debug = true

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







--  Detection dedicata alla AI_A2A
--  molto probabilmente i gruppi di detection devono essere già attivi in ME
--
function detectionAI_A2A(prefix_detector, range, filterCategories, distanceProbability, alphaProbability, zoneProbability, typeDetection )

    local debug = true

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

    local debug = true

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



    --activeGO_TO_ZONE_AIR( awacsSetGroup, battleZone, 1 )
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

    --- OnAfter Transition Handler for Event Detect.
    -- @param Functional.Detection#DETECTION_UNITS self
    -- @param #string From The From State string.
    -- @param #string Event The Event string.
    -- @param #string To The To State string.
    function AwacsDetection:OnAfterDetect(From,Event,To)

      if debug then logging('finest', { 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )' , 'AWACS: Detect!' } ) end

      local DetectionReport = AwacsDetection:DetectedReportDetailed()

      commandCenter:MessageToAll( DetectionReport, 15, "AWACS: Detect!" )

    end-- end function AwacsDetection:OnAfterDetect(From,Event,To)


    if debug then logging('exit', 'activeAWACS( awacsSetGroup, commandCenter, rejectedZone )') end

end -- end function activeAWACS( awacsSetGroup, commandCenter )



--- Gestisce le missioni JTAC
-- fornisce un sistema di rilevamento complementare alla detection utulizzazta in AI.A2A
-- controllo delle azioni aeree a supporto della manovra terrestre
-- @param awacsGroup: il gruppo generato dalla warehouse che effettua l'awacs
-- @param hq: l'HQ
function activeJTAC( type, home, jtacSetGroup, commandCenter, rejectedZone, battleZone)

    local debug = true

    if debug then logging('enter', 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )') end

    if jtacSetGroup == nil then logging('warning', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'jyacSetGroup is nil. Exit' } ) return nil end

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


    elseif type =='air' then --activeGO_TO_ZONE_AIR( jtacSetGroup, battleZone, 1 )

      local altitude = math.random(300, 1000)
      ToCoord:SetAltitude(altitude)
      HomeCoord:SetAltitude(1000)


      for _, _group in pairs(jtacSetGroup:GetSet()) do

            local group = _group --Wrapper.Group#GROUP

            -- Start uncontrolled aircraft.
            group:StartUncontrolled()

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

    --- OnAfter Transition Handler for Event Detect.
    -- @param Functional.Detection#DETECTION_UNITS self
    -- @param #string From The From State string.
    -- @param #string Event The Event string.
    -- @param #string To The To State string.
    function RecceDetection:OnAfterDetect(From,Event,To)

      if debug then logging('finest', { 'activeJTAC( type, jtacSetGroup, commandCenter, rejectedZone )' , 'JTAC: Detect!' } ) end

      local DetectionReport = RecceDetection:DetectedReportDetailed()

      commandCenter:MessageToAll( DetectionReport, 15, "JTAC: Detect!" )

    end-- end function RecceDetection:OnAfterDetect(From,Event,To)



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





-- DISPATCHER

-- Il dispatcher potrebbe essere modificato in base alla situazione: il gci_radius potrebbe essere ridotto cosi come l'engage radius.


--- Create a dispatcher.
--  The dispatcher offer detection service (info on intruder e flight situation) for CAP and GCI mission.
--
-- @param detection:  DETECTION_AREAS
-- @param gci_radius:  The radius to ground control intercept detected targets from the nearest airbase
-- @param engage_radius:  Initialize the dispatcher, setting up a radius of 50km where any airborne friendly without an assignment within 50km radius from a detected target, will engage that target.
-- @param view_tactical_display:  (true/false) Visualize tactical display
-- @return AI_A2A_DISPATCHER
function dispatcher( detection, gci_radius, engage_radius, view_tactical_display )

  -- A2ADispatcher:
  A2ADispatcher = AI_A2A_DISPATCHER:New( detection )

  -- default setup for dispatcher
  -- A2ADispatcher.SetDefaultTakeoffFromParkingCold()

  -- Set the ground intercept radius as the radius to ground control intercept detected targets from the nearest airbase.
  A2ADispatcher:SetGciRadius( gci_radius )

  -- Initialize the dispatcher, setting up a radius of 50km where any airborne friendly without an assignment within 50km radius from a detected target, will engage that target.
  A2ADispatcher:SetEngageRadius( engage_radius )

  A2ADispatcher:SetTacticalDisplay( view_tactical_display )

  return A2ADispatcher

end


-- ASSIGN SQUADRON AT AIRBASE

-- assign_squadron_at_airbase viene modificato in base alla situazione: gli squadroni assegnati alla specifica airbase e il numero di aerei disponibili

--- Setting up and assign an air squadron at airbase.
--
--
--
--  @param airbase_name:  airbase name
--  @param airbase:  AIRBASE
--  @param squadron_name:  specific air template name created in ME
--  @param no_aircraft:  number of aircraft assigned at airbase
--  @param A2ADispatcher:  AI_A2A_DISPATCHER
function assign_squadron_at_airbase ( airbase_name, airbase, squadron_name, no_aircraft, A2ADispatcher )

  A2ADispatcher:SetSquadron( airbase_name, airbase, squadron_name, no_aircraft )

end


-- ASSIGN CAP

--  assign_cap viene modificato in base alla situazione definendo le missioni CAP in base alle zone tattiche definite.

--- Setting up and authorize CAP mission for Squadron assigned at specific airbase.
--
--
--  @param cap_zone:  specific cap zone name created in ME
--  @param airbase_name:  airbase name
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
function assign_cap ( cap_zone, airbase_name, alt_min, alt_max, speed_min_patrol, speed_max_patrol,
                      speed_min_engage, speed_max_engage, num_cap_squad, min_time_new_cap, max_time_new_cap,
                      probability, take_off, landing, A2ADispatcher )

  local zone = ZONE_POLYGON:New( cap_zone, GROUP:FindByName( cap_zone ) )
  A2ADispatcher:SetSquadronCap( airbase_name, zone, alt_min, alt_max, speed_min_patrol, speed_max_patrol, speed_min_engage, speed_max_engage )
  A2ADispatcher:SetSquadronCapInterval( airbase_name, num_cap_squad, min_time_new_cap, max_time_new_cap, probability )
  A2ADispatcher:SetSquadronTakeoff( airbase_name, take_off )
  A2ADispatcher:SetSquadronLanding( airbase_name, landing )


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




--- funzione per spawn gruppi generici
--
-- @param route = 'Georgian Reco Flight@Tskhinvali' -- name del percorso definito dal Ka50
-- @param max_contemp_units = 15 -- limite massimo delle unita' attivabili contemporaneamente
-- @param max_contemp_groups = 40 -- limite massimo dei gruppi attivabili contemporaneamente
-- @param templateList = Spawn_GE_Recognition_Flight  -- tabella dei template per la scelta casuale del template da utilizzare
-- @param route_wp_start = 1  -- variazione random della rotta: posizione del wp iniziale
-- @param route_wp_end = 1  -- variazione random della rotta: posizione del wp finale partendo dall'ultimo wp
-- @param route_range = 2000  -- variazione random della rotta: variazione possibile per i wp compresi tra il wp l'iniziale e il wp finale
-- @param route_altitud = 3000  -- variazione random della rotta: altezza da aggiungere a quella prevista
-- @param scheduled_time = 1200
-- @param scheduled_var = 0.5
-- @param angle = 349
-- @param ngroup_on_x = 30
-- @param distance_groups_on_x = 20
-- @param distance_groups_on_y = 6 * 20
--
function genericSpawn(route, max_contemp_units, max_contemp_groups, templateList, route_wp_start, route_wp_end, route_range, route_altitud, scheduled_time, scheduled_var, angle, ngroup_on_x, distance_groups_on_x, distance_groups_on_y)

  local spawn_object = SPAWN
  :New( route )  -- name del percorso definito dal Ka50
  :InitLimit( max_contemp_units, max_contemp_groups ) -- limiti massimi sul numero delle unita' e dei gruppi attivabili contemporaneamente
  :InitRandomizeTemplate( templateList ) -- scegli a caso dalla tabella dei template delle  troops di sopra
  :InitRandomizeRoute( route_wp_start, route_wp_end, route_range, route_altitud ) -- variazione random della rotta: wp iniziale, posizione del wp finale partendo dall'ultimo wp, variazione in m possibile, altezza da aggiungere a quella prevista
  :InitArray( angle, ngroup_on_x, distance_groups_on_x, distance_groups_on_y ) -- visualizza i gruppi prima dello spawn: The angle in degrees how the groups and each unit of the group will be positioned, num groups on x, spazio tra groups on x, spazio tra groups on y,
  :SpawnScheduled( scheduled_time, scheduled_var )  -- lo spawn e' schedulato per avvenire ogni 60 secondi con una variazione x% calcolata come time*(1-x%/2) - time*(1+x%/2):  600-1800 s

  return spawn_object

end


--- funzione per spawn gruppi generici
-- non e' presente l'initArray
--
-- @param route = 'Georgian Reco Flight@Tskhinvali' -- name del percorso definito dal Ka50
-- @param max_contemp_units = 15 -- limite massimo delle unita' attivabili contemporaneamente
-- @param max_contemp_groups = 40 -- limite massimo dei gruppi attivabili contemporaneamente
-- @param templateList = Spawn_GE_Recognition_Flight  -- tabella dei template per la scelta casuale del template da utilizzare
-- @param route_wp_start = 1  -- variazione random della rotta: posizione del wp iniziale
-- @param route_wp_end = 1  -- variazione random della rotta: posizione del wp finale partendo dall'ultimo wp
-- @param route_range = 2000  -- variazione random della rotta: variazione possibile per i wp compresi tra il wp l'iniziale e il wp finale
-- @param route_altitud = 3000  -- variazione random della rotta: altezza da aggiungere a quella prevista
-- @param scheduled_time = 1200
-- @param scheduled_var = 0.5

function genericSpawnSimple(route, max_contemp_units, max_contemp_groups, templateList, route_wp_start, route_wp_end, route_range, route_altitud, scheduled_time, scheduled_var)

  local spawn_object = SPAWN
  :New( route )  -- name del percorso definito dal Ka50
  :InitLimit( max_contemp_units, max_contemp_groups ) -- limiti massimi sul numero delle unita' e dei gruppi attivabili contemporaneamente
  :InitRandomizeTemplate( templateList ) -- scegli a caso dalla tabella dei template delle  troops di sopra
  :InitRandomizeRoute( route_wp_start, route_wp_end, route_range, route_altitud ) -- variazione random della rotta: wp iniziale, posizione del wp finale partendo dall'ultimo wp, variazione in m possibile, altezza da aggiungere a quella prevista
  :SpawnScheduled( scheduled_time, scheduled_var )  -- lo spawn e' schedulato per avvenire ogni 60 secondi con una variazione x% calcolata come time*(1-x%/2) - time*(1+x%/2):  600-1800 s

  return spawn_object

end





--- funzione per spawn gruppi generici
-- non e' presente l'initArray
--  DEPRECATED
-- @param route = 'Georgian Reco Flight@Tskhinvali' -- name del percorso definito dal Ka50
-- @param max_contemp_units = 15 -- limite massimo delle unita' attivabili contemporaneamente
-- @param max_contemp_groups = 40 -- limite massimo dei gruppi attivabili contemporaneamente
-- @param templateList = Spawn_GE_Recognition_Flight  -- tabella dei template per la scelta casuale del template da utilizzare
-- @param route_wp_start = 1  -- variazione random della rotta: posizione del wp iniziale
-- @param route_wp_end = 1  -- variazione random della rotta: posizione del wp finale partendo dall'ultimo wp
-- @param route_range = 2000  -- variazione random della rotta: variazione possibile per i wp compresi tra il wp l'iniziale e il wp finale
-- @param route_altitud = 3000  -- variazione random della rotta: altezza da aggiungere a quella prevista
-- @param scheduled_time = 1200
-- @param scheduled_var = 0.5
-- @param patrolNameZone = ("DIDMUKHA") il nome della zona di pattugliamento (l'aereo permane in questa zona in attesa che scada il timeOfEngage)
-- @param casNameZone = ("TSVERI") il nome della zona di ricerca target
-- @param timeOfEngage = timer per l'ordine di ingaggio
-- @param timeOfStopEngage = timer di conclusione d'ingaggio
-- @param engageSpeed = velocita'  d'ingaggio
-- @param engageAltitude = quota d'ingaggio
-- @param nameOfTarget = ("USA ARMOR SQUAD") il nome del gruppo target
-- @param targetNumToAccomplish = quantita di target da distruggere per ottenere l'accomplish
-- @param startMission = (1) timer di inizio missione
--
function createCASMission(route, max_contemp_units, max_contemp_groups, templateList, route_wp_start, route_wp_end, route_range, route_altitud, scheduled_time, scheduled_var, patrolNameZone, patrolSpeedMin, patrolMaxSPeed, minAltitude, maxAltitude, casNameZone, timeOfEngage, timeOfStopEngage, engageSpeed, engageAltitude, nameOfTarget, targetNumToAccomplish, startMission)


      local Spawn_CAS_Aircraft  = genericSpawnSimple(route, max_contemp_units, max_contemp_groups, templateList, route_wp_start, route_wp_end, route_range, route_altitud, scheduled_time, scheduled_var)

      local CASPlane = GROUP:FindByName( route )

      -- Create patrol zone
      local PatrolZonePlanes = ZONE:New( patrolNameZone )

     -- Create engage zone
      local CASEngagementTkviavi = ZONE:New( casNameZone )


      -- Create and object (in this case called AICasZone) and
      -- using the functions AI_CAS_ZONE assign the parameters that define this object
      -- (in this case PatrolZone, 500, 1000, 500, 600, CASEngagementZone)
      local AICasZonePlanes = AI_CAS_ZONE:New( PatrolZonePlanes, patrolSpeedMin, patrolMaxSPeed, minAltitude, maxAltitude, casZone )

      -- Create an object (in this case called Targets) and
      -- using the GROUP function find the group labeled "Targets" and assign it to this object
      local Targets = GROUP:FindByName( nameOfTarget )


      -- Tell the program to use the object (in this case called CASPlane) as the group to use in the CAS function
      AICasZonePlanes:SetControllable( CASPlane )

      -- Tell the group CASPlane to start the mission in 1 second.
      AICasZonePlanes:__Start( startMission ) -- Dopo 1 s They should startup, and start patrolling in the PatrolZone.

      -- After 4 minutes, tell the group CASPlanes and CASHelicopters to engage the targets located in the engagement zone called CASEngagement Zone.
      AICasZonePlanes:__Engage( timeOfEngage, engageSpeed, engageAltitude ) -- Dopo 120 s  Engage with a speed of 500 km/h and 1500 meter altitude.


      -- After 12 minutes, tell the group CASPlane to abort the engagement.
      AICasZonePlanes:__Abort( timeOfStopEngage ) -- Abort the engagement.

      -- Qui schedula una funzione che controlla periodicamente ogni 60 secondi la situazione
      -- Check every 60 seconds whether the Targets have been eliminated.
      -- When the trigger completed has been fired, the Planes and Helicopters will go back to the Patrol Zone.
      Check, CheckScheduleID = SCHEDULER:New(nil,
        function()
          if Targets:IsAlive() and Targets:GetSize() > targetNumToAccomplish then
            BASE:E( "Test Mission: " .. Targets:GetSize() .. " targets left to be destroyed.")
          else
            BASE:E( "Test Mission: The required targets are destroyed." )
            Check:Stop( CheckScheduleID )
            AICasZonePlanes:__Accomplish( 1 ) -- Now they should fly back to the patrolzone and patrol
          end
        end, {}, 20, 60, 0.2 )


      -- When the targets in the zone are destroyed, (see scheduled function), the planes will return home ...
      function AICasZonePlanes:OnAfterAccomplish( Controllable, From, Event, To )
        BASE:E( "Test Mission: Sending the Su-25T back to base." )
        AICasZonePlanes:__RTB( 1 )
      end

      -- When the targets in the zone are destroyed, (see scheduled function), the helicpters will return home ...
      function AICasZoneHelicopters:OnAfterAccomplish( Controllable, From, Event, To )
        BASE:E( "Test Mission: Sending the Ka-50 back to base." )
        AICasZoneHelicopters:__RTB( 1 )
      end

      return

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

                        if targets:IsAlive() and nDead < requestNumberKill then

                          MESSAGE:New(string.format("BAI Mission: " .. nameMission .. ": %d of %d red targets still alive. At least %d targets need to be eliminated.", nTargets, nInitial, requestNumberKill), 5):ToAll()

                        else

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









--- Attiva il task GCI per un asset assegnato
--
-- DA MODIFICARE
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
function activeGCI(groupset, capZoneName, typeZoneName, engageRange, engageZone, typeEngageZoneName, patrolFloorAltitude, ceilFloorAltitude, minSpeedEngage, maxSpeedEngage )

      -- vedi come lo ha realizzato nella AI e implementalo qui
      -- nota: inserire il mission accomplish se le munizioni sono finite, l'eventuale check del fuel, se danneggiato ecc.

     local patrolZone = defineZone( capZoneName, typeZoneName )

     for _,group in pairs(groupset:GetSetObjects()) do

          local patrolZone = ZONE:New( "Patrol Zone Tbilisi" )

          -- attiva tutti gli aerei uncontrolled
          group:StartUncontrolled()

          local CAP = AI_A2A_CAP:New(group, patrolZone, 2000, 3000, 400, 600, 600, 800)

          -- Tell the program to use the object (in this case called CAPPlane) as the group to use in the CAP function
          CAP:SetControllable(group)

          -- Set enage range to 10 km from aircraft
          CAP:SetEngageRange(10000)

          -- Start CAP
          CAP:Start()

          -- codice per durata CAP?

        end -- end for

        return

end -- function


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
    local debug = true

    if debug then logging('enter', 'activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )') end

    if debug and nil == groupset then logging('warning', { 'activeRECON( .. )' , 'groupset is nil. Exit!' } ) return nil end

    if debug and nil == target then logging('warning', { 'activeRECON( .. )' , 'target is nil. Exit!' } ) return nil end

    if debug and nil == home then logging('warning', { 'activeRECON( .. )' , 'homebase is nil. Exit!' } ) return nil end

    if debug then logging('finest', { 'activeRECON( .. )' , 'target = ' .. target:GetName() .. '  -  group = ' .. groupset:GetObjectNames() .. '  -  home = ' .. home:GetName() } ) end


    for _, _group in pairs(groupset:GetSet()) do

          local group = _group --Wrapper.Group#GROUP

          -- Start uncontrolled aircraft.
          group:StartUncontrolled()

          -- Target coordinate!
          local ToCoord=target:GetCoordinate():SetAltitude(toTargetAltitude)

          -- Home coordinate.
          local HomeCoord=home:GetCoordinate():SetAltitude(toHomeAltitude)

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





--- Generate a set of cargo (CARGO_SET)
--  @param typeCargo:    'Veichles', 'Infantry', 'Crate'
--  @param nameGroupCargo:  the name of group in mission editor
--  @param loadRadius: the radius for cargo loading
--  @param nearRadius: the radius for immediate loading
function generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)

    local debug = true

    if debug then logging('enter', 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)') end

    if nil == loadRadius then logging('warning', { 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)' , 'loadRadius is nil. Exit!' } ) return nil end
    if nil == typeCargo then logging('warning', { 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)' , 'typeCargo is nil. Exit!' } ) return nil end
    if nil == nameGroupCargo then logging('warning', { 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)' , 'nameGroupCargo is nil. Exit!' } ) return nil end

    if debug then logging('finest', { 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)' , 'typeCargo: ' .. typeCargo .. ' - nameGroupCargo:' .. nameGroupCargo .. ' - loadRadius:' .. loadRadius } ) end


    -- vedi:
    -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/HEL%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter.lua
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Helicopter.html
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New


    local group = GROUP:FindByName( nameGroupCargo )
    if debug then logging('finest', { 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)' , 'group: ' .. group:GetName() } ) end

    -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :
    local cargoGroup = CARGO_GROUP:New( group, typeCargo, nameGroupCargo, LoadRadius, nearRadius)
    if debug then logging('finest', { 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)' , 'cargoGroup: ' .. cargoGroup:GetName() } ) end

    local cargoGroupSet = SET_CARGO:New():FilterTypes( typeCargo ):FilterStart()

    if debug then logging('finest', { 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)' , 'cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. '  - cargo.count:' .. cargoGroupSet:Count() } ) end

    if debug then logging('exit', 'generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)') end

    return cargoGroupSet

end



--- Generate a set of cargo (CARGO_SET)
--  @param typeCargo:    'Veichles', 'Infantry', 'Crate'
--  less sense: ONE FUNCTION FO A SINGLE INSTRUCTION
--  Delete
function generateCargoSetTag(typeCargo)

    local debug = true

    if debug then logging('enter', 'generateCargoSetTag(typeCargo)') end

    if nil == typeCargo then logging('warning', { 'generateCargoSetTag(typeCargo)' , 'typeCargo is nil. Exit!' } ) return nil end

    if debug then logging('finest', { 'generateCargoSetTag(typeCargo)' , 'typeCargo: ' .. typeCargo } ) end

    -- vedi:
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.Cargo.html

    local cargoGroupSet = SET_CARGO:New():FilterTypes( typeCargo ):FilterStart()

    if debug then logging('finest', { 'generateCargoSetTag(typeCargo)' , 'cargoGroup: ' .. cargoGroupSet:GetObjectNamesName() .. '  - cargo.count:' .. cargoGroupSet:Count() } ) end

    if debug then logging('exit', 'generateCargoSetTag(typeCargo)') end

    return cargoGroupSet

end












--- Attiva l'invio di cargo
-- @param groupPlaneSet = il gruppo di aerei utilizzati per il trasporto
-- @param pickupAirbaseName = il nome della airbase di partenza (es: pickupAirbaseName = AIRBASE.Caucasus.Kobuleti)
-- @deployAirbaseName =  il nome della airbase di arrivo (es: deployAirbaseName = AIRBASE.Caucasus.Batumi)
-- @groupCargoSet = il carico da trasportare
-- @speed = velocita' del trasporto
--
function activeCargoAirPlane( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )

  local debug = true

  if debug then logging('enter', 'activeCargoAirPlane( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )') end

  if debug then logging('finest', { 'activeCargoAirPlane( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )' , 'pickupAirbaseName = ' .. pickupAirbaseName .. 'deployAirbaseName = ' .. deployAirbaseName .. '  -  group = ' .. groupPlaneSet:GetObjectNames() .. '  -  speed = ' .. tostring(speed) } ) end

  local lenghtGroupCargoSet = #groupCargoSet

  local i = 1

  -- Cargo assignation for groupset
  for _, group in pairs(groupPlaneSet:GetSetObjects()) do -- loop for PLANE SET

        local group = group --Wrapper.Group#GROUP
        group:StartUncontrolled()

        if debug then logging('finest', { 'activeCargoAirPlane( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )' , ' Airplane = ' .. group:GetName()  } ) end

        -- Cargo Assignation for single group of the groupset
        if i <= #groupCargoSet then -- loop for CARGO SET

            local groupCargo = groupCargoSet[i]

            i = i + 1

            if debug then logging('finest', { 'activeCargoAirPlane( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )' , 'i = ' .. i .. ' - Helicopter = ' .. group:GetName()  .. '  - cargo selected = ' .. groupCargo:GetName()} ) end

            pickupAirbase = AIRBASE:FindByName( pickupAirbaseName )
            deployAirbase = AIRBASE:FindByName( deployAirbaseName )

            CargoAirplane = AI_CARGO_AIRPLANE:New( group, groupCargo )
            CargoAirplane:Pickup( pickupAirbase )

            -- CargoAirplane:Route(group, deployAirbase, speed, 7000, true)

            function CargoAirplane:onafterLoaded( Airplane, From, Event, To, Cargo )
                if debug then logging('finest', { 'activeCargoAirPlane( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )' , 'CargoAirplane:onafterLoaded( Airplane, From, Event, To, Cargo )' } ) end
                CargoAirplane:Deploy( deployAirbase, speed )
            end


            function CargoAirplane:onafterUnloaded( Airplane, From, Event, To, Cargo )
                if debug then logging('finest', { 'activeCargoAirPlane( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )' , 'CargoAirplane:onafterLoaded( Airplane, From, Event, To, Cargo )' } ) end
                CargoAirplane:Pickup( pickupAirbase, speed )
            end

          end -- end if

  end -- end for


  if debug then logging('exit', 'activeCargoAirPlane( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )') end

  return

end -- end function


















--- Attiva l'invio di cargo
-- @param groupHeliSet =        il gruppo di elicotteri utilizzati per il trasporto
-- @param pickupAirbaseName =   il nome della airbase di partenza (es: pickupAirbaseName = AIRBASE.Caucasus.Kobuleti)
-- @deployAirbaseName =         il nome della airbase di arrivo (es: deployAirbaseName = AIRBASE.Caucasus.Batumi)
-- @groupCargoSet =             il carico da trasportare
-- @speed =                     velocita' del trasporto
function activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )

  local debug = true

  if debug then logging('enter', 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )') end

  if debug then logging('finest', { 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )' , 'pickupZone = ' .. pickupZone:GetName() .. 'deployZone = ' .. deployZone:GetName() .. '  -  HeliGroup = ' .. groupHeliSet:GetObjectNames() .. '  -  groupCargoSet = ' .. groupCargoSet:GetObjectNames() .. '  -  speed = ' .. tostring(speed) } ) end

  local lenghtGroupCargoSet = #groupCargoSet
  local i = 1

  -- Cargo assignation for groupset
  for _, group in pairs(groupHeliSet:GetSetObjects()) do

        local group = group --Wrapper.Group#GROUP
        group:StartUncontrolled()

        if debug then logging('finest', { 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )' , ' Helicopter = ' .. group:GetName()  } ) end

        -- Cargo Assignation for single group of the groupset
        if i <= #groupCargoSet then

            local groupCargo = groupCargoSet[i]

            i = i + 1

            if debug then logging('finest', { 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )' , 'i = ' .. i .. ' - Helicopter = ' .. group:GetName() .. '  - cargo selected = ' .. groupCargo:GetName() } ) end

            -- Start uncontrolled aircraft.
            -- group:StartUncontrolled()

            CargoHelicopter = AI_CARGO_HELICOPTER:New( group, groupCargo )


            local innerDeployZone = 10 -- Minimal distance from the center of the zone . Default is 0.
            local outerDeployZone = 500 -- Maximal distance from the outer edge of the zone. Default is the radius of the zone

            local innerPickUpZone = 10
            local outerPickUpZone = 500



            CargoHelicopter:Pickup( PickupZone:GetRandomCoordinate( inner, outer ), speed )

            function CargoHelicopter:onafterLoaded( Helicopter, From, Event, To, Cargo )
                if debug then logging('finest', { 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )' , 'CargoHelicopter:onafterLoaded( Helicopter, From, Event, To, Cargo )' } ) end
                    CargoHelicopter:Deploy( DeployZone:GetRandomCoordinate( innerDeployZone, outerDeployZone ), speed )
            end


            function CargoHelicopter:onafterUnloaded( Helicopter, From, Event, To, Cargo )
                if debug then logging('finest', { 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )' , 'CargoHelicopter:onafterUnloaded( Helicopter, From, Event, To, Cargo )' } ) end
                CargoHelicopter:Pickup( PickupZone:GetRandomCoordinate( innerPickUpZone, outerPickUpZone ), speed )
            end

          end -- end if

  end -- end for


  if debug then logging('exit', 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )') end

  return

end -- end function















--- Attiva l'invio di cargo
-- @param groupHeliSet = il gruppo di elicotteri utilizzati per il trasporto
-- @param pickupAirbaseName = il nome della airbase di partenza (es: pickupAirbaseName = AIRBASE.Caucasus.Kobuleti)
-- @deployAirbaseName =  il nome della airbase di arrivo (es: deployAirbaseName = AIRBASE.Caucasus.Batumi)
-- @groupCargoSet = il carico da trasportare
-- @speed = velocita' del trasporto
--
function activeDispatcherCargo( type, groupHeliSet, pickupZoneSet, deployZoneSet, speed, groupCargoSet )

  local debug = true

  if debug then logging('enter', 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )') end

  if debug then logging('finest', { 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )' , 'pickupZoneSet = ' .. pickupZoneSet:GetObjectName() .. 'deployZoneSet = ' .. deployZoneSet:GetObjectName() .. '  -  HeliGroup = ' .. groupHeliSet:GetObjectNames() .. '  -  groupCargoSet = ' .. groupCargoSet:GetObjectNames() .. '  -  speed = ' .. tostring(speed) } ) end

  --[[
  -- An AI dispatcher object for a helicopter squadron, moving infantry from pickup zones to deploy zones

      local SetCargoInfantry = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
      local SetHelicopter = SET_GROUP:New():FilterPrefixes( "Helicopter" ):FilterStart()
      local SetPickupZones = SET_ZONE:New():FilterPrefixes( "Pickup" ):FilterStart()
      local SetDeployZones = SET_ZONE:New():FilterPrefixes( "Deploy" ):FilterStart()

      AI_CARGO_DISPATCHER_HELICOPTER:New( SetHelicopter, SetCargoInfantry, SetPickupZones, SetDeployZones )    AICargoDispatcherHelicopter:Start()



  -- An AI dispatcher object for a vehicle squadron, moving infantry from pickup zones to deploy zones.

     local SetCargoInfantry = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
     local SetAPC = SET_GROUP:New():FilterPrefixes( "APC" ):FilterStart()
     local SetDeployZones = SET_ZONE:New():FilterPrefixes( "Deploy" ):FilterStart()

     AICargoDispatcherAPC = AI_CARGO_DISPATCHER_APC:New( SetAPC, SetCargoInfantry, nil, SetDeployZones )
     AICargoDispatcherAPC:Start()




 -- An AI dispatcher object for an airplane squadron, moving infantry and vehicles from pickup airbases to deploy airbases.

      local CargoInfantrySet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
      local AirplanesSet = SET_GROUP:New():FilterPrefixes( "Airplane" ):FilterStart()
      local PickupZoneSet = SET_ZONE:New()
      local DeployZoneSet = SET_ZONE:New()

      PickupZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Gudauta ) )
      DeployZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Sochi_Adler ) )
      DeployZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Maykop_Khanskaya ) )
      DeployZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Mineralnye_Vody ) )
      DeployZoneSet:AddZone( ZONE_AIRBASE:New( AIRBASE.Caucasus.Vaziani ) )

      AICargoDispatcherAirplanes = AI_CARGO_DISPATCHER_AIRPLANE:New( AirplanesSet, CargoInfantrySet, PickupZoneSet, DeployZoneSet )
      AICargoDispatcherAirplanes:Start()


      --- Loaded event handler OnAfter for CLASS.
 -- Use this event handler to tailor the event when a CarrierUnit of a CarrierGroup has loaded a cargo object.
 -- You can use this event handler to post messages to players, or provide status updates etc.
 -- Note that if more cargo objects were loading or boarding into the CarrierUnit, then this event can be triggered multiple times for each different Cargo/CarrierUnit.
 -- A CarrierUnit can be part of the larger CarrierGroup.
 -- @param #CLASS self
 -- @param #string From A string that contains the "*from state name*" when the event was triggered.
 -- @param #string Event A string that contains the "*event name*" when the event was triggered.
 -- @param #string To A string that contains the "*to state name*" when the event was triggered.
 -- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
 -- @param Cargo.Cargo#CARGO Cargo The cargo object.
 -- @param Wrapper.Unit#UNIT CarrierUnit The carrier unit that is executing the cargo loading operation.
 -- @param Core.Zone#ZONE_AIRBASE PickupZone (optional) The zone from where the cargo is picked up. Note that the zone is optional and may not be provided, but for AI_CARGO_DISPATCHER_AIRBASE there will always be a PickupZone, as the pickup location is an airbase zone.
 function CLASS:OnAfterLoaded( From, Event, To, CarrierGroup, Cargo, CarrierUnit, PickupZone )

   -- Write here your own code.

 end




 --- PickedUp event handler OnAfter for CLASS.
 -- Use this event handler to tailor the event when a carrier has picked up all cargo objects into the CarrierGroup.
 -- You can use this event handler to post messages to players, or provide status updates etc.
 -- @param #CLASS self
 -- @param #string From A string that contains the "*from state name*" when the event was triggered.
 -- @param #string Event A string that contains the "*event name*" when the event was triggered.
 -- @param #string To A string that contains the "*to state name*" when the event was triggered.
 -- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
 -- @param Core.Zone#ZONE_AIRBASE PickupZone (optional) The zone from where the cargo is picked up. Note that the zone is optional and may not be provided, but for AI_CARGO_DISPATCHER_AIRBASE there will always be a PickupZone, as the pickup location is an airbase zone.
 function CLASS:OnAfterPickedUp( From, Event, To, CarrierGroup, PickupZone )

   -- Write here your own code.

 end




    --- Deploy event handler OnAfter for CLASS.
 -- Use this event handler to tailor the event when a CarrierGroup is routed to a deploy coordinate, to Unload all cargo objects in each CarrierUnit.
 -- You can use this event handler to post messages to players, or provide status updates etc.
 -- @param #CLASS self
 -- @param #string From A string that contains the "*from state name*" when the event was triggered.
 -- @param #string Event A string that contains the "*event name*" when the event was triggered.
 -- @param #string To A string that contains the "*to state name*" when the event was triggered.
 -- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
 -- @param Core.Point#COORDINATE Coordinate The deploy coordinate.
 -- @param #number Speed The velocity in meters per second on which the CarrierGroup is routed towards the deploy Coordinate.
 -- @param #number Height Height in meters to move to the deploy coordinate.
 -- @param Core.Zone#ZONE DeployZone The zone wherein the cargo is deployed. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
 function CLASS:OnAfterDeploy( From, Event, To, CarrierGroup, Coordinate, Speed, Height, DeployZone )

   -- Write here your own code.

 end


 --- Unload event handler OnAfter for CLASS.
 -- Use this event handler to tailor the event when a CarrierGroup has initiated the unloading or unboarding of cargo.
 -- You can use this event handler to post messages to players, or provide status updates etc.
 -- @param #CLASS self
 -- @param #string From A string that contains the "*from state name*" when the event was triggered.
 -- @param #string Event A string that contains the "*event name*" when the event was triggered.
 -- @param #string To A string that contains the "*to state name*" when the event was triggered.
 -- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
 -- @param Core.Zone#ZONE DeployZone The zone wherein the cargo is deployed. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
 function CLASS:OnAfterUnload( From, Event, To, CarrierGroup, DeployZone )

   -- Write here your own code.

 end



 --- UnLoading event handler OnAfter for CLASS.
 -- Use this event handler to tailor the event when a CarrierUnit of a CarrierGroup is in the process of unloading or unboarding of a cargo object.
 -- You can use this event handler to post messages to players, or provide status updates etc.
 -- Note that this event is triggered repeatedly until all cargo (units) have been unboarded from the CarrierUnit.
 -- @param #CLASS self
 -- @param #string From A string that contains the "*from state name*" when the event was triggered.
 -- @param #string Event A string that contains the "*event name*" when the event was triggered.
 -- @param #string To A string that contains the "*to state name*" when the event was triggered.
 -- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
 -- @param Cargo.Cargo#CARGO Cargo The cargo object.
 -- @param Wrapper.Unit#UNIT CarrierUnit The carrier unit that is executing the cargo unloading operation.
 -- @param Core.Zone#ZONE DeployZone The zone wherein the cargo is deployed. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
 function CLASS:OnAfterUnload( From, Event, To, CarrierGroup, Cargo, CarrierUnit, DeployZone )

   -- Write here your own code.

 end



 --- Unloaded event handler OnAfter for CLASS.
-- Use this event handler to tailor the event when a CarrierUnit of a CarrierGroup has unloaded a cargo object.
-- You can use this event handler to post messages to players, or provide status updates etc.
-- Note that if more cargo objects were unloading or unboarding from the CarrierUnit, then this event can be triggered multiple times for each different Cargo/CarrierUnit.
-- A CarrierUnit can be part of the larger CarrierGroup.
-- @param #CLASS self
-- @param #string From A string that contains the "*from state name*" when the event was triggered.
-- @param #string Event A string that contains the "*event name*" when the event was triggered.
-- @param #string To A string that contains the "*to state name*" when the event was triggered.
-- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
-- @param Cargo.Cargo#CARGO Cargo The cargo object.
-- @param Wrapper.Unit#UNIT CarrierUnit The carrier unit that is executing the cargo unloading operation.
-- @param Core.Zone#ZONE DeployZone The zone wherein the cargo is deployed. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
function CLASS:OnAfterUnloaded( From, Event, To, CarrierGroup, Cargo, CarrierUnit, DeployZone )

  -- Write here your own code.

end



--- Deployed event handler OnAfter for CLASS.
 -- Use this event handler to tailor the event when a carrier has deployed all cargo objects from the CarrierGroup.
 -- You can use this event handler to post messages to players, or provide status updates etc.
 -- @param #CLASS self
 -- @param #string From A string that contains the "*from state name*" when the event was triggered.
 -- @param #string Event A string that contains the "*event name*" when the event was triggered.
 -- @param #string To A string that contains the "*to state name*" when the event was triggered.
 -- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
 -- @param Core.Zone#ZONE DeployZone The zone wherein the cargo is deployed. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
 function CLASS:OnAfterDeployed( From, Event, To, CarrierGroup, DeployZone )

   -- Write here your own code.

 end



    AI_CARGO_DISPATCHER.SetPickupRadius(): Sets or randomizes the pickup location for the carrier around the cargo coordinate in a radius defined an outer and optional inner radius.
    AI_CARGO_DISPATCHER.SetPickupSpeed(): Set the speed or randomizes the speed in km/h to pickup the cargo.
    AI_CARGO_DISPATCHER.SetPickupHeight(): Set the height or randomizes the height in meters to pickup the cargo.

5) Set the deploy parameters.

Several parameters can be set to deploy cargo:

    AI_CARGO_DISPATCHER.SetDeployRadius(): Sets or randomizes the deploy location for the carrier around the cargo coordinate in a radius defined an outer and an optional inner radius.
    AI_CARGO_DISPATCHER.SetDeploySpeed(): Set the speed or randomizes the speed in km/h to deploy the cargo.
    AI_CARGO_DISPATCHER.SetDeployHeight(): Set the height or randomizes the height in meters to deploy the cargo.

 AI_CARGO_DISPATCHER.SetHomeZone()






    local CargoHelicopter = AI_CARGO_DISPATCHER_HELICOPTER:New( groupHeliSet, groupCargoSet, SetPickupZones, SetDeployZones )
]]

    if debug then logging('exit', 'activeCargoHelicopter( groupHeliSet, pickupZone, deployZone, speed, groupCargoSet )') end

    return

 end -- end function







--- Attiva l'invio di ground asset nella zone.
-- @param groupset = il gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeGO_TO_ZONE_AIR( groupset, battleZone, speedPerc )

  local debug = true

  if debug then logging('enter', 'activeGO_TO_ZONE_AIR( group, battlezone, speedPerc )') end

  if debug and nil == groupset then logging('warning', { 'activeGO_TO_ZONE_AIR( groupset, battlezone, speedPerc )' , 'groupset is nil. Exit!' } ) return nil end

  if debug and nil == battleZone then logging('warning', { 'activeGO_TO_ZONE_AIR( groupset, battlezone, speedPerc )' , 'battleZone is nil. Exit!' } ) return nil end

  if debug then logging('finest', { 'activeGO_TO_ZONE_AIR( group, battlezone, speedPerc )' , 'battleZone = ' .. battleZone:GetName() .. '  -  group = ' .. groupset:GetObjectNames() .. '  -  speedPerc = ' .. tostring(speedPerc) } ) end


  if nil == speedPerc or speedPerc > 1 or speedPerc < 0.1 then speedPerc = 0.7 end

  -- radius=radius or 100

  -- seleziona ogni gruppo appartenente al set

--  POINT_VEC3.RoutePointAction
--  Fields and Methods inherited from POINT_VEC3.RoutePointAction
--  Description

--  POINT_VEC3.RoutePointAction.FromParkingArea  "From Parking Area"
--  POINT_VEC3.RoutePointAction.TurningPoint  "Turning Point"


 -- POINT_VEC3.RoutePointAltType
 -- Fields and Methods inherited from POINT_VEC3.RoutePointAltType
 -- Description
 -- POINT_VEC3.RoutePointAltType.BARO "BARO"

 -- POINT_VEC3.RoutePointType
 -- Fields and Methods inherited from POINT_VEC3.RoutePointType
 -- Description
 -- POINT_VEC3.RoutePointType.TakeOffParking  "TakeOffParking"
 -- POINT_VEC3.RoutePointType.TurningPoint  "Turning Point"



  for _,group in pairs(groupset:GetSet()) do

    local group = group --Wrapper.Group#GROUP
    group:StartUncontrolled()

    -- Route group to Battle zone.
    local ToCoord = battleZone:GetRandomCoordinate()
    local groupCoord = group:GetCoordinate()
    group:RouteAirTo(ToCoord, POINT_VEC3.RoutePointAltType.BARO, POINT_VEC3.RoutePointType.TurningPoint, POINT_VEC3.RoutePointAction.TurningPoint, group:GetSpeedMax() * speedPerc, nil)

    --

  end -- end for


  if debug then logging('exit', 'activeGO_TO_ZONE_AIR( group, battlezone, speedPerc )') end

  return

end -- end function




--- Attiva l'invio di ground asset nella zone.
-- @param groupset = il set di Group
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
function activeGO_TO_ZONE_GROUND( groupset, battleZone, offRoad, speedPerc )

    local debug = true

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
-- @param param (optional) : lista contenente ulteriori parametri
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
-- DEPRECATED
--[[
function activeGO_TO_BATTLE( groupset, battlezone, task, param, offRoad, speedPerc )

        local debug = true

        if debug then logging('enter', 'activeGO_TO_BATTLE( groupset, battlezone )') end

        if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone )' , 'gorupsetName: ' .. groupset:GetObjectNames() } ) end

        local battle_Zone = battlezone[1] -- the zone object
        local ToCoord = battle_Zone:GetRandomCoordinate()

        activeGO_TO_ZONE_GROUND( groupset, battle_Zone, offRoad, speedPerc )

          for _,group in pairs(groupset:GetSet()) do

            local group = group --Wrapper.Group#GROUP



            if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone )' , 'task = '.. task } ) end

            -- task per attacco diretto
            if task == 'enemy_attack' then

              -- After 3-5 minutes we create an explosion to destroy the group.
              -- sostituisce con task per enemy attack: search & destroy

              SCHEDULER:New(nil, Explosion, {group, 50}, math.random(180, 300))
              if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone )' , 'execute enemy_attack tasking'} ) end

            end  --end if

            -- task per fuoco di artiglieria di bersagli fissi
            if task == 'artillery_firing' then

              local listTargetInfo = param.listTargetInfo
              local command_center = param.commandCenter
              local groupResupplySet = param.resupplySet
              local speed = param.speed
              local onRoad = param.onRoad
              local maxDistance = param.maxDistance
              local maxFiringRange = param.maxFiringRange

              if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone )' , 'execute artillery_firing tasking   -  ' .. 'num target zone = ' .. #listTargetInfo .. '  -  groupResupplySet = ' .. groupResupplySet:GetObjectNames() .. '-  speed = ' .. tostring(speed) .. '-  onRoad = ' .. tostring(onRoad) .. '-  maxDistance = ' .. tostring(maxDistance) .. '-  maxFiringRange = ' .. tostring(maxFiringRange) } ) end


              ArtyPositionAndFireAtTarget(group, groupResupplySet, ToCoord, listTargetInfo, command_center, activateDetectionReport, speed, onRoad, maxDistance, maxFiringRange)

            end  --end if

            -- task per ricognizione e fuoco di artiglieria su bersagli mobili
            if task == 'artillery_detection_and_firing' then


              --qui la funzione che utilizza la func ArtyFireAtDetection

              -- tasking for artillery firing
                if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone )' , 'execute artillery_detection_and_firing tasking'} ) end

            end  --end if

            -- task per posizione difensiva
            if task == 'defence' then

                  -- tasking for artillery firing
                  if debug then logging('finest', { 'activeGO_TO_BATTLE( groupset, battlezone )' , 'execute defence tasking'} ) end

            end  --end if


        end -- end for

        if debug then logging('exit', 'activeGO_TO_BATTLE( groupset, battlezone )') end

        return

end -- end function
]]


--- Attiva l'invio di gorund asset nella battlezone.
-- NOTA: Nella funzione � presente la schedulazione dell'autodistruzione degli asset
--  al raggiungimento della zona. L'autodistruzione � stata inserita per testare il reinvio degli asset
-- @param groupset = il set dei gruppo (asset) proveniente dalla warehouse
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param task = il task essegnato al groupset
-- @param param (optional) : lista contenente ulteriori parametri
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
-- DA IMPLEMENTARE I DIVERSI TASK DI ESECUZIONI
function activeGO_TO_BATTLE_BIS( groupset, battleZone, task, offRoad, speedPerc )

        local debug = true

        if debug then logging('enter', 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )') end

        if debug and nil == groupset then logging('warning', { 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )' , 'group is nil. Exit!' } ) return nil end

        if debug and nil == battleZone then logging('warning', { 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )' , 'battleZone is nil. Exit!' } ) return nil end

        if debug then logging('finest', { 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )' , 'battlezone = ' .. battleZone:GetName() .. '  -  group = ' .. groupset:GetObjectNames() .. '  -  offRoad = ' .. tostring(offRoad) .. '  -  speedPerc = ' .. tostring(speedPerc) } ) end

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

          if debug then logging('finest', { 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )' , 'routeToRoad exist = ' .. tostring(exist) .. '  -  length = ' .. tostring(length) } ) end


          if exist and not offRoad then

            if debug then logging('finest', { 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )' , 'routeToRoad' } ) end
            -- Ottimizzazione: evita il ricalcolo della route. Cmq dai un occhiata a Moose group:RouteGroundOnRoad per una eventuale modifica
            -- group:RoutePush( route )
            group:RouteGroundOnRoad( ToCoord, group:GetSpeedMax() * speedPerc )

          else

            if debug then logging('finest', { 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )' , 'execute routeToGround' } ) end
            group:RouteGroundTo( ToCoord, group:GetSpeedMax() * speedPerc )

          end -- end if then

          if debug then logging('finest', { 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )' , 'task = '.. task } ) end

          -- task per attacco diretto
          if task == 'enemy_attack' then

            -- After 3-5 minutes we create an explosion to destroy the group.
            -- sostituisce con task per enemy attack: search & destroy

            --SCHEDULER:New(nil, Explosion, {group, 50}, math.random(180, 300))
            group:TaskFireAtPoint(ToCoord, 200, nil, nil)


          end  --end if


        end -- end for


        if debug then logging('exit', 'activeGO_TO_BATTLE_BIS( groupset, battlezone, task, offRoad, speedPerc )') end

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

  local debug = true

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

    local debug = true

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
        function RecceGroundDetection:OnAfterDetect(From,Event,To)

          if debug then logging('enter', 'RecceGroundDetection:OnAfterDetect(From,Event,To)') end

          local DetectionReport = RecceGroundDetection:DetectedReportDetailed()

          command_center:GetPositionable():MessageToAll( DetectionReport, persistTimeOfMessage, "" )

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

  local debug = true

  -- determina il recceGroup selezionandolo da tutte le unita' definite Recce (Recce #001, ..)
  --RecceSetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameRecceUnits ):FilterStart()

  -- determina l'arty group selezionandolo da tutte le unita' definite Artillery (Artillery #001, ..)
  --ArtillerySetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameArtyUnits ):FilterStart()

  -- devi utilizzare i gruppi e non i setGorup che credo siano considerati gia' attivi su ME. Quindi
  -- Creare il grouppo da template, posizionarlo e tramite setGroud associarlo al set da utilizzare qui

  -- quindi OK LA WAREHOUSE CON OnAfterSelfRequest  genera un groupSet!!!!!!

  if debug then logging('enter', 'ArtyFiringFromRecceDetection(RecceGroundDetection, ArtillerySetGroup)') end
  if debug then logging('info', { 'ArtyFiringFromRecceDetection(RecceGroundDetection, ArtillerySetGroup)' , 'ArtillerySetGroup: ' .. ArtillerySetGroup  }) end

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

  if debug then logging('info', { 'ArtyFiringFromRecceDetection(RecceGroundDetection, ArtillerySetGroup)' , 'ArtilleryAim: ' .. ArtilleryAim .. ' - radiusTarget: ' .. radiusTarget .. ' - num_ammo: ' .. num_ammo .. ' - activated_time: ' .. activated_time }) end
  --- OnAfter Transition Handler for Event Detect.
  -- @param Functional.Detection#DETECTION_UNITS self
  -- @param #string From The From State string.
  -- @param #string Event The Event string.
  -- @param #string To The To State string.
  -- @param Wrapper.Unit#UNIT DetectedUnits
  function RecceDetection:OnAfterDetected( From, Event, To, DetectedUnits )

    if debug then logging('enter', 'RecceDetection:OnAfterDetected())') end
    if debug then logging('info', { 'RecceDetection:OnAfterDetected( From, Event, To, DetectedUnits )' , 'RecceSetGroup name: ' .. DetectedUnits:GetObjectNames() .. ' - activateDetectionReport: ' .. activateDetectionReport == TRUE .. ' - delayDetection: ' .. delayDetection .. ' - persistTimeOfMessage: ' .. persistTimeOfMessage }) end



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

  local debug = true

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

    local debug = true

    if debug then logging('finest', { 'ArtyPositionAndFireAtTarget()' , ' TEST OnAfterOpenFire(Controllable, From, Event, To, target)'} ) end

  end



  -- ARTY:CombatReady()
  --[[

  function ARTY:OnAfterRearmed(Controllable, From, Event, To)

          end

          function ARTY:OnAfterOpenFire(Controllable, From, Event, To, target)

          end

          function ARTY:OnAfterDead(Controllable, From, Event, To)

          end


  ]]--





  --ARTY:_FireAtCoord(coord, radius, nshells, weapontype)
  --ARTY:_Move(group, ToCoord, Speed, OnRoad)


  -- Specific Weapons

  --This example demonstrates how to use specific weapons during an engagement.

  -- Define the Normandy as ARTY object.
  -- normandy=ARTY:New(GROUP:FindByName("Normandy"))

  -- Add target: prio=50, radius=300 m, number of missiles=20, number of engagements=1, start time=08:05 hours, only use cruise missiles for this attack.
  -- normandy:AssignTargetCoord(GROUP:FindByName("Red Targets 1"):GetCoordinate(),  20, 300,  50, 1, "08:01:00", ARTY.WeaponType.CruiseMissile)

  -- Add target: prio=50, radius=300 m, number of shells=100, number of engagements=1, start time=08:15 hours, only use cannons during this attack.
  -- normandy:AssignTargetCoord(GROUP:FindByName("Red Targets 1"):GetCoordinate(),  50, 300, 100, 1, "08:15:00", ARTY.WeaponType.Cannon)

  -- Define shells that are counted to check whether the ship is out of ammo.
  -- Note that this is necessary because the Normandy has a lot of other shell type weapons which cannot be used to engage ground targets in an artillery style manner.
  -- normandy:SetShellTypes({"MK45_127"})

  -- Define missile types that are counted.
  -- normandy:SetMissileTypes({"BGM"})

  -- Start ARTY process.
  -- normandy:Start()


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

  local debug = true
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

  local debug = true
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


------------------------------------------------------------------------------- END DEFINE FUNCTIONS -------------------------------------------------------------------------------
















































































-------------------------------------------------------------------------------- ASSET TEMPLATE -------------------------------------------------------------------------------------------


-- RED AIR FORCE TEMPLATE

--- Template disponibili in ME
--  GCI_Mig_21Bis = 'SQ red GCI Mig_21Bis', -- GCI
-- GCI_Mig_23MLD = 'SQ red GCI Mig_23MLD',
-- GCI_Mig_25PD = 'SQ red GCI Mig_25PD',
-- CAP_Mig_21Bis = 'SQ red CAP Mig_21Bis', -- CAP
-- CAP_Mig_23MLD = 'SQ red CAP Mig_23MLD',
-- CAP_Mig_25PD = 'SQ red CAP Mig_25PD',
-- CAS_Mig_27K_Bomb = 'SQ red CAS Mig_27K Bomb', -- CAS
-- CAS_Su_17M4_Rocket = 'SQ red CAS Su_17M4 Rocket',
-- CAS_MI_24V = 'SQ red CAS MI_24V',
-- CAS_L_39C_Rocket = 'SQ red CAS L_39C Rocket',
-- GA_SU_24M_HRocket = 'SQ red GA SU_24M HRocket', -- GA
-- GA_SU_24M_Bomb = 'SQ red GA SU_24M Bomb',
-- GA_SU_24M_HBomb = 'SQ red GA SU_24M HBomb',
-- REC_Mig_25RTB = 'SQ red REC Mig_25RTB',  -- RECCE
-- REC_SU_24MR = 'SQ red REC SU_24MR',
-- BOM_TU_22_Bomb = 'SQ red BOM TU_22 Bomb', -- INTERDICTION
-- BOM_TU_22_Nuke = 'SQ red BOM TU_22 Nuke',
-- BOM_SU_24_Bomb = 'SQ red BOM SU_24 Bomb',
-- TRAN_AN_26 = 'SQ red TRA AN_26', -- TRANSPORT
-- TRAN_YAK_40 = 'SQ red TRA YAK_40',
-- TRAN_MI_24 = 'SQ red TRAN MI_24V',
-- TRAN_MI_26 = 'SQ red TRAN MI_26',
-- AWACS_TU_22 = 'SQ red AWACS TU_22',   -- AWACS
-- AWACS_Mig_25RTB = 'SQ red AWACS Mig_25RTB'
-- AFAC_Yak_52 = 'SQ red FAC YAK-52',  -- AFAC
-- AFAC_L_39C = 'SQ red FAC L-39C',
-- AFAC_Mi_8MTV2 = 'SQ red FAC Mi-8MTV2',
-- AFAC_MI_24 = 'SQ red FAC Mi-24'
--
local air_template_red = {

          GCI_Mig_21Bis = 'SQ red GCI Mig_21Bis', -- GCI
          GCI_Mig_23MLD = 'SQ red GCI Mig_23MLD',
          GCI_Mig_25PD = 'SQ red GCI Mig_25PD',
          GCI_Mig_19P = 'SQ red GCI Mig_19P',
          CAP_Mig_21Bis = 'SQ red CAP Mig_21Bis', -- CAP
          CAP_Mig_23MLD = 'SQ red CAP Mig_23MLD',
          CAP_Mig_25PD = 'SQ red CAP Mig_25PD',
          CAP_Mig_19P = 'SQ red CAP Mig_19P',
          CAS_Mig_27K_Bomb = 'SQ red CAS Mig_27K Bomb', -- CAS
          CAS_Mig_27K_Rocket = 'SQ red CAS Mig_27K Rocket',
          CAS_Su_17M4_Rocket = 'SQ red CAS Su_17M4 Rocket',
          CAS_Su_17M4_Bomb = 'SQ red CAS Su_17M4 Bomb',
          CAS_Su_17M4_Cluster = 'SQ red CAS Su_17M4 Cluster',
          CAS_MI_24V = 'SQ red CAS MI_24V',
          CAS_L_39C_Rocket = 'SQ red CAS L_39C Rocket',
          CAS_Mi_8MTV2 = 'SQ red CAS Mi-8MTV2', -- INSERIRE
          GA_SU_24M_HRocket = 'SQ red GA SU_24M HRocket', -- GA
          GA_SU_24M_Bomb = 'SQ red GA SU_24M Bomb',
          GA_SU_24M_HBomb = 'SQ red GA SU_24M HBomb',
          GA_Mig_27K_Bomb_Light = 'SQ Red BOM_Sparse_Light Mig-27K',
          GA_Mig_27K_ROCKET_Heavy = 'SQ Red ROCKET_Sparse_Heavy Mig-27K',
          GA_Mig_27K_ROCKET_Light = 'SQ Red ROCKET_Sparse_Light Mig-27K',
          REC_Mig_25RTB = 'SQ red REC Mig_25RTB',  -- RECCE
          REC_SU_24MR = 'SQ red REC SU_24MR',
          BOM_TU_22_Bomb = 'SQ red BOM TU_22 Bomb', -- INTERDICTION
          BOM_TU_22_Nuke = 'SQ red BOM TU_22 Nuke',
          BOM_SU_24_Bomb = 'SQ red BOM SU_24 Bomb',
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
          AFAC_MI_24 = 'SQ red FAC Mi-24'
}

-- END RED AIR FORCE TEMPLATE





-- BLUE AIR FORCE TEMPLATE

--- template definiti in ME
-- GCI_Mig_21Bis = 'SQ blue GCI Mig_21Bis', -- GCI
-- GCI_F_4 = 'SQ blue GCI F_4',
-- GCI_F_5 = 'SQ blue GCI F_5',
-- GCI_F_14A = 'SQ blue GCI F_14A',
-- CAP_F_4 = 'SQ blue CAP F_4', -- CAP
-- CAP_F_5 = 'SQ blue CAP F_5',
-- CAP_Mig_21Bis = 'SQ blue CAP Mig_21Bis',
-- CAP_L_39ZA = 'SQ blue CAP L_39ZA',  -- CAS
-- CAS_Su_17M4_Rocket = 'SQ blue CAS Su_17M4 Rocket',
-- CAS_MI_24V = 'SQ blue CAS MI_24V',
-- CAS_L_39C_Rocket = 'SQ blue CAS L_39C Rocket',
-- CAS_L_39ZA_HRocket = 'SQ blue CAS L_39ZA HRocket',
-- REC_L_39C = 'SQ blue REC L_39C',  -- RECCE
-- REC_F_4 = 'SQ blue REC F_4',
-- BOM_SU_24_Bomb = 'SQ blue BOM SU_24', -- INTERDICTION
-- B_1B_Bomb = 'SQ blue BOM B_1B Bomb',
-- B_1B_HBomb = 'SQ blue BOM B_1B HBomb',
-- BOM_B_52H = 'SQ blue BOM B_52H',
-- TRAN_AN_26 = 'SQ blue TRAN AN_26', -- TRANSPORT
-- TRAN_YAK_40 = 'SQ blue TRANSPORT YAK_40',
-- TRAN_UH_1H = 'SQ blue TRAN UH_1H',
-- TRAN_UH_60A = 'SQ blue TRAN UH_60A',
-- TRAN_CH_47 = 'SQ blue TRAN CH_47',
-- AWACS_F_4 = 'SQ blue AWACS F_4', -- AWACS
-- AWACS_B_1B = 'SQ blue AWACS B_1B'
-- AFAC_Yak_52 = 'SQ blue FAC Yak-52', -- AFAC
-- AFAC_L_39ZA = 'SQ blue FAC L-39ZA',
-- AFAC_AV_88 = 'SQ blue FAC AV-88',
-- AFAC_MI_24 = 'SQ blue FAC Mi-24',
-- AFAC_SA342L = 'SQ blue FAC SA342L',
-- AFAC_UH_1H = 'SQ blue FAC UH_1H'
--
local air_template_blue = {

          GCI_Mig_21Bis = 'SQ blue GCI Mig_21Bis', -- GCI
          GCI_F_4 = 'SQ blue GCI F_4',
          GCI_F_5 = 'SQ blue GCI F_5',
          GCI_F_14A = 'SQ blue GCI F_14A',
          CAP_F_4 = 'SQ blue CAP F_4', -- CAP
          CAP_F_5 = 'SQ blue CAP F_5',
          CAP_Mig_21Bis = 'SQ blue CAP Mig_21Bis',
          CAP_L_39ZA = 'SQ blue CAP L_39ZA',  -- CAS
          CAS_Su_17M4_Rocket = 'SQ blue CAS Su_17M4 Rocket',
          CAS_Su_17M4_Bomb = 'SQ blue CAS Su_17M4 Bomb',
          CAS_Su_17M4_Cluster = 'SQ blue CAS Su_17M4 Cluster',
          CAS_MI_24V = 'SQ blue CAS MI_24V',
          CAS_UH_1H = 'SQ blue CAS UH_1H',
          CAS_UH_60A = 'SQ blue CAS UH_60A',
          CAS_SA_342 = 'SQ blue CAS SA_342',
          CAS_L_39C_Rocket = 'SQ blue CAS L_39C Rocket',
          CAS_L_39ZA_HRocket = 'SQ blue CAS L_39ZA HRocket',
          CAS_F_4E_Rocket = 'SQ blue CAS F_4E Rocket',
          CAS_AV_88_Rocket = 'SQ blue CAS AV_88 Rocket',
          CAS_AV_88_Cluster = 'SQ blue CAS AV_88 Cluster',
          CAS_AV_88_Bomb = 'SQ blue CAS AV_88 Bomb',
          CAS_F_5E_3_Rocket = 'SQ blue CAS F_5E_3 Rocket',
          CAS_F_5E_3_Bomb = 'SQ blue CAS F_5E_3 Bomb',
          CAS_F_5E_3_Cluster = 'SQ blue CAS F_5E_3 Cluster',
          REC_L_39C = 'SQ blue REC L_39C',  -- RECCE
          REC_F_4 = 'SQ blue REC F_4',
          BOM_SU_24_Bomb = 'SQ blue BOM SU_24', -- INTERDICTION
          BOM_B_1B = 'SQ blue BOM B_1B Bomb',
          B_1B_HBomb = 'SQ blue BOM B_1B HBomb',
          BOM_B_52H = 'SQ blue BOM B_52H',
          BOM_F_4_E_Structure = 'SQ blue Structure BOM F4-E',
          BOM_F_4_E_Sparse_Heavy = 'SQ blue Structure BOM_Heavy F4-E',
          BOM_F_4_E_Sparse_Light = 'SQ blue Structure BOM_Sparse_Light F4-E',
          BOM_F_4_E_Sparse_Cluster = 'SQ blue Sparse BOM_Cluster F4-E',
          BOM_AV_88_Structure = 'SQ blue BOM C-AV88 Structure',
          BOM_AV_88_Heavy_Structure = 'SQ blue BOM C-AV88 Heavy Structure',
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
          AFAC_UH_1H = 'SQ blue FAC UH_1H' -- INSERIRE

}


-- END BLUE AIR FORCE TEMPLATE



-- RED GROUND FORCE TEMPLATE

--- ground_group_template_red table_bis:
-- antitankA = 'RUSSIAN ANTITANK SQUAD', -- ANTITANK
-- antitankB = 'RUSSIAN ANTITANK SQUAD BIS',
-- antitankC = 'RUSSIAN ANTITANK SQUAD TRIS',
-- mechanizedA = 'RUSSIAN MECHANIZED SQUAD', -- MECHANIZED
-- mechanizedB = 'RUSSIAN MECHANIZED SQUAD BIS',
-- mechanizedC = 'RUSSIAN MECHANIZED SQUAD TRIS',
-- ArtiKatiusha = 'RUSSIAN ARTILLERY KATIUSHA SQUAD', -- ARTILLERY
-- ArtiGwozdika = 'RUSSIAN ARTILLERY GWOZDIKA SQUAD',
-- ArtiHeavyMortar = 'RUSSIAN HEAVY MORTAR SQUAD',
-- ArtiAkatsia = 'RUSSIAN ARTILLERY AKATSIA SQUAD',
-- ArmorA = 'RUSSIAN ARMOR SQUAD', -- ARMOR
-- ArmorB = 'RUSSIAN ARMOR SQUAD BIS',
-- ResupplyTrucksColumn = 'GW_1975 Russian  Resupply Trucks Column',-- RESUPPLY
-- Truck = 'Red_Truck'
--
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





-- END RED GROUND FORCE TEMPLATE








-- BLUE GROUND FORCE TEMPLATE


--- Template defininti in ME
--
-- antitankA = 'GEORGIAN ANTITANK SQUAD', -- ANTITANK: WAREHOUSE.Attribute.GROUND_TANK
-- antitankB = 'GEORGIAN ANTITANK SQUAD BIS',
-- antitankC = 'GEORGIAN ANTITANK SQUAD TRIS',
-- mechanizedA = 'GEORGIAN MECHANIZED SQUAD', -- MECHANIZED: WAREHOUSE.Attribute.GROUND_APC
-- mechanizedB = 'GEORGIAN MECHANIZED SQUAD BIS',
-- mechanizedC = 'GEORGIAN MECHANIZED SQUAD TRIS',
-- ArtiKatiusha = 'GEORGIAN ARTILLERY KATIUSHA SQUAD', -- ARTILLERY: WAREHOUSE.Attribute.GROUND_ARTILLERY
-- ArtiGwozdika = 'GEORGIAN ARTILLERY GWOZDIKA SQUAD',
-- ArtiHeavyMortar = 'GEORGIAN HEAVY MORTAR SQUAD',
-- ArtiAkatsia = 'GEORGIAN ARTILLERY AKATSIA SQUAD',
-- ArmorA = 'GEORGIAN ARMOR SQUAD', -- ARMOR: WAREHOUSE.Attribute.GROUND_TANK
-- ArmorB = 'GEORGIAN ARMOR SQUAD BIS',
-- ResupplyTrucksColumn = 'GW_1975 Georgian Resupply Trucks Column', -- RESUPPLY: WAREHOUSE.Attribute.GROUND_TRUCK
-- Truck = 'Blue_Truck'
--
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

-- END BLUE GROUND FORCE TEMPLATE








--- prefix_detector (AWACS AND RADAR)
--
-- red = {"DF CCCP AWACS", "DF CCCP EWR"
--
-- DF GEORGIA AWACS", "DF GEORGIA EWR"
--
--
local prefix_detector = {

  red = {"DF CCCP AWACS", "DF CCCP EWR", "SQ red AWACS" },

  blue = {"DF GEORGIA AWACS", "DF GEORGIA EWR", "DF USA EWR", "DF USA AWACS", "SQ blue AWACS" }

}




-------------------------------------------------------------------------------- END ASSET TEMPLATE -------------------------------------------------------------------------------------------
















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

local airbase_red = { AIRBASE.Caucasus.Mozdok, AIRBASE.Caucasus.Maykop_Khanskaya, AIRBASE.Caucasus.Novorossiysk, AIRBASE.Caucasus.Mineralnye_Vody, AIRBASE.Caucasus.Nalchik,
                        AIRBASE.Caucasus.Beslan, AIRBASE.Caucasus.Gelendzhik, AIRBASE.Caucasus.Krasnodar_Pashkovsky, AIRBASE.Caucasus.Anapa_Vityazevo, AIRBASE.Caucasus.Krasnodar_Center, AIRBASE.Caucasus.Krymsk } -- aeroporti attivi in ME

local airbase_blue = { AIRBASE.Caucasus.Kutaisi, AIRBASE.Caucasus.Sochi_Adler, AIRBASE.Caucasus.Senaki_Kolkhi, AIRBASE.Caucasus.Gudauta, AIRBASE.Caucasus.Sukhumi_Babushara, AIRBASE.Caucasus.Kobuleti, AIRBASE.Caucasus.Tbilisi_Lochini, AIRBASE.Caucasus.Soganlug,
                        AIRBASE.Caucasus.Vaziani } -- aeroporti attivi in ME


-- WAREHOUSE.Attribute.AIR_TRANSPORTHELO
-- WAREHOUSE.Attribute.AIR_TRANSPORTPLANE
-- WAREHOUSE.Attribute.AIR_ATTACKHELO
-- WAREHOUSE.Attribute.AIR_TANKER

-- WAREHOUSE.Attribute.AIR_UAV
-- WAREHOUSE.Attribute.GROUND_AAA
-- WAREHOUSE.Attribute.GROUND_APC
-- WAREHOUSE.Attribute.GROUND_ARTILLERY
-- WAREHOUSE.Attribute.GROUND_EWR
-- WAREHOUSE.Attribute.GROUND_INFANTRY
-- WAREHOUSE.Attribute.GROUND_OTHER
-- WAREHOUSE.Attribute.GROUND_SAM
-- WAREHOUSE.Attribute.GROUND_TANK
-- WAREHOUSE.Attribute.GROUND_TRAIN
-- WAREHOUSE.Attribute.GROUND_TRUCK
-- WAREHOUSE.Attribute.NAVAL_AIRCRAFTCARRIER
-- WAREHOUSE.Attribute.NAVAL_ARMEDSHIP
-- WAREHOUSE.Attribute.NAVAL_OTHER
-- WAREHOUSE.Attribute.NAVAL_UNARMEDSHIP
-- WAREHOUSE.Attribute.NAVAL_WARSHIP
-- WAREHOUSE.Attribute.OTHER_UNKNOWN










































































































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


-- warehouse activation
local wh_activation = {


  Warehouse = {

    blue = {

       Zestafoni     =   false,
       Gori          =   true,
       Khashuri      =   false


    },

    red = {

      Biteta        =   false,
      Didi          =   true,
      Kvemo_Sba     =   false,
      Alagir        =   false

    }

  },

  Warehouse_AB = {

    blue = {

      Vaziani       =   false,
      Soganlug      =   false,
      Tbilisi       =   true,
      Kutaisi       =   true,
      Kvitiri       =   false,
      Kvitiri_Helo  =   false,
      Batumi        =   true

    },

    red = {

      Mozdok        =   false,
      Mineralnye    =   false,
      Beslan        =   true,
      Nalchik       =   false

    }

  },


}

---------------------------- SKILL
-- RED

local min_red_ground_skill = 3
local max_red_ground_skill = 6

local min_red_tank_skill = 4
local max_red_tank_skill = 6

local min_red_artillery_skill = 4
local max_red_artillery_skill = 6

local min_red_sam_skill = 4
local max_red_sam_skill = 6

local min_red_fighter_skill = 4
local max_red_fighter_skill = 6

local min_red_fighter_bomber_skill = 4
local max_red_fighter_bomber_skill = 6

local min_red_bomber_skill = 4
local max_red_bomber_skill = 6

local min_red_transport_skill = 5
local max_red_transport_skill = 6

local min_red_afac_skill = 5
local max_red_afac_skill = 6

local min_red_awacs_skill = 5
local max_red_awacs_skill = 6

local min_red_recon_skill = 5
local max_red_recon_skill = 6



-- BLUE

local min_blue_ground_skill = 3
local max_blue_ground_skill = 6

local min_blue_tank_skill = 4
local max_blue_tank_skill = 6

local min_blue_artillery_skill = 4
local max_blue_artillery_skill = 6

local min_blue_sam_skill = 4
local max_blue_sam_skill = 6

local min_blue_fighter_skill = 4
local max_blue_fighter_skill = 6

local min_blue_fighter_bomber_skill = 4
local max_blue_fighter_bomber_skill = 6

local min_blue_bomber_skill = 4
local max_blue_bomber_skill = 6

local min_blue_transport_skill = 5
local max_blue_transport_skill = 6

local min_blue_afac_skill = 5
local max_blue_afac_skill = 6

local min_blue_awacs_skill = 5
local max_blue_awacs_skill = 6

local min_blue_recon_skill = 5
local max_blue_recon_skill = 6




logging('info', { 'main' , 'conflictZone code module activated = ' ..  conflictZone } )
logging('info', { 'main' , 'Activation code module for Warehouse, Air War, Ground War, SeaWar active = ' .. tostring(activeWarehouse) .. ' , ' .. tostring(activeAirWar) .. ' , ' .. tostring(activeGroundWar) .. ' , ' .. tostring(activeSeaWar) } )

-- Qui l'eventuale codice per stabilire la zona del conflitto
--  conflictZone = conflictZone()

































-----------------------------  TARGET -------------------------------------------------------------------------------------------


if conflictZone == 'Zone 1: South Ossetia' then








  local targetPoints = {

    airbase = { math.random( 1500, 2000 ) },
    ewr_site = { math.random( 1000, 1200 ) },
    port = { math.random( 2000, 3000 ) },
    farp = { math.random( 200, 500 ) },
    warehouse = { math.random( 700, 900 ) },
    warehouse_big = { math.random( 1500, 2000 ) },
    storage_area = { math.random( 1500, 2000 ) },
    power_plant_area = { math.random( 2000, 3000 ) },
    production_plant_area = { math.random( 1700, 2200 ) },
    station = { math.random( 700, 900 ) },
    railway = { math.random( 100, 200 ) },
    bridge = { math.random( 100, 300 ) },
    front_zone = { math.random( 100, 300 ) }

  }




   -- Static Object che rappresentano target startegici (BAI, PINPOINT)
   local staticObject = {

    Warehouse = {

      blue = {

         Zestafoni     =   { STATIC:FindByName( "Warehouse ZESTAFONI" ), "Warehouse ZESTAFONI",  targetPoints.warehouse }, --Functional.Warehouse#WAREHOUSE
         Gori          =   { STATIC:FindByName( "Warehouse GORI" ), "Warehouse GORI",  targetPoints.warehouse_big },  --Functional.Warehouse#WAREHOUSE
         Khashuri      =   { STATIC:FindByName( "Warehouse KHASHURI" ), "Warehouse KHASHURI",  targetPoints.warehouse }   --Functional.Warehouse#WAREHOUSE


      },

      red = {

        Biteta        =   { STATIC:FindByName( "Warehouse Biteta" ), "Warehouse Biteta",  targetPoints.warehouse },--Functional.Warehouse#WAREHOUSE
        Didi          =   { STATIC:FindByName( "Warehouse Didi" ), "Warehouse Didi",  targetPoints.warehouse_big }, --Functional.Warehouse#WAREHOUSE
        Kvemo_Sba     =   { STATIC:FindByName( "Warehouse  Kvemo_Sba" ), "Warehouse  Kvemo_Sba",  targetPoints.warehouse }, --Functional.Warehouse#WAREHOUSE
        Alagir        =   { STATIC:FindByName( "Warehouse Alagir" ), "Warehouse Alagir",  targetPoints.warehouse_big }  --Functional.Warehouse#WAREHOUSE

      }

    },

    --[[ eliminare se no problema
        Farp ={

          blue = {

            Zestafoni  =    { STATIC:FindByName( "Farp ZESTAFONI" ), "Farp ZESTAFONI",  targetPoints.farp }, --Functional.Warehouse#WAREHOUSE
            Khashuri   =    { STATIC:FindByName( "FARP KHASHURI" ), "FARP KHASHURI",  targetPoints.farp },  --Functional.Warehouse#WAREHOUSE
            Gori       =    { STATIC:FindByName( "FARP GORI" ), "FARP GORI",  targetPoints.farp }   --Functional.Warehouse#WAREHOUSE

          },

          red = {

            Biteta        =  { STATIC:FindByName( "FARP  Biteta" ), "FARP  Biteta",  targetPoints.farp },  --Functional.Warehouse#WAREHOUSE
            Didi          =  { STATIC:FindByName( "FARP Didi" ), "FARP Didi",  targetPoints.farp },   --Functional.Warehouse#WAREHOUSE
            Kvemo_Sba     =  { STATIC:FindByName( "FARP  Kvemo-Sba" ), "FARP  Kvemo-Sba",  targetPoints.farp },   --Functional.Warehouse#WAREHOUSE
            Alagir        =  { STATIC:FindByName( "FARP  Alagir" ), "FARP  Alagir",  targetPoints.farp }   --Functional.Warehouse#WAREHOUSE

          }

        },
    ]]
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


    },


    Stucture = {

      blue = {

        Zestafoni_Railway_Station       =   { STATIC:FindByName( "Zestafoni Railway Station" ), "Zestafoni Railway Station",  targetPoints.station },
        Agara_Railway_Station      =   { STATIC:FindByName( "Agara Railway Station" ), "Agara Railway Station",  targetPoints.station }


      },

      red = {



      }


    },


    -- INSERIRE qui gli altri target: strategic, army e quelli sotto gia' definiti

  }








  -- Zone definite su target strutture (edifici, ponti) startegici (BAI, PINPOINT)
  local zoneTargetStructure = {

    Red_Didi_Bridges = {

      { ZONE:New('Target_Zone_Didi_Bridge_1'), 'Target_Zone_Didi_Bridge_1', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_2'), 'Target_Zone_Didi_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_2'), 'Target_Zone_Didi_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_3'), 'Target_Zone_Didi_Bridge_3', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_4'), 'Target_Zone_Didi_Bridge_4', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_5'), 'Target_Zone_Didi_Bridge_5', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_6'), 'Target_Zone_Didi_Bridge_6', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_7'), 'Target_Zone_Didi_Bridge_7', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_8'), 'Target_Zone_Didi_Bridge_8', targetPoints.bridge },
      { ZONE:New('Target_Zone_Didi_Bridge_9'), 'Target_Zone_Didi_Bridge_5', targetPoints.bridge },
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



    Red_Kutaisi_Bridges = {

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
      { ZONE:New('Target_Zone_Zestafoni_Bridge_9'), 'Target_Zone_Zestafoni_Bridge_5', targetPoints.bridge },
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

      { ZONE:New('Target Zone Gori Storage Area'), 'Target Zone Gori Storage Area', targetPoints.storage_area }

    },

    Blue_Military_Base = {

      { ZONE:New('Target_Zone_Kutaisi_EWR'), 'Target_Zone_Kutaisi_EWR', targetPoints.ewr_site }

    }

  }





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
  -- imposterei target dei red e toglierei il prefisso BLUE verifica la posizione delle zone
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

    GROUP:FindByName('GW_1975 Russian Armor Defence@Nabakevi'),
    GROUP:FindByName('Russian Antitank Defence@Didmukha'),
    GROUP:FindByName('Russian Mechanized Defence@Didmukha'),
    GROUP:FindByName('Russian Antitank Defence@Tskhinvali'),
    GROUP:FindByName('RU HQ AirDefence'),
    GROUP:FindByName('Russian Antitank Defence@Sathiari'),
    GROUP:FindByName('RED GROUND MECHA ATTACK A #026'),
    GROUP:FindByName('RED_HQ'),
    GROUP:FindByName('GW_1975 Russian Mechanized Defence@Oni')

  }

  local blueGroundGroup = {

    GROUP:FindByName('Georgian Armored Defence@Khashuri'),
    GROUP:FindByName('Georgian Antitank Defence@Tsveri B'),
    GROUP:FindByName('Georgian Mechanized Defence@Tsveri'),
    GROUP:FindByName('Mecha Nato Group 1'),
    GROUP:FindByName('GW_1975 Russian Armor Defence@Nabakevi #003'),
    GROUP:FindByName('Georgian AAA HQ'),
    GROUP:FindByName('BLUE_HQ'),
    GROUP:FindByName('Georgian Mechanized Defence@Tkviavi B'),
    GROUP:FindByName('NATO GROUND MECHA ATTACK A #017'),
    GROUP:FindByName('Georgian Mechanized Defence Squad@Tkviavi B')

  }








































  ------------------------------------------------------------------------------  SCORING -------------------------------------------------------------------------------


  Scoring = SCORING:New( "1975_GW_Scoring" )

  Scoring:SetScaleDestroyScore( 100 )

  Scoring:SetScaleDestroyPenalty( 400 )

  --Scoring:AddUnitScore( UNIT:FindByName( "Unit #001" ), 200 )

  -- Test for zone scores.


  for j = 1, #zoneTargetStructure do

    local targetZone = zoneTargetStructure[j]

    for i = 1, #targetZone do

      Scoring:AddZoneScore( targetZone[i][1], targetZone[i][3] )

    end

  end


  for j = 1, #staticObject do

    local targetObject = staticObject[j]

    for i = 1, #targetObject.blue do

      Scoring:AddStaticScore( targetObject.blue[i][1], targetObject.blue[i][3] )

    end

    for i = 1, #targetObject.red do

      Scoring:AddStaticScore( targetObject.red[i][1], targetObject.red[i][3] )

    end

  end



  -- This one is to test scoring on scenery.
  -- Note that you can only destroy scenery with heavy weapons.
  --SceneryZone = ZONE:New( "ScoringZone2" )
  --Scoring:AddZoneScore( SceneryZone, 200 )

  --Scoring:AddStaticScore(STATIC:FindByName( "Shooting Range #010" ), 100 )


  ------------------------------------------------------------------------------------------------------------------------------------------------------------------





























































  -- Crea il blue command center selezionando l'unita' HQ
  HQ_BLUE = GROUP:FindByName( 'BLUE_HQ' )
  blue_command_center = COMMANDCENTER:New( HQ_BLUE, 'BLUE_HQ' )

  -- Crea il blue command center selezionando l'unita' HQ
  HQ_RED = GROUP:FindByName( 'RED_HQ' )
  red_command_center = COMMANDCENTER:New( HQ_RED, 'RED_HQ' )
































  -- WAREHOUSE

  if activeWarehouse then

    logging('info', { 'main' , ' --------------------------------------------------  INIT WAREHOUSE SYSTEM'} )





      -- NOTA BENE: LE WAREHOUSE VANNO INSERITE PRIMA DI TUTTO


      -- Architettura:
      -- master warehouse --> link warehouse --> area warehouse --> link warehouse --> farp warehouse, airbase warehouse, naval warehouse, zone warehouse
      -- master warehouse: contiene tutte i rifornimenti che la fazione ha destinato per il conflitto. Queste rifornimenti servono per rifornire le area-farp-airbase-naval -zonewarehouse attraverso le link warehouse,
      -- per via aerea (in questo caso le master warehouse coincidono con le airbase warehouse) e/o per per via marittima (in questo caso le master warehouse coincidono con le naval warehouse)

      -- link warehouse:warehouse di collegamento che effettuano il servizio di trasferimento da - a, contengon pertanto solo gli asset in fase spostamento

      -- area warehouse: warehouse intermedie che servono da depositi di area per i rifornimenti delle farp-airbase-naval-zone

      -- farp warehouse: warehouse che inviano risorse direttamente alle zone di combattimento tramite via aerea prevalentemente elicotteri

      -- zone warehouse: warehouse che inviano risorse direttamente alle zone di combattimento tramite terra

      -- airbase warehouse: warehouse degli aeroporti (devi capire come collegarle alle A2ADispatch: purtroppo l'implementazione dei CAP squadron utilizza come parametri i template). GLi airbase piu' importanti sono delle master warehouse gli altri sono area warehouse.
      -- Per adesso conviene utilizzare il dispatcher includendo nel numero degli aerei assegnati agli sqadron anche le riserve. Le warehouse puoi utilizzarle per il carburante, le munizione e tutti i mezzi terrestri e per i task
      -- di trasporto rifornimenti (Heli, Aircraft ecc in quanto master-aerea warehouse)

      -- naval warehouse:  warehouse dei porti (prevalentemente dovrebbero esssere dele master warehouse)

      -- Conviene dedicare una missione ad ogni fase disponendo solo i mezzi coinvolti in quella fase

      -- suddividere il codice che definisce i mezzi impiegati nella varie sottofasi in modo da impiegare

      -- WAREHOUSE.Debug = true
      -- WAREHOUSE.Report = true




      -- CONVIENE PER ADESSO DEFINIRE QUI LE QUANTITA' DEGLI ASSET, IN FUTURO SI PUO' UTILIZZARE UNA VARIABILE IN MODO DA IMPLEMENTARE UN'ASSEGNAZIONE DINAMICA DELLE QUANTITA'
      -- NOTA CHE E' POSSIBILE SALVARE LO STATO DELLE WAREHOUSE VERIFICA COME IMPLEMENTARE IL SALVATAGGIO NELLA CHIUSURA DELLA MISSIONE E IL CARICAMENTO ALLA APERTURA


      --[[

        BLUE RESUPPLY LINK

        Tbilisi
        Soganlug    --->  Gori
        Kutaisi     --->  Zestafoni
        Zestafoni   --->  Khashuri
        Khashuri    --->  Gori






      -- red airbase warehouses



        RED RESUPPLY LINK

        Myneralnye  --->  Beslan, Kvemo_Sba
        Mozdok      --->  Beslan, Kvemo_Sba
        Beslan      --->  Kvemo_Sba
        Kvemo_Sba   --->  Didi
        Didi        --->  Biteta

      ]]



      --- WAREHOUSE SCHEDULE TIMING CONFIGURATION

          -- AIR --
    local startReqTimeAir = 10 -- ritardo di avvio delle wh request dopo la schedulazione delle stesse
    local waitReqTimeAir = 600 --600 -- tempo di attesa tra due request successive per asset aerei (10')
    local start_sched = 120 -- 120 start_sched = ritardo in secondi nella attivazione dello scheduler. NOTA: può essere inteso come il tempo necessario per attivare una missione dipendente dall'efficienza della warehouse
    local interval_sched = 3600  -- interval_sched = intervallo in secondi della schedulazione (ciclo) della funzione. Nota: è necessario valutare l'effetto della OnAfterDelivered o OnAfterDead
    local rand_sched = 0.3  -- rand_sched = percentuale di variazione casuale per l'intervallo di schedulazione

    -- GROUND --
    local start_ground_sched = 10 -- start_sched = ritardo in secondi nella attivazione dello scheduler. NOTA: può essere inteso come il tempo necessario per attivare una missione dipendente dall'efficienza della warehouse
    local interval_ground_sched = 5400 -- interval_sched = intervallo in secondi della schedulazione (ciclo) della funzione. Nota: è necessario valutare l'effetto della OnAfterDelivered o OnAfterDead
    local rand_ground_sched = 0.2 -- rand_sched = percentuale di variazione casuale per l'intervallo di schedulazione
    local startReqTimeGround = 10 -- ritardo di avvio delle wh request dopo la schedulazione delle stesse
    local waitReqTimeGround = 600 -- 600 tempo di attesa tra due request successive per asset terrestri (10')




















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

    --[[
    local warehouse = { red = { farp = {}, airbase = {} }, blue = { farp = {}, airbase = {}  }   }

    warehouse_.red.farp.Didi             =   WAREHOUSE:New( staticObject.Warehouse.red.Didi[ 1 ], staticObject.Warehouse.red.Didi[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.red.airbase.Biteta        =   WAREHOUSE:New( staticObject.Warehouse.red.Biteta[ 1 ], staticObject.Warehouse.red.Biteta[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.red.farp.Kvemo_Sba        =   WAREHOUSE:New( staticObject.Warehouse.red.Kvemo_Sba[ 1 ], staticObject.Warehouse.red.Kvemo_Sba[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.red.farp.Alagir           =   WAREHOUSE:New( staticObject.Warehouse.red.Alagir[ 1 ], staticObject.Warehouse.red.Alagir[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.red.airbase.Mineralnye    =   WAREHOUSE:New( staticObject.Warehouse_AB.red.Mineralnye[ 1 ], staticObject.Warehouse_AB.red.Mineralnye[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.red.airbase.Mozdok        =   WAREHOUSE:New( staticObject.Warehouse_AB.red.Mozdok[ 1 ], staticObject.Warehouse_AB.red.Mozdok[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.red.airbase.Beslan        =   WAREHOUSE:New( staticObject.Warehouse_AB.red.Beslan[ 1 ], staticObject.Warehouse_AB.red.Beslan[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.red.airbase.Nalchik       =   WAREHOUSE:New( staticObject.Warehouse_AB.red.Nalchik[ 1 ], staticObject.Warehouse_AB.red.Nalchik[ 2 ])  --Functional.Warehouse#WAREHOUSE


    warehouse_.blue.airbase.Batumi        =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Batumi[ 1 ], staticObject.Warehouse_AB.blue.Batumi[ 2 ])   --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.airbase.Kutaisi       =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Kutaisi[ 1 ],  staticObject.Warehouse_AB.blue.Kutaisi[ 2 ] )  --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.airbase.Kvitiri       =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Kvitiri[ 1 ], staticObject.Warehouse_AB.blue.Kvitiri[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.airbase.Kvitiri_Helo  =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Kvitiri_Helo[ 1 ], staticObject.Warehouse_AB.blue.Kvitiri_Helo[ 2 ])  --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.farp.Zestafoni        =   WAREHOUSE:New( staticObject.Warehouse.blue.Zestafoni[ 1 ], staticObject.Warehouse.blue.Zestafoni[ 2 ] )  --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.farp.Khashuri         =   WAREHOUSE:New( staticObject.Warehouse.blue.Khashuri[ 1 ], staticObject.Warehouse.blue.Khashuri[ 2 ] )  --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.farp.Gori             =   WAREHOUSE:New( staticObject.Warehouse.blue.Gori[ 1 ], staticObject.Warehouse.blue.Gori[ 2 ] )  --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.airbase.Tbilisi       =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Tbilisi[ 1 ], staticObject.Warehouse_AB.blue.Tbilisi[ 2 ] )  --Functional.Warehouse#WAREHOUSE                                      warehouse.Vaziani = WAREHOUSE:New( staticObject.Warehouse_AB.blue.Vaziani[ 1 ], staticObject.Warehouse_AB.blue.Vaziani[ 2 ] )  --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.airbase.Vaziani       =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Vaziani[ 1 ], staticObject.Warehouse_AB.blue.Vaziani[ 2 ] )  --Functional.Warehouse#WAREHOUSE
    warehouse_.blue.airbase.Soganlug      =   WAREHOUSE:New( staticObject.Warehouse_AB.blue.Soganlug[ 1 ], staticObject.Warehouse_AB.blue.Soganlug[ 2 ] )  --Functional.Warehouse#WAREHOUSE

    ]]

    -- elimina questo dopo avere sostituito warehouse con  warehouse_ vedi sopra
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





















    -------------------------------------- red AGIDIR warehouse operations -------------------------------------------------------------------------------------------------------




   --- colonne di rifornimento (fuel, ammo)

   ----  DA FARE INOLTRE IMPLEMENTARE NELLE ALTRE WH LE RICHIESTE AD AGIDIR





    -- END red AGIDIR warehouse operations -------------------------------------------------------------------------------------------------------------------------
















    -------------------------------------- red DIDI warehouse operations -------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse.red.Didi then

        -- escono i cami ma sono fermi

        -- Didi warehouse e' una frontline warehouse: invia gli asset sul campo con task assegnato. Didi e' rifornita da Biteta Warehouse

        logging('info', { 'main' , 'addAsset Didi warehouse'} )

        warehouse.Didi:SetSpawnZone(ZONE:New("Didi Warehouse Spawn Zone"))
        warehouse.Didi:Start()


        -- Didi: link and front farp-wharehouse.  Send resupply to Biteta. Receive resupply from Kvemo_sba, Beslan

        warehouse.Didi:AddAsset(                 "Infantry Platoon Alpha",                   6)
        warehouse.Didi:AddAsset(                ground_group_template_red.antitankA,         6,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)] )
        warehouse.Didi:AddAsset(                ground_group_template_red.antitankB,         6,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)] )
        warehouse.Didi:AddAsset(                ground_group_template_red.antitankC,         6,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)] )
        warehouse.Didi:AddAsset(                air_template_red.CAS_Mi_8MTV2,               12,           WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)] ) -- attack
        warehouse.Didi:AddAsset(                air_template_red.TRAN_MI_26,                 4,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 1500, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)] ) -- attack
        warehouse.Didi:AddAsset(                air_template_red.AFAC_MI_24,                 4,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC
        warehouse.Didi:AddAsset(                air_template_red.AFAC_Mi_8MTV2,              4,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC


        logging('info', { 'main' , 'Define blueFrontZone = ' .. 'blueFrontZone' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa
        logging('info', { 'main' , 'addrequest Didi warehouse'} )


        local didi_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local didi_sched = SCHEDULER:New( warehouse.Didi,

          function()

            local num_mission = 3
            local num_mission_helo = 2
            local depart_time_heli = defineRequestPosition( num_mission_helo ) -- heli mission
            local depart_time = defineRequestPosition( num_mission ) -- ground mission
            local pos = 1
            local pos_heli = 1

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            if true and pos_heli <= num_mission_helo  then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_MI_24V, math.random( min_cas_skill , max_cas_skill ), nil, nil, nil, 'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi') pos_heli = pos_heli + 1  end
            if true and pos_heli <= num_mission_helo  then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_MI_24V, math.random( min_cas_skill , max_cas_skill ), nil, nil, nil, 'ATTACK_ZONE_HELO_Didmukha_Tsveri') pos_heli = pos_heli + 1  end
            -- NON APPAIONO GLI AFAC HELO: sono apparsi cambiando AFAC in NOTHING nel template e cambiando in averege lo skill !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            if true and (pos_heli-2) <= num_mission_helo  then warehouse.Didi:__AddRequest( startReqTimeGround + ( depart_time_heli[ pos_heli-2 ] + 1 ) * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_MI_24, 1, nil, nil, nil, 'ATTACK_ZONE_HELO') end
            if true and (pos_heli-1) <= num_mission_helo then warehouse.Didi:__AddRequest( startReqTimeGround + ( depart_time_heli[ pos_heli-1 ] + 1 ) * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_MI_24, 1, nil, nil, nil, 'ATTACK_ZONE_HELO') end
            -- riutilizzo gli stessi indici in quanto essendo ground veichle appaiono nella warehouse spawn zone diversa dal FARP degli helo
            if true and pos <= num_mission  then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankA, 1, nil, nil, nil, 'tkviavi_attack_1' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, 1, nil, nil, nil, 'tkviavi_attack_2' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankC, 1, nil, nil, nil, 'tseveri_attack_1' ) pos = pos + 1  end

            logging('finer', { 'Didi scheduler function' , 'addRequest Didi warehouse'} )

          end, {}, start_ground_sched * didi_efficiency_influence, interval_ground_sched, rand_ground_sched

        ) -- END SCHEDULER


        attackGroupForAFACSet = {}
        lenAttackGroupForAFACSet = 0

        -- Take care of the spawned units.
        function warehouse.Didi:OnAfterSelfRequest( From,Event,To,groupset,request )

          logging('enter', 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' )
          logging('info', { 'main' , 'warehouse.Didi:OnAfterDelivered(From,Event,To,request) - ' .. 'request.assignment: ' .. request.assignment })

          local groupset = groupset --Core.Set#SET_GROUP
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment of this request.
          local assignment = warehouse.Didi:GetAssignment(request)

          logging('finer', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )


          if assignment == 'tkviavi_attack_1' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.TSKHINVALI[1], 'enemy_attack', false, 1  )


          elseif assignment == 'tkviavi_attack_2' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1  )


          elseif assignment == 'tseveri_attack_1' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1 )


          elseif assignment =='AFAC_ZONE_Tskhunvali_Tkviavi' then


            if lenAttackGroupForAFACSet > 0 then

              local attackgroup = attackGroupForAFACSet[ lenAttackGroupForAFACSet ]
              lenAttackGroupForAFACSet = lenAttackGroupForAFACSet - 1
              logging('finer', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group assegnati a AFAC asset:  ' .. attackgroup:GetObjectNames()} )
              activeAFAC( groupset, attackgroup, afacZone.Didmukha_Tsveri, afacZone.Didmukha_Tsveri, red_command_center, 'AFAC_HELO' )

            else

              logging('warning', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group non disponibili per AFAC asset:  ' .. groupset:GetObjectNames()} )

            end



          elseif assignment == 'AFAC_ZONE_Didmukha_Tsveri' then


            if lenAttackGroupForAFACSet > 0 then -- verifica se c'e' almeno un gruppo CAS dedicato disponibile nella lista di CAS dedicate

              local attackgroup = attackGroupForAFACSet[ lenAttackGroupForAFACSet ] -- assegna il gruppo CAS disponibile prelevandolo dalla lista
              lenAttackGroupForAFACSet = lenAttackGroupForAFACSet - 1 -- diminuisce di 1 il numero di gruppi CAS dedicati disponibili
              logging('finer', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group assegnati a AFAC asset:  ' .. attackgroup:GetObjectNames()} )
              activeAFAC( groupset, attackgroup, afacZone.Tskhunvali_Tkviavi, red_command_center, 'AFAC_HELO' )

            else

              logging('warning', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group non disponibili per AFAC asset:  ' .. groupset:GetObjectNames()} )

            end



          elseif assignment == 'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi' then

            lenAttackGroupForAFACSet = lenAttackGroupForAFACSet + 1
            attackGroupForAFACSet[ lenAttackGroupForAFACSet ] = groupset
            logging('finer', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  - inserito un nuovo attack Group per CAS for AFAC asset' .. '  -  groupsetName: ' .. groupset:GetObjectNames() .. ' - lenAttackGroupForCASforAFACSet: ' .. lenAttackGroupForAFACSet} )
            activeCAS_AFAC( groupset, redFrontZone.TSKHINVALI, 'ATTACK_ZONE_HELO' )



          elseif assignment == 'ATTACK_ZONE_HELO_Didmukha_Tsveri' then

            lenAttackGroupForAFACSet = lenAttackGroupForAFACSet + 1
            attackGroupForAFACSet[ lenAttackGroupForAFACSet ] = groupset
            logging('finer', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  - inserito un nuovo attack Group per CAS for AFAC asset' .. '  -  groupsetName: ' .. groupset:GetObjectNames() .. ' - lenAttackGroupForCASforAFACSet: ' .. lenAttackGroupForAFACSet} )
            activeCAS_AFAC( groupset, redFrontZone.DIDMUKHA, 'ATTACK_ZONE_HELO' )



          elseif assignment == 'JTAC_Didmukha_Tsveri' then

            activeJTAC( 'air', warehouse.Didi, groupset, red_command_center, nil, redFrontZone.DIDMUKHA[1] )
            --activeGO_TO_ZONE_AIR( groupset,  redFrontZone.DIDMUKHA[1], 0.8 )
            --RecceGroundDetection( groupset, red_command_center, true, 10, 10 )


          else

            logging('warning', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )


          end -- if elseif else


        end -- end function warehouse.Didi:OnAfterSelfRequest( From,Event,To,groupset,request )


       -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
       -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati

        function warehouse.Didi:OnAfterAssetDead( From, Event, To, asset, request )

          logging('enter', 'warehouse.Didi:OnAfterAssetDead( From, Event, To, asset, request )' )
          local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment.
          local assignment = warehouse.Didi:GetAssignment( request )

          logging('info', { 'warehouse.Didi:OnAfterAssetDead(From, Event, To, asset, request)' , 'Request @ Kvemo Sba   -   assignment = ' .. assignment .. '  - assetGroupName = ' .. asset.templatename .. ' - asset attribute = ' .. asset.attribute } )


          -- Request resupply for dead asset from Kvemo Sba warehouse.
          warehouse.Kvemo_Sba:AddRequest( warehouse.Didi, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, "Resupply" )

          logging('info', { 'warehouse.Didi:OnAfterAssetDead(From, Event, To, asset, request)' , 'Self Request: asset assignment = ' .. assignment } )

          -- Send asset to Battle zone either now or when they arrive.
          warehouse.Didi:AddRequest( warehouse.Didi, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment )

          logging('exit', 'warehouse.Didi:OnAfterAssetDead( From, Event, To, asset, request )' )

        end -- end function warehouse.Didi:OnAfterAssetDead( From, Event, To, asset, request )


        -- crea una funzione da schedulare ogni 60 minuti (?) per controllare lo stato degli asset nelle warehouse di area e nel caso che questi siano inferiori ad un certo quantitativo
        -- esegui una AddRequest alla warehouse di link. Ricevuta la richiesta la warehouse di link richiede a sua volta l'invio degli asset alla warehouse di riferimento (link, Area o Master)

    end -- wh_activation.Warehouse.red.Didi then

    -- END red DIDI warehouse operations -------------------------------------------------------------------------------------------------------------------------
































    ---------------------------------------------- red BITETA warehouse operations ------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse.red.Biteta then

        -- Biteta warehouse e' una supply line warehouse: funziona da collegamento per il trasferimento degli asset tra i diversi nodi della supply line



        warehouse.Biteta:SetSpawnZone(ZONE:New("Warehouse Biteta Spawn Zone"))

        warehouse.Biteta:Start()

        -- Biteta: front farp-wharehouse.  Receive resupply from Didi

        warehouse.Biteta:AddAsset(                "Infantry Platoon Alpha", 50 )
        warehouse.Biteta:AddAsset(              ground_group_template_red.antitankC,        12,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)])
        warehouse.Biteta:AddAsset(              ground_group_template_red.antitankB,        10,           WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)])
        warehouse.Biteta:AddAsset(              air_template_red.CAS_MI_24V,                12,           WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]    ) -- attack
        warehouse.Biteta:AddAsset(              air_template_red.TRAN_MI_24,                 4,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           1500, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]   ) -- attack
        warehouse.Biteta:AddAsset(              air_template_red.AFAC_MI_24,                 4,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC
        warehouse.Biteta:AddAsset(              air_template_red.AFAC_Mi_8MTV2,              4,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC

        logging('info', { 'main' , 'addAsset Biteta warehouse embe' } )


        local ambrolauri_attack_1 = 'AMBROLAURI_attack_1'
        local chiatura_attack_1 = 'CHIATURA_attack_1'

        logging('info', { 'main' , 'addRequest Biteta warehouse'} )

        --local depart_time = defineRequestPosition(3)
        local biteta_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local biteta_sched = SCHEDULER:New( warehouse.Biteta,

          function()

            local num_mission = 2
            local depart_time = defineRequestPosition( num_mission )
            --local depart_time_heli = defineRequestPosition( 2 ) -- heli mission
            local pos = 1
            --local pos_heli = 1

            if true and pos <= num_mission then warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, 1, nil, nil, nil, 'AMBROLAURI_attack_1' ) pos = pos + 1 end
            if true and pos <= num_mission then warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, 2, nil, nil, nil, 'CHIATURA_attack_1' ) pos = pos + 1 end
            --warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[3] * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, 2, nil, nil, nil, 'PEREVI_APC' ) pos = pos + 1 end

            logging('finer', { 'Biteta scheduler function' , 'addRequest Biteta warehouse'} )

          end, {}, start_ground_sched * biteta_efficiency_influence, interval_ground_sched, rand_ground_sched

        )  -- END SCHEDULER



        -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
        -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati

        function warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)

            logging('enter', 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' )

            local groupset = groupset --Core.Set#SET_GROUP
            local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

            -- Get assignment of this request.
            local assignment=warehouse.Biteta:GetAssignment(request)

            logging('info', { 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

            if assignment == 'AMBROLAURI_attack_1' then

                activeGO_TO_BATTLE_BIS( groupset, blueFrontZone.CZ_AMBROLAURI[1], 'enemy_attack', false, 1)


            elseif assignment == 'CHIATURA_attack_1' then

                activeGO_TO_BATTLE_BIS( groupset, blueFrontZone.CZ_CHIATURA[1], 'enemy_attack', false, 1 )


            else

                logging('warning', { 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )

            end -- if elsif else


            logging('exit', 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' )

        end -- end function

        -- An asset has died ==> request resupply for it.
        function warehouse.Biteta:OnAfterAssetDead(From, Event, To, asset, request)

              logging('enter', 'warehouse.Biteta:OnAfterAssetDead( From, Event, To, asset, request )' )

              local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
              local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

                -- Get assignment.
              local assignment=warehouse.Biteta:GetAssignment(request)



              -- Request resupply for dead asset from Kvemo_Sba.
              warehouse.Kvemo_Sba:AddRequest(warehouse.Biteta, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, nil, nil, nil, nil, "Resupply")
              logging('info', { 'warehouse.Biteta:OnAfterAssetDead(From, Event, To, asset, request)' , 'Request @ Kvemo Sba   -   assignment = ' .. assignment .. '  - assetGroupName = ' .. asset.templatename .. ' - asset attribute = ' .. asset.attribute } )

              -- Send asset to Battle zone either now or when they arrive.
              warehouse.Biteta:AddRequest(warehouse.Biteta, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment)

              logging('exit', 'warehouse.Biteta:OnAfterAssetDead( From, Event, To, asset, request )' )

        end -- end function

    end -- wh_activation.Warehouse.red.Biteta then

    -- END red BITETA warehouse operations --------------------------------------------------------------------------------------------------------------------------

































    ------------------------------------------------- red Warehouse KVEMO_SBA operations -------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse.red.Kvemo_Sba then


        warehouse.Kvemo_Sba:Start()

        -- Kvemo_Sba: link farp-wharehouse.  Send resupply to Didi, Batumi. Receive resupply from Beslan, Mineralny, Alagir, Nalchik

        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankA,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]  )
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankB,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]  )
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankC,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]  )
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.CAS_MI_24V,               12,                WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_bomber_skill)]    ) -- attack
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.CAS_Mi_8MTV2,             12,                WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]   ) -- transport
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.TRAN_MI_26,               10,                WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 20000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]  ) -- transport
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.AFAC_MI_24,                4,                WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.AFAC_Mi_8MTV2,             4,                WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArmorA,          10,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArmorB,          10,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]   ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiAkatsia,     10,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_red_artillery_skill, max_red_artillery_skill)]   ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiGwozdika,    10,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_red_artillery_skill, max_red_artillery_skill)]    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiKatiusha,    10,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_red_artillery_skill, max_red_artillery_skill)]    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiHeavyMortar, 10,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_red_artillery_skill, max_red_artillery_skill)]    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedA,     10,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedB,     10,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedC,     10,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]   ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankA,       10,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]   ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TransportA,       5,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]   ) -- transport
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TransportB,       5,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]   ) -- transport
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TroopTransport,   5,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]   ) -- transport troop


        logging('info', { 'main' , 'addAsset Kvemo_Sba warehouse'} )



        logging('info', { 'main' , 'Define blueFrontZone = ' .. 'blueFrontZone' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa
        logging('info', { 'main' , 'addrequest Kvemo_Sba warehouse'} )


        local kvemo_sba_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local kvemo_sba_sched = SCHEDULER:New( warehouse.Kvemo_Sba,

          function()

            local num_mission = 3
            local num_mission_helo = 2
            local depart_time_heli = defineRequestPosition( num_mission_helo ) -- heli mission
            local depart_time = defineRequestPosition( num_mission ) -- ground mission
            local pos = 1
            local pos_heli = 1

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            if true and pos_heli <= num_mission_helo  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_MI_24V, math.random( min_cas_skill , max_cas_skill ), nil, nil, nil, 'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi') pos_heli = pos_heli + 1  end
            if true and pos_heli <= num_mission_helo  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Mi_8MTV2, math.random( min_cas_skill , max_cas_skill ), nil, nil, nil, 'ATTACK_ZONE_HELO_Didmukha_Tsveri') pos_heli = pos_heli + 1  end
            -- NON APPAIONO GLI AFAC HELO: sono apparsi cambiando AFAC in NOTHING nel template e cambiando in averege lo skill !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            if true and (pos_heli-2) <= num_mission_helo  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + ( depart_time_heli[ pos_heli-2 ] + 1 ) * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_MI_24, 1, nil, nil, nil, 'ATTACK_ZONE_HELO') end
            if true and (pos_heli-1) <= num_mission_helo then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + ( depart_time_heli[ pos_heli-1 ] + 1 ) * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_Mi_8MTV2, 1, nil, nil, nil, 'ATTACK_ZONE_HELO') end
            -- riutilizzo gli stessi indici in quanto essendo ground veichle appaiono nella warehouse spawn zone diversa dal FARP degli helo
            if true and pos <= num_mission  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankA, 1, nil, nil, nil, 'tkviavi_attack' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, 1, nil, nil, nil, 'Transfert to Didi' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Kvemo_Sba:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankC, 1, nil, nil, nil, 'Transfert to Biteta' ) pos = pos + 1  end

            logging('finer', { 'Kvemo_Sba scheduler function' , 'addRequest Kvemo_Sba warehouse'} )

          end, {}, start_ground_sched * kvemo_sba_efficiency_influence, interval_ground_sched, rand_ground_sched

        ) -- END SCHEDULER


        attackGroupForAFACSet = {}
        lenAttackGroupForAFACSet = 0

        -- Take care of the spawned units.
        function warehouse.Kvemo_Sba:OnAfterSelfRequest( From,Event,To,groupset,request )

          logging('enter', 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' )
          logging('info', { 'main' , 'warehouse.Kvemo_Sba:OnAfterDelivered(From,Event,To,request) - ' .. 'request.assignment: ' .. request.assignment })

          local groupset = groupset --Core.Set#SET_GROUP
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment of this request.
          local assignment = warehouse.Kvemo_Sba:GetAssignment(request)

          logging('finer', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )


          if assignment == 'tkviavi_attack' then

             activeGO_TO_BATTLE_BIS( groupset, redFrontZone.TSKHINVALI[1], 'enemy_attack', false, 1 )



          elseif assignment =='AFAC_ZONE_Tskhunvali_Tkviavi' then


            if lenAttackGroupForAFACSet > 0 then

              local attackgroup = attackGroupForAFACSet[ lenAttackGroupForAFACSet ]
              lenAttackGroupForAFACSet = lenAttackGroupForAFACSet - 1
              logging('finer', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group assegnati a AFAC asset:  ' .. attackgroup:GetObjectNames()} )
              activeAFAC( groupset, attackgroup, afacZone.Didmukha_Tsveri, afacZone.Didmukha_Tsveri, red_command_center, 'AFAC_HELO' )

            else

              logging('warning', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group non disponibili per AFAC asset:  ' .. groupset:GetObjectNames()} )

            end



          elseif assignment == 'AFAC_ZONE_Didmukha_Tsveri' then


            if lenAttackGroupForAFACSet > 0 then -- verifica se c'e' almeno un gruppo CAS dedicato disponibile nella lista di CAS dedicate

              local attackgroup = attackGroupForAFACSet[ lenAttackGroupForAFACSet ] -- assegna il gruppo CAS disponibile prelevandolo dalla lista
              lenAttackGroupForAFACSet = lenAttackGroupForAFACSet - 1 -- diminuisce di 1 il numero di gruppi CAS dedicati disponibili
              logging('finer', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group assegnati a AFAC asset:  ' .. attackgroup:GetObjectNames()} )
              activeAFAC( groupset, attackgroup, afacZone.Tskhunvali_Tkviavi, red_command_center, 'AFAC_HELO' )

            else

              logging('warning', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group non disponibili per AFAC asset:  ' .. groupset:GetObjectNames()} )

            end



          elseif assignment == 'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi' then

            lenAttackGroupForAFACSet = lenAttackGroupForAFACSet + 1
            attackGroupForAFACSet[ lenAttackGroupForAFACSet ] = groupset
            logging('finer', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  - inserito un nuovo attack Group per CAS for AFAC asset' .. '  -  groupsetName: ' .. groupset:GetObjectNames() .. ' - lenAttackGroupForCASforAFACSet: ' .. lenAttackGroupForAFACSet} )
            activeCAS_AFAC( groupset, redFrontZone.TSKHINVALI, 'ATTACK_ZONE_HELO' )



          elseif assignment == 'ATTACK_ZONE_HELO_Didmukha_Tsveri' then

            lenAttackGroupForAFACSet = lenAttackGroupForAFACSet + 1
            attackGroupForAFACSet[ lenAttackGroupForAFACSet ] = groupset
            logging('finer', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  - inserito un nuovo attack Group per CAS for AFAC asset' .. '  -  groupsetName: ' .. groupset:GetObjectNames() .. ' - lenAttackGroupForCASforAFACSet: ' .. lenAttackGroupForAFACSet} )
            activeCAS_AFAC( groupset, redFrontZone.DIDMUKHA, 'ATTACK_ZONE_HELO' )



          elseif assignment == 'RECON_ZONE_HELO_Didmukha_Tsveri' then

            activeGO_TO_ZONE_AIR( groupset,  redFrontZone.DIDMUKHA[1], 0.8 )
            RecceGroundDetection( groupset, red_command_center, true, 10, 10 )


          else

            logging('warning', { 'warehouse.Kvemo_Sba:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )


          end -- if elseif else


        end -- end function warehouse.Kvemo_Sba:OnAfterSelfRequest( From,Event,To,groupset,request )


       -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
       -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati

        function warehouse.Kvemo_Sba:OnAfterAssetDead( From, Event, To, asset, request )

          logging('enter', 'warehouse.Kvemo_Sba:OnAfterAssetDead( From, Event, To, asset, request )' )
          local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment.
          local assignment = warehouse.Kvemo_Sba:GetAssignment( request )

          logging('info', { 'warehouse.Kvemo_Sba:OnAfterAssetDead(From, Event, To, asset, request)' , 'Request @ Kvemo Sba   -   assignment = ' .. assignment .. '  - assetGroupName = ' .. asset.templatename .. ' - asset attribute = ' .. asset.attribute } )


          -- Request resupply for dead asset from Kvemo Sba warehouse.
          warehouse.Kvemo_Sba:AddRequest( warehouse.Alagir, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, "Resupply" )

          logging('info', { 'warehouse.Kvemo_Sba:OnAfterAssetDead(From, Event, To, asset, request)' , 'Self Request: asset assignment = ' .. assignment } )

          -- Send asset to Battle zone either now or when they arrive.
          warehouse.Kvemo_Sba:AddRequest( warehouse.Kvemo_Sba, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment )

          logging('exit', 'warehouse.Kvemo_Sba:OnAfterAssetDead( From, Event, To, asset, request )' )

        end -- end function warehouse.Kvemo_Sba:OnAfterAssetDead( From, Event, To, asset, request )


        -- crea una funzione da schedulare ogni 60 minuti (?) per controllare lo stato degli asset nelle warehouse di area e nel caso che questi siano inferiori ad un certo quantitativo
        -- esegui una AddRequest alla warehouse di link. Ricevuta la richiesta la warehouse di link richiede a sua volta l'invio degli asset alla warehouse di riferimento (link, Area o Master)


    end -- wh_activation.Warehouse.red.Kvemo_Sba then
    ------------------------------------------------- END red Warehouse KVEMO_SBA operations -------------------------------------------------------------------------------------------------------------------------

























    ------------------------------------------------- red Warehouse ALAGIR operations -------------------------------------------------------------------------------------------------------------------------



    if wh_activation.Warehouse.red.Alagir then


        warehouse.Alagir:Start()

        -- Alagir: link wharehouse.  Send resupply to Didi, Kvemo_Sba. Receive resupply from Beslan, Mineralnye, Nalchik

        logging('info', { 'main' , 'addAsset Kvemo_Sba warehouse'} )

        warehouse.Alagir:AddAsset(               air_template_red.CAS_MI_24V,               52,                WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_bomber_skill)]    ) -- attack
        warehouse.Alagir:AddAsset(               air_template_red.CAS_Mi_8MTV2,             52,                WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]   ) -- transport
        warehouse.Alagir:AddAsset(               air_template_red.TRAN_MI_26,               50,                WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 20000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]  ) -- transport
        warehouse.Alagir:AddAsset(               air_template_red.AFAC_MI_24,               50,                WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC
        warehouse.Alagir:AddAsset(               air_template_red.AFAC_Mi_8MTV2,            50,                WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC
        warehouse.Alagir:AddAsset(               ground_group_template_red.antitankA,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]  )
        warehouse.Alagir:AddAsset(               ground_group_template_red.antitankB,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]  )
        warehouse.Alagir:AddAsset(               ground_group_template_red.antitankC,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]  )
        warehouse.Alagir:AddAsset(               ground_group_template_red.ArmorA,          50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]    ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.ArmorB,          50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]   ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.ArtiAkatsia,     50,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_red_artillery_skill, max_red_artillery_skill)]   ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.ArtiGwozdika,    50,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_red_artillery_skill, max_red_artillery_skill)]    ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.ArtiKatiusha,    50,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_red_artillery_skill, max_red_artillery_skill)]    ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.ArtiHeavyMortar, 50,                WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_red_artillery_skill, max_red_artillery_skill)]    ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.mechanizedA,     50,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]    ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.mechanizedB,     50,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]    ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.mechanizedC,     50,                WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]   ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.antitankA,       50,                WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_red_tank_skill, max_red_tank_skill)]   ) -- Ground troops
        warehouse.Alagir:AddAsset(               ground_group_template_red.TransportA,      50,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]   ) -- transport
        warehouse.Alagir:AddAsset(               ground_group_template_red.TransportB,      50,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]   ) -- transport
        warehouse.Alagir:AddAsset(               ground_group_template_red.TroopTransport,  50,                WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_red_ground_skill, max_red_ground_skill)]   ) -- transport troop




        logging('info', { 'main' , 'addrequest Alagir warehouse'} )

        local alagir_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local kvemo_sba_sched = SCHEDULER:New( warehouse.Alagir,

          function()

            local num_mission = 3
            local num_mission_helo = 2
            local depart_time_heli = defineRequestPosition( num_mission_helo ) -- heli mission
            local depart_time = defineRequestPosition( num_mission ) -- ground mission
            local pos = 1
            local pos_heli = 1

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            if true and pos_heli <= num_mission_helo  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_MI_24V, math.random( min_cas_skill , max_cas_skill ), nil, nil, nil, 'Transfer to Biteta') pos_heli = pos_heli + 1  end
            if true and pos_heli <= num_mission_helo  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time_heli[ pos_heli ] * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Mi_8MTV2, math.random( min_cas_skill , max_cas_skill ), nil, nil, nil, 'Transfer to Kvemo_Sba') pos_heli = pos_heli + 1  end
            -- inserisci missioni cargoSet

            -- riutilizzo gli stessi indici in quanto essendo ground veichle appaiono nella warehouse spawn zone diversa dal FARP degli helo
            if true and pos <= num_mission  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Biteta,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankA, 1, nil, nil, nil, 'Trasnfert to Batumi' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Kvemo_Sba,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, 1, nil, nil, nil, 'Transfert to Kvemo_Sba' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Alagir:__AddRequest( startReqTimeGround + depart_time[ pos ]  * waitReqTimeGround, warehouse.Didi,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankC, 1, nil, nil, nil, 'Transfert to Didi' ) pos = pos + 1  end

            logging('finer', { 'Alagir scheduler function' , 'addRequest Alagir warehouse'} )

          end, {}, start_ground_sched * alagir_efficiency_influence, interval_ground_sched, rand_ground_sched

        ) -- END SCHEDULER


    end -- wh_activation.Warehouse.red.Didi then

    ------------------------------------------------- END Warehouse ALAGIR operations -------------------------------------------------------------------------------------------------------------------------





























    ---------------------------------------------------------------- red Mineralnye warehouse operations -------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse_AB.red.Mineralnye then


        logging('info', { 'main' , 'init Warehouse MINERALNYE operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa

        warehouse.Mineralnye:Start()


        -- Mineralnye e' una delle principale warehouse russe nell'area. Qui sono immagazzinate la maggior parte degli asset da impiegare nella zona dei combattimenti
        -- Send resupply to Kvemo_Sba

        logging('info', { 'main' , 'addAsset Mineralnye warehouse'} )

        warehouse.Mineralnye:AddAsset(            air_template_red.CAP_Mig_21Bis,             10,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)] ) -- Fighter
        warehouse.Mineralnye:AddAsset(            air_template_red.GCI_Mig_21Bis,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]  )
        warehouse.Mineralnye:AddAsset(            air_template_red.BOM_SU_24_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  ) -- Bomber - Cas
        warehouse.Mineralnye:AddAsset(            air_template_red.BOM_TU_22_Bomb,            10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mineralnye:AddAsset(            air_template_red.BOM_SU_24_Structure,       10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mineralnye:AddAsset(            air_template_red.CAS_Su_17M4_Rocket,        10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mineralnye:AddAsset(            air_template_red.CAS_L_39C_Rocket,          10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mineralnye:AddAsset(            air_template_red.CAS_Mig_27K_Bomb,          10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mineralnye:AddAsset(            air_template_red.GA_SU_24M_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mineralnye:AddAsset(            air_template_red.AWACS_TU_22,                 3,          WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_red_awacs_skill, max_red_awacs_skill)]  )
        warehouse.Mineralnye:AddAsset(            air_template_red.CAS_MI_24V,                10,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]       ) -- attack
        warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_MI_24,                24,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]  ) -- transport
        warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_AN_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]    ) -- transport
        warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_MI_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skillr_skill)]    ) -- transport
        warehouse.Mineralnye:AddAsset(            ground_group_template_red.Truck,            3 )



        logging('info', { 'main' , 'addrequest Mineralnye warehouse'} )




        local mineralnye_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local mineralnye_sched = SCHEDULER:New( staticObject.Warehouse_AB.red.Mineralnye[ 1 ],

          function()

            local num_mission = 8
            local depart_time = defineRequestPosition( num_mission )
            local pos = 1

            if true and pos <= num_mission then warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Bomb, math.random( 2 , 3 ), nil, nil, nil, "BAI POINT") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, math.random( 2 , 3 ), nil, nil, nil, "PATROL") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_TU_22_Bomb, math.random( 1 , 2 ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random( 2 , 3 ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random( 2 , 3 ), nil, nil, nil, "BOMBING STRUCTURE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( 2 , 3 ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_TU_22_Bomb, math.random( 1 , 2 ), nil, nil, nil, "BOMBING FARM") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.TRAN_MI_26, math.random( 3 , 5 ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
            logging('info', { 'main' , 'Mineralnye scheduler - start time:' .. start_sched *  mineralnye_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * ( 1 + rand_sched)} )

          end, {}, start_sched * mineralnye_efficiency_influence, interval_sched, rand_sched

        ) -- end mineralnye_sched = SCHEDULER:New( nil, ..)


          -- Do something with the spawned aircraft.
        function warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)

          --local groupset=groupset --Core.Set#SET_GROUP
          --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI POINT" then


            local avalaible_target_zones = {

                zoneTargetStructure.Red_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kutaisi_Bridges) ][1],
                zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
                zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
                zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
                zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

            }

            local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
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
            local target = zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges ) ][1]
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
            local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Mineralnye", 5000, nil)
            local pickupZone =  cargoZone.Warehouse_AB.red.Mineralnye
            local deployZone =  cargoZone.Warehouse.red.Alagir
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )



          else

            logging('warning', { 'warehouse.Myneralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

          end-- end if..elseif

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

    if wh_activation.Warehouse_AB.red.Mozdok then


        -- Mozdok e' una delle principale warehouse russe nell'area. Qui sono immagazzinate la maggior parte degli asset da impiegare nella zona dei combattimenti
        -- Send resupply to Kvemo_Sba, Beslan
        -- warehouse.Didi:SetSpawnZone(ZONE:New("Didi Warehouse Spawn Zone"))

        logging('info', { 'main' , 'addAsset Mozdok warehouse'} )

        warehouse.Mozdok:Start()

        warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_21Bis,             10,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]   )
        --warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_23MLD,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]   )
        --warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_25PD,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]   )
        --warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_19P,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]   )
        warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_21Bis,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]   )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_23MLD,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]   )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_25PD,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]   )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_19P,             15,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]   )
        warehouse.Mozdok:AddAsset(                air_template_red.BOM_SU_24_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mozdok:AddAsset(                air_template_red.BOM_SU_24_Structure,       10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mozdok:AddAsset(                air_template_red.BOM_TU_22_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.BOM_TU_22_Nuke,             5,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_bomber_skill, max_red_bomber_skill)]  )
        warehouse.Mozdok:AddAsset(                air_template_red.AWACS_TU_22,                  1,         WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_red_awacs_skill, max_red_awacs_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.AWACS_Mig_25RTB,                  1,         WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_red_awacs_skill, max_red_awacs_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAS_Su_17M4_Rocket,        10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  ) -- CAS
        --warehouse.Mozdok:AddAsset(                air_template_red.CAS_Su_17M4_Bomb,        10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        warehouse.Mozdok:AddAsset(                air_template_red.CAS_Mig_27K_Rocket,      10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        warehouse.Mozdok:AddAsset(                air_template_red.CAS_MI_24V,                12,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]     ) -- attack
        --warehouse.Mozdok:AddAsset(                air_template_red.CAS_L_39C_Rocket,        10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAS_Mi_8MTV2,            10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        warehouse.Mozdok:AddAsset(                air_template_red.GA_SU_24M_Bomb,             1,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.GA_SU_24M_HRocket,        1,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.GA_SU_24M_HBomb,          1,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.GA_Mig_27K_Sparse_Light, 10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.GA_Mig_27K_ROCKET_Heavy, 10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        --warehouse.Mozdok:AddAsset(                air_template_red.GA_Mig_27K_ROCKET_Light, 10,         WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_skill)]  )
        warehouse.Mozdok:AddAsset(                air_template_red.TRAN_MI_24,                12,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           1500, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]  ) -- transport
        warehouse.Mozdok:AddAsset(                air_template_red.TRAN_MI_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)] ) -- transport
        warehouse.Mozdok:AddAsset(                air_template_red.TRAN_AN_26,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)] ) -- transport
        --warehouse.Mozdok:AddAsset(                air_template_red.TRAN_YAK_40,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)]  ) -- transport
        --warehouse.Mozdok:AddAsset(                air_template_red.AFAC_Yak_52,                4,          WAREHOUSE.Attribute.AIR_OTHER,           9000, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)]  ) -- afac
        --warehouse.Mozdok:AddAsset(                air_template_red.AFAC_L_39C,                4,          WAREHOUSE.Attribute.AIR_OTHER,           9000, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)]  ) -- afac
        --warehouse.Mozdok:AddAsset(                air_template_red.AFAC_Mi_8MTV2,                4,          WAREHOUSE.Attribute.AIR_OTHER,           9000, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)]  ) -- afac
        --warehouse.Mozdok:AddAsset(                air_template_red.AFAC_MI_24,                4,          WAREHOUSE.Attribute.AIR_OTHER,           9000, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)]  ) -- afac



        logging('info', { 'main' , 'addrequest Mozdok warehouse'} )


        local mozdok_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local mozdok_sched = SCHEDULER:New( staticObject.Warehouse_AB.red.Mozdok[ 1 ],

          function()

            local num_mission = 9
            local depart_time = defineRequestPosition(9)
            local pos = 1
            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random(3, 5), nil, nil, nil, "BAI POINT") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Rocket, math.random(3, 5), nil, nil, nil, "BAI TARGET") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_TU_22_Bomb, math.random(4, 6), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, math.random(2, 4), nil, nil, nil, "PATROL") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random(4, 6), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(4, 6), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random(4, 6), nil, nil, nil, "BOMBING FARM") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random(4, 6), nil, nil, nil, "BOMBING STRUCTURE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.TRAN_MI_26, math.random(4, 6), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end

            logging('info', { 'main' , 'Mozdok scheduler - start time:' .. start_sched *  mozdok_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )


          end, {}, start_sched * mozdok_efficiency_influence, interval_sched, rand_sched

        ) -- end mozdok_sched = SCHEDULER:New( nil, ..)

        -- Do something with the spawned aircraft.
        function warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)

          --local groupset=groupset --Core.Set#SET_GROUP
          --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI POINT" then

            local avalaible_target_zones = {

                zoneTargetStructure.Red_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kutaisi_Bridges) ][1],
                zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
                zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
                zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
                zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

            }

            local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
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
            local target = blueGroundGroup[ math.random( 1, #blueGroundGroup ) ]
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
            local target = zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges ) ][1]
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
            local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Mozdok", 5000, nil)

            local pickupZone =  cargoZone.Warehouse_AB.red.Mozdok
            local deployZone =  cargoZone.Warehouse.red.Alagir
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )


          else

            logging('warning', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

          end -- end if..elseif

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

    if wh_activation.Warehouse_AB.red.Beslan then

        logging('info', { 'main' , 'addAsset Beslan warehouse'} )

        warehouse.Beslan:Start()

        -- Beslan e' una delle principale warehouse russe nell'area.
        -- Receive reupply from Mozdok and Mineralnye. Send resupply to Kvemo_Sba

        warehouse.Beslan:AddAsset(               air_template_red.CAP_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.GCI_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.CAS_MI_24V,                10,           WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]       ) -- attack
        warehouse.Beslan:AddAsset(               air_template_red.CAS_Su_17M4_Rocket,        10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.CAS_Su_17M4_Bomb,          10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.CAS_Su_17M4_Cluster,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.CAS_Mig_27K_Bomb,          10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.CAS_Mig_27K_Rocket,        10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.GA_Mig_27K_ROCKET_Heavy,   10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.GA_Mig_27K_ROCKET_Light,   10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.GA_Mig_27K_Bomb_Light,     10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        --warehouse.Beslan:AddAsset(               air_template_red.BOM_SU_24_Bomb,            10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.BOM_SU_24_Structure,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Beslan:AddAsset(               air_template_red.BOM_MIG_27K_Airbase,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)] )
        warehouse.Beslan:AddAsset(               air_template_red.BOM_MIG_27K_Structure,     10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)] )
        --warehouse.Beslan:AddAsset(               air_template_red.BOM_SU_17_Structure,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)] )

        warehouse.Beslan:AddAsset(               air_template_red.TRAN_MI_24,                24,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500, nil, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]  ) -- transport
        warehouse.Beslan:AddAsset(               air_template_red.TRAN_MI_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]   ) -- transport
        warehouse.Beslan:AddAsset(               air_template_red.TRAN_AN_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]   ) -- transport
        warehouse.Beslan:AddAsset(               air_template_red.TRAN_AN_YAK_40,             4,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE, nil, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)] ) -- transport
        warehouse.Beslan:AddAsset(               air_template_red.AFAC_L_39C,                 4,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC
        warehouse.Beslan:AddAsset(               air_template_red.AFAC_Yak_52,                4,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)] ) -- AFAC

        logging('info', { 'main' , 'AddRequest Beslan warehouse'} )




        local beslan_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local beslan_sched = SCHEDULER:New( staticObject.Warehouse_AB.red.Beslan[ 1 ],

          function()

            local num_mission = 9
            local depart_time = defineRequestPosition( num_mission )
            local pos = 1

            if true and pos <= num_mission  then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Cluster, math.random(3, 4), nil, nil, nil, "BAI TARGET") pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Mig_27K_Bomb, math.random(3, 4), nil, nil, nil, "BAI TARGET 2") pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AWACS_Mig_25RTB, math.random(1, 2), nil, nil, nil, "AWACS") pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_MIG_27K_Structure, math.random(2, 3), nil, nil, nil, "BAI BOMBING STRUCTURE") pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_MIG_27K_Airbase, math.random(2, 3), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_MIG_27K_Structure, math.random(2, 3), nil, nil, nil, "BOMBING STRUCTURE GORI") pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(2, 3), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(2, 3), nil, nil, nil, "BOMBING STRUCTURE TBILISI") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.TRAN_MI_26, math.random(3, 5), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
            logging('info', { 'main' , 'Beslan scheduler - start time:' .. start_sched *  beslan_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * ( 1 + rand_sched)} )

          end, {}, start_sched * beslan_efficiency_influence, interval_sched, rand_sched

        )


        -- Do something with the spawned aircraft.
        function warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)

          --local groupset=groupset --Core.Set#SET_GROUP
          --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TARGET" then

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = blueGroundGroup[ math.random( 1, #blueGroundGroup ) ]
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


            --local homeAirbase =  AIRBASE.Caucasus.Beslan
            --local patrolZone =  redPatrolZone.beslan[1]
            --local engageRange = math.random(10000, 20000)
            --local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
            --local patrolFloorAltitude = 4000
            --local patrolCeilAltitude = 9000
            --local minSpeedPatrol = 400
            --local maxSpeedPatrol = 600
            --local minSpeedEngage = 600
            --local maxSpeedEngage = 1000

            logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. redPatrolZone.beslan[1]:GetName() } )
            --logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

            activeAWACS( groupset, warehouse.Beslan, blue_command_center, nil, redAwacsZone.beslan, math.random(6000, 9000), 6000 )





          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
          elseif request.assignment == "BAI TARGET 2" then


            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = blueGroundGroup[ math.random( 1, #blueGroundGroup ) ]
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

            local avalaible_target_zones = {

                zoneTargetStructure.Red_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kutaisi_Bridges) ][1],
                zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
                zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
                zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
                zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

            }

            local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
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
            local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Beslan", 5000, nil)
            local pickupZone =  cargoZone.Warehouse_AB.red.Beslan
            local deployZone =  cargoZone.Warehouse.red.Alagir
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )


          else

            logging('warning', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

          end -- end if..elseif

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

    if wh_activation.Warehouse_AB.red.Nalchik then



        warehouse.Nalchik:Start()
        -- Nalchik e' una delle principale warehouse russe nell'area.
        -- Receive reupply from Mozdok and Mineralnye. Send resupply to Kvemo_Sba

        warehouse.Nalchik:AddAsset(               air_template_red.CAP_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_skill, max_red_fighter_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.GCI_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(3, 6)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.CAS_MI_24V,                10,           WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]       ) -- attack
        warehouse.Nalchik:AddAsset(               air_template_red.CAS_Su_17M4_Rocket,        10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.CAS_Su_17M4_Bomb,          10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.CAS_Su_17M4_Cluster,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.CAS_Mig_27K_Bomb,          10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        --warehouse.Nalchik:AddAsset(               air_template_red.CAS_Mig_27K_Rocket,        10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.GA_Mig_27K_ROCKET_Heavy,   10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.GA_Mig_27K_ROCKET_Light,   10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.GA_Mig_27K_Bomb_Light,     10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        --warehouse.Nalchik:AddAsset(               air_template_red.BOM_SU_24_Bomb,            10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.BOM_SU_24_Structure,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.BOM_SU_17_Structure,       10,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_red_fighter_bomber_skill, max_red_fighter_bomber_skill)]  )
        warehouse.Nalchik:AddAsset(               air_template_red.TRAN_MI_24,                24,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]   ) -- transport
        warehouse.Nalchik:AddAsset(               air_template_red.TRAN_MI_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]   ) -- transport
        warehouse.Nalchik:AddAsset(               air_template_red.TRAN_AN_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]   ) -- transport
        warehouse.Nalchik:AddAsset(               air_template_red.TRAN_AN_YAK_40,             4,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE, nil, nil, nil, AI.Skill[ math.random(min_red_transport_skill, max_red_transport_skill)]  ) -- transport
        warehouse.Nalchik:AddAsset(               air_template_red.AFAC_L_39C,                 4,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)]  ) -- AFAC
        warehouse.Nalchik:AddAsset(               air_template_red.AFAC_Yak_52,                4,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_red_afac_skill, max_red_afac_skill)]  ) -- AFAC

        logging('info', { 'main' , 'addAsset Nalchik warehouse'} )



        logging('info', { 'main' , 'addrequest Nalchik warehouse'} )


        local nalchik_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local nalchik_sched = SCHEDULER:New( staticObject.Warehouse_AB.red.Nalchik[ 1 ],

          function()


            local num_mission = 8
            local depart_time = defineRequestPosition( num_mission )
            local pos = 1

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Rocket, math.random(3, 5), nil, nil, nil, "BAI TARGET") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, math.random(3, 5), nil, nil, nil, "PATROL") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, math.random(3, 5), nil, nil, nil, "PATROL") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.GA_Mig_27K_Bomb_Light, math.random(3, 5), nil, nil, nil, "BAI TARGET 2") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Structure, math.random(3, 5), nil, nil, nil, "BAI POINT") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Cluster, math.random(3, 5), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Cluster, math.random(3, 5), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Bomb, math.random(3, 5), nil, nil, nil, "BOMBING STRUCTURE KHASHURI") pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.TRAN_MI_26, math.random(3, 5), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
            logging('info', { 'main' , 'Nalchik scheduler - start time:' .. start_sched *  nalchik_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

          end, {}, start_sched * nalchik_efficiency_influence, interval_sched, rand_sched

        )


        -- Do something with the spawned aircraft.
        function warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)

          --local groupset=groupset --Core.Set#SET_GROUP
          --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TARGET" then

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = blueGroundGroup[ math.random( 1, #blueGroundGroup ) ]
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


            local avalaible_target_zones = {

                zoneTargetStructure.Red_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kutaisi_Bridges) ][1],
                zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
                zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
                zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
                zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

            }

            local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
            local patrolZone = redPatrolZone.nalchik[1]

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Nalchik against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )




          ------------------------------------------------------------------------------------------------------ assignment for BAI
          elseif request.assignment == "BAI POINT" then

            local avalaible_target_zones = {

                zoneTargetStructure.Red_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kutaisi_Bridges) ][1],
                zoneTargetStructure.Blue_Zestafoni_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Zestafoni_Bridges) ][1],
                zoneTargetStructure.Blue_Gori_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Gori_Bridges) ][1],
                zoneTargetStructure.Blue_Tbilisi_Bridges[ math.random( 1, #zoneTargetStructure.Blue_Tbilisi_Bridges) ][1],
                zoneTargetStructure.Blue_Military_Base[math.random( 1, #zoneTargetStructure.Blue_Military_Base) ][1]

            }

            local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
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
            local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Nalchik", 5000, nil)
            local pickupZone =  cargoZone.Warehouse_AB.red.Nalchik
            local deployZone =  cargoZone.Warehouse.red.Alagir
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )

          else

            logging('warning', { 'warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'no task defined for this request ' } )

          end -- end if ..elseif

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





    ------------------------------------------------- blue Warehouse BATUMI operations -------------------------------------------------------------------------------------------------------------------------


    if wh_activation.Warehouse_AB.blue.Batumi then


        --  Batumi e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Batumi - Zestafoni - Gori
        -- Batumi e' utilizzato come aeroporto militare. Da Batumi decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.



        warehouse.Batumi:Start()

        -- warehouse.Batumi:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        warehouse.Batumi:AddAsset(              air_template_blue.CAP_F_5,                  10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
        warehouse.Batumi:AddAsset(              air_template_blue.CAP_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.GCI_F_4,                  5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.GCI_F_14A,                5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.GCI_F_14A,                5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_F_4E_Rocket,          5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.REC_F_4,                  5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_F_4_E_Structure,      5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_F_4_E_Sparse_Heavy,   5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_F_4_E_Sparse_Light,   5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_F_4_E_Sparse_Cluster, 5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_AV_88_Structure,      5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_AV_88_Heavy_Structure,  5,         WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_AV_88_Bomb,           5,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_AV_88_Cluster,        5,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_AV_88_Rocket,         5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_F_5E_3_Bomb,          5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_F_5E_3_Rocket,        5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.CAS_F_5E_3_Cluster,       5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_B_1B,                 5,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_bomber_skill, max_blue_bomber_skill)]  )
        warehouse.Batumi:AddAsset(              air_template_blue.BOM_B_52H,                5,           WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_bomber_skill, max_blue_bomber_skill)]  )
        -- warehouse.Batumi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber BAI
        -- warehouse.Batumi:AddAsset(               air_template_blue.CAS_Su_17M4_Rocket,       10, nil, nil, nil, AI.Skill[ math.random(3, 6)]   ) --  CAS
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_AN_26,                5,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE, 9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_C_130,                6,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE, 9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Batumi:AddAsset(               air_template_blue.TRAN_UH_1H,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport ) -- Transport
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_UH_60A,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,  4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_CH_47,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 12700, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        -- warehouse.Batumi:AddAsset(               air_template_blue.TRAN_MI_24,             6,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500 ) -- Transport
        -- warehouse.Batumi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,        10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(3, 6)]  ) -- Bomber
        warehouse.Batumi:AddAsset(               air_template_blue.AWACS_F_4,                       10,            WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_blue_awacs_skill, max_blue_awacs_skill)]     ) -- Heli CAS
        warehouse.Batumi:AddAsset(              air_template_blue.AWACS_B_1B,                      2,             WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_blue_awacs_skill, max_blue_awacs_skill)]  ) -- AWACS

        logging('info', { 'main' , 'addAsset Batumi warehouse'} )




        local batumi_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local batumi_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Batumi[ 1 ],

          function()

             local num_mission = 9
             local depart_time = defineRequestPosition( num_mission )
             local pos = 1

             -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive

             if false and pos <= num_mission  then  warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Cluster, math.random( 2 , 3 ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if false and pos <= num_mission  then warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_B_1B, 1, nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if false and pos <= num_mission  then warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_B_1B, math.random( 1 , 2 ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
             if false and pos <= num_mission  then warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_B_52H, math.random( 1 , 2 ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
             if false and pos <= num_mission  then warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_B_52H, math.random( 1 , 2 ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
             if true and pos <= num_mission  then warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_C_130, math.random( 1 , 4 ), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
             if true and pos <= num_mission  then warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( 1 , 4 ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
             if true and pos <= num_mission  then warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AWACS_B_1B, 1, nil, nil, nil, "AWACS") pos = pos + 1  end
             if true and pos <= num_mission  then warehouse.Batumi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Batumi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.REC_F_4, math.random( 1 , 2 ), nil, nil, nil, "RECON AIRBASE") pos = pos + 1  end
             logging('info', { 'main' , 'Tblisi scheduler - start time:' .. start_sched *  batumi_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

          end, {}, start_sched *  batumi_efficiency_influence, interval_sched, rand_sched

        ) -- end  tblisi_sched = SCHEDULER:New( nil, ..)



        -- Do something with the spawned aircraft.
        function warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)



          logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })



          ------------------------------------------------------------------------------------------------------ assignment for BAI asset

          if request.assignment == "BAI TARGET" then

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ]
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


              local avalaible_target_zones = {

                  zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                  zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                  --zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

              }

              local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
              local patrolZone = bluePatrolZone.kutaisi[1]

              speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

              activeBAI( 'Interdiction from Batumi against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )






          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset

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

            activeAWACS( groupset, warehouse.Batumi, blue_command_center, nil, blueAwacsZone.gori, math.random(6000,8000), 5000 )





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



              -- vedi:
              -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/PLN%20-%20Airplane/AIC-PLN-000%20-%20Airplane/AIC-PLN-000%20-%20Airplane.lua
              -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Airplane.html
              -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

              --local vehicleGroup = GROUP:FindByName( "Cargo Vehicles Batumi" )
              -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :
              --local vehicleCargo = CARGO_GROUP:New( vehicleGroup, "Vehicles", "Cargo Vehicles", 5000 )

              --local cargoGroupSet = SET_CARGO:New():FilterTypes( "Vehicles" ):FilterStart()
              --local  = SET_CARGO:New():FilterPrefixes('Vehicles'):FilterStart()


              -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
              local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Nalchik", 5000, nil)

              local destination = AIRBASE.Caucasus.Tbilisi_Lochini --airbase_blue[ math.random( 1 , #airbase_blue ) ]
              local speed = math.random( 300 , 500 )

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - : ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count: ' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )

              activeCargoAirPlane( groupset, AIRBASE.Caucasus.Batumi, destination, speed, cargoGroupSet )

              --logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )
              --activeCargo('airplane', groupset, AIRBASE.Caucasus.Batumi, destination, 'Vehicles',"Cargo Vehicles Batumi", speed)







          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY FARP" then


            -- vedi:
            -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/HEL%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter.lua
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Helicopter.html
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

            --local infantryGroup = GROUP:FindByName( "Cargo Infantry Batumi" )
            -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :   https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New
            --local infantryCargo = CARGO_GROUP:New( infantryGroup, "Infantry", "Cargo Infantry", 5000 )

            --local cargoGroupSet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()

            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Nalchik", 5000, nil)

            local pickupZone =  cargoZone.Warehouse_AB.blue.Batumi
            local deployZone =  cargoZone.Warehouse.blue.Gori
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - : ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count: ' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )
            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )

            --logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - speed: ' .. speed .. ' - destination: ' .. deployZone:GetName() } )
            --activeCargo('helicopter', groupset, pickupZone, deployZone, 'Infantry',"Cargo Infantry Batumi", speed)



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


              activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )

              logging('info', { 'warehouse.Batumi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home:GetName() .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

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

    if wh_activation.Warehouse_AB.blue.Kutaisi then


        warehouse.Kutaisi:Start()

        --  Kutaisi e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Kutaisi - Zestafoni - Gori
        -- Kutaisi e' utilizzato come aeroporto militare. Da Kutaisi decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.

        warehouse.Kutaisi:AddAsset(               air_template_blue.CAP_Mig_21Bis,            20,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]   ) -- Fighter
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAP_F_5,                  20,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]   ) -- Fighter
        warehouse.Kutaisi:AddAsset(               air_template_blue.REC_L_39C,                10,            WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_recon_skill, max_blue_recon_skill)]  ) -- Reco
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_Su_17M4_Rocket,       10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_F_5E_3_Rocket,        10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_F_5E_3_Cluster,       10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,          10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_L_39ZA_HRocket,       10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_AN_26,                5,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_C_130,                5,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport ) -- Transport
        --warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_UH_60A,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport
        warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_CH_47,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        --warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_MI_24,                6,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber
        --warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_MI_24V,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]    ) -- Heli CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.AWACS_F_4,                  2,             WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_blue_awacs_skill, max_blue_awacs_skill)] ) -- AWACS
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.Truck,           3,             WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankA,       10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankB,       10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankC,       10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArmorA,          10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArmorB,          10,            WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,            WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,            WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedA,     10,            WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedB,     10,            WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]    ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedC,     10,            WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]    ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TransportA,       6,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TransportB,       4,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TroopTransport,   4,            WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport

        logging('info', { 'main' , 'addAsset Kutaisi warehouse'} )





        local kutaisi_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local kutaisi_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Kutaisi[ 1 ],

          function()

             local num_mission = 11
             local depart_time = defineRequestPosition( num_mission )
             local pos = 1

             -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
             if false and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Cluster, math.random( 2 , 3 ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if false and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random( 2 , 3 ), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if false and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, math.random( 2 , 3 ), nil, nil, nil, "PATROL") pos = pos + 1  end
             if false and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random( 2 , 3 ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
             if false and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( 2 , 3 ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
             if false and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random( 2 , 3 ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_C_130, math.random( 1 , 2 ), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( 2 , 3 ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, math.random( 2 , 4 ), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AWACS_F_4, math.random( 1 , 2 ), nil, nil, nil, "AWACS") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Kutaisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.REC_L_39C, math.random( 1 , 2 ), nil, nil, nil, "RECON FARP") pos = pos + 1  end
             logging('info', { 'main' , 'Tblisi scheduler - start time:' .. start_sched *  kutaisi_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

          end, {}, start_sched *  kutaisi_efficiency_influence, interval_sched, rand_sched

      ) -- end  tblisi_sched = SCHEDULER:New( nil, ..)



      -- Do something with the spawned aircraft.
      function warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)



        logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })



        ------------------------------------------------------------------------------------------------------ assignment for BAI asset
        if request.assignment == "BAI TARGET" then

          speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

          -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
          local percRequestKill = math.random( 0 , 100 ) * 0.01
          local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ]
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


            local avalaible_target_zones = {

                zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                --zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

            }

            local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
            local patrolZone = bluePatrolZone.kutaisi[1]

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Kutaisi against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )






        ------------------------------------------------------------------------------------------------------ assignment for PATROL asset

        elseif request.assignment == "AWACS" then

          --local homeAirbase =  AIRBASE.Caucasus.Kutaisi
          --local patrolZone =  bluePatrolZone.kutaisi[1]
          --local engageRange = math.random(10000, 20000)
          --local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
          --local patrolFloorAltitude = 7000
          --local patrolCeilAltitude = 9000
          --local minSpeedPatrol = 400
          --local maxSpeedPatrol = 600
          --local minSpeedEngage = 600
          --local maxSpeedEngage = 1000

          logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. bluePatrolZone.kutaisi[1]:GetName()} )
          --logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

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

            -- vedi:
            -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/PLN%20-%20Airplane/AIC-PLN-000%20-%20Airplane/AIC-PLN-000%20-%20Airplane.lua
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Airplane.html
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

            --local vehicleGroup = GROUP:FindByName( "Cargo Vehicles Kutaisi" )
            -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :
            --local vehicleCargo = CARGO_GROUP:New( vehicleGroup, "Vehicles", "Cargo Vehicles", 5000 )

            --local  = SET_CARGO:New():FilterTypes( "Vehicles" ):FilterStart()
            --local  = SET_CARGO:New():FilterPrefixes('Vehicles'):FilterStart()

            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles Kutaisi", 5000, nil)

            local destination = AIRBASE.Caucasus.Batumi --airbase_blue[ math.random( 1 , #airbase_blue ) ]
            local speed = math.random( 300 , 500 )

            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - : ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )

            activeCargoAirPlane( groupset, AIRBASE.Caucasus.Kutaisi, destination, speed, cargoGroupSet )







        ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
    elseif request.assignment == "TRANSPORT INFANTRY FARP" then

            -- vedi:
            -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/HEL%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter.lua
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Helicopter.html
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

            -- local infantryGroup = GROUP:FindByName( "Cargo Infantry Kutaisi" )
            -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :   https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New
            --local infantryCargo = CARGO_GROUP:New( infantryGroup, "Infantry", "Cargo Infantry", 5000 )

            -- local cargoGroupSet = SET_CARGO:New():FilterPrefixes('Cargo Infantry'):FilterStart()

            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kutaisi", 5000, nil)

            local pickupZone =  cargoZone.Warehouse_AB.blue.Kutaisi
            local deployZone =  cargoZone.Warehouse.blue.Gori
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - : ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )







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


            logging('info', { 'warehouse.Kutaisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home:GetName() .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

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

    if wh_activation.Warehouse_AB.blue.Kvitiri then


        warehouse.Kvitiri:Start()

        --  Kvitiri e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Kvitiri - Zestafoni - Gori
        -- Kvitiri e' utilizzato come aeroporto militare. Da Kvitiri decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.

        warehouse.Kvitiri:AddAsset(               air_template_blue.CAP_L_39ZA,                 10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAP_F_5,                    10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_F_5E_3_Rocket,          10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber BAI
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_F_5E_3_Cluster,          10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber BAI
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,            10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber BAI
        warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_AN_26,                 5,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_C_130,                 5,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_UH_1H,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport ) -- Transport
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_UH_60A,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]   ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_CH_47,                 5,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.AFAC_L_39ZA,                6,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_L_39C_Rocket,           10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  ) -- Bomber
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_L_39ZA_HRocket,         10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]     ) -- Heli CAS
        warehouse.Kvitiri:AddAsset(               air_template_blue.REC_L_39C,                  2,             WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_blue_recon_skill, max_blue_recon_skill)]  ) -- AWACS

        logging('info', { 'main' , 'addAsset Kvitiri warehouse'} )

        -- blue Kvitiri warehouse operations

        logging('info', { 'main' , 'addrequest Kvitiri warehouse'} )



        local kvitiri_efficiency_influence = 1

        local kvitiri_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Kvitiri[ 1 ],

            function()


                local num_mission = 11
                local depart_time = defineRequestPosition( num_mission )
                local pos = 1

              -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive

                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_L_39ZA_HRocket, math.random(2, 3), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random(2, 3), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_L_39ZA, math.random(2, 3), nil, nil, nil, "PATROL") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, math.random(2, 3), nil, nil, nil, "PATROL WITH ENGAGE ZONE") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Cluster, math.random(2, 3), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Bomb, math.random(3, 4), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(3, 4), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(2, 3), nil, nil, nil, "BOMBING STRUCTURE BITETA") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, math.random(1, 2), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random(1, 2), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, math.random(3, 4), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
                logging('info', { 'main' , 'Kvitiri scheduler - start time:' .. start_sched *  kvitiri_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

            end, {}, start_sched * kvitiri_efficiency_influence, interval_sched, rand_sched

        ) -- end  vaziani_sched = SCHEDULER:New( nil, ..)







        -- Do something with the spawned aircraft.
        function warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)

          logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' ,  ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })


          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TARGET" then


            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')


            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local  percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ]
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

            local avalaible_target_zones = {

                zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

            }

            local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
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


              -- vedi:
              -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/PLN%20-%20Airplane/AIC-PLN-000%20-%20Airplane/AIC-PLN-000%20-%20Airplane.lua
              -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Airplane.html
              -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

              -- local vehicleGroup = GROUP:FindByName( "Cargo Vehicles Kvitiri" )
              -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :
              -- local vehicleCargo = CARGO_GROUP:New( vehicleGroup, "Vehicles", "Cargo Vehicles", 5000 )

              -- local  = SET_CARGO:New():FilterTypes( "Vehicles" ):FilterStart()
              --local  = SET_CARGO:New():FilterPrefixes('Vehicles'):FilterStart()

              -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
              local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles Kvitiri", 5000, nil)


              local destination = airbase_blue[ math.random( 1 , #airbase_blue ) ]
              local speed = math.random( 300 , 500 )

              logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )

              activeCargoAirPlane( groupset, AIRBASE.Caucasus.Kvitiri, destination, speed, cargoGroupSet )






          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY FARP" then

            -- vedi:
            -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/HEL%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter.lua
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Helicopter.html
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

            --local infantryGroup = GROUP:FindByName( "Cargo Infantry Kvitiri" )
            -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :   https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New
            --local infantryCargo = CARGO_GROUP:New( infantryGroup, "Infantry", "Cargo Infantry", 5000 )

            --local cargoGroupSet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
            --local cargoGroupSet: = SET_CARGO:New():FilterPrefixes('Cargo Infantry'):FilterStart()

            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kvitiri", 5000, nil)

            local pickupZone =  cargoZone.Warehouse_AB.blue.Kvitiri
            local deployZone =  cargoZone.Warehouse.blue.Zestafoni
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )




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


            activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )

            logging('info', { 'warehouse.Kvitiri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home:GetName() .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )






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

    if wh_activation.Warehouse_AB.blue.Kvitiri_Helo then


        warehouse.Kvitiri_Helo:Start()

        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAP_F_5,                  10,            WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber BAI
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_Su_17M4_Rocket,       10  ) --  CAS
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_AN_26,                5,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_UH_1H,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_UH_60A,               15,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_CH_47,                15,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        --warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_MI_24,                6,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_UH_1H,                 10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]    ) -- Heli CAS
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_UH_60A,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]    ) -- Heli CAS
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_SA_342,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]    ) -- Heli CAS
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.AFAC_UH_1H,               10,            WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]    ) -- Heli AFAC
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.AFAC_SA342L,              10,            WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]    ) -- Heli AFAC


        logging('info', { 'main' , 'addAsset Kvitiri_Helo warehouse'} )


        -- blue Kvitiri_Helo warehouse operations

        logging('info', { 'main' , 'addrequest Kvitiri_Helo warehouse'} )



        local kvitiri_helo_efficiency_influence = 1

        local kvitiri_helo_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Kvitiri_Helo[ 1 ],

            function()

                local num_mission = 6
                local depart_time = defineRequestPosition( num_mission )
                local pos = 1

                if true and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri_Helo, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_UH_1H, math.random(1, 2), nil, nil, nil, "TRANSPORT INFANTRY FARP GORI") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri_Helo, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_UH_60A, math.random(1, 2), nil, nil, nil, "TRANSPORT INFANTRY FARP KHASHURI") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri_Helo, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random(1, 2), nil, nil, nil, "TRANSPORT VEHICLE FARP ZESTAFONI") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri_Helo, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random(1, 2), nil, nil, nil, "TRANSPORT INFANTRY AIRBASE") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kvitiri_Helo, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_SA342L, math.random(1, 2), nil, nil, nil, "RECON FARP") pos = pos + 1  end
                if true and pos <= num_mission then warehouse.Kvitiri_Helo:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, math.random(3, 4), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
                logging('info', { 'main' , 'Kvitiri_Helo scheduler - start time:' .. start_sched *  kvitiri_helo_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

            end, {}, start_sched * kvitiri_helo_efficiency_influence, interval_sched, rand_sched

        ) -- end  vaziani_sched = SCHEDULER:New( nil, ..)







        -- Do something with the spawned aircraft.
        function warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)

          logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' ,  ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })




          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
          if request.assignment == "TRANSPORT INFANTRY FARP GORI" then

            -- vedi:
            -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/HEL%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter.lua
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Helicopter.html
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

            --local infantryGroup = GROUP:FindByName( "Cargo Infantry Kvitiri_Helo" )
            -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :   https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New
            --local infantryCargo = CARGO_GROUP:New( infantryGroup, "Infantry", "Cargo Infantry", 5000 )

            --local cargoGroupSet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
            --local cargoGroupSet: = SET_CARGO:New():FilterPrefixes('Cargo Infantry'):FilterStart()

            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kvitiri_Helo", 5000, nil)


            local pickupZone =  cargoZone.Warehouse_AB.blue.Kvitiri_Helo
            local deployZone =  cargoZone.Warehouse.blue.Gori
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )








          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY FARP KHASHURI" then

            -- vedi:
            -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/HEL%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter.lua
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Helicopter.html
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

            -- local infantryGroup = GROUP:FindByName( "Cargo Infantry Kvitiri_Helo #001" )
            -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :   https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New
            -- local infantryCargo = CARGO_GROUP:New( infantryGroup, "Infantry", "Cargo Infantry", 5000 )

            -- local cargoGroupSet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
            -- local cargoGroupSet: = SET_CARGO:New():FilterPrefixes('Cargo Infantry'):FilterStart()

            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kvitiri_Helo #001", 5000, nil)


            local pickupZone =  cargoZone.Warehouse_AB.blue.Kvitiri_Helo
            local deployZone =  cargoZone.Warehouse.blue.Khashuri
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )








          ------------------------------------------------------------------------------------------------------ assignment for TRANSPORT asset
      elseif request.assignment == "TRANSPORT VEHICLE FARP ZESTAFONI" then

            -- vedi:
            -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/PLN%20-%20Airplane/AIC-PLN-000%20-%20Airplane/AIC-PLN-000%20-%20Airplane.lua
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Airplane.html
            -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

            -- local vehicleGroup = GROUP:FindByName( "Cargo Vehicles Kvitiri_Helo" )
            -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :
            -- local vehicleCargo = CARGO_GROUP:New( vehicleGroup, "Vehicles", "Cargo Vehicles", 5000 )

            -- local  = SET_CARGO:New():FilterTypes( "Vehicles" ):FilterStart()
            -- local  = SET_CARGO:New():FilterPrefixes('Cargo Vehicles'):FilterStart()

            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles Kvitiri_Helo", 5000, nil)


            local pickupZone =  cargoZone.Warehouse_AB.blue.Kvitiri_Helo
            local deployZone =  cargoZone.Warehouse.blue.Zestafoni
            local speed = math.random( 100 , 250 )

            logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

            activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )








          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
      elseif request.assignment == "TRANSPORT INFANTRY AIRBASE" then


              -- vedi:
              -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/HEL%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter.lua
              -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Helicopter.html
              -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

              -- local infantryGroup = GROUP:FindByName( "Cargo Infantry Kvitiri_Helo #002" )
              -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :   https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New
              -- local infantryCargo = CARGO_GROUP:New( infantryGroup, "Infantry", "Cargo Infantry", 5000 )

              -- local cargoGroupSet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()
              --local cargoGroupSet: = SET_CARGO:New():FilterPrefixes('Cargo Infantry'):FilterStart()

              -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
              local  cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Kvitiri_Helo #002", 5000, nil)


              local destination = AIRBASE.Caucasus.Vaziani
              local speed = math.random( 100 , 250 )

              logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

              activeCargoAirPlane( groupset, AIRBASE.Caucasus.Kvitiri_Helo, destination, speed, cargoGroupSet )







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

            logging('info', { 'warehouse.Kvitiri_Helo:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home:GetName() .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

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































    ------------------------------------------------- blue Warehouse ZESTAFONI operations -------------------------------------------------------------------------------------------------------------------------

    if wh_activation.Warehouse.blue.Zestafoni then


        warehouse.Zestafoni:SetSpawnZone(ZONE:New("Warehouse ZESTAFONI Spawn Zone"))
        warehouse.Zestafoni:Start()


        -- Zestafoni e' la warehouse di collegamento per rifornire khashuri e Gori
        --warehouse.Zestafoni:AddAsset( "Infantry Platoon Alpha", 6 )
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.antitankB,          6,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)] )
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.antitankA,          6,         WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)] )
        warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_UH_1H,                  3,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  )  -- Transport
        warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_UH_60A,                 3,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  )  -- Transport
        warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_CH_47,                  4,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TransportA,         6,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TransportB,         4,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TroopTransport,     4,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
        warehouse.Zestafoni:AddAsset(           air_template_blue.CAS_MI_24V,                 12,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]       ) -- Attack
        warehouse.Zestafoni:AddAsset(           air_template_blue.AFAC_MI_24,                  4,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]  ) -- AFAC
        warehouse.Zestafoni:AddAsset(           air_template_blue.AFAC_SA342L,                 4,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]  ) -- AFAC
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.ArtilleryResupply, 10,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport

        logging('info', { 'main' , 'addAsset Zestafoni warehouse'} )

        -- ZESTAFONI warehouse e' una frontline warehouse: invia gli asset sul campo con task assegnato. Didi e' rifornita da Biteta Warehouse

        logging('info', { 'main' , 'addrequest Zestafoni warehouse'} )


        local zestafoni_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local zestafoni_sched = SCHEDULER:New( warehouse.Zestafoni,

          function()

            local num_mission = 3 -- the number of mission request ( _addRequest() )
            local depart_time = defineRequestPosition(num_mission)
            local pos = 1

            if true and pos <= num_mission then warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Zestafoni, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1 , nil, nil, nil, 'CZ_PEREVI_attack_1' ) pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Zestafoni, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, 1, nil, nil, nil, 'CZ_PEREVI_attack_2' ) pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Zestafoni, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, 2, nil, nil, nil, 'CZ_ONI_attack_3' ) pos = pos + 1  end
          end, {}, start_ground_sched * zestafoni_efficiency_influence, interval_ground_sched, rand_ground_sched

        ) -- END SCHEDULER

        -- l'eventuale variazione causale dei parametri di missione la devi fare sulla AddRequest: io la farei solo sulle quantit�





        -- Take care of the spawned units.
        function warehouse.Zestafoni:OnAfterSelfRequest( From,Event,To,groupset,request )

          logging('enter', 'warehouse.ZESTAFONI:OnAfterSelfRequest(From,Event,To,groupset,request)' )

          local groupset = groupset --Core.Set#SET_GROUP
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment of this request.
          local assignment = warehouse.Zestafoni:GetAssignment(request)

          logging('info', { 'warehouse.ZESTAFONI:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

          if assignment == 'CZ_PEREVI_attack_1' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.CZ_PEREVI[1], 'enemy_attack', false, 1 )

          elseif assignment == 'CZ_PEREVI_attack_2' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.CZ_ONI[1], 'enemy_attack', false, 1  )

          elseif assignment == 'CZ_ONI_attack_3' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.CZ_PEREVI[1], 'enemy_attack', false, 1  )

          else

              logging('warning', { 'warehouse.Zestafoni:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )

          end

        end -- end function


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

    end -- end wh_activation.Warehouse.blue.Zestafoni then
    ------------------------------------------------- END blue Warehouse ZESTAFONI operations -------------------------------------------------------------------------------------------------------------------







































      ----------------------------------------------- blue Warehouse KHASHURI operations ------------------------------------------------------------------------------------------------------------------------

      if wh_activation.Warehouse.blue.Khashuri then


          -- Khashuri e' una warehouse del fronte
          --warehouse.Khashuri:AddAsset( "Infantry Platoon Alpha", 50 )


          warehouse.Khashuri:SetSpawnZone(ZONE:New("Warehouse KHASHURI Spawn Zone"))

          warehouse.Khashuri:Start()

          warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankA,          6,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)] )
          warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankC,          6,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)] )
          warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankB,          6,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)] )
          warehouse.Khashuri:AddAsset(           air_template_blue.CAS_MI_24V,                 12,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]       ) -- Attack
          warehouse.Khashuri:AddAsset(           air_template_blue.TRAN_UH_1H,                  3,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] )  -- Transport
          warehouse.Khashuri:AddAsset(           air_template_blue.AFAC_MI_24,                  4,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)] ) -- AFAC
          warehouse.Khashuri:AddAsset(           air_template_blue.AFAC_SA342L,                 4,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)] ) -- AFAC
          warehouse.Khashuri:AddAsset(           ground_group_template_blue.ArtilleryResupply, 10,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
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



        local khashuri_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local khashuri_sched = SCHEDULER:New( warehouse.Khashuri,

          function()

            local num_mission = 2 -- the number of mission request ( _addRequest() )
            local depart_time = defineRequestPosition( num_mission )
            local pos = 1

            if true and pos <= num_mission then warehouse.Khashuri:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Khashuri,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1, nil, nil, nil, 'DIDMUKHA_attack_1' ) pos = pos + 1  end
            if true and pos <= num_mission then warehouse.Khashuri:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Khashuri,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, 1, nil, nil, nil, 'DIDMUKHA_attack_2' ) pos = pos + 1  end

          end, {}, start_ground_sched * khashuri_efficiency_influence, interval_ground_sched, rand_ground_sched

        )  -- END SCHEDULER


        -- l'eventuale variazione causale dei parametri di missione la devi fare sulla AddRequest: io la farei solo sulle quantit�

        logging('info', { 'main' , 'addRequest Khashuri warehouse'} )



        -- Take care of the spawned units.
        function warehouse.Khashuri:OnAfterSelfRequest( From,Event,To,groupset,request )

          logging('enter', 'warehouse.Khashuri:OnAfterSelfRequest(From,Event,To,groupset,request)' )

          local groupset = groupset --Core.Set#SET_GROUP
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment of this request.
          local assignment = warehouse.Khashuri:GetAssignment(request)

          logging('info', { 'warehouse.Khashuri:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  -  groupSet = ' .. groupset:GetObjectNames()} )

          if assignment == 'DIDMUKHA_attack_1' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1)


          elseif assignment == 'DIDMUKHA_attack_2' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1)

          else

              logging('warning', { 'warehouse.Zestafoni:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )

          end -- if elsif else

          logging('exit', 'warehouse.Khashuri:OnAfterSelfRequest(From,Event,To,groupset,request)' )


        end -- end function


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

      end -- end wh_activation.Warehouse.blue.Khashuri then
      ----------------------------------------------- END blue Warehouse KHASHURI operations --------------------------------------------------------------------------------------------------------------------





































      ------------------------------------------------ blue Warehouse GORI operations ----------------------------------------------------------------------------------------------------------------------------

      if wh_activation.Warehouse.blue.Gori then



        warehouse.Gori:SetSpawnZone(ZONE:New("Gori WH Spawn Zone"))

        warehouse.Gori:Start()


        -- Gori e' una Farp warehouse quindi invia direttamente le risorse al fronte

        warehouse.Gori:AddAsset(               ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArmorA,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArmorB,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]  )
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedA,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]    ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedB,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]    ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedC,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]    ) -- Ground troops
        warehouse.Gori:AddAsset(               air_template_blue.CAS_MI_24V,               12,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]       ) -- Attack
        warehouse.Gori:AddAsset(               air_template_blue.TRAN_UH_1H,                3,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] )  -- Transport
        warehouse.Gori:AddAsset(               air_template_blue.TRAN_UH_60A,               2,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
        warehouse.Gori:AddAsset(               ground_group_template_blue.TroopTransport,   2,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtilleryResupply,10,         WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
        warehouse.Gori:AddAsset(               air_template_blue.AFAC_MI_24,                 4,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)] ) -- AFAC
        warehouse.Gori:AddAsset(               air_template_blue.AFAC_UH_1H,                 4,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)] ) -- AFAC
         warehouse.Gori:AddAsset(               air_template_blue.AFAC_SA342L,                4,         WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)] ) -- AFAC


        logging('info', { 'main' , 'addAsset Gori warehouse'} )


        -- GORI warehouse e' una frontline warehouse: invia gli asset sul campo con task assegnato. Didi e' rifornita da Biteta Warehouse


        logging('info', { 'main' , 'addrequest Gori warehouse'} )

        local gori_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- NOTA: lo scheduler di didi gestisce anche le missioni tipo ARTY

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local gori_sched = SCHEDULER:New( warehouse.Gori,

          function()

            local num_mission = 7 -- the number of mission request ( _addRequest() )
            local depart_time = defineRequestPosition( num_mission )

            local num_mission_helo = 5 -- the number of mission request ( _addRequest() )
            local depart_time_helo = defineRequestPosition( num_mission_helo )

            local pos = 1
            local pos_heli = 1

            local startReqTimeArtillery = 1 -- Arty groups have first activation
            local startReqTimeGround = startReqTimeArtillery + 420 -- Mech Groups are activated after 7'


            -- artillery request
            warehouse.Gori:__AddRequest( startReqTimeArtillery, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.ArtilleryResupply, 1, nil, nil, nil, 'GORI_Artillery_Resupply' )
            warehouse.Gori:__AddRequest( startReqTimeArtillery + 120 , warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.ArtiAkatsia, 1, nil, nil, nil, 'GORI_Artillery_Ops')


            -- mech request
            --riutilizzo gli stessi indici in quanto essendo ground veichle appaiono nella warehouse spawn zone diversa dal FARP degli helo
            if true and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC,       2 , nil, nil, nil, 'TSKHINVALI_Attack_APC' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1 , nil, nil, nil, 'TSKHINVALI_attack_2' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1 , nil, nil, nil, 'DIDMUKHA_attack_1' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, 1 , nil, nil, nil, 'SATIHARI_attack_1' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1, nil, nil, nil, 'SATIHARI_attack_2' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.jtac, 1, nil, nil, nil, 'JTAC_SATIHARI' ) pos = pos + 1  end
            if true and pos <= num_mission  then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[ pos ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.jtac, 1, nil, nil, nil, 'JTAC_TSKHINVALI' ) pos = pos + 1  end

            -- NON APPAIONO GLI AFAC HELO: sono apparsi cambiando AFAC in NOTHING nel template e cambiando in averege lo skill !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            if true and pos_heli <= num_mission_helo then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_SA_342,   1, nil, nil, nil, 'ATTACK_ZONE_HELO_Didmukha_Tsveri') pos_heli = pos_heli + 1  end
            if true and pos_heli <= num_mission_helo then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Gori,   WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Mi_8MTV2, 1, nil, nil, nil, 'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi') pos_heli = pos_heli + 1  end
            if true and pos_heli <= num_mission_helo then warehouse.Gori:__AddRequest( startReqTimeGround + depart_time_helo[ pos_heli ] * waitReqTimeGround, warehouse.Gori,   WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_SA342L, 1, nil, nil, nil, 'JTAC_ZONE_HELO_Tskhunvali_Tkviavi') pos_heli = pos_heli + 1  end

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            if true and (pos_heli-2) then warehouse.Gori:__AddRequest( startReqTimeGround + ( depart_time_helo[ pos_heli-2 ] + 1 ) * waitReqTimeGround, warehouse.Gori,   WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_SA342L,  1, nil, nil, nil, 'AFAC_ZONE_Tskhunvali_Tkviavi') end
            if true and (pos_heli-1) then warehouse.Gori:__AddRequest( startReqTimeGround + ( depart_time_helo[ pos_heli-2 ] + 1 ) * waitReqTimeGround, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_UH_1H,   1, nil, nil, nil, 'AFAC_ZONE_Didmukha_Tsveri') end

            logging('finer', { 'gori scheduler function' , 'addRequest Gori warehouse'} )

          end, {}, start_ground_sched *  gori_efficiency_influence, interval_ground_sched, rand_ground_sched

        ) -- end gori_sched





        -- l'eventuale variazione causale dei parametri di missione la devi fare sulla AddRequest: io la farei solo sulle quantit�

        logging('info', { 'main' , 'addRequest Gori warehouse'} )

        local groupResupplySet

        -- Take care of the spawned units.
        function warehouse.Gori:OnAfterSelfRequest( From,Event,To,groupset,request )

          logging('enter', 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' )

          local groupset = groupset --Core.Set#SET_GROUP
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment of this request.
          local assignment = warehouse.Gori:GetAssignment(request)

          logging('info', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  -  groupSet = ' .. groupset:GetObjectNames()} )

          -- launch mission functions: mech
          if assignment == 'TSKHINVALI_Attack_APC' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.TSKHINVALI[1], 'enemy_attack', false, 1 )


          elseif assignment == 'TSKHINVALI_attack_2' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.TSKHINVALI[1], 'enemy_attack', false, 1 )


          elseif assignment == 'DIDMUKHA_attack_1' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.DIDMUKHA[1], 'enemy_attack', false, 1 )



          elseif assignment == 'SATIHARI_attack_1' then

              activeGO_TO_BATTLE_BIS( groupset, redFrontZone.SATIHARI[1], 'enemy_attack', false, 1 )



          elseif assignment == 'SATIHARI_attack_2' then

               activeGO_TO_BATTLE_BIS( groupset, redFrontZone.DIDI_CUPTA[1], 'enemy_attack', false, 1 )


          -- launch mission functions: helo
          elseif assignment == 'AFAC_ZONE_Tskhunvali_Tkviavi' then

              activeGO_TO_ZONE_AIR( groupset, afacZone.Didmukha_Tsveri[1], 1 )



          elseif assignment == 'AFAC_ZONE_Didmukha_Tsveri' then

              activeGO_TO_ZONE_AIR( groupset, afacZone.Tskhunvali_Tkviavi[1], 1 )



          elseif assignment == 'ATTACK_ZONE_HELO_Didmukha_Tsveri' then

              activeGO_TO_ZONE_AIR( groupset, redFrontZone.DIDMUKHA[1], 1 )



          elseif assignment == 'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi' then

              activeGO_TO_ZONE_AIR( groupset, redFrontZone.TSKHINVALI[1], 1 )



          elseif assignment == 'JTAC_ZONE_HELO_Tskhunvali_Tkviavi' then

              activeJTAC( 'air', warehouse.Gori, groupset, blue_command_center, nil, redFrontZone.TSKHINVALI[1] )



          elseif assignment == 'JTAC_SATIHARI' then

              activeJTAC( 'ground', warehouse.Gori, groupset, blue_command_center, nil, redFrontZone.SATIHARI[1] )



          elseif assignment == 'JTAC_TSKHINVALI' then

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
              -- nameRecceUnits = recceArtyGroup.getName()  -- "Recce"
              activateDetectionReport = true


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
                        weaponType = ARTY.WeaponType.Rockets -- devi caricare le munizioni (forse)
                      },

                      [4] = {
                        targetCoordinate = targetZoneForBlueArty.DIDMUKHA_3[1]:GetRandomCoordinate(),
                        priority = 70,
                        radiusTarget = 500,
                        num_shots = 10,
                        num_engagements = 5,
                        weaponType = ARTY.WeaponType.IlluminationShells -- devi caricare le munizioni (forse)
                      },

                      [5] = {
                        targetCoordinate = targetZoneForBlueArty.DIDMUKHA_3[1]:GetRandomCoordinate(),
                        priority = 100,
                        radiusTarget = 2000,
                        num_shots = 4,
                        num_engagements = 1,
                        weaponType = ARTY.WeaponType.TacticalNukes -- devi caricare le munizioni (forse)
                      }
                  },

                  commandCenter = blue_command_center,

                  resupplySet = groupResupplySet,

                  speed = 60, -- km/h Akatsia max 60 km/h

                  onRoad = true,

                  maxDistance = 20,

                  maxFiringRange = 3500 -- Akatsia min range 0.3 km, max range 17.0 km


              }


              logging('info', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  -  groupSet = ' .. groupset:GetObjectNames() .. ' -  num target assigned = ' .. #param .. ' -  groupResupplySet = ' .. groupResupplySet:GetObjectNames()  } )

              activeGO_TO_ARTY( groupset, targetZoneForRedArty.TSVERI_5[1], param, true, 70 )

          else

              logging('warning', { 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Assignment not found'} )

          end

          logging('exit', 'warehouse.Gori:OnAfterSelfRequest(From,Event,To,groupset,request)' )

        end -- function warehouse.Gori:OnAfterSelfRequest( From,Event,To,groupset,request )


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


      end -- wh_activation.Warehouse.blue.Gori then
      ----------------------------------------------- END blue Warehouse GORI operations -------------------------------------------------------------------------------------------------------------------------





















































      ------------------------------------------------------------ blue Warehouse TBILISI operations ----------------------------------------------------------------------------------------------------------------------------

      if wh_activation.Warehouse_AB.blue.Tbilisi then -- true activate tbilisi wh operations

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


         --warehouse.Tbilisi:AddAsset(               air_template_blue.GCI_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.GCI_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.GCI_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.GCI_F_14A,                10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_L_39ZA,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]    ) -- Fighter
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_AV_88_Rocket,           2,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS  EXPERIMENTAL PROTOTYPE
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_AV_88_Cluster,          2,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS EXPERIMENTAL PROTOTYPE
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_AV_88_Bomb,             2,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,            10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_5E_3_Rocket,          10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_5E_3_Cluster,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_MI_24V,               10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_UH_1H,                10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_UH_60A,               10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_SA_342,               10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_L_39C_Rocket,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_L_39ZA_HRocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_4E_Rocket,          10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber CAS
         warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_AN_26,                 10,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]   ) -- Transport
         --warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_UH_1H,                10,        WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]   ) -- Transport
         --warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_UH_60A,               10,        WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]    ) -- Transport
         --warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_MI_24,               10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]    ) -- Transport
         warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_C_130,               5,         WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,               9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]    ) -- Transport
         warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_CH_47,               5,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]   ) -- Transport
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           15,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_B_52H,                10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_bomber_skill, max_blue_bomber_skill)]   ) -- Bomber
         --warehouse.Tbilisi:AddAsset(               air_template_blue.B_1B_HBomb,             10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_bomber_skill, max_blue_bomber_skill)]   ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Structure,      10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Heavy,   10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Light,   10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Cluster, 10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_B_1B,                 10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_bomber_skill, max_blue_bomber_skill)]   ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_MI_24V,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]    ) -- Heli CAS
         warehouse.Tbilisi:AddAsset(               air_template_blue.AWACS_B_1B,                 2,           WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_blue_awacs_skill, max_blue_awacs_skill)]   ) -- AWACS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.AWACS_F_4,                 2,           WAREHOUSE.Attribute.AIR_AWACS, nil, nil, nil, AI.Skill[ math.random(min_blue_awacs_skill, max_blue_awacs_skill)]   ) -- AWACS
         warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_L_39ZA,               7,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]   ) -- AFAC
         --warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_MI_24,              7,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]   ) -- AFAC
         --warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_SA342L,              7,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]   ) -- AFAC
         --warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_UH_1H,              7,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]   ) -- AFAC
         warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_AV_88,                2,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]   ) -- AFAC EXPERIMENTAL PROTOTYPE
         warehouse.Tbilisi:AddAsset(               air_template_blue.REC_L_39C,                 2,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]   ) -- AFAC EXPERIMENTAL PROTOTYPE
         warehouse.Tbilisi:AddAsset(               air_template_blue.REC_F_4,                   2,           WAREHOUSE.Attribute.AIR_OTHER, nil, nil, nil, AI.Skill[ math.random(min_blue_afac_skill, max_blue_afac_skill)]   ) -- AFAC EXPERIMENTAL PROTOTYPE

         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedA,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]      ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedB,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]      ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedC,     10,          WAREHOUSE.Attribute.GROUND_APC, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]      ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArmorA,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArmorB,          10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,          WAREHOUSE.Attribute.GROUND_ARTILLERY, nil, nil, nil, AI.Skill[ math.random(min_blue_artillery_skill, max_blue_artillery_skill)]    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TransportA,      12,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]   ) -- Transport
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TransportB,       6,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]   ) -- Transport
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TroopTransport,   4,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]   ) -- Transport
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.Truck,           3,           WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]   ) -- Transport
         --warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtilleryResupply,   4,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]   ) -- Transport
         --warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ResupplyTrucksColumn,   4,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]   ) -- Transport






         -- DA ELIMINARE random targets PRENDI SOLO LE TARGET ZONE E INSERISCILE SOTTO NEGLI ASSIGN
        local rndTrgTbilisi = {


          -- [1] = number of mission
          -- [pos mission][1] = name of mission
          -- [pos mission][2] = name of mission
          -- [pos mission][3] = asset group name
          -- [pos mission][4] = quantity
          -- [pos mission][5] = target zone
          -- [pos mission][6] = type of mission

          cap = { -- mechanized mission parameters

            {'tkviavi_attack_1', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankA, 1 , blueFrontZone.TKVIAVI, 'enemy_attack' }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'tkviavi_attack_2', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, 1 , blueFrontZone.TKVIAVI, 'enemy_attack' }, -- 3
            {'tseveri_attack_1', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankC, 1 , blueFrontZone.TSVERI, 'enemy_attack' } -- 4
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          },

          cas = { -- cas mission parameters

            {'tskhivali_attack_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Rocket, math.random( 2, 5 ) , redFrontZone.TSKHINVALI, "enemy_attack" }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'sathiari_attack_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Rocket, math.random( 2, 5 ) , redFrontZone.SATIHARI, 'enemy_attack' }, -- 3
            {'didmukha_attack_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Rocket, math.random( 2, 5 ) , redFrontZone.DIDMUKHA, 'enemy_attack' }, -- 3
            {'didi_cupta_attack_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Rocket, math.random( 2, 5 ) , redFrontZone.DIDI_CUPTA, 'enemy_attack' }, -- 4
            {'oni_attack_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Rocket, math.random( 2, 5 ) , redFrontZone.CZ_ONI, 'enemy_attack' }, -- 4
            {'perevi_attack_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Rocket, math.random( 2, 5 ) , redFrontZone.CZ_PEREVI, 'enemy_attack' }, -- 4
            {'tskhivali_attack_2', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket, math.random( 2, 5 ) , redFrontZone.TSKHINVALI, "enemy_attack" }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'sathiari_attack_2', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket, math.random( 2, 5 ) , redFrontZone.SATIHARI, 'enemy_attack' }, -- 3
            {'didmukha_attack_2', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket, math.random( 2, 5 ) , redFrontZone.DIDMUKHA, 'enemy_attack' }, -- 3
            {'didi_cupta_attack_2', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket, math.random( 2, 5 ) , redFrontZone.DIDI_CUPTA, 'enemy_attack' }, -- 4
            {'oni_attack_2', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket, math.random( 2, 5 ) , redFrontZone.CZ_ONI, 'enemy_attack' }, -- 4
            {'perevi_attack_2', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket, math.random( 2, 5 ) , redFrontZone.CZ_PEREVI, 'enemy_attack' }

          },

          bai = { -- bai mission parameters

            {'didi_pinpoint_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( 2, 5 ) , zoneTargetStructure.Red_Didi_Bridges[math.random( 1, #zoneTargetStructure.Red_Didi_Bridges)], "pinpoint_strike" },
            {'biteta_pinpoint_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( 2, 5 ) , zoneTargetStructure.Red_Biteta_Bridges[math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges)], "pinpoint_strike" },
            {'kvem0_sba_pinpoint_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( 2, 5 ) , zoneTargetStructure.Red_Kvemo_Sba_Bridges[math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges)], "pinpoint_strike" }
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          },

          sead = { -- helo mission parameters


            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          },

          reco = { -- mechanized mission parameters

            {'tkviavi_attack_1', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankA, math.random( 1, 2 ) , blueFrontZone.TKVIAVI, 'enemy_attack' }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'tkviavi_attack_2', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, math.random( 1, 2 ) , blueFrontZone.TKVIAVI, 'enemy_attack' }, -- 3
            {'tseveri_attack_1', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankC, math.random( 1, 2 ) , blueFrontZone.TSVERI, 'enemy_attack' } -- 4
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          }


        }



        -- blue Tbilisi warehouse operations

        logging('info', { 'main' , 'addrequest Tbilisi warehouse'} )

        local tblisi_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local tblisi_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Tbilisi[ 1 ],

          function()

             local num_mission = 12
             local depart_time = defineRequestPosition( num_mission )
             local pos = 1

             if false and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_5E_3_Cluster, math.random( 2 , 3 ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if false and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( 2 , 3 ), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
             if false and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, math.random( 2 , 3 ), nil, nil, nil, "PATROL") pos = pos + 1  end
             if false and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Cluster, math.random( 2 , 3 ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
             if false and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( 2 , 3 ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
             if false and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Heavy, math.random( 2 , 3 ), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, math.random( 2 , 3 ), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_C_130, math.random( 2 , 3 ), nil, nil, nil, "TRANSPORT INFANTRY AIRBASE") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( 2 , 4 ), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( 2 , 4 ), nil, nil, nil, "TRANSPORT CRATE FARP") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AWACS_F_4, math.random( 1 , 2 ), nil, nil, nil, "AWACS") pos = pos + 1  end
             if true and pos <= num_mission then warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_C_130, math.random( 2 , 3 ), nil, nil, nil, "DISPATCHING AIRBASE TRANSPORT") pos = pos + 1  end

             logging('info', { 'main' , 'Tblisi scheduler - start time:' .. start_sched * tblisi_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

          end, {}, start_sched * tblisi_efficiency_influence, interval_sched, rand_sched

        ) -- end  tblisi_sched = SCHEDULER:New( nil, ..)



        -- Do something with the spawned aircraft.
        function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)



          logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })



          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TARGET" then

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local percRequestKill = math.random( 0 , 100 ) * 0.01
            local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ]
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


            local avalaible_target_zones = {

                zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

            }

            local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
            local patrolZone = bluePatrolZone.tbilisi[1]

            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. patrolZone:GetName() .. ' - engageZone: ' .. engageZone:GetName() } )
            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack: ' .. speed_attack .. ' - altitude_attack: ' .. altitude_attack .. ' - speed_patrol_min: ' .. speed_patrol_min .. ' - altitude_patrol_min: ' .. altitude_patrol_min .. ' - speed_patrol_max: ' .. speed_patrol_max .. ' - altitude_patrol_max: ' .. altitude_patrol_max .. ' - attack_angle: ' .. attack_angle .. ' - num_attack: ' .. num_attack .. ' - num_weapon: ' .. num_weapon .. ' - time_to_engage: ' .. time_to_engage .. ' - time_to_RTB: ' .. time_to_RTB } )

            activeBAI( 'Interdiction from Tbilisi against structure', groupset, 'bombing', patrolZone, engageZone, speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, nil, nil, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 )






          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset

      elseif request.assignment == "AWACS" then

            --local homeAirbase =  AIRBASE.Caucasus.Tbilisi_Lochini
            --local patrolZone =  bluePatrolZone.tbilisi[1]
            --local engageRange = math.random(10000, 20000)
            --local engageZone = patrolZone -- l'ingaggio e' determinato solo dalla valutazione del engangeRange e non dalla zona violata (engageZone)
            --local patrolFloorAltitude = 7000
            --local patrolCeilAltitude = 9000
            --local minSpeedPatrol = 400
            --local maxSpeedPatrol = 600
            --local minSpeedEngage = 600
            --local maxSpeedEngage = 1000

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - patrolZone: ' .. bluePatrolZone.tbilisi[1]:GetName() } )
            --logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'patrolFloorAltitude: ' .. patrolFloorAltitude .. ' - patrolCeilAltitude: ' .. patrolCeilAltitude .. ' - minSpeedPatrol: ' .. minSpeedPatrol .. ' - maxSpeedPatrol: ' .. maxSpeedPatrol .. ' - minSpeedEngage: ' .. minSpeedEngage .. ' - maxSpeedEngage: ' .. maxSpeedEngage} )

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


            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles Tbilisi", 5000, nil)


            -- devi creare dei cargo vehicles con GroupName #CARGO(T=CargoTypeName,RR=Range,NR=Range)
            -- esempio VehicleA #CARGO(T=Vehicles,RR=500,NR=30)
            -- vedi: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.Cargo.html
            local cargoGroupSet = SET_CARGO:New():FilterTypes( 'Vehicles' ):FilterStart()


              local destination = AIRBASE.Caucasus.Kutaisi --airbase_blue[ math.random( 1 , #airbase_blue ) ]
              local speed = math.random( 300 , 500 )

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )
              activeCargoAirPlane( groupset, AIRBASE.Caucasus.Tbilisi_Lochini, destination, speed, cargoGroupSet )

              --logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )
              --activeCargo('airplane', groupset, AIRBASE.Caucasus.Tbilisi_Lochini, destination, 'Vehicles',"Cargo Vehicles Tbilisi", speed)







          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
          elseif request.assignment == "TRANSPORT INFANTRY AIRBASE" then


            -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
            --local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Tbilisi", 5000, nil)

            -- devi creare dei cargo vehicles con GroupName #CARGO(T=CargoTypeName,RR=Range,NR=Range)
            -- esempio InfantryA #CARGO(T=Infantry,RR=500,NR=30)
            -- vedi: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.Cargo.html
            local cargoGroupSet = SET_CARGO:New():FilterTypes( 'Infantry' ):FilterStart()


            local destination = AIRBASE.Caucasus.Kutaisi --airbase_blue[ math.random( 1 , #airbase_blue ) ]
            local speed = math.random( 300 , 500 )

            logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )
            activeCargoAirPlane( groupset, AIRBASE.Caucasus.Tbilisi_Lochini, destination, speed, cargoGroupSet )

            --logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )
            --activeCargo('airplane', groupset, AIRBASE.Caucasus.Tbilisi_Lochini, destination, 'Infantry',"Cargo Infantry Tbilisi", speed)









            ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
            elseif request.assignment == "TRANSPORT INFANTRY FARP" then


              -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
              -- local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Tbilisi", 5000, nil)


              -- devi creare dei cargo vehicles con GroupName #CARGO(T=CargoTypeName,RR=Range,NR=Range)
              -- esempio InfantryA #CARGO(T=Infantry,RR=500,NR=30)
              -- vedi: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.Cargo.html
              local cargoGroupSet = SET_CARGO:New():FilterTypes( 'Infantry' ):FilterStart()


              local pickupZone =  cargoZone.Warehouse_AB.blue.Tbilisi
              local deployZone =  cargoZone.Warehouse.blue.Gori
              local speed = math.random( 100 , 250 )

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )
              activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )

              -- logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - speed: ' .. speed .. ' - destination: ' .. deployZone:GetName() } )
              -- activeCargo('helicopter', groupset, pickupZone, deployZone, 'Infantry',"Cargo Infantry Tbilisi", speed)



          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
          elseif request.assignment == "TRANSPORT CRATE FARP" then

                -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
                -- local cargoGroupSet = generateCargoSet("Infantry", "Cargo Infantry Tbilisi", 5000, nil)


                -- devi creare dei cargo vehicles con StaticName #CARGO(T=CargoTypeName,RR=Range,NR=Range)
                -- esempio Materials #CARGO(T=Workmaterials,RR=500,NR=30)
                -- vedi: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.Cargo.html
                local cargoGroupSet = SET_CARGO:New():FilterTypes( 'Workmaterials' ):FilterStart()


                local pickupZone =  cargoZone.Warehouse_AB.blue.Tbilisi
                local deployZone =  cargoZone.Warehouse.blue.Gori
                local speed = math.random( 100 , 250 )

                logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )
                activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )

                -- logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - speed: ' .. speed .. ' - destination: ' .. deployZone:GetName() } )
                -- activeCargo('helicopter', groupset, pickupZone, deployZone, 'Infantry',"Cargo Infantry Tbilisi", speed)






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

              logging('info', { 'warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home:GetName() .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

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

      if wh_activation.Warehouse_AB.blue.Vaziani then

          logging('info', { 'main' , 'init Warehouse VAZIANI operations' } )


          warehouse.Vaziani:Start()

          -- Vaziani e' un aeroporto vicino Tbilisi dove sono gestiti le risorse aeree fighter, reco, cas transport

          warehouse.Vaziani:AddAsset(              air_template_blue.GCI_Mig_21Bis,             5,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  )
          warehouse.Vaziani:AddAsset(              air_template_blue.CAP_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  )
          warehouse.Vaziani:AddAsset(              air_template_blue.CAP_L_39ZA,               10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  )
          warehouse.Vaziani:AddAsset(              air_template_blue.CAS_Su_17M4_Rocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  ) -- Bomber BAI
          warehouse.Vaziani:AddAsset(              air_template_blue.CAS_Su_17M4_Bomb,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  ) -- Bomber BAI
          warehouse.Vaziani:AddAsset(              air_template_blue.CAS_Su_17M4_Cluster,      10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  ) -- Bomber BAI
          warehouse.Vaziani:AddAsset(              air_template_blue.CAS_L_39C_Rocket,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  ) -- Bomber BAI
          warehouse.Vaziani:AddAsset(              air_template_blue.BOM_SU_24_Bomb,           10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  ) -- Bomber BAI
          warehouse.Vaziani:AddAsset(              air_template_blue.CAS_MI_24V,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]   ) -- Heli CAS
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_UH_1H,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_UH_60A,               5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]    ) -- Transport
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_CH_47,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]   ) -- Transport
          --warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_MI_24,                6,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]   ) -- Transport
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_AN_26,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  )
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]    ) -- Ground troops
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]    ) -- Ground troops
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]    ) -- Ground troops
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.TransportA,       6,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]   ) -- Transport
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.TransportB,       4,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]   ) -- Transport
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.TroopTransport,  4,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]    )-- Transport

          logging('info', { 'main' , 'addAsset Vaziani warehouse'} )



          -- blue Vaziani warehouse operations

          logging('info', { 'main' , 'addrequest Vaziani warehouse'} )


          local vaziani_efficiency_influence = 1

          local vaziani_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Vaziani[ 1 ],

              function()

                  local num_mission = 11
                  local depart_time = defineRequestPosition( num_mission )
                  local pos = 1

                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_MI_24V, math.random(2, 3), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_SU_24_Bomb, math.random(2, 3), nil, nil, nil, "BAI STRUCTURE") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_L_39ZA, math.random(2, 3), nil, nil, nil, "PATROL") pos = pos + 1  end
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_Mig_21Bis, math.random(2, 3), nil, nil, nil, "PATROL WITH ENGAGE ZONE") pos = pos + 1  end
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Cluster, math.random(2, 3), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Bomb, math.random(3, 4), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(3, 4), nil, nil, nil, "BOMBING MIL ZONE") pos = pos + 1  end
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random(2, 3), nil, nil, nil, "BOMBING STRUCTURE BITETA") pos = pos + 1  end
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, math.random(1, 2), nil, nil, nil, "TRANSPORT VEHICLE AIRBASE") pos = pos + 1  end
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random(1, 2), nil, nil, nil, "TRANSPORT INFANTRY FARP") pos = pos + 1  end
                  if true and pos <= num_mission then warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, math.random(3, 4), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
                  logging('info', { 'main' , 'Vaziani scheduler - start time:' .. start_sched *  vaziani_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

              end, {}, start_sched * vaziani_efficiency_influence, interval_sched, rand_sched

          ) -- end  vaziani_sched = SCHEDULER:New( nil, ..)







          -- Do something with the spawned aircraft.
          function warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' ,  ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })


            ------------------------------------------------------------------------------------------------------ assignment for BAI asset
            if request.assignment == "BAI TARGET" then


              speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')


              -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
              local  percRequestKill = math.random( 0 , 100 ) * 0.01
              local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ]
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

              local avalaible_target_zones = {

                  zoneTargetStructure.Red_Didi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Didi_Bridges) ][1],
                  zoneTargetStructure.Red_Biteta_Bridges[ math.random( 1, #zoneTargetStructure.Red_Biteta_Bridges) ][1],
                  zoneTargetStructure.Red_Kvemo_Sba_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kvemo_Sba_Bridges) ][1]

              }

              local engageZone = avalaible_target_zones[ math.random( 1, #avalaible_target_zones ) ]
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


                -- vedi:
                -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/PLN%20-%20Airplane/AIC-PLN-000%20-%20Airplane/AIC-PLN-000%20-%20Airplane.lua
                -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Airplane.html
                -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

                -- local vehicleGroup = GROUP:FindByName( "Cargo Vehicles Vaziani" )
                -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :

                -- local vehicleCargo = CARGO_GROUP:New( vehicleGroup, "Vehicles", "Cargo Vehicles", 5000 )

                -- local destination = airbase_blue[ math.random( 1 , #airbase_blue ) ]

                -- local  = SET_CARGO:New():FilterTypes( "Vehicles" ):FilterStart()
                -- local  = SET_CARGO:New():FilterPrefixes('Vehicles'):FilterStart()

                -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
                local cargoGroupSet = generateCargoSet('Vehicles', "Cargo Vehicles", 5000, nil)


                local speed = math.random( 300 , 500 )

                logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - destination: ' .. destination } )

                activeCargoAirPlane( groupset, AIRBASE.Caucasus.Vaziani, destination, speed, cargoGroupSet )





            ----------------------------------------------------------------------------------------------------- assignment for TRASNPORT asset
        elseif request.assignment == "TRANSPORT INFANTRY FARP" then

                -- vedi:
                -- https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AIC%20-%20AI%20Cargo/HEL%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter/AIC-HEL-000%20-%20Helicopter.lua
                -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Cargo_Helicopter.html
                -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New

                -- local infantryGroup = GROUP:FindByName( "Cargo Infantry Vaziani" )
                -- CARGO_GROUP:New(CargoGroup, Type, Name, LoadRadius, NearRadius) :   https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Cargo.CargoGroup.html##(CARGO_GROUP).New
                -- local infantryCargo = CARGO_GROUP:New( infantryGroup, "Infantry", "Cargo Infantry", 5000 )

                -- local cargoGroupSet = SET_CARGO:New():FilterTypes( "Infantry" ):FilterStart()

                -- generateCargoSet(typeCargo, nameGroupCargo, loadRadius, nearRadius)
                local cargoGroupSet = generateCargoSet('Infantry', "Cargo Infantry Vaziani", 5000, nil)


                local pickupZone =  cargoZone.Warehouse_AB.blue.Vaziani
                local deployZone =  cargoZone.Warehouse.blue.Khashuri
                local speed = math.random( 100 , 250 )

                logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - cargoGroupSet: ' .. cargoGroupSet:GetObjectNames() .. ' - cargo.count' .. cargoGroupSet:Count() .. ' - speed: ' .. speed .. ' - pickupZone: ' .. pickupZone:GetName() .. ' - deployZone: ' .. deployZone:GetName() } )

                activeCargoHelicopter( groupset, pickupZone, deployZone, speed, cargoGroupSet )




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

              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - home: ' .. home:GetName() .. ' - target: ' .. target:GetName() .. ' - toTargetAltitude: ' .. toTargetAltitude .. ' - toHomeAltitude: ' .. toHomeAltitude .. ' - reconDirection: ' .. reconDirection .. ' - reconAltitude: ' .. reconAltitude .. ' - reconRunDistance: ' .. reconRunDistance .. ' - reconRunDirection: ' .. reconRunDirection .. ' - speedReconRun: ' .. speedReconRun } )

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
                -- manca il groupset
                -- So we start another request.
                --[[
                if request.assignment=="PATROL" then

                    logging('info', { 'warehouse.Vaziani:OnAfterDelivered(From,Event,To,request)' , 'vaziani scheduled PATROL mission'})
                    activeCAPWarehouse(groupset, redFrontZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

                end

                if request.assignment=="BAI TARGET" then

                  logging('info', { 'warehouse.Vaziani:OnAfterDelivered(From,Event,To,request)' , 'vaziani scheduled BAI TARGET mission'})
                  activeBAIWarehouseT('Interdiction from Vaziani', groupset, 'target', redFrontZone.BAI_Zone_Vaziani[2], redFrontZone.BAI_Zone_Vaziani[2], 400, 1000, 4, 2, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

                end -- end if

                ]]

          end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)


      end --end wh_activation.Warehouse_AB.blue.Vaziani
      ------------------------------------------------------------ END blue Warehouse Vaziani operations ----------------------------------------------------------------------------------------------------------------------------































































      -------------------------------------------------------------- blue Warehouse Soganlug operations ----------------------------------------------------------------------------------------------------------------------------

      if wh_activation.Warehouse_AB.blue.Soganlug then



          warehouse.Soganlug:Start()


          -- Soganlug e' un aeroporto vicino Tbilisi dove sono gestiti le risorse aeree fighter, reco, cas, transport


          warehouse.Soganlug:AddAsset(              air_template_blue.GCI_Mig_21Bis,             5,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)] )
          warehouse.Soganlug:AddAsset(              air_template_blue.GCI_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)] )
          warehouse.Soganlug:AddAsset(              air_template_blue.CAP_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)]  ) -- Fighter
          warehouse.Soganlug:AddAsset(              air_template_blue.CAP_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)] )
          warehouse.Soganlug:AddAsset(              air_template_blue.GCI_F_4,                  5,           WAREHOUSE.Attribute.AIR_FIGHTER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_skill, max_blue_fighter_skill)] )
          warehouse.Soganlug:AddAsset(              air_template_blue.CAS_F_4E_Rocket,          10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber BAI
          warehouse.Soganlug:AddAsset(              air_template_blue.CAS_L_39C_Rocket,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber BAI
          warehouse.Soganlug:AddAsset(              air_template_blue.CAS_L_39ZA_HRocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber BAI
          warehouse.Soganlug:AddAsset(               air_template_blue.CAS_F_5E_3_Bomb,            10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber CAS
          warehouse.Soganlug:AddAsset(               air_template_blue.CAS_F_5E_3_Rocket,          10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber CAS
          warehouse.Soganlug:AddAsset(               air_template_blue.CAS_F_5E_3_Cluster,         10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber CAS
          warehouse.Soganlug:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Heavy,   10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber
          warehouse.Soganlug:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Light,   10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber
          warehouse.Soganlug:AddAsset(               air_template_blue.BOM_F_4_E_Sparse_Cluster, 10,          WAREHOUSE.Attribute.AIR_BOMBER, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)] ) -- Bomber
          warehouse.Soganlug:AddAsset(              air_template_blue.CAS_UH_1H,                10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  ) -- Heli CAS
          warehouse.Soganlug:AddAsset(              air_template_blue.CAS_UH_60A,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO, nil, nil, nil, AI.Skill[ math.random(min_blue_fighter_bomber_skill, max_blue_fighter_bomber_skill)]  ) -- Heli CAS
          warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_AN_26,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] )
          warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_UH_1H,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
          warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_UH_60A,               5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)]  ) -- Transport
          warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_CH_47,                3,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
          warehouse.Soganlug:AddAsset(              air_template_blue.TRAN_C_130,                6,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,              9000, nil, nil, AI.Skill[ math.random(min_blue_transport_skill, max_blue_transport_skill)] ) -- Transport
          warehouse.Soganlug:AddAsset(              ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
          warehouse.Soganlug:AddAsset(              ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
          warehouse.Soganlug:AddAsset(              ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK, nil, nil, nil, AI.Skill[ math.random(min_blue_tank_skill, max_blue_tank_skill)]  ) -- Ground troops
          warehouse.Soganlug:AddAsset(              ground_group_template_blue.TransportA,       6,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
          warehouse.Soganlug:AddAsset(              ground_group_template_blue.TransportB,       4,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)] ) -- Transport
          warehouse.Soganlug:AddAsset(              ground_group_template_blue.TroopTransport,   4,          WAREHOUSE.Attribute.GROUND_TRUCK, nil, nil, nil, AI.Skill[ math.random(min_blue_ground_skill, max_blue_ground_skill)]  )-- Transport

          logging('info', { 'main' , 'addAsset Soganlug warehouse'} )


          -- Nota: Tipo Operazioni CAP, GCI, CAS, SEAD, RECO, AWACS, Transport


          logging('info', { 'main' , 'init Warehouse Soganlug operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa

          -- Red targets at Soganlug X (late activated). for test
          local RedTargets=GROUP:FindByName("Russian Antitank Defence@Sathiari")


          -- blue Soganlug warehouse operations

          logging('info', { 'main' , 'addrequest Soganlug warehouse'} )


          local depart_time = defineRequestPosition(9) -- list of position

          local soganlug_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

          -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
          local soganlug_sched = SCHEDULER:New( staticObject.Warehouse_AB.blue.Soganlug[ 1 ],

            function()

              local num_mission = 8
              local depart_time = defineRequestPosition( num_mission )
              local pos = 1

              if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket,  math.random( 2 , 3 ), nil, nil, nil, "BAI TARGET") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
              if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_UH_1H,  math.random( 2 , 3 ), nil, nil, nil, "BAI TARGET BIS") pos = pos + 1  end -- BAI_ZONE1, BAI2_ZONE2, ...
              if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, math.random( 2 , 3 ), nil, nil, nil, "PATROL") pos = pos + 1  end
              if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Cluster, math.random( 2 , 3 ), nil, nil, nil, "BOMBING AIRBASE") pos = pos + 1  end
              if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Cluster, math.random( 2 , 3 ), nil, nil, nil, "BOMBING WAREHOUSE") pos = pos + 1  end
              if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Heavy, math.random( 2 , 3 ), nil, nil, nil, "BOMBING STRUCTURE KUTAISI") pos = pos + 1  end
              if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Heavy, math.random( 2 , 3 ), nil, nil, nil, "BOMBING STRUCTURE DIDI") pos = pos + 1  end
              if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Sparse_Heavy, math.random( 2 , 3 ), nil, nil, nil, "BOMBING STRUCTURE KVEMO_SBA") pos = pos + 1  end
              --if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_4, 2, nil, nil, nil, "PATROL F4") pos = pos + 1  end
            --  if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, 2, nil, nil, nil, "TRANSFER MIG 21") pos = pos + 1  end
            --  if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, 2, nil, nil, nil, "TRANSPORT") pos = pos + 1  end
            --  if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_UH_60A, 2, nil, nil, nil, "TRANSPORT 2") pos = pos + 1  end
            --  if true and pos <= num_mission then warehouse.Soganlug:__AddRequest( startReqTimeAir + depart_time[ pos ] * waitReqTimeAir, warehouse.Soganlug, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, 2, nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED") pos = pos + 1  end
              logging('info', { 'main' , 'Soganlug scheduler - start time:' .. start_sched *  soganlug_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

            end, {}, start_sched *  soganlug_efficiency_influence, interval_sched, rand_sched

          )




          -- Do something with the spawned aircraft.
          function warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)


            logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , ' **** REQUEST ASSIGNEMNT **** : ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })


            ------------------------------------------------------------------------------------------------------ assignment for BAI asset
            if request.assignment == "BAI TARGET" then


              speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI('fighter_bomber')

              -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
              local percRequestKill = math.random( 0 , 100 ) * 0.01
              local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ]
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
                local target = redGroundGroup[ math.random( 1, #redGroundGroup ) ]
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
              local target = zoneTargetStructure.Red_Kutaisi_Bridges[ math.random( 1, #zoneTargetStructure.Red_Kutaisi_Bridges ) ][1]
              local toTargetAltitude = math.random(5000, 7000)
              local toHomeAltitude = math.random(3000, 5000)
              local bombingDirection = math.random(270, 359)
              local bombingAltitude = math.random(4000, 6000)
              local diveBomb = false
              local bombRunDistance = 20000
              local bombRunDirection = math.random(270, 359)
              local speedBombRun = math.random(400, 600)

              logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:getName() } )

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

              logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:getName() } )

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

              logging('info', { 'warehouse.Soganlug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'groupset name: ' .. groupset:GetObjectNames() .. ' - target: ' .. target:getName() } )

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




  end -- end activeWarehouse
















































  --      AIRWAR (CAP e GCI ONLY)




  if activeAirWar then



      -- CAP ZONE


      ---
      --  cap_zone_db _red table
      --
      --  Qui devi riportare i nomi delle cap per la red coalition create in ME
      --
      --  [1] = 'RED CAP ZONE BESLAN',
      --  [2] = 'RED CAP ZONE NALCHIK',
      --  [3] = 'RED CAP ZONE TEBERDA',
      --  [4] = 'RED CAP ZONE SOCHI'
      --
      local cap_zone_db_red = {

        [1] = 'RED CAP ZONE BESLAN',
        [2] = 'RED CAP ZONE NALCHIK',
        [3] = 'RED CAP ZONE TEBERDA',
        [4] = 'RED CAP ZONE SOCHI'

        }

      ---
      --  cap_zone_db _red table
      --
      --  Qui devi riportare i nomi delle cap per la red coalition create in ME
      --
      -- [1] = 'BLUE CAP ZONE TBILISI',
      -- [2] = 'BLUE CAP ZONE KUTAISI',
      -- [3] = 'BLUE CAP ZONE SUKUMI',
      -- [4] = 'BLUE CAP ZONE SOCHI GUDAUTA'
      --
      local cap_zone_db_blue = {

        [1] = 'BLUE CAP ZONE TBILISI',
        [2] = 'BLUE CAP ZONE KUTAISI',
        [3] = 'BLUE CAP ZONE SUKUMI',
        [4] = 'BLUE CAP ZONE SOCHI GUDAUTA'

        }



    -- END CAP ZONE



    -- BALANCER

    -- Attualmente i solt gestiti dalla AI effettuano CAP, considerando che le CAP e le CGI sono gestiti tramite l'apposita sezione,
    -- cambia il task delle AI facendogli effettuare missioni BAI, CAS o RECO

    local activeBlueBelancer = false

    if activeBalancer then


      -- # Situation:
      --
      -- AI_BALANCERS created per airbase for both coalitions. Mutiple patrol zones are created
      -- for each side. Each flight that is created by AI_BALANCER will pick a random patrol zone
      -- to patrol.

      -- # Test Cases
      --
      -- 1. Observe at least 1 flight spawning and taking off from each airbase.
      -- 2. Each flight patrols randomly in one of its sides zones.
      -- 3. AI will respawn after killed.
      -- 4. Additional client slots are available at Sochi. If players don't take a slot there
      --    will be more than one AI taking off from Sochi.
      -- 5. Batumi contains a flight of 3 units rather than just 1 like most of the rest of the airbases.
      -- 6. Watch the coalition AI clash and kill each other.

      -- Create the Red Patrol Zone Array

      -- This zone array will be used in the AI_BALANCER to randomize the patrol
      -- zone that each spawned group will patrol

      local RedPatrolZone = {}

      RedPatrolZone[1] = ZONE:New( cap_zone_db_red[1] ) -- beslan
      RedPatrolZone[2] = ZONE:New( cap_zone_db_red[2] ) -- nalchik
      RedPatrolZone[3] = ZONE:New( cap_zone_db_red[3] ) -- teberda
      RedPatrolZone[4] = ZONE:New( cap_zone_db_red[4] ) -- sochi


      -- Russian CAP Aircraft

      -- These are the aircraft created in the mission editor that the AI will spawn
      -- with replacing any CLIENT created aircraft in the mission that a human
      -- player does not take.

      local RU_PlanesSpawn = {}


      RU_PlanesSpawn[1] = SPAWN:New( "RU CAP Beslan AB" ):InitCleanUp( 45 )
      RU_PlanesSpawn[2] = SPAWN:New( "RU CAP Mozdok AB" ):InitCleanUp( 45 )
      RU_PlanesSpawn[3] = SPAWN:New( "RU CAP Mineralnye Vody AB" ):InitCleanUp( 45 )
      RU_PlanesSpawn[4] = SPAWN:New( "RU CAP Nalchik AB" ):InitCleanUp( 45 )


      -- Russian Client Aircraft (via AI_BALANCER, AI will replace these if no human players are in the slot)

      -- If you want more client slots per airbase that you want AI to be able to take control of then
      -- name them with the prefixes below and they will be picked up automatically by FilterPrevixes.
      --
      -- For example, if you want another Client slot available at Anapa name it "RU CLIENT Anapa AB 2".
      -- The code here does not need to be changed. Only an addition in the mission editor. An example
      -- of this can be found on the USA side at Sochi AB.

      local RU_PlanesClientSet = {}

      RU_PlanesClientSet[1] = SET_CLIENT:New():FilterPrefixes("RU Client Beslan AB")
      RU_PlanesClientSet[2] = SET_CLIENT:New():FilterPrefixes("RU Client Mozdok AB")
      RU_PlanesClientSet[3] = SET_CLIENT:New():FilterPrefixes("RU Client Mineralnye Vody AB")
      RU_PlanesClientSet[4] = SET_CLIENT:New():FilterPrefixes("RU Client Nalchik AB")

      local num_bal = #RU_PlanesClientSet

      if num_bal > #RU_PlanesSpawn then logging('warning', { 'BALANCER' , 'num set client higher('.. num_bal ..') of set plane spawn(' .. #RU_PlanesSpawn .. ')' } )  end

      -- We setup an array to store all the AI_BALANCERS that are going to be created. Basically one
      -- per airbase. We loop through and create an AI_BALANCER as well as a separate OnAfterSpawned
      -- function for each. The Patrol Zone is randomized in the first parameter to AI_PATROL_ZONE:New()
      -- call. This is done for each of the AI_BALANCERS. To add more patrol zones, just define them in
      -- the mission editor and add into the array above. Code here does not need to be changed. The
      -- table.getn(RedPatrolZone) gets the number of elements in the RedPatrolZone array so that all
      -- of them are included to pick randomly.


      RU_AI_Balancer = {}

      for i = 1, #RU_PlanesClientSet do

        RU_AI_Balancer[i] = AI_BALANCER:New(RU_PlanesClientSet[i], RU_PlanesSpawn[i])

        -- We set a local variable within the for loop to the AI_BALANCER that was just created.
        -- I couldn't get RU_AI_BALANCER[i]:OnAfterSpawn to be recognized so this is just pointing
        -- curAIBalancer to the relevant RU_AI_BALANCER array item for each loop.

        -- So in this case there are essentially 11 OnAfterSpawned functions defined and handled.

        local curAIBalancer = RU_AI_Balancer[i]

        function curAIBalancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )

          local Patrol = AI_PATROL_ZONE:New( RedPatrolZone[math.random( 1, table.getn(RedPatrolZone))], 1500, 5500, 700, 1400 )
          Patrol:ManageFuel( 0.2, 60 )
          Patrol:SetControllable( AIGroup )
          Patrol:Start()

        end --end function

      end -- end for

      -- US / Blue side is setup pretty much identically to the RU side above. Same detailed comments
      -- above apply here. The main difference here is 10 airbases instead of 11.

      -- Another difference is additional client slots at Sochi and a group defined at Batumi with
      -- more than 1 unit per group (flight of 3 units). This is just to show that you can have more
      -- client slots per airbase and more units in a single group that the AI will control. I think
      -- this will also allow you to fly lead with AI on your wing or you can fly wing with an AI
      -- leader.

      -- Create the Blue Patrol Zone Array
      local BluePatrolZone = {}

      BluePatrolZone[1] = ZONE:New( cap_zone_db_blue[1] ) -- tbilisi
      BluePatrolZone[2] = ZONE:New( cap_zone_db_blue[2] ) -- kutaisi
      BluePatrolZone[3] = ZONE:New( cap_zone_db_blue[3] ) -- sukumi
      BluePatrolZone[4] = ZONE:New( cap_zone_db_blue[4] ) -- sochi - gudauta


      --United States CAP Aircraft (these are used as templates for AI)

      local BLUE_PlanesSpawn = {}

      --BLUE_PlanesSpawn[1] = SPAWN:New( "US CAP Batumi AB" ):InitCleanUp( 45 )
      -- BLUE_PlanesSpawn[2] = SPAWN:New( "US CAP Gudauta AB" ):InitCleanUp( 45 )
      -- BLUE_PlanesSpawn[3] = SPAWN:New( "US CAP Kobuleti AB" ):InitCleanUp( 45 )
      BLUE_PlanesSpawn[1] = SPAWN:New( "GEORGIA CAP Kutaisi AB" ):InitCleanUp( 45 )
      -- BLUE_PlanesSpawn[5] = SPAWN:New( "US CAP Senaki AB" ):InitCleanUp( 45 )
      -- BLUE_PlanesSpawn[6] = SPAWN:New( "US CAP Sochi AB" ):InitCleanUp( 45 )
      BLUE_PlanesSpawn[2] = SPAWN:New( "GEORGIA CAP Soganlug AB" ):InitCleanUp( 45 )
      --BLUE_PlanesSpawn[8] = SPAWN:New( "US CAP Sukhumi AB" ):InitCleanUp( 45 )
      BLUE_PlanesSpawn[3] = SPAWN:New( "GEORGIA CAP Vaziani AB" ):InitCleanUp( 45 )
      BLUE_PlanesSpawn[4] = SPAWN:New( "GEORGIA CAP Tbilisi AB" ):InitCleanUp( 45 )

      --United States Client Aircraft (via AI_BALANCER, AI will replace these if no human players are in the slot)

      local BLUE_PlanesClientSet = {}

      -- BLUE_PlanesClientSet[1] = SET_CLIENT:New():FilterPrefixes("US CLIENT Batumi AB")
      -- BLUE_PlanesClientSet[2] = SET_CLIENT:New():FilterPrefixes("US CLIENT Gudauta AB")
      -- BLUE_PlanesClientSet[3] = SET_CLIENT:New():FilterPrefixes("US CLIENT Kobuleti AB")
      BLUE_PlanesClientSet[1] = SET_CLIENT:New():FilterPrefixes("GEORGIA CLIENT Kutaisi AB")
      -- BLUE_PlanesClientSet[5] = SET_CLIENT:New():FilterPrefixes("US CLIENT Senaki AB")
      -- BLUE_PlanesClientSet[6] = SET_CLIENT:New():FilterPrefixes("US CLIENT Sochi AB")
      BLUE_PlanesClientSet[2] = SET_CLIENT:New():FilterPrefixes("GEORGIA CLIENT Soganlug AB")
      -- BLUE_PlanesClientSet[8] = SET_CLIENT:New():FilterPrefixes("US CLIENT Sukhumi AB")
      BLUE_PlanesClientSet[3] = SET_CLIENT:New():FilterPrefixes("GEORGIA CLIENT Vaziani AB")
      BLUE_PlanesClientSet[4] = SET_CLIENT:New():FilterPrefixes("GEORGIA CLIENT Tbilisi AB")

      BLUE_AI_Balancer = {}

      for i = 1, 4 do

        BLUE_AI_Balancer[i] = AI_BALANCER:New( BLUE_PlanesClientSet[i], BLUE_PlanesSpawn[i] )

        local curAIBalancer = BLUE_AI_Balancer[i]

        function curAIBalancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )

          local Patrol = AI_PATROL_ZONE:New( BluePatrolZone[math.random( 1, table.getn(BluePatrolZone))], 1500, 5500, 700, 1400 )
          Patrol:ManageFuel( 0.2, 60 )
          Patrol:SetControllable( AIGroup )
          Patrol:Start()

        end

      end

    end -- end activeBalancer













    -- SITUATION A



    --[[
    -- FUNZIONA!!!!!!!! LEGGE IL FILE IN RUNTIME!
    filename = 'F:\\Programmi\\luaDevTool\\workspace\\Test_Moose_Missions\\My Mission\\nothing.lua'
    dofile(filename)
    trigger.action.outText(nothing ,5 , false)



    Utilizza questa per avere un db dinamico delle basi di una coalizione

    AIRBASE:Register(AirbaseName)

        Create a new AIRBASE from DCSAirbase.
        Parameter

            #string AirbaseName : The name of the airbase.

        Return value

        Wrapper.Airbase#AIRBASE:



    ]]--















    ------------------------------------------------------------------------   AI A2A Dispatching ---------------------------------------------------------------




    -- RED FORCE CAP-GCI

    -- NOTA: UTILIZZATO SOLO PER LE CAP E GCI AI-



    -- Nota le GCI sono attivate quando non c'e' nessuno aereo alleato disponibile per l'ingaggio dell'incursore
    --
    -- Il dispatcher() imposta l'intercettazione dalla base pi� vicina distante meno del gci_radius. Credo che la base pi� vicina dovrebbe essere scelta da quelle abilitate trmite assign_gci
    --
    -- Credo che per poter utilizzare esclusivamente le gci suad devi dedicare a loro l'uso di un aeroporto: quindi scegli per le cap gli aeroporti vicino al fronte, mentre quelli lontani per i gci






    -- Setup generale

    local activeRedCAP = false
    local activeRedGCI = false
    local activeBlueCAP = false
    local activeBlueGCI = false

    local categories = {Unit.Category.AIRPLANE, Unit.Category.HELICOPTER}
    --- detection red: e' la distanza massima di valutazione se due o piu' aerei appartengono ad uno stesso gruppo (30km x modern, 10 km per ww2)
    -- i distanza impostata a 30 km
    -- local Detection_Red = detection(prefix_detector.red, 30000)

    local Detection_Red = detectionAI_A2A( prefix_detector.red, 30000, categories, nil, nil, nil, nil )

    --- A2ADispatcher red:
    -- distanza massima di attivazione GCI = 70 km (rispetto le airbase),
    -- distanza massima autorizzazione all'ingaggio per aerei alleati nelle vicinanze
    -- true/false: view tactital display
    local A2ADispatcher_Red = dispatcher(Detection_Red, 70000, 20000, false)



    -- Setup Red CAP e GCI

    local num_group = 2 --math.random(2, 3)
    local min_time_cap = 10
    local max_time_cap = 30
    local min_alt = 4000
    local max_alt = 8000
    local min_speed_patrol = 500
    local max_speed_patrol = 800
    local min_speed_engage = 800
    local max_speed_engage = 1200



    -- assign squadron at airbase Mozdok
    local Mozdok_Num_Air = 12


    if activeRedCAP then
      -- 12 Fighter Mig 21 CAP Only
      -- funziona
      assign_squadron_at_airbase ('Mozdok', AIRBASE.Caucasus.Mozdok, air_template_red.CAP_Mig_21Bis, Mozdok_Num_Air, A2ADispatcher_Red)

      -- assign mission cap for Mozdok Squadron
      assign_cap ( cap_zone_db_red[1], 'Mozdok', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Red )

    end




    if activeRedGCI then
      -- assign squadron at airbase Beslan
      -- 5 interceptor Mig 21 , no cap
      local Beslan_Num_Air = 5

      -- funziona
      assign_squadron_at_airbase ('Beslan', AIRBASE.Caucasus.Beslan, air_template_red.GCI_Mig_21Bis, Beslan_Num_Air, A2ADispatcher_Red)

      -- assign CGI mission for Beslan Squadron:
      assign_gci('Beslan', 800, 1200, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Red)

    end



    if activeRedGCI then
      -- assign squadron at airbase Nalchik
      -- 3 interceptor Mig 25 , no cap
      local Nalchik_Num_Air = 3

      -- funziona
      assign_squadron_at_airbase ('Nalchik', AIRBASE.Caucasus.Nalchik, air_template_red.GCI_Mig_25PD, Nalchik_Num_Air, A2ADispatcher_Red)

      -- assign CGI mission for Nalchik Squadron:
      assign_gci('Nalchik', 800, 1200, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Red)

    end


    if activeRedCAP then
      -- assign squadron at airbase Mineralnye
      -- 12 Fighter Mig 23 CAP Only
      local Mineralnye_Num_Air = 12


      -- funziona
      assign_squadron_at_airbase ('Mineralnye', AIRBASE.Caucasus.Mineralnye_Vody, air_template_red.CAP_Mig_23MLD, Mineralnye_Num_Air, A2ADispatcher_Red)

      -- assign mission cap for Mineralnye Squadron
      assign_cap ( cap_zone_db_red[2], 'Mineralnye', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Red )

    end








    -- END RED FORCE CAP-GCI




    -- BLUE FORCE CAP-GCI (OK)

    -- Kutaisi


    -- Setup generale

    --- detection blue: e' la distanza massima di rilevamento dei radar
    -- i distanza impostata a 100 km
    -- local Detection_Blue = detection(prefix_detector.blue, 30000)
    local Detection_Blue = detectionAI_A2A( prefix_detector.blue, 30000, categories, nil, nil, nil, nil )

    --- A2ADispatcher blue:
    -- distanza massima di attivazione GCI = 70 km (rispetto le aribase),
    -- distanza massima autorizzazione all'ingaggio per aerei alleati nelle vicinanze
    -- true/false: view tactital display
    local A2ADispatcher_Blue = dispatcher(Detection_Blue, 70000, 40000, false)



    -- Setup cap e gci

    -- CAP and GCI

    if activeBlueGCI then
      -- assign squadron at airbase
      -- 6 Mig 21 GCI  @ Kutaisi
      local Kutaisi_Num_Air = 6

      -- funziona
      assign_squadron_at_airbase ('Kutaisi', AIRBASE.Caucasus.Kutaisi, air_template_blue.GCI_Mig_21Bis, Kutaisi_Num_Air, A2ADispatcher_Blue)

      -- assign CGI mission for Squadron:
      assign_gci('Kutaisi', 800, 1200, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue)

    end



    if activeBlueCAP then
      -- assign squadron at airbase
      -- 12 F-4 CAP @ Kutaisi zone
      local Senaki_Num_Air = 12

      -- funziona
      assign_squadron_at_airbase ('Senaki', AIRBASE.Caucasus.Senaki_Kolkhi, air_template_blue.CAP_F_4, Senaki_Num_Air, A2ADispatcher_Blue)

      -- assign mission cap for Squadron
      assign_cap ( cap_zone_db_blue[2], 'Senaki', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue )

    end



    if activeBlueCAP then
      -- assign squadron at airbase
      -- 12 Mig-21 CAP @ sukumi
      local Sukhumi_Num_Air = 12

      -- funziona
      assign_squadron_at_airbase ('Sukhumi', AIRBASE.Caucasus.Sukhumi_Babushara, air_template_blue.CAP_Mig_21Bis, Sukhumi_Num_Air, A2ADispatcher_Blue)

      -- assign mission cap for Squadron
      assign_cap ( cap_zone_db_blue[3], 'Sukhumi', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue )

    end



    if activeBlueCAP then
      -- assign squadron at airbase
      -- 12 La-39 CAP sukumi @ sochi-gudauta
      local Gudauta_Num_Air = 12

      -- funziona
      assign_squadron_at_airbase ('Gudauta', AIRBASE.Caucasus.Gudauta, air_template_blue.CAP_L_39ZA, Gudauta_Num_Air, A2ADispatcher_Blue)

      -- assign mission cap for Squadron
      assign_cap ( cap_zone_db_blue[4], 'Gudauta', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue )

    end




    if activeBlueGCI then
      -- assign squadron at airbase
      -- 3 F-14A  GCI sukumi @ sochi-gudauta
      local Sochi_Num_Air = 3

      assign_squadron_at_airbase ('Sochi', AIRBASE.Caucasus.Sochi_Adler, air_template_blue.GCI_F_14A, Sochi_Num_Air, A2ADispatcher_Blue)

      -- assign CGI mission for Squadron:
      assign_gci('Sochi', 800, 1200, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue)

    end












































    ------------------------------------------------------------------------   AI A2G Dispatching ---------------------------------------------------------------


    ------------------------------------------------------------------------   NOTA DEVE ESSERE ANCORA IMPLEMENTATO IN MOOSE -----------------------

    -- info @ https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/AI.AI_A2G_Dispatcher.html

    local activeAI_A2G_Dispatching = false

    if activeAI_A2G_Dispatching then

        -- Define a SET_GROUP object that builds a collection of groups that define the recce network.
       -- Here we build the network with all the groups that have a name starting with CCCP Recce.
       --local DetectionSetGroupRed = SET_GROUP:New() -- Defene a set of group objects, caled DetectionSetGroup.

       --local DetectionSetGroupRed:FilterPrefixes( { "RED RECON" } ) -- The DetectionSetGroup will search for groups that start with the name "CCCP Recce".

       -- This command will start the dynamic filtering, so when groups spawn in or are destroyed,
       -- which have a group name starting with "CCCP Recce", then these will be automatically added or removed from the set.
       --local DetectionSetGroupRed:FilterStart()

       -- This command defines the reconnaissance network.
       -- It will group any detected ground enemy targets within a radius of 1km. (crea un gruppo per tutte le unita' detected (rilevate) presenti in una circonferenza di raggio 1 km)
       -- It uses the DetectionSetGroup, which defines the set of reconnaissance groups to detect for enemy ground targets.
       --local DetectionRed = DETECTION_AREAS:New( DetectionSetGroupRed, 1000 )

       -- Setup the A2A dispatcher, and initialize it.
       --local A2GDispatcherRed = AI_A2G_DISPATCHER:New( DetectionRed )


       -- The defense radius defines the maximum radius that a defense will be initiated around each defense coordinate
       --A2GDispatcherRed:SetDefenseRadius( 30000 ) -- 30Km

       -- A2GDispatcher:SetDefenseReactivityHigh()



       -- SEAD: Suppression of Air Defenses, which are ground targets that have medium or long range radar emitters.
       -- CAS : Close Air Support, when there are enemy ground targets close to friendly units.
       -- BAI : Battlefield Air Interdiction, which are targets further away from the frond-line.


       ------------------------------------------------------------------------   Red HQ1:  --------------------------------------------------------------

       --local HQ_RED_1 = GROUP:FindByName( "HQ_RED_1" )


       -- Add defense coordinates.
       --A2GDispatcherRed:AddDefenseCoordinate( HQ_RED_1:GetName(), HQ_RED_1:GetCoordinate() )

       --A2GDispatcherRed:SetSquadron( "Nalchik SEAD", AIRBASE.Caucasus.Nalchik, { air_template_red.CAS_Su_17M4_Rocket }, 10 )
       --A2GDispatcherRed:SetSquadronSead( "Nalchik SEAD", 500, 700, 2000, 4000 )
       -- AI_A2G_DISPATCHER:SetSquadronSead(SquadronName, EngageMinSpeed, EngageMaxSpeed, EngageFloorAltitude, EngageCeilingAltitude)
       -- nota: puoi usare anche:
       -- A2GDispatcher:SetSquadronSeadPatrol( "Maykop SEAD", PatrolZone, 300, 500, 50, 80, 250, 300 ) insieme a  A2GDispatcher:SetSquadronPatrolInterval( "Maykop SEAD", 2, 30, 60, 1, "SEAD" )
       -- permettono di avere gli aerei in patrol pronti ad intervenire
       --A2GDispatcherRed:SetSquadronTakeoffFromParkingCold( "Nalchik SEAD" )
       --A2ADispatcherRed:SetSquadronTakeOffInterval( "Nalchik SEAD", 60 * 4 ) -- dipende dal numero di slot disponibili: farp = 4, airbase = molti
       --A2ADispatcherRed:SetSquadronLandingAtEngineShutdown( "Nalchik SEAD" )


       --A2GDispatcherRed:SetSquadron( "Nalchik CAS", AIRBASE.Caucasus.Nalchik, { air_template_red.CAS_Su_17M4_Bomb, air_template_red.CAS_Su_17M4_Rocket,  air_template_red.CAS_Su_17M4_Cluster }, 12 )
       --A2GDispatcherRed:SetSquadronSead( "Nalchik CAS", 500, 700, 3000, 5000 )

       --A2GDispatcherRed:SetSquadron( "Nalchik BAI", AIRBASE.Caucasus.Nalchik, { air_template_red.CAS_Su_17M4_Bomb, air_template_red.BOM_SU_17_Structure }, 10 )
       --A2GDispatcherRed:SetSquadronSead( "Nalchik BAI", 500, 700, 6000, 10000 )



       ------------------------------------------------------------------------   Red HQ2:  --------------------------------------------------------------

       ------------------------------------------------------------------------   Red HQ3:  --------------------------------------------------------------

       ------------------------------------------------------------------------   Red HQ4:  --------------------------------------------------------------






    end --activeAI_A2G_Dispatching then
























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

    end -- end if

    ------------------------------------------- END RED CIVILIAN AIR TRAFFIC ------------------------------------------------------------------------------------------------------------------------------































    ------------------------------------------- BLUE CIVILIAN AIR TRAFFIC ------------------------------------------------------------------------------------------------------------------------------

    local blue_civilian_traffic = false

    if blue_civilian_traffic then

      local civilian_aircraft = {

        air_template_blue.TRAN_AN_26,
        air_template_blue.TRAN_YAK_40,
        --air_template_blue.TRAN_UH_60A,
        --air_template_blue.TRAN_CH_47,
        air_template_blue.TRAN_C_130

      }

      -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
      local red_civilian_traffic_sched = SCHEDULER:New( nil,

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

             logging('info', { 'main' , 'red_civilian_traffic_sched SCHEDULER - start time:' .. start_civ_sched .. ' ; scheduling time: ' .. interval_civ_sched * ( 1 - rand_civ_sched ) } )

          end, {}, start_civ_sched, interval_civ_sched, rand_civ_sched

      ) -- end  scheduler

    end -- end if

    ------------------------------------------- END BLUE CIVILIAN AIR TRAFFIC ------------------------------------------------------------------------------------------------------------------------------







  end -- end activeAirWar





end -- end if conflictZone == 'Zone 1: South Ossetia' then
