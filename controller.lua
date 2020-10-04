--[[ --------MASTER/CONTROLLER Prog. Board
     Insert code onto unit>>start() filter and the timer/tick. 

     Connect/link the databank that is connected to the worker/slave boards, connect the core (don't forget this, or no custom names shall show up!),
     and displays (connect one display per worker/slave board that you'll use/define; and NAME THEM! or use the default slot names, but remmember who is who ffs, you'll need it later).
     Edit the lua parameters (right click, advanced>>edit lua parameters; set the refresh/timer/tick rate at what the screens will update; make sure it's >= worker pboard refresh.)

     Now comes the somewhat "maybe" tricky part.
     If you have more than one worker/slave board, then you'll need
     to copy&paste some code, and change a couple lines of code. I'll try my best to lead you on how to do it.

     Example, if you have 3 worker/slave boards (make sure their IDs are unique! and note them down. you'll need them) connected and feeding to the databank,
     then you'll need 3 displays. each display is going to show you their respective board (1:1 ratio for now; working on this part).
     Now, how do you do that, simple. To try and keep it simple for even new players to the game, I tried to keep this realy basic. so, here we go.

     duplicate as many times, as many displays/worker boards you've got connected, the following line that you have put into the tick/timer section "screen1":
     display.setHTML(renderHTML("PB1"))

     If you notice the PB1, is the default unique ID for the initial single worker/slave board. and you'll also notice that the display slot is named "display".
     So, if you have more displays and you've named their respective slots on the controller board, for example, display1, display2, displayMetalWorks...
     You'd change the code in the tick/timer filter, like so:

     display1.setHTML(renderHTML("PB1"))   it'll show the status of the industries connected to the PB1 worker/slave board on display1.
     display2.setHTML(renderHTML("PB2"))   it'll show the status of the industries connected to PB2 on the display2... and so on.
     displayMetalWorks.setHTML(renderHTML('MetalWorks'))  it'll show the status of indy's connected to worker boards MetalWorks on displayMetalWorks...   you catch my drift?
     |----------------|                   |----------|
     display_slot_name  . function ( function ('UID you defined on the worker/slave board') )

     The you have it.

     So, just make sure, that you are using unique identifiers on the worker/slave boards (check the worker.lua header for info), and that you know where the connected displays are linked to (which slots on the controller board).
     Then, put an extra line on the tick/timer filter, with the correct display slot name, and the worker/slave board ID, and you shoul'd be golden.

     ]]
--// the "magic" starts here...
--
if display then
    display.activate()
    display.setCenteredText("Industry Monitor Starting...")
    end

unit.hide()
--

--variables
local refresh = 10 --export: refresh info screen every # seconds (keep it higher than the worker boards)
local _strON  = "ON" --export: string to display when industry is ON
local _strOFF = "OFF" --export: string to display when industry is OFF
local _strHLD = "HLD" --export: string to display when industry is on hold/maintain mode
local _strREZ = "REZ" --export: string to display when industry is in need for resources (input)
local _strERR = "ERR" --export: string to display when industry is in fault/error mode
local _colorBGHeader = "red" --export: html color code, that you want the header background to have. can be #ffffff values, or simple colour names (red, yellow, green.... check htmlcolorcodes.com ;] ) 
local _colorFGHeader = "black" --export: html colour code, that you want the header font to have. can be #ffffff values, or simple colour names (red, yellow, green.... check htmlcolorcodes.com ;] ) 
local _colorFGHeader = "black" --export: html colour code, that you want the header font to have. can be #ffffff values, or simple colour names (red, yellow, green.... check htmlcolorcodes.com ;] ) 
local _colorTable = "white" --export: industry names and efficiency font colour
--

--functions
function tablelenght(input)
    local count = 0
    for _ in pairs(input) do count = count + 1 end
    return count
end
--

function getWorkerDbData(_PBID)
    local _data = json.decode(databank.getStringValue(_PBID))
    local strings = {}
    if _data then
        for k,v in pairs(_data) do
            local str = ""
            if string.match(_data[k].status, "OFF") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. "</th><th>" .. _strOFF .. "</th><th>NaN</th>"
                elseif string.match(_data[k].status, "ON") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. [[</th><th style="color: green;">]] .. _strON .. "</th><th>" .._data[k].efficiency .."</th>"
                elseif string.match(_data[k].status, "HLD") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. [[</th><th style="color: yellow;">]] .. _strHLD .. "</th><th>" .._data[k].efficiency .."</th>"
                elseif string.match(_data[k].status, "REZ") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. [[</th><th style="color: orange; !important;">]] .. _strREZ .. "</th><th>" .._data[k].efficiency .."</th>"
                elseif string.match(_data[k].status, "ERR") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. [[</th><th style="color: red; !important;">]] .. _strERR .. "</th><th>" .._data[k].efficiency .."</th>"
                else str = [[<th style="color: red; !important;">FUBAR</th><th></th><th></th>]]
            end
            strings[k] = str
        end
    else system.print("!!DB READ ERROR!!")  --you forgot to connect the damned databank, or turn on the worker/slave board :P
    end
    --
    return strings        
end    
--

function renderHTML(_pbID)
    local htmlout = ""
    local _status = getWorkerDbData(_pbID)
    --
    for i=1, tablelenght(_status) do
        htmlout = htmlout .. [[<tr style="font-size: 7rem; font-family: roboto">]] .. _status[i] .. "</tr>"
    end
    --
    local html = [[
    <style>
    .container {
      font-size: 10rem;
      color:]] .. _colorTable .. [[;
    }
    </style>
    <div class="container">
      <div class="row" style="margin-top: auto; justify-content: center;">
        <table style="margin-left: auto; margin-right: auto; width: 98%; font-size: 9rem;">
          <tr style="background-color:]] .. _colorBGHeader .. "; color: "  .. _colorFGHeader .. [[; font-size: 10rem; text-align: center;">
            <th>Industry</th><th>Status</th><th>%</th>
          </tr>
    ]] .. htmlout .. [[</table></div></div>]]
    --    
    return html
end
--

--runtime
unit.setTimer("screens", refresh)



--[[ insert into unit>>tick("screens") filter]]
--
display.setHTML(renderHTML("PB1"))



--[[ insert into unit>>stop() filter]]
--
if display then
    display.clear()
    display.deactivate()
    end

--EOF
