--[[
该插件作用为：
	1.整合各部分图形，合并同色部分，得到图形的表格
		表格格式：{{text="",color=""},{text="",color=""}...}
	2.根据需要添加函数loop_random和double_loop，函数源码见下方
使用方式：
	选中各部分图形的行和为表格或函数预留出的行（若未按指定格式预留则不会添加），应用插件
格式：
	图形：根据颜色分成多行，每行至少包含以下信息——图形颜色（如c&HFFFFFF&）和图形绘图代码
	表格：在 说话人/actor 栏中输入表格名称，在 特效/effect 栏输入 shapes
	函数：在 特效/effect 栏输入 loop_random 或者 double_loop
函数说明：
	loop_random：
		输入：
			loop_n：单组循环的次数
			n2：整组重复的次数
			tbl：添加随机数，格式为{{"name1",value1,value2[,"abs"]},{"name2",value1,value2[,"abs"]}...}
			     会为每一组创建一个随机数，储存在 lr 中，值的范围是[value1,value2]
				 若添加"abs"，则取值正负随机，绝对值范围为value1和value2两者绝对值之间
		输出：空字符串
		可用变量：
			li：整组循环次数
			loop_i：在当前组内的循环计数
			lr：随机数的表，lr[i].name即调用第i组循环中的名为 name 的随机数
	double_loop：
		输入：
			l_tbl：循环的数量表格，以l_tbl每个元素的元素数为一组，即l_tbl的每个元素的格式都是table
			tbl：添加随机数，格式为{{"name1",value1,value2[,"abs"]},{"name2",value1,value2[,"abs"]}...}
			     会为每一组创建一个随机数，储存在 lr 中，值的范围是[value1,value2]
				 若添加"abs"，则取值正负随机，绝对值范围为value1和value2两者绝对值之间
		输出：空字符串
		可用变量：
			li：循环到l_tbl第li个元素，即第li组
			loop_i：当前组（l_tbl第li个元素）内的第loop_i个元素
			lr：随机数的表，lr[i].name即调用第i组循环中的名为 name 的随机数
]]--

function loop_random(loop_n,n2,tbl)
	maxloop(loop_n*n2)
	li=math.ceil(j/loop_n)
	if j%loop_n == 0 then
		loop_i=loop_n
	else
		loop_i=j%loop_n
	end
	if tbl ~= nil then
		if j == 1 then
			lr={}
		end
		if loop_i == 1 then
			lr[li]={}
			for i=1,#tbl do
				if tbl[i][4] == "abs" then
					local a=math.abs(tbl[i][2])
					local b=math.abs(tbl[i][3])
					if a > b then
						a=b
						b=math.abs(tbl[i][2])
					end
					lr[li][tbl[i][1]]=math.random(a,b)*2*(math.random(0,1)-0.5)
				else
					local a=tbl[i][2]
					local b=tbl[i][3]
					if a > b then
						a=b
						b=tbl[i][2]
					end
					lr[li][tbl[i][1]]=math.random(a,b)
				end
			end
		end
	end
return""
end

function double_loop(l_tbl,tbl)
	local n=0
	for i=1,#l_tbl do
		n=n+#l_tbl[i]
	end
	maxloop(n)
	loop_i=j
	li=1
	while loop_i > #l_tbl[li] do
		loop_i=loop_i-#l_tbl[li]
		li=li+1
	end
	if tbl ~= nil then
		if j == 1 then
			lr={}
		end
		local loop_n=#l_tbl[li]
		if loop_i == 1 then
			lr[li]={}
			for i=1,#tbl do
				if tbl[i][4] == "abs" then
					local a=math.abs(tbl[i][2])
					local b=math.abs(tbl[i][3])
					if a > b then
						a=b
						b=math.abs(tbl[i][2])
					end
					lr[li][tbl[i][1]]=math.random(a,b)*2*(math.random(0,1)-0.5)
				else
					local a=tbl[i][2]
					local b=tbl[i][3]
					if a > b then
						a=b
						b=tbl[i][2]
					end
					lr[li][tbl[i][1]]=math.random(a,b)
				end
			end
		end
	end
return""
end