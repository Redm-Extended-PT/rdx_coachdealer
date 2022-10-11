RDX = nil
TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)

local function GetAmmoutCoaches( Player_ID, Character_ID )
    local HasCoaches = MySQL.Sync.fetchAll( "SELECT * FROM coaches WHERE identifier = @identifier ", {
        ['identifier'] = Player_ID       
    } )
    if #HasCoaches > 0 then return true end
    return false
end

RegisterServerEvent('rdx:buycoach')
AddEventHandler( 'rdx:buycoach', function ( args )

    local _src   = source
    local _price = args['Price']
    --local _level = args['Level']
    local _model = args['Model']
    local xPlayer = RDX.GetPlayerFromId(_src)  
	
        u_identifier = xPlayer.getIdentifier()
        --u_level = xPlayer.getLevel()        
        u_money = xPlayer.getMoney()
    

    local _resul = GetAmmoutCoaches(u_identifier)

    if u_money <= _price then
        TriggerClientEvent( 'UI:DrawNotification', _src, Config.NoMoney )
        return
    end

    --[[if u_level <= _level then
        TriggerClientEvent( 'UI:DrawNotification', _src, Config.LevelMissing )
        return
    end]]

	
        xPlayer.removeMoney(_price)
   

    TriggerClientEvent('rdx:spawnCoach', _src, _model)


    if _resul ~= true then
        local Parameters = { ['identifier'] = u_identifier, ['coach'] = _model }
        MySQL.Async.execute("INSERT INTO coaches ( `identifier`, `coach` ) VALUES ( @identifier, @coach )", Parameters)
        TriggerClientEvent( 'UI:DrawNotification', _src, 'You got a new coach !' )
    else
        local Parameters = { ['identifier'] = u_identifier, ['coach'] = _model }
        MySQL.Async.execute(" UPDATE coaches SET coach = @coach WHERE identifier = @identifier ", Parameters)
        TriggerClientEvent( 'UI:DrawNotification', _src, 'You update the coach !' )
    end

end)

RegisterServerEvent( 'rdx:loadcoach' )
AddEventHandler( 'rdx:loadcoach', function ( )

    local _src = source

	local xPlayer = RDX.GetPlayerFromId(_src)  
	u_identifier =  xPlayer.getIdentifier()

    local Parameters = { ['identifier'] = u_identifier }
    local HasCoaches = MySQL.Sync.fetchAll( "SELECT * FROM Coaches WHERE identifier = @identifier ", Parameters )

    if HasCoaches[1] then
        local coach = HasCoaches[1].coach
        TriggerClientEvent("rdx:spawnCoach", _src, coach)
    end

end )