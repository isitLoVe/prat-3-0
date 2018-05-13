---------------------------------------------------------------------------------
--
-- Prat - A framework for World of Warcraft chat mods
--
-- Copyright (C) 2006-2018  Prat Development Team
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor,
-- Boston, MA  02110-1301, USA.
--
--
-------------------------------------------------------------------------------

Prat:AddModuleToLoad(function()
    local function dbg(...) end

    --@debug@
    function dbg(...) Prat:PrintLiteral(...) end

    --@end-debug@

    local PRAT_MODULE = Prat:RequestModuleName("Achievements")

    if PRAT_MODULE == nil then
        return
    end

    local module = Prat:NewModule(PRAT_MODULE)

    Prat:SetModuleDefaults(module.name, {
        profile = {
            on = false
        }
    })

    local function white(text)
        return Prat.CLR:Colorize("ffffff", text)
    end

    local regexp = "(|cffffff00|Hachievement:([0-9]+):(.+):([%-0-9]+):([%-0-9]+):([%-0-9]+):([%-0-9]+):([%-0-9]+):([%-0-9]+):([%-0-9]+):([%-0-9]+)|h%[([^]]+)%]|h|r)"
    local gratsLinkType = "gratsl"


    local function formatDate(m, d, y)
        return ("%d/%d/20%02d"):format(m, d, y)
    end

    local function doGrats()
    end

    local function buildGratsLink(name, group)
        if type(name) == "nil" then
        else
            return Prat.BuildLink(gratsLinkType, ("%s:%s"):format(name, group), "grats", "00a0ff")
        end
    end

    local function ShowOurCompletion(...)
--        dbg(...)
        local text, thierId, thierPlayerGuid, thierDone, thierMonth, thierDay, thierYear, _, _, _, _, thierAchievmentName = ...
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(thierId)

        local _, _, _, _, _, thierName, _ = GetPlayerInfoByGUID(thierPlayerGuid)
        local group = Prat.CurrentMessage.CHATGROUP

        if completed then
            return Prat:RegisterMatch(text.." "..white("(").."Completed "..formatDate(month, day, year)..white(")")).." "..buildGratsLink(thierName, group)
        else
            return Prat:RegisterMatch(text.." "..buildGratsLink(thierName, group))
        end
    end


    module.link = function(name) return buildGratsLink(name) end

    Prat:SetModulePatterns(module, {
        { pattern = regexp, matchfunc = ShowOurCompletion, priority = 100 },
    })

    function module:OnModuleEnable()
        Prat.RegisterLinkType({ linkid = gratsLinkType, linkfunc = self.OnGratsLink, handler = self }, self.name)
    end

    function module:OnGratsLink(link, text, button, ...)
        local name, group = strsub(link, gratsLinkType:len()+2):match("([^:]*):(.*)")

        SendChatMessage("Grats "..name, group)

        return false
    end
end)