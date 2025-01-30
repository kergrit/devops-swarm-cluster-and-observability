#!/bin/sh
# mkdir -p /etc/ssl/private
# openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt -subj "/C=TH/ST=Bangkok/L=Latprao /O=YDMThailand/OU=DevOps/CN=aws.ydmthailand.com/emailAddress=kergrit@gmail.com"

FTP_DATA=/home/$FTP_USER
FTP_GROUP=$( getent group "$GID" | awk -F ':' '{print $1}' )

if test -z "$FTP_GROUP"; then
	FTP_GROUP=$FTP_USER
	addgroup -g "$GID" -S "$FTP_GROUP"
fi

adduser -D -G "$FTP_GROUP" -h "$FTP_DATA" -s "/bin/false" -u "$UID" "$FTP_USER"

mkdir -p $FTP_DATA
chown -R "$FTP_USER:$FTP_GROUP" "$FTP_DATA"
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

sed -i -r "s/0.0.0.0/$PUBLIC_IP/g" /etc/vsftpd.conf

### kergrit added for multiple users inspired by https://github.com/wildscamp/docker-vsftpd
for VARIABLE in $(env); do
    if [[ "${VARIABLE}" =~ ^VSFTPD_USER_[[:digit:]]+=.*$ ]]; then
			# remove VSFTPD_USER_:digit:= from beginning of variable
			VARIABLE="$(echo ${VARIABLE} | cut -d'=' -f2)"

			if [ "$(echo ${VARIABLE} | awk -F ':' '{ print NF }')" -ne 3 ]; then
					echo "'${VARIABLE}' user has invalid syntax. Skipping. | Must be USER:PASSWORD:UID"
					continue
			fi

			VSFTPD_USER_NAME="$(echo ${VARIABLE} | cut -d':' -f1)"
			VSFTPD_USER_PASS="$(echo ${VARIABLE} | cut -d':' -f2)"
			VSFTPD_USER_ID="$(echo ${VARIABLE} | cut -d':' -f3)"			

			FTP_USER=$VSFTPD_USER_NAME
			FTP_PASS=$VSFTPD_USER_PASS
			UID=$VSFTPD_USER_ID
			GID=$VSFTPD_USER_ID
						
			FTP_DATA=/home/$FTP_USER
			FTP_GROUP=$( getent group "$GID" | awk -F ':' '{print $1}' )

			if test -z "$FTP_GROUP"; then
				FTP_GROUP=$FTP_USER
				addgroup -g "$GID" -S "$FTP_GROUP"
			fi

			adduser -D -G "$FTP_GROUP" -h "$FTP_DATA" -s "/bin/false" -u "$UID" "$FTP_USER"

			mkdir -p $FTP_DATA
			chown -R "$FTP_USER:$FTP_GROUP" "$FTP_DATA"
			echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

# cat << EOB
# USER SETTINGS
# ---------------
# . FTP User: $VSFTPD_USER_NAME
# . FTP Password: $VSFTPD_USER_PASS
# . System UID: $VSFTPD_USER_ID
# . FTP Home Dir: $VSFTPD_USER_HOME_DIR

# EOB
    fi
done

touch /var/log/vsftpd.log
tail -f /var/log/vsftpd.log | tee /dev/stdout &
touch /var/log/xferlog
tail -f /var/log/xferlog | tee /dev/stdout &

exec "$@"
