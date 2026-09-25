#!/usr/bin/env bash
set -euo pipefail

output_dir=${1:?usage: capture-sx1-inventory.sh OUTPUT_DIRECTORY}
install -d -m 0700 "$output_dir"

mapfile -t sync_repos < <(pacman-conf --repo-list)

{
  printf 'name\tversion\treason\tforeign\trepository\n'
  while read -r name version; do
    reason=dependency
    pacman -Qqe "$name" >/dev/null 2>&1 && reason=explicit
    foreign=no
    pacman -Qm "$name" >/dev/null 2>&1 && foreign=yes
    repository=foreign
    if [[ $foreign == no ]]; then
      repository=unknown
      for repo in "${sync_repos[@]}"; do
        if pacman -Sl "$repo" 2>/dev/null | awk -v package="$name" '$2 == package { found=1; exit } END { exit !found }'; then
          repository=$repo
          break
        fi
      done
    fi
    printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$version" "$reason" "$foreign" "$repository"
  done < <(LC_ALL=C pacman -Q | sort)
} >"$output_dir/packages.tsv"

LC_ALL=C pacman -Qqe | sort >"$output_dir/explicit-packages.txt"
{
  printf 'unit\tstate\tpreset\n'
  systemctl list-unit-files --state=enabled --no-legend --no-pager \
    | LC_ALL=C sort \
    | awk 'BEGIN { OFS="\t" } { print $1, $2, $3 }'
} >"$output_dir/enabled-units.tsv"
findmnt --raw --noheadings --output TARGET,SOURCE,FSTYPE,OPTIONS \
  | awk 'BEGIN { OFS="\t"; print "target", "source", "fstype", "options" } \
      $1 != "/home" && $3 !~ /^(proc|sysfs|devtmpfs|devpts|tmpfs|cgroup2|securityfs|pstore|bpf|tracefs|debugfs|configfs|fusectl|mqueue|hugetlbfs|autofs)$/ \
      { print $1, $2, $3, $4 }' \
  >"$output_dir/mounts.tsv"
lsblk --json --output NAME,PATH,TYPE,SIZE,FSTYPE,FSVER,LABEL,UUID,PARTUUID,MOUNTPOINTS \
  >"$output_dir/block-devices.json"
{
  printf 'hostname\t%s\n' "$(hostname)"
  printf 'architecture\t%s\n' "$(uname -m)"
  printf 'kernel\t%s\n' "$(uname -r)"
  if [[ -d /sys/firmware/efi ]]; then printf 'boot_mode\tUEFI\n'; else printf 'boot_mode\tBIOS\n'; fi
  printf 'repositories\t%s\n' "${sync_repos[*]}"
  lspci -nnk | sed -n '/VGA compatible controller\|3D controller\|Display controller/,+3p'
} >"$output_dir/system.txt"
