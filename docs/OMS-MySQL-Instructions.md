# MySQL Log Monitoring Solution for Operations Management Suite

1. Setup a Linux(Ubuntu/Redhat) machine and install [MySQL](http://dev.mysql.com/doc/refman/5.7/en/installing.html).

2. Download and Install [OMS Agent for Linux](https://github.com/Microsoft/OMS-Agent-for-Linux) on the machine. 

3. Configure MySQL to generate slow, error and general logs.

4. Verify and update the MySQL log file path in the configuration file ```/etc/opt/microsoft/omsagent/conf/omsagent.d/mysql_logs.conf```

  ```config
  # MySql General Log
  
  <source>
    ...
    path <MySQL-file-path-for-general-logs>
    ...
  </source>
  
  # MySql Error Log
  
  <source>
    ...
    path <MySQL-file-path-for-error-logs>
    ...
  </source>
  
  # MySql Slow Query Log
  
  <source>
    ...
    path <MySQL-file-path-for-slow-query-logs>
    ...
  </source>
  ```

5. Restart the MySQL daemon:
```sudo service mysql restart``` or ```/etc/init.d/mysqld restart```

6. Restart the OMS agent:
```sudo service omsagent restart```


7. Confirm that there are no errors in the OMS Agent log:  
```tail /var/opt/microsoft/omsagent/log/omsagent.log```

Go to OMS Log Analysis and see whether you can find any search results
![MySQLSearchView](pictures/MySQLSearchView.PNG?raw=true)




If you encounter the following error in ```omsagent.log```:  
```[error]: Permission denied @ rb_sysopen - <MySQL-file-path-for-logs>```

1. Ensure that the user ```omsagent``` has read permissions on the parent directory and contained log files:  
```chmod +r <MySQL-file-path-for-logs>```
  
2. If your machine has logrotate enabled, the new log files that get rotated in may cause this error to resurface. Check the logrotate configuration file (e.g. ```/etc/logrotate.d/mysql-server```) for the permissions it assigns new log files. To ensure that the user ```omsagent``` has read permissions on newly-created log files, here are two options:

 a. Identify the file group for the log files, and add the user ```omsagent``` to the file group:
  ```commands
  ls -l <MySQL-file-path-for-slow-query-logs>
  usermod -aG <file-group> omsagent
  ```  
 
 b. Modify the logrotate configuration file to assign new log files read permissions to all users:  
Change ```create 640 mysql adm``` to ```create 644 mysql adm```

3. After changing file permissions, the OMS agent should be restarted:  
```sudo service omsagent restart```
