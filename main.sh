# Only source modules dynamically if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")/modules"
	for module in "$MODULES_DIR"/*.sh; do
		if [[ -f $module ]]; then
			source "$module"
		fi
	done
fi

main() {
	local QUIET=0

	if [[ $# -eq 0 ]]; then
		if [[ $QUIET -ne 1 ]]; then
			print_banner
		fi
		if check_root; then
			usage_root
		else
			usage_user
		fi
		exit 0
	fi

	# Parse command line arguments
	while [[ "$1" != "" ]]; do
		case $1 in
			-q | --quiet )
				QUIET=1
				;;
			-h | --help )
				if check_root; then
					usage_root
				else
					usage_user
				fi
				exit
				;;
			--mitre-matrix )
				display_mitre_matrix
				exit
				;;
			--at )
				shift
				setup_at "$@"
				exit
				;;
			--authorized-keys )
				shift
				setup_authorized_keys "$@"
				exit
				;;
			--backdoor-system-user )
				shift
				setup_backdoor_system_user "$@"
				exit
				;;
			--backdoor-user )
				shift
				setup_backdoor_user "$@"
				exit
				;;
			--bind-shell )
				shift
				setup_bind_shell "$@"
				exit
				;;
			--cap )
				shift
				setup_cap_backdoor "$@"
				exit
				;;
			--create-user )
				shift
				setup_create_new_user "$@"
				exit
				;;
			--cron )
				shift
				setup_cron "$@"
				exit
				;;
			--dbus )
				shift
				setup_dbus "$@"
				exit
				;;
			--generator )
				shift
				setup_generator_persistence "$@"
				exit
				;;
			--git )
				shift
				setup_git_persistence "$@"
				exit
				;;
			--grub )
				shift
				setup_grub "$@"
				exit
				;;
			--initd )
				shift
				setup_initd_backdoor "$@"
				exit
				;;
			--initramfs )
				shift
				setup_initramfs "$@"
				exit
				;;
			--ld-preload )
				shift
				setup_ld_preload_backdoor "$@"
				exit
				;;
			--lkm )
				shift
				setup_lkm_backdoor "$@"
				exit
				;;
			--malicious-container )
				shift
				setup_malicious_docker_container "$@"
				exit
				;;
			--malicious-package )
				shift
				setup_malicious_package "$@"
				exit
				;;
			--motd )
				shift
				setup_motd_backdoor "$@"
				exit
				;;
			--network-manager )
				shift
				setup_network_manager "$@"
				exit
				;;
			--package-manager )
				shift
				setup_package_manager_persistence "$@"
				exit
				;;
			--pam )
				shift
				setup_pam_persistence "$@"
				exit
				;;
			--passwd-user )
				shift
				setup_passwd_user "$@"
				exit
				;;
			--password-change )
				shift
				setup_password_change "$@"
				exit
				;;
			--polkit )
				shift
				setup_polkit "$@"
				exit
				;;
			--rc-local )
				shift
				setup_rc_local_backdoor "$@"
				exit
				;;
			--reverse-shell )
				shift
				setup_reverse_shell "$@"
				exit
				;;
			--rootkit )
				shift
				setup_rootkit "$@"
				exit
				;;
			--shell-profile )
				shift
				setup_shell_profile "$@"
				exit
				;;
			--ssh-key )
				shift
				setup_ssh_key "$@"
				exit
				;;
			--sudoers )
				shift
				setup_sudoers_backdoor "$@"
				exit
				;;
			--suid )
				shift
				setup_suid_backdoor "$@"
				exit
				;;
			--system-binary )
				shift
				setup_system_binary_backdoor "$@"
				exit
				;;
			--systemd )
				shift
				setup_systemd "$@"
				exit
				;;
			--tmpfiles )
				shift
				setup_tmpfiles "$@"
				exit
				;;
			--udev )
				shift
				setup_udev "$@"
				exit
				;;
			--web-shell )
				shift
				setup_web_shell "$@"
				exit
				;;
			--xdg )
				shift
				setup_xdg "$@"
				exit
				;;
			--revert )
				shift
				if [[ -z $1 ]]; then
					echo "Error: Missing module name. Use '--revert all' to revert all modules or specify a module name."
					echo ""
					echo "Example 1: ./panix.sh --revert malicious-package"
					echo "Example 2: ./panix.sh --revert all"
					echo "Example 3: ./panix.sh --revert-all"
					echo ""
					echo "Modules: all, at, authorized-keys, backdoor-user, bind-shell, cap, create-user, cron, malicious-container, generator, git, initd, ld-preload, lkm, malicious-package, motd, package-manager, pam, passwd-user, password-change, rc-local, rootkit, shell-profile, ssh-key, sudoers, suid, system-binary, systemd, tmpfiles, udev, xdg"
					echo ""
					exit 1
				fi

				# Check if "all" is specified
				if [[ "$1" == "all" ]]; then
					echo "[+] Running full reversion with --revert-all..."
					revert_all
					exit
				fi

				# Replace hyphens with underscores for function names
				MODULE_NAME="revert_${1//-/_}"

				if type "$MODULE_NAME" &>/dev/null; then
					echo ""
					echo "################## [+] Reverting $1 module... "##################
					echo ""
					$MODULE_NAME  # Execute the function
				else
					echo ""
					echo "Error: Revert function for module '$1' not found."
					echo ""
					exit 1
				fi
				exit
				;;
			--revert-all )
				revert_all
				exit
				;;
			* )
				echo "Invalid option: $1"
				if check_root; then
					usage_root
				else
					usage_user
				fi
				exit 1
		esac
		shift
	done

	# Print banner unless in quiet mode
	if [[ $QUIET -ne 1 ]]; then
		print_banner
	fi

	# Show the usage menu if no specific command is given
	if check_root; then
		usage_root
	else
		usage_user
	fi
}

main "$@"
