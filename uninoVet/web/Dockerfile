# Painel em Java (JSP/Servlet) rodando no Tomcat.
# Compila os servlets na propria imagem, entao nao precisa de Maven nem de
# instalar nada na maquina.
FROM tomcat:9.0-jdk17-temurin

# Troca a aplicacao padrao do Tomcat pela nossa (fica na raiz: /).
RUN rm -rf /usr/local/tomcat/webapps/ROOT
WORKDIR /usr/local/tomcat/webapps/ROOT

# Paginas (JSP e CSS).
COPY webapp/ ./

# Driver do MySQL.
RUN mkdir -p WEB-INF/lib WEB-INF/classes
ADD https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar WEB-INF/lib/mysql-connector-j.jar

# Compila o codigo Java.
COPY src/ /tmp/src/
RUN javac -cp "/usr/local/tomcat/lib/servlet-api.jar:WEB-INF/lib/mysql-connector-j.jar" \
      -d WEB-INF/classes $(find /tmp/src -name "*.java")

EXPOSE 8080
