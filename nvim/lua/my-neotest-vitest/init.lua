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
    ;; describe ブロック
    ((call_expression
      function: (identifier) @func_name (#match? @func_name "^(describe)$")
      arguments: (arguments . [(string) (template_string)] @namespace.name)
    )) @namespace.definition

    ;; 通常の test/it ブロック
    ((call_expression
      function: (identifier) @func_name (#match? @func_name "^(test|it)$")
      arguments: (arguments . [(string) (template_string)] @test.name)
    )) @test.definition

    ;; test.each([...])('name') や test.for([...])('name')
    ;; 呼び出しの結果をさらに呼び出している構造を広く捉える
    ((call_expression
      function: (call_expression
        function: (member_expression
          object: (identifier) @func_name (#match? @func_name "^(test|it)$")
          property: (property_identifier) @method (#match? @method "^(each|for)$")
        )
      )
      arguments: (arguments . [(string) (template_string)] @test.name)
    )) @test.definition

    ;; test.each`table`('name') 
    ;; tagged_template_expression の代わりに、より一般的な構造でマッチを試みる
    ((call_expression
      function: (binary_expression
        left: (member_expression
          object: (identifier) @func_name (#match? @func_name "^(test|it)$")
          property: (property_identifier) @method (#match? @method "^(each|for)$")
        )
      )
      arguments: (arguments . [(string) (template_string)] @test.name)
    ) @test.definition)
    
    ;; フォールバック: あらゆる .each / .for の呼び出しの引数を test.name として試行
    ((call_expression
      function: [
        (member_expression 
          object: (call_expression)
          property: (property_identifier) @method (#match? @method "^(each|for)$")
        )
        (member_expression
          object: (identifier) @func_name (#match? @func_name "^(test|it)$")
          property: (property_identifier) @method (#match? @method "^(each|for)$")
        )
      ]
      arguments: (arguments . [(string) (template_string)] @test.name)
    )) @test.definition
  ]]

  ---@diagnostic disable-next-line: missing-fields position_id を実装すると行単位のテストが実行できない
  local result = lib.treesitter.parse_positions(file_path, query, {
    nested_tests = true,
    require_namespaces = false,
    build_position = function(file_path, source, captured_nodes)
      local match_type = captured_nodes["test.definition"] and "test" or "namespace"
      local name_node = captured_nodes[match_type .. ".name"]

      if not name_node then
        return nil
      end

      if not name_node then
        return nil
      end

      local raw_name = vim.treesitter.get_node_text(name_node, source)

      -- 1. Vitest 実行用のオリジナル名 (引用符だけ外す)
      local origin_name = raw_name:gsub("^['\"`]", ""):gsub("['\"`]$", "")

      -- 2. Summary 表示用の整形名 (改行を消して空白を集約)
      local display_name = origin_name:gsub("[\r\n]", " "):gsub("%s+", " ")
      display_name = vim.trim(display_name)

      local definition_node = captured_nodes[match_type .. ".definition"]
      local range = { definition_node:range() }

      logger.info("[build_position] name:" .. vim.inspect(display_name))

      return {
        type = match_type,
        path = file_path,
        name = display_name,
        origin_name = origin_name, -- 実行時に参照する用の隠しフィールド
        range = range,
      }
    end,
  })

  logger.info("[discover_positions] result:" .. vim.inspect(result))
  return result
end

---@diagnostic disable-next-line: duplicate-set-field
adapter.build_spec = function(args)
  local results_path = vim.fn.tempname() .. ".json"
  local tree = args.tree
  local pos = tree:data()
  logger.info(
    "[build_spec] type:"
      .. vim.inspect(pos.type)
      .. ", path:"
      .. vim.inspect(pos.path)
      .. ", name:"
      .. vim.inspect(pos.name)
      .. ", extra_args:"
      .. vim.inspect(args.extra_args)
      .. ", strategy:"
      .. vim.inspect(args.strategy)
  )

  local command = {
    "pnpm",
    "vitest",
    "run",
    pos.path, -- 対象ファイル
    "--reporter=default",
    "--reporter=json",
    "--outputFile=" .. results_path,
  }

  -- 実行対象が 'test' または 'namespace' (describe) の場合、フィルタを追加
  if pos.type == "test" or pos.type == "namespace" then
    -- pos.name は Treesitter でキャプチャした名前です
    table.insert(command, "-t")

    logger.info("[pos.name] pos.name:" .. vim.inspect(pos.origin_name))

    -- テスト名にバッククオートが含まれているとそのままコマンド引数に渡り、
    -- テスト名とコマンド引数が一致しなくなるため、バッククオートを削除してコマンド引数に渡す
    local name = not pos.origin_name and "" or pos.origin_name:gsub("%$[%w_%.]+", ".*"):gsub("%%[sdjif%d%.]+", ".*")
    table.insert(command, name)
  end

  return {
    command = command,
    output = output_path,
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

  -- 1. 全ノードをID（パスや名前）で引きやすくするためにフラットなリストにする
  local nodes = {}
  for _, pos in tree:iter() do
    logger.info("[results] pos:" .. vim.inspect(pos))

    -- pos.type は 'file', 'namespace', 'test' のいずれか
    if pos.type == "test" then
      -- 行番号をキーにしてノードを保持（0-indexedに合わせるため -1）
      -- Vitest の line が 10 なら、Neotest の 9 行目と一致させる
      logger.info("[results] range:" .. pos.range[1] .. ", name:" .. pos.name)

      nodes[pos.range[1]] = pos
    end
  end

  -- 2. Vitest の結果をループして回す
  for _, testFile in ipairs(decoded.testResults or {}) do
    for _, assertion in ipairs(testFile.assertionResults or {}) do
      -- Vitest の行番号（1-indexed）を取得
      local line = assertion.location and assertion.location.line
      logger.info(
        "[results] location:" .. vim.inspect(assertion.location) .. ", line:" .. vim.inspect(assertion.location.line)
      )

      if line then
        -- Neotest の 0-indexed に合わせて検索（1つ上を探す）
        local pos = nodes[line - 1]
        logger.info("[results] start line:" .. vim.inspect(line) .. ", pos:" .. vim.inspect(pos))

        if pos then
          -- マッチしたノードに対して結果を格納
          results[pos.id] = {
            status = assertion.status == "passed" and "passed" or "failed",
            short = assertion.title,
            errors = assertion.status == "failed" and {
              {
                message = table.concat(assertion.failureMessages, "\n"),
                line = line - 1,
              },
            } or nil,
          }
        end
      end
    end
  end

  -- 3. 最後にファイル自体のステータスも忘れずに入れる
  results[tree:data().id] = {
    status = decoded.success and "passed" or "failed",
    output = spec.output,
  }
  logger.info("[results] results:" .. vim.inspect(results))

  return results
end

return adapter
