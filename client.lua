PanelControl = {}
PanelControl.panels = {}

function addPanel ( panel, resourceName, systemName, eventName, ... )
    panel.resourceName = resourceName
    panel.systemName = systemName
    panel.eventName = eventName
    panel.argument = { ... }
    table.insert(PanelControl.panels, panel )
    panel.index = #PanelControl.panels -- เก็บ index ของหน้าต่างในตาราง

    triggerEvent( "onClientControlSystemAddPanel", getLocalPlayer(  ), PanelControl.panels[ panel.index ] )
end

function bringToFront ( panel )
    for i, p in ipairs(PanelControl.panels) do
        if p == panel then
            table.remove(PanelControl.panels, i) -- ลบหน้าต่างจากตำแหน่งเดิม
            table.insert(PanelControl.panels, panel) -- เพิ่มหน้าต่างไปยังตำแหน่งสุดท้าย
            triggerEvent( "onClientControlSystemBringToFront", getLocalPlayer(  ), panel )
            break
        end
    end
end

function bringToFrontBySystemName ( systemName )
    for i, p in ipairs(PanelControl.panels) do
        if p.systemName == systemName then
            table.remove(PanelControl.panels, i) -- ลบหน้าต่างจากตำแหน่งเดิม
            table.insert(PanelControl.panels, p) -- เพิ่มหน้าต่างไปยังตำแหน่งสุดท้าย
            triggerEvent( "onClientControlSystemBringToFront", getLocalPlayer(  ), p )
            break
        end
    end
end

function isBringToFrontBySystemName ( systemName )
    local topPanel = getTopPanel( )
    if topPanel and topPanel.systemName == systemName then
        return true
    end
    return false
end

function getTopPanel ( )
    return PanelControl.panels[#PanelControl.panels] -- หน้าต่างด้านหน้าสุดอยู่ในตำแหน่งสุดท้ายของตาราง
end

function changePositionBySystemName ( systemName, x, y, w, h )
    for i, p in ipairs(PanelControl.panels) do
        if p.systemName == systemName then
            p.layout.x = x
            p.layout.y = y
            p.layout.w = w
            p.layout.h = h
        end
    end
    return false
end

function removePanelBySystemName ( systemName )
    for i, p in ipairs(PanelControl.panels) do
        if p.systemName == systemName then
            table.remove( PanelControl.panels, i ) -- ลบหน้าต่างจากตำแหน่ง
            triggerEvent( "onClientControlSystemRemovePanel", getLocalPlayer(  ), p )
        end
    end
end

function removePanelByResourceName ( resourceName )
    for i, p in ipairs(PanelControl.panels) do
        if p.resourceName == resourceName then
            table.remove( PanelControl.panels, i ) -- ลบหน้าต่างจากตำแหน่ง
            triggerEvent( "onClientControlSystemRemovePanel", getLocalPlayer(  ), p )
        end
    end
end

function removePanel ( panel )
    for i, p in ipairs(PanelControl.panels) do
        if p == panel then
            table.remove(PanelControl.panels, i) -- ลบหน้าต่างจากตำแหน่ง
            triggerEvent( "onClientControlSystemRemovePanel", getLocalPlayer(  ), p )
            break
        end
    end
end

function isMouseInPanel(panel)
    local cursor = cursorPosition()
    local x, y, w, h = panel.layout.x, panel.layout.y, panel.layout.w, panel.layout.h
    return cursor.x >= x and cursor.x <= x + w and cursor.y >= y and cursor.y <= y + h
end

function getPanelAtCursorPosition( )
    local tb = {}
    local cursor = cursorPosition()
    for _, panel in ipairs(PanelControl.panels) do
        local x, y, w, h = panel.layout.x, panel.layout.y, panel.layout.w, panel.layout.h
        if cursor.x >= x and cursor.x <= x + w and cursor.y >= y and cursor.y <= y + h then
            table.insert( tb, panel )
        end
    end
    return tb
end

function getTopPanelClicked()
    local topPanel = getTopPanel ( )
    if topPanel and isMouseInPanel(topPanel) then
        return topPanel
    end
    for i = #PanelControl.panels - 1, 1, -1 do
        local panel = PanelControl.panels[i]
        if isMouseInPanel(panel) then
            return panel
        end
    end
    return nil
end

function onClientKey ( button, press )
    if ( button == "mouse1" or button == "mouse2" ) and press == true then
        local clickedPanel = getTopPanelClicked( )
        if clickedPanel then
            bringToFront ( clickedPanel )
            triggerEvent( clickedPanel.eventName, getLocalPlayer(  ), unpack( clickedPanel.argument ) )
            triggerEvent( "onClientControlSystemClickPanel", getLocalPlayer(  ), clickedPanel)
        end
    end
end
addEventHandler("onClientKey", root, onClientKey)

function refreshElementPanel ( )
    local tb = {}
    for k,v in pairs( PanelControl.panels ) do
        local systemName = v.systemName
        if systemName then
            tb[ systemName ] = v
        end
    end
    return tb
end

addEvent( "onClientControlSystemClickPanel", true )
addEventHandler( "onClientControlSystemClickPanel", root, 
function ( thePanel )
    setElementData( getLocalPlayer(  ), "panel-control-list", refreshElementPanel ( ) )
end
)

addEvent( "onClientControlSystemBringToFront", true )
addEventHandler( "onClientControlSystemBringToFront", root, 
function ( thePanel )
    setElementData( getLocalPlayer(  ), "panel-control-list", refreshElementPanel ( ) )
end
)

addEvent( "onClientControlSystemAddPanel", true )
addEventHandler( "onClientControlSystemAddPanel", root, 
function ( thePanel )
    setElementData( getLocalPlayer(  ), "panel-control-list", refreshElementPanel ( ) )
end
)

addEvent( "onClientControlSystemRemovePanel", true )
addEventHandler( "onClientControlSystemRemovePanel", root, 
function ( thePanel )
    setElementData( getLocalPlayer(  ), "panel-control-list", refreshElementPanel ( ) )
end
)

function cursorPosition()
    if isCursorShowing() then
        local screenx, screeny = getCursorPosition()
        local sw, sh = guiGetScreenSize()
        return { x = screenx * sw, y = screeny * sh }
    end
    return { x = 0, y = 0 }
end

addEventHandler( "onClientResourceStop", getRootElement( ),
function ( stoppedRes )
    removePanelByResourceName ( getResourceName( stoppedRes ) )
end
)

function onClientRender()
    if getElementData( getLocalPlayer(  ), "dev" ) == true then
        for i, panel in ipairs(PanelControl.panels) do
            dxDrawRectangle(panel.layout.x, panel.layout.y, panel.layout.w, panel.layout.h, tocolor( 255, 255, 255, 60 ))
            dxDrawText(panel.systemName, panel.layout.x + 10, panel.layout.y + 10, panel.layout.x + panel.layout.w, panel.layout.y + panel.layout.h, tocolor(255, 0, 0), 1, "default-bold")

            dxDrawText( panel.index .. " | " .. panel.resourceName .. " / " .. panel.systemName, 100, 200 + 15 * ( i - 1 ) )
        end
    end
end
addEventHandler("onClientRender", root, onClientRender)