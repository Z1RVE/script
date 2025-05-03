local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Sabitler ve Varsayılanlar
local CONFIG = {
    DEFAULT_COLORS = {
        primary = Color3.fromRGB(130, 90, 153), -- Style.primaryColor
        secondary = Color3.fromRGB(166, 128, 191), -- Style.secondaryColor
        background = Color3.fromRGB(26, 0, 51), -- Style.backgroundColor
        text = Color3.fromRGB(220, 220, 220),
        accent = Color3.fromRGB(200, 150, 255),
    },
    DEFAULT_FONT = Enum.Font.Gotham,
    ANIMATION_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    CORNER_RADIUS = UDim.new(0, 8),
    SHADOW_TRANSPARENCY = 0.7,
}

-- Yardımcı Fonksiyonlar
local function randomString()
    local length = math.random(10, 20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

local function applyCorner(element)
    local corner = Instance.new("UICorner", element)
    corner.CornerRadius = CONFIG.CORNER_RADIUS
end

local function applyGradient(element, color1, color2)
    local gradient = Instance.new("UIGradient", element)
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = 45
    return gradient
end

local function applyShadow(element)
    local shadow = Instance.new("Frame", element)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = CONFIG.SHADOW_TRANSPARENCY
    shadow.ZIndex = element.ZIndex - 1
    applyCorner(shadow)
    return shadow
end

local function createTween(element, properties)
    return TweenService:Create(element, CONFIG.ANIMATION_INFO, properties)
end

-- Signal Sınıfı
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _connections = {} }, Signal)
end

function Signal:Connect(callback)
    table.insert(self._connections, callback)
    return {
        Disconnect = function()
            for i, conn in ipairs(self._connections) do
                if conn == callback then
                    table.remove(self._connections, i)
                    break
                end
            end
        end
    }
end

function Signal:Fire(...)
    for _, callback in ipairs(self._connections) do
        callback(...)
    end
end

-- Ana Modül
local erismodulargui = {}

function erismodulargui:Initialize(modularInfo)
    modularInfo = modularInfo or {}
    
    -- Varsayılan ayarlar
    modularInfo = {
        primaryColor = modularInfo.primaryColor or CONFIG.DEFAULT_COLORS.primary,
        secondaryColor = modularInfo.secondaryColor or CONFIG.DEFAULT_COLORS.secondary,
        backgroundColor = modularInfo.backgroundColor or CONFIG.DEFAULT_COLORS.background,
        textColor = modularInfo.textColor or CONFIG.DEFAULT_COLORS.text,
        accentColor = modularInfo.accentColor or CONFIG.DEFAULT_COLORS.accent,
        font = modularInfo.font or CONFIG.DEFAULT_FONT,
        name = modularInfo.name or "No Big Deal GUI",
        size = modularInfo.size or UDim2.new(0, 600, 0, 420),
        barY = modularInfo.barY or 20,
        maxPages = modularInfo.maxPages or 3,
        draggable = modularInfo.draggable or true,
        centered = modularInfo.centered == nil and false or modularInfo.centered,
        freemouse = modularInfo.freemouse or true,
        toggleBind = modularInfo.toggleBind or nil,
        startMinimized = modularInfo.startMinimized or false,
    }

    -- GUI Oluşturma
    local newGUI
    if RunService:IsStudio() then
        newGUI = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
        newGUI.Name = randomString()
    else
        local COREGUI = cloneref(game:GetService("CoreGui"))
        if get_hidden_gui or gethui then
            local hiddenUI = get_hidden_gui or gethui
            newGUI = Instance.new("ScreenGui")
            newGUI.Name = randomString()
            newGUI.Parent = hiddenUI()
        elseif syn and syn.protect_gui then
            newGUI = Instance.new("ScreenGui")
            newGUI.Name = randomString()
            syn.protect_gui(newGUI)
            newGUI.Parent = COREGUI
        else
            newGUI = Instance.new("ScreenGui")
            newGUI.Name = randomString()
            newGUI.Parent = COREGUI
        end
    end
    newGUI.ResetOnSpawn = false
    newGUI.IgnoreGuiInset = true
    self.GUI = newGUI

    -- Free Mouse Desteği
    local freeMouseButton = Instance.new("TextButton", newGUI)
    freeMouseButton.Size = UDim2.new(1, 0, 1, 0)
    freeMouseButton.BackgroundTransparency = 1
    freeMouseButton.Text = ""
    freeMouseButton.Interactable = false
    freeMouseButton.Modal = modularInfo.freemouse
    freeMouseButton.Visible = not modularInfo.startMinimized

    -- Ana Çerçeve
    local newMainFrame = Instance.new("Frame", newGUI)
    newMainFrame.Size = modularInfo.size
    newMainFrame.BackgroundColor3 = modularInfo.backgroundColor
    newMainFrame.BackgroundTransparency = 0.1
    newMainFrame.BorderSizePixel = 0
    applyCorner(newMainFrame)
    applyShadow(newMainFrame)
    if modularInfo.centered then
        newMainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        newMainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    else
        newMainFrame.Position = UDim2.new(1, -10, 1, -10)
        newMainFrame.AnchorPoint = Vector2.new(1, 1)
    end

    -- Üst Çubuk
    local topBar = Instance.new("Frame", newMainFrame)
    topBar.Size = UDim2.new(1, 0, 0, modularInfo.barY)
    topBar.BackgroundColor3 = modularInfo.primaryColor
    topBar.BorderSizePixel = 0
    applyCorner(topBar)
    applyGradient(topBar, modularInfo.primaryColor, modularInfo.accentColor)

    -- Başlık
    local titleLabel = Instance.new("TextLabel", topBar)
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Text = modularInfo.name
    titleLabel.TextColor3 = modularInfo.textColor
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextScaled = true
    titleLabel.Font = modularInfo.font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local titlePadding = Instance.new("UIPadding", titleLabel)
    titlePadding.PaddingLeft = UDim.new(0, 10)

    -- Kapatma Düğmesi
    local closeButton = Instance.new("TextButton", topBar)
    closeButton.Size = UDim2.new(0, modularInfo.barY, 0, modularInfo.barY)
    closeButton.Position = UDim2.new(1, -5, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = modularInfo.secondaryColor
    closeButton.TextColor3 = modularInfo.textColor
    closeButton.Text = "✕"
    closeButton.TextScaled = true
    closeButton.Font = modularInfo.font
    applyCorner(closeButton)
    closeButton.Activated:Connect(function()
        createTween(newGUI, {Enabled = false}):Play()
        wait(0.3)
        newGUI:Destroy()
    end)

    -- Küçültme Düğmesi
    local minimizeButton = Instance.new("TextButton", topBar)
    minimizeButton.Size = UDim2.new(0, modularInfo.barY, 0, modularInfo.barY)
    minimizeButton.Position = UDim2.new(1, -modularInfo.barY - 10, 0.5, 0)
    minimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    minimizeButton.BackgroundColor3 = modularInfo.secondaryColor
    minimizeButton.TextColor3 = modularInfo.textColor
    minimizeButton.Text = "−"
    minimizeButton.TextScaled = true
    minimizeButton.Font = modularInfo.font
    applyCorner(minimizeButton)

    -- Maksimize Düğmesi
    local maximizeButton = Instance.new("TextButton", newGUI)
    maximizeButton.Size = UDim2.new(0, modularInfo.barY, 0, modularInfo.barY)
    maximizeButton.Position = UDim2.new(1, -10, 1, -10)
    maximizeButton.AnchorPoint = Vector2.new(1, 1)
    maximizeButton.BackgroundColor3 = modularInfo.secondaryColor
    maximizeButton.TextColor3 = modularInfo.textColor
    maximizeButton.Text = "□"
    maximizeButton.TextScaled = true
    maximizeButton.Font = modularInfo.font
    maximizeButton.Visible = false
    applyCorner(maximizeButton)

    -- Sayfa Seçici
    local pageSelector = Instance.new("Frame", newMainFrame)
    pageSelector.Size = UDim2.new(1, 0, 0, modularInfo.barY)
    pageSelector.Position = UDim2.new(0, 0, 0, modularInfo.barY)
    pageSelector.BackgroundColor3 = modularInfo.secondaryColor
    pageSelector.BorderSizePixel = 0
    applyCorner(pageSelector)

    local leftPageButton = Instance.new("TextButton", pageSelector)
    leftPageButton.Size = UDim2.new(0, modularInfo.barY, 0, modularInfo.barY)
    leftPageButton.Position = UDim2.new(0, 5, 0.5, 0)
    leftPageButton.AnchorPoint = Vector2.new(0, 0.5)
    leftPageButton.BackgroundColor3 = modularInfo.accentColor
    leftPageButton.TextColor3 = modularInfo.textColor
    leftPageButton.Text = "◄"
    leftPageButton.TextScaled = true
    leftPageButton.Font = modularInfo.font
    applyCorner(leftPageButton)

    local rightPageButton = Instance.new("TextButton", pageSelector)
    rightPageButton.Size = UDim2.new(0, modularInfo.barY, 0, modularInfo.barY)
    rightPageButton.Position = UDim2.new(1, -5, 0.5, 0)
    rightPageButton.AnchorPoint = Vector2.new(1, 0.5)
    rightPageButton.BackgroundColor3 = modularInfo.accentColor
    rightPageButton.TextColor3 = modularInfo.textColor
    rightPageButton.Text = "►"
    rightPageButton.TextScaled = true
    rightPageButton.Font = modularInfo.font
    applyCorner(rightPageButton)

    local pageIndicator = Instance.new("TextLabel", pageSelector)
    pageIndicator.Size = UDim2.new(0, 50, 1, 0)
    pageIndicator.Position = UDim2.new(0.5, 0, 0.5, 0)
    pageIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
    pageIndicator.BackgroundTransparency = 1
    pageIndicator.TextColor3 = modularInfo.textColor
    pageIndicator.Text = "1/1"
    pageIndicator.TextScaled = true
    pageIndicator.Font = modularInfo.font

    -- İçerik Alanı
    local mainContentFrame = Instance.new("Frame", newMainFrame)
    mainContentFrame.Size = UDim2.new(1, 0, 1, -(modularInfo.barY * 2))
    mainContentFrame.Position = UDim2.new(0, 0, 1, 0)
    mainContentFrame.AnchorPoint = Vector2.new(0, 1)
    mainContentFrame.BackgroundTransparency = 1
    local contentGrid = Instance.new("UIGridLayout", mainContentFrame)
    contentGrid.CellSize = UDim2.new(1 / modularInfo.maxPages, 0, 1, 0)
    contentGrid.CellPadding = UDim.new(0, 5)
    contentGrid.SortOrder = Enum.SortOrder.LayoutOrder

    -- Küçültme/Maksimize İşlevi
    local minimized = modularInfo.startMinimized
    local function handleMinimize()
        minimized = not minimized
        freeMouseButton.Visible = not minimized
        if minimized then
            createTween(newMainFrame, {Size = UDim2.new(0, 200, 0, modularInfo.barY)}):Play()
            createTween(pageSelector, {Position = UDim2.new(0, 0, 0, -modularInfo.barY)}):Play()
            mainContentFrame.Visible = false
            maximizeButton.Visible = true
        else
            createTween(newMainFrame, {Size = modularInfo.size}):Play()
            createTween(pageSelector, {Position = UDim2.new(0, 0, 0, modularInfo.barY)}):Play()
            mainContentFrame.Visible = true
            maximizeButton.Visible = false
        end
    end

    minimizeButton.Activated:Connect(handleMinimize)
    maximizeButton.Activated:Connect(handleMinimize)

    if modularInfo.toggleBind then
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == modularInfo.toggleBind then
                handleMinimize()
            end
        end)
    end

    -- Sürükleme Desteği
    if modularInfo.draggable then
        local dragging, dragStart, startPos
        titleLabel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = UserInputService:GetMouseLocation()
                startPos = newMainFrame.Position
            end
        end)

        RunService:BindToRenderStep("DragGUI", Enum.RenderPriority.Input.Value, function(dt)
            if dragging then
                local mousePos = UserInputService:GetMouseLocation()
                local delta = mousePos - dragStart
                local newPos = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
                newMainFrame.Position = newMainFrame.Position:Lerp(newPos, dt * 20)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- Modül Yönetimi
    local createdModules = {}
    local currentPage = 1
    local modulesPerPage = modularInfo.maxPages

    local function updateModuleVisibility()
        local totalPages = math.ceil(#createdModules / modulesPerPage)
        currentPage = math.clamp(currentPage, 1, totalPages)

        for _, module in pairs(createdModules) do
            module.Frame.Visible = false
            createTween(module.Frame, {Position = UDim2.new(1, 0, 0, 0)}):Play()
        end

        local startIndex = (currentPage - 1) * modulesPerPage + 1
        local endIndex = math.min(startIndex + modulesPerPage - 1, #createdModules)

        for i = startIndex, endIndex do
            local module = createdModules[i]
            module.Frame.Visible = true
            createTween(module.Frame, {Position = UDim2.new(0, 0, 0, 0)}):Play()
        end

        pageIndicator.Text = tostring(currentPage) .. "/" .. tostring(totalPages)
    end

    leftPageButton.Activated:Connect(function()
        if currentPage > 1 then
            currentPage -= 1
            updateModuleVisibility()
        end
    end)

    rightPageButton.Activated:Connect(function()
        if currentPage < math.ceil(#createdModules / modulesPerPage) then
            currentPage += 1
            updateModuleVisibility()
        end
    end)

    -- Hover Efektleri
    local function applyHoverEffect(button)
        button.MouseEnter:Connect(function()
            createTween(button, {BackgroundColor3 = modularInfo.accentColor}):Play()
        end)
        button.MouseLeave:Connect(function()
            createTween(button, {BackgroundColor3 = modularInfo.secondaryColor}):Play()
        end)
    end

    applyHoverEffect(closeButton)
    applyHoverEffect(minimizeButton)
    applyHoverEffect(leftPageButton)
    applyHoverEffect(rightPageButton)

    -- Yeni Modül Oluşturma
    function self:createNewModule(title)
        local moduleFrame = Instance.new("Frame", mainContentFrame)
        moduleFrame.Name = title
        moduleFrame.Size = UDim2.new(1, 0, 1, 0)
        moduleFrame.BackgroundTransparency = 1
        moduleFrame.Visible = false
        applyCorner(moduleFrame)

        local moduleTitle = Instance.new("TextLabel", moduleFrame)
        moduleTitle.Size = UDim2.new(1, 0, 0, modularInfo.barY)
        moduleTitle.Text = title
        moduleTitle.TextColor3 = modularInfo.textColor
        moduleTitle.BackgroundColor3 = modularInfo.secondaryColor
        moduleTitle.TextScaled = true
        moduleTitle.Font = modularInfo.font
        applyCorner(moduleTitle)
        applyGradient(moduleTitle, modularInfo.secondaryColor, modularInfo.accentColor)

        local contentBox = Instance.new("Frame", moduleFrame)
        contentBox.Size = UDim2.new(1, 0, 1, -modularInfo.barY)
        contentBox.Position = UDim2.new(0, 0, 0, modularInfo.barY)
        contentBox.BackgroundTransparency = 0.2
        contentBox.BackgroundColor3 = modularInfo.backgroundColor
        applyCorner(contentBox)
        local contentList = Instance.new("UIListLayout", contentBox)
        contentList.Padding = UDim.new(0, 5)
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        local contentPadding = Instance.new("UIPadding", contentBox)
        contentPadding.PaddingAll = UDim.new(0, 5)

        local module = { Frame = moduleFrame }

        function module:AddText(text)
            local textLabel = Instance.new("TextLabel", contentBox)
            textLabel.Size = UDim2.new(1, 0, 0, modularInfo.barY)
            textLabel.Text = text
            textLabel.TextScaled = true
            textLabel.Font = modularInfo.font
            textLabel.TextColor3 = modularInfo.textColor
            textLabel.BackgroundTransparency = 1
            return textLabel
        end

        function module:AddDivider()
            local divider = Instance.new("Frame", contentBox)
            divider.Size = UDim2.new(1, 0, 0, 2)
            divider.BackgroundColor3 = modularInfo.accentColor
            divider.BackgroundTransparency = 0.5
            return divider
        end

        function module:AddButton(buttonText)
            local button = Instance.new("TextButton", contentBox)
            button.Size = UDim2.new(1, 0, 0, modularInfo.barY + 10)
            button.Text = buttonText
            button.TextScaled = true
            button.Font = modularInfo.font
            button.TextColor3 = modularInfo.textColor
            button.BackgroundColor3 = modularInfo.secondaryColor
            applyCorner(button)
            applyHoverEffect(button)
            return button
        end

        function module:AddToggle(toggleText)
            local toggleData = { state = false }
            local toggleButton = Instance.new("TextButton", contentBox)
            toggleButton.Size = UDim2.new(1, 0, 0, modularInfo.barY + 10)
            toggleButton.Text = toggleText .. ": OFF"
            toggleButton.TextScaled = true
            toggleButton.Font = modularInfo.font
            toggleButton.TextColor3 = modularInfo.textColor
            toggleButton.BackgroundColor3 = modularInfo.secondaryColor
            applyCorner(toggleButton)
            applyHoverEffect(toggleButton)

            toggleButton.Activated:Connect(function()
                toggleData.state = not toggleData.state
                toggleButton.Text = toggleText .. (toggleData.state and ": ON" or ": OFF")
                createTween(toggleButton, {BackgroundColor3 = toggleData.state and modularInfo.accentColor or modularInfo.secondaryColor}):Play()
            end)

            function toggleData:GetState()
                return self.state
            end

            return toggleButton, toggleData
        end

        function module:AddList(listTitle)
            local listContainer = Instance.new("Frame", contentBox)
            listContainer.Size = UDim2.new(1, 0, 0, modularInfo.barY + 10)
            listContainer.BackgroundTransparency = 1

            local titleButton = Instance.new("TextButton", listContainer)
            titleButton.Size = UDim2.new(1, 0, 0, modularInfo.barY + 10)
            titleButton.Text = listTitle
            titleButton.TextScaled = true
            titleButton.Font = modularInfo.font
            titleButton.TextColor3 = modularInfo.textColor
            titleButton.BackgroundColor3 = modularInfo.secondaryColor
            applyCorner(titleButton)
            applyHoverEffect(titleButton)

            local itemListFrame = Instance.new("ScrollingFrame", listContainer)
            itemListFrame.Size = UDim2.new(1, 0, 0, 100)
            itemListFrame.Position = UDim2.new(0, 0, 1, 0)
            itemListFrame.BackgroundColor3 = modularInfo.backgroundColor
            itemListFrame.BackgroundTransparency = 0.2
            itemListFrame.Visible = false
            itemListFrame.ScrollBarThickness = 4
            applyCorner(itemListFrame)

            local listLayout = Instance.new("UIListLayout", itemListFrame)
            listLayout.Padding = UDim.new(0, 5)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder

            titleButton.Activated:Connect(function()
                itemListFrame.Visible = not itemListFrame.Visible
                createTween(itemListFrame, {CanvasSize = itemListFrame.Visible and UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y) or UDim2.new(0, 0, 0, 0)}):Play()
            end)

            local listObject = {
                Frame = listContainer,
                currentItem = nil,
                Items = {},
                OnItemChanged = Signal.new()
            }

            function listObject:AddListItem(itemText, relatedValue)
                relatedValue = relatedValue or itemText
                local itemButton = Instance.new("TextButton", itemListFrame)
                itemButton.Size = UDim2.new(1, 0, 0, modularInfo.barY)
                itemButton.Text = itemText
                itemButton.TextScaled = true
                itemButton.Font = modularInfo.font
                itemButton.TextColor3 = modularInfo.textColor
                itemButton.BackgroundColor3 = modularInfo.secondaryColor
                applyCorner(itemButton)
                applyHoverEffect(itemButton)

                itemButton.Activated:Connect(function()
                    listObject.currentItem = relatedValue
                    titleButton.Text = listTitle .. ": " .. itemText
                    itemListFrame.Visible = false
                    listObject.OnItemChanged:Fire(relatedValue)
                end)

                table.insert(listObject.Items, { Button = itemButton, Value = relatedValue })
                return itemButton
            end

            function listObject:GetCurrentItem()
                return listObject.currentItem
            end

            return listObject
        end

        function module:AddSlider(sliderText, min, max)
            local sliderFrame = Instance.new("Frame", contentBox)
            sliderFrame.Size = UDim2.new(1, 0, 0, modularInfo.barY + 30)
            sliderFrame.BackgroundTransparency = 1

            local sliderLabel = Instance.new("TextLabel", sliderFrame)
            sliderLabel.Size = UDim2.new(1, 0, 0, modularInfo.barY)
            sliderLabel.Text = sliderText .. ": " .. string.format("%.2f", min)
            sliderLabel.TextScaled = true
            sliderLabel.Font = modularInfo.font
            sliderLabel.TextColor3 = modularInfo.textColor
            sliderLabel.BackgroundTransparency = 1

            local sliderHolder = Instance.new("Frame", sliderFrame)
            sliderHolder.Size = UDim2.new(1, 0, 0, modularInfo.barY)
            sliderHolder.Position = UDim2.new(0, 0, 0, modularInfo.barY + 10)
            sliderHolder.BackgroundColor3 = modularInfo.secondaryColor
            applyCorner(sliderHolder)

            local sliderBar = Instance.new("Frame", sliderHolder)
            sliderBar.Size = UDim2.new(0.98, 0, 0.4, 0)
            sliderBar.Position = UDim2.new(0.5, 0, 0.5, 0)
            sliderBar.AnchorPoint = Vector2.new(0.5, 0.5)
            sliderBar.BackgroundColor3 = modularInfo.accentColor
            applyCorner(sliderBar)

            local sliderButton = Instance.new("TextButton", sliderBar)
            sliderButton.Size = UDim2.new(0, modularInfo.barY, 1.5, 0)
            sliderButton.Position = UDim2.new(0, 0, 0.5, 0)
            sliderButton.AnchorPoint = Vector2.new(0, 0.5)
            sliderButton.BackgroundColor3 = modularInfo.primaryColor
            sliderButton.Text = ""
            applyCorner(sliderButton)

            local dragging, dragStart, startPos
            local valueChanged = Signal.new()

            sliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = UserInputService:GetMouseLocation()
                    startPos = sliderButton.Position
                end
            end)

            RunService:BindToRenderStep("SliderDrag", Enum.RenderPriority.Input.Value, function(dt)
                if dragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local delta = mousePos.X - dragStart.X
                    local maxPos = sliderBar.AbsoluteSize.X - sliderButton.AbsoluteSize.X
                    local newPos = math.clamp(startPos.X.Offset + delta, 0, maxPos)
                    sliderButton.Position = UDim2.new(0, newPos, 0.5, 0)

                    local value = min + (newPos / maxPos) * (max - min)
                    sliderLabel.Text = sliderText .. ": " .. string.format("%.2f", value)
                    valueChanged:Fire(value)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            local sliderObject = {
                Frame = sliderFrame,
                GetValue = function()
                    return min + (sliderButton.Position.X.Offset / (sliderBar.AbsoluteSize.X - sliderButton.AbsoluteSize.X)) * (max - min)
                end,
                SetValue = function(value)
                    value = math.clamp(value, min, max)
                    local normalizedValue = (value - min) / (max - min)
                    sliderButton.Position = UDim2.new(normalizedValue, 0, 0.5, 0)
                    sliderLabel.Text = sliderText .. ": " .. string.format("%.2f", value)
                end,
                OnValueChanged = valueChanged
            }

            return sliderObject
        end

        table.insert(createdModules, module)
        updateModuleVisibility()
        return module
    end

    -- Destroy Metodu
    function self:Destroy()
        createTween(newGUI, {Enabled = false}):Play()
        wait(0.3)
        newGUI:Destroy()
    end

    return self
end

return erismodulargui
