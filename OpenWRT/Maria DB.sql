opkg update
opkg install mariadb-server mariadb-client
/etc/init.d/mysqld enable
mysql_install_db --force --basedir=/usr

/etc/init.d/mysqld start
cat /etc/config/mysqld
uci set mysqld.general.enabled='1'
uci commit mysqld
/etc/init.d/mysqld start
/etc/init.d/mysqld restart

mysql -u root
CREATE USER 'marcelo'@'%' IDENTIFIED BY 'xxxx';
GRANT ALL PRIVILEGES ON *.* TO 'marcelo'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SELECT User, Host FROM mysql.user;
exit

### DEBUG ###
/etc/init.d/mysqld start
ps | grep mysqld
netstat -tuln | grep 3306
grep -r "bind-address" /etc/mysql/
mysqld --verbose
PS C:\Users\Marcelo> Test-NetConnection -ComputerName 192.168.2.1 -Port 3306
