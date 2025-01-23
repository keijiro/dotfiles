local function find_library_dir(start_dir)
  local uv = vim.loop
  local current_dir = start_dir or uv.cwd()

  while current_dir do
    local library_path = current_dir .. "/Library"
    if uv.fs_stat(library_path) then
      return library_path
    end
    local parent_dir = current_dir:match("(.*/)[^/]+/?$")
    if parent_dir == current_dir then break end
    current_dir = parent_dir
  end
  return nil
end

local function change_to_package_cache()
  local library_dir = find_library_dir()
  if not library_dir then
    print("Library directory not found!")
    return
  end

  local package_cache_dir = library_dir .. "/PackageCache"
  local uv = vim.loop

  if uv.fs_stat(package_cache_dir) then
    vim.cmd("lcd " .. package_cache_dir)
    print("Changed directory to: " .. package_cache_dir)
  else
    print("PackageCache directory not found!")
  end
end

return {
  change_to_package_cache = change_to_package_cache,
}
