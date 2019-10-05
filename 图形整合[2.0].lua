local tr = aegisub.gettext
script_name = tr("图形整合")
script_description = tr("整合图形及添加函数")
script_author = "kiriko"
script_version = "2.0"

include("unicode.lua")
Y = require "Yutils"

function bounding(ass_shape)
	assert(type(ass_shape) == "string", "ass_shape is not a string")
	local x1,y1,x2,y2=Y.shape.bounding(ass_shape)
	local tbl={left=x1,right=x2,center=(x1+x2)/2,top=y1,bottom=y2,middle=(y1+y2)/2,width=x2-x1,height=y2-y1}
return tbl
end

function shape_scale(ass_shape,xscale,yscale)
    assert(type(ass_shape) == "string", "ass_shape is not a string")
	if xscale == nil then
		xscale = 1
	else
		xscale = xscale/100
	end
	if yscale == nil then
		yscale = 1
	else
		yscale = yscale/100
	end
return Y.shape.filter(ass_shape,function(x,y) return x*xscale,y*yscale end)
end

function select_shape(subtitles, selected_lines, active_line)
	local shapes={}
	local li=0
	dialog_config =	{
		{class="label",x=2,y=0,width=1,height=1,label="对齐方式"},
		{class="dropdown",x=3,y=0,width=1,height=1,name="mode",value=vsf1,items={"none","1","2","3","4","5","6","7","8","9"}},
		{class="label",x=2,y=1,width=1,height=1,label="x缩放"},
		{class="edit",x=3,y=1,width=1,height=1,name="xscale",value="100"},
		{class="label",x=2,y=2,width=1,height=1,label="y缩放"},
		{class="edit",x=3,y=2,width=1,height=1,name="yscale",value="100"}
		}
		btn,config=_G.aegisub.dialog.display(dialog_config,{"OK","Cancel"})
	if btn=="Cancel" then 
		aegisub.cancel()
	end
	local mode = config.mode
	local xscale = config.xscale
	local yscale = config.yscale
	for z, i in ipairs(selected_lines) do
		local l = subtitles[i]
		if l.effect == "shapes" then
			li=i
			l.effect="code once"
		elseif l.effect == "double_loop" then
			l.text='function double_loop(loop_n,n2,tbl) maxloop(loop_n*n2) li=math.ceil(j/loop_n) if j%loop_n == 0 then loop_i=loop_n else loop_i=j%loop_n end if tbl ~= nil then if j == 1 then lr={} end if loop_i == 1 then lr[li]={} for i=1,#tbl do if tbl[i][4] == "abs" then local a=math.abs(tbl[i][2]) local b=math.abs(tbl[i][3]) if a > b then a=b b=math.abs(tbl[i][2]) end lr[li][tbl[i][1]]=math.random(a,b)*2*(math.random(0,1)-0.5) else local a=tbl[i][2] local b=tbl[i][3] if a > b then a=b b=tbl[i][2] end lr[li][tbl[i][1]]=math.random(a,b) end end end end return"" end'
			l.effect="code once"
		elseif l.effect == "tbl_loop" then
			l.text='function tbl_loop(l_tbl,tbl) local n=0 for i=1,#l_tbl do n=n+#l_tbl[i] end maxloop(n) loop_i=j li=1 while loop_i > #l_tbl[li] do loop_i=loop_i-#l_tbl[li] li=li+1 end if tbl ~= nil then if j == 1 then lr={} end local loop_n=#l_tbl[li] if loop_i == 1 then lr[li]={} for i=1,#tbl do if tbl[i][4] == "abs" then local a=math.abs(tbl[i][2]) local b=math.abs(tbl[i][3]) if a > b then a=b b=math.abs(tbl[i][2]) end lr[li][tbl[i][1]]=math.random(a,b)*2*(math.random(0,1)-0.5) else local a=tbl[i][2] local b=tbl[i][3] if a > b then a=b b=tbl[i][2] end lr[li][tbl[i][1]]=math.random(a,b) end end end end return"" end'
			l.effect="code once"
		else
		    local text=string.match(l.text,"(m [mlb%d%-%. ]+)")
			if text ~= nil then
				table.insert(shapes,{text=string.gsub(text,"%s+"," "),color=string.match(l.text,"c(&H[^&]+&)")})
			end
		end
		l.comment = true
		subtitles[i]=l
	end
	local i=2
	while i <= #shapes do
		local result=false
		for j=1,i-1 do
			if shapes[i].color == shapes[j].color then
				shapes[j].text=string.match(string.gsub(shapes[j].text.." "..shapes[i].text,"%s+"," "),"^%s*(.-)%s*$")
				result=true
				break
			end
		end
		if result then
			table.remove(shapes,i)
		else
			i=i+1
		end
	end
	for i=1,#shapes do
		shapes[i].text=shape_scale(shapes[i].text,xscale,yscale)
	end
	if #shapes >= 1 and mode ~= "none" then
		mode = mode*1
		local x1=bounding(shapes[1].text).left
		local x2=bounding(shapes[1].text).right
		local y1=bounding(shapes[1].text).top
		local y2=bounding(shapes[1].text).bottom
		for i=1,#shapes do
			shapes[i].text=shape_scale(shapes[i].text,xscale,yscale)
			x1=math.min(x1,bounding(shapes[i].text).left)
			x2=math.max(x2,bounding(shapes[i].text).right)
			y1=math.min(y1,bounding(shapes[i].text).top)
			y2=math.max(y2,bounding(shapes[i].text).bottom)
		end
		local b_tbl={left=x1,right=x2,center=(x1+x2)/2,top=y1,bottom=y2,middle=(y1+y2)/2,width=x2-x1,height=y2-y1}
		for i=1,#shapes do
			if mode == 7 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.left,-b_tbl.top)
			elseif mode == 1 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.left,-b_tbl.bottom)
			elseif mode == 2 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.center,-b_tbl.bottom)
			elseif mode == 3 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.right,-b_tbl.bottom)
			elseif mode == 4 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.left,-b_tbl.middle)
			elseif mode == 5 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.center,-b_tbl.middle)
			elseif mode == 6 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.right,-b_tbl.middle)
			elseif mode == 8 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.center,-b_tbl.top)
			elseif mode == 9 then
				shapes[i].text=Y.shape.move(shapes[i].text,-b_tbl.right,-b_tbl.top)
			end
		end
	end
	if li ~= 0 then
		local l=subtitles[li]
		local name=l.actor
		if name == "" then
			name="shapes"
		end
		l.text=string.format("%s={};",name)
		for j=1,#shapes do
			l.text=l.text..string.format("%s[%d]={text='%s',color='%s'};",l.actor,j,shapes[j].text,shapes[j].color)
		end
		subtitles[li]=l
	end
end

aegisub.register_macro(script_name, script_description, select_shape)