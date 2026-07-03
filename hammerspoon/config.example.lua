-- =============================================================================
-- Workspace Launcher Configuration
-- =============================================================================
-- Copy this file to config.lua and customize it for your setup.
--   cp config.example.lua config.lua
--
-- config.lua is gitignored so your personal settings won't be committed.
-- =============================================================================

return {
  -- -------------------------------------------------------------------------
  -- Projects Root
  -- -------------------------------------------------------------------------
  -- The folder that contains your coding projects. Subdirectories will appear
  -- in the project chooser. Supports ~ for home directory.
  projectsRoot = "~/Projects",

  -- -------------------------------------------------------------------------
  -- Browser
  -- -------------------------------------------------------------------------
  -- The browser used to open URLs in workflows. Must match the exact
  -- application name as it appears in macOS (e.g. "Safari", "Google Chrome",
  -- "Arc", "Firefox", "Comet").
  browser = "Safari",

  -- -------------------------------------------------------------------------
  -- Coding Apps
  -- -------------------------------------------------------------------------
  -- Apps that get launched when you open a coding project.
  --   name          - Exact macOS application name
  --   openWithPath  - If true, the project folder path is passed to the app
  --                   (useful for editors and terminals). If false, the app
  --                   is just launched/focused without a path argument.
  codingApps = {
    { name = "Visual Studio Code", openWithPath = true },
    { name = "Terminal",           openWithPath = true },
  },

  -- -------------------------------------------------------------------------
  -- Workflows
  -- -------------------------------------------------------------------------
  -- Each workflow appears as an option in the workspace chooser.
  --
  -- Two types of workflows:
  --
  --   1. Project Chooser (type = "project_chooser")
  --      Opens a secondary chooser listing subdirectories of projectsRoot.
  --      When you pick one, all codingApps are launched with that folder.
  --
  --   2. Custom Workflow (any other type)
  --      - apps: list of application names to launch
  --      - urls: list of URLs to open in your configured browser
  --
  -- Fields:
  --   text     - Display name in the chooser
  --   subText  - Description shown below the name
  --   type     - "project_chooser" or any other string
  --   apps     - (custom only) list of app names to launch
  --   urls     - (custom only) list of URLs to open in browser
  workflows = {
    {
      text = "Code",
      subText = "Launch coding apps and choose a project",
      type = "project_chooser",
    },
    {
      text = "Research",
      subText = "Slack and Google Scholar",
      apps = { "Slack" },
      urls = {
        "https://scholar.google.com/",
      },
    },
    {
      text = "Email & Chat",
      subText = "Gmail and Google Chat",
      apps = {},
      urls = {
        "https://mail.google.com/",
        "https://chat.google.com/",
      },
    },
  },

  -- -------------------------------------------------------------------------
  -- Hotkey
  -- -------------------------------------------------------------------------
  -- Keyboard shortcut to open the workspace chooser.
  --   modifiers - table of modifier keys: "cmd", "alt", "shift", "ctrl"
  --   key       - key string (e.g. "return", "space", "a")
  hotkey = {
    modifiers = { "shift", "cmd" },
    key = "return",
  },

  -- -------------------------------------------------------------------------
  -- Karabiner Fallback
  -- -------------------------------------------------------------------------
  -- If you use Karabiner-Elements to map a key to F18 (or another key code),
  -- set this to true and optionally set karabinerKey to the key name.
  -- This overrides the hotkey setting above.
  useKarabinerFallback = false,
  karabinerKey = "F18",
}
