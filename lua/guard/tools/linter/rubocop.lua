local diag_fmt = require('guard.lint').diag_fmt
return {
  cmd = 'bundle',
  args = { "exec", "rubocop", "--format", "json", "--force-exclusion", "--stdin" },
  stdin = true,
  output_fmt = function(result, buf)
    local severities = {
      info = 3,
      convention = 3,
      refactor = 4,
      warning = 2,
      error = 1,
      fatal = 1
    }

    local offenses = vim.json.decode(result).files[1].offenses
    local diags = {}

    if #offenses < 1 then
      return {}
    end

    vim.tbl_map(function(mes)
      diags[#diags + 1] = diag_fmt(
        buf,
        tonumber(mes.location.line) - 1,
        tonumber(mes.location.column) - 1,
        mes.message .. " [" .. mes.cop_name .. "]",
        severities[mes.severity] or 4,
        'rubocop'
      )
    end, offenses)

    return diags
  end,
}
