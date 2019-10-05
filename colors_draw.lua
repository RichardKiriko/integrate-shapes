function colors_draw(tbl) 
	local shapes_text="" 
	if #tbl ~= 0 then 
		local wid={0} 
		local top=0 
		local bottom=0 
		local left={} 
		for i=1,#tbl do 
			local x1,y1,x2,y2=_G.Yutils.shape.bounding(tbl[i].text)
			left[i]=x1
			wid[i+1]=wid[i]+x2-x1
			top=math.min(top,y1)
			bottom=math.max(bottom,y2)
		end 
		shapes_text=string.format("{\\c%s}m %d %d l %d %d %s",tbl[1].color,left[1],top,left[1],bottom,tbl[1].text) 
		for i=2,#tbl do 
			shapes_text=shapes_text..string.format("{\\c%s}%s",tbl[i].color,_G.Yutils.shape.move(string.format("m %d %d l %d %d %s",left[i],top,left[i],bottom,tbl[i].text),-wid[i],0)) 
		end 
	end 
return shapes_text 
end