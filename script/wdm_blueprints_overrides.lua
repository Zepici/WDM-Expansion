local M = {}

local BLUEPRINT_NAMES = { "pirate_ship_10" }

-- Put your 3 blueprint strings here for rotation testing.
local TEST_BLUEPRINT_SLOTS = {
    [1] = "0eNqVl+1OgzAUhu+lv3GB0k9uxSzLNqtpwsoEpi4L9y5Mo8bwBt6fW9qnzzvO6Q43cagv4dzG1IvqJuKxSZ2oHm+iiy9pX0/fpf0piEp0fZPCw/u+rsWQiZiewoeoiiGbWdo2h+bctP2fhXLYZiKkPvYxfB1w/3DdpcvpENqRlM0clIlz041bmjTRp/OM2ehMXEVVlhs9TKf/40iWI+c55UqOXeAolgNy6ZUct+BjVnL8AseyPiCXY30Ax6/j2HwhV5GvBBVLoII1AskKyRoh0MqatnIp2sqituUSSLMgFM2w0RDIsveHBiDHghQAefYGAUYyZ0HASBbsU0MgyYJQNLqykZFiQchIs4/fApBhQQaALPv4kZFjQcjot7J/Joa5+/EbMg4TbXi9hK7fPce6D203LenCcVr9NVP8TCXb2b/0nC03IF7SDQB+ylKy5YaM6AZARvS84gGIbgAEohvAARDdAAhEzywommeHKABSOWsEoqmCNUIgemhB0Up2jEIgxRqhaJo1QiDDXiMommW7H4Eca4SiedboDhrfEWMfTuOu37fSTLyNV/19jzbSK++1U7nMlRuGTyOvscM=",
    [2] = "0eNqVm9tuG0cQBf9lnzfG3uamXwkMQ3I2AQFqKZNUbEPgv0eUg/AhLMzUmyRwS+dou6d7pkdv3dP+dX057rZz9/DW7b4etlP38Ptbd9r9tT3urz/bHp/X7qE7nQ/b+tv3x/2+u/Tdbvtj/dE9jJfPfbdu5915t/567uObn1+21+en9fj+gf7O8333cji9P3LYrvwrJqZPoe9+vn81fgqXS/8/ztTIyRXO3MgpFc7SxklDhRMaOWOFExs5U4WT7Pua7nOy5cz3OcW+d9AzDvbFE2i0isDZOFlFBJptLJK1xQYjgYJVRNaiVUSgZPODrGULIkXFZsgCK+NgQQFAOrJJkY5sAs1WEVlbrCIC6cgmazqyCZSsIrKWrSICFZsiYG0eLAgUzboLiQCaLCgBSEc2KdKRTaBgFZG1aBURSEc2WdORTaBiFYG1ZbCKCDTaFAFry2RBpGi2KZIBtFhQAZCObFKkI5tAySoia9kqIpCObLAWdGQTaLSKwFqYrCICzTZFyNpiQaQoyBSZBgBFC6LtbGtkxxooyxRBa0WmCIGi3UGStWj7bARNMkXQ2ixTBEF2B4nWbJ+NIHswgtZau5G5psjuIBHUGtn/KYKtaGqN7KkGGq0i2GWnySoiUGs3EmrWWruRpQYKVhFZi1YRgeyZH1rLdvEnkD0bIWt5sIoINNrFn0D2IBtBes0mkD3KRlCwCxu8/hztUksge+qH1rJVRKDWPru2HpXWPru2HpXRKgJrZbKKCNQa2bX1qLRGdm09KsEqImvRKiJQa2SXmrXWyM41ULGKcFIzWElI0v1IIJJuSJA0W00LkRarCUm6J0F3uilBUrKa0F22mpCk+xJyN+rGBEn2bBvdNQ8kY5V0i/Hj4enwcjie7zYU/zq79N1x/fa6ns5f/tztz+vxdP3Iaf16/fSvWwW36wb3f6E9UeE/Z7CVHkl654l/Tr31RFK2xR7dFVvtidQ6v0zVRG8dYKZqordOMFM10VtHmKma6K0zzFRN9OYhZjXRm6eYpeou2aKPpGw1obtiNRGpdZJ5K/qJSKMt+kiarKZIpNlqQtJiiz66C7boIylaTeguWU1Ister2F2xRZ9Ii72Hgu5ah5o3TUjSpy3ozl4cZJI+b0GSvTzIJN2rIEn3KkjS5+QYBcVqIlLQvQq5C7pXQdJkNaG72WpCku5V0J3uVZAUrSZ0l6wmJOleBd3pXoVIrXPOmyZy1zrovGlCkt6aZiLZ6ylMWmxtQVKwtQVJ0dYWJCVbW5Ck13Ek6XX8g/S573bn9fn9qdu/OvTd3+vx9PFMiFNZSgl5GaZhyZfLP9GOh24=",
    [3] = "0eNqVmu1umzAYhe+F37QCG3/lVqaqSjs2IaWkA7KtqnLvS5qpXSdO7OffOpGHc/DL62Ob1+phd+ifp2Fcqs1rNTzux7nafHmt5uH7uN2d/2/cPvXVppqX/djf/NrudtWxrobxa/+72rTHeuXS3Xbup5vlME398s/F5nhXV/24DMvQX27y9sfL/Xh4euinE61euVldPe/n00/24/kO53v6cOvq6uX0r/bWHc8K/uOYQk7McGwhJ2U4XRknNBmOK+S0GY4v5JgMJ9DxMuucSDl2nZPouAs9bUMHXoFaqkg4aw1VpECW1qKy1tFiVCBHFSlrnipSoEDfD2UtUpBSlOgb0onO2NCCVKCWFqQCGTr8CmTp8CtQR0dNgT4q+9OMuPKU/AUUVjGeDn4QekKxnngB+VVMpDWk9CRaQwJkm1JjoblizLa0FJUeQ0tRgWyxMXPNGK5opae4okN3TY8vxvhrmPJ6/qsmrmJw/Iji6eAunURexF1aKOpwl1YgHKmVNZypFQiHamUNp2oF8lSRshaoIgXC+UNZSxQkFLmGNpDVV9a1tIGsYwxsIKZZxVg4zwtMB9uHacRDdhSk1pulycPnQAG2D2ktwvYhQTR7KGue9moJoulDWfM0fUgQTdTSGu3VEuRgH5LWSnu1zSmia0UJirAzrjcRn2BnXMeE0qp+fz5i5RpKE4jJgQxVJBblwVJFClTar13OWmm/7nIgTxUpa4EqUiCaraW1RKciAYoNVaQ2LVuqSIHo3p4EWToVKRDd25MgurcnQXTLWg5/oI1fgWi2ltYSVSRAqbCyQ64fpdIkkutHyVBFypqlihSotLJz/SiVVnauHyVPFSlrgSpSoNLKTjlrpZUdM6C2aagkebLTUk2ShAOJUyScSCSpo5o6RXJUkyThUCLd4VQiSZFqku4S1aRILQ4myl2Lk4kkGapJurNUkyR91Pi0f9g/76crG/3GHetq6n8c+nm5/zbsln6az5fM/eP56stXCO/fMtyt3xAvOuXjxKtOScLLTvk4I9UkSYnO9spd6SllyL7opceUIfuiF59TZl/04oPK7ItefFKZfdGNo5qkO081SVKgk750F+mkL0mJalLubEM1SVJLJ/2gSIZO+pJkqSavSB3VJEmOTvrSnaeTviQFqkm6i1STJNFjTOmu+BzTZ0n000Dprvgk02dJeLtFuuvoDpAk4Q0XSaJfU2kSziqShLOKJNEDTVkFrqGaJAlnFeXO4awiSZZqku46qkmScFaR7nBWkaRANUl3kWqSJJxVlDuPs4oktVSTcld8yhk/ke7qalj6p9OvPr57r6ufp2Xh22+cN6lLycWuMU0Xj8c/mcX05A=="
}

local function debug_log(debug_fn, message)
    if debug_fn then debug_fn(message) end
end

local function apply_override_to_name(name, blueprint_string, debug_fn)
    local ok, err = pcall(function()
        remote.call("WDM", "add_wdm_blueprint", name, blueprint_string)
    end)

    if ok then
        debug_log(debug_fn, "Applied WDM blueprint override: " .. name)
        return true
    end

    debug_log(debug_fn, "Failed to apply WDM blueprint override '" .. tostring(name) .. "': " .. tostring(err))
    return false
end

local function ensure_override_state()
    storage.wdm_blueprint_override_state = storage.wdm_blueprint_override_state or { index = 1 }
    local state = storage.wdm_blueprint_override_state
    if type(state.index) ~= "number" or state.index < 1 or state.index > #TEST_BLUEPRINT_SLOTS then
        state.index = 1
    end
    return state
end

local function apply_current_slot(debug_fn)
    if not remote.interfaces["WDM"] then
        debug_log(debug_fn, "WDM interface not found, cannot override WDM blueprints")
        return false
    end

    local state = ensure_override_state()
    local blueprint_string = TEST_BLUEPRINT_SLOTS[state.index]
    if type(blueprint_string) ~= "string" or blueprint_string == "" then
        debug_log(debug_fn, "WDM blueprint slot #" .. tostring(state.index) .. " is empty, override skipped")
        return false
    end

    local applied = false
    for _, name in ipairs(BLUEPRINT_NAMES) do
        if apply_override_to_name(name, blueprint_string, debug_fn) then
            applied = true
        end
    end

    if applied then
        debug_log(debug_fn, "Applied WDM blueprint slot #" .. tostring(state.index))
    end

    return applied
end

function M.register_wdm_blueprint_overrides(debug_fn)
    local state = ensure_override_state()
    state.index = math.random(1, #TEST_BLUEPRINT_SLOTS)
    debug_log(debug_fn, "Selected random WDM blueprint slot #" .. tostring(state.index))
    return apply_current_slot(debug_fn)
end

return M
