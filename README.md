# Workspace Launcher

A Hammerspoon-based workspace launcher for macOS. Hit a keyboard shortcut, pick a workspace, and all the right apps and URLs open automatically.

## What It Does

- **Workspace Chooser** -- press `Shift+Cmd+Return` (configurable) and select a workspace from a searchable list
- **Project Chooser** -- the "Code" workflow lists all subdirectories in your projects folder; pick one and your editor, terminal, and other tools open with that folder
- **Custom Workflows** -- define any number of named workflows that launch specific apps and open specific URLs in your browser

## Requirements

- macOS
- [Hammerspoon](https://www.hammerspoon.org/) (or [Spoon](https://github.com/Hammerspoon/Spoon) if you prefer the App Store build)

## Installation

1. **Install Hammerspoon** if you haven't already:
   ```bash
   brew install --cask hammerspoon
   ```

2. **Clone this repo** into your Hammerspoon configuration directory:
   ```bash
   # This replaces your existing Hammerspoon config.
   # Back it up first if you have one:
   mv ~/.hammerspoon ~/.hammerspoon-backup

   git clone https://github.com/Dav50505/workspace-picker.git ~/.hammerspoon
   ```

   If you already have a Hammerspoon setup you want to keep, you can integrate the files manually -- just copy the contents of the `hammerspoon/` directory into `~/.hammerspoon/`.

3. **Create your config file** from the example:
   ```bash
   cd ~/.hammerspoon
   cp config.example.lua config.lua
   ```

4. **Edit `config.lua`** to match your setup (see Configuration below).

5. **Reload Hammerspoon** -- click the Hammerspoon icon in the menu bar and choose "Reload Config", or run:
   ```bash
   hs -c "hs.reload()"
   ```

You should see a brief alert saying "Workspace launcher loaded".

## Configuration

All personal settings live in `config.lua` (which is gitignored). The file is a Lua script that returns a single table. Here's what each field does:

### `projectsRoot`

The folder whose subdirectories appear in the project chooser. Supports `~` for home.

```lua
projectsRoot = "~/Projects"
```

### `browser`

The browser used to open URLs in workflows. Must match the exact application name as shown in macOS.

```lua
browser = "Safari"       -- or "Google Chrome", "Arc", "Firefox", "Brave Browser", etc.
```

### `codingApps`

A list of apps launched when you open a coding project from the project chooser.

```lua
codingApps = {
  { name = "Visual Studio Code", openWithPath = true },
  { name = "Terminal",           openWithPath = true },
}
```

- **`name`** -- Exact macOS application name
- **`openWithPath`** -- If `true`, the project folder path is passed as an argument to the app (useful for editors/terminals). If `false`, the app is just launched without arguments.

Common examples:

```lua
codingApps = {
  { name = "Visual Studio Code", openWithPath = true },
  { name = "Cursor",             openWithPath = true },
  { name = "Warp",               openWithPath = true },
  { name = "Terminal",           openWithPath = true },
  { name = "iTerm",              openWithPath = true },
  { name = "Codex",              openWithPath = true },
  { name = "Docker Desktop",     openWithPath = false },
}
```

### `workflows`

A list of workspace definitions that appear in the chooser. Two types:

#### Project Chooser Workflow

Opens a secondary chooser listing subdirectories of `projectsRoot`. When you pick one, all `codingApps` are launched with that folder.

```lua
{
  text = "Code",
  subText = "Launch coding apps and choose a project",
  type = "project_chooser",
}
```

#### Custom Workflow

Launches specific apps and opens specific URLs in your browser.

```lua
{
  text = "Research",
  subText = "Slack and Google Scholar",
  apps = { "Slack" },
  urls = {
    "https://scholar.google.com/",
  },
}
```

You can omit `apps` or `urls` if you only need one or the other:

```lua
{
  text = "Email",
  subText = "Open Gmail",
  urls = { "https://mail.google.com/" },
},
{
  text = "Chat",
  subText = "Open Slack and Discord",
  apps = { "Slack", "Discord" },
},
```

### `hotkey`

The keyboard shortcut that opens the workspace chooser.

```lua
hotkey = {
  modifiers = { "shift", "cmd" },
  key = "return",
}
```

Available modifiers: `"cmd"`, `"alt"`, `"shift"`, `"ctrl"`.

Common key examples: `"return"`, `"space"`, `"p"`, `"f5"`, etc. See the [Hammerspoon docs](https://www.hammerspoon.org/docs/hs.keycodes.html) for key string names.

### `useKarabinerFallback` and `karabinerKey`

If you use [Karabiner-Elements](https://karabiner-elements.pqrs.org/) to map a physical key to a virtual key code (like F18), set this to `true`. This overrides the `hotkey` setting above.

A ready-made Karabiner complex modification is included at `hammerspoon/karabiner-shift-command-return-to-f18.json`. To use it:

1. Open Karabiner-Elements Settings > Complex Modifications > Add Rule
2. Import the JSON file
3. Enable the "Map shift + command + return to F18" rule
4. In your `config.lua`, set `useKarabinerFallback = true`

```lua
useKarabinerFallback = true,
karabinerKey = "F18",
```

## Full Example Config

```lua
return {
  projectsRoot = "~/Projects",

  browser = "Arc",

  codingApps = {
    { name = "Visual Studio Code", openWithPath = true },
    { name = "Warp",               openWithPath = true },
  },

  workflows = {
    {
      text = "Code",
      subText = "Launch VS Code + Warp and choose a project",
      type = "project_chooser",
    },
    {
      text = "School",
      subText = "Canvas and Google Docs",
      apps = {},
      urls = {
        "https://canvas.university.edu/",
        "https://docs.google.com/",
      },
    },
    {
      text = "Work",
      subText = "Slack, Gmail, and Jira",
      apps = { "Slack", "Zoom" },
      urls = {
        "https://mail.google.com/",
        "https://company.atlassian.net/",
      },
    },
    {
      text = "Personal",
      subText = "YouTube and Reddit",
      apps = {},
      urls = {
        "https://youtube.com/",
        "https://reddit.com/",
      },
    },
  },

  hotkey = {
    modifiers = { "shift", "cmd" },
    key = "return",
  },

  useKarabinerFallback = false,
}
```

## File Structure

```
~/.hammerspoon/
  init.lua              -- Core logic (no personal data)
  config.example.lua    -- Example configuration with comments
  config.lua            -- Your personal config (gitignored)
```

## Troubleshooting

- **"config.lua not found" alert** -- Make sure you copied `config.example.lua` to `config.lua` in the same directory as `init.lua`.
- **Apps don't launch** -- App names must match exactly what macOS shows. Check in `/Applications` or use `hs.application.runningApplications()` in the Hammerspoon console to find the correct name.
- **URLs open in the wrong browser** -- Update the `browser` setting in `config.lua` to the exact application name.
- **Projects folder not found** -- Verify `projectsRoot` points to an existing directory. Use `~` instead of the full home path.

## License

MIT
