# TODO

Canonical, git-tracked backlog for this repository. This is the single source
of truth for agent-actionable work. The process agents follow is defined in
[AGENTS.md › Todo Processing](./AGENTS.md#todo-processing).

It lives at the repo root, not under `docs/`, on purpose: rcm links every file
under a directory it finds here, so a `docs/` holding anything but `*.md`
(which `rcrc` excludes) would surface as `~/.docs`. This file is excluded by
that same `*.md` rule and is never linked.

## Conventions

- Item format: `- [ ] [<prio>] <area>: <description>` where `<prio>` is `P1`
  (next), `P2` (soon), or `P3` (someday). Priority is optional on `Backlog`.
  `<area>` is the tool or plane touched: `nvim`, `rcm`, `mise`, `nix`, `hypr`,
  `tmux`, `zsh`, …
- States are expressed by which section an item lives in: `Backlog`,
  `In progress`, `Done`.
- An item may carry an owner tag `@<name>` (e.g. `@claude`) while in progress.
- Keep one line per item; add detail as an indented sub-bullet if needed.
- Every item names its **observable check** — there is no test suite here, so an
  item is not closable until someone has run the changed config and looked at
  it. Say which **profile** (`desktop` / `node`) the check was run on; a change
  under the untagged root is only checked once it has been seen on both, or the
  item says why one is enough.

## In progress

- [ ] [P2] bash: full `mise activate bash` in tag-node's 60-deas.sh, so
  interactive non-login shells load per-directory mise `[env]` @claude
  - From the sovera1gn-n0des session (2026-11-12): herdr-core.service starts
    the core with `bash -lc` (login, non-interactive), so profile.d gives
    shims only. Its terminals are interactive non-login shells that read just
    ~/.bashrc, so no cd hook ever loads, and in owners/s0n
    ANSIBLE_VAULT_PASSWORD_FILE stays unset (`ansible-vault edit` prompts).
  - **Observable check (`node`, `devops` on h0):** in a fresh herdr pane,
    `cd owners/s0n` sets `ANSIBLE_VAULT_PASSWORD_FILE`; `type -a hc` still
    lists `~/.local/bin/hc` first; an ssh login shell keeps exactly one mise
    hook.

## Backlog

- [ ] [P3] hypr: Super+C/V in herdr-app send Ctrl+C/V (interrupt, image paste)
  - Omarchy's `default/hypr/bindings/clipboard.lua` sends Ctrl+Shift+C/V only
    to windows tagged `terminal` (`default/hypr/apps/terminals.lua`), and
    Ctrl+C/V to everything else. `herdr-app` (its Wayland app-id) is not on
    that list, so Super+C sends Ctrl+C (unbound: interrupts the agent) and
    Super+V sends Ctrl+V (`terminal.paste_image`, which on Linux never pastes
    text). No `keys.json` binding can catch Super: Hyprland consumes it.
  - Unfixed on omarchy v4.5.0 and on `master` `36b70f1` (2026-11-12); being
    discussed upstream. Revisit once omarchy decides.
  - Interim: `tag-desktop/config/herdr-app/keys.json` is omarchy's own
    `default/herdr-app/keys.json` at `36b70f1` (added after v4.5.0 by
    `8acbf7716`, #18073), linked by rcm so `omarchy-refresh-herdr-app`
    preserves it. Drop it once the installed omarchy ships the file.
  - Candidate local fix: `o.window("herdr-app", { tag = "+terminal" })` in
    `tag-desktop/config/hypr/bindings.lua`. It also makes the window
    transparent like other terminals.
  - **Observable check (desktop):** `hyprctl clients` lists `terminal` in
    herdr-app's tags; in a herdr-app pane, Super+C copies a selection and
    Super+V pastes text.

- [ ] [P2] herdr-core: h0 as the hub for agents across accounts (`sl0p` → `deas`, …)
  - Machine lists are per core (`machines.json` in that core's state): the
    laptop's `hc machine add deas@h0` gives agents ON h0 nothing. For a hub
    that survives the laptop sleeping, h0's `sl0p` core adds the other
    accounts itself: `hc machine add deas@localhost --name deas --install`
    (likewise `c4n4ry`, `devops`).
  - Per herdr-core's source (`remote.rs`, `from_machine`), a dialed machine
    may only call back to terminals here that started work there: parent →
    helper (`hc run --on deas`, `send`, `read`, `wait`) and the helper's
    reports back work over the parent's line; unsolicited agent-to-agent
    messages across accounts do not, by design. Reverse delegation (`deas` →
    `sl0p`) needs `deas`'s core to add `sl0p@localhost` too.
  - Prerequisites per target account: an SSH key from `sl0p` in its
    `~/.ssh/authorized_keys`, and `systemctl --user enable --now
    herdr-core.service` once hc is there (else its terminals have no mise —
    see the closed PATH item). **Needs a human decision before it is picked:**
    a machine entry is effectively a shell as that user (`hc exec`, `hc file
    write`), so each account's owner grants the key, not an agent.
  - **Observable check (`node`, h0):** from an agent in `sl0p`'s core,
    `hc run --on deas --bg --name probe claude "Reply with hc send
    $HC_TERMINAL_ID: probe-ok"` starts by bare name, the `<hc from=…>` report
    reaches the parent, and `hc exec --on deas 'id -un; command -v claude'`
    prints `deas` and a mise shim. Repeat with the laptop asleep: the helper
    keeps running and still reports.

- [ ] [P2] gh: a seat's `git` pushes as `a1auto1gg`, via its forks
  - **Blocked on `sovera1gn-n0des` identity-vault issue 05** (wire `a1auto1gg`
    end to end): the grant (fork vs collaborator vs deploy key) is decided
    there; the fork option was added to 05 on 2026-11-12. The seat key is
    registered (`ssh -T` with it alone answers `a1auto1gg`), but on
    2026-11-12 it could not read the private `deas/sovera1gn-n0des`: no grant
    yet, and no forks.
  - This repo owns the consumer half (ADR-0043): a `Host github.com` entry in
    the seat's `~/.ssh/config` using its seat key (`IdentitiesOnly yes`) —
    **not before the grant**, or pushes lose the forwarded-agent path with
    nothing in its place; and agent instructions to sync the fork before
    starting and open PRs with `gh pr create --repo deas/<repo>`.
  - **Observable check (`node`, the agent seat):** `ssh -T git@github.com`
    answers `a1auto1gg` without a forwarded agent; a push to `deas/<repo>` is
    refused while a push to the fork succeeds; a PR opened from the fork runs
    its checks without secrets.

- [ ] [P2] nvim: the desktop theme plugin is a tracked symlink into `/home/deas`
  - `tag-desktop/config/nvim/lua/plugins/neovim.lua` →
    `/home/deas/.local/state/omarchy/current/theme/neovim.lua`. Any other login
    carrying the `desktop` tag gets a link it cannot read (observed
    2026-10-24 as `sl0p`: `Permission denied`).
  - Either move it to `tag-user-deas-desktop/` or have provisioning create it
    relative to `$HOME` instead of tracking an absolute target.
  - **Observable check:** `readlink ~/.config/nvim/lua/plugins/neovim.lua`
    resolves under the current user's `$HOME` on a desktop, and switching the
    omarchy theme still hot-reloads nvim.
- [ ] [P2] nvim: buffers go stale while an agent edits files from another pane
  - LazyVim only `checktime`s on `FocusGained`/`TermClose`/`TermLeave`;
    `FocusGained` does not reach nvim inside tmux without `focus-events on`,
    which no tmux config here sets.
  - Fix with `set -g focus-events on` plus a `checktime` on `CursorHold` /
    `BufEnter`, or sidekick's `cli.watch` — decide which, not both.
  - **Observable check:** with a file open in nvim, edit it from another tmux
    pane (e.g. `claude` or `sed -i`); the buffer shows the change without `:e`,
    on `node` and `desktop`.
- [ ] [P2] nvim: no one-keystroke review of what an agent changed
  - `vscode-diff.nvim` (`:CodeDiff`), `difft.nvim` and mini-diff are installed
    with no keymaps. Bind e.g. `<leader>gR` (working tree vs HEAD) and
    `<leader>go` (mini-diff overlay toggle).
  - **Observable check:** after an uncommitted edit, `<leader>gR` opens a diff of
    exactly the changed files; which-key lists both maps.
- [ ] [P2] nvim: no mechanical check an agent can run after touching `config/nvim`
  - Replace the dead codecompanion `Makefile` with a `just nvim-check`: headless
    start that fails on any error in `:messages`, plus a filtered
    `:checkhealth` dump. (Note: mason-lspconfig skips `ensure_installed` when
    headless, so missing servers only show up interactively.)
  - **Observable check:** `just nvim-check` exits 0 on a clean tree, and exits
    non-zero after deliberately introducing a `require("nope")` in a plugin spec.
- [ ] [P2] nvim: confirm sidekick's Copilot status error in a real session
  - 2026-10-24, after enabling the sidekick extra on `node` (`8c19b51`), a
    headless `:checkhealth sidekick` reported `Sidekick is not handling Copilot
    LSP status notifications for client: 1`. Suspected artifact of force-loading
    sidekick after the LSP had attached; not verified.
  - **Observable check:** interactive nvim on `node`, open a file, run
    `:checkhealth sidekick` — no `ERROR`. If it persists, find the cause.
- [ ] [P3] nvim: `autocmds.lua` passes an undefined global as the augroup
  - `group = nativeTermGroup` is `nil`, so the TermOpen autocmd has no group and
    re-registers on every re-source. Use `nvim_create_augroup(…, { clear = true })`.
  - **Observable check:** `:source` the file twice, `:autocmd TermOpen` lists the
    callback once, under the named group.
- [ ] [P3] nvim: dead scaffolding copied from codecompanion's repo
  - `config/nvim/Makefile`, `tests/`, `scripts/minimal_init.lua`,
    `lua/plugins/example.lua`, `lua/sandbox.lua`. `tests/test_cmds.lua`
    requires a `tests.helpers` that does not exist. All are linked into
    `~/.config/nvim`. Run `just rcm-clean` after removal for the stale links.
  - **Observable check:** `lsrc | grep nvim` no longer lists them; headless start
    has empty `:messages`.
- [ ] [P3] nvim: `lua/plugins/random.lua` is a 500-line grab bag
  - Split by concern (`ai.lua`, `finder.lua`, `notes.lua`, `lang-extra.lua`) and
    delete the commented-out blocks (mcphub, old sidekick, old obsidian,
    lualine workaround) — git keeps them.
  - **Observable check:** `:Lazy` shows the same plugin set before and after
    (diff the list), headless start clean.
- [ ] [P3] nvim: settle on one agent stack
  - Present today: copilot, sidekick, codecompanion (ACP → `opencode-sandbox`),
    VectorCode (disabled, but its `build` still runs `uv tool install`), mcphub
    remnants. Proposal: sidekick for terminal CLIs, codecompanion only if
    in-buffer chat is wanted. **Needs a human decision before it is picked.**
  - **Observable check:** `:Lazy` lists only the chosen plugins; the chosen
    entrypoints open `claude` / `opencode` on both profiles.
- [ ] [P3] nvim: codecompanion rules load `CONVENTIONS.md`, not `AGENTS.md` / `CLAUDE.md`
  - The repos here carry `AGENTS.md`; in-editor chat should get the same
    instructions as the CLI agents.
  - **Observable check:** a new codecompanion chat in this repo shows
    `AGENTS.md` among its loaded rules.
- [ ] [P3] nvim: Mason installs tools outside the mise/nix planes
  - ~37 binaries under `~/.local/share/nvim/mason/bin` on this node, several
    left over from desktop extras (`dlv`, `netcoredbg`, `ktlint`). Where a tool
    is declared in mise or nix, set `mason = false` like `qml.lua` does.
    fff.nvim's `build` downloads a binary for the same reason.
  - **Observable check:** for each moved tool, `:LspInfo` / `:checkhealth`
    shows it resolved from the mise/nix path, not `mason/bin`.
- [ ] [P3] nvim: let agents in `:terminal` open files in the parent nvim
  - `$NVIM` is set inside `:terminal`; a one-line `nvim-open file:line` wrapper
    around `nvim --server "$NVIM" --remote` plus a sentence in AGENTS.md.
  - **Observable check:** from a `:terminal`, `nvim-open README.md:10` opens it at
    line 10 in the parent instance.
- [ ] [P3] nvim: small cleanups
  - `lazy.lua`: the second `LazyVim/LazyVim` spec repeats `defaults.version = false`.
  - `init.lua`: warns on every start if `osv` is missing; require it inside
    `osv_launch()` instead.
  - codecompanion `log_level = "TRACE"`.
  - `epwalsh/obsidian.nvim` is unmaintained → `obsidian-nvim/obsidian.nvim`.
  - `plugin/after/transparency.lua` lists Telescope/NeoTree/nvim-tree groups
    this config does not use.
  - **Observable check:** headless start clean; obsidian `:checkhealth` clean on a
    machine that has a vault.
- [ ] [P3] nvim: `lazy-lock.json` is gitignored while `checker` auto-updates
  - Every machine drifts to whatever was HEAD at its last update.
  - **2026-10-24: the human decided not to commit the lockfile.** Do not pick
    this up without asking first.

## Done

- [x] [P2] gh: `gh` reads the seat's GitHub token per call, never exported (`6608572`)
  - From the sovera1gn-n0des handover (2026-11-12): `sl0p` on `h0` has
    `~/.config/s0n/secrets/github.token` (classic `repo` token on `a1auto1gg`,
    `secret_files:`). A `gh` wrapper on `~/.local/bin` sets `GH_TOKEN` from it
    for that one process, so shells, make, npm and the agents' other children
    never inherit it, and a re-seeded token applies on the next call. An
    explicit `GH_TOKEN` wins; a seat without the file falls through to `gh`'s
    own auth. Untagged: a pass-through wherever the file is absent.
  - Reaches what has `~/.local/bin` ahead of `/usr/bin`: interactive shells
    and hc terminals (login PATH). Not hermes (`PATH=/usr/local/bin:/usr/bin`,
    and `~/.config/s0n` is `InaccessiblePaths=` for it) — by design.
  - **Observable check (`node`, `sl0p`):** after `just rcm-sync`, `type -a gh`
    lists the wrapper first; `gh api user -q .login` answers `a1auto1gg`; the
    interactive shell has no `GH_TOKEN`; `GH_TOKEN=bogus gh api user` is
    refused (explicit wins); with `HOME` pointing at a dir without the file,
    `gh` falls back to its own auth. As `devops`, `gh api user` answers what
    it did before.
- [x] [P2] ssh: one alias per machine and account for herdr (`5aff5b0`)
  - `tag-desktop/ssh/config`: `agent-work` replaced by `h0-sl0p`, `h0-devops`,
    `h3-sl0p`, `h3-devops`, so hc and the herdr app name machines by host and
    account; `browser-cdp-push` defaults to `h0-sl0p`. `tag-node/ssh/config`:
    only `h3-sl0p`, no `devops` alias on nodes (it would hand `sl0p` on h0
    passwordless root on h3).
  - Observed on `node` (h0, `sl0p`) 2026-11-11: `ssh -G` on both files
    resolves each alias to the intended user and host, `h3-devops` is
    unknown on nodes; `bash -n browser-cdp-push` clean.
  - Not observed: the `desktop` half (`ssh h0-devops id -un`, `hc machine add
    h0-sl0p` named `h0-sl0p`); closed by the human without it.

- [x] herdr-core: declare the `hc` agent skill for node accounts (`bd63ca5`)
  - Upstream's stub in `tag-node/config/asm/skills.yml`,
    `github:herdrdev/herdr-core#master:skills/herdr-core` (the default branch is
    `master`, not `main`), for claude, opencode and pi. The binary stays out of
    this repo: the connecting client installs and updates it.
  - Observed on `node` (h0, `sl0p`) 2026-11-11: `make skills` → `failed=0`,
    re-run `changed=0`; `SKILL.md` installed for all three providers,
    byte-identical to upstream; a Claude started via `hc run --bg` answered
    `herdr-core=yes`.
- [x] [P1] herdr-core: hc terminals on h0 start without mise, so agents aren't found (`eda60c9`)
  - hc gives the core its launcher's environment; a laptop cold-starts it over
    non-interactive ssh, which activates no mise. Fixed by
    `tag-node/config/systemd/user/herdr-core.service`: login bash plus
    `~/.local/bin` → `hc server start`, then `hc server restart --fresh`
    (hc >= 0.1.20; restarts keep the environment from 0.1.19 on).
  - Observed on `node` (h0, `sl0p`) 2026-11-11, hc 0.1.20: after `systemctl
    --user restart herdr-core`, `hc`, `claude`, `pi`, `opencode`, `omp` resolve
    in hc terminals; `hc run --bg --name probe claude` started by bare name and
    answered; after `hc machine update agent-work` from the laptop (new core
    pid) the PATH held.
  - Not observed: a cold boot of h0. Other accounts need their own one-time
    `systemctl --user enable --now herdr-core.service`.

- [x] nvim: free the `f` motion, drop coc.nvim, sidekick on `node` (`8c19b51`)
  - fff.nvim keys moved to `<leader>F*`, its debug overlay off; coc.nvim removed;
    `lazyvim.plugins.extras.ai.sidekick` added to `tag-node`.
  - Observed on `node` 2026-10-24: headless start with empty `:messages`, bare
    `ff`/`fg` unmapped, `<leader>Ff`/`Fg` mapped, `:CocInfo` absent, sidekick
    finds `claude`, `opencode`, `tmux`.
