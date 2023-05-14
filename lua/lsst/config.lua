lsst.Config = {}  local CONFIG = lsst.Config

CONFIG.StatCost         = 50               --How much does it take for each 'Character Stats' level.

CONFIG.Restrict         = true            --Certain items will be removed from the inventory if players don't have current skills activated.

CONFIG.PlayerEarn       = 5               --Earning points from each player kill.
CONFIG.NPCEarn          = 1               --Earning points from each NPC kill.
CONFIG.TimerEarn        = 10             --Earning points from playing in the server.
CONFIG.Timer            = 1800             --How many seconds does it take for each 'Timer Earn'.
CONFIG.TimerAFK         = true            --Set this to false and players cannot earn timer points when AFK.