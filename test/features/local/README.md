+elmr means http://hostname/auth/elmr/config is expected to be accessiable
-elmr means http://hostname/auth/elmr/config is expected to be inaccessiable
+env means http://hostname/auth/cgi-bin/* is expected to be accessiable
-env means http://hostname/auth/cgi-bin/* is expected to be inaccessiable

dev = +elmr +env
prod = -elmr -env
