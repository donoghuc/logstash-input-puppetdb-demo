Facter.add('node_group') do
    setcode do
      hostname = Facter.value(:hostname)
      case hostname
      when /agent[1-2]/
        'webserver'
      when /agent[3-4]/
        'database'
      else
        'application'
      end
    end
  end