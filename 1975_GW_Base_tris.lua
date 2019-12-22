--[[


1975 Georgian War


Template BASE

autor: Marco Bellafante



note sviluppo:

la funzione OnAfterDelivered(From,Event,To,request) per tutte le WH puo' essere eliminata: lo scheduler si occupa del rinvio degli asset
Aggiornare il codice nelle funzioni OnAfterSelfRequest, OnAfterAssetDead come per le _addRequest



30.5.19:
in 1654 groupResupply e' nil!!!!!  Forse e' lo spawn o il local
in activeGO_TO_ZONEWarehouse modificare il parametro battlezone in toCoord in qnuanto queste sono rilevate nella activeGO_TO_BATTLEWarehouse
in  ArtyPositionAndFireAtTarget inserire e gestire i parametri moveCoordinate, speed e onroad e  e modificare le chiamate a questa funzione prima in activeGO_TO_BATTLEWarehouse
dopo verificato il funziomanento inserirla solo in activeGO_TO_ARTYWarehouse


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

mediante il nome dell'unit� template es: nome = 'SQ red CAP Mig_23MLD', unit.findByName(name), name_missile = unit.getDescr.getMissile.name, out_info(name_missile)





 LOAD MISSION LOG FILE:

    filename = 'F:\\Programmi\\luaDevTool\\workspace\\Test_Moose_Missions\\My Mission\\moose.lua'
    dofile(filename) se il file � in lua come credo che sia (mission.lua)


 PARSING MISSION LOG FILE:

   airbase avalaible, airbase_aircraft_avalaible,

   valutare la possibilit� di duplicare il file log di missione salvandolo con un nome specifico per l'utilizzo nella missione


   analisi:

   - valutazione perdite in relazione al contingente militare (*) di riferimento per la zona




 (*): il contingente militare � costituito da tutte le unit�/gruppi (tactical_group) che agiscono in una determinata zona tattica (tactical_zone) (**)

 (**): la zona tattica pu� essere rappresentata mediante una trigger zone. Il "fronte" pu� essere rappresentato da zone tattiche muovibili in runtime.
 NOTA: l'eventuale aggiornamento della situazione pu� essere effettuato in runtime (come nei server multiplayer) in modo da realizzare una situazione dinamica.
 La chiusura della missione comporterebbe solo il salvataggio dello stato attuale.



 Forse conviene utilizzare la modalit� server multiplayer in modo da proporre pi� missioni al player lasciando alla  AI la gestione dei piloti/missioni non selezionati:
 vedi:

   - https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_Balancer.html
   - https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master/AIB%20-%20AI%20Balancing


  per spawning:

  https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Core.Spawn.html
https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master/SPA%20-%20Spawning


-- La detection non dovrebbe essere modificato in quanto serve solo ad associare al sistema di rilevamento tutte le unit� di rilevameno con nome conforme al prefix_detector.

-- La posizione delle detector units (EWR) pu� eventualmente essere cambiata in base alla evoluzione della situazione.

-- Il dispatcher potrebbe essere modificato in base alla situazione: il gci_radius potrebbe essere ridotto cosi come l'engage radius.

-- assign_squadron_at_airbase viene modificato in base alla situazione: gli squadroni assegnati alla specifica airbase e il numero di aerei disponibili.

-- assign_gci viene modificato in base alla situazione definendo le missioni GCI in base alle zone tattiche relative alle basi aeree e alle zone strategiche definite.

-- assign_cap viene modificato in base alla situazione definendo le missioni CAP in base alle zone tattiche definite.


  GRUPPO TATTICO TERRESTRE
  tactical_ground_group: tabella contenente l'elenco dei gruppi tattici con definita per ciascuna unit� la posizione (vect3d?) e . Il gruppo tattico ha una warhouse contenente
  i rifornimenti per le unit�. Al gruppo tattico � associato il morale (che incider� negli skill di combattimento), la tactical_zone dove agisce, la categoria di appartenenza
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


--self:E( '1975GW - function: ' .. 'logging level' .. logginglevel)

-- DEFINE FUNCTION (devono essere posizonate prima del codice che le utilizza)



-- UTILITY FUNCTION




--- Registra in dcs.log le info di log
--
-- @param type = il tipo di logging: enter, exit, error, severe, warning, info, fine, finer, finest
-- @param info = info da inserire in base al type:
-- type = enter, exit  info = 'name function'
-- type = info error, warning, info, fine, finer, finest ={ 'name function' , 'info' }
-- 0 = nessun messaggio di log,   1 = error, 2 = severe, 3 = warning, 4 = info, 5 = fine, 6 = finer/enter/exit, 7 = finest
--
function logging(type, info)

    local msg = '1975GW - Function:  '

    if type == 'enter' and loggingLevel > 5 then  env.info( msg .. info .. '  ENTER') end

    if type == 'exit'  and loggingLevel > 5 then  env.info( msg .. info .. '  EXIT') end

    if type == 'error' and loggingLevel > 0 then  env.info( msg .. info[1] .. '  ERROR: ' .. info[2] ) end

    if type == 'severe' and loggingLevel > 1 then  env.info( msg .. info[1] .. '  SEVERE: ' .. info[2] ) end

    if type == 'warning' and loggingLevel > 2 then  env.info( msg .. info[1] .. '  WARNING: ' .. info[2] ) end

    if type == 'info' and loggingLevel > 3 then  env.info( msg .. info[1] .. '  INFO: ' .. info[2] ) end

    if type == 'fine' and loggingLevel > 4 then  env.info( msg .. info[1] .. '  FINE: ' .. info[2] ) end

    if type == 'finer' and loggingLevel > 5 then  env.info( msg .. info[1] .. '  FINER: ' .. info[2] ) end

    if type == 'finest' and loggingLevel > 6 then  env.info( msg .. info[1] .. '  FINEST: ' .. info[2] ) end

    return

end



--- Imposta il livello di log impostando la variabile loggingLevel.
--
--  @param level = 1 = error, 2 = severe, 3 = warning, 4 = info, 5 = fine, 6 = finer, 7 = finest
--
function setLoggingLevel(level)


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

  logging('enter', 'defineRequestPosition(num_pos)')

  if num_pos > 30 then num_pos = 30 end
  if num_pos < 1 then num_pos = 1 end
  logging('finest', { 'defineRequestPosition(num_pos)' , 'num_pos = ' .. num_pos  } )
  local pos = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}
  local pos_f = {}

  for i = 1, num_pos do

    local b = math.random(num_pos-#pos_f)
    pos_f[ i ] = pos[ b ]
    table.remove( pos, b )
    logging('finest', { 'defineRequestPosition(num_pos)' , 'pos_f[' .. i .. '] = ' .. pos_f[ i ] .. ' - removed pos[' .. #pos_f .. '] = ' .. pos_f[#pos_f]  } )

  end

  logging('exit', 'defineRequestPosition(num_pos)')

  return pos_f

end



--- Restituisce velocita' e altitudine comprese tra i paramentri della funzione
-- @param: min_vel, max_vel, min_alt, max_alt
function defineSpeedAndAltitude(min_vel, max_vel, min_alt, max_alt)

    logging('enter', 'defineSpeedAndAltitude(min_vel, max_vel, min_alt, max_alt)')

  if min_vel < 0 or min_vel > 3000 then min_vel = 100 end
  if max_vel < 0 or max_vel > 3000 then max_vel = 200 end
  if min_alt < 10 or min_alt > 20000 then min_vel = 1000 end
  if max_alt < 10 or max_alt > 20000 then max_vel = 2000 end


  local speed = math.random( min_vel, max_vel )
  local altitude = math.random( min_alt, max_alt )

  logging('exit', 'defineSpeedAndAltitude(min_vel, max_vel, min_alt, max_alt)')

  return speed, altitude

end



--- Restituisce i parametri necessari per configurare una BAI Mission di tipo target
-- @param: type_aircraft ('fighter_bomber', 'bomber', 'helycopter')
function calcParamForBAI_target(type_aircraft)

  logging('enter', 'calcParamForBAI_target(type_aircraft)')

  if type_aircraft == 'fighter_bomber' then
    speed_patrol_max = 700
    speed_patrol_min = 500
    speed_attack = math.random(400, 600)
    altitude_attack = math.random(1500, 3000)
    altitude_patrol_max = 8000
    altitude_patrol_min = 5000

  elseif type_aircraft == 'bomber' then
    speed_patrol_max = 600
    speed_patrol_min = 500
    speed_attack = math.random(400, 500)
    altitude_attack = math.random(2000, 4000)
    altitude_patrol_max = 12000
    altitude_patrol_min = 7000

  else --hely
    speed_patrol_max = 300
    speed_patrol_min = 200
    speed_attack = math.random(200, 300)
    altitude_attack = math.random(500, 1000)
    altitude_patrol_max = 3000
    altitude_patrol_min = 1000
  end


  local attack_angle = math.random( 0 , 360 )
  local num_attack = math.random( 1 , 4 )

  local time_to_engage = 300
  local time_to_RTB = -3500


   --[[

          'AI.Task.WeaponExpend.ALL


          AI.Task.WeaponExpend.FOUR


          AI.Task.WeaponExpend.HALF


          AI.Task.WeaponExpend.ONE


          AI.Task.WeaponExpend.QUARTER


          AI.Task.WeaponExpend.TWO'

          ]]--



  local num_weapon = AI.Task.WeaponExpend.QUARTER

  if num_attack == 1 then
    num_weapon = AI.Task.WeaponExpend.ALL

  elseif num_attack == 2 then
    num_weapon = AI.Task.WeaponExpend.HALF

  else
    -- se gli attacchi sono 3 li porta a 4 in modo da impostare un rilascio di weapon pari ad 1/4
      num_attack = 4

  end

  logging('finest', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB: ' .. speed_attack .. ' - ' .. altitude_attack .. ' - ' .. speed_patrol_min .. ' - ' .. altitude_patrol_min .. ' - ' .. speed_patrol_max .. ' - ' .. altitude_patrol_max .. ' - ' .. attack_angle  .. ' - ' .. num_attack .. ' - ' .. num_weapon .. ' - ' .. time_to_engage .. ' - ' .. time_to_RTB } )
  logging('exit', 'calcParamForBAI_target(type_aircraft)')

  return speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB

end



-- END UTILITY FUNCTION



-- DETECTION

-- La detection non dovrebbe essere modificato in quanto serve solo ad associare al sistema di rilevamento tutte le unit� di rilevameno con nome conforme al prefix_detector.
-- Eventualmente la posizione delle detector units (EWR) pu� essere cambiata in base alla evoluzione della situazione.


--- Create a detection zone based on a group of detector units.
--  The detector group is created utilizing detector units with name formed with prefix_detector.
--
--
-- @param prefix_detector:  table with name of EWR unit in Mission Editor
-- @param range:  range max of detection target
-- @return DETECTION_AREAS
function detection(prefix_detector, range)

  local DetectionSetGroup = SET_GROUP:New()
  DetectionSetGroup:FilterPrefixes( prefix_detector )
  DetectionSetGroup:FilterStart()
  Detection = DETECTION_AREAS:New( DetectionSetGroup, range )

  return Detection

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
function dispatcher(detection, gci_radius, engage_radius, view_tactical_display)

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
function assign_squadron_at_airbase (airbase_name, airbase, squadron_name, no_aircraft, A2ADispatcher)

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
function activePATROLWarehouse(groupset, capZoneName, typeZoneName, engageRange, engageZone, typeEngageZoneName, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage )

      -- nota: inserire il mission accomplish se le munizioni sono finite, l'eventuale check del fuel, se danneggiato ecc.
      -- modifica la funzione in modo da passare direttamente la zone come parametro

      local patrolZone = defineZone( capZoneName, typeZoneName )

      for _,group in pairs(groupset:GetSetObjects()) do

        -- local patrolZone = defineZone( capZoneName, typeZoneName )

        -- attiva tutti gli aerei uncontrolled
        group:StartUncontrolled()

        CAP = AI_A2A_CAP:New(group, patrolZone, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage)

        -- Tell the program to use the object (in this case called CAPPlane) as the group to use in the CAP function
        CAP:SetControllable(group)

        -- set engage rules
        if engageRange ~= nil then

          -- Set enage range from aircraft
          CAP:SetEngageRange(engageRange)

        elseif engageZone ~= nil then

          -- Set enage zone
          engageZone = defineZone( capZoneName, typeEngageZoneName )
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


function activePATROLWarehouseA( param )

    activePATROLWarehouse(param[1], param[2], param[3], param[4], param[5], param[6], param[7], param[8], param[9], param[10], param[11], param[12])

end


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
-- ATTIVA SOLO UN AEREO: BOH!!!
--
function activeBAIWarehouse(nameMission, groupset, typeOfBAI, patrolZoneName, engageZoneName, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, targets, requestNumberKill, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission )


        local patrolZone = defineZone( patrolZoneName, 'circle' )
        local engageZone = defineZone( engageZoneName, 'circle' )

        for _, _group in pairs(groupset:GetSetObjects()) do

                local group = _group --Wrapper.Group#GROUP

                -- Start uncontrolled aircraft.
                group:StartUncontrolled()

                --self:E( "BAI Mission: " .. nameMission .. ": group = " .. group .." started!!" )
                --MESSAGE:New("BAI Mission: " .. nameMission .. ": group = " .. group .." started!!", 10):ToAll()


                BAI = AI_BAI_ZONE:New(patrolZone, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, engageZone)

                -- Tell the program to use the object (in this case called BAIPlane) as the group to use in the BAI function
                BAI:SetControllable(group)

                local Check, CheckScheduleID

                if typeOfBAI == 'bombing' then

                    -- Tell the BAI not to search for potential targets in the BAIEngagementZone, but rather use the center of the BAIEngagementZone as the bombing location.
                      BAI:SearchOff()

                    -- inserire il codice per verificare se il bombardamento � stato effettuato e ordinare l'rtb:  BAI:__RTB(1)

                elseif typeOfBAI == 'target' and targets ~= nil then

                    -- Function checking if targets are still alive: utilizzata per stabilire se la missione e' stata eseguita (imposta BAI_Accomplish a 1)
                        local function CheckTargets()

                                local nTargets = targets:GetSize()
                                local nInitial = targets:GetInitialSize()
                                local nDead = nInitial-nTargets

                                if targets:IsAlive() and nDead < requestNumberKill then

                                    MESSAGE:New(string.format("BAI Mission: " .. nameMission .. ": %d of %d red targets still alive. At least %d targets need to be eliminated.", nTargets, nInitial, requestNumberKill), 5):ToAll()

                                else

                                    MESSAGE:New("BAI Mission: " .. nameMission .. ": The required red targets are destroyed. Mission accomplish!", 30):ToAll()
                                    BAI:__Accomplish(1) -- Now they should fly back to the patrolzone and patrol (nota che l'accomplish nella funzione evento ordina l'RTB vedi sotto).

                                end -- end if

                        end  -- end local function

                        -- Schedula la funzione locale CheckTargets() con un ritardo iniziale di 60 secondi e successivamente una frequenza di ripetizione di 60 secondi.
                        -- Start scheduler to monitor number of targets and so order RTB.
                        Check, CheckScheduleID = SCHEDULER:New(nil, CheckTargets, {}, 60, 60)

                end -- end if

                -- inserire una funzione evento se le munizioni sono finite -- accomplish, rtb se non e' automatico


                -- When the targets in the zone are destroyed, (see scheduled function), the planes will return home ...
                function BAI:OnAfterAccomplish( Controllable, From, Event, To )

                      MESSAGE:New( "BAI Mission:" .. nameMission .." Sending the aircraft back to base.", 30):ToAll()
                      Check:Stop(CheckScheduleID) -- chiude lo Scheduler
                      BAI:__RTB(1) -- qui viene ordinato l'RTB ma potresti eliminarlo in modo che la BAI rimanga nella patrol zone in attesa di successivi comandi

                end -- end function

                -- Start BAI
                -- BAI:__Start(delayMission)
                BAI:Start()

                -- Engage after timeToEngage.
                -- BAI:__Engage(timeToEngage, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection)
                BAI:__Engage()

                -- RTB after timeToRTB.
                BAI:__RTB(timeToRTB)

        end -- end for

        return

end -- end function




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
function activeBAIWarehouseBis(nameMission, groupset, typeOfBAI, patrolZoneName, engageZoneName, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, targets, requestNumberKill, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission )


          if typeOfBAI == 'bombing' then

             activeBAIWarehouseP(nameMission, groupset, patrolZoneName, engageZoneName, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission )

          elseif typeOfBAI == 'target' and targets ~= nil then

            activeBAIWarehouseT(nameMission, groupset, patrolZoneName, engageZoneName, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, targets, requestNumberKill, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission )

          end -- end if

          return


end -- end function



--- Attiva il task BAI per un asset assegnato
--
-- @param param:  tabella conentente i seguenti parametri:
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param typeOfBAI = tipo di BAI richiesta = 'bombing': bombarda il centro della engage zone, 'target': Attacca i target
-- @param patrolZoneName = il nome della Zone assegnata per la patrol
-- @param engageZoneName = il nome della Zone di ingaggio
-- @param engageSpeed =  velocita di attacco
-- @param engageAltitude = quota di attacco
-- @param engageWeaponExpend = numero di weapon da sganciare
-- @param engageAttackQty = numero attacchi
-- @param engageDirection = direzione angolare di attacco
-- @param targets = il wrapper:group dei target
-- @param requestNumberKill = il numero di target distrutti utilizzato per valutare il completamento della missione
-- @param patrolFloorAltitude = altezza minima  nella patrol zone
-- @param patrolCeilAltitude = altezza massima nella patrol zone
-- @param minPatrolSpeed = velocita minima di pattugliamento
-- @param maxPatrolSpeed = velocita massima di pattugliamento
-- @param timeToEngage = timer per l'ingaggiare
-- @param timeToRTB = timer per l'RTB
-- @param delay = ritardo di attesa per l'attivazione della missione
--
-- OK
--
function activeBAIWarehouseBisA(param)

    logging('enter', 'activeBAIWarehouseBisA(param)')

    -- { 'Interdiction from Tbilisi', groupset, 'target', "Patrol Zone Tbilisi", "Patrol Zone Tbilisi", 400, 1000, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 },

    if not checkParam( param, 'all') then

      logging('warning', { 'activeBAIWarehouseBisA(param)' , 'some parameter are null.' } )

    end

    activeBAIWarehouseBis( param[1], param[2], param[3], param[4], param[5], param[6], param[7], param[8], param[9], param[10], param[11], param[12], param[13], param[14], param[15], param[16], param[17], param[18], param[19] )

    logging('exit', 'activeBAIWarehouseBisA(param)')

end





--- Attiva il task BAI contro un target predefinito per un asset assegnato
--
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
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
--
function activeBAIWarehouseT(nameMission, groupset, patrolZoneName, engageZoneName, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, targets, requestNumberKill, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission )

        local patrolZone = defineZone( patrolZoneName, 'circle' )
        local engageZone = defineZone( engageZoneName, 'circle' )


        for _,group in pairs(groupset:GetSetObjects()) do

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

                    if targets:IsAlive() and nDead < requestNumberKill then

                      MESSAGE:New(string.format("BAI Mission: " .. nameMission .. ": %d of %d red targets still alive. At least %d targets need to be eliminated.", nTargets, nInitial, requestNumberKill), 5):ToAll()

                    else

                      MESSAGE:New("BAI Mission: " .. nameMission .. ": The required red targets are destroyed. Mission accomplish!", 30):ToAll()
                      BAI:__Accomplish(1) -- Now they should fly back to the patrolzone and patrol (nota che l'accomplish nella funzione evento ordina l'RTB vedi sotto).

                    end -- end if

              end  -- end local function


                -- Schedula la funzione locale CheckTargets() con un ritardo iniziale di 60 secondi e successivamente una frequenza di ripetizione di 60 secondi.
                -- Start scheduler to monitor number of targets and so order RTB.
                Check, CheckScheduleID = SCHEDULER:New(nil, CheckTargets, {}, 60, 60)

              -- inserire una funzione evento se le munizioni sono finite -- accomplish, rtb se non e' automatico


              -- When the targets in the zone are destroyed, (see scheduled function), the planes will return home ...
              function BAI:OnAfterAccomplish( Controllable, From, Event, To )

                    MESSAGE:New( "BAI Mission:" .. nameMission .." Sending the aircraft back to base.", 30):ToAll()
                    Check:Stop(CheckScheduleID) -- chiude lo Scheduler
                    BAI:__RTB(1) -- qui viene ordinato l'RTB ma potresti eliminarlo in modo che la BAI rimanga nella patrol zone in attesa di successivi comandi

              end -- end function

              -- Start BAI
              BAI:__Start(delayMission)

              -- Engage after timeToEngage.
              BAI:__Engage(timeToEngage, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection)

              -- RTB after timeToRTB.
              BAI:__RTB(timeToRTB)

            end -- end for

            return

end -- end function






--- Attiva il task BAI contro il centro della engage zone per un asset assegnato
--
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param patrolZoneName = il nome della Zone assegnata per la patrol
-- @param engageZoneName = il nome della Zone di ingaggio
-- @param engageSpeed =  velocit� di attacco
-- @param engageAltitude = quota di attacco
-- @param engageWeaponExpend = numero di weapon da sganciare
-- @param engageAttackQty = numero attacchi
-- @param engageDirection = direzione angolare di attacco
-- @param requestNumberKill = il numero di target distrutti utilizzato per valutare il completamento della missione
-- @param patrolFloorAltitude = altezza minima  nella patrol zone
-- @param patrolCeilAltitude = altezza massima nella patrol zone
-- @param minPatrolSpeed = velocit� minima di pattugliamento
-- @param maxPatrolSpeed = velocit� massima di pattugliamento
-- @param timeToEngage = timer per l'ingaggiare
-- @param timeToRTB = timer per l'RTB
-- @param delay = ritardo di attesa per l'attivazione della missione
--
--
--
function activeBAIWarehouseP(nameMission, groupset, patrolZoneName, engageZoneName, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission )

        local patrolZone = defineZone( patrolZoneName, 'circle' )
        local engageZone = defineZone( engageZoneName, 'circle' )

        for _, group in pairs(groupset:GetSetObjects()) do

              local group = group --Wrapper.Group#GROUP

              -- Start uncontrolled aircraft.
              group:StartUncontrolled()

              -- self:E( "BAI Mission: " .. nameMission .. ": group = " .. group .." started!!" )
              -- MESSAGE:New("BAI Mission: " .. nameMission .. ": group = " .. group .." started!!", 10):ToAll()


              BAI = AI_BAI_ZONE:New(patrolZone, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, engageZone)

              -- Tell the program to use the object (in this case called BAIPlane) as the group to use in the BAI function
              BAI:SetControllable(group)

              local Check, CheckScheduleID

              -- Tell the BAI not to search for potential targets in the BAIEngagementZone, but rather use the center of the BAIEngagementZone as the bombing location.
              BAI:SearchOff()

              -- inserire una funzione evento se le munizioni sono finite -- accomplish, rtb se non e' automatico

              -- Start BAI
              BAI:__Start(delayMission)

              -- Engage after timeToEngage.
              BAI:__Engage(timeToEngage, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection)

              -- RTB after timeToRTB.
              BAI:__RTB(timeToRTB)

        end -- end for

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
function activeGCIWarehouse(groupset, capZoneName, typeZoneName, engageRange, engageZone, typeEngageZoneName, patrolFloorAltitude, ceilFloorAltitude, minSpeedEngage, maxSpeedEngage )

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


    --[[ i task sono descritti in controllable:

    https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Controllable.html





        ]]

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
          --local task=group:TaskBombing(target:GetCoordinate():GetVec2(), false, "All", nil , reconDirection, reconAltitude, bombQuantity)

          -- Define waypoints.
          local WayPoints={}

          -- Take off position.
          WayPoints[1]=home:GetCoordinate():WaypointAirTakeOffParking()
          -- Begin bombing run 20 km south of target.
          WayPoints[2]=ToCoord:Translate(reconRunDistance, reconRunDirection):WaypointAirTurningPoint(nil, speedBombRun, {task}, "RECON Run")
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
-- @param target = il target (es warehouse.tblisi)
-- @param toTargetAltitude = altitudine relativa alla rotta verso il target
-- @param toHomeAltitude = altitudine relativa alla rotta verso la airbase
-- @param bombingDirection = la direzione di attacco
-- @param bombingAltitude = altitudine di attacco
-- @param bombQuantity = quantit� di weapon da rilasciare
-- @param bombRunDistance = distanza dal target per l'inizio del run
-- @param bombRunDirection = direzione del run
-- @param speedBombRun = velocit� di attacco
--
function activeBOMBINGWarehouse(groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombQuantity, bombRunDistance, bombRunDirection, speedBombRun )

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
              local task=group:TaskBombing(target:GetCoordinate():GetVec2(), false, "All", nil , bombingDirection, bombingAltitude, bombQuantity)

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


--- Attiva il task STRATEGIC BOMBING per un asset assegnato
--
-- @param param = tabella contenente i seguenti parametri:
-- @param groupset = il gruppo (asset) proveniente dalla warehouse
-- @param home = il nome della warehouse airbase di partenza
-- @param target = il target (es warehouse.tblisi)
-- @param toTargetAltitude = altitudine relativa alla rotta verso il target
-- @param toHomeAltitude = altitudine relativa alla rotta verso la airbase
-- @param bombingDirection = la direzione di attacco
-- @param bombingAltitude = altitudine di attacco
-- @param bombQuantity = quantita' di weapon da rilasciare
-- @param bombRunDistance = distanza dal target per l'inizio del run
-- @param bombRunDirection = direzione del run
-- @param speedBombRun = velocita' di attacco
--
--
function activeBOMBINGWarehouseA(  param )

    activeBOMBINGWarehouse( param[1], param[2],  param[3], param[4], param[5],  param[6], param[7], param[8],  param[9], param[10], param[11] )

end



--- Attiva l'invio di cargo
-- @param groupPlaneSet = il gruppo di aerei utilizzati per il trasporto
-- @param pickupAirbaseName = il nome della airbase di partenza (es: pickupAirbaseName = AIRBASE.Caucasus.Kobuleti)
-- @deployAirbaseName =  il nome della airbase di arrivo (es: deployAirbaseName = AIRBASE.Caucasus.Batumi)
-- @groupCargoSet = il carico da trasportare
-- @speed = velocita' del trasporto
--
function activeCARGOWarehouse( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )


  logging('enter', 'activeCARGOWarehouse( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )')

  logging('finest', { 'activeCARGOWarehouse( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )' , 'pickupAirbaseName = ' .. pickupAirbaseName .. 'deployAirbaseName = ' .. deployAirbaseName .. '  -  group = ' .. groupPlaneSet:GetName() .. '  -  speed = ' .. tostring(speed) } )

  local lenghtGroupCargoSet = #groupCargoSet
  local i = 1

  for _, group in pairs(groupPlaneSet:GetSetObjects()) do

        if i <= #groupCargoSet then

            local groupCargo = groupCargoSet[i]

            i = i + 1

            local group = group --Wrapper.Group#GROUP

            -- Start uncontrolled aircraft.
            -- group:StartUncontrolled()

            pickupAirbase = AIRBASE:FindByName( pickupAirbaseName )
            DeployAirbase = AIRBASE:FindByName( deployAirbaseName )

            CargoAirplane = AI_CARGO_AIRPLANE:New( group, groupCargo )
            CargoAirplane:Pickup( PickupAirbase )

            function CargoAirplane:onafterLoaded( Airplane, From, Event, To, Cargo )
              CargoAirplane:Deploy( DeployAirbase, speed )
            end


            function CargoAirplane:onafterUnloaded( Airplane, From, Event, To, Cargo )
              CargoAirplane:Pickup( PickupAirbase, speed )
            end

          end -- end if

  end -- end for


  logging('exit', 'activeCARGOWarehouse( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet )')

  return

end -- end function




--- Attiva l'invio di ground asset nella zone.
-- @param groupset = il gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeGO_TO_ZONE_AIR_Warehouse( group, battlezone, speedPerc )


  logging('enter', 'activeGO_TO_ZONEWarehouse( group, battlezone )')

  logging('finest', { 'activeGO_TO_ZONEWarehouse( group, battlezone )' , 'battlezone = ' .. battlezone[2] .. '  -  group = ' .. group:GetName() .. '  -  offRoad = ' .. tostring(offRoad) .. '  -  speedPerc = ' .. tostring(speedPerc) } )

  local battleZone = battlezone[1] -- the zone object

  if nil == offRoad or offRoad ~= true then offRoad = false end

  if nil == speedPerc or speedPerc > 1 or speedPerc < 0.1 then speedPerc = 0.7 end

  -- radius=radius or 100

  -- seleziona ogni gruppo appartenente al set

  for _,group in pairs(groupset:GetSet()) do

    local group = group --Wrapper.Group#GROUP

    -- Route group to Battle zone.
    local ToCoord = battleZone:GetRandomCoordinate()
    local groupCoord = group:GetCoordinate()
    group:RouteAirTo(ToCoord, 'BARO', ToCoord.WaypointType, nil)

    logging('finest', { 'activeGO_TO_ZONEWarehouse( group, battlezone )' , 'routeToRoad exist = ' .. tostring(exist) .. '  -  length = ' .. tostring(length) } )



  end -- end for



  logging('exit', 'activeGO_TO_ZONEWarehouse( group, battlezone )')

  return

end -- end function




--- Attiva l'invio di ground asset nella zone.
-- @param groupset = il gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeGO_TO_ZONEWarehouse( group, battlezone, offRoad, speedPerc )


    logging('enter', 'activeGO_TO_ZONEWarehouse( group, battlezone )')

    logging('finest', { 'activeGO_TO_ZONEWarehouse( group, battlezone )' , 'battlezone = ' .. battlezone[2] .. '  -  group = ' .. group:GetName() .. '  -  offRoad = ' .. tostring(offRoad) .. '  -  speedPerc = ' .. tostring(speedPerc) } )

    local battleZone = battlezone[1] -- the zone object

    if nil == offRoad or offRoad ~= true then offRoad = false end

    if nil == speedPerc or speedPerc > 1 or speedPerc < 0.1 then speedPerc = 0.7 end

    -- radius=radius or 100

    -- seleziona ogni gruppo appartenente al set


    local group = group --Wrapper.Group#GROUP

    -- Route group to Battle zone.
    local ToCoord = battleZone:GetRandomCoordinate()
    local groupCoord = group:GetCoordinate()
    local route, length, exist = groupCoord:GetPathOnRoad( ToCoord )

    logging('finest', { 'activeGO_TO_ZONEWarehouse( group, battlezone )' , 'routeToRoad exist = ' .. tostring(exist) .. '  -  length = ' .. tostring(length) } )


    if exist and not offRoad then

      logging('finest', { 'activeGO_TO_ZONEWarehouse( group, battlezone )' , 'routeToRoad' } )
      -- Ottimizzazione: evita il ricalcolo della route. Cmq dai un occhiata a Moose group:RouteGroundOnRoad per una eventuale modifica
      -- group:RoutePush( route )
      group:RouteGroundOnRoad( ToCoord, group:GetSpeedMax() * speedPerc )

    else

      logging('finest', { 'activeGO_TO_ZONEWarehouse( group, battlezone )' , 'routeToGround' } )
      group:RouteGroundTo( ToCoord, group:GetSpeedMax() * speedPerc )

    end


    logging('exit', 'activeGO_TO_ZONEWarehouse( group, battlezone )')

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
--
function activeGO_TO_BATTLEWarehouse( groupset, battlezone, task, param, offRoad, speedPerc )

        logging('enter', 'activeGO_TO_BATTLEWarehouse( groupset, battlezone )')

        logging('finest', { 'activeGO_TO_BATTLEWarehouse( groupset, battlezone )' , 'gorupsetName: ' .. groupset:GetObjectNames() } )

        local battleZone = battlezone[1] -- the zone object
        local ToCoord = battleZone:GetRandomCoordinate()

          for _,group in pairs(groupset:GetSet()) do

            local group = group --Wrapper.Group#GROUP

            activeGO_TO_ZONEWarehouse( group, battlezone, offRoad, speedPerc )

            logging('finest', { 'activeGO_TO_BATTLEWarehouse( groupset, battlezone )' , 'task = '.. task } )

            -- task per attacco diretto
            if task == 'enemy_attack' then

              -- After 3-5 minutes we create an explosion to destroy the group.
              -- sostituisce con task per enemy attack: search & destroy

              SCHEDULER:New(nil, Explosion, {group, 50}, math.random(180, 300))
              logging('finest', { 'activeGO_TO_BATTLEWarehouse( groupset, battlezone )' , 'execute enemy_attack tasking'} )

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

              logging('finest', { 'activeGO_TO_BATTLEWarehouse( groupset, battlezone )' , 'execute artillery_firing tasking   -  ' .. 'num target zone = ' .. #listTargetInfo .. '  -  groupResupplySet = ' .. groupResupplySet:GetObjectNames() .. '-  speed = ' .. tostring(speed) .. '-  onRoad = ' .. tostring(onRoad) .. '-  maxDistance = ' .. tostring(maxDistance) .. '-  maxFiringRange = ' .. tostring(maxFiringRange) } )


              ArtyPositionAndFireAtTarget(group, groupResupplySet, ToCoord, listTargetInfo, command_center, activateDetectionReport, speed, onRoad, maxDistance, maxFiringRange)

            end  --end if

            -- task per ricognizione e fuoco di artiglieria su bersagli mobili
            if task == 'artillery_detection_and_firing' then


              --qui la funzione che utilizza la func ArtyFireAtDetection

              -- tasking for artillery firing
                logging('finest', { 'activeGO_TO_BATTLEWarehouse( groupset, battlezone )' , 'execute artillery_detection_and_firing tasking'} )

            end  --end if

            -- task per posizione difensiva
            if task == 'defence' then

                  -- tasking for artillery firing
                  logging('finest', { 'activeGO_TO_BATTLEWarehouse( groupset, battlezone )' , 'execute defence tasking'} )

            end  --end if


        end -- end for

        logging('exit', 'activeGO_TO_BATTLEWarehouse( groupset, battlezone )')

        return

end -- end function




--- Invia il groupset artillery asset nella firing zone e attiva il fuoco sulla zona target.
-- @param groupset = il set dei gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param param (optional) : lista contenente ulteriori parametri
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeGO_TO_ARTYWarehouse( groupset, battlezone, param, onRoad, speed )

  logging('enter', 'activeGO_TO_ARTYWarehouse( groupset, battlezone )')

  logging('finest', { 'activeGO_TO_ARTYWarehouse( groupset, battlezone )' , 'gorupsetName: ' .. groupset:GetObjectNames() } )

  local battleZone = battlezone[1] -- the zone object
  local ToCoord = battleZone:GetRandomCoordinate()

  for _,group in pairs(groupset:GetSet()) do

    local group = group --Wrapper.Group#GROUP

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

      logging('finest', { 'activeGO_TO_ARTYWarehouse( groupset, battlezone )' , 'item.weaponType = ' .. tostring(item.weaponType) .. ' - item.num_shots = ' .. tostring(item.num_shots) .. '  -  item.num_engagements = ' .. tostring(item.num_engagements) .. ' -  numOtherAmmo[item.weaponType] = ' .. tostring(numOtherAmmo[item.weaponType]) } )
      numOtherAmmo[item.weaponType] = numOtherAmmo[item.weaponType] + item.num_shots * item.num_engagements
      logging('finest', { 'activeGO_TO_ARTYWarehouse( groupset, battlezone )' , 'numOtherAmmo[item.weaponType] = ' .. tostring(numOtherAmmo[item.weaponType]) } )

    end


    logging('finest', { 'activeGO_TO_ARTYWarehouse( groupset, battlezone )' , 'execute artillery_firing tasking   -  ' .. 'num target zone = ' .. #listTargetInfo .. '  -  groupResupplySet = ' .. groupResupplySet:GetObjectNames() .. '-  speed = ' .. tostring(speed) .. '-  onRoad = ' .. tostring(onRoad) .. '-  maxDistance = ' .. tostring(maxDistance) .. '-  maxFiringRange = ' .. tostring(maxFiringRange) } )

    ArtyPositionAndFireAtTarget(group, groupResupplySet, ToCoord, listTargetInfo, command_center, activateDetectionReport, speed, onRoad, maxDistance, maxFiringRange, numOtherAmmo)

  end -- end for

  logging('exit', 'activeGO_TO_GO_TO_ARTYWarehouse( groupset, battlezone )')

  return

end -- end function


--- Richiede una BAI Mission per una warehouse
--
-- -- ATTIVA SOLO UN AEREO DEL GRUPPO ???
--
-- @param nameMissione = nome della missione
-- @param warehouse = la warehouse oggetto della richiesta
-- @param airTemplate = il template dei mezzi aerei impiegati (forse possono essere misti: un gruppo di aerei di tipo diverso se ha senso)
-- @param quantity = la quantit� dei mezzi aerei impiegati
-- @param typeOfTarget = il tipo di obbiettivo della BAI Mission: 'troops' (mezzi terrestri) o 'infrastructure' (il centro della zona deve essere posizionato sull'obbiettivo)
-- @param patrolZoneName = il nome della Zone assegnata per la patrol
-- @param engageZoneName = il nome della Zone di ingaggio
-- @param engageSpeed =  velocit� di attacco
-- @param engageAltitude = quota di attacco
-- @param engageWeaponExpend = numero di weapon da sganciare
-- @param engageAttackQty = numero attacchi
-- @param engageDirection = direzione angolare di attacco
-- @param target = il nome del gruppo target
-- @param requestNumberKill = il numero di target distrutti utilizzato per valutare il completamento della missione
-- @param patrolFloorAltitude = altezza minima  nella patrol zone
-- @param patrolCeilAltitude = altezza massima nella patrol zone
-- @param minPatrolSpeed = velocit� minima di pattugliamento
-- @param maxPatrolSpeed = velocit� massima di pattugliamento
-- @param timeToEngage = timer per l'ingaggiare
-- @param timeToRTB = timer per l'RTB
-- @param delayMission = ritardo di attesa per l'attivazione della missione
-- @param delaySpawn = ritardo di attesa per lo spawn nella parking zone
--
-- dispatchBAIMission(warehouse.Mineralnye, 0, air_template_red.BOM_SU_24_Bomb, 2, 'infrastructure', nil, "bombing zone", "bombing zone", 1, 500, 1000, 400, 500)
--
function  dispatchBAIMission(nameMission, warehouse, airTemplate, airplaneQuantity, typeOfTarget, target, patrolZoneName, engageZoneName, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, requestNumberKill, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission, delaySpawn)

      local typeOfBAI = nil
      local targets = nil
      local numOfRepeat = 0

      if typeOfTarget == 'troops' then

        -- targets in zone (late activated).
        targets = GROUP:FindByName(target)

        -- activate the targets.
        targets:Activate()

        typeOfBAI = 'target'

      elseif typeOfTarget == 'infrastructure' then

        typeOfBAI = 'bombing'

      end


       -- autorequest for spawn aircraft in parking area (watch combatibility parking zone - aircraft)
      warehouse:__AddRequest(delaySpawn, warehouse, WAREHOUSE.Descriptor.GROUPNAME, airTemplate, airplaneQuantity, nil, nil, nil, nameMission)


      -- MESSAGE:New( "dispatchBAIMission: typeOfBAI = "..typeOfBAI, 30):ToAll()

        -- Do something with the spawned aircraft.
      function warehouse:OnAfterSelfRequest(From,Event,To,groupset,request)

        local groupset=groupset --Core.Set#SET_GROUP
        local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem


        -- provato anche a inserire direttamente il codice di activeBAIWarehouse senza successo: forse vuole che le warehouse siano globali e non passate come parametro della funzione per un funzionamento corretto

        -- codice per scegliere random missione e parametri
        -- schedule per schedulare diverse BAI mission in tempi diversi
        activeBAIWarehouseBis(nameMission, groupset, typeOfBAI, patrolZoneName, engageZoneName, engageSpeed, engageAltitude, engageWeaponExpend, engageAttackQty, engageDirection, targets, requestNumberKill, patrolFloorAltitude, patrolCeilingAltitude, minPatrolSpeed, maxPatrolSpeed, timeToEngage, timeToRTB, delayMission )



      end -- end function

      --[[

      function warehouse:OnAfterDelivered(From,Event,To,request)

        local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

         -- codice per gestire il rilascio

      end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)



       -- An asset has died ==> request resupply for it.
     function warehouse:OnAfterAssetDead(From, Event, To, asset, request)

       local asset=asset       --Functional.Warehouse#WAREHOUSE.Assetitem
       local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        -- Get assignment.
       local assignment=warehouse.Didi:GetAssignment(request)

         -- codice per gestire la perdita degli asset

      end -- end function
      ]]--

end -- end function













--- Richiede una PIN POINT STRIKE Mission per una warehouse
--
-- ATTIVA SOLO UN AEREO DEL GRUPPO ???
--
-- @param nameMissione = nome della missione
-- @param warehouse = la warehouse oggetto della richiesta
-- @param criterioSceltaAsset = 'template' o 'classe'
-- @param airAsset = il template dei mezzi aerei impiegati (forse possono essere misti: un gruppo di aerei di tipo diverso se ha senso) o la classe (es WAREHOUSE.Attribute.AIR_BOMBER)
-- @param quantity = quantit� di air-asset
-- @param target = il target (es warehouse.tblisi)
-- @param toTargetAltitude = altitudine relativa alla rotta verso il target
-- @param toHomeAltitude = altitudine relativa alla rotta verso la airbase
-- @param bombingDirection = la direzione di attacco
-- @param bombingAltitude = altitudine di attacco
-- @param bombQuantity = quantit� di weapon da rilasciare
-- @param bombRunDistance = distanza dal target per l'inizio del run
-- @param bombRunDirection = direzione del run
-- @param speedBombRun = velocit� di attacco
-- @param delaySpawn = ritardo di attesa per lo spawn nella parking zone
--
--
function  dispatchBOMBINGMission(nameMission, warehouse, criterioSceltaAsset, airAsset, quantity, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombQuantity, bombRunDistance, bombRunDirection, speedBombRun, delaySpawn)

      local targets = nil
      local criterio = nil


      -- selezione airAsset in base al criterioSceltaAsset
      if criterioSceltaAsset == 'template' then

        criterio = WAREHOUSE.Descriptor.GROUPNAME

      elseif criterioSceltaAsset == 'classe' then

        criterio = WAREHOUSE.Descriptor.ATTRIBUTE

      end



     -- autorequest for spawn aircraft in parking area (watch combatibility parking zone - aircraft)
     warehouse:__AddRequest( delaySpawn, warehouse, criterio, airAsset, quantity, nil, nil, nil, nameMission )

     -- Do something with the spawned aircraft.
      function warehouse:OnAfterSelfRequest(From,Event,To,groupset,request)

        local groupset=groupset --Core.Set#SET_GROUP
        local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        activeBOMBINGWarehouse( groupset, warehouse, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombQuantity, bombRunDistance, bombRunDirection, speedBombRun )

      end  --end  function warehouse:OnAfterSelfRequest(From, Event, To, groupset, request)


      --- When the helo is out of fuel, it will return to the carrier and should be delivered.
      function warehouse:OnAfterDelivered(From,Event,To,request)

        local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

        -- codice per la funzione

      end -- end function warehouse:OnAfterDelivered(From,Event,To,request)

end -- end function  dispatchBOMBINGMission()





--- Attiva un gruppo di artiglieria mediante indicazioni fornite da un gruppo di ricognizione
-- @param nameRecceUnits = prefisso delle unita dedicate alla ricognizione
-- @param command_Center = il command_center
-- @param activateDetectionReport = true: attiva la visualizzazione dei detection report false la disattiva
--
function RecceDetection(RecceSetGroup, command_Center, activateDetectionReport, delayDetection, persistTimeOfMessage)

    -- determina il recceGroup selezionandolo da tutte le unita' definite Recce (Recce #001, ..)
    --RecceSetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameRecceUnits ):FilterStart()

    -- determina l'arty group selezionandolo da tutte le unita' definite Artillery (Artillery #001, ..)
    --ArtillerySetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameArtyUnits ):FilterStart()

    -- devi utilizzare i gruppi e non i setGorup che credo siano considerati gia' attivi su ME. Quindi
    -- Creare il grouppo da template, posizionarlo e tramite setGroud associarlo al set da utilizzare qui

    -- quindi OK LA WAREHOUSE CON OnAfterSelfRequest  genera un groupSet!!!!!!

    logging('enter', 'RecceDetection(RecceSetGroup, command_Center, activateDetectionReport, delayDetection, persistTimeOfMessage')

    logging('info', { 'RecceDetection(RecceSetGroup, command_Center, activateDetectionReport, delayDetection)' , 'RecceSetGroup name: ' .. RecceSetGroup:GetObjectNames() .. ' - activateDetectionReport: ' .. activateDetectionReport == TRUE .. ' - delayDetection: ' .. delayDetection .. ' - persistTimeOfMessage: ' .. persistTimeOfMessage })

    local RecceDetection = DETECTION_UNITS:New( RecceSetGroup )

    RecceDetection:SetRefreshTimeInterval( delayDetection )

    RecceDetection:Start()



    if activateDetectionReport then

        --- OnAfter Transition Handler for Event Detect.
        -- @param Functional.Detection#DETECTION_UNITS self
        -- @param #string From The From State string.
        -- @param #string Event The Event string.
        -- @param #string To The To State string.
        function RecceDetection:OnAfterDetect(From,Event,To)

          logging('enter', 'RecceDetection:OnAfterDetect(From,Event,To)')

          local DetectionReport = RecceDetection:DetectedReportDetailed()

          command_center:GetPositionable():MessageToAll( DetectionReport, persistTimeOfMessage, "" )

          logging('exit', 'RecceDetection:OnAfterDetect(From,Event,To)')

        end

    end

    logging('exit', 'RecceDetection(RecceSetGroup, command_Center, activateDetectionReport, delayDetection, persistTimeOfMessage')

    return RecceDetection

end




--- Attiva un gruppo di artiglieria mediante indicazioni fornite da un gruppo di ricognizione
-- @param coalition = nome della coalizione
-- @param nameRecceUnits = prefisso delle unita dedicate alla ricognizione
-- @param nameArtyUnits = prefisso delle unita di artiglieria
-- @param command_Center = il command_center
-- @param activateDetectionReport = true: attiva la visualizzazione dei detection report false la disattiva
--
function ArtyFiringFromRecceDetection(RecceDetection, ArtillerySetGroup)

  -- determina il recceGroup selezionandolo da tutte le unita' definite Recce (Recce #001, ..)
  --RecceSetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameRecceUnits ):FilterStart()

  -- determina l'arty group selezionandolo da tutte le unita' definite Artillery (Artillery #001, ..)
  --ArtillerySetGroup = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( nameArtyUnits ):FilterStart()

  -- devi utilizzare i gruppi e non i setGorup che credo siano considerati gia' attivi su ME. Quindi
  -- Creare il grouppo da template, posizionarlo e tramite setGroud associarlo al set da utilizzare qui

  -- quindi OK LA WAREHOUSE CON OnAfterSelfRequest  genera un groupSet!!!!!!

  logging('enter', 'ArtyFiringFromRecceDetection(RecceDetection, ArtillerySetGroup)')
  logging('info', { 'ArtyFiringFromRecceDetection(RecceDetection, ArtillerySetGroup)' , 'ArtillerySetGroup: ' .. ArtillerySetGroup  })

  local RecceDetection = RecceDetection

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

  logging('info', { 'ArtyFiringFromRecceDetection(RecceDetection, ArtillerySetGroup)' , 'ArtilleryAim: ' .. ArtilleryAim .. ' - radiusTarget: ' .. radiusTarget .. ' - num_ammo: ' .. num_ammo .. ' - activated_time: ' .. activated_time })
  --- OnAfter Transition Handler for Event Detect.
  -- @param Functional.Detection#DETECTION_UNITS self
  -- @param #string From The From State string.
  -- @param #string Event The Event string.
  -- @param #string To The To State string.
  -- @param Wrapper.Unit#UNIT DetectedUnits
  function RecceDetection:OnAfterDetected( From, Event, To, DetectedUnits )

    logging('enter', 'RecceDetection:OnAfterDetected())')
    logging('info', { 'RecceDetection:OnAfterDetected( From, Event, To, DetectedUnits )' , 'RecceSetGroup name: ' .. DetectedUnits:GetObjectNames() .. ' - activateDetectionReport: ' .. activateDetectionReport == TRUE .. ' - delayDetection: ' .. delayDetection .. ' - persistTimeOfMessage: ' .. persistTimeOfMessage })



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
      logging('exit', 'RecceDetection:OnAfterDetected())')
  end

  logging('exit', 'ArtyFireAndDetection(RecceSetGroup, ArtillerySetGroup, command_Center, activateDetectionReport)')
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


  logging('enter', 'ArtyPositionAndFireAtTarget(ArtilleryGroup, resupplyGroupTemplate, moveCoordinate, listTargetInfo, command_Center, activateDetectionReport)')

  logging('finest', { 'ArtyPositionAndFireAtTarget()' , '  ArtilleryGroup: ' .. ArtilleryGroup:GetName() .. '  -  groupResupplySet: ' .. groupResupplySet:GetObjectNames() .. '  -  moveCoordinate: ' .. tostring(moveCoordinate.z) .. ',' .. tostring(moveCoordinate.y) .. ',' .. tostring(moveCoordinate.z)} )

  ARTY.Debug = true

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

  local groupResupply -- solo per il logging
  -- prende l'ultimo gruppo: da migliorare inserendo una lista di resupplyGreoup presa dal set. Il set e' costituito dal numero di gruppi inseriti nel warehouse _addRequest (vedi 31160 set di 2 gruppi)
  for _,group in pairs(groupResupplySet:GetSet()) do

    local group = group --Wrapper.Group#GROUP

    artyGroup:SetRearmingGroup( group )
    groupResupply = group -- solo per il logging

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

  logging('finest', { 'ArtyPositionAndFireAtTarget()' , '  artyGroupName: ' .. artyGroup.DisplayName .. '  -   resupplyGroup' .. groupResupply:GetName()  .. '  -  shellType (total,  shells, rocket, missile): ' .. string.format('%i  %i  %i %i', artyGroup:GetAmmo( false ) ) } )

  -- ARTY:AssignTargetCoord(coord, prio, radius, nshells, maxengage, time, weapontype, name, unique)

  -- Low priorty (90) target, will be engage last. Target is engaged two times. At each engagement five shots are fired.
  -- artilleryGroup:AssignTargetCoord(GROUP:FindByName("Red Targets 3"):GetCoordinate(),  90, nil,  5, 2)
  -- Medium priorty (nil=50) target, will be engage second. Target is engaged two times. At each engagement ten shots are fired.
  --artilleryGroup:AssignTargetCoord(GROUP:FindByName("Red Targets 1"):GetCoordinate(), nil, nil, 10, 2)

  -- High priorty (10) target, will be engage first. Target is engaged three times. At each engagement twenty shots are fired.

  for _, targetInfo in pairs(listTargetInfo) do

    local targetDistance = moveCoordinate:Get2DDistance(targetInfo.targetCoordinate)
    logging('finest', { 'ArtyPositionAndFireAtTarget()' , '  targetInfo = ' .. tostring(targetInfo.targetCoordinate.x) .. ',' .. tostring(targetInfo.targetCoordinate.y)  .. ',' .. tostring(targetInfo.targetCoordinate.z) .. '  -  targetInfo.num_engagements = ' .. targetInfo.num_engagements .. '  -  targetDistance = ' .. tostring(targetDistance)} )
    logging('finest', { 'ArtyPositionAndFireAtTarget()' , '  targetPriority = ' .. tostring(targetInfo.priority) .. '  -  radiusTarget = ' .. tostring(targetInfo.radiusTarget)  .. '  -  num_shots = ' .. tostring(targetInfo.num_shots) .. '  -  targetInfo.weaponType = ' .. tostring(targetInfo.weaponType) } )
    artyGroup:AssignTargetCoord( targetInfo.targetCoordinate,  targetInfo.priority, targetInfo.radiusTarget, targetInfo.num_shots, targetInfo.num_engagements, nil, targetInfo.weaponType)

  end

  -- Start ARTY process.
  artyGroup:Start()

  function ARTY:OnAfterOpenFire(artyGroup, From, Event, To, target)

    logging('finest', { 'ArtyPositionAndFireAtTarget()' , ' TEST OnAfterOpenFire(Controllable, From, Event, To, target)'} )

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


  logging('exit', 'ArtyPositionAndFireAtTarget(ArtilleryGroup, resupplyGroupTemplate, moveCoordinate, listTargetInfo, command_Center, activateDetectionReport)')

end -- end function







--- Invia il group AFAC nella Afac Zone con assegnato il gruppo di attacco dedicato.
-- @param groupset = il set dei gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param param (optional) : lista contenente ulteriori parametri
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeAFACWarehouse( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)


  -- VEDI LE MISSIONI DES (DESIGNATE) IN PARTICOLARE LA DES 101

  logging('enter', 'activeAFACWarehouse( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)')


  local afacZone = afaczone[1] -- the zone object


  logging('finest', { 'activeAFACWarehouse( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)' , 'afacgroupsetName: ' .. facgroupset:GetObjectNames() .. 'attackgroupsetName: ' .. attackgroupset:GetObjectNames() .. '  -  mission: ' .. nameMission  .. '  -  zone: ' .. afaczone[2] } )



  for _, facgroup in pairs(facgroupset:GetSet()) do


    -- muovi verso la zona

    local facGroup = facgroup --Wrapper.Group#GROUP
    logging('finest', { 'activeAFACWarehouse( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)' , 'afacgroup: ' .. facGroup:GetName() } )

    -- GLI HELO 'FUMANO' (non e' la posizione della FARP prova a cambiare in heliport singolo: fuma uguale o prova 1 solo: fuma uguale)
    -- NON PERMANE NELLA ZONA VEDI ALTRI TASK IN CONTROLLABLE

    facGroup:StartUncontrolled()
    facGroup:TaskRouteToZone(afacZone, true, 56, nil)
    facGroup:PatrolZones( { afacZone }, 200, "Vee" )

    -- assegna per ogni gruppo AFAC tutti i gruppi ATTACK
    for _, attackgroup in pairs(attackgroupset:GetSet()) do

      local attackGroup = attackgroup --Wrapper.Group#GROU
      logging('finest', { 'activeAFACWarehouse( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)' , 'attackGroup: ' .. attackGroup:GetName() } )
      facGroup:TaskAttackGroup(attackGroup, nil, nil, nil)

    end --end for

  end --end for

  logging('exit', 'activeAFACWarehouse( facgroupset, attackgroupset, afaczone, commandCenter, nameMission)')

  return

end -- end function



--- Invia il group AFAC nella Afac Zone con assegnato il gruppo di attacco dedicato.
-- @param groupset = il set dei gruppo (asset)
-- @param battlezone = la WRAPPER: ZONE d'invio asset
-- @param param (optional) : lista contenente ulteriori parametri
-- @param offRoad (optional - default = false): se true
-- @param speedPerc (optional - 1 <= speedPerc  >= 0.1  default = 0.7): velocita
--
function activeCAS_AFACWarehouse( attackgroupset, patrolzone, nameMission )


  -- VEDI LE MISSIONI DES (DESIGNATE) IN PARTICOLARE LA DES 101

  logging('enter', 'activeCAS_AFACWarehouse( groupset, ' .. patrolzone[2] .. ', ' .. nameMission .. ' ) ')


  local patrolZone = patrolzone[1] -- the zone object

  logging('finest', { 'activeCAS_AFACWarehouse( groupset, ' .. patrolzone[2] .. ', ' .. nameMission .. ' ) ' , 'attackgroupsetName: ' .. attackgroupset:GetObjectNames() .. '  -  mission: ' .. nameMission  .. '  -  patrol zone: ' .. patrolzone[2] } )


  for _, attackgroup in pairs(attackgroupset:GetSet()) do


    -- muovi verso la zona

    local attackGroup = attackgroup --Wrapper.Group#GROUP
    logging('finest', { 'activeCAS_AFACWarehouse( groupset, ' .. patrolzone[2] .. ', ' .. nameMission .. ' ) ' , 'attack group: ' .. attackGroup:GetName() } )
    attackGroup:StartUncontrolled()
    attackGroup:TaskRouteToZone(patrolZone, true, 56, nil)
    attackGroup:PatrolZones( { patrolZone }, 200, "Vee" )
    -- GLI HELO 'FUMANO' (non e' la posizione della FARP prova a cambiare in heliport singolo o prova 1 solo)
    -- NON PERMANE NELLA ZONA VEDI ALTRI TASK IN CONTROLLABLE

  end --end for

  logging('exit', 'activeCAS_AFACWarehouse( groupset, ' .. patrolzone[2] .. ', ' .. nameMission .. ' ) ')

  return

end -- end function




--[[
--- Asset globali disponibili per i Red
local redAsset = {

  --(group, ngroups, forceattribute, forcecargobay, forceweight, loadradius, skill, liveries, assignment

  -- armor antitank
  -- group, num
  {"Biteta" ground_group_template_red.antitankA, 25},
  [2] = { ground_group_template_red.antitankB, 30},
  [3] = { ground_group_template_red.antitankC, 45},


  -- armor mechanized
  -- group, num
  [4] = { ground_group_template_red.mechanizedA, 25},
  [5] = { ground_group_template_red.mechanizedB, 30},
  [6] = { ground_group_template_red.mechanizedC, 45},


  -- armor mechanized
  -- group, num
  [7] = { ground_group_template_red.ArmorA, 25},
  [8] = { ground_group_template_red.ArmorB, 30},


  -- artillery
  -- group, num, weight
  [9] = { ground_group_template_red.ArtiAkatsia, 45},
  [10] = { ground_group_template_red.ArtiGwozdika, 45},
  [11] = { ground_group_template_red.ArtiHeavyMortar, 10, 2000}, -- "Mortar Alpha" 9 unita da 210 kg ciascuna
  [10] = { ground_group_template_red.ArtiKatiusha, 45},

  -- infantry


  -- transport
  -- group, num, forceattribute, forcecargobay
  [5] = { ground_group_template_red, 10, WAREHOUSE.Attribute.AIR_TRANSPORTHELO, 6000}, -- Huey
  [5] = { ground_group_template_red, 10, nil, 77000} -- "C-17A"





}


function loadAssetWH (warehouse, asset)

  if warehouse.notStarting then warehouse:Start() end

  for _, e = in pairs asset do

    warehouse.Didi:AddAsset(e.asset, 6)



end

]]--

-- END DEFINE FUNCTION




































































-- TEMPLATE



-- ASSET TEMPLATE


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
-- EWR_TU_22 = 'SQ red EWR TU_22',   -- EWR
-- EWR_Mig_25RTB = 'SQ red EWR Mig_25RTB'
-- AFAC_Yak_52 = 'SQ red FAC YAK-52',  -- AFAC
-- AFAC_L_39C = 'SQ red FAC L-39C',
-- AFAC_Mi_8MTV2 = 'SQ red FAC Mi-8MTV2',
-- AFAC_Mi_24 = 'SQ red FAC Mi-24'
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
          CAS_Su_17M4_Rocket = 'SQ red CAS Su_17M4 Rocket',
          CAS_MI_24V = 'SQ red CAS MI_24V',
          CAS_L_39C_Rocket = 'SQ red CAS L_39C Rocket',
          CAS_Mi_8MTV2 = 'SQ red CAS Mi-8MTV2', -- INSERIRE
          GA_SU_24M_HRocket = 'SQ red GA SU_24M HRocket', -- GA
          GA_SU_24M_Bomb = 'SQ red GA SU_24M Bomb',
          GA_SU_24M_HBomb = 'SQ red GA SU_24M HBomb',
          REC_Mig_25RTB = 'SQ red REC Mig_25RTB',  -- RECCE
          REC_SU_24MR = 'SQ red REC SU_24MR',
          BOM_TU_22_Bomb = 'SQ red BOM TU_22 Bomb', -- INTERDICTION
          BOM_TU_22_Nuke = 'SQ red BOM TU_22 Nuke',
          BOM_SU_24_Bomb = 'SQ red BOM SU_24 Bomb',
          BOM_SU_24_Structure = 'SQ red BOM SU_24 Structure',
          TRAN_AN_26 = 'SQ red TRA AN_26', -- TRANSPORT
          TRAN_YAK_40 = 'SQ red TRA YAK_40',
          TRAN_MI_24 = 'SQ red TRAN MI_24V',
          TRAN_MI_26 = 'SQ red TRAN MI_26',
          EWR_TU_22 = 'SQ red EWR TU_22',   -- EWR
          EWR_Mig_25RTB = 'SQ red EWR Mig_25RTB',
          AFAC_Yak_52 = 'SQ red FAC YAK-52',  -- AFAC
          AFAC_L_39C = 'SQ red FAC L-39C',
          AFAC_Mi_8MTV2 = 'SQ red FAC Mi-8MTV2',
          AFAC_Mi_24 = 'SQ red FAC Mi-24'
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
-- EWR_F_4 = 'SQ blue EWR F_4', -- EWR
-- EWR_B_1B = 'SQ blue EWR B_1B'
-- AFAC_Yak_52 = 'SQ blue FAC Yak-52', -- AFAC
-- AFAC_L_39ZA = 'SQ blue FAC L-39ZA',
-- AFAC_AV_88 = 'SQ blue FAC AV-88',
-- AFAC_Mi_24 = 'SQ blue FAC Mi-24',
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
          CAS_MI_24V = 'SQ blue CAS MI_24V',
          CAS_UH_1H = 'SQ blue CAS UH_1H',
          CAS_UH_60A = 'SQ blue CAS UH_60A',
          CAS_SA_342 = 'SQ blue CAS SA_342',
          CAS_L_39C_Rocket = 'SQ blue CAS L_39C Rocket',
          CAS_L_39ZA_HRocket = 'SQ blue CAS L_39ZA HRocket',
          CAS_F_4E_Rocket = 'SQ blue CAS F_4E Rocket',
          REC_L_39C = 'SQ blue REC L_39C',  -- RECCE
          REC_F_4 = 'SQ blue REC F_4',
          BOM_SU_24_Bomb = 'SQ blue BOM SU_24', -- INTERDICTION
          BOM_B_1B = 'SQ blue BOM B_1B Bomb',
          B_1B_HBomb = 'SQ blue BOM B_1B HBomb',
          BOM_B_52H = 'SQ blue BOM B_52H',
          BOM_F_4_E_Structure = 'SQ blue Structure BOM F4-E',
          TRAN_AN_26 = 'SQ blue TRAN AN_26', -- TRANSPORT
          TRAN_YAK_40 = 'SQ blue TRANSPORT YAK_40',
          TRAN_UH_1H = 'SQ blue TRAN UH_1H',
          TRAN_UH_60A = 'SQ blue TRAN UH_60A',
          TRAN_CH_47 = 'SQ blue TRAN CH_47',
          TRAN_MI_24 = 'SQ blue TRAN MI_24V',
          TRAN_C_130 = 'SQ blue TRAN C_130',
          EWR_F_4 = 'SQ blue EWR F_4', -- EWR
          EWR_B_1B = 'SQ blue EWR B_1B',
          AFAC_Yak_52 = 'SQ blue FAC Yak-52', -- AFAC
          AFAC_L_39ZA = 'SQ blue FAC L-39ZA',
          AFAC_AV_88 = 'SQ blue FAC AV-88',
          AFAC_Mi_24 = 'SQ blue FAC Mi-24',
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
    ArtilleryResupply = 'RUSSIAN ARTILLERY RESUPPLY TRUCK'

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
  ArtilleryResupply = 'GEORGIAN ARTILLERY RESUPPLY TRUCK'

}

-- END BLUE GROUND FORCE TEMPLATE






-- END TEMPLATE







-- VARIABLE

--- prefix_detector (AWACS AND RADAR)
--
-- red = {"DF CCCP AWACS", "DF CCCP EWR"
--
-- DF GEORGIA AWACS", "DF GEORGIA EWR"
--
--
local prefix_detector = {

  red = {"DF CCCP AWACS", "DF CCCP EWR" },

  blue = {"DF GEORGIA AWACS", "DF GEORGIA EWR", "DF USA EWR", "DF USA AWACS" }

}


-- trigger_zone_group = -- trigger zone gorup definite in ME: sono le zone dove agiscono i gruppi













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
local airbase = { Kutaisi = AIRBASE.Caucasus.Kutaisi, Sochi_Adler = AIRBASE.Caucasus.Sochi_Adler, Mozdok = AIRBASE.Caucasus.Mozdok, Senaki_Kolkhi = AIRBASE.Caucasus.Senaki_Kolkhi,
                  Maykop = AIRBASE.Caucasus.Maykop_Khanskaya, Novo = AIRBASE.Caucasus.Novorossiysk, Mineralnye = AIRBASE.Caucasus.Mineralnye_Vody, Nalchik = AIRBASE.Caucasus.Nalchik,
                  Beslan = AIRBASE.Caucasus.Beslan, Gudauta = AIRBASE.Caucasus.Gudauta, Gelendzhik = AIRBASE.Caucasus.Gelendzhik, Krasnodar_Pashkovsky = AIRBASE.Caucasus.Krasnodar_Pashkovsky,
                  Sukhumi_Babushara = AIRBASE.Caucasus.Sukhumi_Babushara, Kobuleti = AIRBASE.Caucasus.Kobuleti, Tbilisi_Lochini = AIRBASE.Caucasus.Tbilisi_Lochini, Soganlug = AIRBASE.Caucasus.Soganlug,
                  Vaziani = AIRBASE.Caucasus.Vaziani, Anapa_Vityazevo = AIRBASE.Caucasus.Anapa_Vityazevo, Krasnodar_Center = AIRBASE.Caucasus.Krasnodar_Center, Krymsk = AIRBASE.Caucasus.Krymsk } -- aeroporti attivi in ME



local sam = {SA_6 = 'SA_6', SA_10 = 'SA_10'}

local skill = { excellent = 'excellent', high = 'high', good = 'good', normal = 'normal', random = 'random' } -- skill influenzato anche dal morale


--
--  coalition table
--
--  red, blue, neutral
--
local coalition = {red = 'red', blue = 'blue', neutral = 'neutral'} -- coalizione attive in ME



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

--[[

ARTILLERY INFO


Arty group          = SAU Akatsia_WID-161_AID-152_RID-2
Arty alias          = SAU Akatsia_WID-161_AID-152_RID-2
Artillery attribute = true
Type                = SAU Akatsia
Display Name        = SPH 2S3 Akatsia
Number of units     = 9
Speed max           = 60 km/h
Speed default       = 42 km/h
Is mobile           = true
Is cargo            = false
Min range           = 0.3 km
Max range           = 17.0 km
Total ammo count    = 423
Number of shells    = 423
Number of rockets   = 0
Number of missiles  = 0
Number of nukes     = 0
Nuclear warhead     = 75 tons TNT
Nuclear demolition  = 1500 m
Nuclear fires       = 45 (active=false)
Number of illum.    = 0
Illuminaton Power   = 1.000 mcd
Illuminaton Minalt  = 500 m
Illuminaton Maxalt  = 1000 m
Number of smoke     = 0
Smoke color         = 1
Rearming safe dist. = 100 m
Rearming group      = M 818_WID-161_AID-221_RID-1
Rearming group speed= 37 km/h
Rearming group roads= false
Relocate after fire = false
Relocate min dist.  = 300 m
Relocate max dist.  = 800 m
Auto move in range  = false
Auto move dist. max = 50.0 km
Auto move on road   = false
Marker assignments  = false
Marker auth. key    = nil
Marker readonly     = false


]]







-- THE CONFLICT


-- la Zona del conflitto attivata
local conflictZone = 'Zone 1: South Ossetia'

-- stato attivazione warehouse
local activeWarehouse = true

-- stato attivazione conflitto aereo
local activeAirWar = true

-- stato attivazione conflitto terrestre
local activeGroundWar = true

-- stato attivazione conflitto navale
local activeSeaWar = true

logging('info', { 'main' , 'conflictZone code module activated = ' ..  conflictZone } )
logging('info', { 'main' , 'Activation code module for Warehouse, Air War, Ground War, SeaWar active = ' .. 'activeWarehouse and true' .. ' , ' .. 'activeAirWar' .. ' , ' .. 'activeGroundWar' .. ' , ' .. 'activeSeaWar' } )

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
   local targetBAIStaticObj = {

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

    Warehouse_AB = {

      blue = {

        Vaziani       =   { STATIC:FindByName( "Warehouse Vaziani Airbase" ), "Warehouse Vaziani Airbase",  targetPoints.airbase },  --Functional.Warehouse#WAREHOUSE
        Soganiug      =   { STATIC:FindByName( "Warehouse Soganiug Airbase" ), "Warehouse Soganiug Airbase",  targetPoints.airbase },   --Functional.Warehouse#WAREHOUSE
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
  local targetBAIZoneStructure = {

    Blue_Didi = {

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

    Blue_Biteta = {


      { ZONE:New('Target Zone Biteta Storage Area'), 'Target Zone Biteta Storage Area', targetPoints.storage_area }


    },

    Blue_Kvemo_Sba = {


      { ZONE:New('Target Zone Kvemo Sba Storage Area'), 'Target Zone Kvemo Sba Storage Area', targetPoints.storage_area }


    },



    Red_Kutaisi = {

      { ZONE:New('Target_Zone_Kutaisi_Bridge_1'), 'Target_Zone_Kutaisi_Bridge_1', targetPoints.bridge },
      { ZONE:New('Target_Zone_Kutaisi_Bridge_2'), 'Target_Zone_Kutaisi_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Kutaisi_Bridge_3'), 'Target_Zone_Kutaisi_Bridge_3', targetPoints.bridge }


    },

    Red_Zestafoni = {

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

    Red_Gori = {

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
      { ZONE:New('Target_Zone_Gori_Bridge_14'), 'Target_Zone_Gori_Bridge_14', targetPoints.bridge },
      { ZONE:New('Target Zone Gori Storage Area'), 'Target Zone Gori Storage Area', targetPoints.storage_area }

    },

    Red_Tbilisi = {

      { ZONE:New('Target_Zone_Tbilisi_Bridge_1'), 'Target_Zone_Tbilisi_Bridge_1', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_2'), 'Target_Zone_Tbilisi_Bridge_2', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_3'), 'Target_Zone_Tbilisi_Bridge_3', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_4'), 'Target_Zone_Tbilisi_Bridge_4', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_5'), 'Target_Zone_Tbilisi_Bridge_5', targetPoints.bridge },
      { ZONE:New('Target_Zone_Tbilisi_Bridge_6'), 'Target_Zone_Tbilisi_Bridge_6', targetPoints.bridge }
    }

  }

  local targetBAIZoneFarm = { }

  local targetBAIZoneMilitarySite = {

    blue = {

      { ZONE:New('Target_Zone_Kutaisi_EWR'), 'Target_Zone_Kutaisi_EWR', targetPoints.ewr_site }

    },

    red = {

      { ZONE:New('Target_Zone_Beslan_EWR_Site'), 'Target_Zone_Beslan_EWR_Site', targetPoints.ewr_site }

    }



  }






  -- le zone che costituiscono la linea del fronte dei red
  local redFrontZone = {

        TSKHINVALI = { ZONE:New("TSKHINVALI") , "TSKHINVALI", targetPoints.front_zone },
        SATIHARI = { ZONE:New("SATIHARI") , "SATIHARI", targetPoints.front_zone },
        DIDMUKHA = { ZONE:New("DIDMUKHA") , "DIDMUKHA", targetPoints.front_zone },
        DIDI_CUPTA = { ZONE:New("DIDI_CUPTA") , "DIDI_CUPTA", targetPoints.front_zone },
        CZ_ONI = { ZONE:New("CZ_ONI") , "CZ_ONI"}, targetPoints.front_zone ,
        CZ_PEREVI = { ZONE:New("CZ_PEREVI") , "CZ_PEREVI", targetPoints.front_zone }

  }

  -- le zone che costituiscono la linea del fronte dei blue
  local blueFrontZone = {

        TSVERI = { ZONE:New("TSVERI") , "TSVERI", targetPoints.front_zone },
        TKVIAVI = { ZONE:New("TKVIAVI") , "TKVIAVI", targetPoints.front_zone },
        GORI = { ZONE:New("GORI") , "GORI", targetPoints.front_zone },
        HEOBA = { ZONE:New("HEOBA") , "HEOBA", targetPoints.front_zone },
        CZ_AMBROLAURI = { ZONE:New("CZ_AMBROLAURI") , "CZ_AMBROLAURI", targetPoints.front_zone },
        CZ_CHIATURA = { ZONE:New("CZ_CHIATURA") , "CZ_CHIATURA", targetPoints.front_zone }

  }

  local redPatrolZone = {

      BAI_Zone_Mineralnye = { ZONE:New("BAI_Zone_Mineralnye") , "BAI_Zone_Mineralnye", targetPoints.front_zone },
      BAI_Zone_Nalchik = { ZONE:New("BAI_Zone_Nalchik") , "BAI_Zone_Nalchik", targetPoints.front_zone },
      BAI_Zone_Beslan = { ZONE:New("BAI_Zone_Beslan") , "BAI_Zone_Beslan", targetPoints.front_zone }

  }

  local bluePatrolZone = {

      BAI_Zone_Tbilisi = { ZONE:New("BAI_Zone_Tbilisi") , "BAI_Zone_Tbilisi", targetPoints.front_zone },
      BAI_Zone_Vaziani = { ZONE:New("BAI_Zone_Vaziani") , "BAI_Zone_Vaziani", targetPoints.front_zone },
      BAI_Zone_Soganiug = { ZONE:New("BAI_Zone_Soganiug") , "BAI_Zone_Soganiug", targetPoints.front_zone },
      Patrol_Zone_Kutaisi = { ZONE:New("BAI_Zone_Kutaisi") , "BAI_Zone_Kutaisi", targetPoints.front_zone }


  }

  -- i target per l'arty dei blue
  -- imposterei target dei blue e toglierei il prefisso BLUE verifica la posizione delle zone
  local blueArtilleryTargetZone = {

    RED_TARZ_DIDMUKHA_1 = { ZONE:New("RED_TARZ_DIDMUKHA_1") , "RED_TARZ_DIDMUKHA_1", targetPoints.front_zone },
    RED_TARZ_DIDMUKHA_2 = { ZONE:New("RED_TARZ_DIDMUKHA_2") , "RED_TARZ_DIDMUKHA_2", targetPoints.front_zone },
    RED_TARZ_DIDMUKHA_3 = { ZONE:New("RED_TARZ_DIDMUKHA_3") , "RED_TARZ_DIDMUKHA_3", targetPoints.front_zone },

    RED_TARZ_SATHIARI_1 = { ZONE:New("RED_TARZ_SATHIARI_1") , "RED_TARZ_SATHIARI_1", targetPoints.front_zone },
    RED_TARZ_SATHIARI_2 = { ZONE:New("RED_TARZ_SATHIARI_2") , "RED_TARZ_SATHIARI_2", targetPoints.front_zone },
    RED_TARZ_SATHIARI_3 = { ZONE:New("RED_TARZ_SATHIARI_3") , "RED_TARZ_SATHIARI_3", targetPoints.front_zone },

    RED_TARZ_TSKHINVALI_1 = { ZONE:New("RED_TARZ_TSKHINVALI_1") , "RED_TARZ_TSKHINVALI_1", targetPoints.front_zone },
    RED_TARZ_TSKHINVALI_2 = { ZONE:New("RED_TARZ_TSKHINVALI_2") , "RED_TARZ_TSKHINVALI_2", targetPoints.front_zone },
  }

  -- i target  per l'arty dei red
  -- imposterei target dei red e toglierei il prefisso BLUE verifica la posizione delle zone
  local redArtilleryTargetZone = {

    BLUE_TARZ_TKVIAVI_1 =   { ZONE:New("BLUE_TARZ_TKVIAVI_1") , "BLUE_TARZ_TKVIAVI_1", targetPoints.front_zone },
    BLUE_TARZ_TKVIAVI_2 =   { ZONE:New("BLUE_TARZ_TKVIAVI_2") , "BLUE_TARZ_TKVIAVI_2", targetPoints.front_zone },
    BLUE_TARZ_TKVIAVI_3 =   { ZONE:New("BLUE_TARZ_TKVIAVI_3") , "BLUE_TARZ_TKVIAVI_3", targetPoints.front_zone },
    BLUE_TARZ_TKVIAVI_4 =   { ZONE:New("BLUE_TARZ_TKVIAVI_4") , "BLUE_TARZ_TKVIAVI_4", targetPoints.front_zone },

    BLUE_TARZ_TSVERI_1 =   { ZONE:New("BLUE_TARZ_TSVERI_1") , "BLUE_TARZ_TSVERI_1", targetPoints.front_zone },
    BLUE_TARZ_TSVERI_2 =   { ZONE:New("BLUE_TARZ_TSVERI_2") , "BLUE_TARZ_TSVERI_2", targetPoints.front_zone },
    BLUE_TARZ_TSVERI_3 =   { ZONE:New("BLUE_TARZ_TSVERI_3") , "BLUE_TARZ_TSVERI_3", targetPoints.front_zone },
    BLUE_TARZ_TSVERI_4 =   { ZONE:New("BLUE_TARZ_TSVERI_4") , "BLUE_TARZ_TSVERI_4", targetPoints.front_zone },
    BLUE_TARZ_TSVERI_5 =   { ZONE:New("BLUE_TARZ_TSVERI_5") , "BLUE_TARZ_TSVERI_5", targetPoints.front_zone },
    BLUE_TARZ_TSVERI_6 =   { ZONE:New("BLUE_TARZ_TSVERI_6") , "BLUE_TARZ_TSVERI_6", targetPoints.front_zone },

    BLUE_TARZ_KHASHURI_1 =  { ZONE:New("BLUE_TARZ_KHASHURI_1") , "BLUE_TARZ_KHASHURI_1", targetPoints.front_zone },
    BLUE_TARZ_KHASHURI_2 =  { ZONE:New("BLUE_TARZ_KHASHURI_2") , "BLUE_TARZ_KHASHURI_2", targetPoints.front_zone }

  }

  local afacZone = {

    Didmukha_Tsveri =       { ZONE:New("AFAC_ZONE_Didmukha_Tsveri") , "AFAC_ZONE_Didmukha_Tsveri", targetPoints.front_zone },
    Tskhunvali_Tkviavi =    { ZONE:New("AFAC_ZONE_Tskhunvali_Tkviavi") , "AFAC_ZONE_Tskhunvali_Tkviavi", targetPoints.front_zone },
    Sathiari_Tkviavi =      { ZONE:New("AFAC_ZONE_Sathiari_Tkviavi") , "AFAC_ZONE_Sathiari_Tkviavi", targetPoints.front_zone },
    Didi_South =            { ZONE:New("AFAC_ZONE_Didi_South") , "AFAC_ZONE_Didi_South", targetPoints.front_zone },
    Khashuri_Est =          { ZONE:New("AFAC_ZONE_Khashuri_Est") , "AFAC_ZONE_Khashuri_Est", targetPoints.front_zone }

  }




  local redGroundGroup = {

    GROUP:FindByName('GW_1975 Russian Armor Defence@Nabakevi'),
    GROUP:FindByName('Russian Antitank Defence@Didmukha'),
    GROUP:FindByName('Russian Mechanized Defence@Didmukha'),
    GROUP:FindByName('Russian Antitank Defence@Tskhinvali'),
    GROUP:FindByName('RU Attack Route Didmukha-Tsveri A #002'),
    GROUP:FindByName('Russian Antitank Defence@Sathiari'),
    GROUP:FindByName('RED GROUND MECHA ATTACK A #026'),
    GROUP:FindByName('RED_HQ'),
    GROUP:FindByName('RU Attack Route Didmukha-Tsveri A #002')

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


  for j = 1, #targetBAIZoneStructure do

    local targetZone = targetBAIZoneStructure[j]

    for i = 1, #targetZone do

      Scoring:AddZoneScore( targetZone[i][1], targetZone[i][3] )

    end

  end


  for j = 1, #targetBAIStaticObj do

    local targetObject = targetBAIStaticObj[j]

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
        Soganiug    --->  Gori
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


    local warehouse={}


    -- AIR --
    local startReqTimeAir = 10 -- ritardo di avvio delle wh request dopo la schedulazione delle stesse
    local waitReqTimeAir = 600 -- tempo di attesa tra due request successive per asset aerei (10')
    local start_sched = 120 -- start_sched = ritardo in secondi nella attivazione dello scheduler. NOTA: può essere inteso come il tempo necessario per attivare una missione dipendente dall'efficienza della warehouse
    local interval_sched = 3600  -- interval_sched = intervallo in secondi della schedulazione (ciclo) della funzione. Nota: è necessario valutare l'effetto della OnAfterDelivered o OnAfterDead
    local rand_sched = 0.3  -- rand_sched = percentuale di variazione casuale per l'intervallo di schedulazione

    -- GROUND --
    local start_ground_sched = 10 -- start_sched = ritardo in secondi nella attivazione dello scheduler. NOTA: può essere inteso come il tempo necessario per attivare una missione dipendente dall'efficienza della warehouse
    local interval_ground_sched = 5400 -- interval_sched = intervallo in secondi della schedulazione (ciclo) della funzione. Nota: è necessario valutare l'effetto della OnAfterDelivered o OnAfterDead
    local rand_ground_sched = 0.2 -- rand_sched = percentuale di variazione casuale per l'intervallo di schedulazione
    local startReqTimeGround = 10 -- ritardo di avvio delle wh request dopo la schedulazione delle stesse
    local waitReqTimeGround = 300 -- tempo di attesa tra due request successive per asset terrestri (5')

































    --------------------------------         RED WAREHOUSE OPERATION   ------------------------------------------------------------------------------------------





















    -------------------------------------- red AGIDIR warehouse operations -------------------------------------------------------------------------------------------------------




   --- colonne di rifornimento (fuel, ammo)

   ----  DA FARE INOLTRE IMPLEMENTARE NELLE ALTRE WH LE RICHIESTE AD AGIDIR





    -- END red AGIDIR warehouse operations -------------------------------------------------------------------------------------------------------------------------
















    -------------------------------------- red DIDI warehouse operations -------------------------------------------------------------------------------------------------------
    local didi_wh_activation = true

    if didi_wh_activation then

        -- escono i cami ma sono fermi

        -- Didi warehouse e' una frontline warehouse: invia gli asset sul campo con task assegnato. Didi e' rifornita da Biteta Warehouse

        warehouse.Didi = WAREHOUSE:New( targetBAIStaticObj.Warehouse.red.Didi[ 1 ], targetBAIStaticObj.Warehouse.red.Didi[ 2 ])  --Functional.Warehouse#WAREHOUSE
        warehouse.Didi:SetSpawnZone(ZONE:New("Didi Warehouse Spawn Zone"))
        warehouse.Didi:Start()


        -- Didi: link and front farp-wharehouse.  Send resupply to Biteta. Receive resupply from Kvemo_sba, Beslan

        warehouse.Didi:AddAsset(                 "Infantry Platoon Alpha",                   6)
        warehouse.Didi:AddAsset(                ground_group_template_red.antitankA,         6,           WAREHOUSE.Attribute.GROUND_TANK)
        warehouse.Didi:AddAsset(                ground_group_template_red.antitankB,         6,           WAREHOUSE.Attribute.GROUND_TANK)
        warehouse.Didi:AddAsset(                ground_group_template_red.antitankC,         6,           WAREHOUSE.Attribute.GROUND_TANK)
        warehouse.Didi:AddAsset(                air_template_red.CAS_MI_24V,                12,           WAREHOUSE.Attribute.AIR_ATTACKHELO    ) -- attack
        warehouse.Didi:AddAsset(                air_template_red.TRAN_MI_24,                 4,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           1500  ) -- attack
        warehouse.Didi:AddAsset(                air_template_red.AFAC_Mi_24,                 4,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
        warehouse.Didi:AddAsset(                air_template_red.AFAC_Mi_8MTV2,              4,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC


        logging('info', { 'main' , 'addAsset Didi warehouse'} )

        logging('info', { 'main' , 'Define blueFrontZone = ' .. 'blueFrontZone' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa
        logging('info', { 'main' , 'addrequest Didi warehouse'} )

        -- fixed targets

        local Didmukha_Tsveri_ATTACK_HELO = 'ATTACK_ZONE_HELO_Didmukha_Tsveri'
        local Tskhunvali_Tkviavi_ATTACK_HELO = 'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi'

        -- random targets: mission parameters list for random choice
        local rndTrgDidi = {


          -- [1] = number of mission
          -- [pos mission][1] = name of mission
          -- [pos mission][2] = name of mission
          -- [pos mission][3] = asset group name
          -- [pos mission][4] = quantity
          -- [pos mission][5] = target zone
          -- [pos mission][6] = type of mission

          mechanized = { -- mechanized mission parameters

            {'tkviavi_attack_1', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankA, 1 , blueFrontZone.TKVIAVI, 'enemy_attack' }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'tkviavi_attack_2', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, 1 , blueFrontZone.TKVIAVI, 'enemy_attack' }, -- 3
            {'tseveri_attack_1', WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankC, 1 , blueFrontZone.TSVERI, 'enemy_attack' } -- 4
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          },

          helo = { -- helo mission parameters: att le CAS sdevono essere successive alle AFAC in quanto sono connesse tra loro

            {'AFAC_ZONE_Tskhunvali_Tkviavi', WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_Mi_24, 1, afacZone.Didmukha_Tsveri, 'AFAC_HELO'},
            {'AFAC_ZONE_Didmukha_Tsveri', WAREHOUSE.Descriptor.GROUPNAME, air_template_red.AFAC_Mi_8MTV2, 1, afacZone.Tskhunvali_Tkviavi, 'AFAC_HELO'},
            {'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi', WAREHOUSE.Descriptor.GROUPNAME,  air_template_red.CAS_MI_24V, math.random( 1 , 4 ), redFrontZone.TSKHINVALI, 'ATTACK_ZONE_HELO'},
            {'ATTACK_ZONE_HELO_Didmukha_Tsveri', WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_MI_24V, math.random( 1 , 4 ), redFrontZone.DIDMUKHA, 'ATTACK_ZONE_HELO'},
            {'RECON_ZONE_HELO_Didmukha_Tsveri', WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_MI_24V, math.random( 1 , 2 ), redFrontZone.DIDMUKHA, 'RECON_ZONE_HELO'}
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          }
        }



        local didi_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local didi_sched = SCHEDULER:New( nil,

          function()

            local num_mission = 3 -- the number of mission request ( _addRequest() )
            local depart_time = defineRequestPosition( num_mission )
            local pos_mech = defineRequestPosition( #rndTrgDidi.mechanized )
            local pos_helo = { 1, 2, 3, 4 } -- defineRequestPosition( #rndTrgDidi.helo ) -- le CAS sono connesse alle AFAC e devono essere lanciate prima delle AFAC (alle AFAC sono assegnati i gruppi CAS da dirigere)

            for i = 1, num_mission do

              logging('finest', { 'didi scheduler function' , 'depart_time = [ ' .. i .. ' ] = ' .. depart_time[i] } )

              if i < #rndTrgDidi.mechanized then

                logging('finest', { 'didi scheduler function' , 'pos_mech[ ' .. i .. '] =' .. pos_mech[i] } )
                -- logging('finest', { 'didi scheduler function' , 'rndTrgDidi.mechanized[ 1 ] = ' .. rndTrgDidi.mechanized[ 1 ] .. '  - rndTrgDidi.mechanized[ pos_mech[][ 2 ] = ' .. rndTrgDidi.mechanized[ pos_mech[ i ] + 1 ][ 2 ] .. 'rndTrgDidi.mechanized[ pos_mech[][ 3 ] = ' .. rndTrgDidi.mechanized[ pos_mech[ i ] + 1 ][ 3 ] .. '  - rndTrgDidi.mechanized[ pos_mech[][ 4 ] = ' .. rndTrgDidi.mechanized[ pos_mech[ i ] ][ 4 ][ 2 ]  .. '  - rndTrgDidi.mechanized[ pos_mech[][ 5 ] = ' .. rndTrgDidi.mechanized[ pos_mech[ i ] ][ 5 ]} )
                logging('finest', { 'didi scheduler function' , '#rndTrgDidi.mechanized = ' .. #rndTrgDidi.mechanized} )
                logging('finest', { 'didi scheduler function' , 'rndTrgDidi.mechanized[ pos_mech[][ 2 ] = ' .. rndTrgDidi.mechanized[ pos_mech[ i ] ][ 2 ]} )
                logging('finest', { 'didi scheduler function' , 'rndTrgDidi.mechanized[ pos_mech[][ 3 ] = ' .. rndTrgDidi.mechanized[ pos_mech[ i ] ][ 3 ]} )
                logging('finest', { 'didi scheduler function' , 'rndTrgDidi.mechanized[ pos_mech[][ 4 ] = ' .. rndTrgDidi.mechanized[ pos_mech[ i ] ][ 4 ]} )
                logging('finest', { 'didi scheduler function' , 'rndTrgDidi.mechanized[ pos_mech[][ 5 ] = ' .. rndTrgDidi.mechanized[ pos_mech[ i ] ][ 5 ][2]} )
              end

            end

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[1] * waitReqTimeGround, warehouse.Didi,  rndTrgDidi.helo[ pos_helo[ 3 ] ][ 2 ], rndTrgDidi.helo[ pos_helo[ 1 ] ][ 3 ], rndTrgDidi.helo[ pos_helo[ 1 ] ][ 4 ], nil, nil, nil, rndTrgDidi.helo[ pos_helo[ 1 ] ][ 1 ])
            warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[2] * waitReqTimeGround, warehouse.Didi,  rndTrgDidi.helo[ pos_helo[ 4 ] ][ 2 ], rndTrgDidi.helo[ pos_helo[ 2 ] ][ 3 ], rndTrgDidi.helo[ pos_helo[ 2 ] ][ 4 ], nil, nil, nil, rndTrgDidi.helo[ pos_helo[ 2 ] ][ 1 ])
            -- NON APPAIONO GLI AFAC HELO: sono apparsi cambiando AFAC in NOTHING nel template e cambiando in averege lo skill !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            warehouse.Didi:__AddRequest( startReqTimeGround + ( depart_time[1] + 1 ) * waitReqTimeGround, warehouse.Didi,  rndTrgDidi.helo[ pos_helo[ 1 ] ][ 2 ], rndTrgDidi.helo[ pos_helo[ 3 ] ][ 3 ], rndTrgDidi.helo[ pos_helo[ 3 ] ][ 4 ], nil, nil, nil, rndTrgDidi.helo[ pos_helo[ 3 ] ][ 1 ])
            warehouse.Didi:__AddRequest( startReqTimeGround + ( depart_time[2] + 1 ) * waitReqTimeGround, warehouse.Didi,  rndTrgDidi.helo[ pos_helo[ 2 ] ][ 2 ], rndTrgDidi.helo[ pos_helo[ 4 ] ][ 3 ], rndTrgDidi.helo[ pos_helo[ 4 ] ][ 4 ], nil, nil, nil, rndTrgDidi.helo[ pos_helo[ 4 ] ][ 1 ])
            -- riutilizzo gli stessi indici in quanto essendo ground veichle appaiono nella warehouse spawn zone diversa dal FARP degli helo
            warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[1]  * waitReqTimeGround, warehouse.Didi,  rndTrgDidi.mechanized[ pos_mech[ 1 ] ][ 2 ], rndTrgDidi.mechanized[ pos_mech[ 1 ] ][ 3 ], rndTrgDidi.mechanized[ pos_mech[ 1 ] ][ 4 ], nil, nil, nil, rndTrgDidi.mechanized[ pos_mech[ 1 ] ][ 1 ] )
            warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[2] * waitReqTimeGround, warehouse.Didi,  rndTrgDidi.mechanized[ pos_mech[ 2 ] ][ 2 ], rndTrgDidi.mechanized[ pos_mech[ 2 ] ][ 3 ], rndTrgDidi.mechanized[ pos_mech[ 2 ] ][ 4 ], nil, nil, nil, rndTrgDidi.mechanized[ pos_mech[ 2 ] ][ 1 ] )
            warehouse.Didi:__AddRequest( startReqTimeGround + depart_time[3] * waitReqTimeGround, warehouse.Didi,  rndTrgDidi.mechanized[ pos_mech[ 3 ] ][ 2 ], rndTrgDidi.mechanized[ pos_mech[ 3 ] ][ 3 ], rndTrgDidi.mechanized[ pos_mech[ 3 ] ][ 4 ], nil, nil, nil, rndTrgDidi.mechanized[ pos_mech[ 3 ] ][ 1 ] )

            logging('finest', { 'didi scheduler function' , 'addRequest Didi warehouse'} )

          end, {}, start_ground_sched * didi_efficiency_influence, interval_ground_sched, rand_ground_sched

        )


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

          logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

          -- activeGO_TO_BATTLEWarehouse( groupset, blueFrontZone.CZ_AMBROLAURI, 'enemy_attack', nil, nil, nil)  end
          if assignment == rndTrgDidi.mechanized[ 1 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgDidi.mechanized[ 1 ][ 5 ], rndTrgDidi.mechanized[ 1 ][ 6 ], nil, nil, nil )  end
          if assignment == rndTrgDidi.mechanized[ 2 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgDidi.mechanized[ 2 ][ 5 ], rndTrgDidi.mechanized[ 2 ][ 6 ], nil, nil, nil  )  end
          if assignment == rndTrgDidi.mechanized[ 3 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgDidi.mechanized[ 3 ][ 5 ], rndTrgDidi.mechanized[ 3 ][ 6 ], nil, nil, nil  )  end
          --if assignment == tkviavi_attack_2 then activeGO_TO_BATTLEWarehouse( groupset, blueFrontZone.TKVIAVI, 'enemy_attack' )  end

          if assignment == rndTrgDidi.helo[ 1 ][ 1 ] then

            logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

            if lenAttackGroupForAFACSet > 0 then

              local attackgroup = attackGroupForAFACSet[ lenAttackGroupForAFACSet ]
              lenAttackGroupForAFACSet = lenAttackGroupForAFACSet - 1
              logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group assegnati a AFAC asset:  ' .. attackgroup:GetObjectNames()} )
              activeAFACWarehouse( groupset, attackgroup, rndTrgDidi.helo[ 1 ][ 5 ], red_command_center, rndTrgDidi.helo[ 1 ][ 6 ] )

            else

              logging('warning', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group non disponibili per AFAC asset:  ' .. groupset:GetObjectNames()} )

            end

          end

          if assignment == rndTrgDidi.helo[ 2 ][ 1 ] then

            logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

            if lenAttackGroupForAFACSet > 0 then -- verifica se c'e' almeno un gruppo CAS dedicato disponibile nella lista di CAS dedicate

              local attackgroup = attackGroupForAFACSet[ lenAttackGroupForAFACSet ] -- assegna il gruppo CAS disponibile prelevandolo dalla lista
              lenAttackGroupForAFACSet = lenAttackGroupForAFACSet - 1 -- diminuisce di 1 il numero di gruppi CAS dedicati disponibili
              logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group assegnati a AFAC asset:  ' .. attackgroup:GetObjectNames()} )
              activeAFACWarehouse( groupset, attackgroup, rndTrgDidi.helo[ 2 ][ 5 ], red_command_center, rndTrgDidi.helo[ 2 ][ 6 ] )

            else

              logging('warning', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  -  attack Group non disponibili per AFAC asset:  ' .. groupset:GetObjectNames()} )

            end

          end

          if assignment == rndTrgDidi.helo[ 3 ][ 1 ] then

            logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Didmukha_Tsveri_ATTACK_HELO assigned = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )
            lenAttackGroupForAFACSet = lenAttackGroupForAFACSet + 1
            attackGroupForAFACSet[ lenAttackGroupForAFACSet ] = groupset
            logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  - inserito un nuovo attack Group per CAS for AFAC asset' .. '  -  groupsetName: ' .. groupset:GetObjectNames() .. ' - lenAttackGroupForCASforAFACSet: ' .. lenAttackGroupForAFACSet} )
            activeCAS_AFACWarehouse( groupset, rndTrgDidi.helo[ 4 ][ 5 ], rndTrgDidi.helo[ 4 ][ 6 ] )

          end

          if assignment == rndTrgDidi.helo[ 4 ][ 1 ] then

            logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Tskhunvali_Tkviavi_ATTACK_HELO assigned = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )
            lenAttackGroupForAFACSet = lenAttackGroupForAFACSet + 1
            attackGroupForAFACSet[ lenAttackGroupForAFACSet ] = groupset
            logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  - inserito un nuovo attack Group per CAS for AFAC asset' .. '  -  groupsetName: ' .. groupset:GetObjectNames() .. ' - lenAttackGroupForCASforAFACSet: ' .. lenAttackGroupForAFACSet} )
            activeCAS_AFACWarehouse( groupset, rndTrgDidi.helo[ 4 ][ 5 ], rndTrgDidi.helo[ 4 ][ 6 ] )

          end

          if assignment == rndTrgDidi.helo[ 5 ][ 1 ] then

            logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'RECON_ZONE_HELO_Didmukha_Tsveri assigned = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

            activeGO_TO_ZONE_AIR_Warehouse( groupset,  rndTrgDidi.helo[ 5 ][ 5 ], speedPerc )
            RecceDetection( groupset, red_command_center, true, 10, 10 )
            logging('finest', { 'warehouse.Didi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - lenAttackGroupForAFACSet = ' .. lenAttackGroupForAFACSet .. '  - inserito un nuovo attack Group per CAS for AFAC asset' .. '  -  groupsetName: ' .. groupset:GetObjectNames() .. ' - lenAttackGroupForCASforAFACSet: ' .. lenAttackGroupForAFACSet} )


          end

        end -- end function warehouse.Didi:OnAfterSelfRequest( From,Event,To,groupset,request )


       -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
       -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati

        function warehouse.Didi:OnAfterAssetDead( From, Event, To, asset, request )

          logging('enter', 'warehouse.Didi:OnAfterAssetDead( From, Event, To, asset, request )' )
          local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment.
          local assignment = warehouse.Didi:GetAssignment( request )

          logging('info', { 'warehouse.Didi:OnAfterAssetDead(From, Event, To, asset, request)' , 'assignment = ' .. assignment .. '  - assetGroupName = ' .. asset.templatename } )

          logging('info', { 'warehouse.Didi:OnAfterAssetDead(From, Event, To, asset, request)' , 'Request @ Kvemo Sba: asset attribute = ' .. asset.attribute } )

          -- Request resupply for dead asset from Kvemo Sba warehouse.
          warehouse.Kvemo_Sba:AddRequest( warehouse.Didi, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, "Resupply" )

          logging('info', { 'warehouse.Didi:OnAfterAssetDead(From, Event, To, asset, request)' , 'Self Request: asset assignment = ' .. assignment } )
          -- Send asset to Battle zone either now or when they arrive.
          warehouse.Didi:AddRequest( warehouse.Didi, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment )

          logging('exit', 'warehouse.Didi:OnAfterAssetDead( From, Event, To, asset, request )' )

        end -- end function warehouse.Didi:OnAfterAssetDead( From, Event, To, asset, request )


        -- crea una funzione da schedulare ogni 60 minuti (?) per controllare lo stato degli asset nelle warehouse di area e nel caso che questi siano inferiori ad un certo quantitativo
        -- esegui una AddRequest alla warehouse di link. Ricevuta la richiesta la warehouse di link richiede a sua volta l'invio degli asset alla warehouse di riferimento (link, Area o Master)
    end

    -- END red DIDI warehouse operations -------------------------------------------------------------------------------------------------------------------------
































    ---------------------------------------------- red BITETA warehouse operations ------------------------------------------------------------------------------------------------------------
    local biteta_wh_activation = true

    if biteta_wh_activation then

        -- Biteta warehouse e' una supply line warehouse: funziona da collegamento per il trasferimento degli asset tra i diversi nodi della supply line

        warehouse.Biteta = WAREHOUSE:New( targetBAIStaticObj.Warehouse.red.Biteta[ 1 ], targetBAIStaticObj.Warehouse.red.Biteta[ 2 ])  --Functional.Warehouse#WAREHOUSE

        warehouse.Biteta:SetSpawnZone(ZONE:New("Warehouse Biteta Spawn Zone"))

        warehouse.Biteta:Start()

        -- Biteta: front farp-wharehouse.  Receive resupply from Didi

        warehouse.Biteta:AddAsset(                "Infantry Platoon Alpha", 50 )
        warehouse.Biteta:AddAsset(              ground_group_template_red.antitankC,        12,           WAREHOUSE.Attribute.GROUND_TANK)
        warehouse.Biteta:AddAsset(              ground_group_template_red.antitankB,        10,           WAREHOUSE.Attribute.GROUND_TANK)
        warehouse.Biteta:AddAsset(              air_template_red.CAS_MI_24V,                12,           WAREHOUSE.Attribute.AIR_ATTACKHELO    ) -- attack
        warehouse.Biteta:AddAsset(              air_template_red.TRAN_MI_24,                 4,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           1500   ) -- attack
        warehouse.Biteta:AddAsset(              air_template_red.AFAC_Mi_24,                 4,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
        warehouse.Biteta:AddAsset(              air_template_red.AFAC_Mi_8MTV2,              4,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC

        logging('info', { 'main' , 'addAsset Biteta warehouse embe' } )


        local ambrolauri_attack_1 = 'AMBROLAURI_attack_1'
        local chiatura_attack_1 = 'CHIATURA_attack_1'

        -- random targets
        local rndTrgBiteta = {


          -- [1] = number of mission
          -- [pos mission][1] = name of mission
          -- [pos mission][2] = name of mission
          -- [pos mission][3] = asset group name
          -- [pos mission][4] = quantity
          -- [pos mission][5] = target zone
          -- [pos mission][6] = type of mission

          mechanized = {

            {'AMBROLAURI_attack_1',  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_red.antitankB, 1 , blueFrontZone.CZ_AMBROLAURI, 'mech_attack'  }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'CHIATURA_attack_1',    WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, 2 , blueFrontZone.CZ_CHIATURA, 'mech_attack'  }, -- 3
            {'PEREVI_APC',           WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, 2 , blueFrontZone.CZ_AMBROLAURI,   'mech_attack'  }, -- 4

            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          },

          helo = {}

        }


        --local depart_time = defineRequestPosition(3)
        local biteta_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local biteta_sched = SCHEDULER:New( nil,

          function()

            local num_mission = 3 -- the number of mission request ( _addRequest() )
            local depart_time = defineRequestPosition( num_mission )
            local pos_mech = defineRequestPosition( #rndTrgBiteta.mechanized )
            -- local pos_helo = defineRequestPosition( #rndTrgBiteta.helo )

            for i = 1, num_mission do

              logging('finest', { 'didi scheduler function' , 'depart_time = [ ' .. i .. ' ] = ' .. depart_time[i] } )

              if i < #rndTrgBiteta.mechanized then
                logging('finest', { 'didi scheduler function' , 'pos_mech[ ' .. i .. '] =' .. pos_mech[i] } )
                logging('finest', { 'didi scheduler function' , '#rndTrgBiteta.mechanized = ' .. #rndTrgBiteta.mechanized .. '  - rndTrgBiteta.mechanized[ pos_mech[][ 2 ] = ' .. rndTrgBiteta.mechanized[ pos_mech[ i ] ][ 2 ] .. 'rndTrgBiteta.mechanized[ pos_mech[][ 3 ] = ' .. rndTrgBiteta.mechanized[ pos_mech[ i ] ][ 3 ] .. '  - rndTrgBiteta.mechanized[ pos_mech[][ 4 ] = ' .. rndTrgBiteta.mechanized[ pos_mech[ i ] ][ 4 ]  .. '  - rndTrgBiteta.mechanized[ pos_mech[][ 5 ] = ' .. rndTrgBiteta.mechanized[ pos_mech[ i ] ][ 5 ][2]} )
              end

            end

            warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[1] * waitReqTimeGround, warehouse.Biteta,  rndTrgBiteta.mechanized[ pos_mech[ 1 ] ][ 2 ], rndTrgBiteta.mechanized[ pos_mech[ 1 ] ][ 3 ], rndTrgBiteta.mechanized[ pos_mech[ 1 ] ][ 4 ], nil, nil, nil, rndTrgBiteta.mechanized[ pos_mech[ 1 ] ][ 1 ] )
            warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[2] * waitReqTimeGround, warehouse.Biteta,  rndTrgBiteta.mechanized[ pos_mech[ 2 ] ][ 2 ], rndTrgBiteta.mechanized[ pos_mech[ 2 ] ][ 3 ], rndTrgBiteta.mechanized[ pos_mech[ 2 ] ][ 4 ], nil, nil, nil, rndTrgBiteta.mechanized[ pos_mech[ 2 ] ][ 1 ] )
            warehouse.Biteta:__AddRequest( startReqTimeGround + depart_time[3] * waitReqTimeGround, warehouse.Biteta,  rndTrgBiteta.mechanized[ pos_mech[ 3 ] ][ 2 ], rndTrgBiteta.mechanized[ pos_mech[ 3 ] ][ 3 ], rndTrgBiteta.mechanized[ pos_mech[ 3 ] ][ 4 ], nil, nil, nil, rndTrgBiteta.mechanized[ pos_mech[ 3 ] ][ 1 ] )

          end, {}, start_ground_sched * biteta_efficiency_influence, interval_ground_sched, rand_ground_sched

        )

        logging('info', { 'main' , 'addRequest Biteta warehouse'} )

        -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
        -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati

        function warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)

            logging('enter', 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' )

            local groupset = groupset --Core.Set#SET_GROUP
            local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

            -- Get assignment of this request.
            local assignment=warehouse.Biteta:GetAssignment(request)

            logging('info', { 'warehouse.Biteta:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

            if assignment == rndTrgBiteta.mechanized[ 1 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgBiteta.mechanized[ 1 ][ 5 ], rndTrgBiteta.mechanized[ 1 ][ 6 ], nil, nil, nil)  end
            if assignment == rndTrgBiteta.mechanized[ 2 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgBiteta.mechanized[ 2 ][ 5 ], rndTrgBiteta.mechanized[ 2 ][ 6 ], nil, nil, nil)  end

        end -- end function

        -- An asset has died ==> request resupply for it.
        function warehouse.Biteta:OnAfterAssetDead(From, Event, To, asset, request)

              local asset=asset       --Functional.Warehouse#WAREHOUSE.Assetitem
              local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

                -- Get assignment.
              local assignment=warehouse.Biteta:GetAssignment(request)

              logging('info', { 'warehouse.Biteta:OnAfterAssetDead(From, Event, To, asset, request)' , 'assignment = ' .. assignment .. '  - assetGroupName = ' .. asset.templatename } )

                -- Request resupply for dead asset from Batumi.
                warehouse.Kvemo_Sba:AddRequest(warehouse.Biteta, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, nil, nil, nil, nil, "Resupply")

                -- Send asset to Battle zone either now or when they arrive.
                warehouse.Biteta:AddRequest(warehouse.Biteta, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment)

        end -- end function

    end

    -- END red BITETA warehouse operations --------------------------------------------------------------------------------------------------------------------------

































    ------------------------------------------------- red Warehouse KVEMO_SBA operations -------------------------------------------------------------------------------------------------------------------------

    local Kvemo_Sba_wh_activation = false

    if Kvemo_Sba_wh_activation then

        warehouse.Kvemo_Sba     =   WAREHOUSE:New( targetBAIStaticObj.Warehouse.red.Kvemo_Sba[ 1 ], targetBAIStaticObj.Warehouse.red.Kvemo_Sba[ 2 ])  --Functional.Warehouse#WAREHOUSE
        warehouse.Kvemo_Sba:Start()

        -- Kvemo_Sba: link farp-wharehouse.  Send resupply to Didi. Receive resupply from Beslan, Mineralnye

        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankA,       50,                WAREHOUSE.Attribute.GROUND_TANK  )
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankB,       50,                WAREHOUSE.Attribute.GROUND_TANK  )
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankC,       50,                WAREHOUSE.Attribute.GROUND_TANK  )
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.CAS_MI_24V,               12,                WAREHOUSE.Attribute.AIR_ATTACKHELO    ) -- attack
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.TRAN_MI_24,               12,                WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           1500   ) -- transport
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.TRAN_MI_26,               10,                WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000  ) -- transport
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.AFAC_Mi_24,                4,                WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
        warehouse.Kvemo_Sba:AddAsset(               air_template_red.AFAC_Mi_8MTV2,             4,                WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArmorA,          10,                WAREHOUSE.Attribute.GROUND_TANK    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArmorB,          10,                WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiAkatsia,     10,                WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiGwozdika,    10,                WAREHOUSE.Attribute.GROUND_ARTILLERY    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiKatiusha,    10,                WAREHOUSE.Attribute.GROUND_ARTILLERY    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.ArtiHeavyMortar, 10,                WAREHOUSE.Attribute.GROUND_ARTILLERY    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedA,     10,                WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedB,     10,                WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.mechanizedC,     10,                WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.antitankA,       10,                WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TransportA,       5,                WAREHOUSE.Attribute.GROUND_TRUCK   ) -- transport
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TransportB,       5,                WAREHOUSE.Attribute.GROUND_TRUCK   ) -- transport
        warehouse.Kvemo_Sba:AddAsset(               ground_group_template_red.TroopTransport,   5,                WAREHOUSE.Attribute.GROUND_TRUCK   ) -- transport troop


        logging('info', { 'main' , 'addAsset Kvemo_Sba warehouse'} )

    end
    ------------------------------------------------- END red Warehouse KVEMO_SBA operations -------------------------------------------------------------------------------------------------------------------------

























    ------------------------------------------------- red Warehouse ALAGIR operations -------------------------------------------------------------------------------------------------------------------------

    local Alagir_wh_activation = false

    if Alagir_wh_activation then

        warehouse.Alagir        =   WAREHOUSE:New( targetBAIStaticObj.Warehouse.red.Alagir[ 1 ], targetBAIStaticObj.Warehouse.red.Alagir[ 2 ])  --Functional.Warehouse#WAREHOUSE
        warehouse.Alagir:Start()

    end
    ------------------------------------------------- END Warehouse ALAGIR operations -------------------------------------------------------------------------------------------------------------------------





























    ---------------------------------------------------------------- red Mineralnye warehouse operations -------------------------------------------------------------------------------------------------------------------------
    local mineralnye_wh_activation = true

    if mineralnye_wh_activation then


        warehouse.Mineralnye    =   WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.red.Mineralnye[ 1 ], targetBAIStaticObj.Warehouse_AB.red.Mineralnye[ 2 ])  --Functional.Warehouse#WAREHOUSE
        warehouse.Mineralnye:Start()


        -- Mineralnye e' una delle principale warehouse russe nell'area. Qui sono immagazzinate la maggior parte degli asset da impiegare nella zona dei combattimenti
        -- Send resupply to Kvemo_Sba

        warehouse.Mineralnye:AddAsset(            air_template_red.CAP_Mig_21Bis,             10,         WAREHOUSE.Attribute.AIR_FIGHTER ) -- Fighter
        warehouse.Mineralnye:AddAsset(            air_template_red.GCI_Mig_21Bis,             15,         WAREHOUSE.Attribute.AIR_FIGHTER )
        warehouse.Mineralnye:AddAsset(            air_template_red.BOM_SU_24_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber - Cas
        warehouse.Mineralnye:AddAsset(            air_template_red.BOM_TU_22_Bomb,            5,          WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mineralnye:AddAsset(            air_template_red.BOM_TU_22_Bomb,            5,          WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mineralnye:AddAsset(            air_template_red.CAS_Su_17M4_Rocket,        10,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mineralnye:AddAsset(            air_template_red.CAS_L_39C_Rocket,          10,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mineralnye:AddAsset(            air_template_red.CAS_Mig_27K_Bomb,          10,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mineralnye:AddAsset(            air_template_red.GA_SU_24M_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mineralnye:AddAsset(            air_template_red.EWR_TU_22,                 3,          WAREHOUSE.Attribute.AIR_AWACS )
        warehouse.Mineralnye:AddAsset(            air_template_red.CAS_MI_24V,                10,         WAREHOUSE.Attribute.AIR_ATTACKHELO      ) -- attack
        warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_MI_24,                24,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500  ) -- transport
        warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_AN_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- transport
        warehouse.Mineralnye:AddAsset(            air_template_red.TRAN_MI_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000  ) -- transport
        warehouse.Mineralnye:AddAsset(            ground_group_template_red.Truck,            3 )

        logging('info', { 'main' , 'addAsset Mineralnye warehouse'} )

        logging('info', { 'main' , 'addrequest Mineralnye warehouse'} )

        local depart_time = defineRequestPosition(5)

        local mineralnye_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local mineralnye_sched = SCHEDULER:New( nil,

          function()
            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[1] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Bomb, 4, nil, nil, nil, "BAI A")
            warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[2] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.BOM_SU_24_Bomb, 4, nil, nil, nil, "BAI B")
            warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[3] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, 2, nil, nil, nil, "PATROL TKVIAVI")
            warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[4] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 2, nil, nil, nil, "Bomb Tbilisi")
            warehouse.Mineralnye:__AddRequest( startReqTimeAir + depart_time[5] * waitReqTimeAir, warehouse.Mineralnye, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 2, nil, nil, nil, "Bomb Tkviavi")
            logging('info', { 'main' , 'Mineralnye scheduler - start time:' .. start_sched *  mineralnye_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

          end, {}, start_sched * mineralnye_efficiency_influence, interval_sched, rand_sched

        ) -- end mineralnye_sched = SCHEDULER:New( nil, ..)


          -- Do something with the spawned aircraft.
        function warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)

          --local groupset=groupset --Core.Set#SET_GROUP
          --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI A" then

            local speed, altitude = defineSpeedAndAltitude(500, 700, 3000, 5000)

            local param = {

                  [1] = { 'Interdiction from Mineralnye to Kutaisi Bridges', groupset, 'bombing', redFrontZone.DIDI_CUPTA[2], targetBAIZoneStructure.Red_Kutaisi[ math.random( 1, #targetBAIZoneStructure.Red_Kutaisi ) ][ 2 ], speed, altitude, AI.Task.WeaponExpend.FOUR, 2, 300, nil, 3, 500, 3000, 500, 600, 300, -3600, 1  },
                  [2] = { 'Interdiction from Mineralnye to Zestafoni Bridges', groupset, 'bombing', redFrontZone.DIDI_CUPTA[2], targetBAIZoneStructure.Red_Zestafoni[ math.random( 1, #targetBAIZoneStructure.Red_Zestafoni ) ][ 2 ], speed, altitude, AI.Task.WeaponExpend.HALF, 1, 300, nil, 3, 500, 3000, 500, 600, 300, -3600, 1 },
                  [3] = { 'Interdiction from Mineralnye to Gori Bridges', groupset, 'bombing', redFrontZone.DIDI_CUPTA[2],  targetBAIZoneStructure.Red_Gori[ math.random( 1, #targetBAIZoneStructure.Red_Gori ) ][ 2 ], speed, altitude, AI.Task.WeaponExpend.ALL, 1, 300, nil, 3, 500, 3000, 500, 600, 300, -3600, 1 }


              }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mineralnye scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

            activeBAIWarehouseBisA( param[ pos ] )


          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI B" then

            local speed, altitude = defineSpeedAndAltitude(500, 700, 3000, 5000)

            local param = {

                  [1] = { 'Interdiction from Mineralnye to Kutaisi Bridges', groupset, 'bombing', redFrontZone.DIDI_CUPTA[2], targetBAIZoneStructure.Red_Kutaisi[ math.random( 1, #targetBAIZoneStructure.Red_Kutaisi ) ][ 2 ], speed, altitude, AI.Task.WeaponExpend.FOUR, 2, 300, nil, 3, 500, 3000, 500, 600, 300, -3600, 1  },
                  [2] = { 'Interdiction from Mineralnye to Zestafoni Bridges', groupset, 'bombing', redFrontZone.DIDI_CUPTA[2], targetBAIZoneStructure.Red_Zestafoni[ math.random( 1, #targetBAIZoneStructure.Red_Zestafoni ) ][ 2 ], speed, altitude, AI.Task.WeaponExpend.HALF, 1, 300, nil, 3, 500, 3000, 500, 600, 300, -3600, 1 },
                  [3] = { 'Interdiction from Mineralnye to Gori Bridges', groupset, 'bombing', redFrontZone.DIDI_CUPTA[2],  targetBAIZoneStructure.Red_Gori[ math.random( 1, #targetBAIZoneStructure.Red_Gori ) ][ 2 ], speed, altitude, AI.Task.WeaponExpend.ALL, 1, 300, nil, 3, 500, 3000, 500, 600, 300, -3600, 1 }


              }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mineralnye scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

            activeBAIWarehouseBisA( param[ pos ] )


          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
          if request.assignment == "PATROL TKVIAVI" then


            local param = {

              [1] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
              [2] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
              [3] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 }

            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mineralnye scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activePATROLWarehouseA( param[ pos ] )

          end -- end if


          ------------------------------------------------------------------------------------------------------ assignment for GCI asset
          if request.assignment == "GCI" then

            -- inserire la funzione

          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
          if request.assignment == "Bomb Tbilisi" then


              local param = {

                [1] = { groupset, warehouse.Mineralnye, warehouse.Tbilisi, 5000, 7000, 330, 5000, AI.Task.WeaponExpend.ALL, 20000, 330, 500  },
                [2] = { groupset, warehouse.Mineralnye, warehouse.Tbilisi, 7000, 3000, 370, 4000, AI.Task.WeaponExpend.ALL, 20000, 310, 540  },
                [3] = { groupset, warehouse.Mineralnye, warehouse.Tbilisi, 4000, 5000, 300, 3000, AI.Task.WeaponExpend.ALL, 20000, 340, 600  }


            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mineralnye scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activeBOMBINGWarehouseA( param[ pos ] )

          end  --end  function warehouse.Kobuleti:OnAfterSelfRequest(From, Event, To, groupset, request)


          if request.assignment == "Bomb Tkviavi" then

              local param = {

                [1] = { groupset, warehouse.Mineralnye, warehouse.Gori, 5000, 7000, 330, 5000, AI.Task.WeaponExpend.ALL, 20000, 330, 500  },
                [2] = { groupset, warehouse.Mineralnye, warehouse.Gori, 7000, 3000, 370, 4000, AI.Task.WeaponExpend.ALL, 20000, 310, 540  },
                [3] = { groupset, warehouse.Mineralnye, warehouse.Gori, 4000, 5000, 300, 3000, AI.Task.WeaponExpend.ALL, 20000, 340, 600  }


              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mineralnye scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )


              activeBOMBINGWarehouseA( param[ pos ] )

          end  --end  function warehouse.Mineralnye:OnAfterSelfRequest(From, Event, To, groupset, request)



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

        end -- end function warehouse.Mineralnye:OnAfterSelfRequest(From,Event,To,groupset,request)

    end
    ---------------------------------------------------------------- END red Mineralnye warehouse operations -------------------------------------------------------------------------------------------------------------------------




















































    ------------------------------------------------------------------ red Mozdok warehouse operations -------------------------------------------------------------------------------------------------------------------------
    local mozdok_wh_activation = true

    if mozdok_wh_activation then


        -- Mozdok e' una delle principale warehouse russe nell'area. Qui sono immagazzinate la maggior parte degli asset da impiegare nella zona dei combattimenti
        -- Send resupply to Kvemo_Sba, Beslan

        warehouse.Mozdok = WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.red.Mozdok[ 1 ], targetBAIStaticObj.Warehouse_AB.red.Mozdok[ 2 ])  --Functional.Warehouse#WAREHOUSE

        warehouse.Mozdok:Start()

        warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_21Bis,             10,         WAREHOUSE.Attribute.AIR_FIGHTER  )
        --warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_23MLD,             15,         WAREHOUSE.Attribute.AIR_FIGHTER  )
        --warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_25PD,             15,         WAREHOUSE.Attribute.AIR_FIGHTER  )
        --warehouse.Mozdok:AddAsset(                air_template_red.GCI_Mig_19P,             15,         WAREHOUSE.Attribute.AIR_FIGHTER  )
        warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_21Bis,             15,         WAREHOUSE.Attribute.AIR_FIGHTER  )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_23MLD,             15,         WAREHOUSE.Attribute.AIR_FIGHTER  )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_25PD,             15,         WAREHOUSE.Attribute.AIR_FIGHTER  )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAP_Mig_19P,             15,         WAREHOUSE.Attribute.AIR_FIGHTER  )
        warehouse.Mozdok:AddAsset(                air_template_red.BOM_SU_24_Bomb,            10,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mozdok:AddAsset(                air_template_red.BOM_TU_22_Bomb,             5,         WAREHOUSE.Attribute.AIR_BOMBER )
        --warehouse.Mozdok:AddAsset(                air_template_red.BOM_TU_22_Nuke,             5,         WAREHOUSE.Attribute.AIR_BOMBER )
        --warehouse.Mozdok:AddAsset(                air_template_red.BOM_SU_24_Bomb,             5,         WAREHOUSE.Attribute.AIR_BOMBER )
        --warehouse.Mozdok:AddAsset(                air_template_red.BOM_SU_24_Structure,             5,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mozdok:AddAsset(                air_template_red.EWR_TU_22,                  1,         WAREHOUSE.Attribute.AIR_AWACS )
        --warehouse.Mozdok:AddAsset(                air_template_red.EWR_Mig_25RTB,                  1,         WAREHOUSE.Attribute.AIR_AWACS )
        warehouse.Mozdok:AddAsset(                air_template_red.CAS_Su_17M4_Rocket,        10,         WAREHOUSE.Attribute.AIR_BOMBER )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAS_Mig_27K_Bomb,        10,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mozdok:AddAsset(                air_template_red.CAS_MI_24V,                12,         WAREHOUSE.Attribute.AIR_ATTACKHELO    ) -- attack
        --warehouse.Mozdok:AddAsset(                air_template_red.CAS_L_39C_Rocket,        10,         WAREHOUSE.Attribute.AIR_BOMBER )
        --warehouse.Mozdok:AddAsset(                air_template_red.CAS_Mi_8MTV2,        10,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mozdok:AddAsset(                air_template_red.GA_SU_24M_Bomb,             1,         WAREHOUSE.Attribute.AIR_BOMBER )
        --warehouse.Mozdok:AddAsset(                air_template_red.GA_SU_24M_HRocket,             1,         WAREHOUSE.Attribute.AIR_BOMBER )
        --warehouse.Mozdok:AddAsset(                air_template_red.GA_SU_24M_HBomb,             1,         WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Mozdok:AddAsset(                air_template_red.TRAN_MI_24,                12,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           1500   ) -- transport
        warehouse.Mozdok:AddAsset(                air_template_red.TRAN_MI_26,                10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000  ) -- transport
        warehouse.Mozdok:AddAsset(                air_template_red.TRAN_AN_26,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- transport
        --warehouse.Mozdok:AddAsset(                air_template_red.TRAN_YAK_40,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- transport
        --warehouse.Mozdok:AddAsset(                air_template_red.REC_Mig_25RTB,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- recognition
        --warehouse.Mozdok:AddAsset(                air_template_red.REC_SU_24MR,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- recognition
        --warehouse.Mozdok:AddAsset(                air_template_red.AFAC_Yak_52,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- afac
        --warehouse.Mozdok:AddAsset(                air_template_red.AFAC_L_39C,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- afac
        --warehouse.Mozdok:AddAsset(                air_template_red.AFAC_Mi_8MTV2,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- afac
        --warehouse.Mozdok:AddAsset(                air_template_red.AFAC_Mi_24,                4,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- afac
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.ArmorA,          10,                WAREHOUSE.Attribute.GROUND_TANK    ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.ArmorB,          10,                WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.ArtiAkatsia,     10,                WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.ArtiGwozdika,    10,                WAREHOUSE.Attribute.GROUND_ARTILLERY    ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.ArtiKatiusha,    10,                WAREHOUSE.Attribute.GROUND_ARTILLERY    ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.ArtiHeavyMortar, 10,                WAREHOUSE.Attribute.GROUND_ARTILLERY    ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.mechanizedA,     10,                WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.mechanizedB,     10,                WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.mechanizedC,     10,                WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.antitankA,       10,                WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.antitankB,       50,          WAREHOUSE.Attribute.GROUND_TANK  )
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.antitankC,       50,          WAREHOUSE.Attribute.GROUND_TANK  )
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.TransportA,       5,                WAREHOUSE.Attribute.GROUND_TRUCK   ) -- transport
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.TransportB,       5,                WAREHOUSE.Attribute.GROUND_TRUCK   ) -- transport
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.TroopTransport,   5,                WAREHOUSE.Attribute.GROUND_TRUCK   ) -- transport troop
        --warehouse.Mozdok:AddAsset(                ground_group_template_red.Truck,            3 )

        logging('info', { 'main' , 'addAsset Mozdok warehouse'} )

        logging('info', { 'main' , 'addrequest Mozdok warehouse'} )

        local depart_time = defineRequestPosition(4)
        local mozdok_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local mozdok_sched = SCHEDULER:New( nil,

          function()
            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[1] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Rocket, 4, nil, nil, nil, "BAI TKVIAVI")
            warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[2] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, 2, nil, nil, nil, "PATROL TKVIAVI")
            warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[3] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 2, nil, nil, nil, "Bomb Kutaisi")
            warehouse.Mozdok:__AddRequest( startReqTimeAir + depart_time[4] * waitReqTimeAir, warehouse.Mozdok, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 2, nil, nil, nil, "Bomb Tkviavi")
            logging('info', { 'main' , 'Mozdok scheduler - start time:' .. start_sched *  mozdok_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )


          end, {}, start_sched * mozdok_efficiency_influence, interval_sched, rand_sched

        ) -- end mozdok_sched = SCHEDULER:New( nil, ..)

        -- Do something with the spawned aircraft.
        function warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)

          --local groupset=groupset --Core.Set#SET_GROUP
          --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TKVIAVI" then

            local targets=GROUP:FindByName("Georgian Mechanized Defence Squad@Tkviavi B")

            -- Activate the targets.
            --RedTargets:Activate()

            local speed, altitude = defineSpeedAndAltitude(500, 700, 4000, 7000)

            local param = {

                  [1] = { 'Interdiction from Mozdok to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.FOUR, 2, 300, blueGroundGroup[6], 3, 500, 1000, 500, 600, 300, -3600, 1  },
                  [2] = { 'Interdiction from Mozdok to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.HALF, 1, 300, blueGroundGroup[7], 3, 500, 1000, 500, 600, 300, -3600, 1 },
                  [3] = { 'Interdiction from Mozdok to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.ALL, 1, 300, blueGroundGroup[9], 3, 500, 1000, 500, 600, 300, -3600, 1 }


            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mozdok scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

            activeBAIWarehouseBisA( param[ pos ] )


          end -- end if


          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
          if request.assignment == "PATROL TKVIAVI" then


            local param = {

              [1] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
              [2] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
              [3] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 }

            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mozdok scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activePATROLWarehouseA( param[ pos ] )


          end -- end if


          ------------------------------------------------------------------------------------------------------ assignment for GCI asset
          if request.assignment == "GCI" then

            -- inserire la funzione

          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
          if request.assignment == "Bomb Kutaisi" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

              local home = warehouse.Mozdok
              local target = warehouse.Kutaisi

              'groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombQuantity, bombRunDistance, bombRunDirection, speedBombRun'

              local toTargetAltitude = math.random(5000, 7000)
              local toHomeAltitude = math.random(3000, 5000)
              local bombingDirection = math.random(270, 359)
              local bombingAltitude = math.random(4000, 6000)
              local bombQuantity = 2023
              local bombRunDistance = 20000
              local bombRunDirection = math.random(270, 359)
              local speedBombRun = math.random(400, 600)

              local param = {

                [1] = { groupset, warehouse.Mozdok, warehouse.Kutaisi, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun },
                [2] = { groupset, warehouse.Mozdok, warehouse.Kvitiri, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun },
                [3] = { groupset, warehouse.Mozdok, warehouse.Kvitiri_Helo, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun },
                [4] = { groupset, warehouse.Mozdok, warehouse.Zestafoni, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun }



            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mozdok scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activeBOMBINGWarehouseA( param[ pos ] )

          end  --end  if


            if request.assignment == "Bomb Tkviavi" then

              local param = {

                [1] = { groupset, warehouse.Mozdok, warehouse.Biteta, 5000, 7000, 330, 5000, AI.Task.WeaponExpend.ALL, 20000, 330, 500  },
                [2] = { groupset, warehouse.Mozdok, warehouse.Biteta, 7000, 3000, 370, 4000, AI.Task.WeaponExpend.ALL, 20000, 310, 540  },
                [3] = { groupset, warehouse.Mozdok, warehouse.Biteta, 4000, 5000, 300, 3000, AI.Task.WeaponExpend.ALL, 20000, 340, 600  }


              }


            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Mozdok scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activeBOMBINGWarehouseA( param[ pos ] )

            end  --end  if




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

        end -- end function warehouse.Mozdok:OnAfterSelfRequest(From,Event,To,groupset,request)

    end
    ------------------------------------------------------------------ END red Mozdok warehouse operations -------------------------------------------------------------------------------------------------------------------------




























































    ------------------------------------------------------------------ red Beslan warehouse operations -------------------------------------------------------------------------------------------------------------------------
    local beslan_wh_activation = true

    if beslan_wh_activation then


        warehouse.Beslan = WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.red.Beslan[ 1 ], targetBAIStaticObj.Warehouse_AB.red.Beslan[ 2 ])  --Functional.Warehouse#WAREHOUSE
        warehouse.Beslan:Start()

        -- Beslan e' una delle principale warehouse russe nell'area.
        -- Receive reupply from Mozdok and Mineralnye. Send resupply to Kvemo_Sba

        warehouse.Beslan:AddAsset(               air_template_red.CAP_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER )
        warehouse.Beslan:AddAsset(               air_template_red.GCI_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER )
        warehouse.Beslan:AddAsset(               air_template_red.CAS_MI_24V,                10,           WAREHOUSE.Attribute.AIR_ATTACKHELO      ) -- attack
        warehouse.Beslan:AddAsset(               air_template_red.CAS_Su_17M4_Rocket,        10,           WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Beslan:AddAsset(               air_template_red.CAS_Mig_27K_Bomb,          10,           WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Beslan:AddAsset(               air_template_red.TRAN_MI_24,                24,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500  ) -- transport
        warehouse.Beslan:AddAsset(               air_template_red.TRAN_MI_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000  ) -- transport
        warehouse.Beslan:AddAsset(               air_template_red.TRAN_AN_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- transport
        warehouse.Beslan:AddAsset(               air_template_red.TRAN_AN_YAK_40,             4,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE ) -- transport
        warehouse.Beslan:AddAsset(               air_template_red.AFAC_L_39C,                 4,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
        warehouse.Beslan:AddAsset(               air_template_red.AFAC_Yak_52,                4,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
        --warehouse.Beslan:AddAsset(               ground_group_template_red.ArmorA,          10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.ArmorB,          10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.ArtiAkatsia,     10,           WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.ArtiGwozdika,    10,           WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.ArtiKatiusha,    10,           WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.ArtiHeavyMortar, 10,           WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.mechanizedA,     10,           WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.mechanizedB,     10,           WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.mechanizedC,     10,           WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.antitankA,       10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.antitankB,       10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Beslan:AddAsset(               ground_group_template_red.antitankC,       10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Beslan:AddAsset(                "Infantry Platoon Alpha",                 6   )

        logging('info', { 'main' , 'addAsset Beslan warehouse'} )

        logging('info', { 'main' , 'addrequest Beslan warehouse'} )

        local depart_time = defineRequestPosition(4)
        local beslan_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local beslan_sched = SCHEDULER:New( nil,

          function()

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[1] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Rocket, 4, nil, nil, nil, "BAI TKVIAVI")
            warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[2] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, 2, nil, nil, nil, "PATROL TKVIAVI")
            warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[3] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 2, nil, nil, nil, "Bomb Kutaisi")
            warehouse.Beslan:__AddRequest( startReqTimeAir + depart_time[4] * waitReqTimeAir, warehouse.Beslan, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 2, nil, nil, nil, "Bomb Tkviavi")
            logging('info', { 'main' , 'Beslan scheduler - start time:' .. start_sched *  beslan_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

          end, {}, start_sched * beslan_efficiency_influence, interval_sched, rand_sched

        )


        -- Do something with the spawned aircraft.
        function warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)

          --local groupset=groupset --Core.Set#SET_GROUP
          --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TKVIAVI" then

            local targets=GROUP:FindByName("Georgian Mechanized Defence Squad@Tkviavi B")

            -- Activate the targets.
            --RedTargets:Activate()

            local speed, altitude = defineSpeedAndAltitude(500, 700, 3000, 5000)

            local param = {

                  [1] = { 'Interdiction from Beslan to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.FOUR, 2, 300, blueGroundGroup[6], 3, 500, 1000, 500, 600, 300, -3600, 1  },
                  [2] = { 'Interdiction from Beslan to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.HALF, 1, 300, blueGroundGroup[7], 3, 500, 1000, 500, 600, 300, -3600, 1 },
                  [3] = { 'Interdiction from Beslan to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.ALL, 1, 300, blueGroundGroup[10], 3, 500, 1000, 500, 600, 300, -3600, 1 }


            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Beslan scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

            activeBAIWarehouseBisA( param[ pos ] )


          end -- end if


          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
          if request.assignment == "PATROL TKVIAVI" then


            local param = {

              [1] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
              [2] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
              [3] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 }

            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Beslan scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )


            activePATROLWarehouseA( param[ pos ] )


          end -- end if


          ------------------------------------------------------------------------------------------------------ assignment for GCI asset
          if request.assignment == "GCI" then

            -- inserire la funzione

          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
          if request.assignment == "Bomb Kutaisi" then


              local param = {

                [1] = { groupset, warehouse.Beslan, warehouse.Kutaisi, 5000, 7000, 330, 5000, AI.Task.WeaponExpend.ALL, 20000, 330, 500  },
                [2] = { groupset, warehouse.Beslan, warehouse.Kutaisi, 7000, 3000, 370, 4000, AI.Task.WeaponExpend.ALL, 20000, 310, 540  },
                [3] = { groupset, warehouse.Beslan, warehouse.Kutaisi, 4000, 5000, 300, 3000, AI.Task.WeaponExpend.ALL, 20000, 340, 600  }


            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Beslan scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activeBOMBINGWarehouseA( param[ pos ] )

          end  -- end if


          if request.assignment == "Bomb Tkviavi" then

            local param = {

              [1] = { groupset, warehouse.Beslan, warehouse.Tkviavi, 5000, 7000, 330, 5000, AI.Task.WeaponExpend.ALL, 20000, 330, 500  },
              [2] = { groupset, warehouse.Beslan, warehouse.Tkviavi, 7000, 3000, 370, 4000, AI.Task.WeaponExpend.ALL, 20000, 310, 540  },
              [3] = { groupset, warehouse.Beslan, warehouse.Tkviavi, 4000, 5000, 300, 3000, AI.Task.WeaponExpend.ALL, 20000, 340, 600  }


            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Beslan scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

           activeBOMBINGWarehouseA( param[ pos ] )

          end  -- end  if




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

        end -- end function warehouse.Beslan:OnAfterSelfRequest(From,Event,To,groupset,request)

    end
    ----------------------------------------------------------------- END red Beslan warehouse operations -------------------------------------------------------------------------------------------------------------------------




























































    ------------------------------------------------------------------- red Nalchik warehouse operations -------------------------------------------------------------------------------------------------------------------------
    local nalchik_wh_activation = true

    if nalchik_wh_activation then

        warehouse.Nalchik       =   WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.red.Nalchik[ 1 ], targetBAIStaticObj.Warehouse_AB.red.Nalchik[ 2 ])  --Functional.Warehouse#WAREHOUSE

        warehouse.Nalchik:Start()
        -- Nalchik e' una delle principale warehouse russe nell'area.
        -- Receive reupply from Mozdok and Mineralnye. Send resupply to Kvemo_Sba

        warehouse.Nalchik:AddAsset(               air_template_red.CAP_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER )
        warehouse.Nalchik:AddAsset(               air_template_red.GCI_Mig_21Bis,             15,           WAREHOUSE.Attribute.AIR_FIGHTER )
        warehouse.Nalchik:AddAsset(               air_template_red.CAS_MI_24V,                10,           WAREHOUSE.Attribute.AIR_ATTACKHELO      ) -- attack
        warehouse.Nalchik:AddAsset(               air_template_red.CAS_Su_17M4_Rocket,        10,           WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Nalchik:AddAsset(               air_template_red.CAS_Mig_27K_Bomb,          10,           WAREHOUSE.Attribute.AIR_BOMBER )
        warehouse.Nalchik:AddAsset(               air_template_red.TRAN_MI_24,                24,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,            1500  ) -- transport
        warehouse.Nalchik:AddAsset(               air_template_red.TRAN_MI_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,           20000  ) -- transport
        warehouse.Nalchik:AddAsset(               air_template_red.TRAN_AN_26,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,           9000  ) -- transport
        warehouse.Nalchik:AddAsset(               air_template_red.TRAN_AN_YAK_40,             4,           WAREHOUSE.Attribute.AIR_TRANSPORTPLANE ) -- transport
        warehouse.Nalchik:AddAsset(               air_template_red.AFAC_L_39C,                 4,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
        warehouse.Nalchik:AddAsset(               air_template_red.AFAC_Yak_52,                4,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.ArmorA,          10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.ArmorB,          10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.ArtiAkatsia,     10,           WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.ArtiGwozdika,    10,           WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.ArtiKatiusha,    10,           WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.ArtiHeavyMortar, 10,           WAREHOUSE.Attribute.GROUND_ARTILLERY   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.mechanizedA,     10,           WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.mechanizedB,     10,           WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.mechanizedC,     10,           WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.antitankA,       10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.antitankB,       10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(               ground_group_template_red.antitankC,       10,           WAREHOUSE.Attribute.GROUND_TANK   ) -- Ground troops
        --warehouse.Nalchik:AddAsset(                "Infantry Platoon Alpha",                 6   )

        logging('info', { 'main' , 'addAsset Nalchik warehouse'} )



        logging('info', { 'main' , 'addrequest Nalchik warehouse'} )

        local depart_time = defineRequestPosition(4)
        local nalchik_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local nalchik_sched = SCHEDULER:New( nil,

          function()

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[1] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAS_Su_17M4_Rocket, 4, nil, nil, nil, "BAI TKVIAVI")
            warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[2] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.GROUPNAME, air_template_red.CAP_Mig_23MLD, 2, nil, nil, nil, "PATROL TKVIAVI")
            warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[3] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 2, nil, nil, nil, "Bomb Kutaisi")
            warehouse.Nalchik:__AddRequest( startReqTimeAir + depart_time[4] * waitReqTimeAir, warehouse.Nalchik, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 2, nil, nil, nil, "Bomb Tkviavi")
            logging('info', { 'main' , 'Nalchik scheduler - start time:' .. start_sched *  nalchik_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

          end, {}, start_sched * nalchik_efficiency_influence, interval_sched, rand_sched

        )


        -- Do something with the spawned aircraft.
        function warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)

          --local groupset=groupset --Core.Set#SET_GROUP
          --local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TKVIAVI" then

            local targets=GROUP:FindByName("Georgian Mechanized Defence Squad@Tkviavi B")

            -- Activate the targets.
            --RedTargets:Activate()

            local speed, altitude = defineSpeedAndAltitude(500, 700, 3000, 5000)

            local param = {

                  [1] = { 'Interdiction from Nalchik to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.FOUR, 2, 300, blueGroundGroup[1], 3, 500, 1000, 500, 600, 300, -3600, 1  },
                  [2] = { 'Interdiction from Nalchik to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.HALF, 1, 300, blueGroundGroup[4], 3, 500, 1000, 500, 600, 300, -3600, 1 },
                  [3] = { 'Interdiction from Nalchik to Tkviavi', groupset, 'target', redFrontZone.DIDI_CUPTA[2], blueFrontZone.TKVIAVI[2], speed, altitude, AI.Task.WeaponExpend.ALL, 1, 300, blueGroundGroup[5], 3, 500, 1000, 500, 600, 300, -3600, 1 }


              }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest' , 'Nalchik scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

            activeBAIWarehouseBisA( param[ pos ] )


          end -- end if


          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
          if request.assignment == "PATROL TKVIAVI" then


            local param = {

              [1] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
              [2] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
              [3] = { groupset, redFrontZone.DIDI_CUPTA[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 }

            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest' , 'Nalchik scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activePATROLWarehouseA( param[ pos ] )


          end -- end if


          ------------------------------------------------------------------------------------------------------ assignment for GCI asset
          if request.assignment == "GCI" then

            -- inserire la funzione

          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset (devi introdurre il ritardo)
          if request.assignment == "Bomb Kutaisi" then


              local param = {

                [1] = { groupset, warehouse.Nalchik, warehouse.Kutaisi, 5000, 7000, 330, 5000, AI.Task.WeaponExpend.ALL, 20000, 330, 500  },
                [2] = { groupset, warehouse.Nalchik, warehouse.Kutaisi, 7000, 3000, 370, 4000, AI.Task.WeaponExpend.ALL, 20000, 310, 540  },
                [3] = { groupset, warehouse.Nalchik, warehouse.Kutaisi, 4000, 5000, 300, 3000, AI.Task.WeaponExpend.ALL, 20000, 340, 600  }


            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest' , 'Nalchik scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activeBOMBINGWarehouseA( param[ pos ] )

          end  --end  if


          if request.assignment == "Bomb Tkviavi" then

            local param = {

              [1] = { groupset, warehouse.Nalchik, warehouse.Tkviavi, 5000, 7000, 330, 5000, AI.Task.WeaponExpend.ALL, 20000, 330, 500  },
              [2] = { groupset, warehouse.Nalchik, warehouse.Tkviavi, 7000, 3000, 370, 4000, AI.Task.WeaponExpend.ALL, 20000, 310, 540  },
              [3] = { groupset, warehouse.Nalchik, warehouse.Tkviavi, 4000, 5000, 300, 3000, AI.Task.WeaponExpend.ALL, 20000, 340, 600  }


            }

            local pos = math.random( 1 , #param )

            logging('info', { 'warehouse.Nalchik:OnAfterSelfRequest' , 'Nalchik scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

            activeBOMBINGWarehouseA( param[ pos ] )

          end  --end  if




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

        end -- end function warehouse.Nalchik:OnAfterSelfRequest(From,Event,To,groupset,request)

    end
    ------------------------------------------------------------------- END red Nalchik warehouse operations -------------------------------------------------------------------------------------------------------------------------













































    ----------------------------------------------------------- BLUE WAREHOUSE OPERATIONS





    ------------------------------------------------- blue Warehouse BATUMI operations -------------------------------------------------------------------------------------------------------------------------

    local Batumi_wh_activation = false

    if Batumi_wh_activation then


        --  Batumi e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Batumi - Zestafoni - Gori
        -- Batumi e' utilizzato come aeroporto militare. Da Batumi decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.


        warehouse.Batumi        =   WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.blue.Batumi[ 1 ], targetBAIStaticObj.Warehouse_AB.blue.Batumi[ 2 ])   --Functional.Warehouse#WAREHOUSE
        warehouse.Batumi:Start()

        -- warehouse.Batumi:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        warehouse.Batumi:AddAsset(               air_template_blue.CAP_F_5,                  10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        warehouse.Batumi:AddAsset(              air_template_blue.CAP_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER )
        warehouse.Batumi:AddAsset(              air_template_blue.GCI_F_4,                  5,           WAREHOUSE.Attribute.AIR_FIGHTER )
        -- warehouse.Batumi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER  ) -- Bomber BAI
        -- warehouse.Batumi:AddAsset(               air_template_blue.CAS_Su_17M4_Rocket,       10  ) --  CAS
        warehouse.Batumi:AddAsset(               air_template_blue.TRAN_AN_26,                5,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000 ) -- Transport
        warehouse.Batumi:AddAsset(              air_template_blue.TRAN_C_130,                6,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,              9000 ) -- Transport
        -- warehouse.Batumi:AddAsset(               air_template_blue.TRAN_UH_1H,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 ) -- Transport ) -- Transport
        warehouse.Batumi:AddAsset(               air_template_blue.TRAN_UH_60A,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000  ) -- Transport
        warehouse.Batumi:AddAsset(               air_template_blue.TRAN_CH_47,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700 ) -- Transport
        -- warehouse.Batumi:AddAsset(               air_template_blue.TRAN_MI_24,                6,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500 ) -- Transport
        -- warehouse.Batumi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
        -- warehouse.Batumi:AddAsset(               air_template_blue.CAS_MI_24V,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO    ) -- Heli CAS
        warehouse.Batumi:AddAsset(               air_template_blue.EWR_B_1B,                 2,             WAREHOUSE.Attribute.AIR_AWACS ) -- EWR
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.Truck,           3,             WAREHOUSE.Attribute.GROUND_TRUCK ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.antitankA,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.antitankB,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.antitankC,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.ArmorA,          10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.ArmorB,          10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.mechanizedA,     10,            WAREHOUSE.Attribute.GROUND_APC  ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.mechanizedB,     10,            WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.mechanizedC,     10,            WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.TransportA,       6,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.TransportB,       4,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        -- warehouse.Batumi:AddAsset(               ground_group_template_blue.TroopTransport,   4,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport

        logging('info', { 'main' , 'addAsset Batumi warehouse'} )

    end
    ------------------------------------------------- END blue Warehouse BATUMI operations -------------------------------------------------------------------------------------------------------------------------


























    ------------------------------------------------- blue Warehouse KUTAISI operations -------------------------------------------------------------------------------------------------------------------------
    local Kutaisi_wh_activation = false

    if Kutaisi_wh_activation then

        warehouse.Kutaisi       =   WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.blue.Kutaisi[ 1 ],  targetBAIStaticObj.Warehouse_AB.blue.Kutaisi[ 2 ] )  --Functional.Warehouse#WAREHOUSE
        warehouse.Kutaisi:Start()

        --  Kutaisi e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Kutaisi - Zestafoni - Gori
        -- Kutaisi e' utilizzato come aeroporto militare. Da Kutaisi decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.

        warehouse.Kutaisi:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAP_F_5,                  10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        warehouse.Kutaisi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER  ) -- Bomber BAI
        warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_Su_17M4_Rocket,       10  ) --  CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_AN_26,                5,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000 ) -- Transport
        warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_UH_1H,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 ) -- Transport ) -- Transport
        --warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_UH_60A,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000  ) -- Transport
        --warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_CH_47,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700 ) -- Transport
        --warehouse.Kutaisi:AddAsset(               air_template_blue.TRAN_MI_24,                6,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500 ) -- Transport
        warehouse.Kutaisi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
        --warehouse.Kutaisi:AddAsset(               air_template_blue.CAS_MI_24V,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO    ) -- Heli CAS
        warehouse.Kutaisi:AddAsset(               air_template_blue.EWR_B_1B,                 2,             WAREHOUSE.Attribute.AIR_AWACS ) -- EWR
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.Truck,           3,             WAREHOUSE.Attribute.GROUND_TRUCK ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankA,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankB,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.antitankC,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArmorA,          10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArmorB,          10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedA,     10,            WAREHOUSE.Attribute.GROUND_APC  ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedB,     10,            WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.mechanizedC,     10,            WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TransportA,       6,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TransportB,       4,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        warehouse.Kutaisi:AddAsset(               ground_group_template_blue.TroopTransport,   4,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport

        logging('info', { 'main' , 'addAsset Kutaisi warehouse'} )


    end
    ------------------------------------------------- END blue Warehouse KUTAISI operations -------------------------------------------------------------------------------------------------------------------------























    ------------------------------------------------- blue Warehouse KVITIRI operations -------------------------------------------------------------------------------------------------------------------------

    local Kvitiri_wh_activation = false

    if Kvitiri_wh_activation then

        warehouse.Kvitiri       =   WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.blue.Kvitiri[ 1 ], targetBAIStaticObj.Warehouse_AB.blue.Kvitiri[ 2 ])  --Functional.Warehouse#WAREHOUSE
        warehouse.Kvitiri:Start()

        --  Kvitiri e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Kvitiri - Zestafoni - Gori
        -- Kvitiri e' utilizzato come aeroporto militare. Da Kvitiri decollano voli per trasporto merci e missioni di pinpoint strike CAS e BAI.

        warehouse.Kvitiri:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        warehouse.Kvitiri:AddAsset(               air_template_blue.CAP_F_5,                  10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER  ) -- Bomber BAI
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_Su_17M4_Rocket,       10  ) --  CAS
        warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_AN_26,                2,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000 ) -- Transport
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_UH_1H,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 ) -- Transport ) -- Transport
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_UH_60A,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000  ) -- Transport
        warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_CH_47,                2,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700 ) -- Transport
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.TRAN_MI_24,                6,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500 ) -- Transport
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.CAS_MI_24V,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO    ) -- Heli CAS
        -- warehouse.Kvitiri:AddAsset(               air_template_blue.EWR_B_1B,                 2,             WAREHOUSE.Attribute.AIR_AWACS ) -- EWR
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.Truck,           3,             WAREHOUSE.Attribute.GROUND_TRUCK ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.antitankA,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.antitankB,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.antitankC,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.ArmorA,          10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.ArmorB,          10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.mechanizedA,     10,            WAREHOUSE.Attribute.GROUND_APC  ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.mechanizedB,     10,            WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.mechanizedC,     10,            WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.TransportA,       6,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        -- warehouse.Kvitiri:AddAsset(               ground_group_template_blue.TransportB,       4,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        --warehouse.Kvitiri:AddAsset(               ground_group_template_blue.TroopTransport,   4,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport

        logging('info', { 'main' , 'addAsset Kvitiri warehouse'} )

    end
    ------------------------------------------------- END blue Warehouse KVITIRI operations -------------------------------------------------------------------------------------------------------------------------




























    ------------------------------------------------- blue Warehouse KVITIRI_HELO operations -------------------------------------------------------------------------------------------------------------------------

    local Kvitiri_Helo_wh_activation = false

    if Kvitiri_Helo_wh_activation then

        warehouse.Kvitiri_Helo  =   WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.blue.Kvitiri_Helo[ 1 ], targetBAIStaticObj.Warehouse_AB.blue.Kvitiri_Helo[ 2 ])  --Functional.Warehouse#WAREHOUSE
        warehouse.Kvitiri_Helo:Start()

        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAP_F_5,                  10,            WAREHOUSE.Attribute.AIR_FIGHTER   ) -- Fighter
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER  ) -- Bomber BAI
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_Su_17M4_Rocket,       10  ) --  CAS
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_AN_26,                5,            WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000 ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_UH_1H,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 ) -- Transport ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_UH_60A,               10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000  ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_CH_47,                10,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700 ) -- Transport
        warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.TRAN_MI_24,                6,            WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500 ) -- Transport
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           10,            WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.CAS_MI_24V,               10,            WAREHOUSE.Attribute.AIR_ATTACKHELO    ) -- Heli CAS
        -- warehouse.Kvitiri_Helo:AddAsset(               air_template_blue.EWR_B_1B,                 2,             WAREHOUSE.Attribute.AIR_AWACS ) -- EWR
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.Truck,           3,             WAREHOUSE.Attribute.GROUND_TRUCK ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.antitankA,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.antitankB,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.antitankC,       10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.ArmorA,          10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.ArmorB,          10,            WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,            WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.mechanizedA,     10,            WAREHOUSE.Attribute.GROUND_APC  ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.mechanizedB,     10,            WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.mechanizedC,     10,            WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.TransportA,       6,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.TransportB,       4,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        -- warehouse.Kvitiri_Helo:AddAsset(               ground_group_template_blue.TroopTransport,   4,            WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport

        logging('info', { 'main' , 'addAsset Kvitiri_Helo warehouse'} )

    end
    ------------------------------------------------- END blue Warehouse KVITIRI_HELO operations -------------------------------------------------------------------------------------------------------------------------































    ------------------------------------------------- blue Warehouse ZESTAFONI operations -------------------------------------------------------------------------------------------------------------------------
    local zestafoni_wh_activation = true

    if zestafoni_wh_activation then

        warehouse.Zestafoni  =  WAREHOUSE:New( targetBAIStaticObj.Warehouse.blue.Zestafoni[ 1 ], targetBAIStaticObj.Warehouse.blue.Zestafoni[ 2 ] )  --Functional.Warehouse#WAREHOUSE
        warehouse.Zestafoni:SetSpawnZone(ZONE:New("Warehouse ZESTAFONI Spawn Zone"))
        warehouse.Zestafoni:Start()


        -- Zestafoni e' la warehouse di collegamento per rifornire khashuri e Gori
        --warehouse.Zestafoni:AddAsset( "Infantry Platoon Alpha", 6 )
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.antitankB,          6,         WAREHOUSE.Attribute.GROUND_TANK )
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.antitankA,          6,         WAREHOUSE.Attribute.GROUND_TANK )
        warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_UH_1H,                  3,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000  )  -- Transport
        warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_UH_60A,                 3,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000  )  -- Transport
        warehouse.Zestafoni:AddAsset(           air_template_blue.TRAN_CH_47,                  4,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700 ) -- Transport
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TransportA,         6,         WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TransportB,         4,         WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.TroopTransport,     4,         WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        warehouse.Zestafoni:AddAsset(           air_template_blue.CAS_MI_24V,                 12,         WAREHOUSE.Attribute.AIR_ATTACKHELO       ) -- Attack
        warehouse.Zestafoni:AddAsset(           air_template_blue.AFAC_Mi_24,                  4,         WAREHOUSE.Attribute.AIR_ATTACKHELO ) -- AFAC
        warehouse.Zestafoni:AddAsset(           air_template_blue.AFAC_SA342L,                 4,         WAREHOUSE.Attribute.AIR_ATTACKHELO ) -- AFAC
        warehouse.Zestafoni:AddAsset(           ground_group_template_blue.ArtilleryResupply, 10,         WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport

        logging('info', { 'main' , 'addAsset Zestafoni warehouse'} )

        -- ZESTAFONI warehouse e' una frontline warehouse: invia gli asset sul campo con task assegnato. Didi e' rifornita da Biteta Warehouse

        logging('info', { 'main' , 'addrequest Zestafoni warehouse'} )


           -- random targets
        local rndTrgZestafoni = {

          -- [1] = number of mission
          -- [pos mission][1] = name of mission
          -- [pos mission][2] = name of mission
          -- [pos mission][3] = asset group name
          -- [pos mission][4] = quantity
          -- [pos mission][5] = target zone
          -- [pos mission][6] = type of mission

          mechanized = {

            {'CZ_PEREVI_attack_1',  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1 , redFrontZone.CZ_PEREVI, 'mech_attack'  }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'CZ_PEREVI_attack_2',  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, 1, redFrontZone.CZ_ONI, 'mech_attack'  }, -- 3
            {'CZ_ONI_attack_3',  WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, 2, redFrontZone.CZ_PEREVI, 'mech_APC'  } -- 3
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          },

          helo = {}

        }


        local zestafoni_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local zestafoni_sched = SCHEDULER:New( nil,

          function()

            local num_mission = 3 -- the number of mission request ( _addRequest() )
            local depart_time = defineRequestPosition(num_mission)
            local pos_mech = defineRequestPosition( #rndTrgZestafoni.mechanized )
            -- local pos_helo = defineRequestPosition( #rndTrgZestafoni.helo )


            for i = 1, num_mission do

              logging('finest', { 'Zestafoni scheduler function' , 'depart_time = [ ' .. i .. ' ] = ' .. depart_time[i] } )

              if i < #rndTrgZestafoni.mechanized then
                logging('finest', { 'Zestafoni scheduler function' , 'pos_mech[ ' .. i .. '] =' .. pos_mech[i] } )
                -- logging('finest', { 'Zestafoni scheduler function' , 'rndTrgZestafoni.mechanized[ 1 ] = ' .. rndTrgZestafoni.mechanized[ 1 ] .. '  - rndTrgZestafoni.mechanized[ pos_mech[][ 2 ] = ' .. rndTrgZestafoni.mechanized[ pos_mech[ i ] + 1 ][ 2 ] .. 'rndTrgZestafoni.mechanized[ pos_mech[][ 3 ] = ' .. rndTrgZestafoni.mechanized[ pos_mech[ i ] + 1 ][ 3 ] .. '  - rndTrgZestafoni.mechanized[ pos_mech[][ 4 ] = ' .. rndTrgZestafoni.mechanized[ pos_mech[ i ] + 1 ][ 4 ][ 2 ]  .. '  - rndTrgZestafoni.mechanized[ pos_mech[][ 5 ] = ' .. rndTrgZestafoni.mechanized[ pos_mech[ i ] + 1 ][ 5 ]} )
                logging('finest', { 'Zestafoni scheduler function' , '#rndTrgZestafoni.mechanized = ' .. #rndTrgZestafoni.mechanized} )
                logging('finest', { 'Zestafoni scheduler function' , 'rndTrgZestafoni.mechanized[ pos_mech[][ 2 ] = ' .. rndTrgZestafoni.mechanized[ pos_mech[ i ] ][ 2 ]} )
                logging('finest', { 'Zestafoni scheduler function' , 'rndTrgZestafoni.mechanized[ pos_mech[][ 3 ] = ' .. rndTrgZestafoni.mechanized[ pos_mech[ i ] ][ 3 ]} )
                logging('finest', { 'Zestafoni scheduler function' , 'rndTrgZestafoni.mechanized[ pos_mech[][ 4 ] = ' .. rndTrgZestafoni.mechanized[ pos_mech[ i ] ][ 4 ]} )
                logging('finest', { 'Zestafoni scheduler function' , 'rndTrgZestafoni.mechanized[ pos_mech[][ 5 ] = ' .. rndTrgZestafoni.mechanized[ pos_mech[ i ] ][ 5 ][2]} )
              end

            end



            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[1] * waitReqTimeGround, warehouse.Zestafoni,  rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 2 ], rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 3 ], rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 4 ], nil, nil, nil, rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 1 ] )
            warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[2] * waitReqTimeGround, warehouse.Zestafoni,  rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 2 ], rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 3 ], rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 4 ], nil, nil, nil, rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 1 ] )
            warehouse.Zestafoni:__AddRequest( startReqTimeGround + depart_time[3] * waitReqTimeGround, warehouse.Zestafoni,  rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 2 ], rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 3 ], rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 4 ], nil, nil, nil, rndTrgZestafoni.mechanized[ pos_mech[ 1 ] ][ 1 ] )
          end, {}, start_ground_sched * zestafoni_efficiency_influence, interval_ground_sched, rand_ground_sched

        )

        -- l'eventuale variazione causale dei parametri di missione la devi fare sulla AddRequest: io la farei solo sulle quantit�

        logging('info', { 'main' , 'addRequest ZESTAFONI warehouse'} )



        -- Take care of the spawned units.
        function warehouse.Zestafoni:OnAfterSelfRequest( From,Event,To,groupset,request )

          logging('enter', 'warehouse.ZESTAFONI:OnAfterSelfRequest(From,Event,To,groupset,request)' )

          local groupset = groupset --Core.Set#SET_GROUP
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

          -- Get assignment of this request.
          local assignment = warehouse.Zestafoni:GetAssignment(request)

          logging('info', { 'warehouse.ZESTAFONI:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'assignment = ' .. assignment .. '  - groupName = ' .. groupset:GetObjectNames()} )

          if assignment == rndTrgZestafoni.mechanized[ 1 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgZestafoni.mechanized[ 1 ][ 5 ], rndTrgZestafoni.mechanized[ 1 ][ 6 ], nil, nil, nil )  end

          if assignment == rndTrgZestafoni.mechanized[ 2 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgZestafoni.mechanized[ 2 ][ 5 ], rndTrgZestafoni.mechanized[ 2 ][ 6 ], nil, nil, nil  )  end

          if assignment == rndTrgZestafoni.mechanized[ 3 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgZestafoni.mechanized[ 3 ][ 5 ], rndTrgZestafoni.mechanized[ 3 ][ 6 ], nil, nil, nil  )  end

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

    end
    ------------------------------------------------- END blue Warehouse ZESTAFONI operations -------------------------------------------------------------------------------------------------------------------







































      ----------------------------------------------- blue Warehouse KHASHURI operations ------------------------------------------------------------------------------------------------------------------------
      local khashuri_wh_activation = true

      if khashuri_wh_activation then


          -- Khashuri e' una warehouse del fronte
          --warehouse.Khashuri:AddAsset( "Infantry Platoon Alpha", 50 )
          warehouse.Khashuri = WAREHOUSE:New( targetBAIStaticObj.Warehouse.blue.Khashuri[ 1 ], targetBAIStaticObj.Warehouse.blue.Khashuri[ 2 ] )  --Functional.Warehouse#WAREHOUSE

          warehouse.Khashuri:SetSpawnZone(ZONE:New("Warehouse KHASHURI Spawn Zone"))

          warehouse.Khashuri:Start()

          warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankA,          6,          WAREHOUSE.Attribute.GROUND_TANK )
          warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankC,          6,          WAREHOUSE.Attribute.GROUND_TANK )
          warehouse.Khashuri:AddAsset(           ground_group_template_blue.antitankB,          6,          WAREHOUSE.Attribute.GROUND_TANK )
          warehouse.Khashuri:AddAsset(           air_template_blue.CAS_MI_24V,                 12,          WAREHOUSE.Attribute.AIR_ATTACKHELO       ) -- Attack
          warehouse.Khashuri:AddAsset(           air_template_blue.TRAN_UH_1H,                  3,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 )  -- Transport
          warehouse.Khashuri:AddAsset(           air_template_blue.AFAC_Mi_24,                  4,          WAREHOUSE.Attribute.AIR_ATTACKHELO ) -- AFAC
          warehouse.Khashuri:AddAsset(           air_template_blue.AFAC_SA342L,                 4,          WAREHOUSE.Attribute.AIR_ATTACKHELO ) -- AFAC
          warehouse.Khashuri:AddAsset(           ground_group_template_blue.ArtilleryResupply, 10,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
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
        local khashuri_sched = SCHEDULER:New( nil,

          function()

            local num_mission = 2 -- the number of mission request ( _addRequest() )
            local depart_time = defineRequestPosition( num_mission )
            local pos_mech = defineRequestPosition( #rndTrgKhashuri.mechanized )
            -- local pos_helo = defineRequestPosition( #rndTrgKhashuri.helo )

            for i = 1, num_mission do

              logging('finest', { 'khashuri scheduler function' , 'depart_time = [ ' .. i .. ' ] = ' .. depart_time[i] } )

              if i < #rndTrgKhashuri.mechanized then
                logging('finest', { 'khashuri scheduler function' , 'pos_mech[ ' .. i .. '] =' .. pos_mech[i] } )
                logging('finest', { 'khashuri scheduler function' , '#rndTrgKhashuri.mechanized = ' .. #rndTrgKhashuri.mechanized .. '  - rndTrgKhashuri.mechanized[ pos_mech[][ 2 ] = ' .. rndTrgKhashuri.mechanized[ pos_mech[ i ] ][ 2 ] .. 'rndTrgKhashuri.mechanized[ pos_mech[][ 3 ] = ' .. rndTrgKhashuri.mechanized[ pos_mech[ i ] ][ 3 ] .. '  - rndTrgKhashuri.mechanized[ pos_mech[][ 4 ] = ' .. rndTrgKhashuri.mechanized[ pos_mech[ i ] ][ 4 ]  .. '  - rndTrgKhashuri.mechanized[ pos_mech[][ 5 ] = ' .. rndTrgKhashuri.mechanized[ pos_mech[ i ] ][ 5 ][2]} )
              end

            end

            warehouse.Khashuri:__AddRequest( startReqTimeGround + depart_time[1] * waitReqTimeGround, warehouse.Khashuri,  rndTrgKhashuri.mechanized[ pos_mech[ 1 ] ][ 2 ], rndTrgKhashuri.mechanized[ pos_mech[ 1 ] ][ 3 ], rndTrgKhashuri.mechanized[ pos_mech[ 1 ] ][ 4 ], nil, nil, nil, rndTrgKhashuri.mechanized[ pos_mech[ 1 ] ][ 1 ] )
            warehouse.Khashuri:__AddRequest( startReqTimeGround + depart_time[2] * waitReqTimeGround, warehouse.Khashuri,  rndTrgKhashuri.mechanized[ pos_mech[ 2 ] ][ 2 ], rndTrgKhashuri.mechanized[ pos_mech[ 2 ] ][ 3 ], rndTrgKhashuri.mechanized[ pos_mech[ 2 ] ][ 4 ], nil, nil, nil, rndTrgKhashuri.mechanized[ pos_mech[ 2 ] ][ 1 ] )

          end, {}, start_ground_sched * khashuri_efficiency_influence, interval_ground_sched, rand_ground_sched

        )


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

          if assignment == rndTrgKhashuri.mechanized[ 1 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgKhashuri.mechanized[ 1 ][ 5 ], rndTrgKhashuri.mechanized[ 1 ][ 6 ], nil, nil, nil)  end
          if assignment == rndTrgKhashuri.mechanized[ 2 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgKhashuri.mechanized[ 2 ][ 5 ], rndTrgKhashuri.mechanized[ 2 ][ 6 ], nil, nil, nil)  end


        end -- end function


        -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di zestafoni (link) quando gli asset vengono distrutti
        -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati
        --
        function warehouse.Khashuri:OnAfterAssetDead( From, Event, To, asset, request )

            local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
            local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

              -- Get assignment.
            local assignment = warehouse.Khashuri:GetAssignment( request )

            logging('info', { 'warehouse.Didmukha:OnAfterAssetDead(From, Event, To, asset, request)' , 'assignment = ' .. assignment .. '  -  assetGroupName = ' .. asset.templatename } )

              -- Request resupply for dead asset from Batumi.

              warehouse.Zestafoni:AddRequest( warehouse.Satihari, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, nil, nil, nil, nil, "Resupply" )

              -- Send asset to Battle zone either now or when they arrive.
              warehouse.Satihari:AddRequest( warehouse.Satihari, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment )

        end -- end function

      end
      ----------------------------------------------- END blue Warehouse KHASHURI operations --------------------------------------------------------------------------------------------------------------------





































      ------------------------------------------------ blue Warehouse GORI operations ----------------------------------------------------------------------------------------------------------------------------
      local gori_wh_activation = true

      if gori_wh_activation then

        warehouse.Gori = WAREHOUSE:New( targetBAIStaticObj.Warehouse.blue.Gori[ 1 ], targetBAIStaticObj.Warehouse.blue.Gori[ 2 ] )  --Functional.Warehouse#WAREHOUSE

        warehouse.Gori:SetSpawnZone(ZONE:New("Gori WH Spawn Zone"))

        warehouse.Gori:Start()


        -- Gori e' una Farp warehouse quindi invia direttamente le risorse al fronte

        warehouse.Gori:AddAsset(               ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArmorA,          10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArmorB,          10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,          WAREHOUSE.Attribute.GROUND_ARTILLERY  )
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,          WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedA,     10,          WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedB,     10,          WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        warehouse.Gori:AddAsset(               ground_group_template_blue.mechanizedC,     10,          WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
        warehouse.Gori:AddAsset(               air_template_blue.CAS_MI_24V,               12,          WAREHOUSE.Attribute.AIR_ATTACKHELO       ) -- Attack
        warehouse.Gori:AddAsset(               air_template_blue.TRAN_UH_1H,                3,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 )  -- Transport
        warehouse.Gori:AddAsset(               air_template_blue.TRAN_UH_60A,               2,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000 ) -- Transport
        warehouse.Gori:AddAsset(               ground_group_template_blue.TroopTransport,   2,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        warehouse.Gori:AddAsset(               ground_group_template_blue.ArtilleryResupply,10,         WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
        warehouse.Gori:AddAsset(               air_template_blue.AFAC_Mi_24,                 4,         WAREHOUSE.Attribute.AIR_ATTACKHELO ) -- AFAC
        warehouse.Gori:AddAsset(               air_template_blue.AFAC_UH_1H,                 4,         WAREHOUSE.Attribute.AIR_ATTACKHELO ) -- AFAC
        warehouse.Gori:AddAsset(               air_template_blue.AFAC_SA342L,                4,         WAREHOUSE.Attribute.AIR_ATTACKHELO ) -- AFAC


        logging('info', { 'main' , 'addAsset Gori warehouse'} )


        -- GORI warehouse e' una frontline warehouse: invia gli asset sul campo con task assegnato. Didi e' rifornita da Biteta Warehouse


        logging('info', { 'main' , 'addrequest Gori warehouse'} )



        local GORI_Artillery_Ops = 'GORI_Artillery_Ops'
        local GORI_Artillery_Resupply = 'GORI_Artillery_Resupply'

        -- random targets
        local rndTrgGori = {


          -- [1] = number of mission
          -- [pos mission][1] = name of mission
          -- [pos mission][2] = name of mission
          -- [pos mission][3] = asset group name
          -- [pos mission][4] = quantity
          -- [pos mission][5] = target zone
          -- [pos mission][6] = type of mission

          mechanized = {

            {'TSKHINVALI_Attack_APC', WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC,       2 , redFrontZone.TSKHINVALI, 'enemy_attack'  }, -- 2    -- { <mission name>, { <parameter> }, { <parameter> } }
            {'TSKHINVALI_attack_2',   WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1 , redFrontZone.TSKHINVALI, 'enemy_attack'  }, -- 3
            {'DIDMUKHA_attack_1',     WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1 , redFrontZone.SATIHARI,   'enemy_attack'  }, -- 4
            {'SATIHARI_attack_1',     WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankA, 1 , redFrontZone.DIDMUKHA,   'enemy_attack'  }, -- 4
            {'SATIHARI_attack_2',     WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.antitankB, 1 , redFrontZone.DIDI_CUPTA, 'enemy_attack'  } -- 4
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          },

          helo = {

            {'AFAC_ZONE_Tskhunvali_Tkviavi',        WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_SA342L,  1, afacZone.Didmukha_Tsveri, 'AFAC_HELO'},
            {'AFAC_ZONE_Didmukha_Tsveri',           WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.AFAC_UH_1H,   1, afacZone.Tskhunvali_Tkviavi, 'AFAC_HELO'},
            {'ATTACK_ZONE_HELO_Didmukha_Tsveri',    WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_SA_342,   1, redFrontZone.DIDMUKHA, 'ATTACK_ZONE_HELO'},
            {'ATTACK_ZONE_HELO_Tskhunvali_Tkviavi', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Mi_8MTV2, 1, redFrontZone.TSKHINVALI, 'ATTACK_ZONE_HELO'}
            -- inserirne diverse (almeno 3-4 volte il numero delle richieste) per avere una diversificazione delle missioni nelle successive schedulazioni
          }
        } -- end rndTrgGori


        local gori_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- NOTA: lo scheduler di didi gestisce anche le missioni tipo ARTY

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local gori_sched = SCHEDULER:New( nil,

          function()

            local num_mission = 5 -- the number of mission request ( _addRequest() )
            local depart_time = defineRequestPosition( num_mission )
            local pos_mech = defineRequestPosition( #rndTrgGori.mechanized )
            local pos_helo = defineRequestPosition( #rndTrgGori.helo )
            local startReqTimeArtillery = 1 -- Arty groups have first activation
            local startReqTimeGround = startReqTimeArtillery + 420 -- Mech Groups are activated after 7'

            -- only for logging
            for i = 1, 5 do

              logging('finest', { 'gori scheduler function' , 'depart_time = [ ' .. i .. ' ] = ' .. depart_time[i] } )

              if i < #rndTrgGori.mechanized then

                logging('finest', { 'gori scheduler function' , 'pos_mech[ ' .. i .. '] =' .. pos_mech[i] } )
                logging('finest', { 'gori scheduler function' , '#rndTrgGori.mechanized = ' .. #rndTrgGori.mechanized .. '  - rndTrgGori.mechanized[ pos_mech[][ 2 ] = ' .. rndTrgGori.mechanized[ pos_mech[ i ] ][ 2 ] .. 'rndTrgGori.mechanized[ pos_mech[][ 3 ] = ' .. rndTrgGori.mechanized[ pos_mech[ i ] ][ 3 ] .. '  - rndTrgGori.mechanized[ pos_mech[][ 4 ] = ' .. rndTrgGori.mechanized[ pos_mech[ i ] ][ 4 ]  .. '  - rndTrgGori.mechanized[ pos_mech[][ 5 ] = ' .. rndTrgGori.mechanized[ pos_mech[ i ] ][ 5 ][2]} )

                end

            end

            -- artillery request
            warehouse.Gori:__AddRequest( startReqTimeArtillery, warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.ArtilleryResupply, 1, nil, nil, nil, GORI_Artillery_Resupply )
            warehouse.Gori:__AddRequest( startReqTimeArtillery + 120 , warehouse.Gori,  WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.ArtiAkatsia, 1, nil, nil, nil, GORI_Artillery_Ops)


            -- mech request
            -- riutilizzo gli stessi indici in quanto essendo ground veichle appaiono nella warehouse spawn zone diversa dal FARP degli helo
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[1] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.mechanized[ pos_mech[ 1 ] ][ 2 ], rndTrgGori.mechanized[ pos_mech[ 1 ] ][ 3 ], rndTrgGori.mechanized[ pos_mech[ 1 ] ][ 4 ], nil, nil, nil, rndTrgGori.mechanized[ pos_mech[ 1 ] ][ 1 ] )
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[2] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.mechanized[ pos_mech[ 2 ] ][ 2 ], rndTrgGori.mechanized[ pos_mech[ 2 ] ][ 3 ], rndTrgGori.mechanized[ pos_mech[ 2 ] ][ 4 ], nil, nil, nil, rndTrgGori.mechanized[ pos_mech[ 2 ] ][ 1 ] )
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[3] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.mechanized[ pos_mech[ 3 ] ][ 2 ], rndTrgGori.mechanized[ pos_mech[ 3 ] ][ 3 ], rndTrgGori.mechanized[ pos_mech[ 3 ] ][ 4 ], nil, nil, nil, rndTrgGori.mechanized[ pos_mech[ 3 ] ][ 1 ] )
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[4] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.mechanized[ pos_mech[ 4 ] ][ 2 ], rndTrgGori.mechanized[ pos_mech[ 4 ] ][ 3 ], rndTrgGori.mechanized[ pos_mech[ 4 ] ][ 4 ], nil, nil, nil, rndTrgGori.mechanized[ pos_mech[ 4 ] ][ 1 ] )
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[5] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.mechanized[ pos_mech[ 5 ] ][ 2 ], rndTrgGori.mechanized[ pos_mech[ 5 ] ][ 3 ], rndTrgGori.mechanized[ pos_mech[ 5 ] ][ 4 ], nil, nil, nil, rndTrgGori.mechanized[ pos_mech[ 5 ] ][ 1 ] )

            -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[1] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.helo[ pos_helo[ 1 ] ][ 2 ], rndTrgGori.helo[ pos_helo[ 1 ] ][ 3 ], rndTrgGori.helo[ pos_helo[ 1 ] ][ 4 ], nil, nil, nil, rndTrgGori.helo[ pos_helo[ 1 ] ][ 1 ])
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[2] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.helo[ pos_helo[ 2 ] ][ 2 ], rndTrgGori.helo[ pos_helo[ 2 ] ][ 3 ], rndTrgGori.helo[ pos_helo[ 2 ] ][ 4 ], nil, nil, nil, rndTrgGori.helo[ pos_helo[ 2 ] ][ 1 ])
            -- NON APPAIONO GLI AFAC HELO: sono apparsi cambiando AFAC in NOTHING nel template e cambiando in averege lo skill !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[3] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.helo[ pos_helo[ 3 ] ][ 2 ], rndTrgGori.helo[ pos_mech[ 3 ] ][ 3 ], rndTrgGori.helo[ pos_helo[ 3 ] ][ 4 ], nil, nil, nil, rndTrgGori.helo[ pos_helo[ 3 ] ][ 1 ])
            warehouse.Gori:__AddRequest( startReqTimeGround + depart_time[4] * waitReqTimeGround, warehouse.Gori,  rndTrgGori.helo[ pos_helo[ 4 ] ][ 2 ], rndTrgGori.helo[ pos_helo[ 4 ] ][ 3 ], rndTrgGori.helo[ pos_helo[ 4 ] ][ 4 ], nil, nil, nil, rndTrgGori.helo[ pos_helo[ 4 ] ][ 1 ])

            logging('finest', { 'gori scheduler function' , 'addRequest Gori warehouse'} )

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
          if assignment == rndTrgGori.mechanized[ 1 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.mechanized[ 1 ][ 5 ], rndTrgGori.mechanized[ 1 ][ 6 ] )  end
          if assignment == rndTrgGori.mechanized[ 2 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.mechanized[ 2 ][ 5 ], rndTrgGori.mechanized[ 2 ][ 6 ] )  end
          if assignment == rndTrgGori.mechanized[ 3 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.mechanized[ 3 ][ 5 ], rndTrgGori.mechanized[ 3 ][ 6 ] )  end
          if assignment == rndTrgGori.mechanized[ 4 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.mechanized[ 4 ][ 5 ], rndTrgGori.mechanized[ 4 ][ 6 ] )  end
          if assignment == rndTrgGori.mechanized[ 5 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.mechanized[ 5 ][ 5 ], rndTrgGori.mechanized[ 5 ][ 6 ] )  end
          -- launch mission functions: helo
          if assignment == rndTrgGori.helo[ 1 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.helo[ 1 ][ 5 ], rndTrgGori.helo[ 1 ][ 6 ] )  end
          if assignment == rndTrgGori.helo[ 2 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.helo[ 2 ][ 5 ], rndTrgGori.helo[ 2 ][ 6 ] )  end
          if assignment == rndTrgGori.helo[ 3 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.helo[ 3 ][ 5 ], rndTrgGori.helo[ 3 ][ 6 ] )  end
          if assignment == rndTrgGori.helo[ 4 ][ 1 ] then activeGO_TO_BATTLEWarehouse( groupset, rndTrgGori.helo[ 4 ][ 5 ], rndTrgGori.helo[ 4 ][ 6 ] )  end



          -- launch mission function: arty resupply
          if assignment == GORI_Artillery_Resupply then

            groupResupplySet = groupset
            -- controlla se redArtilleryTargetZone.BLUE_TARZ_TSVERI_5 e' coerente come posizione
            --rndTrgGori.artillery[ pos_arty[ 1 ] + 1 ][ 2 ]
            activeGO_TO_BATTLEWarehouse( groupset, redArtilleryTargetZone.BLUE_TARZ_TSVERI_5, 'artillery_resupply' )

          end


          -- launch mission function: arty
          if assignment == GORI_Artillery_Ops then

              nameArtyUnits = groupset:GetObjectNames()   -- "Artillery"
              -- nameRecceUnits = recceArtyGroup.getName()  -- "Recce"
              activateDetectionReport = true


              -- lista dei target e delle ammo
              param = {

                  listTargetInfo = {

                      --targetInfo.targetCoordinate,  targetInfo.priority, targetInfo.radiusTarget, targetInfo.num_shots, targetInfo.num_engagements, nil, targetInfo.weaponType

                      [1] = {
                        targetCoordinate = blueArtilleryTargetZone.RED_TARZ_DIDMUKHA_1[1]:GetRandomCoordinate(),
                        priority = 10,
                        radiusTarget = 500,
                        num_shots = 10,
                        num_engagements = 10,
                        weaponType = ARTY.WeaponType.Auto
                      },

                      [2] = {
                        targetCoordinate = blueArtilleryTargetZone.RED_TARZ_DIDMUKHA_2[1]:GetRandomCoordinate(),
                        priority = 50,
                        radiusTarget = 500,
                        num_shots = 10,
                        num_engagements = 7,
                        weaponType = ARTY.WeaponType.Auto
                      },

                      [3] = {
                        targetCoordinate = blueArtilleryTargetZone.RED_TARZ_DIDMUKHA_2[1]:GetRandomCoordinate(),
                        priority = 50,
                        radiusTarget = 500,
                        num_shots = 10,
                        num_engagements = 7,
                        weaponType = ARTY.WeaponType.Rockets -- devi caricare le munizioni (forse)
                      },

                      [4] = {
                        targetCoordinate = blueArtilleryTargetZone.RED_TARZ_DIDMUKHA_3[1]:GetRandomCoordinate(),
                        priority = 70,
                        radiusTarget = 500,
                        num_shots = 10,
                        num_engagements = 5,
                        weaponType = ARTY.WeaponType.IlluminationShells -- devi caricare le munizioni (forse)
                      },

                      [5] = {
                        targetCoordinate = blueArtilleryTargetZone.RED_TARZ_DIDMUKHA_3[1]:GetRandomCoordinate(),
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

              -- activeGO_TO_BATTLEWarehouse( groupset, redArtilleryTargetZone.BLUE_TARZ_TSVERI_5, 'artillery_firing', param )
              activeGO_TO_ARTYWarehouse( groupset, redArtilleryTargetZone.BLUE_TARZ_TSVERI_5, param, true, 70 )






          end



        end -- function warehouse.Gori:OnAfterSelfRequest( From,Event,To,groupset,request )


        -- Questa funzione gestisce le richieste di rifornmento verso la warehouse di biteta (link) quando gli asset vengono distrutti
        -- questa implememntazione garantisce un coinvolgimento costante di mezzi nella zona di combattimento fino a quando i rifornimenti sono erogati
        --
        function warehouse.Gori:OnAfterAssetDead( From, Event, To, asset, request )

          local asset = asset       --Functional.Warehouse#WAREHOUSE.Assetitem
          local request = request   --Functional.Warehouse#WAREHOUSE.Pendingitem

            -- Get assignment.
          local assignment = warehouse.Gori:GetAssignment( request )

          logging('info', { 'warehouse.Gori:OnAfterAssetDead(From, Event, To, asset, request)' , 'assignment = ' .. assignment .. '  - assetGroupName = ' .. asset.templatename } )

            -- Request resupply for dead asset from Batumi.

            warehouse.Soganiug:AddRequest( warehouse.Gori, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, nil, nil, nil, nil, "Resupply" )

            -- Send asset to Battle zone either now or when they arrive.
            warehouse.Gori:AddRequest( warehouse.Gori, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil, assignment )

        end --  warehouse.Gori:OnAfterAssetDead( From, Event, To, asset, request )

      end
      ----------------------------------------------- END blue Warehouse GORI operations -------------------------------------------------------------------------------------------------------------------------





















































      ------------------------------------------------------------ blue Warehouse TBILISI operations ----------------------------------------------------------------------------------------------------------------------------
      local tbilisi_wh_activation = true

      if tbilisi_wh_activation then -- true activate tbilisi wh operations

        -- Nota: Tipo Operazioni Bomber, Transport, EWR


        logging('info', { 'main' , 'init Warehouse TBILISI operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa

        -- INITIALIZE WAREHOUSE.
        warehouse.Tbilisi =   WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.blue.Tbilisi[ 1 ], targetBAIStaticObj.Warehouse_AB.blue.Tbilisi[ 2 ] )  --Functional.Warehouse#WAREHOUSE

        -- START WAREHOUSE
        warehouse.Tbilisi:Start()


        -- ADD ASSET
        -- Tbilisi e' una delle principali warehouse della Georgia, nei suoi depositi sono immagazzinate tutti gli asset che riforniscono le seguenti supply line
        -- Tbilisi - Gori
        -- Tbilisi e' utilizzato come aeroporto internazionale civile e non e' attaccato dalla forze sovietiche. Da Tbilisi decollano voli per trasporto merci e missioni di pinpoint strike e BAI.
        -- non decollano elicotteri


         --warehouse.Tbilisi:AddAsset(               air_template_blue.GCI_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.GCI_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.GCI_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.GCI_F_14A,                10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAP_L_39ZA,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_Su_17M4_Rocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_4E_Rocket,          10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_MI_24V,               10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_UH_1H,                10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_UH_60A,               10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_SA_342,               10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_L_39C_Rocket,         10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_L_39ZA_HRocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         --warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_F_4E_Rocket,          10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber CAS
         warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_AN_26,                 5,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000 ) -- Transport
         --warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_UH_1H,                10,        WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 ) -- Transport
         --warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_UH_60A,               10,        WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000  ) -- Transport
         --warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_MI_24,               10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500  ) -- Transport
         --warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_C_130,               10,         WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              9000  ) -- Transport
         warehouse.Tbilisi:AddAsset(               air_template_blue.TRAN_CH_47,               5,           WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700 ) -- Transport
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_SU_24_Bomb,           15,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_B_52H,                10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
         --warehouse.Tbilisi:AddAsset(               air_template_blue.B_1B_HBomb,                10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_F_4_E_Structure,      10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.BOM_B_1B,                 10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber
         warehouse.Tbilisi:AddAsset(               air_template_blue.CAS_MI_24V,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO  ) -- Heli CAS
         warehouse.Tbilisi:AddAsset(               air_template_blue.EWR_B_1B,                 2,           WAREHOUSE.Attribute.AIR_AWACS ) -- EWR
         --warehouse.Tbilisi:AddAsset(               air_template_blue.EWR_F_4,                 2,           WAREHOUSE.Attribute.AIR_AWACS ) -- EWR
         warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_L_39ZA,              7,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
         --warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_Mi_24,              7,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
         --warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_SA342L,              7,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
         --warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_UH_1H,              7,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC
         warehouse.Tbilisi:AddAsset(               air_template_blue.AFAC_AV_88,               2,           WAREHOUSE.Attribute.AIR_OTHER ) -- AFAC EXPERIMENTAL PROTOTYPE
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedA,     10,          WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedB,     10,          WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.mechanizedC,     10,          WAREHOUSE.Attribute.GROUND_APC    ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArmorA,          10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArmorB,          10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiAkatsia,     10,          WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiGwozdika,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiKatiusha,    10,          WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtiHeavyMortar, 10,          WAREHOUSE.Attribute.GROUND_ARTILLERY  ) -- Ground troops
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TransportA,      12,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TransportB,       6,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.TroopTransport,   4,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
         warehouse.Tbilisi:AddAsset(               ground_group_template_blue.Truck,           3,           WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
         --warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ArtilleryResupply,   4,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
         --warehouse.Tbilisi:AddAsset(               ground_group_template_blue.ResupplyTrucksColumn,   4,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport


         logging('info', { 'main' , 'addAsset Tbilisi warehouse'} )



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

            {'didi_pinpoint_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( 2, 5 ) , targetBAIZoneStructure.Blue_Didi[math.random( 1, #targetBAIZoneStructure.Blue_Didi)], "pinpoint_strike" },
            {'biteta_pinpoint_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( 2, 5 ) , targetBAIZoneStructure.Blue_Biteta[math.random( 1, #targetBAIZoneStructure.Blue_Biteta)], "pinpoint_strike" },
            {'kvem0_sba_pinpoint_1', WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( 2, 5 ) , targetBAIZoneStructure.Blue_Kvemo_Sba[math.random( 1, #targetBAIZoneStructure.Blue_Kvemo_Sba)], "pinpoint_strike" }
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

        local depart_time = defineRequestPosition(8)
        local tblisi_efficiency_influence = 1  -- Influence start_sched (from 1 to inf)

        -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
        local tblisi_sched = SCHEDULER:New( nil,

          function()

             -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
             warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[1] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Rocket, math.random( 2 , 5 ), nil, nil, nil, "BAI TARGET") -- BAI_ZONE1, BAI2_ZONE2, ...
             warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[2] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.BOM_F_4_E_Structure, math.random( 3 , 5 ), nil, nil, nil, "BAI STRUCTURE") -- BAI_ZONE1, BAI2_ZONE2, ...
             warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[3] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, math.random( 2 , 3 ), nil, nil, nil, "PATROL")
             warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[4] * waitReqTimeAir, warehouse.Tbilisi, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, math.random( 3 , 5 ), nil, nil, nil, "Bomb Airbase")
             warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[5] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_Mig_21Bis, math.random( 2 , 3 ), nil, nil, nil, "TRANSFER MIG 21")
             warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[6] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, math.random( 2 , 3 ), nil, nil, nil, "TRANSPORT")
             warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[7] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_CH_47, math.random( 2 , 3 ), nil, nil, nil, "TRANSPORT 2")
             warehouse.Tbilisi:__AddRequest( startReqTimeAir + depart_time[8] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, math.random( 2 , 4 ), nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED")
             logging('info', { 'main' , 'Tblisi scheduler - start time:' .. start_sched *  tblisi_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

          end, {}, start_sched *  tblisi_efficiency_influence, interval_sched, rand_sched

        ) -- end  tblisi_sched = SCHEDULER:New( nil, ..)



        -- Do something with the spawned aircraft.
        function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)



          logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'request.assignmet: ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })



            ------------------------------------------------------------------------------------------------------ assignment for BAI asset
          if request.assignment == "BAI TARGET" then

            -- le diverse opzioni disponibili per la scelta casuale della missione: nota puoi definire un vettore unico per tutte le missioni e utilizzarlo qui


            -- VEDI vettore parametri missione (sopra)
            -- @param param:  tabella conentente i seguenti parametri:
            -- @param groupset = il gruppo (asset) proveniente dalla warehouse
            -- @param typeOfBAI = tipo di BAI richiesta = 'bombing': bombarda il centro della engage zone, 'target': Attacca i target
            -- @param patrolZoneName = il nome della Zone assegnata per la patrol
            -- @param engageZoneName = il nome della Zone di ingaggio
            -- @param engageSpeed =  velocita di attacco
            -- @param engageAltitude = quota di attacco
            -- @param engageWeaponExpend = numero di weapon da sganciare
            -- @param engageAttackQty = numero attacchi
            -- @param engageDirection = direzione angolare di attacco
            -- @param targets = il wrapper:group dei target
            -- @param requestNumberKill = il numero di target distrutti utilizzato per valutare il completamento della missione
            -- @param patrolFloorAltitude = altezza minima  nella patrol zone
            -- @param patrolCeilAltitude = altezza massima nella patrol zone
            -- @param minPatrolSpeed = velocita minima di pattugliamento
            -- @param maxPatrolSpeed = velocita massima di pattugliamento
            -- @param timeToEngage = timer per l'ingaggiare
            -- @param timeToRTB = timer per l'RTB
            -- @param delay = ritardo di attesa per l'attivazione della missione


            speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI_target('aircraft')

            logging('finest', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB: ' .. speed_attack .. ' - ' .. altitude_attack .. ' - ' .. speed_patrol_min .. ' - ' .. altitude_patrol_min .. ' - ' .. speed_patrol_max .. ' - ' .. altitude_patrol_max .. ' - ' .. attack_angle  .. ' - ' .. num_attack ..  ' - ' .. num_weapon .. ' - ' .. time_to_engage .. ' - ' .. time_to_RTB } )


              ------------------------------------------------------------------------------------------------------ assignment for BAI asset

            -- dovrebbe essere calcolato in base alla quantità di unità contenuta nel target group (vedi funzione per avere numero unità)
            local request_kills = math.random( 2 , 4 )

            local param = {

              [1] = { 'Interdiction from Tbilisi', groupset, 'target', bluePatrolZone.BAI_Zone_Tbilisi[2], bluePatrolZone.BAI_Zone_Tbilisi[2], speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, redGroundGroup[2], request_kills, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 },
              [2] = { 'Interdiction from Tbilisi', groupset, 'target', bluePatrolZone.BAI_Zone_Tbilisi[2], bluePatrolZone.BAI_Zone_Tbilisi[2], speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, redGroundGroup[3], request_kills, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 },
              [3] = { 'Interdiction from Tbilisi', groupset, 'target', bluePatrolZone.BAI_Zone_Tbilisi[2], bluePatrolZone.BAI_Zone_Tbilisi[2], speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, redGroundGroup[5], request_kills, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 }

            }

            local pos = math.random( 1 , #param )


            logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB: ' .. speed_attack .. ' - ' .. altitude_attack .. ' - ' .. speed_patrol_min .. ' - ' .. altitude_patrol_min .. ' - ' .. speed_patrol_max .. ' - ' .. altitude_patrol_max .. ' - ' .. attack_angle .. ' - ' .. num_attack .. ' - ' .. num_weapon .. ' - ' .. time_to_engage .. ' - ' .. time_to_RTB } )
            logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )
            activeBAIWarehouseBisA( param[ pos ] )

          end -- end if



          if request.assignment == "BAI STRUCTURE" then


              local targets = {

                  targetBAIZoneStructure.Blue_Didi[ math.random( 1, #targetBAIZoneStructure.Blue_Didi) ],
                  targetBAIZoneStructure.Blue_Blue_Biteta[ math.random( 1, #targetBAIZoneStructure.Blue_Biteta) ],
                  targetBAIZoneStructure.Blue_Blue_Kvemo_Sba[ math.random( 1, #targetBAIZoneStructure.Blue_Kvemo_Sba) ]

              }


              --eliminare local speed, altitude = defineSpeedAndAltitude(400, 600, 3000, 7000)
              speed_attack, altitude_attack, speed_patrol_min, altitude_patrol_min, speed_patrol_max, altitude_patrol_max, attack_angle, num_attack, num_weapon, time_to_engage, time_to_RTB = calcParamForBAI_target('aircraft')

              local param = {

                { 'Interdiction from Tbilisi tris', groupset, 'bombing', targets[ 1 ], targets[ 1 ], speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 },
                { 'Interdiction from Tbilisi tris', groupset, 'bombing', targets[ 2 ], targets[ 2 ], speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 },
                { 'Interdiction from Tbilisi tris', groupset, 'bombing', targets[ 3 ], targets[ 3 ], speed_attack, altitude_attack, num_weapon, num_attack, attack_angle, altitude_patrol_min, altitude_patrol_max, speed_patrol_min, speed_patrol_max, time_to_engage, time_to_RTB, 1 }


              }

              local pos = math.random( 1 , #param )

              logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )
              activeBAIWarehouseBisA( param[ pos ] )

          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
          if request.assignment == "PATROL" then

          -- groupset, capZoneName, typeZoneName, engageRange, engageZone, typeEngageZoneName, patrolFloorAltitude, patrolCeilAltitude, minSpeedPatrol, maxSpeedPatrol, minSpeedEngage, maxSpeedEngage


            -- le diverse opzioni disponibili per la scelta casuale della missione
            local param = {
                -- modifica la activePATROLWarehouseA in modo da passare come parametro direttamente la ZONE già configurata
              [1] = { groupset, bluePatrolZone.BAI_Zone_Tbilisi[2], 'circle', 10000, nil, nil, 5000, 7000, 400, 500, 600, 800 },
              [2] = { groupset, bluePatrolZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, nil, 4000, 6000, 400, 550, 700, 1000 },
              [3] = { groupset, bluePatrolZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, nil, 3000, 5000, 400, 600, 800, 900 },
              [4] = { groupset, bluePatrolZone.BAI_Zone_Kutaisi[2], 'circle', 10000, blueFrontZone.GORI[2], 'circle', 5000, 8000, 400, 600, 800, 1000 }

            }

            local pos = math.random( 1 , #param )

            logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )
            activePATROLWarehouseA( param[ pos ] )


          end -- end if


          ------------------------------------------------------------------------------------------------------ assignment for PATROL MIG 21 asset
          if request.assignment == "PATROL MIG 21" then

            -- le diverse opzioni disponibili per la scelta casuale della missione
            local param = {

                [1] = { groupset, bluePatrolZone.BAI_Zone_Tbilisi[2], 'circle', 10000, nil, nil, 5000, 7000, 400, 500, 600, 800 },
                [2] = { groupset, bluePatrolZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, nil, 4000, 6000, 400, 550, 700, 1000 },
                [3] = { groupset, bluePatrolZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, nil, 3000, 5000, 400, 600, 800, 900 },
                [4] = { groupset, bluePatrolZone.BAI_Zone_Kutaisi[2], 'circle', 10000, blueFrontZone.GORI[2], 'circle', 5000, 8000, 400, 600, 800, 1000 }

            }

            local pos = math.random( 1 , #param )

            logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )
            activePATROLWarehouseA( param[ pos ] )


          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for GCI asset
          if request.assignment == "GCI" then

            -- inserire la funzione

            --local pos = math.random( 1 , #param )

            --logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

          end -- end if



          ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
          if request.assignment == "Bomb Airbase" then

              -- in linea di massima sarebbe opportuno effettuare una Fighter sweep prima del bombing

              local home = warehouse.Tbilisi
              local target = warehouse.Beslan

              'groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombQuantity, bombRunDistance, bombRunDirection, speedBombRun'

              local toTargetAltitude = math.random(5000, 7000)
              local toHomeAltitude = math.random(3000, 5000)
              local bombingDirection = math.random(270, 359)
              local bombingAltitude = math.random(4000, 6000)
              local bombQuantity = 2023
              local bombRunDistance = 20000
              local bombRunDirection = math.random(270, 359)
              local speedBombRun = math.random(400, 600)

              -- le diverse opzioni disponibili per la scelta casuale della missione
              local param = {

                [1] = { groupset, warehouse.Tbilisi, warehouse.Beslan, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun },
                [2] = { groupset, warehouse.Tbilisi, warehouse.Mozdok, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun },
                [3] = { groupset, warehouse.Tbilisi, warehouse.Mineralnye, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun },
                [4] = { groupset, warehouse.Tbilisi, warehouse.Nalchik, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombingAltitude, bombRunDistance, bombRunDirection, speedBombRun }

              }


              local pos = math.random( 1 , #param )

              logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )
              activeBOMBINGWarehouseA( param[ pos ] )

          end


          ------------------------------------------------------------------------------------------------------ assignment for TRANSPORT asset
          if request.assignment == "TRANSPORT" then

              -- da realizzare: ridefinire param creando percorsi diversi :


              -- le diverse opzioni disponibili per la scelta casuale della missione
              VehicleCargoSet = SET_CARGO:New():FilterTypes( "Vehicles" ):FilterStart()

              local param = {

                -- activeCARGOWarehouse( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet

                [1] = { groupset, AIRBASE.Caucasus.Tbilisi, AIRBASE.Caucasus.Kutaisi, 300, VehicleCargoSet },
                [2] = { groupset, AIRBASE.Caucasus.Tbilisi, AIRBASE.Caucasus.Kutaisi, 260, VehicleCargoSet },
                [3] = { groupset, AIRBASE.Caucasus.Tbilisi, AIRBASE.Caucasus.Batumi, 300, VehicleCargoSet },

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )
              activeCARGOWarehouse( param[ pos ] )

          end


          ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
          if request.assignment == "TRANSPORT 2" then

            -- da realizzare: ridefinire param creando percorsi diversi :


            -- le diverse opzioni disponibili per la scelta casuale della missione
            VehicleCargoSet = SET_CARGO:New():FilterTypes( "Vehicles" ):FilterStart()

            local param = {

              -- activeCARGOWarehouse( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet

              [1] = { groupset, AIRBASE.Caucasus.Tbilisi, AIRBASE.Caucasus.Kutaisi, 300, VehicleCargoSet },
              [2] = { groupset, AIRBASE.Caucasus.Tbilisi, AIRBASE.Caucasus.Kutaisi, 260, VehicleCargoSet },
              [3] = { groupset, AIRBASE.Caucasus.Tbilisi, AIRBASE.Caucasus.Batumi, 300, VehicleCargoSet },

            }

            local pos = math.random( 1 , #param )

            logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )
            activeCARGOWarehouse( param[ pos ] )

          end


          ------------------------------------------------------------------------------------------------------ assignment for RECON asset
          if request.assignment == "RECON " then

              -- da realizzare: ridefinire param creando percorsi diversi vedi funzioni random di assegnazione waypoint e
              local toTargetAltitude = math.random(5000, 7000)
              local toHomeAltitude = math.random(3000, 5000)
              local reconDirection = math.random(270, 359)
              local reconAltitude = math.random(4000, 6000)
              local reconRunDistance = 20000
              local reconRunDirection = math.random(270, 359)
              local speedReconRun = math.random(400, 600)


              -- le diverse opzioni disponibili per la scelta casuale della missione
              local param = {

                [1] = { groupset, warehouse.Tbilisi, warehouse.Beslan, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                [2] = { groupset, warehouse.Tbilisi, warehouse.Mozdok, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                [3] = { groupset, warehouse.Tbilisi, warehouse.Mineralnye, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },

              }

              local pos = math.random( 1 , #param )

              activeRECON(groupset, home, target, toTargetAltitude, toHomeAltitude, reconDirection, reconAltitude, reconRunDistance, reconRunDirection, speedReconRun )

              logging('info', { 'function warehouse.Tbilisi:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'tblisi scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )


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
      local vaziani_wh_activation = true

      if vaziani_wh_activation then

          warehouse.Vaziani = WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.blue.Vaziani[ 1 ], targetBAIStaticObj.Warehouse_AB.blue.Vaziani[ 2 ] )  --Functional.Warehouse#WAREHOUSE
          warehouse.Vaziani:Start()

          -- Vaziani e' un aeroporto vicino Tbilisi dove sono gestiti le risorse aeree fighter, reco, cas transport

          warehouse.Vaziani:AddAsset(              air_template_blue.GCI_Mig_21Bis,             5,          WAREHOUSE.Attribute.AIR_FIGHTER )
          warehouse.Vaziani:AddAsset(              air_template_blue.CAP_Mig_21Bis,            10,          WAREHOUSE.Attribute.AIR_FIGHTER )
          warehouse.Vaziani:AddAsset(              air_template_blue.CAP_L_39ZA,               10,          WAREHOUSE.Attribute.AIR_FIGHTER )
          warehouse.Vaziani:AddAsset(              air_template_blue.CAS_Su_17M4_Rocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber BAI
          warehouse.Vaziani:AddAsset(              air_template_blue.CAS_L_39C_Rocket,         10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber BAI
          warehouse.Vaziani:AddAsset(              air_template_blue.BOM_SU_24_Bomb,           10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber BAI
          warehouse.Vaziani:AddAsset(              air_template_blue.CAS_MI_24V,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO  ) -- Heli CAS
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_UH_1H,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 ) -- Transport
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_UH_60A,               5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000  ) -- Transport
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_CH_47,                3,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700 ) -- Transport
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_MI_24,                6,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              1500 ) -- Transport
          warehouse.Vaziani:AddAsset(              air_template_blue.TRAN_AN_26,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000)
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.TransportA,       6,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.TransportB,       4,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
          warehouse.Vaziani:AddAsset(              ground_group_template_blue.TroopTransport,  4,          WAREHOUSE.Attribute.GROUND_TRUCK  )-- Transport

          logging('info', { 'main' , 'addAsset Soganiug warehouse'} )
          -- Nota: Tipo Operazioni CAP, GCI, CAS, SEAD, RECO, EWR, Transport

          logging('info', { 'main' , 'init Warehouse Vaziani operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa

          warehouse.Vaziani =  WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.blue.Vaziani[ 1 ], targetBAIStaticObj.Warehouse_AB.blue.Vaziani[ 2 ] )  --Functional.Warehouse#WAREHOUSE
          -- Red targets at Vaziani X (late activated). for test
          local RedTargets = GROUP:FindByName("Russian Antitank Defence@Sathiari")



          -- blue Vaziani warehouse operations

          logging('info', { 'main' , 'addrequest Vaziani warehouse'} )

          local depart_time = defineRequestPosition(9)

          local vaziani_efficiency_influence = 1

          local vaziani_sched = SCHEDULER:New( nil,

              function()

                -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive

                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[1] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_Su_17M4_Rocket, 4, nil, nil, nil, "BAI TARGET") -- BAI_ZONE1, BAI2_ZONE2, ...
                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[2] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_MI_24V, 4, nil, nil, nil, "BAI TARGET BIS") -- BAI_ZONE1, BAI2_ZONE2, ...
                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[3] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_L_39ZA, 2, nil, nil, nil, "PATROL")
                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[4] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_Mig_21Bis, 2, nil, nil, nil, "PATROL MIG 21")
                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[5] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 3, nil, nil, nil, "Bomb Airbase")
                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[6] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_Mig_21Bis, 2, nil, nil, nil, "TRANSFER MIG 21")
                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[7] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, 2, nil, nil, nil, "TRANSPORT")
                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[8] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_YAK_40, 2, nil, nil, nil, "TRANSPORT 2")
                  warehouse.Vaziani:__AddRequest( startReqTimeAir + depart_time[9] * waitReqTimeAir, warehouse.Vaziani, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, 2, nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED")
                  logging('info', { 'main' , 'Vaziani scheduler - start time:' .. start_sched *  vaziani_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

              end, {}, start_sched * vaziani_efficiency_influence, interval_sched, rand_sched

          ) -- end  vaziani_sched = SCHEDULER:New( nil, ..)







          -- Do something with the spawned aircraft.
          function warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)

            logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'request.assignmet: ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })


            ------------------------------------------------------------------------------------------------------ assignment for BAI asset
            if request.assignment == "BAI TARGET" then

              -- le diverse opzioni disponibili per la scelta casuale della missione: nota puoi definire un vettore unico per tutte le missioni e utilizzarlo qui


              -- VEDI vettore parametri missione (sopra)
              -- @param param:  tabella conentente i seguenti parametri:
              -- @param groupset = il gruppo (asset) proveniente dalla warehouse
              -- @param typeOfBAI = tipo di BAI richiesta = 'bombing': bombarda il centro della engage zone, 'target': Attacca i target
              -- @param patrolZoneName = il nome della Zone assegnata per la patrol
              -- @param engageZoneName = il nome della Zone di ingaggio
              -- @param engageSpeed =  velocita di attacco
              -- @param engageAltitude = quota di attacco
              -- @param engageWeaponExpend = numero di weapon da sganciare
              -- @param engageAttackQty = numero attacchi
              -- @param engageDirection = direzione angolare di attacco
              -- @param targets = il wrapper:group dei target
              -- @param requestNumberKill = il numero di target distrutti utilizzato per valutare il completamento della missione
              -- @param patrolFloorAltitude = altezza minima  nella patrol zone
              -- @param patrolCeilAltitude = altezza massima nella patrol zone
              -- @param minPatrolSpeed = velocita minima di pattugliamento
              -- @param maxPatrolSpeed = velocita massima di pattugliamento
              -- @param timeToEngage = timer per l'ingaggiare
              -- @param timeToRTB = timer per l'RTB
              -- @param delay = ritardo di attesa per l'attivazione della missione
              local param = {

                [1] = { 'Interdiction from Vaziani', groupset, 'target', bluePatrolZone.BAI_Zone_Vaziani[2], bluePatrolZone.BAI_Zone_Vaziani[2], 400, 1000, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 },
                [2] = { 'Interdiction from Vaziani', groupset, 'target', bluePatrolZone.BAI_Zone_Vaziani[2], bluePatrolZone.BAI_Zone_Vaziani[2], 400, 1000, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 },
                [3] = { 'Interdiction from Vaziani', groupset, 'target', bluePatrolZone.BAI_Zone_Vaziani[2], bluePatrolZone.BAI_Zone_Vaziani[2], 400, 1000, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 }

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'vaziani scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

              activeBAIWarehouseBisA( param[ pos ] )

            end -- end if


            if request.assignment == "BAI TARGET BIS" then

              local speed, altitude = defineSpeedAndAltitude(500, 700, 3000, 5000)

                local param = {

                [1] = { 'Interdiction from Vaziani bis', groupset, 'target', bluePatrolZone.BAI_Zone_Vaziani[2], bluePatrolZone.BAI_Zone_Vaziani[2], speed, altitude, 4, 2, 300, RedTargets, 3, 500, 1000, 100, 200, 300, -3600, 1  },
                [2] = { 'Interdiction from Vaziani tris', groupset, 'target', bluePatrolZone.BAI_Zone_Vaziani[2], bluePatrolZone.BAI_Zone_Vaziani[2], speed, altitude, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 },

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'vaziani scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

              activeBAIWarehouseBisA( param[ pos ] )

            end -- end if



            ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
            if request.assignment == "PATROL" then


              -- le diverse opzioni disponibili per la scelta casuale della missione
              local param = {

                [1] = { groupset, bluePatrolZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
                [2] = { groupset, bluePatrolZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, nil, 1000, 2000, 500, 600, 600, 800 },
                [3] = { groupset, bluePatrolZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, nil, 1000, 2000, 500, 600, 600, 800 },

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'vaziani scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

              activePATROLWarehouseA( param[ pos ] )


            end -- end if


            ------------------------------------------------------------------------------------------------------ assignment for PATROL MIG 21 asset
            if request.assignment == "PATROL MIG 21" then

              -- le diverse opzioni disponibili per la scelta casuale della missione
              local param = {

                [1] = { groupset, bluePatrolZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
                [2] = { groupset, bluePatrolZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, nil, 1000, 2000, 500, 600, 600, 800 },
                [3] = { groupset, bluePatrolZone.BAI_Zone_Vaziani[2], 'circle', 10000, nil, nil, 1000, 2000, 500, 600, 600, 800 },

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'vaziani scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

              activePATROLWarehouseA( param[ pos ] )


            end -- end if



            ------------------------------------------------------------------------------------------------------ assignment for GCI asset
            if request.assignment == "GCI" then

              -- inserire la funzione

            end -- end if



            ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
            if request.assignment == "Bomb Airbase" then

              local home = warehouse.Vaziani
              local target = warehouse.Beslan

              -- groupset, home, target, toTargetAltitude, toHomeAltitude, bombingDirection, bombingAltitude, bombQuantity, bombRunDistance, bombRunDirection, speedBombRun
              -- le diverse opzioni disponibili per la scelta casuale della missione
              local param = {

                  [1] = { groupset, home, warehouse.Beslan, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                  [2] = { groupset, home, warehouse.Mozdok, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                  [3] = { groupset, home, warehouse.Mineralnye, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'vaziani scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

              activeBOMBINGWarehouseA( param[ pos ] )

            end -- end if


            ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
            if request.assignment == "TRANSPORT" then

                -- da realizzare: ridefinire param creando percorsi diversi :


                -- le diverse opzioni disponibili per la scelta casuale della missione
                VehicleCargoSet = SET_CARGO:New():FilterTypes( "VehiclesToCargo" ):FilterStart()

                local param = {

                  -- activeCARGOWarehouse( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet

                  [1] = { groupset, AIRBASE.Caucasus.Vaziani, AIRBASE.Caucasus.Kutaisi, 300, VehicleCargoSet },
                  [2] = { groupset, AIRBASE.Caucasus.Vaziani, AIRBASE.Caucasus.Kutaisi, 260, VehicleCargoSet },
                  [3] = { groupset, AIRBASE.Caucasus.Vaziani, AIRBASE.Caucasus.Batumi, 300, VehicleCargoSet },

                }

                local pos = math.random( 1 , #param )

                logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'vaziani scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

                activeCARGOWarehouse( param[ pos ] )

            end -- end if


            ------------------------------------------------------------------------------------------------------ assignment for RECON asset
            if request.assignment == "RECON " then

                -- da realizzare: ridefinire param creando percorsi diversi vedi funzioni random di assegnazione waypoint e


                -- le diverse opzioni disponibili per la scelta casuale della missione
                local param = {

                  [1] = { groupset, warehouse.Vaziani, warehouse.Beslan, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                  [2] = { groupset, warehouse.Vaziani, warehouse.Mozdok, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                  [3] = { groupset, warehouse.Vaziani, warehouse.Mineralnye, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },

                }

                local pos = math.random( 1 , #param )

                logging('info', { 'warehouse.Vaziani:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'vaziani scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )


                -- activeRECONWarehouseA( param[ pos ] )

            end -- end if









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

          end  --end  function warehouse.Kobuleti:OnAfterSelfRequest(From, Event, To, groupset, request)
      end
      ------------------------------------------------------------ END blue Warehouse Vaziani operations ----------------------------------------------------------------------------------------------------------------------------































































      -------------------------------------------------------------- blue Warehouse Soganiug operations ----------------------------------------------------------------------------------------------------------------------------
      local soganiug_wh_activation = true

      if soganiug_wh_activation then


          warehouse.Soganiug      =   WAREHOUSE:New( targetBAIStaticObj.Warehouse_AB.blue.Soganiug[ 1 ], targetBAIStaticObj.Warehouse_AB.blue.Soganiug[ 2 ] )  --Functional.Warehouse#WAREHOUSE
          warehouse.Soganiug:Start()


          -- Soganiug e' un aeroporto vicino Tbilisi dove sono gestiti le risorse aeree fighter, reco, cas, transport


          warehouse.Soganiug:AddAsset(              air_template_blue.GCI_Mig_21Bis,             5,          WAREHOUSE.Attribute.AIR_FIGHTER )
          warehouse.Soganiug:AddAsset(              air_template_blue.GCI_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER )
          warehouse.Soganiug:AddAsset(              air_template_blue.CAP_F_5,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER  ) -- Fighter
          warehouse.Soganiug:AddAsset(              air_template_blue.CAP_F_4,                  10,          WAREHOUSE.Attribute.AIR_FIGHTER )
          warehouse.Soganiug:AddAsset(              air_template_blue.GCI_F_4,                  5,           WAREHOUSE.Attribute.AIR_FIGHTER )
          warehouse.Soganiug:AddAsset(              air_template_blue.CAS_F_4E_Rocket,          10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber BAI
          warehouse.Soganiug:AddAsset(              air_template_blue.CAS_L_39C_Rocket,         10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber BAI
          warehouse.Soganiug:AddAsset(              air_template_blue.CAS_L_39ZA_HRocket,       10,          WAREHOUSE.Attribute.AIR_BOMBER ) -- Bomber BAI
          warehouse.Soganiug:AddAsset(              air_template_blue.CAS_UH_1H,                10,          WAREHOUSE.Attribute.AIR_ATTACKHELO  ) -- Heli CAS
          warehouse.Soganiug:AddAsset(              air_template_blue.CAS_UH_60A,               10,          WAREHOUSE.Attribute.AIR_ATTACKHELO  ) -- Heli CAS
          warehouse.Soganiug:AddAsset(              air_template_blue.TRAN_AN_26,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,             9000)
          warehouse.Soganiug:AddAsset(              air_template_blue.TRAN_UH_1H,                5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              2000 ) -- Transport
          warehouse.Soganiug:AddAsset(              air_template_blue.TRAN_UH_60A,               5,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              4000  ) -- Transport
          warehouse.Soganiug:AddAsset(              air_template_blue.TRAN_CH_47,                3,          WAREHOUSE.Attribute.AIR_TRANSPORTHELO,              12700 ) -- Transport
          warehouse.Soganiug:AddAsset(              air_template_blue.TRAN_C_130,                6,          WAREHOUSE.Attribute.AIR_TRANSPORTPLANE,              9000 ) -- Transport
          warehouse.Soganiug:AddAsset(              ground_group_template_blue.antitankA,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
          warehouse.Soganiug:AddAsset(              ground_group_template_blue.antitankB,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
          warehouse.Soganiug:AddAsset(              ground_group_template_blue.antitankC,       10,          WAREHOUSE.Attribute.GROUND_TANK  ) -- Ground troops
          warehouse.Soganiug:AddAsset(              ground_group_template_blue.TransportA,       6,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
          warehouse.Soganiug:AddAsset(              ground_group_template_blue.TransportB,       4,          WAREHOUSE.Attribute.GROUND_TRUCK ) -- Transport
          warehouse.Soganiug:AddAsset(              ground_group_template_blue.TroopTransport,   4,          WAREHOUSE.Attribute.GROUND_TRUCK  )-- Transport

          logging('info', { 'main' , 'addAsset Soganiug warehouse'} )


          -- Nota: Tipo Operazioni CAP, GCI, CAS, SEAD, RECO, EWR, Transport


          logging('info', { 'main' , 'init Warehouse Soganiug operations' } ) -- verifica se c'e' una istruzione che consente di inviare tutti gli elementi di blueFrontZone come stringa

          -- Red targets at Soganiug X (late activated). for test
          local RedTargets=GROUP:FindByName("Russian Antitank Defence@Sathiari")


          -- blue Soganiug warehouse operations

          logging('info', { 'main' , 'addrequest Soganiug warehouse'} )


          local depart_time = defineRequestPosition(9) -- list of position

          local soganiug_efficiency_influence = 1 -- Influence start_sched (from 1 to inf)

          -- Mission schedulator: position here the warehouse auto request for mission. The mission start list will be random
          local soganiug_sched = SCHEDULER:New( nil,

            function()
              -- nelle request la selezione random esclusiva (utilizzando defineRequestPosition) dei target in modo da avere target diversi per schedulazioni successive
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[1] * waitReqTimeAir, warehouse.Soganiug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_F_4E_Rocket, 4, nil, nil, nil, "BAI TARGET") -- BAI_ZONE1, BAI2_ZONE2, ...
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[2] * waitReqTimeAir, warehouse.Soganiug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAS_UH_1H, 4, nil, nil, nil, "BAI TARGET BIS") -- BAI_ZONE1, BAI2_ZONE2, ...
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[3] * waitReqTimeAir, warehouse.Soganiug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, 2, nil, nil, nil, "PATROL")
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[4] * waitReqTimeAir, warehouse.Soganiug, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.AIR_BOMBER, 3, nil, nil, nil, "Bomb Airbase")
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[5] * waitReqTimeAir, warehouse.Soganiug, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_4, 2, nil, nil, nil, "PATROL F4")
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[6] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.CAP_F_5, 2, nil, nil, nil, "TRANSFER MIG 21")
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[7] * waitReqTimeAir, warehouse.Kutaisi, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_AN_26, 2, nil, nil, nil, "TRANSPORT")
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[8] * waitReqTimeAir, warehouse.Gori, WAREHOUSE.Descriptor.GROUPNAME, air_template_blue.TRAN_UH_60A, 2, nil, nil, nil, "TRANSPORT 2")
              warehouse.Soganiug:__AddRequest( startReqTimeAir + depart_time[9] * waitReqTimeAir, warehouse.Soganiug, WAREHOUSE.Descriptor.GROUPNAME, ground_group_template_blue.mechanizedA, 2, nil, nil, nil, "TRANSFER MECHANIZED SELFPROPELLED")
              logging('info', { 'main' , 'Soganiug scheduler - start time:' .. start_sched *  soganiug_efficiency_influence .. ' ; scheduling time: ' .. interval_sched * (1-rand_sched) .. ' - ' .. interval_sched * (1+rand_sched)} )

            end, {}, start_sched *  soganiug_efficiency_influence, interval_sched, rand_sched

          )




          -- Do something with the spawned aircraft.
          function warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)


            logging('info', { 'warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'request.assignmet: ' .. request.assignment .. ' - groupset name: ' .. groupset:GetObjectNames()  })

            ------------------------------------------------------------------------------------------------------ assignment for BAI asset
            if request.assignment == "BAI TARGET" then

              -- le diverse opzioni disponibili per la scelta casuale della missione: nota puoi definire un vettore unico per tutte le missioni e utilizzarlo qui


              -- VEDI vettore parametri missione (sopra)
              -- @param param:  tabella conentente i seguenti parametri:
              -- @param groupset = il gruppo (asset) proveniente dalla warehouse
              -- @param typeOfBAI = tipo di BAI richiesta = 'bombing': bombarda il centro della engage zone, 'target': Attacca i target
              -- @param patrolZoneName = il nome della Zone assegnata per la patrol
              -- @param engageZoneName = il nome della Zone di ingaggio
              -- @param engageSpeed =  velocita di attacco
              -- @param engageAltitude = quota di attacco
              -- @param engageWeaponExpend = numero di weapon da sganciare
              -- @param engageAttackQty = numero attacchi
              -- @param engageDirection = direzione angolare di attacco
              -- @param targets = il wrapper:group dei target
              -- @param requestNumberKill = il numero di target distrutti utilizzato per valutare il completamento della missione
              -- @param patrolFloorAltitude = altezza minima  nella patrol zone
              -- @param patrolCeilAltitude = altezza massima nella patrol zone
              -- @param minPatrolSpeed = velocita minima di pattugliamento
              -- @param maxPatrolSpeed = velocita massima di pattugliamento
              -- @param timeToEngage = timer per l'ingaggiare
              -- @param timeToRTB = timer per l'RTB
              -- @param delay = ritardo di attesa per l'attivazione della missione
              local param = {

                [1] = { 'Interdiction from Soganiug', groupset, 'target', redFrontZone.TSKHINVALI[2], redFrontZone.TSKHINVALI[2], 400, 1000, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 },
                [2] = { 'Interdiction from Soganiug', groupset, 'target', redFrontZone.SATIHARI[2], redFrontZone.SATIHARI[2], 400, 1000, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 },
                [3] = { 'Interdiction from Soganiug', groupset, 'target', redFrontZone.DIDI_CUPTA[2], redFrontZone.DIDI_CUPTA[2], 400, 1000, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 }

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Soganiug scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

              activeBAIWarehouseBisA( param[ pos ] )

            end -- end if


            if request.assignment == "BAI TARGET BIS" then

                local speed, altitude = defineSpeedAndAltitude(500, 700, 3000, 5000)

                local param = {

                [1] = { 'Interdiction from Soganiug bis', groupset, 'target', blueFrontZone.BAI_Zone_Soganiug[2], blueFrontZone.BAI_Zone_Soganiug[2], speed, altitude, 4, 2, 300, RedTargets, 3, 500, 1000, 100, 200, 300, -3600, 1  },
                [2] = { 'Interdiction from Soganiug tris', groupset, 'target', blueFrontZone.BAI_Zone_Soganiug[2], blueFrontZone.BAI_Zone_Soganiug[2], speed, altitude, 4, 2, 300, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 },

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Soganiug scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 2 ]:GetObjectNames() } )

              activeBAIWarehouseBisA( param[ pos ] )

            end -- end if



            ------------------------------------------------------------------------------------------------------ assignment for PATROL asset
            if request.assignment == "PATROL" then


              -- le diverse opzioni disponibili per la scelta casuale della missione
              local param = {

                [1] = { groupset, blueFrontZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
                [2] = { groupset, blueFrontZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, nil, 1000, 2000, 500, 600, 600, 800 },
                [3] = { groupset, blueFrontZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, nil, 1000, 2000, 500, 600, 600, 800 },

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Soganiug scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

              activePATROLWarehouseA( param[ pos ] )


            end -- end if


            ------------------------------------------------------------------------------------------------------ assignment for PATROL MIG 21 asset
            if request.assignment == "PATROL MIG 21" then

              -- le diverse opzioni disponibili per la scelta casuale della missione
              local param = {

                [1] = { groupset, blueFrontZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, nil, 2000, 3000, 500, 600, 600, 800 },
                [2] = { groupset, blueFrontZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, nil, 1000, 2000, 500, 600, 600, 800 },
                [3] = { groupset, blueFrontZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, nil, 1000, 2000, 500, 600, 600, 800 },

              }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Soganiug scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

              activePATROLWarehouseA( param[ pos ] )


            end -- end if



            ------------------------------------------------------------------------------------------------------ assignment for GCI asset
            if request.assignment == "GCI" then

              -- inserire la funzione

            end -- end if



            ------------------------------------------------------------------------------------------------------ assignment for STRATEGIC BOMBING asset
            if request.assignment == "Bomb Airbase" then

                local home = warehouse.Soganiug
                local target = warehouse.Beslan

                -- le diverse opzioni disponibili per la scelta casuale della missione
                local param = {

                  [1] = { groupset, warehouse.Soganiug, warehouse.Beslan, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                  [2] = { groupset, warehouse.Soganiug, warehouse.Mozdok, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                  [3] = { groupset, warehouse.Soganiug, warehouse.Mineralnye, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },

                }

              local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Soganiug scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

              activeBOMBINGWarehouseA( param[ pos ] )

            end


            ------------------------------------------------------------------------------------------------------ assignment for TRASNPORT asset
            if request.assignment == "TRANSPORT" then

                -- da realizzare: ridefinire param creando percorsi diversi :


                -- le diverse opzioni disponibili per la scelta casuale della missione
                VehicleCargoSet = SET_CARGO:New():FilterTypes( "VehiclesToCargo" ):FilterStart()

                local param = {

                  -- activeCARGOWarehouse( groupPlaneSet, pickupAirbaseName, deployAirbaseName, speed, groupCargoSet

                  [1] = { groupset, AIRBASE.Caucasus.Soganiug, AIRBASE.Caucasus.Kutaisi, 300, VehicleCargoSet },
                  [2] = { groupset, AIRBASE.Caucasus.Soganiug, AIRBASE.Caucasus.Kutaisi, 260, VehicleCargoSet },
                  [3] = { groupset, AIRBASE.Caucasus.Soganiug, AIRBASE.Caucasus.Batumi, 300, VehicleCargoSet },

                }

                local pos = math.random( 1 , #param )

                logging('info', { 'warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Soganiug scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

                activeCARGOWarehouse( param[ pos ] )

            end


            ------------------------------------------------------------------------------------------------------ assignment for RECON asset
            if request.assignment == "RECON " then

                -- da realizzare: ridefinire param creando percorsi diversi vedi funzioni random di assegnazione waypoint e


                -- le diverse opzioni disponibili per la scelta casuale della missione
                local param = {

                  [1] = { groupset, warehouse.Soganiug, warehouse.Beslan, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                  [2] = { groupset, warehouse.Soganiug, warehouse.Mozdok, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },
                  [3] = { groupset, warehouse.Soganiug, warehouse.Mineralnye, 5000, 3000, 330, 5000, 2023, 20000, 330, 400 },

                }

                local pos = math.random( 1 , #param )

              logging('info', { 'warehouse.Soganiug:OnAfterSelfRequest(From,Event,To,groupset,request)' , 'Soganiug scheduled mission number: ' .. pos .. ' - groupset name: ' .. param[ pos ][ 1 ]:GetObjectNames() } )

                -- activeRECONWarehouseA( param[ pos ] )

            end









            --- When the helo is out of fuel, it will return to the carrier and should be delivered.
            function warehouse.Soganiug:OnAfterDelivered(From,Event,To,request)

                  -- le diverse opzioni disponibili per la scelta casuale della missione
                  local request=request   --Functional.Warehouse#WAREHOUSE.Pendingitem

                  logging('info', { 'warehouse.Soganiug:OnAfterDelivered(From,Event,To,request)' , 'request.assignment: ' .. request.assignment })
                --[[
                  -- manca il groupset
                  -- So we start another request.
                  if request.assignment=="PATROL" then

                    logging('info', { 'warehouse.Soganiug:OnAfterDelivered(From,Event,To,request)' , 'Soganiug scheduled PATROL mission' })
                    activeCAPWarehouse(groupset, redFrontZone.BAI_Zone_Soganiug[2], 'circle', 10000, nil, 2000, 3000, 500, 600, 600, 800 )

                  end

                  if request.assignment=="BAI TARGET" then

                    logging('info', { 'warehouse.Soganiug:OnAfterDelivered(From,Event,To,request)' , 'Soganiug scheduled BAI TARGET mission' })
                    activeBAIWarehouseT('Interdiction from Soganiug', groupset, 'target', redFrontZone.BAI_Zone_Soganiug[2], redFrontZone.BAI_Zone_Soganiug[2], 400, 1000, 4, 2, RedTargets, 3, 500, 1000, 500, 600, 300, -3600, 1 )

                  end -- end if
                  ]]

            end -- end function warehouse.Stennis:OnAfterDelivered(From,Event,To,request)

          end  --end  function warehouse.Kobuleti:OnAfterSelfRequest(From, Event, To, groupset, request)
      end
      -------------------------------------------------------------END blue Soganiug operations ----------------------------------------------------------------------------------------------------------------------------




























































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

    local activeBlueBelancer = true

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



      -- We setup an array to store all the AI_BALANCERS that are going to be created. Basically one
      -- per airbase. We loop through and create an AI_BALANCER as well as a separate OnAfterSpawned
      -- function for each. The Patrol Zone is randomized in the first parameter to AI_PATROL_ZONE:New()
      -- call. This is done for each of the AI_BALANCERS. To add more patrol zones, just define them in
      -- the mission editor and add into the array above. Code here does not need to be changed. The
      -- table.getn(RedPatrolZone) gets the number of elements in the RedPatrolZone array so that all
      -- of them are included to pick randomly.


      RU_AI_Balancer = {}

      for i = 1, 11 do

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

      for i = 1, 10 do

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













    --[[

    Risorse aeree
    --
    -- deve essere inizializzato in base alle unita definite come template. Quindi
    -- ricerca delle unita con prefisso SQ NO solo in runtime
    --

    red

    MIG-21Bis, fighter, 5.4k, 1.8k
    MIG-23MLD, fighter, 10.4k, 1.9k
    MIG-25PD, interceptor, 20 k, 1.2k
    MIG-27K, attack , 22k, 1.9k
    SU-17M4, attack, 10.6 k, 1.7k
    SU-24, bomber, 22k, 1.2k
    TU-142, bomber, 96k, 10.5k
    TU-160, bomber, ???
    TU-22, bomber, 50k, 5.1k
    TU-95, bomber, 96k, 6.4k
    MIG-25RTB, reco, 20k, 1.9k
    SU-24MR, reco, 22.3k, 1.2k
    L-39C, trainer, 3.4k, 1.6k
    L-39ZA, trainer, 3.4k, 1.6k
    AN-26, trasporto, 15.8k, 2.6k
    IL-76MD, trasporto, 100k, 7.3k
    YAK-40, trasporto, 9.4k, 2.5k

    MI-24V, attacco, 8.2k, 0.5k


    blue

    F-5, Fighter, 4.3k, 2k
    F-4, Fighter, 24k, 2.6k
    A-10 A ???
    S-3??
    B-1B, bomber, 87k, 12k
    B-52H, bomber, 120k, 16k


    UH-1H, trasporto,.3k, 0.4k
    UH-60A, trasporto, 5.7k, 0.6k

    ]]--




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









    -- RED FORCE CAP-GCI

    -- NOTA: UTILIZZATO SOLO PER LE CAP E GCI AI



    -- Nota le GCI sono attivate quando non c'e' nessuno aereo alleato disponibile per l'ingaggio dell'incursore
    --
    -- Il dispatcher() imposta l'intercettazione dalla base pi� vicina distante meno del gci_radius. Credo che la base pi� vicina dovrebbe essere scelta da quelle abilitate trmite assign_gci
    --
    -- Credo che per poter utilizzare esclusivamente le gci suad devi dedicare a loro l'uso di un aeroporto: quindi scegli per le cap gli aeroporti vicino al fronte, mentre quelli lontani per i gci






    -- Setup generale

    --- detection red: e' la distanza massima di valutazione se due o piu' aerei appartengono ad uno stesso gruppo (30km x modern, 10 km per ww2)
    -- i distanza impostata a 30 km
    local Detection_Red = detection(prefix_detector.red, 30000)

    --- A2ADispatcher red:
    -- distanza massima di attivazione GCI = 70 km (rispetto le aribase),
    -- distanza massima autorizzazione all'ingaggio per aerei alleati nelle vicinanze
    -- true/false: view tactital display
    local A2ADispatcher_Red = dispatcher(Detection_Red, 70000, 40000, false)



    -- Setup Red CAP e GCI

    local num_group = 2
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


    -- 12 Fighter Mig 21 CAP Only
    -- funziona
    assign_squadron_at_airbase ('Mozdok', airbase.Mozdok, air_template_red.CAP_Mig_21Bis, Mozdok_Num_Air, A2ADispatcher_Red)

    -- assign mission cap for Mozdok Squadron
    assign_cap ( cap_zone_db_red[1], 'Mozdok', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Red )





    -- assign squadron at airbase Beslan
    -- 6 interceptor Mig 21 , no cap
    local Beslan_Num_Air = 5

    -- funziona
    assign_squadron_at_airbase ('Beslan', AIRBASE.Caucasus.Beslan, air_template_red.GCI_Mig_21Bis, Beslan_Num_Air, A2ADispatcher_Red)

    -- assign CGI mission for Beslan Squadron:
    assign_gci('Beslan', 800, 1200, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Red)



    -- assign squadron at airbase Nalchik
    -- 3 interceptor Mig 25 , no cap
    local Nalchik_Num_Air = 3

    -- funziona
    assign_squadron_at_airbase ('Nalchik', airbase.Nalchik, air_template_red.GCI_Mig_25PD, Nalchik_Num_Air, A2ADispatcher_Red)

    -- assign CGI mission for Nalchik Squadron:
    assign_gci('Nalchik', 800, 1200, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Red)



    -- assign squadron at airbase Mineralnye
    -- 12 Fighter Mig 23 CAP Only
    local Mineralnye_Num_Air = 12


    -- funziona
    assign_squadron_at_airbase ('Mineralnye', airbase.Mineralnye, air_template_red.CAP_Mig_23MLD, Mineralnye_Num_Air, A2ADispatcher_Red)

    -- assign mission cap for Mineralnye Squadron
    assign_cap ( cap_zone_db_red[2], 'Mineralnye', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Red )








    -- END RED FORCE CAP-GCI




    -- BLUE FORCE CAP-GCI (OK)

    -- Kutaisi


    -- Setup generale

    --- detection blue: e' la distanza massima di rilevamento dei radar
    -- i distanza impostata a 100 km
    local Detection_Blue = detection(prefix_detector.blue, 30000)

    --- A2ADispatcher blue:
    -- distanza massima di attivazione GCI = 70 km (rispetto le aribase),
    -- distanza massima autorizzazione all'ingaggio per aerei alleati nelle vicinanze
    -- true/false: view tactital display
    local A2ADispatcher_Blue = dispatcher(Detection_Blue, 70000, 40000, false)



    -- Setup cap e gci

    -- CAP and GCI

    -- assign squadron at airbase
    -- 6 Mig 21 GCI  @ Kutaisi
    local Kutaisi_Num_Air = 6

    -- funziona
    assign_squadron_at_airbase ('Kutaisi', airbase.Kutaisi, air_template_blue.GCI_Mig_21Bis, Kutaisi_Num_Air, A2ADispatcher_Blue)

    -- assign CGI mission for Squadron:
    assign_gci('Kutaisi', 800, 1200, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue)



    -- assign squadron at airbase
    -- 12 F-4 CAP @ Kutaisi zone
    local Senaki_Num_Air = 12

    -- funziona
    assign_squadron_at_airbase ('Senaki', airbase.Senaki_Kolkhi, air_template_blue.CAP_F_4, Senaki_Num_Air, A2ADispatcher_Blue)

    -- assign mission cap for Squadron
    assign_cap ( cap_zone_db_blue[2], 'Senaki', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue )



    -- assign squadron at airbase
    -- 12 Mig-21 CAP @ sukumi
    local Sukhumi_Num_Air = 12

    -- funziona
    assign_squadron_at_airbase ('Sukhumi', airbase.Sukhumi_Babushara, air_template_blue.CAP_Mig_21Bis, Sukhumi_Num_Air, A2ADispatcher_Blue)

    -- assign mission cap for Squadron
    assign_cap ( cap_zone_db_blue[3], 'Sukhumi', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue )



    -- assign squadron at airbase
    -- 12 La-39 CAP sukumi @ sochi-gudauta
    local Gudauta_Num_Air = 12

    -- funziona
    assign_squadron_at_airbase ('Gudauta', airbase.Gudauta, air_template_blue.CAP_L_39ZA, Gudauta_Num_Air, A2ADispatcher_Blue)

    -- assign mission cap for Squadron
    assign_cap ( cap_zone_db_blue[4], 'Gudauta', min_alt, max_alt, min_speed_patrol, max_speed_patrol, min_speed_engage, max_speed_engage, num_group, min_time_cap, max_time_cap, 1, AI_A2A_DISPATCHER.Takeoff.Cold, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue )





    -- assign squadron at airbase
    -- 3 F-14A  GCI sukumi @ sochi-gudauta
    local Sochi_Num_Air = 3

    assign_squadron_at_airbase ('Sochi', airbase.Sochi_Adler, air_template_blue.GCI_F_14A, Sochi_Num_Air, A2ADispatcher_Blue)

    -- assign CGI mission for Squadron:
    assign_gci('Sochi', 800, 1200, AI_A2A_DISPATCHER.Takeoff.Hot, AI_A2A_DISPATCHER.Landing.AtRunway, A2ADispatcher_Blue)








    -- Spawn aircraft from template  IMPORTANTE
    -- Da utilizzare per generare traffico o voli generici




    --[[

    local Spawn_GE_Recognition_Flight =
      { air_template_blue.REC_L_39C,
        air_template_blue.REC_F_4,
        air_template_blue.REC_F_4,
        air_template_blue.REC_L_39C
      }

    local Spawn_BLUE_Air_Recon = genericSpawnSimple('Georgian Reco Flight@Tskhinvali', 15, 40, Spawn_GE_Recognition_Flight, 1, 1, 2000, 3000, 1200, 0.5)


    local Spawn_GE_Transpor_Flight =
      { air_template_blue.TRAN_AN_26,
        air_template_blue.TRAN_YAK_40
      }

    local Spawn_BLUE_Air_Recon = genericSpawnSimple('Georgian Transport Flight', 15, 40, Spawn_GE_Transpor_Flight, 1, 1, 1000, 2000, 900, 0.7)

    ]]

          -- CAS MISSION
      ---
      -- Name: CAS-111 - Multiple CAS in 1 Radius Zone by Helicopter and AirPlane Groups
      -- Author: FlightControl
      -- Date Created: 6 February 2017
      --
      -- # Situation:
      --
      -- A group of 2 Mi-24V and 2 Su-17 are patrolling north in two engage zone for 5 minutes.
      -- After 5 minutes, the command center orders the groups to engage the zone and execute a CAS.

      -- Create a local variable (in this case called CASEngagementZone) and
      -- using the ZONE function find the pre-defined zone called "Engagement Zone"
      -- currently on the map and assign it to this variable
      --CASEngagementTkviavi = ZONE:New( "TSVERI" )

      --[[


      -- Prova a generarare il group mediante uno spawn riferito ad un template:
      --

      Spawn_Russian_CAS_Flight =
        { air_template_blue[40],
          air_template_blue[41],
          air_template_blue[42],
          air_template_blue[43]
        }


      Spawn_Red_CAS_Missione = SPAWN
        :New( 'Russian CAS Flight@Tskhinvali' )  -- name del percorso definito dal Ka50
        :InitLimit( 15, 40 ) -- limiti massimi sul numero delle unita' e dei gruppi attivabili contemporaneamente
        :InitRandomizeTemplate( Spawn_GE_Recognition_Flight ) -- scegli a caso dalla tabella dei template delle  troops di sopra
        :InitRandomizeRoute( 1, 1, 2000, 3000 ) -- variazione random della rotta: wp iniziale, posizione del wp finale partendo dall'ultimo wp, variazione in m possibile, altezza da aggiungere a quella prevista
        --:InitArray( 349, 30, 20, 6 * 20 ) -- visualizza i gruppi prima dello spawn: The angle in degrees how the groups and each unit of the group will be positioned, num groups on x, spazio tra groups on x, spazio tra groups on y,
        :SpawnScheduled( 1200, 0.5 )  -- lo spawn e' schedulato per avvenire ogni 60 secondi con una variazione x% calcolata come time*(1-x%/2) - time*(1+x%/2):  600-1800 s


      e poi continui con sotto

      basta questo

      local CSAR_Spawn = SPAWN:NewWithFromTemplate( Template, "CSAR", "Pilot" )

      ]]--




      -- Create a local variables (in this case called CASPlane and CASHelicopters) and
      -- using the GROUP function find the aircraft group called "Plane" and "Helicopter" and assign to these variables
      --CASPlane = GROUP:FindByName( "Russian CAS Mission Su_17" )
      --CASHelicopter = GROUP:FindByName( "Russian Mission CAS Mi_24V" )

      -- MODIFICA
        --[[
      local Spawn_Russian_CAS_Flight_Aircraft =
        {

          air_template_red.CAS_Su_17M4_Rocket,
          air_template_red.CAS_L_39C_Rocket,
          air_template_red.CAS_Mig_27K_Bomb

        }

      local Spawn_Russian_CAS_Flight_Heli =
        {

          air_template_red.CAS_MI_24V

        }


      -- NON FUNZIONA
      --local Spawn_CASPlane = SPAWN:NewWithFromTemplate( Spawn_Russian_CAS_Flight, "CAS Aircraft@DIDMUKHA")
      --local Spawn_CASHelicopter = SPAWN:NewWithFromTemplate( air_template_red.CAS_Su_17M4_Rocket, "CAS Heli@DIDMUKHA")
      --CASPlane = GROUP:FindByName( "CAS Aircraft@DIDMUKHA" )
      --CASHelicopter = GROUP:FindByName( "CAS Heli@DIDMUKHA" )


      local route = 'Route for Russian CAS Aircraft@DIDMUKHA'
      local max_contemp_units =  8
      local max_contemp_groups = 4
      local templateList = Spawn_Russian_CAS_Flight_Aircraft
      local route_wp_start = 1
      local route_wp_end = 1
      local route_range = 300
      local route_altitude = 500
      local scheduled_time = 1200
      local scheduled_var = 0.7
      local patrolNameZone = "DIDMUKHA"
      local patrolSpeedMin = "TSKHINVALI"
      local patrolMaxSPeed = 400
      local minAltitude = 500
      local maxAltitude = 1000
      local casNameZone = 2000
      local timeOfEngage = 240
      local timeOfStopEngage = 720
      local engageSpeed = 400
      local engageAltitude = 500
      local nameOfTarget = "USA ARMOR SQUAD"
      local targetNumToAccomplish = 5
      local startMission =  1
      -- Test
      createCASMission(route, max_contemp_units, max_contemp_groups, templateList, route_wp_start, route_wp_end, route_range, route_altitude, scheduled_time, scheduled_var, patrolNameZone, patrolSpeedMin, patrolMaxSPeed, minAltitude, maxAltitude, casNameZone, timeOfEngage, timeOfStopEngage, engageSpeed, engageAltitude, nameOfTarget, targetNumToAccomplish, startMission)
      ]]


      --[[

      OK

      Spawn_Red_CAS_Missione_Aircraft  = genericSpawnSimple('Russian CAS Aircraft@DIDMUKHA', 8, 4, Spawn_Russian_CAS_Flight_Aircraft, 1, 1, 300, 500, 1200, 0.7)
      Spawn_Red_CAS_Missione_Heli  = genericSpawnSimple('Russian CAS Heli@DIDMUKHA', 8, 4, Spawn_Russian_CAS_Flight_Aircraft, 1, 1, 300, 500, 1200, 0.7)


      CASPlane = GROUP:FindByName( "Russian CAS Aircraft@DIDMUKHA" )
      CASHelicopter = GROUP:FindByName( "Russian CAS Heli@DIDMUKHA" )



      -- Create two patrol zones, one for the Planes and one for the Helicopters.
      PatrolZonePlanes = ZONE:New( "DIDMUKHA" )
      PatrolZoneHelicopters = ZONE:New( "TSKHINVALI" )

      -- Create and object (in this case called AICasZone) and
      -- using the functions AI_CAS_ZONE assign the parameters that define this object
      -- (in this case PatrolZone, 500, 1000, 500, 600, CASEngagementZone)
      AICasZonePlanes = AI_CAS_ZONE:New( PatrolZonePlanes, 400, 500, 500, 2500, CASEngagementTkviavi )
      AICasZoneHelicopters = AI_CAS_ZONE:New( PatrolZoneHelicopters, 100, 250, 300, 1000, CASEngagementTkviavi )

      -- Create an object (in this case called Targets) and
      -- using the GROUP function find the group labeled "Targets" and assign it to this object
      Targets = GROUP:FindByName("USA ARMOR SQUAD")


      -- Tell the program to use the object (in this case called CASPlane) as the group to use in the CAS function
      AICasZonePlanes:SetControllable( CASPlane )
      AICasZoneHelicopters:SetControllable( CASHelicopter )

      -- Tell the group CASPlane to start the mission in 1 second.
      AICasZonePlanes:__Start( 1 ) -- Dopo 1 s They should startup, and start patrolling in the PatrolZone.
      AICasZoneHelicopters:__Start( 1 ) -- Dopo 1 s They should startup, and start patrolling in the PatrolZone.

      -- After 4 minutes, tell the group CASPlanes and CASHelicopters to engage the targets located in the engagement zone called CASEngagement Zone.
      AICasZonePlanes:__Engage( 240, 500, 1500 ) -- Dopo 120 s  Engage with a speed of 500 km/h and 1500 meter altitude.
      AICasZoneHelicopters:__Engage( 240, 100, 150 ) -- Dopo 120 s Engage with a speed of 100 km/h and 150 meter altitude.

      -- After 12 minutes, tell the group CASPlane to abort the engagement.
      AICasZonePlanes:__Abort( 720 ) -- Abort the engagement.
      AICasZoneHelicopters:__Abort( 720 ) -- Abort the engagement.


      -- Qui schedula una funzione che controlla periodicamente ogni 60 secondi la situazione
      -- Check every 60 seconds whether the Targets have been eliminated.
      -- When the trigger completed has been fired, the Planes and Helicopters will go back to the Patrol Zone.
      Check, CheckScheduleID = SCHEDULER:New(nil,
        function()
          if Targets:IsAlive() and Targets:GetSize() > 5 then
            BASE:E( "Test Mission: " .. Targets:GetSize() .. " targets left to be destroyed.")
          else
            BASE:E( "Test Mission: The required targets are destroyed." )
            Check:Stop( CheckScheduleID )
            AICasZonePlanes:__Accomplish( 1 ) -- Now they should fly back to the patrolzone and patrol.
            AICasZoneHelicopters:__Accomplish( 1 ) -- Now they should fly back to the patrolzone and patrol.
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


      ]]--






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




    -- Create RAT object. Additionally, to the template group name we give the group an alias to be able to distinguish to another group created from this template.
    local ant = RAT:New(air_template_red.TRAN_AN_26, "Antonov 26 Red")

    -- Change coalition of Antonof to red.
    ant:SetCoalitionAircraft("red")


    -- This restricts the possible departure and destination airports the airports belonging to the red coalition.
    -- Here it is important that in the mission editor enough (>2) airports have been set to red! Otherwise there will be no possible departure and/or destination airports.
    ant:SetCoalition("sameonly")

    -- Explicitly exclude Senaki from possible departures and destinations.
    ant:ExcludedAirports("Nalchik", "Beslan")

    -- Spawn three aircraft.
    ant:Spawn(3)



    -- Create RAT object. Alias is "Yak Blue". If the same template is used multiple times, it is important to give each RAT object an indiviual name!
    local yakblue=RAT:New(air_template_blue.TRAN_YAK_40, "Yak Blue")

    -- Change coalition of Yak to blue.
    yakblue:SetCoalitionAircraft("blue")

    -- This restricts the possible departure and destination airports the airports belonging to the blue coalition since the coalition is changed manually.
    yakblue:SetCoalition("sameonly")

    -- We also change the livery of these groups. If a table of liveries is given, each spawned group gets a random livery.
    yakblue:Livery({"Georgian Airlines"})

    -- Explicitly exclude Nalchik from possible departures and destinations.
    yakblue:ExcludedAirports({"Kutaisi", "Gudauta", "Sochi-Adler"})

    -- Spawn three aircraft.
    yakblue:Spawn(3)



  end -- end activeAirWar



end -- end if conflictZone == 'Zone 1: South Ossetia' then
