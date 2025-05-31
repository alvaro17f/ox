package app

import "../utils"
import "core:fmt"

ox :: proc(config: ^Config) {
	print_config(config)

	if (utils.confirm(default_value = true)) {
		utils.title_maker("Git Pull")
		cmd_git_pull(config.repo)

		if (config.update) {
			utils.title_maker("Nix Update")
			cmd_nix_update(config.repo)
		}
		if (cmd_git_diff(config.repo) == 1) {
			utils.title_maker("Git Changes")
			cmd_git_status(config.repo)

			if (utils.confirm("Do you want to add these changes to the stage?", true)) {
				cmd_git_add(config.repo)
			}
		}

		utils.title_maker("Nixos Rebuild")
		cmd_nix_rebuild(config.repo, config.hostname)
		cmd_nix_keep(config.repo, config.keep)

		if (config.diff) {
			utils.title_maker("Nix Diff")
			cmd_nix_diff()
		}
	}
}

