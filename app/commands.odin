#+private
package app

import "../utils"
import "core:fmt"
import "core:os"


cmd_git_pull :: proc(repo: string) -> (success: bool, err: os.Error) {
	assert(len(repo) > 0)
	result, e := utils.exec(fmt.tprintf("git -C %s pull", repo))
	if e != nil {
		return false, e
	}
	return result.success, nil
}

cmd_is_git_diff :: proc(repo: string) -> (has_diff: bool, err: os.Error) {
	assert(len(repo) > 0)
	result, e := utils.exec(fmt.tprintf("git -C %s diff --exit-code", repo), false, false)
	if e != nil {
		return false, e
	}
	return !result.success, nil
}

cmd_git_status :: proc(repo: string) -> os.Error {
	assert(len(repo) > 0)
	_, err := utils.exec(fmt.tprintf("git -C %s status --porcelain", repo))
	return err
}

cmd_git_add :: proc(repo: string) -> os.Error {
	assert(len(repo) > 0)
	_, err := utils.exec(fmt.tprintf("git -C %s add .", repo))
	return err
}

cmd_nix_update :: proc(repo: string) -> os.Error {
	assert(len(repo) > 0)
	_, err := utils.exec(fmt.tprintf("nix flake update --flake %s", repo))
	return err
}

cmd_nix_rebuild :: proc(repo: string, hostname: string) -> os.Error {
	assert(len(repo) > 0)
	assert(len(hostname) > 0)
	_, err := utils.exec(fmt.tprintf("sudo nixos-rebuild switch --flake %s#%s --show-trace", repo, hostname))
	return err
}

cmd_nix_keep :: proc(repo: string, keep: int) -> os.Error {
	assert(len(repo) > 0)
	assert(keep > 0)
	_, err := utils.exec(
		fmt.tprintf(
			"sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +%d",
			keep,
		),
	)
	return err
}

cmd_nix_diff :: proc() -> os.Error {
	_, err := utils.exec(
		"nix profile diff-closures --profile /nix/var/nix/profiles/system | tac | awk '/Version/{print; exit} 1' | tac",
	)
	return err
}