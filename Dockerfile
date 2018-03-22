FROM tomcat:8-jre8

ADD docker/context.xml /usr/local/tomcat/webapps/manager/META-INF/
ADD docker/tomcat-users.xml /usr/local/tomcat/conf/

ADD target/fussballtipp-1.0.war /usr/local/tomcat/webapps/fussballtipp.war

CMD ["catalina.sh", "run"] 