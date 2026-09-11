-- Build the shared LSP registry used for plugin provisioning and runtime activation.
-- Language modules only declare data; this file validates and combines it.
--
-- This explicit manifest controls which languages are active. Merely adding a
-- file under lua/languages/ does not opt it into the configuration.
local containers = {
  require("languages.python"),
}

-- Keep configurations keyed by server name for config.lsp, and keep a separate
-- name array because mason-lspconfig's ensure_installed option expects one.
local registry = {
  servers = {},
  server_names = {},
}

-- These builder-only lookup tables detect ambiguous ownership. They are not
-- included in the registry returned to consumers.
local language_names = {}
local server_owners = {}

-- Reject a malformed container before accepting any declarations from it.
for _, container in ipairs(containers) do
  assert(type(container) == "table", "each language container must return a table")
  assert(
    type(container.name) == "string" and container.name ~= "",
    "each language container needs a name"
  )
  assert(
    not language_names[container.name],
    ("duplicate language container %q"):format(container.name)
  )
  assert(
    type(container.servers) == "table",
    ("language %q needs a servers table"):format(container.name)
  )

  language_names[container.name] = true

  -- A server must have exactly one language owner. Its configuration table is
  -- preserved as the local override passed later to vim.lsp.config().
  for server_name, server_config in pairs(container.servers) do
    assert(
      type(server_name) == "string" and server_name ~= "",
      ("language %q has an invalid server name"):format(container.name)
    )
    assert(
      type(server_config) == "table",
      ("server %q in language %q needs a config table"):format(server_name, container.name)
    )
    assert(
      not server_owners[server_name],
      ("server %q is owned by both %q and %q"):format(
        server_name,
        server_owners[server_name],
        container.name
      )
    )

    -- Store the same configuration table by name, then append that name for
    -- consumers such as Mason that need an array rather than a keyed table.
    server_owners[server_name] = container.name
    registry.servers[server_name] = server_config
    registry.server_names[#registry.server_names + 1] = server_name
  end
end

-- pairs() does not guarantee declaration order, so stabilize the name array for
-- predictable provisioning and debugging.
table.sort(registry.server_names)

-- plugins.lsp reads server_names for installation and passes the whole registry
-- to config.lsp for activation.
return registry
