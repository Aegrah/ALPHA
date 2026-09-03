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
