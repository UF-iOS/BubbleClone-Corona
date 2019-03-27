--Premade functiom
local function hasCollided(obj1, obj2) 

if obj1 == nil then  return false end 
if obj2 == nil then  return false end 

local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin 
local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax  
local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin 
local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax 

return (left or right) and (up or down)
end
--
display.setStatusBar( display.HiddenStatusBar )

local bg = display.newRect( display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
bg:setFillColor( .3,.6,1 )
local titleGroup = display.newGroup( )
local gameGroup = display.newGroup( )
titleGroup.alpha = 1
gameGroup.alpha=0
local title = display.newText( titleGroup, "Bubble Ball", display.contentCenterX, display.contentCenterY-120, native.systemFontBold, 50 )

local play = display.newText( titleGroup, "Play", display.contentCenterX, display.contentCenterY, native.systemFont, 25 )

local function goHome(  )
	bg:setFillColor( .3,.6,1 )
	titleGroup.alpha = 1
	gameGroup.alpha = 0
end
local function goGame( )
	bg:setFillColor( .9 )
	titleGroup.alpha = 0
	gameGroup.alpha = 1

end

play:addEventListener( "tap", function (  )
	play.alpha = .5

	timer.performWithDelay( 300, function ( )
		play.alpha = 1
		goGame()
	end )
	
end )

--game
local physics = require "physics"
physics.start( )

physics.pause( )
physics.setGravity( 0, 9.8)

local objectBox = display.newRect( gameGroup, display.contentCenterX, 40, display.actualContentWidth,80 )
objectBox:setFillColor( .5 )
physics.addBody( objectBox, "static" )
objectBox.isSensor = true

local ground = display.newRect( gameGroup, display.contentCenterX, display.actualContentHeight-50, 400, 100 )
ground:setFillColor( 0 )
physics.addBody(ground, "static",{bounce=.1,friction = 1})

local rightTriangle = display.newPolygon( gameGroup, objectBox.x-90, objectBox.y, {0,0, 0,70, 70,70} )
rightTriangle:setFillColor( 1,1,.5 )
physics.addBody( rightTriangle, "dynamic",{bounce = 0, friction = 1, shape={-35,-35,-35,35,35,35 }} )
rightTriangle.isSensor = true

local finish = display.newRect( gameGroup, 350, 195, 50,50 )
finish.name = "finish"
finish:setFillColor( .5)
finish.alpha=.5
physics.addBody( finish, "static" )
finish.isSensor = true

local bubble = display.newCircle( gameGroup, 90, objectBox.y+80, 15 )
physics.addBody( bubble, "dynamic", {radius = 15, bounce = .4} )
bubble.name = "bubble"
bubble:setFillColor( .3,.6,1 )

rightTriangle:addEventListener( "touch", function (e)
	if(e.phase == "began") then
		display.getCurrentStage():setFocus(rightTriangle);
		rightTriangle.hasFocus = true;
		rightTriangle.oldX = rightTriangle.x;
		rightTriangle.oldY = rightTriangle.y;


	elseif (rightTriangle.hasFocus) then
		if(e.phase == "moved") then

			rightTriangle.x = e.x;
			rightTriangle.y = (e.y - e.yStart) + rightTriangle.oldY;

	
		elseif(e.phase == "ended" or e.phase == "cancelled") then

			display.getCurrentStage():setFocus(nil);
			rightTriangle.hasFocus = false;
			
		end
	end
end )	
local isGameRunning = false
local function start(  )
	isGameRunning = true
	physics.start( )
	bubble:setLinearVelocity( 0, 0 )
	rightTriangle:setLinearVelocity( 0, 0 )
	rightTriangle.xStore, rightTriangle.yStore = rightTriangle.x, rightTriangle.y
	bubble.xStore, bubble.yStore = bubble.x, bubble.y
	if (hasCollided(rightTriangle,objectBox)) then
		rightTriangle.isSensor = true
		rightTriangle.gravityScale = 0
	else
		rightTriangle.isSensor = false
		rightTriangle.gravityScale = 1
	end
end
local function stop(  )
	isGameRunning = false
	physics.pause()
	rightTriangle.x, rightTriangle.y = rightTriangle.xStore, rightTriangle.yStore
	bubble.x, bubble.y = bubble.xStore, bubble.yStore
	
end

local startStopButtonRect = display.newRect( gameGroup, objectBox.x+150, objectBox.y, 100, 70 )
local startStopButtonText = display.newText( gameGroup, "Start",  startStopButtonRect.x, startStopButtonRect.y, systemFont, 20)
startStopButtonRect:setFillColor( 0,1,0 )
startStopButtonRect:addEventListener( "tap", function (  )
	if (isGameRunning == true) then
		stop( )
		startStopButtonText.text = "Start"
		startStopButtonRect:setFillColor( 0,1,0 )
	else
		start()
		startStopButtonText.text = "Stop"
		startStopButtonRect:setFillColor( 1,0,0 )
	end
end )

local function reset(  )
	physics.pause()
	rightTriangle.x, rightTriangle.y = objectBox.x-90, objectBox.y
	bubble.x, bubble.y = 90, objectBox.y+80
	startStopButtonText.text = "Start"
	startStopButtonRect:setFillColor( 0,1,0 )
end

local function onLocalCollision( event )
 
    if ( event.phase == "began" ) then
 		if ((event.target.name== "finish" and event.other.name == "bubble")) then
 			bubble:setLinearVelocity( 0, 0 )
        	native.showAlert( "You Beat Game", "Congrats", {"Reset"}, function (  )
        		reset()
        	end )
        end
    end
end

finish:addEventListener( "collision",onLocalCollision )
bubble:addEventListener( "collision",onLocalCollision )
