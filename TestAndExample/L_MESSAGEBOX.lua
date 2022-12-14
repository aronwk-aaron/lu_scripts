-- When FireEvent is called on this object create a message box with the given text. 
-- Trigger format should be: MessageBox, your text here, *optional time in sec*
-- Created: 4/07/09 mrb...

require('o_mis')
-- default values for mBox
local mBox = {boxTarget = nil,
    isDisp = false,
    isTouch = false,
    isFirst = true,
    boxSelf = nil,
    boxText = '',
    boxTime = 3 }

function MakeBox()
    -- check to make sure we have a target
    if mBox.boxTarget == nil or mBox.isDisp then return end
    
    mBox.isDisp = true
    print('Creating Box')
    newTime = mBox.boxTime + 2
    GAMEOBJ:GetTimer():AddTimerWithCancel( newTime, "BoxTimer", mBox.boxSelf )
    mBox.boxTarget:DisplayTooltip { bShow = true, strText = mBox.boxText, iTime = mBox.boxTime*1000 }
end

function onFireEvent( self, msg )
    -- check to make sure there is a message associated with the FireEvent
    if not msg.args or mBox.isTouch  or mBox.isDisp then return end
    local fText = split(msg.args, ',')
    if string.lower(fText[1]) == 'messagebox' then
        mBox.boxSelf = self
        if fText[3] then
            mBox.boxTime = fText[3]
        end
        mBox.boxText = fText[2]
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1, "EventTimer", self )
        print('FiredEvent')
    end   
end

-- OnEnter in HF Trigger system
function onCollisionPhantom(self, msg)
    -- Gets the target id that has collided
    if msg.objectID then 
        mBox.boxTarget = msg.objectID
        --print('Entering')
    end        
end

-- OnExit in HF Trigger system
function onOffCollisionPhantom(self, msg )
    -- Says we have finished colliding tries to resetBox()
    if msg.objectID then 
        mBox.isTouch = false 
        resetBox()
        --print('Exiting')
    end
end

function onTimerDone(self, msg)    
    -- Says we are done with the displaying the message box, tries to resetBox()
    if msg.name == "BoxTimer" then
        mBox.isDisp = false
        resetBox()    
        --print('Box Timer Done')
    end
    -- checks to see if EventTimer has been called and if we are ready to do MakeBox(), need a valid mBox.boxTarget 
    if msg.name == "EventTimer" then
        if not mBox.boxTarget then
            --print('EventTimer not long enough.... running again')
            GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1, "EventTimer", mBox.boxSelf )
            return
        end
        --print('EventTimer Done!!!')
        MakeBox()
    end
end

-- resets local data mBox
function resetBox() 
    -- checks to see if we are ready to reset mBox
    if mBox.isDisp or mBox.isTouch then return end
    -- default values
    mBox = {boxTarget = nil,
        isDisp = false,
        isTouch = false,
        isFirst = true,
        boxSelf = nil,
        boxText = '',
        boxTime = 3 }
end