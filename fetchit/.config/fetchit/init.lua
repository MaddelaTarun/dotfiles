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
        color.red("os:      ") .. string.lower(os.name),
        color.yellow("kernel:  ") .. "linux " .. kernel.release,
        color.green("cpu:     ") .. string.lower(cpu.name),
        color.blue("gpu:     ") .. string.lower(gpu.name),
        color.magenta("ram:     ") .. string.format("%.1fGB/%.1fGB (%.1f%%)", memory.used_gb, memory.total_gb, memory.percent),
        color.cyan("disk:    ") .. string.format("%.1fGB/%.1fGB (%.1f%%)", disk.used_gb, disk.total_gb, disk.percent),

      }
  }
}
end
