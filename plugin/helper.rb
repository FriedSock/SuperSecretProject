def get_first_number string
  string.split(' ')[1..-1].each do |token|
    if token.to_i.to_s.to_i != 0
      return token
    end
  end
  return 'Aint been commited yet!'
end

def run
  filename = VIM::Buffer.current.name
  size = VIM::Buffer.current.length

  new_name = filename + '-prime'
  VIM::command("badd #{new_name}")
  new_buffer = VIM::Buffer[VIM::Buffer.count-1]

  (1..size).each do |line|
    command = 'git blame ' + filename + ' -L ' + line.to_s + ',' + line.to_s + ' -t'
    git_out = VIM::evaluate("ShellCall('" + command + "')")
    new_buffer.append line-1,  get_first_number(git_out)
  end

  VIM::command('vertical 20 new')
  VIM::command('edit ' + new_name)
  VIM::command('normal GGdd')
end