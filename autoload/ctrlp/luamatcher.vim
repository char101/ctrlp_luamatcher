" lua fuzzy search based on https://github.com/rgieseke/textredux/blob/master/util/matcher.lua

lua << EOF
local lua_escapes = {}
for c in string.gmatch('^$()%.[]*+-?', '.') do
	lua_escapes[c] = '%' .. c
end

local vim_escapes = {}
for c in string.gmatch('^$.()[]{}+\\/', '.') do
	vim_escapes[c] = '\\' .. c
end

local function lua_search_pattern(search)
	if #search == 1 then
		return search
	end
	local pattern = ''
	for i = 1, #search do
		local c = search:sub(i, i)
		if c == '\\' or c == '/' then
			pattern = pattern .. '[\\/][^\\/]-'
		else
			c = lua_escapes[c] or c
			pattern = pattern .. c .. '[^' .. c .. ']-'
		end
	end
	return pattern
end

local function vim_search_pattern(search)
	if #search == 1 then
		return search
	end
	local lastchar = search:sub(-1)
	if lastchar == '\\' or lastchar == '/' then
		search = search:sub(1, -2)
	end
	local pattern = ''
	for i = 1, #search - 1 do
		local c = search:sub(i, i)
		if c == '\\' or c == '/' then
			pattern = pattern .. '[\\\\\\/][^\\\\\\/]{-}'
		else
			c = vim_escapes[c] or c
			pattern = pattern .. c .. '[^' .. c .. ']{-}'
		end
	end
	return pattern .. search:sub(-1)
end

local function find_shortest(string, search)
	-- local b, e = string.find(string, search)
	-- if b then
	-- 	return e-b
	-- end
	-- return b
	local found_len, begin
	local end_ = 0
	while true do
		begin, end_ = string.find(string, search, end_ + 1)
		if not begin then
			return found_len
		end
		local len = end_ - begin + 1
		if not found_len or len < found_len then
			found_len = len
		end
	end
	return found_len
end

local is_neovim = vim['api'] ~= nil and vim.api['nvim_eval'] ~= nil

if is_neovim then
	function to_vim_list(obj)
		return obj
	end
else
	function to_vim_list(obj)
		return vim.list(obj)
	end
end

function ctrlp_lua_match(items, str, limit, match_mode, ispathnum, currentfile)
	local search = str:lower()
	local ispath = ispathnum == 1
	local filename_only = match_mode == 'filename-only'

	local temp_result = {}
	local pattern = lua_search_pattern(search)
	for idx, item in ipairs(items) do
		if not ispath or item ~= currentfile then
			if filename_only then
				item = item.gsub(item, '[^\\/]*[\\/]', '')
			end
			if #search == 1 then
				if string.find(item:lower(), search, 1, true) then
					table.insert(temp_result, {item, 1})
				end
			else
				local len = find_shortest(item:lower(), pattern)
				if len then
					table.insert(temp_result, {item, len})
				end
			end
		end
	end

	table.sort(temp_result, function(a, b) return a[2] < b[2] or (a[2] == b[2] and #a[1] < #b[1]) end)

	local result = {}
	for i, item in ipairs(temp_result) do
		if i <= limit then
			table.insert(result, item[1])
		end
	end

	return to_vim_list(result)
end

function ctrlp_lua_regex(str)
	return vim_search_pattern(str:lower())
end
EOF

func! ctrlp#luamatcher#Match(items, str, limit, mmode, ispath, crfile, regex)
	call clearmatches()

	if a:str == ''
		return a:items[0:a:limit]
	endif

	call matchadd('CtrlPMatch', '\v\c' . (a:mmode == 'filename-only' ? '[\^\\\/]*' : '') . luaeval('ctrlp_lua_regex(_A.str)', { 'str': a:str }))

	let result = luaeval('ctrlp_lua_match(_A.items, _A.str, _A.limit, _A.mmode, _A.ispath, _A.crfile)', { 'items': a:items, 'str': a:str, 'limit': a:limit, 'mmode': a:mmode, 'ispath': a:ispath, 'crfile': a:crfile })
	return result
endf
