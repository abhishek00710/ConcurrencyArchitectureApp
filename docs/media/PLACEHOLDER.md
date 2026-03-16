# Media Checklist

Use this folder for screenshots and demo recordings that appear in the repository README.

## Expected files

Add the following files with these exact names:

- `dashboard.png`
- `search-lab.png`
- `search-loading.png`
- `quick-demo.gif`
- `demo.mov`
- `social-preview.png`

## Screenshot plan

### `dashboard.png`

Capture the dashboard after data has loaded.

Aim to show:

- hero card
- metric tiles
- trending topics
- recent events

### `search-lab.png`

Capture the Search Lab screen after entering a query and loading results.

Aim to show:

- query text field
- status text
- at least 2 or 3 result cards

### `search-loading.png`

Capture the Search Lab while a request is actively running.

Aim to show:

- typed query
- in-flight request card
- visible loading state

## GIF plan

### `quick-demo.gif`

Keep this short, around 8 to 15 seconds.

Suggested sequence:

1. Launch the app on the dashboard
2. Pull to refresh once
3. Switch to Search Lab
4. Type a query quickly
5. Pause long enough for results to appear

Tips:

- keep the simulator at a phone size that looks good in README
- trim all dead time before exporting
- keep file size small enough for GitHub to load quickly

## MP4 plan

### `demo.mov`

Keep this around 30 to 60 seconds.

Suggested sequence:

1. Show Dashboard and explain parallel loading
2. Mention actor-backed caching and coalescing
3. Switch to Search Lab
4. Show debouncing and cancellation by typing multiple times
5. End on the loaded results state

## Recording tips

- Use iPhone Simulator for consistent screenshots
- Prefer portrait orientation
- Use the same simulator device for every asset
- Use light mode for consistency with the current UI
- Avoid capturing Xcode chrome if the focus is the app itself

## Nice-to-have additions

If you want to go further later, you can also add:

- `architecture-view.png` for a future architecture tab
- `demo-thumbnail.png` for social previews
- a GitHub Release containing the full demo assets
