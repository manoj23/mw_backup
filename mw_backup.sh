#!/bin/sh

mw_var()
{
	mw_local_settings=$1
	mw_var=$2

	sed -n "s/^\$$mw_var = \"\(.*\)\";/\1/p" "$mw_local_settings"
}

mw_backup()
{
	mw_root=$1
	mw_backup_output=$2
	mw_local_settings="$mw_root/LocalSettings.php"
	mw_local_settings_backup=$(mktemp)
	mw_db_type=$(mw_var "$mw_local_settings" "wgDBtype")
	mw_db_server=$(mw_var "$mw_local_settings" "wgDBserver")
	mw_db_name=$(mw_var "$mw_local_settings" "wgDBname")
	mw_db_user=$(mw_var "$mw_local_settings" "wgDBuser")
	mw_db_password=$(mw_var "$mw_local_settings" "wgDBpassword")

	[ "$mw_db_type" != "mysql" ] && echo "$mw_db_type is not supported" && exit 1
	[ ! -d "$mw_backup_output" ] && echo "$mw_backup_output directory does not exist" && exit 2
	[ ! -d "$mw_backup_output/.git" ] && echo "$mw_backup_output directory is not a git repository" && exit 3

	cp -p "$mw_local_settings" "$mw_local_settings_backup"
	cp "$mw_local_settings" "$mw_backup_output"
	echo "\$wgReadOnly = 'Dumping Database, Access will be restored shortly';" >> "$mw_local_settings"

	if mysqldump -h "$mw_db_server" -u "$mw_db_user" "$mw_db_name" \
		--default-character-set=utf8 > "$mw_backup_output/mw-db.sql"; then
			(cd "$mw_backup_output" \
				&& mw_commit_message="$(date --iso-8601) - $(tail -n 1 mw-db.sql)" \
				&& sed -i '$ d' mw-db.sql \
				&& git add mw-db.sql LocalSettings.php \
				&& git commit -m "$mw_commit_message")
	else
		echo "mysqldump failed"
	fi

	mv "$mw_local_settings_backup" "$mw_local_settings"
}
