-- Created: 10/21/09 mrb...
-- need to put dispText in config data in HF

require('o_mis')

function onStartup(self)
    local tempText = self:GetVar('dispText') 
    local tempTime = self:GetVar('dispTime')
    
    resetBox(self)
    if not tempText then
        self:SetVar('dispText', 'Missing dispText in HF')
    end
    
    if not tempTime then
        self:SetVar('dispTime', 3)
    end    
end

function MakeBox(self)
    -- check to make sure we have a target
    if self:GetVar('isDisp') and not self:GetVar('isTouch') then return end
    
    local player = GAMEOBJ:GetObjectByID( GAMEOBJ:GetLocalCharID())
    
    self:SetVar('isDisp', true)
    --print('Creating Box')
    newTime = self:GetVar('dispTime')
    GAMEOBJ:GetTimer():AddTimerWithCancel( newTime, "BoxTimer", self )
    print(Localize(self:GetVar('dispText')) .. ' ' .. self:GetVar('dispTime'))
    player:DisplayTooltip { bShow = true, strText = Localize(self:GetVar('dispText')), iTime = 100000 }
end

-- OnEnter in HF Trigger system
function onCollisionPhantom(self, msg)
    -- Gets the target id that has collided
    self:SetVar('isTouch', true)    
    if msg.objectID:GetID() ~= GAMEOBJ:GetLocalCharID() or self:GetVar('isDisp') then return end
    
    MakeBox(self)
end

-- OnExit in HF Trigger system
function onOffCollisionPhantom(self, msg )
    -- Says we have finished colliding tries to resetBox()
    if msg.objectID then 
        self:SetVar('isTouch', false) 
        --print('Exiting')
        resetBox(self)
    end
end

function onTimerDone(self, msg)    
    -- Says we are done with the displaying the message box, tries to resetBox()
    if msg.name == "BoxTimer" then
        local player = GAMEOBJ:GetObjectByID( GAMEOBJ:GetLocalCharID())
        
        self:SetVar('isDisp', false)
        --print('Box Timer Done')
        player:DisplayTooltip { bShow = false }
        resetBox(self)  
    end
end

-- resets local data mBox
function resetBox(self) 
    -- checks to see if we are ready to reset mBox
    if self:GetVar('isDisp') or self:GetVar('isTouch') then return end
    -- default values
    self:SetVar('isDisp', false)
    self:SetVar('isTouch', false)
    --print('resetBox')
end 