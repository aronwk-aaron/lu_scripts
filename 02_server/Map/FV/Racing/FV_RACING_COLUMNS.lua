--------------------------------------------------------------
--script telling the columns in the race track to freeze on startup
--created SY, 4-01-10
--------------------------------------------------------------

function onStartup(self)
   self:StopPathing()
end
