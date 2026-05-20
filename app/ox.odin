package app

import "../lib/colors"
import "../utils"
import "core:fmt"
import "core:os"


// ox_workflow is the testable core. Returns error instead of panicking.
ox_workflow :: proc(config: ^Config, input: ^os.File = os.stdin) -> (err: os.Error) {
	assert(config != nil)
	assert(input != nil)
	assert(len(config.repo) > 0)
	assert(len(config.hostname) > 0)
	assert(config.keep > 0)

	print_config(config)

	proceed, c_err := utils.confirm(default_value = true, input = input)
	if c_err != nil {
		return c_err
	}
	if !proceed {
		return nil
	}

	utils.title_maker("Git Pull")
	success, pull_err := cmd_git_pull(config.repo)
	if pull_err != nil {
		return pull_err
	}
	if !success {
		fmt.eprintfln("%sError pulling from git%s", colors.RED, colors.RESET)
		return os.General_Error.Invalid_Command
	}

	if config.update {
		utils.title_maker("Nix Update")
		update_err := cmd_nix_update(config.repo)
		if update_err != nil {
			return update_err
		}
	}

	has_diff, diff_err := cmd_is_git_diff(config.repo)
	if diff_err != nil {
		return diff_err
	}

	if has_diff {
		utils.title_maker("Git Changes")
		status_err := cmd_git_status(config.repo)
		if status_err != nil {
			return status_err
		}

		add_proceed, a_err := utils.confirm("Do you want to add these changes to the stage?", true, input)
		if a_err != nil {
			return a_err
		}

		if add_proceed {
			add_err := cmd_git_add(config.repo)
			if add_err != nil {
				return add_err
			}

			still_diff, check_err := cmd_is_git_diff(config.repo)
			if check_err != nil {
				return check_err
			}

			if !still_diff {
				fmt.printfln(
					"%sChanges added to git stage successfully%s",
					colors.GREEN,
					colors.RESET,
				)
			} else {
				fmt.eprintfln("%sError adding changes to git stage%s", colors.RED, colors.RESET)
				return os.General_Error.Invalid_Command
			}
		}
	}

	utils.title_maker("Nixos Rebuild")
	rebuild_err := cmd_nix_rebuild(config.repo, config.hostname)
	if rebuild_err != nil {
		return rebuild_err
	}

	keep_err := cmd_nix_keep(config.repo, config.keep)
	if keep_err != nil {
		return keep_err
	}

	if config.diff {
		utils.title_maker("Nix Diff")
		nix_diff_err := cmd_nix_diff()
		if nix_diff_err != nil {
			return nix_diff_err
		}
	}

	return nil
}


// ox runs the workflow. Returns error for testability.
ox :: proc(config: ^Config, input: ^os.File = os.stdin) -> os.Error {
	assert(config != nil)
	assert(input != nil)
	return ox_workflow(config, input)
}