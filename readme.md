Commands

VM Prepare Steps 
(RUN THIS ON VM BEFOREHAND)

sudo apt update
sudo apt install curl git maven openjdk-11-jdk

Run/ Git Clone and Maven once so items are cached
---

git clone https://github.com/spring-projects/spring-petclinic

cd spring-petclinic

./mvnw package

cd ..

Rm -rf spring-petclinic



INFRA

Go To Olly UI

Hamburguer Menu > Data Setup

Linux > Add Connection

Copy Command

curl -sSL https://dl.signalfx.com/splunk-otel-collector.sh > /tmp/splunk-otel-collector.sh && \
sudo sh /tmp/splunk-otel-collector.sh --realm us1 -- 7kGZ__HJWzhTvAa9D_5TDA --mode agent

(see agent)

Hamburguer Menu > Infrastructure > My Data Center

Show Infrastructure


APM
Go to Terminal

git clone https://github.com/spring-projects/spring-petclinic

cd spring-petclinic

./mvnw package -Dmaven.test.skip=true

java -jar target/spring-petclinic-2.4.5.jar

curl localhost:8080

(app is Running)

Hamburger Menu > Data Setup > APM Instrumentation

Java > Add Connection

curl -L https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent-all.jar -o splunk-otel-javaagent.jar

export OTEL_SERVICE_NAME='petclinic'
export OTEL_RESOURCE_ATTRIBUTES='deployment.environment=conf21,version=0.314'
export OTEL_EXPORTER_OTLP_ENDPOINT='http://localhost:4317'

java  -javaagent:./splunk-otel-javaagent.jar -Dsplunk.metrics.enabled=true -jar target/spring-petclinic-2.4.5.jar

curl localhost:8080

Hamburguer Menu > APM 

Main Screen, metrics
APM Map

Traces

LogObserver

(Add setting to fluentd)

Sudo vim /etc/otel/collector/fluentd/conf.d/petclinic.conf

(paste)
<source>
  @type tail
  @label @SPLUNK
  tag petclinic.app
  path /tmp/spring-petclinic.log
  pos_file /tmp/spring-petclinic.pos_file
  read_from_head false
 <parse>
   @type none
 </parse>
</source>

(restart fluentd)
sudo systemctl restart td-agent

(Add LogBack Settings to the folder)
vim /home/ubuntu/spring-petclinic/src/main/resources/logback.xml

(paste XML)

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xml>
<configuration scan="true" scanPeriod="30 seconds">
  <contextListener class="ch.qos.logback.classic.jul.LevelChangePropagator">
     <resetJUL>true</resetJUL>
  </contextListener>
  <!-- <logger name="org.hibernate" level="debug"/> -->
  <logger name="org.springframework.samples.petclinic" level="debug"/>
  <appender name="file" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>/tmp/spring-petclinic.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
      <fileNamePattern>springLogFile.%d{yyyy-MM-dd}.log</fileNamePattern>
      <maxHistory>5</maxHistory>
      <totalSizeCap>1GB</totalSizeCap>
    </rollingPolicy>
    <encoder>
            <pattern>
                    %d{yyyy-MM-dd HH:mm:ss} - %logger{36} - %msg trace_id=%X{trace_id} span_id=%X{span_id} trace_flags=%X{trace_flags} service.name=%property{otel.resource.service.name}, deployment.environment=%property{otel.resource.deployment.environment} %n
    </pattern>
</encoder>
  </appender>
  <root level="debug">
    <appender-ref ref="file" />
  </root>
</configuration>

(repackage app)

./mvnw package -Dmaven.test.skip=true

(run again)
java  -javaagent:./splunk-otel-javaagent.jar -Dsplunk.metrics.enabled=true -jar target/spring-petclinic-2.4.5.jar

curl localhost:8080

Hamburguer Menu > Log Observer > Filter hostname

RUM

Hamburguer Menu > Data Setup > RUM Instrumentation

Next

vim /home/ubuntu/spring-petclinic/src/main/resources/templates/fragments/layout.html

<script src="https://cdn.signalfx.com/o11y-gdi-rum/latest/splunk-otel-web.js" crossorigin="anonymous"></script>
<script>
    SplunkRum.init({
        beaconUrl: "https://rum-ingest.us1.signalfx.com/v1/rum",
        rumAuth: "5iVBi1LYecSG9jfqTUs2vg",
        app: "petclinic",
        environment: "conf21"
        });
</script>

curl localhost:8080

Go to RUM

Show pages/traces/correlation





# Spring PetClinic Sample Application [![Build Status](https://travis-ci.org/spring-projects/spring-petclinic.png?branch=main)](https://travis-ci.org/spring-projects/spring-petclinic/)

## Understanding the Spring Petclinic application with a few diagrams
<a href="https://speakerdeck.com/michaelisvy/spring-petclinic-sample-application">See the presentation here</a>

## Running petclinic locally
Petclinic is a [Spring Boot](https://spring.io/guides/gs/spring-boot) application built using [Maven](https://spring.io/guides/gs/maven/). You can build a jar file and run it from the command line:


```
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
./mvnw package
java -jar target/*.jar
```

You can then access petclinic here: http://localhost:8080/

<img width="1042" alt="petclinic-screenshot" src="https://cloud.githubusercontent.com/assets/838318/19727082/2aee6d6c-9b8e-11e6-81fe-e889a5ddfded.png">

Or you can run it from Maven directly using the Spring Boot Maven plugin. If you do this it will pick up changes that you make in the project immediately (changes to Java source files require a compile as well - most people use an IDE for this):

```
./mvnw spring-boot:run
```

> NOTE: Windows users should set `git config core.autocrlf true` to avoid format assertions failing the build (use `--global` to set that flag globally).

## In case you find a bug/suggested improvement for Spring Petclinic
Our issue tracker is available here: https://github.com/spring-projects/spring-petclinic/issues


## Database configuration

In its default configuration, Petclinic uses an in-memory database (H2) which
gets populated at startup with data. The h2 console is automatically exposed at `http://localhost:8080/h2-console`
and it is possible to inspect the content of the database using the `jdbc:h2:mem:testdb` url.
 
A similar setup is provided for MySql in case a persistent database configuration is needed. Note that whenever the database type is changed, the app needs to be run with a different profile: `spring.profiles.active=mysql` for MySql.

You could start MySql locally with whatever installer works for your OS, or with docker:

```
docker run -e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:5.7.8
```

Further documentation is provided [here](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources/db/mysql/petclinic_db_setup_mysql.txt).

## Working with Petclinic in your IDE

### Prerequisites
The following items should be installed in your system:
* Java 8 or newer (full JDK not a JRE).
* git command line tool (https://help.github.com/articles/set-up-git)
* Your preferred IDE 
  * Eclipse with the m2e plugin. Note: when m2e is available, there is an m2 icon in `Help -> About` dialog. If m2e is
  not there, just follow the install process here: https://www.eclipse.org/m2e/
  * [Spring Tools Suite](https://spring.io/tools) (STS)
  * IntelliJ IDEA
  * [VS Code](https://code.visualstudio.com)

### Steps:

1) On the command line
    ```
    git clone https://github.com/spring-projects/spring-petclinic.git
    ```
2) Inside Eclipse or STS
    ```
    File -> Import -> Maven -> Existing Maven project
    ```

    Then either build on the command line `./mvnw generate-resources` or using the Eclipse launcher (right click on project and `Run As -> Maven install`) to generate the css. Run the application main method by right clicking on it and choosing `Run As -> Java Application`.

3) Inside IntelliJ IDEA
    In the main menu, choose `File -> Open` and select the Petclinic [pom.xml](pom.xml). Click on the `Open` button.

    CSS files are generated from the Maven build. You can either build them on the command line `./mvnw generate-resources` or right click on the `spring-petclinic` project then `Maven -> Generates sources and Update Folders`.

    A run configuration named `PetClinicApplication` should have been created for you if you're using a recent Ultimate version. Otherwise, run the application by right clicking on the `PetClinicApplication` main class and choosing `Run 'PetClinicApplication'`.

4) Navigate to Petclinic

    Visit [http://localhost:8080](http://localhost:8080) in your browser.


## Looking for something in particular?

|Spring Boot Configuration | Class or Java property files  |
|--------------------------|---|
|The Main Class | [PetClinicApplication](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/PetClinicApplication.java) |
|Properties Files | [application.properties](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources) |
|Caching | [CacheConfiguration](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/system/CacheConfiguration.java) |

## Interesting Spring Petclinic branches and forks

The Spring Petclinic "main" branch in the [spring-projects](https://github.com/spring-projects/spring-petclinic)
GitHub org is the "canonical" implementation, currently based on Spring Boot and Thymeleaf. There are
[quite a few forks](https://spring-petclinic.github.io/docs/forks.html) in a special GitHub org
[spring-petclinic](https://github.com/spring-petclinic). If you have a special interest in a different technology stack
that could be used to implement the Pet Clinic then please join the community there.


## Interaction with other open source projects

One of the best parts about working on the Spring Petclinic application is that we have the opportunity to work in direct contact with many Open Source projects. We found some bugs/suggested improvements on various topics such as Spring, Spring Data, Bean Validation and even Eclipse! In many cases, they've been fixed/implemented in just a few days.
Here is a list of them:

| Name | Issue |
|------|-------|
| Spring JDBC: simplify usage of NamedParameterJdbcTemplate | [SPR-10256](https://jira.springsource.org/browse/SPR-10256) and [SPR-10257](https://jira.springsource.org/browse/SPR-10257) |
| Bean Validation / Hibernate Validator: simplify Maven dependencies and backward compatibility |[HV-790](https://hibernate.atlassian.net/browse/HV-790) and [HV-792](https://hibernate.atlassian.net/browse/HV-792) |
| Spring Data: provide more flexibility when working with JPQL queries | [DATAJPA-292](https://jira.springsource.org/browse/DATAJPA-292) |


# Contributing

The [issue tracker](https://github.com/spring-projects/spring-petclinic/issues) is the preferred channel for bug reports, features requests and submitting pull requests.

For pull requests, editor preferences are available in the [editor config](.editorconfig) for easy use in common text editors. Read more and download plugins at <https://editorconfig.org>. If you have not previously done so, please fill out and submit the [Contributor License Agreement](https://cla.pivotal.io/sign/spring).

# License

The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).

[spring-petclinic]: https://github.com/spring-projects/spring-petclinic
[spring-framework-petclinic]: https://github.com/spring-petclinic/spring-framework-petclinic
[spring-petclinic-angularjs]: https://github.com/spring-petclinic/spring-petclinic-angularjs 
[javaconfig branch]: https://github.com/spring-petclinic/spring-framework-petclinic/tree/javaconfig
[spring-petclinic-angular]: https://github.com/spring-petclinic/spring-petclinic-angular
[spring-petclinic-microservices]: https://github.com/spring-petclinic/spring-petclinic-microservices
[spring-petclinic-reactjs]: https://github.com/spring-petclinic/spring-petclinic-reactjs
[spring-petclinic-graphql]: https://github.com/spring-petclinic/spring-petclinic-graphql
[spring-petclinic-kotlin]: https://github.com/spring-petclinic/spring-petclinic-kotlin
[spring-petclinic-rest]: https://github.com/spring-petclinic/spring-petclinic-rest
