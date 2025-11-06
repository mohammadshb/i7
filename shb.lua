local KeysBin = MachoWebRequest("https://mohammadshb.github.io/i7/README.md")
local CurrentKey = MachoAuthenticationKey()

if not string.find(KeysBin, CurrentKey, 1, true) then
    MachoMenuNotification("Authentication Failed", "Your key is not authorized go to S H B")
    return
end

print("S H B MENU START!")

local dui = nil
local activeMenu = {}
local activeIndex = 1
local originalMenu = {}

-- Menu toggle key variables
local menuToggleKey = 137  -- CAPS كقيمة افتراضية
local menuToggleKeyText = "CAPS"
local menuToggleKeybindInputActive = false

-- S H B MENU
local shbMenuKey = nil
local shbMenuKeybindText = "None"
local shbMenuKeybindInputActive = false

-- Freecam variables
local freecamActive = false
local freecamCam = nil
local freecamSpeed = 2.0
local freecamSelectedKey = 0
local freecamKeybindText = "None"
local freecamKeybindInputActive = false
local freecamEnabled = false

-- Waypoint Teleport Keybind
local waypointKey = nil
local waypointKeybindText = "None"
local waypointKeybindInputActive = false
local waypointEnabled = false

-- Heal Player Keybind  
local healKey = nil
local healKeybindText = "None"
local healKeybindInputActive = false
local healEnabled = false

-- Teleport variables
local teleportCoords = vector3(-3944.15, -15998.42, -6.05)
local lastLocation = nil
local teleportEnabled = false
local teleportKey = nil
local teleportKeybindText = "None"
local teleportKeybindInputActive = false

-- Ultimate RP variables
local ultimateRpEnabled = false
local ultimateRpKey = nil
local ultimateRpKeybindText = "None"
local ultimateRpKeybindInputActive = false
local ultimateRpCoords = vector3(2121.559, 4510.059, -100.124)

-- Menu state tracking
local menuInitialized = false

-- Self menu features variables
local godmodeEnabled = false
local superJumpEnabled = false
local superSpeedLoop = false
local noclipEnabled = false
local noclipActive = false
local invisibilityEnabled = false
local infiniteStaminaEnabled = false
local noRagdollEnabled = false

-- Noclip settings
local speedLevels = {
    {label = "Very Slow", value = 0.5, rotation = 0.5},
    {label = "Slow", value = 1.0, rotation = 1.0},
    {label = "Normal", value = 2.0, rotation = 2.0},
    {label = "Fast", value = 4.0, rotation = 4.0},
    {label = "Very Fast", value = 6.0, rotation = 6.0},
    {label = "Super Fast", value = 8.0, rotation = 8.0},
    {label = "Ultra Fast", value = 16.0, rotation = 12.0},
    {label = "Max Speed", value = 24.0, rotation = 16.0}
}
local currentSpeedIndex = 3
local camMode = false
local noclipSelectedKey = 0
local noclipKeybindText = "None"
local noclipKeybindInputActive = false
local scaleform = nil
local alphaValue = 128

-- Wara & 8dam variables
local waraAttached = false
local waraAttachedTo = nil
local eightDamAttached = false
local eightDamAttachedTo = nil

-- ======= وظائف الفري كام =======
local function StartFreeCamera()
    if freecamActive then return end
    
    freecamActive = true
    local playerPed = PlayerPedId()
    
    -- إخفاء القائمة أثناء الفري كام
    if menuInitialized then
        _G.clientMenuShowing = false
    end
    
    -- إنشاء الكاميرا
    local camCoords = GetGameplayCamCoord()
    local camRotation = GetGameplayCamRot(2)
    freecamCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    SetCamCoord(freecamCam, camCoords.x, camCoords.y, camCoords.z)
    SetCamRot(freecamCam, camRotation.x, camRotation.y, camRotation.z, 2)
    SetCamActive(freecamCam, true)
    RenderScriptCams(true, true, 1000, true, true)
    
    -- ثريد الحركة الرئيسي
    Citizen.CreateThread(function()
        while freecamActive do
            Citizen.Wait(0)
            
            -- السماح بضغط ESC والخروج
            EnableControlAction(0, 200, true) -- ESC
            EnableControlAction(0, 177, true) -- Backspace
            
            -- خروج بـ ESC
            if IsControlJustPressed(0, 200) then -- ESC
                freecamActive = false
                break
            end
            
            -- الحصول على إحداثيات واتجاه الكاميرا
            local currentCamCoords = GetCamCoord(freecamCam)
            local currentCamRot = GetCamRot(freecamCam, 2)
            
            -- السرعة الحالية
            local currentSpeed = freecamSpeed
            
            -- التحكم في السرعة بالشفت
            if IsControlPressed(0, 21) then -- LSHIFT للسرعة
                currentSpeed = currentSpeed * 4
            end
            
            -- الحصول على اتجاه الكاميرا
            local camHeading = currentCamRot.z
            local camPitch = currentCamRot.x
            
            -- تحويل إلى راديان
            local headingRad = camHeading * 3.14159 / 180.0
            local pitchRad = camPitch * 3.14159 / 180.0
            
            -- حساب الاتجاه الثلاثي الأبعاد
            local dirX = -math.sin(headingRad) * math.cos(pitchRad)
            local dirY = math.cos(headingRad) * math.cos(pitchRad)
            local dirZ = math.sin(pitchRad)
            
            -- الحركة الأمامية/الخلفية (W/S)
            if IsControlPressed(0, 32) then -- W للأمام
                SetCamCoord(freecamCam, 
                    currentCamCoords.x + currentSpeed * dirX,
                    currentCamCoords.y + currentSpeed * dirY,
                    currentCamCoords.z + currentSpeed * dirZ
                )
            end
            
            if IsControlPressed(0, 33) then -- S للخلف
                SetCamCoord(freecamCam, 
                    currentCamCoords.x - currentSpeed * dirX,
                    currentCamCoords.y - currentSpeed * dirY,
                    currentCamCoords.z - currentSpeed * dirZ
                )
            end
            
            -- الحركة الجانبية (A/D)
            if IsControlPressed(0, 34) then -- A لليسار
                local leftX = -math.cos(headingRad)
                local leftY = -math.sin(headingRad)
                SetCamCoord(freecamCam, 
                    currentCamCoords.x + currentSpeed * leftX,
                    currentCamCoords.y + currentSpeed * leftY,
                    currentCamCoords.z
                )
            end
            
            if IsControlPressed(0, 35) then -- D لليمين
                local rightX = math.cos(headingRad)
                local rightY = math.sin(headingRad)
                SetCamCoord(freecamCam, 
                    currentCamCoords.x + currentSpeed * rightX,
                    currentCamCoords.y + currentSpeed * rightY,
                    currentCamCoords.z
                )
            end
            
            -- الحركة الرأسية (Q/E)
            if IsControlPressed(0, 44) then -- Q للأعلى
                SetCamCoord(freecamCam, 
                    currentCamCoords.x,
                    currentCamCoords.y, 
                    currentCamCoords.z + currentSpeed
                )
            end
            
            if IsControlPressed(0, 38) then -- E للأسفل
                SetCamCoord(freecamCam, 
                    currentCamCoords.x,
                    currentCamCoords.y, 
                    currentCamCoords.z - currentSpeed
                )
            end
            
            -- دوران الكاميرا بالماوس
            local lookX = GetDisabledControlNormal(0, 1) * 5.0
            local lookY = GetDisabledControlNormal(0, 2) * 5.0
            
            local newRotX = currentCamRot.x - lookY
            local newRotZ = currentCamRot.z - lookX
            
            -- تحديد الحد الأقصى للدوران
            if newRotX < -89.0 then newRotX = -89.0 end
            if newRotX > 89.0 then newRotX = 89.0 end
            
            SetCamRot(freecamCam, newRotX, 0.0, newRotZ, 2)
            
            -- تحديث التركيز
            local newCoords = GetCamCoord(freecamCam)
            SetFocusArea(newCoords.x, newCoords.y, newCoords.z, 0.0, 0.0, 0.0)
        end
        
        -- تنظيف بعد الخروج
        RenderScriptCams(false, true, 1000, true, true)
        if freecamCam then
            DestroyCam(freecamCam, false)
            freecamCam = nil
        end
        
        SetFocusEntity(PlayerPedId())
        
        -- إرسال إشعار إيقاف
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "Free Camera - Deactivated",
                type = 'info'
            }))
        end
    end)
end

local function StopFreeCamera()
    if not freecamActive then return end
    freecamActive = false
end

local function ToggleFreeCamera()
    if freecamActive then
        StopFreeCamera()
    else
        StartFreeCamera()
    end
end

-- ======= وظائف النوكلب المتقدمة =======
local function SetupInstructions()
    scaleform = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
    while not HasScaleformMovieLoaded(scaleform) do Wait(0) end

    local function Button(slot, control, label)
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(slot)
        N_0xe83a3e3557a56640(GetControlInstructionalButton(0, control, true))
        BeginTextCommandScaleformString("STRING")
        AddTextComponentSubstringKeyboardDisplay(label)
        EndTextCommandScaleformString()
        PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    local i = 0
    Button(i, 21, "Change Speed ("..speedLevels[currentSpeedIndex].label..")") i=i+1
    Button(i, 35, "Turn Left/Right") i=i+1
    Button(i, 32, "Move") i=i+1
    Button(i, 20, "Down") i=i+1
    Button(i, 44, "Up") i=i+1
    Button(i, 74, "Cam Mode") i=i+1
    Button(i, 289, "Toggle NoClip") i=i+1

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()
end

local function DrawInstructions()
    if scaleform and noclipActive then
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end
end

local function ApplyInvisibility(ped)
    NetworkSetEntityInvisibleToNetwork(ped, true)
    SetEntityVisible(ped, true, false)
    SetEntityAlpha(ped, alphaValue, false)
end

local function RemoveInvisibility(ped)
    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetEntityVisible(ped, true, false)
    ResetEntityAlpha(ped)
end

local function ActivateNoclip()
    noclipActive = true
    local ped = PlayerPedId()
    local player = PlayerId()
    
    SetupInstructions()

    -- 🔧 الفيزياء أولاً
    SetEntityCollision(ped, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityVelocity(ped, 0.0, 0.0, 0.0)

    -- 🎯 الإخفاء عن الآخرين
    SetEntityVisible(ped, false, false)
    NetworkSetEntityInvisibleToNetwork(ped, true)
    SetPlayerInvisibleLocally(player, true)

    -- 🔥 السحر: إعادة الظهور لك فقط مع الشفافية
    SetEntityLocallyVisible(ped)
    SetEntityAlpha(ped, 80, false)

    -- 🔄 نضمن استمرارية الرؤية المحلية
    Citizen.CreateThread(function()
        while noclipActive do
            SetEntityLocallyVisible(ped)
            SetEntityAlpha(ped, 80, false)
            Citizen.Wait(0)
        end
    end)

    if dui then
        MachoSendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "Noclip Activated - Transparent to you, invisible to others",
            type = 'success'
        }))
    end
end

local function DeactivateNoclip()
    noclipActive = false
    local ped = PlayerPedId()
    local player = PlayerId()

    -- إعادة كل شيء طبيعي
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)
    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetPlayerInvisibleLocally(player, false)
    ResetEntityAlpha(ped)
    SetEntityAlpha(ped, 255, false)

    if dui then
        MachoSendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "Noclip Deactivated - Fully visible",
            type = 'info'
        }))
    end
end

-- ثريد النوكلب الرئيسي
Citizen.CreateThread(function()
    while true do
        Wait(0)

        if noclipActive then
            -- السماح بالأزرار الأساسية للتحكم في النوكلب
            EnableControlAction(0, 1, true)   -- Look left/right
            EnableControlAction(0, 2, true)   -- Look up/down
            EnableControlAction(0, 11, true)  -- F2
            EnableControlAction(0, 289, true) -- F2
            EnableControlAction(0, 200, true) -- ESC
            EnableControlAction(0, 177, true) -- Backspace
            
            -- أزرار النوكلب الأساسية
            EnableControlAction(0, 21, true)  -- LSHIFT
            EnableControlAction(0, 74, true)  -- H
            EnableControlAction(0, 32, true)  -- W
            EnableControlAction(0, 33, true)  -- S
            EnableControlAction(0, 34, true)  -- A
            EnableControlAction(0, 35, true)  -- D
            EnableControlAction(0, 44, true)  -- Q (طلوع)
            EnableControlAction(0, 38, true)  -- E (نزول)

            DrawInstructions()

            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local x, y, z = coords.x, coords.y, coords.z
            local speed = speedLevels[currentSpeedIndex].value
            local rotationSpeed = speedLevels[currentSpeedIndex].rotation

            -- تغيير السرعة
            if IsControlJustPressed(0, 21) then
                currentSpeedIndex = currentSpeedIndex + 1
                if currentSpeedIndex > #speedLevels then currentSpeedIndex = 1 end
                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Speed: " .. speedLevels[currentSpeedIndex].label,
                        type = 'info'
                    }))
                end
                SetupInstructions()
            end

            -- تبديل وضع الكاميرا
            if IsControlJustPressed(0, 74) then
                camMode = not camMode
                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Cam Mode: " .. (camMode and "Camera" or "Heading"),
                        type = 'info'
                    }))
                end
            end

            -- 🔥 نظام الحركة المنفصل حسب النمط
            if camMode then
                -- النمط الأول: الحركة حسب الكاميرا (بدون دوران)
                local camRot = GetGameplayCamRot(2)
                local camHeading = camRot.z
                local camPitch = camRot.x

                local headingRad = math.rad(camHeading)
                local pitchRad = math.rad(camPitch)
                
                local forwardX = -math.sin(headingRad) * math.cos(pitchRad)
                local forwardY = math.cos(headingRad) * math.cos(pitchRad)
                local forwardZ = math.sin(pitchRad)
                
                local rightX = math.cos(headingRad)
                local rightY = math.sin(headingRad)

                -- الحركة الأمامية/الخلفية (W/S)
                if IsControlPressed(0, 32) then -- W
                    x = x + forwardX * speed
                    y = y + forwardY * speed
                    z = z + forwardZ * speed
                end
                
                if IsControlPressed(0, 33) then -- S
                    x = x - forwardX * speed
                    y = y - forwardY * speed
                    z = z - forwardZ * speed
                end

                -- الحركة الجانبية (A/D)
                if IsControlPressed(0, 34) then -- A
                    x = x - rightX * speed
                    y = y - rightY * speed
                end
                
                if IsControlPressed(0, 35) then -- D
                    x = x + rightX * speed
                    y = y + rightY * speed
                end

            else
                -- النمط الثاني: الحركة حسب اتجاه اللاعب (مع دوران)
                local pedHeading = GetEntityHeading(ped)
                
                -- الدوران (A/D)
                if IsControlPressed(0, 34) then -- A للدوران يسار
                    SetEntityHeading(ped, pedHeading + rotationSpeed)
                end
                
                if IsControlPressed(0, 35) then -- D للدوران يمين
                    SetEntityHeading(ped, pedHeading - rotationSpeed)
                end
                
                -- تحديث الاتجاه بعد الدوران
                pedHeading = GetEntityHeading(ped)
                local rad = math.rad(pedHeading)
                
                -- اتجاهات الحركة بناءً على اتجاه اللاعب
                local forwardX = -math.sin(rad)
                local forwardY = math.cos(rad)

                -- الحركة الأمامية/الخلفية (W/S)
                if IsControlPressed(0, 32) then -- W للأمام
                    x = x + forwardX * speed
                    y = y + forwardY * speed
                end
                
                if IsControlPressed(0, 33) then -- S للخلف
                    x = x - forwardX * speed
                    y = y - forwardY * speed
                end
            end

            -- الحركة الرأسية (Q/E) - مشتركة بين النمطين
            if IsControlPressed(0, 44) then -- Q للأعلى
                z = z + speed
            end
            
            if IsControlPressed(0, 38) then -- E للأسفل
                z = z - speed
            end

            -- تحديث الموقع
            SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
            SetEntityVelocity(ped, 0.0, 0.0, 0.0)
        end
    end
end)

-- ======= وظائف التليبورت مع الهيل التلقائي =======
local function TeleportToUltimateRP()
    local ped = PlayerPedId()
    local currentCoords = GetEntityCoords(ped)
    
    local distance = #(currentCoords - ultimateRpCoords)
    
    if distance > 50.0 then
        lastLocation = currentCoords
        SetEntityCoords(ped, ultimateRpCoords.x, ultimateRpCoords.y, ultimateRpCoords.z, false, false, false, true)
        
        -- هيل تلقائي بعد التليبورت
        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 100)
        
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "Teleported to Ultimate RP + Auto Heal",
                type = 'success'
            }))
        end
    else
        if lastLocation ~= nil then
            SetEntityCoords(ped, lastLocation.x, lastLocation.y, lastLocation.z, false, false, false, true)
            
            -- هيل تلقائي بعد العودة
            SetEntityHealth(ped, 200)
            SetPedArmour(ped, 100)
            
            if dui then
                MachoSendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "Returned from Ultimate RP + Auto Heal",
                    type = 'info'
                }))
            end
        end
    end
end

local function TeleportToCustom()
    local ped = PlayerPedId()
    local currentCoords = GetEntityCoords(ped)
    
    local distance = #(currentCoords - teleportCoords)
    
    if distance > 50.0 then
        lastLocation = currentCoords
        SetEntityCoords(ped, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false, true)
        
        -- هيل تلقائي بعد التليبورت
        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 100)
        
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "Teleported to destination + Auto Heal",
                type = 'success'
            }))
        end
    else
        if lastLocation ~= nil then
            SetEntityCoords(ped, lastLocation.x, lastLocation.y, lastLocation.z, false, false, false, true)
            
            -- هيل تلقائي بعد العودة
            SetEntityHealth(ped, 200)
            SetPedArmour(ped, 100)
            
            if dui then
                MachoSendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "Returned to original location + Auto Heal",
                    type = 'info'
                }))
            end
        end
    end
end

-- ======= وظائف Wara و 8dam =======
local function GetClosestPlayer()
    local ped = PlayerPedId()
    local myCoords = GetEntityCoords(ped)
    local closestPlayer, closestDist = -1, 999.0

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= ped then
            local dist = #(myCoords - GetEntityCoords(targetPed))
            if dist < closestDist then
                closestDist = dist
                closestPlayer = player
            end
        end
    end

    return closestPlayer, closestDist
end

local function DetachWara()
    local ped = PlayerPedId()
    DetachEntity(ped, true, true)
    ClearPedTasks(ped)
    SetEntityCollision(ped, true, true)
    waraAttached = false
    waraAttachedTo = nil
    
    if dui then
        MachoSendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "🔞 تم اخراج زبك منه",
            type = 'info'
        }))
    end
end

local function AttachWara()
    local ped = PlayerPedId()

    if waraAttached then
        DetachWara()
        return false
    end

    local closestPlayer, closestDist = GetClosestPlayer()

    if closestPlayer ~= -1 and closestDist < 1.5 then
        local targetPed = GetPlayerPed(closestPlayer)

        RequestAnimDict("misscarsteal2pimpsex")
        while not HasAnimDictLoaded("misscarsteal2pimpsex") do
            Citizen.Wait(10)
        end

        TaskPlayAnim(ped, "misscarsteal2pimpsex", "shagloop_pimp", 8.0, -8.0, -1, 1, 0, false, false, false)

        AttachEntityToEntity(
            ped,
            targetPed,
            GetPedBoneIndex(targetPed, 0),
            0.0,
            -0.35,
            0.2,
            0.0, 0.0, 0.0,
            false, false, false, false, 2, true
        )

        SetEntityCollision(ped, false, true)
        waraAttached = true
        waraAttachedTo = targetPed
        
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "🔞 Wara dance activated on closest player",
                type = 'success'
            }))
        end
        
        -- مراقبة التلقائي للانفصال
        Citizen.CreateThread(function()
            while waraAttached do
                Citizen.Wait(1000)
                
                if waraAttached and waraAttachedTo then
                    if not DoesEntityExist(waraAttachedTo) or 
                       #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(waraAttachedTo)) > 10.0 or
                       IsPedDeadOrDying(waraAttachedTo, true) then
                       
                        DetachWara()
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Auto detached from player",
                                type = 'info'
                            }))
                        end
                    end
                else
                    break
                end
            end
        end)
        
        return true
    else
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "❌ No player close enough for Wara dance",
                type = 'error'
            }))
        end
        return false
    end
end

local function Detach8DAM()
    local ped = PlayerPedId()
    DetachEntity(ped, true, true)
    ClearPedTasks(ped)
    SetEntityCollision(ped, true, true)
    eightDamAttached = false
    eightDamAttachedTo = nil
    
    if dui then
        MachoSendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "🔞 تم اخراج زبك منه",
            type = 'info'
        }))
    end
end

local function Attach8DAM()
    local ped = PlayerPedId()

    if eightDamAttached then
        Detach8DAM()
        return false
    end

    local closestPlayer, closestDist = GetClosestPlayer()

    if closestPlayer ~= -1 and closestDist < 1.5 then
        local targetPed = GetPlayerPed(closestPlayer)
        local animDict = 'timetable@trevor@skull_loving_bear'
        local animName = 'skull_loving_bear'

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(10)
        end

        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)

        AttachEntityToEntity(
            ped,
            targetPed,
            GetPedBoneIndex(targetPed, 0),
            0.0,
            0.3,
            0.72,
            0.0, 0.0, 180.0,
            false, false, false, false, 2, true
        )

        SetEntityCollision(ped, false, true)
        eightDamAttached = true
        eightDamAttachedTo = targetPed
        
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "🔞 8DAM dance activated on closest player",
                type = 'success'
            }))
        end
        
        -- مراقبة التلقائي للانفصال
        Citizen.CreateThread(function()
            while eightDamAttached do
                Citizen.Wait(1000)
                
                if eightDamAttached and eightDamAttachedTo then
                    if not DoesEntityExist(eightDamAttachedTo) or 
                       #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(eightDamAttachedTo)) > 10.0 or
                       IsPedDeadOrDying(eightDamAttachedTo, true) then
                       
                        Detach8DAM()
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Auto detached from player",
                                type = 'info'
                            }))
                        end
                    end
                else
                    break
                end
            end
        end)
        
        return true
    else
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "❌ No player close enough for 8DAM dance",
                type = 'error'
            }))
        end
        return false
    end
end

-- ======= وظائف الكلبشة والسحب =======
local function ExecuteUncuff()
    Citizen.CreateThread(function()
        print("Executing Uncuff...")
        
        -- الطريقة 1: جرب vRP إذا كان متاحاً مباشرة
        MachoInjectResource("vrp", [[tvRP.toggleHandcuff()]])
        
        -- الطريقة 2: جرب ESX إذا كان متاحاً
        MachoInjectResource("es_extended", [[
            local playerPed = PlayerPedId()
            TriggerEvent('esx_policejob:unrestrain')
            SetEnableHandcuffs(playerPed, false)
        ]])
        
        -- الطريقة 3: فك مباشر (إذا فشلت الطرق فوق)
        Citizen.Wait(100)
        local playerPed = PlayerPedId()
        
        -- فك الكلبشة مباشرة
        SetEnableHandcuffs(playerPed, false)
        ClearPedTasksImmediately(playerPed)
        DetachEntity(playerPed, true, false)
        FreezeEntityPosition(playerPed, false)
        
        -- إعادة التحكم
        for i = 0, 350 do
            EnableControlAction(0, i, true)
        end
        
        print("Direct uncuff applied")
        
        -- إشعار
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("~g~Uncuff executed! Handcuffs removed.")
        EndTextCommandThefeedPostTicker(false, true)
        
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "✅ تم فك الكلبشة",
                type = 'success'
            }))
        end
    end)
end

local function ExecuteUndrag()
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local isDragging = false
        local draggedPlayer = nil

        if not isDragging then
            -- بدء السحب
            local function GetNearestPlayer(radius)
                local players = GetActivePlayers()
                local closestDistance = radius
                local closestPlayer = nil
                local plyCoords = GetEntityCoords(playerPed, false)
                
                for _, player in ipairs(players) do
                    local target = GetPlayerPed(player)
                    if target ~= playerPed then
                        local targetCoords = GetEntityCoords(target, false)
                        local distance = #(plyCoords - targetCoords)
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
                return closestPlayer
            end

            local nearestPlayer = GetNearestPlayer(10.0)
            
            if nearestPlayer then
                draggedPlayer = GetPlayerPed(nearestPlayer)
                TriggerEvent("dr:drag", GetPlayerServerId(nearestPlayer))
                isDragging = true
                
                SetNotificationTextEntry("STRING")
                AddTextComponentString("~g~Started dragging player!")
                DrawNotification(true, false)
                
                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "🚶 تم بدء سحب اللاعب",
                        type = 'success'
                    }))
                end
            else
                SetNotificationTextEntry("STRING")
                AddTextComponentString("~y~No player nearby")
                DrawNotification(true, false)
            end
        else
            -- إيقاف السحب
            DetachEntity(playerPed, true, false)
            if draggedPlayer then
                DetachEntity(draggedPlayer, true, false)
            end
            isDragging = false
            draggedPlayer = nil
            
            SetNotificationTextEntry("STRING")
            AddTextComponentString("~r~Stopped dragging!")
            DrawNotification(true, false)
            
            if dui then
                MachoSendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "🛑 تم إيقاف السحب",
                    type = 'info'
                }))
            end
        end
    end)
end

-- ======= نظام تحديث البلاير لست التلقائي =======
local lastPlayerUpdate = 0
local UPDATE_INTERVAL = 0  -- تحديث كل 3 ثواني
local nearbyPlayersCache = {}
local spectateCam = nil
local isSpectating = false
local spectatingPlayer = nil
local isInPlayerMenu = false

local function UpdateNearbyPlayers()
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local nearbyPlayers = {}

    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local targetPed = GetPlayerPed(pid)
            if DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                local dist = #(coords - myCoords)
                local serverId = GetPlayerServerId(pid)
                local name = GetPlayerName(pid)

                table.insert(nearbyPlayers, {
                    label = string.format("%s [ID:%s] (%dm)", name, serverId, math.floor(dist)),
                    type = 'submenu',
                    submenu = {
{
    label = "👁️ Spectate Player",
    type = 'checkbox',
    checked = (spectatingPlayer == targetPed),
    onConfirm = function(checked)
        if checked then
            -- بدء المراقبة
            spectatingPlayer = targetPed
            isSpectating = true
            local spectateCamMode = false  -- false = منظور حر بالماوس, true = منظور اللاعب

            if spectateCam then
                DestroyCam(spectateCam)
                spectateCam = nil
            end
            
            spectateCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            SetCamActive(spectateCam, true)
            RenderScriptCams(true, true, 1000, true, true)

            -- إعداد التعليمات
            local function SetupSpectateInstructions()
                local scaleform = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
                while not HasScaleformMovieLoaded(scaleform) do Wait(0) end

                local function Button(slot, control, label)
                    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
                    PushScaleformMovieFunctionParameterInt(slot)
                    N_0xe83a3e3557a56640(GetControlInstructionalButton(0, control, true))
                    BeginTextCommandScaleformString("STRING")
                    AddTextComponentSubstringKeyboardDisplay(label)
                    EndTextCommandScaleformString()
                    PopScaleformMovieFunctionVoid()
                end

                PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
                PopScaleformMovieFunctionVoid()

                local i = 0
                local modeText = spectateCamMode and "Player View" or "Free Look"
                Button(i, 74, "Camera Mode ("..modeText..")") i=i+1
                Button(i, 1, "Look Around") i=i+1
                Button(i, 200, "Exit Spectate") i=i+1

                PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
                PopScaleformMovieFunctionVoid()
                return scaleform
            end

            local spectateScaleform = SetupSpectateInstructions()
            local cameraRotation = vector3(0.0, 0.0, 0.0)

            Citizen.CreateThread(function()
                while isSpectating and DoesCamExist(spectateCam) do
                    if not DoesEntityExist(targetPed) then 
                        isSpectating = false
                        spectatingPlayer = nil
                        break 
                    end
                    
                    -- 🔓 السماح بكل تحكمات الماوس
                    EnableControlAction(0, 1, true)   -- Mouse X
                    EnableControlAction(0, 2, true)   -- Mouse Y
                    EnableControlAction(0, 239, true) -- Mouse X (بديل)
                    EnableControlAction(0, 240, true) -- Mouse Y (بديل)
                    
                    -- تبديل وضع الكاميرا بـ H
                    if IsControlJustPressed(0, 74) then -- H
                        spectateCamMode = not spectateCamMode
                        spectateScaleform = SetupSpectateInstructions()
                        
                        if dui then
                            local modeMessage = spectateCamMode and "Player View" or "Free Look"
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "🎥 Camera Mode: " .. modeMessage,
                                type = 'info'
                            }))
                        end
                        Wait(200) -- منع التكرار السريع
                    end
                    
                    -- الخروج بـ ESC
                    if IsControlJustPressed(0, 200) then -- ESC
                        isSpectating = false
                        break
                    end
                    
                    -- الحصول على موقع اللاعب
                    local targetCoords = GetEntityCoords(targetPed)
                    
                    -- 🔧 الحفاظ على التركيز حول اللاعب المستهدف فقط
                    SetFocusArea(targetCoords.x, targetCoords.y, targetCoords.z, 0.0, 0.0, 0.0)
                    
                    if spectateCamMode then
                        -- النمط الأول: منظور اللاعب (حسب ما يناظر هو)
                        SetCamCoord(spectateCam, targetCoords.x, targetCoords.y - 3.0, targetCoords.z + 2.0)
                        PointCamAtEntity(spectateCam, targetPed, 0.0, 0.0, 0.0, true)
                        
                    else
                        -- النمط الثاني: منظور حر بالماوس (أنت تتحكم)
                        local lookX = GetDisabledControlNormal(0, 1) * 3.0  -- حساسية أقل لمنع الابتعاد السريع
                        local lookY = GetDisabledControlNormal(0, 2) * 3.0  -- حساسية أقل لمنع الابتعاد السريع
                        
                        -- تحديث دوران الكاميرا بناءً على حركة الماوس
                        cameraRotation = vector3(
                            cameraRotation.x + lookY,  -- فوق = فوق، تحت = تحت
                            cameraRotation.y,
                            cameraRotation.z - lookX   -- يمين = يمين، يسار = يسار
                        )
                        
                        -- تحديد حدود الدوران لمنع الابتعاد الشديد
                        cameraRotation = vector3(
                            math.max(-60.0, math.min(60.0, cameraRotation.x)),  -- حدود فوق/تحت
                            cameraRotation.y,
                            cameraRotation.z  -- لا حدود للدوران الأفقي
                        )
                        
                        -- حساب موقع الكاميرا حول اللاعب (مسافة ثابتة وقريبة)
                        local distance = 2.5  -- مسافة أقرب لمنع اختفاء الماب
                        local headingRad = math.rad(cameraRotation.z)
                        local pitchRad = math.rad(cameraRotation.x)
                        
                        -- حساب الإزاحة بناءً على الاتجاه
                        local offsetX = -math.sin(headingRad) * math.cos(pitchRad) * distance
                        local offsetY = math.cos(headingRad) * math.cos(pitchRad) * distance
                        local offsetZ = math.sin(pitchRad) * distance
                        
                        local camX = targetCoords.x + offsetX
                        local camY = targetCoords.y + offsetY
                        local camZ = targetCoords.z + offsetZ + 0.8  -- إزاحة رأسية إضافية
                        
                        -- 🔧 التحقق من أن الكاميرا ليست بعيدة جداً
                        local camDistance = #(vector3(camX, camY, camZ) - targetCoords)
                        if camDistance > 8.0 then  -- إذا ابتعدت كثيراً، إعادة تعيين
                            camX = targetCoords.x
                            camY = targetCoords.y - 3.0
                            camZ = targetCoords.z + 2.0
                            cameraRotation = vector3(0.0, 0.0, GetEntityHeading(targetPed))
                        end
                        
                        -- تحديث موقع الكاميرا
                        SetCamCoord(spectateCam, camX, camY, camZ)
                        
                        -- توجيه الكاميرا نحو اللاعب
                        PointCamAtCoord(spectateCam, targetCoords.x, targetCoords.y, targetCoords.z + 0.8)
                    end
                    
                    -- 🔧 منع اختفاء الكيانات عن طريق إعادة تحميل المنطقة كل 10 ثواني
                    if GetGameTimer() % 10000 < 50 then  -- كل 10 ثواني
                        local x, y, z = table.unpack(targetCoords)
                        ClearAreaOfVehicles(x, y, z, 100.0, false, false, false, false, false)
                        ClearAreaOfPeds(x, y, z, 100.0, 0)
                    end
                    
                    -- رسم التعليمات
                    if spectateScaleform then
                        DrawScaleformMovieFullscreen(spectateScaleform, 255, 255, 255, 255, 0)
                    end
                    
                    Wait(0)
                end
                
                -- تنظيف بعد الخروج
                RenderScriptCams(false, false, 0, true, true)
                if spectateCam then
                    DestroyCam(spectateCam)
                    spectateCam = nil
                end
                -- إعادة التركيز للاعب الحالي
                SetFocusEntity(PlayerPedId())
                isSpectating = false
                spectatingPlayer = nil
            end)

            if dui then
                MachoSendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "👁️ مراقبة " .. name .. " - H لتبديل الكاميرا",
                    type = 'success'
                }))
            end
        else
            -- إيقاف المراقبة
            if spectatingPlayer == targetPed then
                isSpectating = false
                spectatingPlayer = nil
                
                if spectateCam then
                    DestroyCam(spectateCam)
                    spectateCam = nil
                end
                RenderScriptCams(false, false, 0, true, true)
                -- إعادة التركيز للاعب الحالي
                SetFocusEntity(PlayerPedId())

                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "⏹️ توقفت المراقبة",
                        type = 'info'
                    }))
                end
            end
        end
    end
},
                        {
                            label = "📍 TP To Player",
                            type = 'button',
                            onConfirm = function()
                                local coords = GetEntityCoords(targetPed)
                                SetEntityCoords(myPed, coords.x, coords.y, coords.z)
                                if dui then
                                    MachoSendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "✅ تم النقل إلى " .. name,
                                        type = 'success'
                                    }))
                                end
                            end
                        },
                        {
                            label = "👕 Copy Outfit",
                            type = "button",
                            onConfirm = function()
                                Citizen.CreateThread(function()
                                    local playerPed = PlayerPedId()
                                    local targetModel = GetEntityModel(targetPed)

                                    -- 🔁 تبديل الموديل لو مختلف
                                    if targetModel ~= GetEntityModel(playerPed) then
                                        RequestModel(targetModel)
                                        while not HasModelLoaded(targetModel) do Wait(0) end
                                        SetPlayerModel(PlayerId(), targetModel)
                                        SetModelAsNoLongerNeeded(targetModel)
                                        playerPed = PlayerPedId()
                                    end

                                    Wait(150)

                                    -- 🧬 نسخ كامل من الهدف
                                    ClonePedToTarget(targetPed, playerPed)

                                    Wait(250)

                                    if dui then
                                        MachoSendDuiMessage(dui, json.encode({
                                            action = 'notify',
                                            message = "✅ تم نسخ مظهر " .. name,
                                            type = 'success'
                                        }))
                                    end
                                end)
                            end
                        },
                        {
                            label = "🚗 TP Into Vehicle",
                            type = 'button', 
                            onConfirm = function()
                                local vehicle = GetVehiclePedIsIn(targetPed, false)
                                if vehicle and vehicle ~= 0 then
                                    local seat = -2
                                    for i = -1, 6 do
                                        if GetPedInVehicleSeat(vehicle, i) == 0 then
                                            seat = i
                                            break
                                        end
                                    end
                                    
                                    if seat ~= -2 then
                                        SetPedIntoVehicle(PlayerPedId(), vehicle, seat)
                                        if dui then
                                            MachoSendDuiMessage(dui, json.encode({
                                                action = 'notify',
                                                message = "✅ تم الركوب في مركبة " .. name,
                                                type = 'success'
                                            }))
                                        end
                                    else
                                        if dui then
                                            MachoSendDuiMessage(dui, json.encode({
                                                action = 'notify',
                                                message = "❌ لا يوجد مقاعد شاغرة",
                                                type = 'error'
                                            }))
                                        end
                                    end
                                else
                                    if dui then
                                        MachoSendDuiMessage(dui, json.encode({
                                            action = 'notify',
                                            message = "❌ اللاعب ليس في مركبة",
                                            type = 'error'
                                        }))
                                    end
                                end
                            end
                        }
                    }
                })
            end
        end
    end

    -- ترتيب حسب المسافة
    table.sort(nearbyPlayers, function(a, b)
        local distA = tonumber(string.match(a.label, "(%d+)m") or 9999)
        local distB = tonumber(string.match(b.label, "(%d+)m") or 9999)
        return distA < distB
    end)

    if #nearbyPlayers == 0 then
        table.insert(nearbyPlayers, { 
            label = "👥 No nearby players", 
            type = "button",
            onConfirm = function()
                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "🔍 جاري البحث عن لاعبين...",
                        type = 'info'
                    }))
                end
            end
        })
    end

    nearbyPlayersCache = nearbyPlayers
    return nearbyPlayers
end

-- ثريد التحديث التلقائي الذكي
Citizen.CreateThread(function()
    local lastUpdate = 0
    
    while true do
        Citizen.Wait(0) -- تحقق كل ثانية
        
        if _G.clientMenuShowing and menuInitialized then
            local now = GetGameTimer()
            local currentInPlayerMenu = false
            
            -- تحقق إذا نحن في قائمة اللاعبين
            if activeMenu and #activeMenu > 0 then
                for i, item in ipairs(activeMenu) do
                    if item.label and (string.find(item.label, "ID:") or string.find(item.label, "No nearby players")) then
                        currentInPlayerMenu = true
                        break
                    end
                end
            end
            
            -- إذا دخلنا قائمة اللاعبين أو مرت 3 ثواني
            if currentInPlayerMenu and (not isInPlayerMenu or (now - lastUpdate) > UPDATE_INTERVAL) then
                isInPlayerMenu = true
                lastUpdate = now
                
                -- تحديث قائمة اللاعبين
                UpdateNearbyPlayers()
                
                -- تحديث القائمة الحالية
                if currentInPlayerMenu then
                    activeMenu = nearbyPlayersCache
                    setCurrent()
                end
                
            elseif not currentInPlayerMenu then
                isInPlayerMenu = false
            end
        else
            isInPlayerMenu = false
        end
    end
end)

-- تحديث أولي عند فتح القائمة
local function InitializePlayerList()
    UpdateNearbyPlayers()
    
    -- تحديث القائمة الرئيسية
    if originalMenu[5] and originalMenu[5].label == "Player List" then
        originalMenu[5].submenu = nearbyPlayersCache
    end
end

-- استدعاء التحديث الأولي بعد تحميل السكريبت
Citizen.CreateThread(function()
    Wait(0)
    InitializePlayerList()
end)

-- ======= وظائف Player Options =======
local function EnableGodmode()
    godmodeEnabled = true
    Citizen.CreateThread(function()
        while godmodeEnabled do
            local playerPed = PlayerPedId()
            local playerId = PlayerId()

            if GetResourceState("ReaperV4") == "started" then
                SetPlayerInvincible(playerId, true)
                SetEntityInvincible(playerPed, true)
            elseif GetResourceState("WaveShield") == "started" then
                SetEntityCanBeDamaged(playerPed, false)
            else
                SetEntityCanBeDamaged(playerPed, false)
                SetEntityProofs(playerPed, true, true, true, false, true, false, false, false)
                SetEntityInvincible(playerPed, true)
            end
            Wait(0)
        end
        
        -- تنظيف عند الإيقاف
        local playerPed = PlayerPedId()
        local playerId = PlayerId()
        
        if GetResourceState("ReaperV4") == "started" then
            SetPlayerInvincible(playerId, false)
            SetEntityInvincible(playerPed, false)
        elseif GetResourceState("WaveShield") == "started" then
            SetEntityCanBeDamaged(playerPed, true)
        else
            SetEntityCanBeDamaged(playerPed, true)
            SetEntityProofs(playerPed, false, false, false, false, false, false, false, false)
            SetEntityInvincible(playerPed, false)
        end
    end)
end

local function DisableGodmode()
    godmodeEnabled = false
end

local function EnableSuperJump()
    superJumpEnabled = true
    Citizen.CreateThread(function()
        while superJumpEnabled do
            SetSuperJumpThisFrame(PlayerId())
            Wait(0)
        end
    end)
end

local function DisableSuperJump()
    superJumpEnabled = false
end

local function EnableFastRun()
    superSpeedLoop = true
    Citizen.CreateThread(function()
        while superSpeedLoop do
            local playerPed = PlayerPedId()
            
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
            SetSwimMultiplierForPlayer(PlayerId(), 1.49)
            
            if IsPedRunning(playerPed) then
                SetPedMoveRateOverride(playerPed, 1.2)
            elseif IsPedSprinting(playerPed) then
                SetPedMoveRateOverride(playerPed, 1.3)
            else
                SetPedMoveRateOverride(playerPed, 1.0)
            end
            
            if IsPedSprinting(playerPed) then
                local forwardVector = GetEntityForwardVector(playerPed)
                local velocity = GetEntityVelocity(playerPed)
                SetEntityVelocity(playerPed, 
                    velocity.x + forwardVector.x * 0.1,
                    velocity.y + forwardVector.y * 0.1,
                    velocity.z
                )
            end
            
            Citizen.Wait(0)
        end
        
        local playerPed = PlayerPedId()
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        SetSwimMultiplierForPlayer(PlayerId(), 1.0)
        SetPedMoveRateOverride(playerPed, 1.0)
    end)
end

local function DisableFastRun()
    superSpeedLoop = false
end

local function EnableInvisibility()
    invisibilityEnabled = true
    Citizen.CreateThread(function()
        while invisibilityEnabled do
            SetEntityVisible(PlayerPedId(), false, false)
            Wait(0)
        end
        SetEntityVisible(PlayerPedId(), true, false)
    end)
end

local function DisableInvisibility()
    invisibilityEnabled = false
end

local function EnableInfiniteStamina()
    infiniteStaminaEnabled = true
    Citizen.CreateThread(function()
        while infiniteStaminaEnabled do
            RestorePlayerStamina(PlayerId(), 1.0)
            Wait(0)
        end
    end)
end

local function DisableInfiniteStamina()
    infiniteStaminaEnabled = false
end

local function EnableNoRagdoll()
    noRagdollEnabled = true
    Citizen.CreateThread(function()
        while noRagdollEnabled do
            SetPedCanRagdoll(PlayerPedId(), false)
            Wait(0)
        end
        SetPedCanRagdoll(PlayerPedId(), true)
    end)
end

local function DisableNoRagdoll()
    noRagdollEnabled = false
end

-- ======= وظائف الملابس =======
local function RandomizeOutfit()
    local ped = PlayerPedId()
    
    local function GetRandomComponent(component, exclude)
        local total = GetNumberOfPedDrawableVariations(ped, component)
        if total <= 1 then return 0 end
        local choice = exclude
        while choice == exclude do
            choice = math.random(0, total - 1)
        end
        return choice
    end

    local function GetRandomComponentSimple(component)
        local total = GetNumberOfPedDrawableVariations(ped, component)
        return total > 1 and math.random(0, total - 1) or 0
    end

    SetPedComponentVariation(ped, 11, GetRandomComponent(11, 15), 0, 2)
    SetPedComponentVariation(ped, 6, GetRandomComponent(6, 15), 0, 2)
    SetPedComponentVariation(ped, 8, 15, 0, 2)
    SetPedComponentVariation(ped, 3, 0, 0, 2)
    SetPedComponentVariation(ped, 4, GetRandomComponentSimple(4), 0, 2)

    local face = math.random(0, 166)
    local skin = math.random(0, 166)
    SetPedHeadBlendData(ped, face, skin, 0, face, skin, 0, 1.0, 1.0, 0.0, false)

    local hairMax = GetNumberOfPedDrawableVariations(ped, 2)
    local hair = hairMax > 1 and math.random(0, hairMax - 1) or 0
    SetPedComponentVariation(ped, 2, hair, 0, 2)
    SetPedHairColor(ped, 0, 0)

    local brows = GetNumHeadOverlayValues(2)
    SetPedHeadOverlay(ped, 2, brows > 1 and math.random(0, brows - 1) or 0, 1.0)
    SetPedHeadOverlayColor(ped, 2, 1, 0, 0)

    ClearPedProp(ped, 0)
    ClearPedProp(ped, 1)
    
    if dui then
        MachoSendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "Outfit Randomized",
            type = 'success'
        }))
    end
end

local function CleanClothes()
    local ped = PlayerPedId()

    -- إزالة الدم والأوساخ والطين
    ClearPedBloodDamage(ped)
    ClearPedWetness(ped)
    ClearPedEnvDirt(ped)
    SetPedToLoadCover(ped, false)

    -- إرسال إشعار للواجهة
    if dui then
        MachoSendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "✅ تم تنظيف الملابس بنجاح!",
            type = 'success'
        }))
    end
end

-- ======= وظائف الهيل والتليبورت السريع =======
local function QuickHeal()
    SetEntityHealth(PlayerPedId(), 200)
    SetPedArmour(PlayerPedId(), 100)
    if dui then
        MachoSendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "✅ تم انعاشك بنجاح",
            type = 'success'
        }))
    end
end

local function QuickTeleport()
    local waypointBlip = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypointBlip) then
        local coords = GetBlipInfoIdCoord(waypointBlip)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 5.0, false, false, false, true)
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "✅ تم الأنتقال بنجاح",
                type = 'success'
            }))
        end
    else
        if dui then
            MachoSendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "❌ No waypoint set",
                type = 'error'
            }))
        end
    end
end

local function GetKeyName(key)
    local keyNames = {
        [322] = "ESC", [288] = "F1", [289] = "F2", [170] = "F3", [166] = "F5", 
        [167] = "F6", [168] = "F7", [169] = "F8", [56] = "F9", [57] = "F10",
        [243] = "~", [157] = "1", [158] = "2", [160] = "3", [164] = "4", 
        [165] = "5", [159] = "6", [161] = "7", [162] = "8", [163] = "9", 
        [84] = "-", [83] = "=", [177] = "BACKSPACE",
        [37] = "TAB", [44] = "Q", [32] = "W", [38] = "E", [45] = "R", 
        [245] = "T", [246] = "Y", [303] = "U", [199] = "P", [39] = "[", 
        [40] = "]", [18] = "ENTER",
        [137] = "CAPS", [34] = "A", [8] = "S", [9] = "D", [23] = "F", 
        [47] = "G", [74] = "H", [311] = "K", [182] = "L",
        [21] = "LEFTSHIFT", [20] = "Z", [73] = "X", [26] = "C", [0] = "V", 
        [29] = "B", [249] = "N", [244] = "M", [82] = ",", [81] = ".",
        [36] = "LEFTCTRL", [19] = "LEFTALT", [22] = "SPACE", [70] = "RIGHTCTRL",
        [212] = "HOME", [10] = "PAGEUP", [11] = "PAGEDOWN", [178] = "DELETE",
        [174] = "LEFT", [175] = "RIGHT", [27] = "TOP", [173] = "DOWN",
        [201] = "NENTER", [108] = "N4", [60] = "N5", [107] = "N6", [96] = "N+", 
        [97] = "N-", [117] = "N7", [61] = "N8", [118] = "N9",
        [1] = "Mouse1", [2] = "Mouse2", [4] = "Mouse3",
        [112] = "F11", [113] = "F12", [144] = "NUMLOCK", [145] = "SCROLLLOCK",
        [186] = ";", [187] = "=", [188] = ",", [189] = "-", [190] = ".", 
        [191] = "/", [192] = "`", [219] = "[", [220] = "\\", [221] = "]", 
        [222] = "'", [223] = "~"
    }
    
    return keyNames[key] or "Key" .. tostring(key)
end

-- ======= القائمة الرئيسية =======
originalMenu = {
    {
        label = "Player Options",
        type = 'submenu',
        icon = 'ph-user',
        submenu = {
            {
                label = "Godmode",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        EnableGodmode()
                    else
                        DisableGodmode()
                    end
                end
            },
            {
                label = "Super Jump",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        EnableSuperJump()
                    else
                        DisableSuperJump()
                    end
                end
            },
            {
                label = "Fast Run",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        EnableFastRun()
                    else
                        DisableFastRun()
                    end
                end
            },
            {
                label = "Invisibility",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        EnableInvisibility()
                    else
                        DisableInvisibility()
                    end
                end
            },
            {
                label = "Infinite Stamina",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        EnableInfiniteStamina()
                    else
                        DisableInfiniteStamina()
                    end
                end
            },
            {
                label = "No Ragdoll",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        EnableNoRagdoll()
                    else
                        DisableNoRagdoll()
                    end
                end
            }
        }
    },
    {
        label = "Noclip System",
        type = 'submenu',
        icon = 'ph-airplane-takeoff',
        submenu = {
            {
                label = "Toggle Noclip",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    noclipEnabled = checked
                    if checked then
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Noclip System Enabled (Press key to fly)",
                                type = 'success'
                            }))
                        end
                    else
                        if noclipActive then 
                            DeactivateNoclip() 
                        end
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Noclip System Disabled",
                                type = 'info'
                            }))
                        end
                    end
                end
            },
            {
                label = "Set Noclip Key : None",
                type = 'button',
                onConfirm = function()
                    noclipKeybindInputActive = true
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Press any key to set Noclip key...",
                            type = 'warning'
                        }))
                    end
                end
            }
        }
    },
    {
        label = "Free Camera",
        type = "submenu",
        icon = "ph-camera",
        submenu = {
            {
                label = "Toggle Free Camera",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    freecamEnabled = checked
                    if checked then
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Free Camera Enabled (Press key to activate)",
                                type = 'success'
                            }))
                        end
                    else
                        if freecamActive then 
                            StopFreeCamera() 
                        end
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Free Camera Disabled",
                                type = 'info'
                            }))
                        end
                    end
                end
            },
            {
                label = "Set Freecam Key : None",
                type = 'button',
                onConfirm = function()
                    freecamKeybindInputActive = true
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Press any key to set Freecam key...",
                            type = 'warning'
                        }))
                    end
                end
            }
        }
    },
    {
        label = "Teleport & Glitch",
        type = 'submenu',
        icon = 'ph-map-pin',
        submenu = {
            {
                label = "TP To Waypoint",
                type = 'button',
                onConfirm = function()
                    QuickTeleport()
                end
            },
            {
            label = "⌨️ Set Waypoint Key : None",
            type = 'button',
            onConfirm = function()
                waypointKeybindInputActive = true
                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Press any key to set Waypoint Teleport key...",
                        type = 'warning'
                    }))
                end
            end
        },
            {
                label = "Glitch Teleport",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    teleportEnabled = checked
                    if checked then
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Glitch Teleport Enabled (Press key to activate)",
                                type = 'success'
                            }))
                        end
                    else
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify', 
                                message = "Glitch Teleport Disabled",
                                type = 'info'
                            }))
                        end
                    end
                end
            },
            {
                label = "Set Teleport Key : None", 
                type = 'button',
                onConfirm = function()
                    teleportKeybindInputActive = true
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Press any key to set Teleport key...", 
                            type = 'warning'
                        }))
                    end
                end
            },
            {
                label = "Toggle Ultimate RP",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    ultimateRpEnabled = checked
                    if checked then
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Ultimate RP Enabled (Press key to go to sky)",
                                type = 'success'
                            }))
                        end
                    else
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify', 
                                message = "Ultimate RP Disabled",
                                type = 'info'
                            }))
                        end
                    end
                end
            },
            {
                label = "Set Ultimate RP Key : None", 
                type = 'button',
                onConfirm = function()
                    ultimateRpKeybindInputActive = true
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Press any key to set Ultimate RP key...", 
                            type = 'warning'
                        }))
                    end
                end
            }
        }
    },
    {
        label = "Player List",
        type = 'submenu',
        icon = 'ph-users',
        submenu = {{ label = "Loading players...", type = "button" }}
    },
    {
        label = "Player Actions",
        type = 'submenu',
        icon = 'ph-heart',
        submenu = {
            {
                label = "Heal Player",
                type = 'button',
                onConfirm = function()
                    QuickHeal()
                end
            },
            {
            label = "⌨️ Set Heal Key : None",
            type = 'button', 
            onConfirm = function()
                healKeybindInputActive = true
                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Press any key to set Heal key...",
                        type = 'warning'
                    }))
                end
            end
        },
            {
                label = "Add Armor",
                type = 'button',
                onConfirm = function()
                    SetPedArmour(PlayerPedId(), 100)
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Armor Added",
                            type = 'success'
                        }))
                    end
                end
            },
            {
                label = "Kill Self",
                type = 'button',
                onConfirm = function()
                    SetEntityHealth(PlayerPedId(), 0)
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Player Killed",
                            type = 'info'
                        }))
                    end
                end
            },
            {
                label = "Clean Clothes",
                type = 'button',
                onConfirm = function()
                    CleanClothes()
                end
            },
            {
                label = "S H B MENU",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    _G.shbMenuEnabled = checked
                    if checked then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "SHB Menu Enabled - Keybind is now active",
                            type = 'success'
                        }))
                    else
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "SHB Menu Disabled - Keybind is now inactive",
                            type = 'info'
                        }))
                    end
                end
            },
            {
                label = "⌨️ Set SHB Menu Key : None",
                type = 'button',
                onConfirm = function()
                    shbMenuKeybindInputActive = true
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Press any key to set SHB Menu key...",
                            type = 'warning'
                        }))
                    end
                end
            },
            {
                label = "SHB Tools",
                type = 'submenu',
                icon = 'ph-toolbox',
                submenu = {
                    {
                        label = "Uncuff Player",
                        type = 'button',
                        onConfirm = function()
                            ExecuteUncuff()
                        end
                    },
                    {
                        label = "Undrag Player", 
                        type = 'button',
                        onConfirm = function()
                            ExecuteUndrag()
                        end
                    }
                }
            }
        }
    },
    {
        label = "Clothing Menu",
        type = 'submenu',
        icon = 'ph-tshirt',
        submenu = {
            {
                label = "Randomize Outfit",
                type = 'button',
                onConfirm = function()
                    RandomizeOutfit()
                end
            },
            {
                label = "Clean Clothes",
                type = 'button',
                onConfirm = function()
                    CleanClothes()
                end
            },
            {
                label = "🔞 Skin +18",
                type = 'button',
                onConfirm = function()
                    local modelHash = GetHashKey("a_m_m_acult_01")
                    RequestModel(modelHash)
                    while not HasModelLoaded(modelHash) do Wait(10) end
                    SetPlayerModel(PlayerId(), modelHash)
                    SetPedDefaultComponentVariation(PlayerPedId())
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Skin Changed",
                            type = 'success'
                        }))
                    end
                end
            }
        }
    },
    {
        label = "Fun & Misc",
        type = 'submenu',
        icon = 'ph-magic-wand',
        submenu = {
            {
                label = "Blips [Log]",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        TriggerEvent("showBlips")
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "👥 تم تشغيل بلبز اللاعبين",
                                type = 'success'
                            }))
                        end
                    else
                        TriggerEvent("showBlips")
                        if dui then
                            MachoSendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "👥 تم إيقاف بلبز اللاعبين",
                                type = 'info'
                            }))
                        end
                    end
                end
            },
            {
                label = "🔞 Wara",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        AttachWara()
                    else
                        DetachWara()
                    end
                end
            },
            {
                label = "🔞 8dam",
                type = 'checkbox',
                checked = false,
                onConfirm = function(checked)
                    if checked then
                        Attach8DAM()
                    else
                        Detach8DAM()
                    end
                end
            }
        }
    },
    {
        label = "Settings",
        type = 'submenu',
        icon = 'ph-gear-six',
        submenu = {
            {
                label = "⌨️ Set Menu Toggle Key : CAPS",
                type = 'button',
                onConfirm = function()
                    menuToggleKeybindInputActive = true
                    if dui then
                        MachoSendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Press any key to set Menu Toggle key...", 
                            type = 'warning'
                        }))
                    end
                end
            },
            { 
                label = 'Close Menu', 
                type = 'button', 
                onConfirm = function() 
                    _G.clientMenuShowing = false
                end 
            }
        }
    }
}

activeMenu = originalMenu

-- Safe copy for DUI
local function safeMenuCopy(menu)
    local copy = {}
    for i, v in ipairs(menu) do
        local item = {
            label = v.label or "",
            type = v.type or ""
        }
        
        -- تحديث النصوص ديناميكياً
        if v.label and string.find(v.label, "Set SHB Menu Key") then
            item.label = "⌨️ Set SHB Menu Key : " .. shbMenuKeybindText
        elseif v.label and string.find(v.label, "Set Ultimate RP Key") then
            item.label = "⌨️ Set Ultimate RP Key : " .. ultimateRpKeybindText
        elseif v.label and string.find(v.label, "Set Noclip Key") then
            item.label = "⌨️ Set Noclip Key : " .. noclipKeybindText
        elseif v.label and string.find(v.label, "Set Freecam Key") then
            item.label = "⌨️ Set Freecam Key : " .. freecamKeybindText
        elseif v.label and string.find(v.label, "Set Teleport Key") then
            item.label = "⌨️ Set Teleport Key : " .. teleportKeybindText
        elseif v.label and string.find(v.label, "Set Menu Toggle Key") then
            item.label = "⌨️ Set Menu Toggle Key : " .. menuToggleKeyText
        end
        
        if v.icon then item.icon = v.icon end

        if v.type == "scroll" then
            item.options = {}
            for _, opt in ipairs(v.options or {}) do
                if type(opt) == "table" then
                    table.insert(item.options, {
                        label = tostring(opt.label or ""),
                        value = tostring(opt.value or opt.label or "")
                    })
                else
                    table.insert(item.options, { label = tostring(opt), value = tostring(opt) })
                end
            end
            if #item.options == 0 then
                item.options = {{ label = "(empty)", value = "(empty)" }}
            end
            local sel = v.selected or 1
            if sel < 1 then sel = 1 end
            if sel > #item.options then sel = #item.options end
            item.selected = sel - 1 -- 0-based for JS
        elseif v.type == "slider" then
            item.min = v.min or 0
            item.max = v.max or 100
            item.value = v.value or item.min
        elseif v.type == "checkbox" then
            item.checked = v.checked == true
        elseif v.type == "submenu" then
            if type(v.submenu) == "table" then
                item.submenu = safeMenuCopy(v.submenu)
            end
        end
        copy[i] = item
    end
    return copy
end

function setCurrent()
    if dui and menuInitialized then
        MachoSendDuiMessage(dui, json.encode({
            action = 'setCurrent',
            current = activeIndex,
            menu = safeMenuCopy(activeMenu)
        }))
    end
end

-- دالة تحديث نص Waypoint Key
local function updateWaypointKeybindText()
    for i, item in ipairs(originalMenu) do
        if item.label and string.find(item.label, "Teleport & Glitch") and item.submenu then
            for j, subItem in ipairs(item.submenu) do
                if subItem.label and string.find(subItem.label, "Set Waypoint Key") then
                    subItem.label = "⌨️ Set Waypoint Key : " .. waypointKeybindText
                    break
                end
            end
            break
        end
    end
end

-- دالة تحديث نص Heal Key
local function updateHealKeybindText()
    for i, item in ipairs(originalMenu) do
        if item.label and string.find(item.label, "Player Actions") and item.submenu then
            for j, subItem in ipairs(item.submenu) do
                if subItem.label and string.find(subItem.label, "Set Heal Key") then
                    subItem.label = "⌨️ Set Heal Key : " .. healKeybindText
                    break
                end
            end
            break
        end
    end
end

local function isControlJustPressed(control)
    return IsControlJustPressed(0, control) or IsDisabledControlJustPressed(0, control)
end

local function initializeMenu()
    if not menuInitialized and dui then
        menuInitialized = true
        
        -- استخدم الحالة المحفوظة إذا كانت موجودة
        if savedMenuState then
            activeMenu = savedMenuState.activeMenu
            activeIndex = savedMenuState.activeIndex
            nestedMenus = savedMenuState.menuStack
        else
            activeMenu = originalMenu
            activeIndex = 1
            nestedMenus = {}
        end
        
        MachoSendDuiMessage(dui, json.encode({
            action = 'setVisible',
            visible = true
        }))
        
        setCurrent()
    end
end

local function closeMenu()
    -- احفظ الحالة الحالية دائماً
    savedMenuState = {
        activeMenu = activeMenu,
        activeIndex = activeIndex,
        menuStack = nestedMenus
    }
    
    if dui then
        MachoSendDuiMessage(dui, json.encode({
            action = 'setVisible',
            visible = false
        }))
    end
    
    menuInitialized = false
    isInPlayerMenu = false
end

-- Main thread
CreateThread(function()
    dui = MachoCreateDui("https://mohammadshb.github.io/i7/build/")
    
    if dui then
        MachoShowDui(dui)
        Wait(500)
        
        -- Start with menu closed
        MachoSendDuiMessage(dui, json.encode({
            action = 'setVisible',
            visible = false
        }))
    else
        print("ERROR: Failed to create DUI!")
        return
    end

    -- Menu toggle thread
    CreateThread(function()
        local lastPress = 0
        while true do
            if IsControlJustPressed(0, menuToggleKey) then
                local currentTime = GetGameTimer()
                if currentTime - lastPress > 200 then
                    _G.clientMenuShowing = not _G.clientMenuShowing
                    lastPress = currentTime
                end
            end
            Wait(0)
        end
    end)

    -- Main menu loop
    local showing = false
    local nestedMenus = {}
    _G.clientMenuShowing = false

    while true do
        if _G.clientMenuShowing and not showing then
            showing = true
            initializeMenu()
            nestedMenus = {}
        elseif not _G.clientMenuShowing and showing then
            showing = false
            closeMenu()
        end
        
        if showing then
            EnableControlAction(0, 1, true) -- Mouse
            EnableControlAction(0, 2, true) -- Mouse
            EnableControlAction(0, menuToggleKey, true) -- Menu Toggle Key

            -- معالجة إدخال الأزرار
            if noclipKeybindInputActive then
                local keyPressed = false
                for i = 1, 350 do
                    if IsControlJustPressed(0, i) then
                        if i == 200 or i == 202 or i == 177 then -- ESC أو Backspace
                            noclipKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Noclip key binding cancelled",
                                    type = 'info'
                                }))
                            end
                        else
                            noclipSelectedKey = i
                            noclipKeybindText = GetKeyName(i)
                            noclipKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Noclip key set to: " .. noclipKeybindText,
                                    type = 'success'
                                }))
                            end
                        end
                        keyPressed = true
                        setCurrent()
                        Wait(500)
                        break
                    end
                end
                if not keyPressed then Wait(0) end
                
            elseif freecamKeybindInputActive then
                local keyPressed = false
                for i = 1, 350 do
                    if IsControlJustPressed(0, i) then
                        if i == 200 or i == 202 or i == 177 then
                            freecamKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Freecam key binding cancelled",
                                    type = 'info'
                                }))
                            end
                        else
                            freecamSelectedKey = i
                            freecamKeybindText = GetKeyName(i)
                            freecamKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Freecam key set to: " .. freecamKeybindText,
                                    type = 'success'
                                }))
                            end
                        end
                        keyPressed = true
                        setCurrent()
                        Wait(500)
                        break
                    end
                end
                if not keyPressed then Wait(0) end
                
            elseif teleportKeybindInputActive then
                local keyPressed = false
                for i = 1, 350 do
                    if IsControlJustPressed(0, i) then
                        if i == 200 or i == 202 or i == 177 then
                            teleportKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Teleport key binding cancelled",
                                    type = 'info'
                                }))
                            end
                        else
                            teleportKey = i
                            teleportKeybindText = GetKeyName(i)
                            teleportKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Teleport key set to: " .. teleportKeybindText,
                                    type = 'success'
                                }))
                            end
                        end
                        keyPressed = true
                        setCurrent()
                        Wait(500)
                        break
                    end
                end
                if not keyPressed then Wait(0) end
                
            elseif ultimateRpKeybindInputActive then
                local keyPressed = false
                for i = 1, 350 do
                    if IsControlJustPressed(0, i) then
                        if i == 200 or i == 202 or i == 177 then
                            ultimateRpKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Ultimate RP key binding cancelled",
                                    type = 'info'
                                }))
                            end
                        else
                            ultimateRpKey = i
                            ultimateRpKeybindText = GetKeyName(i)
                            ultimateRpKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Ultimate RP key set to: " .. ultimateRpKeybindText,
                                    type = 'success'
                                }))
                            end
                        end
                        keyPressed = true
                        setCurrent()
                        Wait(500)
                        break
                    end
                end
                if not keyPressed then Wait(0) end
                
            elseif shbMenuKeybindInputActive then
                local keyPressed = false
                for i = 1, 350 do
                    if IsControlJustPressed(0, i) then
                        if i == 200 or i == 202 or i == 177 then
                            shbMenuKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "SHB Menu key binding cancelled",
                                    type = 'info'
                                }))
                            end
                        else
                            shbMenuKey = i
                            shbMenuKeybindText = GetKeyName(i)
                            shbMenuKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "SHB Menu key set to: " .. shbMenuKeybindText,
                                    type = 'success'
                                }))
                            end
                        end
                        keyPressed = true
                        setCurrent()
                        Wait(500)
                        break
                    end
                end
                if not keyPressed then Wait(0) end
                
-- Waypoint Keybind Input
elseif waypointKeybindInputActive then
    local keyPressed = false
    for i = 1, 350 do
        if IsControlJustPressed(0, i) then
            if i == 200 or i == 202 or i == 177 then -- ESC أو Backspace
                waypointKeybindInputActive = false
                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Waypoint key binding cancelled",
                        type = 'info'
                    }))
                end
                keyPressed = true
                break
            end
            
            waypointKey = i
            waypointKeybindText = GetKeyName(i)
            waypointKeybindInputActive = false
            updateWaypointKeybindText()
            
            if dui then
                MachoSendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "Waypoint key set to: " .. waypointKeybindText,
                    type = 'success'
                }))
            end
            
            keyPressed = true
            Wait(500)
            break
        end
    end
    
    if not keyPressed then
        Wait(0)
    else
        setCurrent()
        Wait(100)
    end

-- Heal Keybind Input
elseif healKeybindInputActive then
    local keyPressed = false
    for i = 1, 350 do
        if IsControlJustPressed(0, i) then
            if i == 200 or i == 202 or i == 177 then -- ESC أو Backspace
                healKeybindInputActive = false
                if dui then
                    MachoSendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Heal key binding cancelled",
                        type = 'info'
                    }))
                end
                keyPressed = true
                break
            end
            
            healKey = i
            healKeybindText = GetKeyName(i)
            healKeybindInputActive = false
            updateHealKeybindText()
            
            if dui then
                MachoSendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "Heal key set to: " .. healKeybindText,
                    type = 'success'
                }))
            end
            
            keyPressed = true
            Wait(500)
            break
        end
    end
    
    if not keyPressed then
        Wait(0)
    else
        setCurrent()
        Wait(100)
    end
                
            elseif menuToggleKeybindInputActive then
                local keyPressed = false
                for i = 1, 350 do
                    if IsControlJustPressed(0, i) then
                        if i == 200 or i == 202 or i == 177 then
                            menuToggleKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Menu toggle key binding cancelled",
                                    type = 'info'
                                }))
                            end
                        else
                            menuToggleKey = i
                            menuToggleKeyText = GetKeyName(i)
                            menuToggleKeybindInputActive = false
                            if dui then
                                MachoSendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Menu toggle key set to: " .. menuToggleKeyText,
                                    type = 'success'
                                }))
                            end
                        end
                        keyPressed = true
                        setCurrent()
                        Wait(500)
                        break
                    end
                end
                if not keyPressed then Wait(0) end
                
            else
                -- تحكمات القائمة العادية
                if isControlJustPressed(187) then -- Arrow Down
                    activeIndex = activeIndex + 1
                    if activeIndex > #activeMenu then activeIndex = 1 end
                    setCurrent()
                    Wait(100)
                elseif isControlJustPressed(188) then -- Arrow Up
                    activeIndex = activeIndex - 1
                    if activeIndex < 1 then activeIndex = #activeMenu end
                    setCurrent()
                    Wait(100)
                elseif isControlJustPressed(189) then -- Left Arrow
                    local activeData = activeMenu[activeIndex]
                    if activeData.type == 'scroll' then
                        activeData.selected = activeData.selected - 1
                        if activeData.selected < 1 then activeData.selected = #activeData.options end
                        setCurrent()
                        if activeData.onChange then
                            activeData.onChange(activeData.options[activeData.selected])
                        end
                    elseif activeData.type == 'slider' then
                        activeData.value = math.max(activeData.min, activeData.value - 1)
                        setCurrent()
                        if activeData.onChange then
                            activeData.onChange(activeData.value)
                        end
                    end
                    Wait(100)
                elseif isControlJustPressed(190) then -- Right Arrow
                    local activeData = activeMenu[activeIndex]
                    if activeData.type == 'scroll' then
                        activeData.selected = activeData.selected + 1
                        if activeData.selected > #activeData.options then activeData.selected = 1 end
                        setCurrent()
                        if activeData.onChange then
                            activeData.onChange(activeData.options[activeData.selected])
                        end
                    elseif activeData.type == 'slider' then
                        activeData.value = math.min(activeData.max, activeData.value + 1)
                        setCurrent()
                        if activeData.onChange then
                            activeData.onChange(activeData.value)
                        end
                    end
                    Wait(100)
elseif isControlJustPressed(191) then -- Enter
    local activeData = activeMenu[activeIndex]
    
    if activeData.type == 'submenu' then
        -- احفظ القائمة الحالية في التاريخ
        nestedMenus[#nestedMenus + 1] = { 
            index = activeIndex, 
            menu = activeMenu 
        }
        
        if activeData.submenu then
            activeIndex = 1
            activeMenu = activeData.submenu
            setCurrent()
        end
                    elseif activeData.type == 'button' then
                        if activeData.onConfirm then
                            activeData.onConfirm()
                        end
                    elseif activeData.type == 'checkbox' then
                        activeData.checked = not activeData.checked
                        setCurrent()
                        if activeData.onConfirm then
                            activeData.onConfirm(activeData.checked)
                        end
                    elseif activeData.type == 'scroll' then
                        if activeData.onConfirm then
                            local selectedIndex = activeData.selected
                            activeData.onConfirm(activeData.options[selectedIndex])
                        end
                        setCurrent()
                    elseif activeData.type == 'slider' then
                        if activeData.onConfirm then
                            activeData.onConfirm(activeData.value)
                        end
                        setCurrent()
                    end
                    Wait(200)
elseif isControlJustPressed(194) then -- Backspace
    local lastMenu = nestedMenus[#nestedMenus]
    if lastMenu then
        table.remove(nestedMenus)
        activeIndex = lastMenu.index
        activeMenu = lastMenu.menu
        setCurrent()
    else
        -- فقط إذا كان في القائمة الرئيسية الأصلية، أغلق المنيو
        if activeMenu == originalMenu then
            _G.clientMenuShowing = false
        else
            -- إذا كان في قائمة فرعية، ارجع للقائمة الرئيسية
            activeMenu = originalMenu
            activeIndex = 1
            nestedMenus = {}
            setCurrent()
        end
    end
    Wait(200)
end
            end
        end
        
        Wait(0)
    end
end)

-- Keybind handlers خارج القائمة
-- في جزء Keybind handlers خارج القائمة
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- SHB Menu Keybind - يفتح قائمة SHB Tools مباشرة
        if shbMenuKey ~= nil and shbMenuKey ~= 0 and IsControlJustPressed(0, shbMenuKey) and _G.shbMenuEnabled then
            if not _G.clientMenuShowing then
                _G.clientMenuShowing = true
                -- الانتظار حتى تهيئة القائمة
                while not menuInitialized do
                    Wait(10)
                end
                -- الانتظار شوي ثم فتح قائمة SHB Tools
                Citizen.Wait(300)
            end
            
            -- فتح قائمة SHB Tools مباشرة
            activeMenu = {
                {
                    label = "Uncuff Player",
                    type = 'button',
                    onConfirm = function()
                        ExecuteUncuff()
                    end
                },
                {
                    label = "Undrag Player", 
                    type = 'button',
                    onConfirm = function()
                        ExecuteUndrag()
                    end
                }
            }
            activeIndex = 1
            setCurrent()
            Citizen.Wait(500)
        end
        
        -- Freecam keybind
        if freecamSelectedKey ~= nil and freecamSelectedKey ~= 0 and IsControlJustPressed(0, freecamSelectedKey) and freecamEnabled and not noclipActive then
            ToggleFreeCamera()
            Citizen.Wait(500)
        end
        
        -- Noclip keybind
        if noclipSelectedKey ~= nil and noclipSelectedKey ~= 0 and IsControlJustPressed(0, noclipSelectedKey) and noclipEnabled and not freecamActive then
            if noclipActive then
                DeactivateNoclip()
            else
                ActivateNoclip()
            end
            Citizen.Wait(500)
        end
        
       -- Waypoint Teleport Keybind - التصحيح هنا
       if waypointKey ~= nil and waypointKey ~= 0 and IsControlJustPressed(0, waypointKey) then
           QuickTeleport()
           Citizen.Wait(500)
       end

       -- Heal Player Keybind - التصحيح هنا
       if healKey ~= nil and healKey ~= 0 and IsControlJustPressed(0, healKey) then
           QuickHeal()
           Citizen.Wait(500)
       end

        -- Ultimate RP keybind
        if ultimateRpKey ~= nil and ultimateRpKey ~= 0 and IsControlJustPressed(0, ultimateRpKey) and ultimateRpEnabled then
            TeleportToUltimateRP()
            Citizen.Wait(500)
        end
        
        -- Teleport keybind
        if teleportKey ~= nil and teleportKey ~= 0 and IsControlJustPressed(0, teleportKey) and teleportEnabled and not freecamActive and not noclipActive then
            TeleportToCustom()
            Citizen.Wait(500)
        end

        -- Disable controls during freecam
        if freecamActive then
            DisableControlAction(0, 1, true)  -- Mouse Look
            DisableControlAction(0, 2, true)  -- Mouse Look
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 37, true) -- Weapon Wheel
            EnableControlAction(0, 200, true) -- ESC
        end
    end
end)

-- ======= تخطي الحماية =======
CreateThread(function()
    for i = 0, GetNumResources() - 1 do
        local v = GetResourceByFindIndex(i)

        if v and GetResourceState(v) == "started" then
            if GetResourceMetadata(v, "ac", 0) == "fg" then
                while true do
                    MachoResourceStop(v)
                    Wait(0)
                end
            end
        end
    end
end)