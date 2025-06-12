package app

import "../utils"
import "core:fmt"

cmd_git_pull :: proc(repo: string) {
	utils.exec(fmt.tprintf("git -C %s pull", repo))
}

cmd_is_git_diff :: proc(repo: string) -> bool {
	state, err := utils.exec(fmt.tprintf("git -C %s diff --exit-code", repo), false, false)
	if err != nil {
		fmt.panicf("Error running git diff: %s", err)
	}

	return i32(state.exit_code) != 0
}

cmd_git_status :: proc(repo: string) {
	utils.exec(fmt.tprintf("git -C %s status --porcelain", repo))
}

cmd_git_add :: proc(repo: string) {
	utils.exec(fmt.tprintf("git -C %s add .", repo))
}

cmd_nix_update :: proc(repo: string) {
	utils.exec(fmt.tprintf("nix flake update --flake %s", repo))
}

cmd_nix_rebuild :: proc(repo: string, hostname: string) {
	utils.exec(fmt.tprintf("sudo nixos-rebuild switch --flake %s#%s --show-trace", repo, hostname))
}

cmd_nix_keep :: proc(repo: string, keep: int) {
	utils.exec(
		fmt.tprintf(
			"sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +%d",
			keep,
		),
	)
}

cmd_nix_diff :: proc() {
	utils.exec(
		"nix profile diff-closures --profile /nix/var/nix/profiles/system | tac | awk '/Version/{print; exit} 1' | tac",
	)
}

