if love._version_major >= 11 then 
	local _setColor = love.graphics.setColor
	
	love.graphics.setColor = function (r, g, b, a)
		_setColor(r / 255, g / 255, b / 255, (a or 255) / 255)
	end
end

--[[
	绘制文本，默认使用了中文像素的字体，修复直接print，无法显示中文的问题
]]
function drawText(text,x,y,size)
    local font = love.graphics.newFont("assets/fonts/fz.ttf",size)
    love.graphics.setFont(font)
    love.graphics.print(text,x,y)
end