local M = {}

local function cargo_executable(source_path)
  local cwd = vim.uv.cwd()
  local manifest = vim.fs.find("Cargo.toml", {
    path = source_path and vim.fs.dirname(source_path) or cwd,
    upward = true,
  })[1]
  if not manifest then
    manifest = vim.fs.find("Cargo.toml", { path = cwd, upward = true })[1]
  end
  if not manifest then
    return nil
  end

  local target_dir = vim.env.CARGO_TARGET_DIR or (vim.fs.dirname(manifest) .. "/target")
  if vim.fn.executable("cargo") == 1 then
    local result = vim.system({
      "cargo", "metadata", "--no-deps", "--format-version", "1", "--offline",
      "--manifest-path", manifest,
    }, { cwd = cwd, text = true }):wait(5000)
    if result.code == 0 then
      local ok, metadata = pcall(vim.json.decode, result.stdout)
      if ok and type(metadata) == "table" and type(metadata.target_directory) == "string" then
        target_dir = metadata.target_directory
      end
    end
  end

  local candidates = {}
  -- Include profiles, cross-compilation targets, examples, and hashed test binaries.
  -- Skip Cargo's internal executables (build scripts and compiler probes).
  for name, kind in vim.fs.dir(target_dir, {
    depth = 4,
    skip = function(dir)
      local basename = vim.fs.basename(dir)
      return basename ~= "build" and basename ~= "incremental" and basename:sub(1, 1) ~= "."
    end,
  }) do
    if kind == "file" or kind == "link" then
      local candidate = target_dir .. "/" .. name
      local extension = vim.fn.fnamemodify(name, ":e")
      if (extension == "" or extension == "exe") and vim.fn.executable(candidate) == 1 then
        local stat = vim.uv.fs_stat(candidate)
        if stat and stat.type == "file" then
          candidates[#candidates + 1] = { path = candidate, mtime = stat.mtime }
        end
      end
    end
  end
  table.sort(candidates, function(a, b)
    if a.mtime.sec ~= b.mtime.sec then
      return a.mtime.sec > b.mtime.sec
    end
    if a.mtime.nsec ~= b.mtime.nsec then
      return a.mtime.nsec > b.mtime.nsec
    end
    return a.path < b.path
  end)
  return candidates[1] and candidates[1].path or nil
end

function M.setup()
  -- SplitAsm has no configurable search directories; extend its resolver so
  -- both :SplitAsmOpen and its setup diagnostics see Cargo build artifacts.
  local runtime = require("splitasm.runtime")
  local resolve = runtime.resolve_executable_path
  runtime.resolve_executable_path = function(config, override, source_path)
    return resolve(config, override, source_path) or cargo_executable(source_path)
  end
end

return M
