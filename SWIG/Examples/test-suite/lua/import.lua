-- import
function import(module,intoglobal)
	-- imports the file into the program
	-- for a module example
	-- this must load 'example.dll' or 'example.so'
	-- and look for the fn 'Example_Init()' (note the capitalisation)
	
	-- capitialising the first letter
	local c=string.upper(string.sub(module,1,1))
	local fnname=c..string.sub(module,2).."_Init"
	
        -- attempt to load the module using Unix and Windows dll/shared object
	local loadlibrary = loadlib(module..".so",fnname)
        if loadlibrary == nil then
          loadlibrary = loadlib(module..".dll",fnname)
        end
        assert(loadlibrary~=nil,"could not load module")
        loadlibrary()
	
	-- moving to global namespace
	if intoglobal then
		--m=raw_get(_G,module)	-- gets the module object
		local m=_G[module]	-- gets the module object
		assert(m~=nil,"no module table found")
		local k,v
		for k,v in m do _G[k]=v end
	end
end
