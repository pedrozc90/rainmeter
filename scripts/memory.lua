local format = string.format
local floor, ceil = math.floor, math.ceil

local GIGABYTES_BYNARY = 1073741824 -- bytes
local MEGABYTES_BYNARY = 1048576 -- bytes
local KILOBYTES_BYNARY = 1024 -- bytes

function Initialize()

    -- variables
    colors = {}
    colors.default = SKIN:GetVariable("ColorDefault")
    colors.alert = SKIN:GetVariable("ColorAlert")
    colors.warn = SKIN:GetVariable("ColorWarn")
    precision = tonumber(SKIN:GetVariable("Precision"))
    
    meterName = SELF:GetOption("MeterName")
    meterRAM = SKIN:GetMeter("MeterRAM")
    meterSWAP = SKIN:GetMeter("MeterSWAP")

    -- physical
    measurePhysicalMemoryTotal = SKIN:GetMeasure("MeasurePhysicalMemoryTotal")
    measurePhysicalMemoryFree = SKIN:GetMeasure("MeasurePhysicalMemoryFree")
    measurePhysicalMemory = SKIN:GetMeasure("MeasurePhysicalMemory")

    -- swap
    measureSwapMemoryTotal = SKIN:GetMeasure("MeasureSwapMemoryTotal")
    measureSwapMemoryFree = SKIN:GetMeasure("MeasureSwapMemoryFree")
    measureSwapMemory = SKIN:GetMeasure("MeasureSwapMemory")

    -- memory
    measureMemoryTotal = SKIN:GetMeasure("MeasureMemoryTotal")
    measureMemoryFree = SKIN:GetMeasure("MeasureMemoryFree")
    measureMemory = SKIN:GetMeasure("MeasureMemory")

end

function Update()

    totalRAM = measurePhysicalMemoryTotal:GetValue()
    freeRAM = measurePhysicalMemoryFree:GetValue()
    usedRAM = measurePhysicalMemory:GetValue()
    percRAM = (usedRAM / totalRAM) * 100

    totalSWAP = measureSwapMemoryTotal:GetValue()
    usedSWAP = measureSwapMemory:GetValue()
    percSWAP = (usedSWAP / totalSWAP) * 100

    textRAM = format("RAM: %s / %s (%s%%)", ShortValue(usedRAM, precision), ShortValue(totalRAM, precision), Round(percRAM, precision))
    textSWAP = format("Swap: %s (%s%%)", ShortValue(usedSWAP, precision), Round(percSWAP, precision))

    SKIN:Bang("!SetOption", meterRAM:GetName(), "Text", textRAM)
    SKIN:Bang("!SetOption", meterRAM:GetName(), "FontColor", SetColor(percRAM))

    SKIN:Bang("!SetOption", meterSWAP:GetName(), "Text", textSWAP)
    SKIN:Bang("!SetOption", meterSWAP:GetName(), "FontColor", SetColor(percSWAP))

end

SetColor = function(percentage)
    if (percentage >= 90.0) then
        return colors.alert
    elseif (percentage >= 75.0) then
        return colors.warn
    else
        return colors.default
    end
end

Round = function(number, decimals)
    if (precision == false) then return number end
    assert(type(number) == "number", "Round expects a number as argument.")
    local mult = 10^(decimals or 0)
    if (number >= 0) then
        return floor(number * mult + 0.5) / mult
    end
    return ceil(number * mult - 0.5) / mult
end

ShortValue = function(value, precision)
    -- assert(type(number) == "number", "Round expects a number as argument.")
    if (value > 1E9) then
        return Round(value / GIGABYTES_BYNARY, precision) .. " GB"
    elseif (value > 1E6) then
        return Round(value / MEGABYTES_BYNARY, precision) .. " MB"
    elseif (value > 1E3) then
        return Round(value / KILOBYTES_BYNARY, precision) .. " KB"
    end
    return Round(value, precision) .. " Bytes"
end
