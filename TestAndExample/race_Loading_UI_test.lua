local count = 1

function onCheckUseRequirements(self, msg)
    if count == 1 then
        UI:SendMessage( "pushGameState", {{"state", "Instance_Loading"}} )
        count = count + 1
    elseif count == 2 then
        UI:SendMessage("InstanceLoading", {{"numOfPlayers", 4}, 
                                            {"Type", "Race"},
                                            {"Player_1", "John"}} )
        count = count + 1
    elseif count == 3 then
        UI:SendMessage("InstanceLoading", {{"numOfPlayers", 4}, 
                                            {"Type", "Race"},
                                            {"Player_1", "John"},
                                            {"Player_2", "Mike"},
                                            {"Player_3", "Keith"},
                                            {"Player_4", "Bob"}} )
        count = count + 1
    elseif count == 4 then
        UI:SendMessage("InstanceLoading", {{"numOfPlayers", 5}, 
                                            {"Type", "Race"},
                                            {"Player_1", "John"},
                                            {"Player_2", "Mike"},
                                            {"Player_3", "Keith"},
                                            {"Player_4", "Bob"}} )
        count = count + 1
    elseif count == 5 then
        UI:SendMessage("InstanceLoading", {{"numOfPlayers", 5}, 
                                            {"Type", "Race"},
                                            {"Player_1", "John"},
                                            {"Player_2", "Mike"},
                                            {"Player_3", "Keith"},
                                            {"Player_4", "Bob"},
                                            {"Player_5", "Win"}} )
        count = count + 1
    else
        UI:SendMessage( "popGameState", {{"state", "Instance_Loading"}} )
        count = 1
    end
    
    --print('send Instance_Loading to UI')
    
    msg.bCanUse = false
    return msg
end 

function onGetPriorityPickListType(self, msg)
    local myPriority = 0.8
        
    if ( myPriority > msg.fCurrentPickTypePriority ) then

       msg.fCurrentPickTypePriority = myPriority
       msg.ePickType = 14    -- Interactive pick type

    end

    return msg
end 