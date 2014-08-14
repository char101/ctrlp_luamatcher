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
            pattern = pattern .. '[\\/][^\\/]*'
        else
            c = lua_escapes[c] or c
            pattern = pattern .. c .. '[^' .. c .. ']*'
        end
    end
    return pattern
end

function vim_search_pattern(search)
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
            pattern = pattern .. '[\\\\\\/][^\\\\\\/]*'
        else
            c = vim_escapes[c] or c
            pattern = pattern .. c .. '[^' .. c .. ']*'
        end
    end
    return pattern .. search:sub(-1)
end

function ctrlp_lua_match()
    local items = vim.eval('a:items')
    local search = vim.eval('a:str'):lower()
    local match_mode = vim.eval('a:mmode')
    local ispath = vim.eval('a:ispath') == 1
    local currentfile = vim.eval('a:crfile')
    local filename_only = match_mode == 'filename-only'
    local pattern = lua_search_pattern(search)

    local temp_result = {}
    for item in items() do
        if not ispath or item ~= currentfile then
            if filename_only then
                item = item.gsub(item, '[^\\/]*[\\/]', '')
            end
            if string.find(item:lower(), pattern) then
                table.insert(temp_result, item)
            end
        end
    end

    table.sort(temp_result, function(a, b)
        if #a < #b then
            return true
        else
            return false
        end
    end)

    local limit = vim.eval('a:limit')
    local result = vim.eval('result')
    for i, item in ipairs(temp_result) do
        if i <= limit then
            result:add(item)
        end
    end
end

function ctrlp_lua_regex()
    return vim_search_pattern(vim.eval('a:str'):lower())
end
EOF

func! ctrlp#luamatcher#Match(items, str, limit, mmode, ispath, crfile, regex)
    call clearmatches()

    if a:str == ''
        return a:items[0:a:limit]
    endif

    call matchadd('CtrlPMatch', '\v\c' . (a:mmode == 'filename-only' ? '[\^\/]*' : '') . luaeval('ctrlp_lua_regex()'))

    let result = []
    lua ctrlp_lua_match()
    return result
endf
