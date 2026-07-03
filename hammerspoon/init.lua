local configPath = hs.configdir .. "/config.lua"
local config

if hs.fs.attributes(configPath) then
  config = dofile(configPath)
else
  hs.alert.show("Workspace Launcher: config.lua not found! Copy config.example.lua to config.lua", 5)
  return
end

local projectsRoot = config.projectsRoot or os.getenv("HOME") .. "/Projects"
if projectsRoot:sub(1, 1) == "~" then
  projectsRoot = os.getenv("HOME") .. projectsRoot:sub(2)
end

local browser = config.browser or "Safari"
local useKarabinerFallback = config.useKarabinerFallback or false
local codingApps = config.codingApps or {}
local workflows = config.workflows or {}

local function shellQuote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function openApp(appName)
  hs.application.launchOrFocus(appName)
end

local function openUrlInBrowser(url)
  hs.execute("/usr/bin/open -a " .. shellQuote(browser) .. " " .. shellQuote(url), true)
end

local function openPathInApp(appName, path)
  hs.execute("/usr/bin/open -a " .. shellQuote(appName) .. " " .. shellQuote(path), true)
end

local codexBin = "/Applications/Codex.app/Contents/Resources/codex"
local codexGlobalState = os.getenv("HOME") .. "/.codex/.codex-global-state.json"

local function launchCodexAtPath(path)
  hs.execute(shellQuote(codexBin) .. " app " .. shellQuote(path) .. " >/dev/null 2>&1 &", true)
end

local function prepareCodexWorkspace(path)
  local f = io.open(codexGlobalState, "r")
  if not f then
    return
  end
  local content = f:read("*a")
  f:close()

  local ok, state = pcall(hs.json.decode, content)
  if not ok or type(state) ~= "table" then
    return
  end

  state["active-workspace-roots"] = { path }
  state["electron-saved-workspace-roots"] = { path }

  local out, err = io.open(codexGlobalState, "w")
  if not out then
    print("Workspace launcher: could not write Codex global state: " .. tostring(err))
    return
  end
  out:write(hs.json.encode(state))
  out:close()
end

local function stopCodexAppServer(path)
  hs.execute(shellQuote(codexBin) .. " app-server daemon stop >/dev/null 2>&1", true)
  hs.execute("/usr/bin/pkill -f " .. shellQuote("/Applications/Codex.app/Contents/Resources/codex app-server") .. " >/dev/null 2>&1", true)
  prepareCodexWorkspace(path)
end

local function codexGuiRunning()
  return hs.application.get("com.openai.codex") or hs.application.get("Codex")
end

local function openCodexAtPath(path)
  -- Codex.app is a single-instance Electron app backed by a persistent
  -- `codex app-server` daemon. To force a workspace switch we must quit the
  -- GUI AND stop the daemon before relaunching.
  local existing = codexGuiRunning()

  if not existing then
    stopCodexAppServer(path)
    hs.timer.doAfter(0.25, function() launchCodexAtPath(path) end)
    return
  end

  existing:kill()

  local attempts = 0
  local maxAttempts = 40  -- ~4s total
  local function relaunchWhenGone()
    attempts = attempts + 1
    local still = codexGuiRunning()
    if not still then
      stopCodexAppServer(path)
      hs.timer.doAfter(0.35, function() launchCodexAtPath(path) end)
    elseif attempts >= maxAttempts then
      still:kill9()
      hs.timer.doAfter(0.3, function()
        stopCodexAppServer(path)
        hs.timer.doAfter(0.35, function() launchCodexAtPath(path) end)
      end)
    else
      hs.timer.doAfter(0.1, relaunchWhenGone)
    end
  end
  hs.timer.doAfter(0.1, relaunchWhenGone)
end

local function openCodingProject(projectPath, projectName)
  for _, app in ipairs(codingApps) do
    if app.name == "Codex" then
      openCodexAtPath(projectPath)
    elseif app.openWithPath then
      openPathInApp(app.name, projectPath)
    else
      openApp(app.name)
    end
  end
  hs.alert.show("Opened " .. projectName .. " workspace")
end

local function directProjectChoices()
  local choices = {}

  local iterator, errorMessage = hs.fs.dir(projectsRoot)
  if not iterator then
    table.insert(choices, {
      text = "Projects folder not found",
      subText = errorMessage or projectsRoot,
      disabled = true,
    })
    return choices
  end

  local projectNames = {}
  for name in iterator do
    if name ~= "." and name ~= ".." and name:sub(1, 1) ~= "." then
      local path = projectsRoot .. "/" .. name
      local attributes = hs.fs.attributes(path)
      if attributes and attributes.mode == "directory" then
        table.insert(projectNames, name)
      end
    end
  end

  table.sort(projectNames, function(a, b)
    return a:lower() < b:lower()
  end)

  for _, name in ipairs(projectNames) do
    local path = projectsRoot .. "/" .. name
    table.insert(choices, {
      text = name,
      subText = path,
      projectPath = path,
    })
  end

  return choices
end

local projectChooser = hs.chooser.new(function(choice)
  if not choice or choice.disabled then
    return
  end

  openCodingProject(choice.projectPath, choice.text)
end)

projectChooser:placeholderText("Choose a coding project")
projectChooser:searchSubText(true)

local function showProjectChooser()
  projectChooser:choices(directProjectChoices())
  projectChooser:show()
end

local function resolveWorkflow(workflow)
  return function()
    if workflow.type == "project_chooser" then
      showProjectChooser()
    else
      if workflow.apps then
        for _, appName in ipairs(workflow.apps) do
          openApp(appName)
        end
      end
      if workflow.urls then
        for _, url in ipairs(workflow.urls) do
          openUrlInBrowser(url)
        end
      end
      hs.alert.show("Opened " .. workflow.text)
    end
  end
end

local workflowChooser = hs.chooser.new(function(choice)
  if not choice then
    return
  end

  workflows[choice.workflowIndex].run()
end)

local workflowChoices = {}
for index, workflow in ipairs(workflows) do
  workflow.run = resolveWorkflow(workflow)
  table.insert(workflowChoices, {
    text = workflow.text,
    subText = workflow.subText,
    workflowIndex = index,
  })
end

workflowChooser:choices(workflowChoices)
workflowChooser:placeholderText("Choose a workspace")
workflowChooser:searchSubText(true)

local function showWorkflowChooser()
  workflowChooser:show()
end

if useKarabinerFallback then
  hs.hotkey.bind({}, config.karabinerKey or "F18", showWorkflowChooser)
else
  local hotkey = config.hotkey or { modifiers = { "shift", "cmd" }, key = "return" }
  hs.hotkey.bind(hotkey.modifiers, hotkey.key, showWorkflowChooser)
end

hs.alert.show("Workspace launcher loaded")
