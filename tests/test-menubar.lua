-- Test the menubar

local runner = require("_runner")
local menubar = require("menubar")

local menubar_refreshed = false
local orig_refresh = menubar.refresh
function menubar.refresh(...)
    menubar_refreshed = true
    orig_refresh(...)
end

-- XXX This test sporadically errors on LuaJIT ("attempt to call a number
-- value"). This might be a different issue, but still, disable the test.
-- And also breaks other tests due to weirdness of older lgi version.
if os.getenv('LGIVER') == '0.8.0' or jit then --luacheck: globals jit
    print("Skipping this test since it would just fail.")
    runner.run_steps { function() return true end }
    return
end

-- Make sure no error messages for non-existing directories are printed. If the
-- word "error" appears in our output, the test is considered to have failed.
do
    local gdebug = require("gears.debug")
    local orig_warning = gdebug.print_warning
    function gdebug.print_warning(msg)
        msg = tostring(msg)
        if (not msg:match("/dev/null/.local/share/applications")) and
                (not msg:match("No such file or directory")) then
            orig_warning(msg)
        end
    end
end

local show_menubar_and_hide = function(count)
    -- Just show the menubar and hide it.
    -- TODO: Write a proper test. But for the mean time this is better than
    -- nothing (and tells us when errors are thrown).

    if count == 1 then
        menubar.show()
    end

    -- Test that the async population of the menubar is done
    if menubar_refreshed then
        menubar.hide()
        awesome.sync()
        return true
    end
end

local refresh_on_show_when_cache_off = function()
    menubar_refreshed = false
    menubar.cache_entries = false
    menubar.show()
    menubar.hide()
    awesome.sync()
    return menubar_refreshed;
end

local no_refresh_on_second_show_when_cache_on = function()
    menubar.cache_entries = true
    -- Ensure that we have loaded the cache
    menubar.show()
    menubar.hide()
    awesome.sync()

    -- Now show again
    menubar_refreshed = false
    menubar.show()
    menubar.hide()
    awesome.sync()
    return not menubar_refreshed;
end

runner.run_steps {
    function(count)
        -- Show and hide with defaults
        return show_menubar_and_hide(count)
    end,

    function(count)
        -- Show and hide with match_empty set to false
        menubar.match_empty = false
        return show_menubar_and_hide(count)
    end,

    function(_)
        -- Show and hide with cache disabled
        return refresh_on_show_when_cache_off()
    end,

    function(_)
        -- Show twice and confirm that cache is not set afterward
        return no_refresh_on_second_show_when_cache_on()
    end,

    function()
        return true
    end
}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
