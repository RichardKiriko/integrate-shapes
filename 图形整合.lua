local tr = aegisub.gettext
script_name = tr("图形整合")
script_description = tr("整合图形及添加函数")
script_author = "kiriko"
script_version = "2.0"

include("unicode.lua")

function select_shape(subtitles, selected_lines, active_line)
	local shapes={}
	local li=0
	for z, i in ipairs(selected_lines) do
		local l = subtitles[i]
		if l.effect == "shapes" then
			li=i
			l.effect="code once"
		elseif l.effect == "loop_random" then
			l.text='function loop_random(loop_n,n2,tbl) maxloop(loop_n*n2) li=math.ceil(j/loop_n) if j%loop_n == 0 then loop_i=loop_n else loop_i=j%loop_n end if tbl ~= nil then if j == 1 then lr={} end if loop_i == 1 then lr[li]={} for i=1,#tbl do if tbl[i][4] == "abs" then local a=math.abs(tbl[i][2]) local b=math.abs(tbl[i][3]) if a > b then a=b b=math.abs(tbl[i][2]) end lr[li][tbl[i][1]]=math.random(a,b)*2*(math.random(0,1)-0.5) else local a=tbl[i][2] local b=tbl[i][3] if a > b then a=b b=tbl[i][2] end lr[li][tbl[i][1]]=math.random(a,b) end end end end return"" end'
			l.effect="code once"
		elseif l.effect == "double_loop" then
			l.text='function double_loop(l_tbl,tbl) local n=0 for i=1,#l_tbl do n=n+#l_tbl[i] end maxloop(n) loop_i=j li=1 while loop_i > #l_tbl[li] do loop_i=loop_i-#l_tbl[li] li=li+1 end if tbl ~= nil then if j == 1 then lr={} end local loop_n=#l_tbl[li] if loop_i == 1 then lr[li]={} for i=1,#tbl do if tbl[i][4] == "abs" then local a=math.abs(tbl[i][2]) local b=math.abs(tbl[i][3]) if a > b then a=b b=math.abs(tbl[i][2]) end lr[li][tbl[i][1]]=math.random(a,b)*2*(math.random(0,1)-0.5) else local a=tbl[i][2] local b=tbl[i][3] if a > b then a=b b=tbl[i][2] end lr[li][tbl[i][1]]=math.random(a,b) end end end end return"" end'
			l.effect="code once"
		else
		    local text=string.match(l.text,"(m [mlb%d%-%. ]+)")
			if text == nil then
				text=""
			end
			table.insert(shapes,{text=string.gsub(text,"%s+"," "),color=string.match(l.text,"c(&H[^&]+&)")})
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