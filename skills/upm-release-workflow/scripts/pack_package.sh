#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
root_dir="${1:-.}"
destination="${2:-$root_dir}"
package_dir=$("$script_dir/detect_package_dir.sh" "$root_dir")

key_id=$(security find-generic-password -s UPM_SERVICE_ACCOUNT_KEY_ID -w)
key_secret=$(security find-generic-password -s UPM_SERVICE_ACCOUNT_KEY_SECRET -w)
org_id=$(security find-generic-password -s UPM_SERVICE_ACCOUNT_ORG_ID -w)

UPM_SERVICE_ACCOUNT_KEY_ID="$key_id" \
UPM_SERVICE_ACCOUNT_KEY_SECRET="$key_secret" \
upm pack --organization-id "$org_id" --destination "$destination" "$package_dir"
