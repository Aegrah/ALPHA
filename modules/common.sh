RED='\033[0;31m'
NC='\033[0m'

print_banner() {
	echo ""
	echo " __                      "
	echo "|__)  /\  |\\ | | \\_/   "
	echo "|    /~~\\ | \\| | / \\  "
	echo "                         "
	echo "@RFGroenewoud"
	echo ""
}

check_root() {
	if [[ $EUID -ne 0 ]]; then
		return 1
	else
		return 0
	fi
}

usage_user() {
	echo -e "${RED}[!] Warning: More features are available when running as root.${NC}"
	echo ""
	echo "Low Privileged User Options:"
	echo ""
	echo "  --at                   At job persistence"
	echo "  --authorized-keys      Add public key to authorized keys"
	echo "  --bind-shell           Execute backgrounded bind shell (supports multiple LOLBins)"
	echo "  --cron                 Cron job persistence"
	echo "  --git                  Git persistence"
	echo "  --malicious-container  Docker container with host escape (requires docker group permissions)"
	echo "  --reverse-shell        Reverse shell persistence (supports multiple LOLBins)"
	echo "  --shell-profile        Shell profile persistence"
	echo "  --ssh-key              SSH key persistence"
	echo "  --systemd              Systemd service persistence"
	echo "  --tmpfiles             systemd-tmpfiles.d persistence"
	echo "  --web-shell            Web shell persistence (PHP/Python)"
	echo "  --xdg                  XDG autostart persistence"
	echo "  --revert               Revert most changes made by PANIX' default options"
	echo "  --mitre-matrix         Display the MITRE ATT&CK Matrix for PANIX"
	echo "  --quiet (-q)           Quiet mode (no banner)"
}

usage_root() {
	echo ""
	echo "Root User Options:"
	echo ""
	echo "  --at                   At job persistence"
	echo "  --authorized-keys      Add public key to authorized keys"
	echo "  --backdoor-user        Create backdoor user"
	echo "  --backdoor-system-user Create backdoor system user"
	echo "  --bind-shell           Execute backgrounded bind shell (supports multiple LOLBins)"
	echo "  --cap                  Add capabilities persistence"
	echo "  --create-user          Create a new user"
	echo "  --cron                 Cron job persistence"
	echo "  --dbus                 D-Bus service persistence"
	echo "  --generator            Generator persistence"
	echo "  --git                  Git hook/pager persistence"
	echo "  --grub                 GRUB bootloader persistence"
	echo "  --initd                SysV Init (init.d) persistence"
	echo "  --initramfs            Initramfs persistence"
	echo "  --ld-preload           LD_PRELOAD backdoor persistence"
	echo "  --lkm                  Loadable Kernel Module (LKM) persistence"
	echo "  --malicious-container  Docker container with host escape"
	echo "  --malicious-package    Build and Install a package for persistence (DPKG/RPM)"
	echo "  --motd                 Message Of The Day (MOTD) persistence (not available on RHEL derivatives)"
	echo "  --network-manager      NetworkManager dispatcher script persistence"
	echo "  --package-manager      Package Manager persistence (APT/YUM/DNF)"
	echo "  --pam                  Pluggable Authentication Module (PAM) persistence (backdoored PAM & pam_exec)"
	echo "  --passwd-user          Add user to /etc/passwd directly"
	echo "  --password-change      Change user password"
	echo "  --polkit               Allow pkexec as any user through Polkit"
	echo "  --rc-local             Run Control (rc.local) persistence"
	echo "  --reverse-shell        Reverse shell persistence (supports multiple LOLBins)"
	echo "  --rootkit              Diamorphine (LKM) rootkit persistence"
	echo "  --shell-profile        Shell profile persistence"
	echo "  --ssh-key              SSH key persistence"
	echo "  --sudoers              Sudoers persistence"
	echo "  --suid                 SUID persistence"
	echo "  --system-binary        System binary persistence"
	echo "  --systemd              Systemd service persistence"
	echo "  --tmpfiles             systemd-tmpfiles.d persistence"
	echo "  --udev                 Udev (driver) persistence"
	echo "  --web-shell            Web shell persistence (PHP/Python)"
	echo "  --xdg                  XDG autostart persistence"
	echo "  --revert               Revert most changes made by PANIX' default options"
	echo "  --mitre-matrix         Display the MITRE ATT&CK Matrix for PANIX"
	echo "  --quiet (-q)           Quiet mode (no banner)"
	echo ""
}

# All revert functions
revert_all() {
	echo "[+] Reverting all modules..."
	
	local modules=(
		revert_at
		revert_authorized_keys
		revert_backdoor_user
		revert_bind_shell
		revert_cap
		revert_create_user
		revert_cron
		revert_dbus
		revert_generator
		revert_git
		revert_grub
		revert_initd
		revert_initramfs
		revert_ld_preload
		revert_lkm
		revert_malicious_container
		revert_malicious_package
		revert_motd_backdoor
		revert_network_manager
		revert_package_manager
		revert_pam
		revert_passwd_user
		revert_password_change
		revert_polkit
		revert_rc_local
		revert_reverse_shell
		revert_rootkit
		revert_shell_profile
		revert_ssh_key
		revert_sudoers
		revert_suid
		revert_system_binary
		revert_systemd
		revert_tmpfiles
		revert_udev
		revert_web_shell
		revert_xdg
	)

	# Disable exit on error
	set +e

	for module in "${modules[@]}"; do
		echo ""
		echo "######################### [+] Reverting $module... #########################"
		echo ""

		# Check if the module exists
		if ! command -v "$module" &>/dev/null; then
			echo "[-] Function $module not found. Skipping..."
			continue
		fi

		# Execute the module and capture its exit status
		"$module"
		local exit_code=$?
		if [[ $exit_code -eq 0 ]]; then
			echo ""
			echo "[+] $module reverted successfully."
			echo ""
		else
			echo ""
			echo "[-] Failed to revert $module. Exit Code: $exit_code"
			echo ""
		fi
	done

	# Re-enable exit on error
	set -e

	echo "[+] Reversion of all modules complete."
}

