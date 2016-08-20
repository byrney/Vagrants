
module ProvisionHelpers
    def provision_ps(lib_path, *script_paths)
        inline = lib_path ?  File.read(lib_path) : ""
        leader = "\nWrite-Host 'Powershell %s'\n"
        inline << script_paths.reduce("") {|memo, script| memo << sprintf(leader, File.basename(script)) << File.read(script) }
        self.provision(:shell, inline: inline)
    end

    def provision_gem(*gems)
        command = "\nWrite-Host 'Gem %s'\ngem install %s\n"
        inline  = gems.reduce("") { |memo, pkg| memo << sprintf(command, pkg, pkg) }
        self.provision(:shell, inline: inline)
    end
end
