column_padding = 2

art = {
  source = "./logos/logo.txt"
}

function fetch()
  return {
    columns = {
      art.out,
      {
        color.red(user.name .. "@" .. host.name),
        -- color.red("os:      ") .. string.lower(os.name),
        color.red("os:      ") .. "fedora linux (44)",
        color.yellow("kernel:  ") .. "linux " .. kernel.release,
        -- color.green("cpu:     ") .. string.lower(cpu.name),
        color.green("cpu:     ") .. "intel i5-12400",
        -- color.blue("gpu:     ") .. string.lower(gpu.name),
        color.blue("gpu:     ") .. "nvidia rtx 3060",
        color.magenta("ram:     ") .. string.format("%.1fGB/%.1fGB (%.1f%%)", memory.used_gb, memory.total_gb, memory.percent),
        color.cyan("disk:    ") .. string.format("%.1fGB/%.1fGB (%.1f%%)", disk.used_gb, disk.total_gb, disk.percent),

      }
  }
}
end
