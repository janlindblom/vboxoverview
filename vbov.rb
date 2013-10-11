

module VirtualBox
  class VM
    attr_accessor :uuid, :name

    def enable_metrics
      ok = system "VBoxManage metrics setup #{self.name}"
      ok = system "VBoxManage metrics enable #{self.name}"
      ok = system "VBoxManage metrics collect --detach #{self.name}"
      ok
    end

    def load
      load = `VBoxManage metrics query #{self.name} Guest/CPU/Load/User`
      match = load.scan /[\w\-]+\s+CPU\/Load\/User\s+(\d+\.\d+)\%$/
      if match
        match[0][0]
      else
	0
      end
    end

    def memory
      mem_tot = `VBoxManage metrics query #{self.name} Guest/RAM/Usage/Total`
      mem_free = `VBoxManage metrics query #{self.name} Guest/RAM/Usage/Free`
      {:used => mem_used, :total => mem_tot}
    end
  end
end

hosts = `VBoxManage list vms`.lines.map(&:chomp).to_a

hostmap = []

hosts.each do |hoststring|
  res = hoststring.scan(/\"(.*)\"\s\{(.*)\}/)
  res.each do |r|
    vm = VirtualBox::VM.new()
    vm.uuid = r[1]
    vm.name = r[0]
    hostmap << vm
  end
end

hostmap.each do |host|
  #host.enable_metrics

  puts "#{host.name}: #{host.load}% CPU, #{host.memory}"
end

