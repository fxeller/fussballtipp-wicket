call mvn clean install
rd /s /q C:\Tomcat\apache-tomcat-8.5.66\webapps\ROOT
del /s C:\Tomcat\apache-tomcat-8.5.66\webapps\ROOT.war
copy /y C:\Users\Florian\IdeaProjects\fussballtipp-wicket\target\fussballtipp-1.0.war C:\Tomcat\apache-tomcat-8.5.66\webapps\ROOT.war