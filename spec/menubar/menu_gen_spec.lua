local menu_gen = require("menubar.menu_gen")

menu_gen.all_menu_dirs = {
    (os.getenv("SOURCE_DIRECTORY") or '.') .. "/spec/menubar/home/.local/share",
    (os.getenv("SOURCE_DIRECTORY") or '.') .. "/spec/menubar/usr/share"
}

describe("menubar.menu_gen generate", function()
    it("Removes .desktop entries with duplicate IDs", function()
        async() -- DOES NOT WORK IN BUSTED 2.0
        local function callback(result)
            local names = {}
            for entry in pairs(result) do
                names[entry.name] = (names[entry.name] or 0) + 1
            end
            assert.is_equal(names["Test Dupe In Usr"], 0)
            assert.is_equal(names["Test Dupe In Home"], 1)
            done()
        end

        menu_gen.generate(callback)
    end)
end)
