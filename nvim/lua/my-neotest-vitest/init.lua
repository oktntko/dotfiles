local lib = require("neotest.lib")

---@class neotest.Adapter
local adapter = {
  name = "my-neotest-vitest",
}

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@diagnostic disable-next-line: duplicate-set-field
adapter.root = function(path)
  local result = lib.files.match_root_pattern(
    "vitest.config.ts",
    "vitest.config.js",
    "vite.config.ts",
    "vite.config.js",
    "package.json"
  )(path)

  return result
end

---Filter directories when searching for test files
---@diagnostic disable-next-line: duplicate-set-field
adapter.filter_dir = function(name)
  -- 基本的な除外ディレクトリ
  local ignore_dirs = {
    node_modules = true,
    dist = true,
    build = true,
    [".git"] = true,
  }

  if ignore_dirs[name] then
    return false
  end

  -- プロジェクト構造に応じて、テストが含まれないことが確実なディレクトリを除外
  -- 本来は vitest.config の exclude を参照すべきだが、パフォーマンスのため標準的な除外を適用
  return true
end

---@diagnostic disable-next-line: duplicate-set-field
adapter.is_test_file = function(file_path)
  if not file_path then
    return false
  end

  -- Vitestのデフォルトパターンに近い判定
  -- .test.ts, .spec.ts, .test.js, .spec.js など
  local result = file_path:match("%.test%.[tj]sx?$") or file_path:match("%.spec%.[tj]sx?$")

  return result ~= nil
end

---Given a file path, parse all the tests within it.
---@diagnostic disable-next-line: duplicate-set-field
adapter.discover_positions = function(file_path)
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
    build_position = function(path, source, captured_nodes)
      local match_type = captured_nodes["test.definition"] and "test" or "namespace"
      local name_node = captured_nodes[match_type .. ".name"]

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
      ---@diagnostic disable-next-line: undefined-field
      local range = { definition_node:range() }

      return {
        type = match_type,
        path = path,
        name = display_name,
        origin_name = origin_name, -- 実行時に参照する用の隠しフィールド
        range = range,
      }
    end,
  })

  return result
end

---@diagnostic disable-next-line: duplicate-set-field
adapter.build_spec = function(args)
  local results_path = vim.fn.tempname() .. ".json"
  local tree = args.tree
  local pos = tree:data()

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
    ---@diagnostic disable-next-line: undefined-field
    table.insert(command, pos.origin_name)
  end

  return {
    command = command,
    ---@diagnostic disable-next-line: undefined-global
    output = output_path,
    context = {
      results_path = results_path,
    },
  }
end

---@diagnostic disable-next-line: duplicate-set-field
adapter.results = function(spec, _, tree)
  local results_path = spec.context.results_path

  -- ファイルを読み込む
  local ok, data = pcall(lib.files.read, results_path)

  if not ok then
    return {}
  end

  local decoded = vim.json.decode(data)
  local results = {}
  -- 1. 全ノードをID（パスや名前）で引きやすくするためにフラットなリストにする
  local nodes = {}
  for _, pos in tree:iter() do
    -- pos.type は 'file', 'namespace', 'test' のいずれか
    if pos.type == "test" then
      -- 行番号をキーにしてノードを保持（0-indexedに合わせるため -1）
      -- Vitest の line が 10 なら、Neotest の 9 行目と一致させる
      nodes[pos.range[1]] = pos
    end
  end

  -- 2. Vitest の結果をループして回す
  for _, testFile in ipairs(decoded.testResults or {}) do
    for _, assertion in ipairs(testFile.assertionResults or {}) do
      -- Vitest の行番号（1-indexed）を取得
      local line = assertion.location and assertion.location.line

      if line then
        -- Neotest の 0-indexed に合わせて検索（1つ上を探す）
        local pos = nodes[line - 1]

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

  local status = "failed"
  if ((decoded.numPassedTests or 0) + (decoded.numFailedTests or 0)) == 0 then
    status = "skipped"
  elseif decoded.success then
    status = "passed"
  end

  results[tree:data().id] = {
    status = status,
    ---@diagnostic disable-next-line: undefined-field
    output = spec.output,
  }

  return results
end

return adapter
