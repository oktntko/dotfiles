local async = require("neotest.async")
local lib = require("neotest.lib")
local logger = require("neotest.logging")
local types = require("neotest.types")

---@class neotest.Adapter
local adapter = {
  name = "my-neotest-vitest",
}

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@diagnostic disable-next-line: duplicate-set-field
adapter.root = function(path)
  logger.debug("[root] path:" .. path)

  local result = lib.files.match_root_pattern("package.json")(path)

  logger.debug("[root] result:" .. vim.inspect(result))
  return result
  -- TODO: vitest.config.ts だとダメなのか？
end

---Filter directories when searching for test files
---@diagnostic disable-next-line: duplicate-set-field
adapter.filter_dir = function(name, rel_path, root)
  logger.debug("[filter_dir] name:" .. name .. ", rel_path:" .. rel_path .. ", root" .. root)

  local result = name ~= "node_modules"

  logger.debug("[filter_dir] result:" .. vim.inspect(result))
  return result
  -- TODO: vitest.config.ts から読めないか？
end

---@diagnostic disable-next-line: duplicate-set-field
adapter.is_test_file = function(file_path)
  logger.debug("[is_test_file] file_path:" .. file_path)

  local result = file_path:match("%.test%.ts$") or file_path:match("%.spec%.ts$")

  logger.debug("[is_test_file] result:" .. vim.inspect(result))
  return result
  -- TODO: vitest.config.ts から読めないか？
end

---Given a file path, parse all the tests within it.
---@diagnostic disable-next-line: duplicate-set-field
adapter.discover_positions = function(file_path)
  logger.info("[discover_positions] file_path:" .. file_path)

  local query = [[
    ((call_expression
      function: (identifier) @test_name
        (#match? @test_name "^(test|it|describe)$")
    )) @scope.root
  ]]
  local result = lib.treesitter.parse_positions(file_path, query, {
    nested_tests = false,
    require_namespaces = false,
    position_id = function(position, parents)
      return position.id
    end,
  })

  logger.info("[discover_positions] result:" .. vim.inspect(result))
  return result
end

---@diagnostic disable-next-line: duplicate-set-field
adapter.build_spec = function(args)
  logger.info("[build_spec] args:" .. vim.inspect(args))

  local results_path = vim.fn.tempname() .. ".json"
  local tree = args.tree
  local position = tree:data()

  return {
    command = {
      "pnpm",
      "vitest",
      "run",
      position.path,
      "--reporter=json",
      "--outputFile=" .. results_path,
    },
    context = {
      results_path = results_path,
    },
  }
end

---@diagnostic disable-next-line: duplicate-set-field
adapter.results = function(spec, result, tree)
  logger.info("[results] spec:" .. vim.inspect(spec), ", result:" .. vim.inspect(result))

  local results_path = spec.context.results_path

  -- ファイルを読み込む
  local ok, data = pcall(lib.files.read, results_path)
  logger.info("[results] ok:" .. vim.inspect(ok))

  if not ok then
    return {}
  end
  logger.info("[results] data:" .. vim.inspect(data))

  local decoded = vim.json.decode(data)
  local results = {}

  -- 1. ファイル単位の結果をまず入れる
  -- tree:data().id は通常、ファイルの絶対パスです
  local file_id = tree:data().id
  results[file_id] = {
    status = decoded.success and "passed" or "failed",
    output = spec.context.results_path, -- フルログのパス
    short = decoded.success and "All tests passed" or "Some tests failed",
  }

  -- 2. (オプション) 個別テスト（行）の結果をマッピングする
  -- ここを実装すると、エディタの各行に ✔ や ✖ がつきます
  for _, testFile in ipairs(decoded.testResults or {}) do
    for _, assertion in ipairs(testFile.assertionResults or {}) do
      -- Vitest の JSON は 1-indexed の行番号を location.line に持っています
      -- Neotest の ID 体系に合わせるため、tree から子ノードを探す必要があります
      -- 最小構成なら、まずファイル単位の結果が出るだけで十分感動します！
    end
  end
  logger.info("[results] results:" .. vim.inspect(results))

  return results
end

return adapter
